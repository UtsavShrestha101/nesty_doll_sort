import 'package:nesty_core/src/codec/json_values.dart';
import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/models/doll.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/move_result.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/models/session_types.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_check.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:nesty_core/src/rules/rules.dart';
import 'package:nesty_core/src/session/game_session.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// What [GameSessionCodec.decode] produced: a [session] resumed at the saved
/// board with its undo history and `undosUsed`, or the [issues] that made
/// the saved JSON unusable. The game then restarts the level (spec §13.3:
/// "Otherwise the level restarts").
final class GameSessionDecodeResult {
  GameSessionDecodeResult({this.session, List<LevelIssue> issues = const []})
    : issues = List.unmodifiable(issues);

  /// The resumed session. Null exactly when [issues] contains an error.
  final GameSession? session;

  final List<LevelIssue> issues;

  /// True when a session was decoded.
  bool get isOk => session != null;

  @override
  bool operator ==(Object other) =>
      other is GameSessionDecodeResult &&
      identical(other.session, session) &&
      listEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(session, Object.hashAll(issues));

  @override
  String toString() => 'GameSessionDecodeResult(ok: $isOk, $issues)';
}

/// A [GameSession] in progress to JSON and back: the in-progress level of
/// the save (spec §13.3 `inProgress.state` and `undo`; M3 acceptance "kill
/// the app mid-level and it resumes exactly where it was").
///
/// The contract is docs/plans/m3-design.md §4 (D69). Format 1:
///
/// ```text
/// { "format": 1, "levelId": "L0024", "undosUsed": 1,
///   "state":   <board>,
///   "history": [ {"before": <board>, "move": ["r0c2", "r0c0"]}, … ] }
///                                            oldest first
/// <board> = { "moves": 12, "sets": 1, "extra": 1, "opened": ["r1c0"],
///             "slots": { "r0c0": [["red4", "red3"]], "r0c1": [], "x0": [] } }
/// ```
///
/// - `slots` has exactly the board's `GameState.slotIds` (grid, then the
///   active extra slots), each with its nests bottom to top in the level
///   codec's doll tokens (spec §5.1). Ice is derived from `sets` and not
///   stored. `opened` is the engine's opened mask: the towers that emptied
///   and the cases that broke, in `slotIds` order. Which cases broke also
///   follows from which colors completed, and [decode] checks the two agree.
/// - A history entry stores the board before its move, with that board's
///   own extra slots. The move's events are not stored: [decode] re-derives
///   them with `Rules.tryMove`, which also proves the history leads to the
///   next board (the next entry's `before`, or `state`) once that board's
///   extra slots are added.
/// - [encode] writes keys in the order above, so `jsonEncode(encode(s))` is
///   a stable string. For every session `s` of a level `l`,
///   `decode(encode(s), l).session` has an equal `state`, an equal
///   `history` (events included) and the same `undosUsed`, and encodes to
///   the same JSON.
///
/// [decode] checks in this order and stops after the first group that
/// fails, with one issue per problem, each with a JSON pointer:
/// 1. `format` is 1 (else `session.unsupportedFormat` and nothing more is
///    read); the keys, JSON types and doll tokens (`schema.missingField`,
///    `schema.unknownField`, `schema.wrongType`, `doll.badToken`, and
///    `gold.notSupported` since gold is v1.1). Unknown keys are reported per
///    object after its known fields, sorted (JSON object key order is not
///    portable to the web). `schema.wrongType`'s `expected` is `object`,
///    `array`, `string`, `integer` or `pair` (a `move`: two slot ids); its
///    `field` names a key, or `session`, `entry` (a history element),
///    `slotId`, `slot`, `nest` or `doll` for unnamed values.
/// 2. `levelId` is the level's id (`session.levelMismatch`).
/// 3. Every board, `state` first, is one the level can be in
///    (`session.badBoard`, one per board): `extra` 0–2, `sets` 0 up to the
///    level's sets, `moves` 0 up to 2^31 − 1 (the engine's counter); the
///    slot ids are exactly the board's; `opened` names slots of the board
///    once each; every nest is one color in consecutive decreasing sizes up
///    to `maxSize` and not a full set (spec §2.1); an open slot, a case and
///    an emptied tower hold at most one nest and a standing tower at most
///    its starting depth; the kernel's invariants that `SolverSnapshot`
///    also enforces (the dolls that left are whole sets, `sets` of them);
///    and nothing play can't reach (a case is broken exactly when a set of
///    its color is complete; iced and locked slots hold their starting
///    nests; a standing tower changed only at its top).
/// 4. The history replays (`session.badHistory`, one per entry): each move
///    is applied by `Rules.tryMove`, completes no set (a completion clears
///    the history, spec §2.4), and gives the next board once that board's
///    extra slots, never fewer, are added.
/// 5. `undosUsed` is not negative (`schema.valueOutOfRange`).
///
/// Pure and web-safe (CLAUDE.md rules 2, 7; D11): no `dart:io`, integers
/// read by value like `LevelCodec` (D29), and never a throw.
abstract final class GameSessionCodec {
  /// The `format` this codec reads and writes.
  static const int format = 1;

  /// The session [session] as a JSON map in canonical key order.
  ///
  /// Unmodifiable at every level: each board's JSON is built once per
  /// `GameState` and shared by later calls, so saving after every move
  /// (spec §13.3) only builds the boards that are new since the last save.
  static Map<String, Object?> encode(GameSession session) =>
      Map.unmodifiable(<String, Object?>{
        _Keys.format: format,
        _Keys.levelId: session.level.id,
        _Keys.undosUsed: session.undosUsed,
        _Keys.state: _board(session.state),
        _Keys.history: List<Object?>.unmodifiable([
          for (final entry in session.history)
            Map<String, Object?>.unmodifiable(<String, Object?>{
              _Keys.before: _board(entry.before),
              _Keys.move: List<String>.unmodifiable([
                entry.move.from,
                entry.move.to,
              ]),
            }),
        ]),
      });

  /// Resumes a session of [level] from [json], an already-parsed JSON value
  /// written by [encode]. Never throws: anything unusable (another format,
  /// another level id, a board the engine rejects, a history that doesn't
  /// replay) is reported in the result's issues, with no session.
  ///
  /// The session plays [level] itself, so [level] only has to equal the
  /// level that was saved (a level decoded again from its JSON will do).
  static GameSessionDecodeResult decode(Object? json, Level level) =>
      _SessionDecoder(level).decode(json);

  // Boards are immutable, so their JSON is too: cached per state (by
  // identity), a board already in the history is not encoded again.
  static final Expando<Map<String, Object?>> _boards = Expando(
    'GameSessionCodec board',
  );

  static Map<String, Object?> _board(GameState state) =>
      _boards[state] ??= _encodeBoard(state);

  static Map<String, Object?> _encodeBoard(GameState state) {
    final ids = state.slotIds;
    final opened = GameStateBoard.peek(state).openedMask;
    return Map.unmodifiable(<String, Object?>{
      _Keys.moves: state.moveCount,
      _Keys.sets: state.completedSets,
      _Keys.extra: state.extraSlotCount,
      _Keys.opened: List<String>.unmodifiable([
        for (var i = 0; i < ids.length; i++)
          if (((opened >> i) & 1) == 1) ids[i],
      ]),
      _Keys.slots: Map<String, Object?>.unmodifiable(<String, Object?>{
        for (final id in ids)
          id: List<Object?>.unmodifiable([
            // A slot view lists its nests bottom to top (spec §3.2).
            for (final nest in state.slot(id).nests)
              List<String>.unmodifiable([
                for (final doll in nest.dolls) doll.token,
              ]),
          ]),
      }),
    });
  }
}

/// The JSON keys of format 1.
abstract final class _Keys {
  static const format = 'format';
  static const levelId = 'levelId';
  static const undosUsed = 'undosUsed';
  static const state = 'state';
  static const history = 'history';

  static const before = 'before';
  static const move = 'move';

  static const moves = 'moves';
  static const sets = 'sets';
  static const extra = 'extra';
  static const opened = 'opened';
  static const slots = 'slots';

  static const Set<String> session = {
    format,
    levelId,
    undosUsed,
    state,
    history,
  };
  static const Set<String> entry = {before, move};
  static const Set<String> board = {moves, sets, extra, opened, slots};
}

/// The `expected` arg of `schema.wrongType`.
abstract final class _Expected {
  static const object = 'object';
  static const array = 'array';
  static const string = 'string';
  static const integer = 'integer';
  static const pair = 'pair';
}

/// A board as read in group 1: typed, not yet checked against the level.
final class _RawBoard {
  _RawBoard({
    required this.path,
    required this.name,
    required this.moves,
    required this.sets,
    required this.extra,
    required this.opened,
    required this.slots,
  });

  /// Its JSON pointer segments, such as `['history', 2, 'before']`.
  final List<Object> path;

  /// `state` or `history/<i>`, the `board` arg of `session.badBoard`.
  final String name;

  final int moves;
  final int sets;
  final int extra;
  final List<String> opened;

  /// Slot id → its nests bottom to top, each as dolls outer to inner.
  final Map<String, List<List<Doll>>> slots;
}

/// A history entry as read in group 1.
final class _RawEntry {
  _RawEntry(this.before, this.move);

  final _RawBoard before;
  final Move move;
}

/// A board read in group 3: its [state], or the [problem] (and the slot it
/// is about) that stopped it.
final class _Built {
  _Built.ok(GameState this.state) : problem = '', slotId = null;

  _Built.bad(this.problem, [this.slotId]) : state = null;

  final GameState? state;
  final String problem;
  final String? slotId;
}

/// One decode: collects issues while it walks the document in order.
final class _SessionDecoder {
  _SessionDecoder(this._level);

  final Level _level;
  final List<LevelIssue> _issues = [];
  int _errors = 0;

  GameSessionDecodeResult decode(Object? json) {
    // Group 1: the format, then keys, types and tokens.
    final root = _asMap(json, const [], 'session');
    if (root == null) return _done();
    if (root.containsKey(_Keys.format)) {
      final found = JsonValues.integer(root[_Keys.format]);
      if (found == null) {
        _wrongType(const [_Keys.format], _Keys.format, _Expected.integer);
      } else if (found != GameSessionCodec.format) {
        // Another format has another shape, so nothing more is read.
        _add(
          IssueCodes.sessionUnsupportedFormat,
          'Session format $found is not supported (this build reads '
          '${GameSessionCodec.format})',
          const [_Keys.format],
          args: {'found': found},
        );
        return _done();
      }
    } else {
      _missing(_Keys.format, const []);
    }
    final levelId = _requiredString(root, _Keys.levelId);
    final undosUsed = _requiredInt(root, _Keys.undosUsed, const []);
    final state = root.containsKey(_Keys.state)
        ? _board(root[_Keys.state], const [_Keys.state], _Keys.state, 'state')
        : _missing(_Keys.state, const []);
    final history = _history(root);
    _rejectUnknownKeys(root, _Keys.session, const []);
    if (_errors > 0 ||
        levelId == null ||
        undosUsed == null ||
        state == null ||
        history == null) {
      return _done();
    }

    // Group 2: the level.
    if (levelId != _level.id) {
      _add(
        IssueCodes.sessionLevelMismatch,
        'The session is for level $levelId, not ${_level.id}',
        const [_Keys.levelId],
        args: {'expected': _level.id, 'found': levelId},
      );
      return _done();
    }

    // Group 3: every board is a board of the level.
    final BoardLayout layout;
    try {
      layout = BoardLayout.of(_level);
    } on ArgumentError catch (error) {
      // GameSession(level) would throw the same: no board can be resumed.
      _add(
        IssueCodes.sessionBadBoard,
        'The engine cannot lay out level ${_level.id}: ${error.message}',
        const [_Keys.state],
        args: {'board': state.name},
      );
      return _done();
    }
    final stateBoard = _checkedBoard(state, layout);
    final befores = [
      for (final entry in history) _checkedBoard(entry.before, layout),
    ];
    if (_errors > 0) return _done();

    // Group 4: the history replays through the rules.
    final entries = <UndoEntry>[];
    for (var i = 0; i < history.length; i++) {
      final before = befores[i]!;
      final next = i + 1 < history.length ? befores[i + 1]! : stateBoard!;
      final entry = _replay(i, before, history[i].move, next);
      if (entry != null) entries.add(entry);
    }
    if (_errors > 0) return _done();

    // Group 5: undosUsed.
    if (undosUsed < 0) {
      _add(
        IssueCodes.valueOutOfRange,
        'undosUsed must be 0 or more (got $undosUsed)',
        const [_Keys.undosUsed],
        args: {
          'field': _Keys.undosUsed,
          'value': undosUsed,
          'min': 0,
          'max': JsonValues.maxInteger,
        },
      );
      return _done();
    }

    return _done(
      GameSession.restore(_level, stateBoard!, entries, undosUsed: undosUsed),
    );
  }

  GameSessionDecodeResult _done([GameSession? session]) =>
      GameSessionDecodeResult(
        session: _errors > 0 ? null : session,
        issues: _issues,
      );

  // --- Group 1: shapes ---

  List<_RawEntry>? _history(Map<Object?, Object?> root) {
    const path = [_Keys.history];
    if (!root.containsKey(_Keys.history)) return _missing(_Keys.history, []);
    final list = _asList(root[_Keys.history], path, _Keys.history);
    if (list == null) return null;
    final entries = <_RawEntry>[];
    var ok = true;
    for (var i = 0; i < list.length; i++) {
      final entry = _entry(list[i], i);
      if (entry == null) {
        ok = false;
      } else {
        entries.add(entry);
      }
    }
    return ok ? entries : null;
  }

  _RawEntry? _entry(Object? value, int index) {
    final path = <Object>[_Keys.history, index];
    final map = _asMap(value, path, 'entry');
    if (map == null) return null;
    final before = map.containsKey(_Keys.before)
        ? _board(
            map[_Keys.before],
            [...path, _Keys.before],
            _Keys.before,
            '${_Keys.history}/$index',
          )
        : _missing(_Keys.before, path);
    final move = map.containsKey(_Keys.move)
        ? _move(map[_Keys.move], [...path, _Keys.move])
        : _missing(_Keys.move, path);
    _rejectUnknownKeys(map, _Keys.entry, path);
    return before == null || move == null ? null : _RawEntry(before, move);
  }

  Move? _move(Object? value, List<Object> path) {
    if (value is! List || value.length != 2) {
      _wrongType(path, _Keys.move, _Expected.pair);
      return null;
    }
    final from = _asString(value[0], [...path, 0], 'slotId');
    final to = _asString(value[1], [...path, 1], 'slotId');
    return from == null || to == null ? null : Move(from, to);
  }

  _RawBoard? _board(
    Object? value,
    List<Object> path,
    String field,
    String name,
  ) {
    final map = _asMap(value, path, field);
    if (map == null) return null;
    final errorsBefore = _errors;
    final moves = _requiredInt(map, _Keys.moves, path);
    final sets = _requiredInt(map, _Keys.sets, path);
    final extra = _requiredInt(map, _Keys.extra, path);
    final opened = _opened(map, path);
    final slots = _slots(map, path);
    _rejectUnknownKeys(map, _Keys.board, path);
    if (_errors != errorsBefore ||
        moves == null ||
        sets == null ||
        extra == null ||
        opened == null ||
        slots == null) {
      return null;
    }
    return _RawBoard(
      path: path,
      name: name,
      moves: moves,
      sets: sets,
      extra: extra,
      opened: opened,
      slots: slots,
    );
  }

  List<String>? _opened(Map<Object?, Object?> board, List<Object> path) {
    if (!board.containsKey(_Keys.opened)) return _missing(_Keys.opened, path);
    final openedPath = [...path, _Keys.opened];
    final list = _asList(board[_Keys.opened], openedPath, _Keys.opened);
    if (list == null) return null;
    final ids = <String>[];
    for (var i = 0; i < list.length; i++) {
      final id = _asString(list[i], [...openedPath, i], 'slotId');
      if (id != null) ids.add(id);
    }
    return ids.length == list.length ? ids : null;
  }

  Map<String, List<List<Doll>>>? _slots(
    Map<Object?, Object?> board,
    List<Object> path,
  ) {
    if (!board.containsKey(_Keys.slots)) return _missing(_Keys.slots, path);
    final slotsPath = [...path, _Keys.slots];
    final map = _asMap(board[_Keys.slots], slotsPath, _Keys.slots);
    if (map == null) return null;
    // Sorted, so issues come in the same order on every platform (the
    // web's JSON.parse lists integer-like keys first). For ids of the grid
    // and x0, x1 this is also the board order.
    final keys = [for (final key in map.keys) '$key']..sort();
    final byKey = {for (final key in map.keys) '$key': map[key]};
    final slots = <String, List<List<Doll>>>{};
    var ok = true;
    for (final id in keys) {
      final nests = _slotNests(byKey[id], [...slotsPath, id], id);
      if (nests == null) {
        ok = false;
      } else {
        slots[id] = nests;
      }
    }
    return ok ? slots : null;
  }

  List<List<Doll>>? _slotNests(Object? value, List<Object> path, String id) {
    final list = _asList(value, path, 'slot', slotId: id);
    if (list == null) return null;
    final nests = <List<Doll>>[];
    var ok = true;
    for (var i = 0; i < list.length; i++) {
      final nestPath = [...path, i];
      final tokens = _asList(list[i], nestPath, 'nest', slotId: id);
      if (tokens == null) {
        ok = false;
        continue;
      }
      final dolls = <Doll>[];
      for (var j = 0; j < tokens.length; j++) {
        final doll = _doll(tokens[j], [...nestPath, j], id);
        if (doll != null) dolls.add(doll);
      }
      if (dolls.length == tokens.length) {
        nests.add(dolls);
      } else {
        ok = false;
      }
    }
    return ok ? nests : null;
  }

  Doll? _doll(Object? value, List<Object> path, String id) {
    final token = _asString(value, path, 'doll', slotId: id);
    if (token == null) return null;
    final match = JsonValues.dollToken.firstMatch(token);
    final color = match == null ? null : JsonValues.colorsById[match[1]!];
    if (match == null || color == null) {
      _add(
        IssueCodes.badDollToken,
        'Bad doll token "$token" (expected a color and a size 1–6, such as '
        'red4)',
        path,
        slotId: id,
        args: {'token': token},
      );
      return null;
    }
    if (color.isWild) {
      // Spec §3.5 is v1.1 (D22): the Nest model can't hold a golden doll
      // inside another color yet, so no saved board has one.
      // TODO(v1.1): read gold once the §3.5 rules and the Nest view ship.
      _add(
        IssueCodes.goldNotSupported,
        'Gold dolls are not supported yet ("$token")',
        path,
        slotId: id,
        args: {'token': token},
      );
      return null;
    }
    return Doll(color, int.parse(match[2]!));
  }

  // --- Group 3: boards of the level ---

  /// The state [raw] describes, or null after one `session.badBoard`.
  GameState? _checkedBoard(_RawBoard raw, BoardLayout layout) {
    switch (_build(raw, layout)) {
      case _Built(:final state?):
        return state;
      case _Built(:final problem, :final slotId):
        _add(
          IssueCodes.sessionBadBoard,
          'The ${raw.name} board is not one of level ${_level.id}: $problem',
          raw.path,
          slotId: slotId,
          args: {'board': raw.name},
        );
        return null;
    }
  }

  /// The board [raw] describes, or its first problem.
  _Built _build(_RawBoard raw, BoardLayout layout) {
    if (raw.extra < 0 || raw.extra > LayoutLimits.maxExtraSlots) {
      return _Built.bad(
        'extra is ${raw.extra}, not 0–${LayoutLimits.maxExtraSlots} '
        '(spec §3.6)',
      );
    }
    if (raw.sets < 0 || raw.sets > layout.totalSets) {
      return _Built.bad('sets is ${raw.sets}, not 0–${layout.totalSets}');
    }
    if (raw.moves < 0 || raw.moves > _maxMoves) {
      return _Built.bad('moves is ${raw.moves}, not 0–$_maxMoves');
    }

    // The slot ids are exactly the board's.
    final ids = layout.activeIds(raw.extra);
    for (final id in ids) {
      if (!raw.slots.containsKey(id)) return _Built.bad('no slot $id', id);
    }
    if (raw.slots.length != ids.length) {
      final unknown = raw.slots.keys.firstWhere(
        (id) => layout.indexOf(id) < 0 || layout.indexOf(id) >= ids.length,
      );
      return _Built.bad('no slot $unknown on this board', unknown);
    }

    var openedMask = 0;
    for (final id in raw.opened) {
      final index = layout.indexOf(id);
      if (index < 0 || index >= ids.length) {
        return _Built.bad('opened names $id, which is not on this board', id);
      }
      if (((openedMask >> index) & 1) == 1) {
        return _Built.bad('opened names $id twice', id);
      }
      openedMask |= 1 << index;
    }

    final board = Board(layout);
    board.cells.fillRange(0, board.cells.length, NestCode.empty);
    for (var slot = 0; slot < ids.length; slot++) {
      final id = ids[slot];
      final nests = <Nest>[];
      for (final dolls in raw.slots[id]!) {
        if (dolls.isEmpty) return _Built.bad('$id holds an empty nest', id);
        final written = dolls.map((doll) => doll.token).join(', ');
        final nest = Nest.tryFromDolls(dolls);
        if (nest == null) {
          return _Built.bad(
            '$id holds [$written], not one color in consecutive decreasing '
            'sizes (spec §2.1)',
            id,
          );
        }
        if (nest.outerSize > layout.maxSize) {
          return _Built.bad(
            '$id holds [$written], larger than maxSize ${layout.maxSize}',
            id,
          );
        }
        if (nest.isFullSet(layout.maxSize)) {
          return _Built.bad(
            '$id holds the full set [$written], which would have completed '
            '(spec §2.1)',
            id,
          );
        }
        nests.add(nest);
      }
      // Spec §3.1–§3.3: one nest in an open slot, a case, an emptied tower
      // or an extra slot; a standing tower up to its starting depth.
      final standingTower =
          layout.kind[slot] == BoardLayout.kindTower &&
          ((openedMask >> slot) & 1) == 0;
      final capacity = standingTower ? layout.capacity[slot] : 1;
      if (nests.length > capacity) {
        return _Built.bad(
          '$id holds ${nests.length} nests; it takes $capacity',
          id,
        );
      }
      final start = layout.cellOffset[slot];
      for (var i = 0; i < nests.length; i++) {
        board.cells[start + i] = NestCode.of(nests[i]);
      }
    }
    board
      ..completedSets = raw.sets
      ..openedMask = openedMask
      ..extraCount = raw.extra
      ..moveCount = raw.moves;
    final problem = BoardCheck.kernel(board) ?? BoardCheck.reachable(board);
    if (problem != null) {
      return _Built.bad(
        problem.message,
        problem.slot < 0 ? null : layout.ids[problem.slot],
      );
    }
    return _Built.ok(GameStateBoard.adopt(board));
  }

  // The engine's move counter crosses the solver isolate as an Int32
  // (SolverSnapshot), so a saved board stays within it.
  static const int _maxMoves = 0x7FFFFFFF;

  // --- Group 4: the history replays ---

  /// The entry [index] re-derived, or null after its `session.badHistory`.
  UndoEntry? _replay(int index, GameState before, Move move, GameState next) {
    final result = Rules.tryMove(before, move);
    final String problem;
    switch (result) {
      case MoveRejected(:final reason):
        problem = 'the move $move is rejected (${reason.name})';
      case MoveApplied(:final completedSet) when completedSet:
        // Spec §2.4: a completion clears the history.
        problem = 'the move $move completes a set';
      case MoveApplied() when next.extraSlotCount < before.extraSlotCount:
        // Spec §3.6: an extra slot lasts until the level ends.
        problem =
            'the extra slots go from ${before.extraSlotCount} to '
            '${next.extraSlotCount}';
      case MoveApplied(:final state, :final events):
        if (GameStateBoard.withExtraSlots(state, next.extraSlotCount) == next) {
          return UndoEntry(before: before, move: move, events: events);
        }
        problem = 'the move $move does not lead to the next board';
    }
    _add(
      IssueCodes.sessionBadHistory,
      'History entry $index does not replay: $problem',
      [_Keys.history, index],
      args: {'index': index},
    );
    return null;
  }

  // --- JSON helpers ---

  Null _missing(String key, List<Object> parentPath) {
    _add(
      IssueCodes.missingField,
      'Missing "$key"',
      parentPath,
      args: {'field': key},
    );
    return null;
  }

  String? _requiredString(Map<Object?, Object?> root, String key) {
    if (!root.containsKey(key)) return _missing(key, const []);
    return _asString(root[key], [key], key);
  }

  int? _requiredInt(
    Map<Object?, Object?> map,
    String key,
    List<Object> parentPath,
  ) {
    if (!map.containsKey(key)) return _missing(key, parentPath);
    final number = JsonValues.integer(map[key]);
    if (number == null) {
      _wrongType([...parentPath, key], key, _Expected.integer);
    }
    return number;
  }

  /// Reports every key of [map] outside [allowed], sorted by code unit, so
  /// the order is the same on the VM and the web.
  void _rejectUnknownKeys(
    Map<Object?, Object?> map,
    Set<String> allowed,
    List<Object> path,
  ) {
    final unknown = [
      for (final key in map.keys)
        if (key is! String || !allowed.contains(key)) '$key',
    ]..sort();
    for (final name in unknown) {
      _add(
        IssueCodes.unknownField,
        'Unknown field "$name"',
        [...path, name],
        args: {'field': name},
      );
    }
  }

  Map<Object?, Object?>? _asMap(
    Object? value,
    List<Object> path,
    String field,
  ) {
    if (value is Map) return value;
    _wrongType(path, field, _Expected.object);
    return null;
  }

  List<Object?>? _asList(
    Object? value,
    List<Object> path,
    String field, {
    String? slotId,
  }) {
    if (value is List) return value;
    _wrongType(path, field, _Expected.array, slotId: slotId);
    return null;
  }

  String? _asString(
    Object? value,
    List<Object> path,
    String field, {
    String? slotId,
  }) {
    if (value is String) return value;
    _wrongType(path, field, _Expected.string, slotId: slotId);
    return null;
  }

  void _wrongType(
    List<Object> path,
    String field,
    String expected, {
    String? slotId,
  }) {
    _add(
      IssueCodes.wrongType,
      '"$field" must be ${_article(expected)}',
      path,
      slotId: slotId,
      args: {'field': field, 'expected': expected},
    );
  }

  static String _article(String expected) => switch (expected) {
    _Expected.object => 'an object',
    _Expected.array => 'an array',
    _Expected.integer => 'an integer (a whole number up to 2^53 − 1)',
    _Expected.pair => 'a pair of slot ids',
    _ => 'a $expected',
  };

  void _add(
    String code,
    String message,
    List<Object> path, {
    String? slotId,
    Map<String, Object> args = const {},
  }) {
    final issue = LevelIssue(
      code: code,
      message: message,
      path: LevelIssue.pointer(path),
      slotId: slotId,
      args: args,
    );
    if (issue.isError) _errors++;
    _issues.add(issue);
  }
}
