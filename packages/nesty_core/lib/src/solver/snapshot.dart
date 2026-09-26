import 'dart:typed_data';

import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:nesty_core/src/solver/hint.dart';
import 'package:nesty_core/src/solver/solver.dart';
import 'package:nesty_core/src/solver/solver_run.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// The solver's isolate boundary (design §6, CLAUDE.md rule 8).
///
/// Core never imports `dart:isolate`. Instead a state travels as a small,
/// versioned, self-contained `Int32List` (the level plus the board: about
/// 100 ints), which crosses an isolate port cheaply, and the answer comes
/// back as a fixed-layout `Int32List` whose slot indexes map to ids through
/// `GameState.slotIds`.
///
/// Result layout: `[requestId, verdict, source, fromIndex, toIndex, nodes,
/// solutionLength]`, indexed by the `result*` constants. `verdict` is a
/// [SolveVerdict] index, `source` a [HintSource] index, the move indexes
/// are [noSlot] when there is no move, and `solutionLength` is the optimal
/// move count when the verdict is `solved`, else [noSolution].
///
/// The game's worker either calls [run], or steps a [start]ed [SolverTask]
/// with `advance(2000)` and drops it when a newer request arrives (design
/// §6: latest wins). Both give the answer `Solver.hint` or
/// `Solver.softStuck` gives on the decoded state.
///
/// Snapshot format, version 1: every int is non-negative, so a snapshot
/// also hashes as u32 words.
/// ```text
/// [0] version  [1] total length
/// [2] schemaVersion  [3] maxSize
/// [4..6] generatorVersion: present (0/1), value ~/ 2^26, value % 2^26
/// [7..9] seed: the same
/// [10] id length n, then n UTF-16 code units
/// shelf count s, then s shelf lengths
/// per slot, row-major: kind (0 open, 1 tower, 2 locked), unlockColor
///   (DollColor index + 1, or 0), ice, nest count k, then k nest codes
///   (bottom to top)
/// completedSets, openedMask, extraCount, moveCount, cell count c, then c
///   cells (the engine's board, extra slots included)
/// ```
abstract final class SolverSnapshot {
  /// Snapshot format version, the first int of every snapshot.
  static const int version = 1;

  /// [run] task: a hint (`Solver.hint`).
  static const int taskHint = 0;

  /// [run] task: the soft-stuck check (`Solver.softStuck`).
  static const int taskSoftStuck = 1;

  /// A move index meaning "no move".
  static const int noSlot = -1;

  /// `solutionLength` when the verdict is not `solved`.
  static const int noSolution = -1;

  static const int resultRequestId = 0;
  static const int resultVerdict = 1;
  static const int resultSource = 2;
  static const int resultFromIndex = 3;
  static const int resultToIndex = 4;
  static const int resultNodes = 5;
  static const int resultSolutionLength = 6;

  /// Length of a [run] result.
  static const int resultLength = 7;

  // Values split into two parts below 2^26 and 2^27 stay exact, positive
  // Int32 values on every platform (design §3: no 64-bit ints).
  static const int _split = 0x4000000;
  static const int _maxSplit = 0x1FFFFFFFFFFFFF;
  static const int _maxInt32 = 0x7FFFFFFF;

  static const int _kindOpen = 0;
  static const int _kindTower = 1;
  static const int _kindLocked = 2;

  /// [state] as a self-contained snapshot.
  ///
  /// Throws an [ArgumentError] for a level field the format can't carry: a
  /// `generatorVersion` or `seed` outside [0, 2^53), or a `schemaVersion`,
  /// `maxSize` or ice outside [0, 2^31).
  static Int32List encode(GameState state) {
    final level = state.level;
    final board = GameStateBoard.peek(state);
    final out = <int>[version, 0];

    void small(int value, String name) {
      if (value < 0 || value > _maxInt32) {
        throw ArgumentError.value(value, name, 'Not in [0, 2^31)');
      }
      out.add(value);
    }

    void optional(int? value, String name) {
      if (value == null) {
        out.addAll(const [0, 0, 0]);
        return;
      }
      if (value < 0 || value > _maxSplit) {
        throw ArgumentError.value(value, name, 'Not in [0, 2^53)');
      }
      out.addAll([1, value ~/ _split, value % _split]);
    }

    small(level.schemaVersion, 'schemaVersion');
    small(level.maxSize, 'maxSize');
    optional(level.generatorVersion, 'generatorVersion');
    optional(level.seed, 'seed');
    out
      ..add(level.id.length)
      ..addAll(level.id.codeUnits)
      ..add(level.shelves.length);
    for (final shelf in level.shelves) {
      out.add(shelf.length);
    }
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        final (kind, unlock) = switch (slot) {
          OpenSlot() => (_kindOpen, 0),
          TowerSlot() => (_kindTower, 0),
          LockedSlot(:final unlockColor) => (
            _kindLocked,
            unlockColor.index + 1,
          ),
        };
        out
          ..add(kind)
          ..add(unlock);
        small(slot.ice, 'ice');
        out.add(slot.nests.length);
        for (final nest in slot.nests) {
          out.add(NestCode.of(nest));
        }
      }
    }
    out
      ..add(board.completedSets)
      ..add(board.openedMask)
      ..add(board.extraCount)
      ..add(board.moveCount)
      ..add(board.cells.length)
      ..addAll(board.cells);
    out[1] = out.length;
    return Int32List.fromList(out);
  }

  /// The state [encode] captured: equal (`==`) to the encoded state, with
  /// the same slot ids in the same order. Throws a [FormatException] for a
  /// snapshot of another [version] or a malformed one: a value out of range,
  /// a board that breaks the kernel's invariants, or cells that contradict
  /// `completedSets` (only full sets ever leave a board, spec §4).
  static GameState decode(Int32List snapshot) => _Reader(snapshot).read();

  /// A [task] ([taskHint] or [taskSoftStuck]) on [snapshot] with [budget],
  /// ready to be stepped. It echoes [requestId] in its result so the caller
  /// can drop stale answers.
  ///
  /// Throws a [FormatException] for a malformed snapshot, an
  /// [ArgumentError] for an unknown task and a [RangeError] for a budget
  /// below 1 or a [requestId] outside the Int32 range.
  static SolverTask start(
    Int32List snapshot,
    int task,
    int budget, {
    int requestId = 0,
  }) => SolverTask._(decode(snapshot), task, budget, requestId);

  /// Runs [task] ([taskHint] or [taskSoftStuck]) on [snapshot] with [budget]
  /// and returns the result layout above, echoing [requestId] so the caller
  /// can drop stale answers. Throws as [start] does.
  static Int32List run(
    Int32List snapshot,
    int task,
    int budget, {
    int requestId = 0,
  }) {
    final solverTask = start(snapshot, task, budget, requestId: requestId);
    while (!solverTask.advance(budget)) {}
    return solverTask.result;
  }

  /// A [taskHint] result as a [HintResult], with its move indexes mapped to
  /// ids through `state.slotIds` of the state that was encoded.
  static HintResult readHint(Int32List result, GameState state) {
    _checkResult(result);
    final from = result[resultFromIndex];
    final to = result[resultToIndex];
    final ids = state.slotIds;
    return HintResult(
      move: from == noSlot || to == noSlot ? null : Move(ids[from], ids[to]),
      source: HintSource.values[result[resultSource]],
      verdict: readVerdict(result),
      nodes: result[resultNodes],
    );
  }

  /// The verdict of a [run] result.
  static SolveVerdict readVerdict(Int32List result) {
    _checkResult(result);
    return SolveVerdict.values[result[resultVerdict]];
  }

  static void _checkResult(Int32List result) {
    if (result.length != resultLength) {
      throw FormatException(
        'A solver result has $resultLength ints, got ${result.length}',
      );
    }
  }
}

/// A [SolverSnapshot] task in steps (design §6): the hint or soft-stuck
/// search of a decoded snapshot, advanced by the caller until [isDone],
/// then read as the snapshot result layout.
final class SolverTask {
  SolverTask._(this.state, this.task, this.budget, this.requestId)
    : _run = SolverRun(state, budget: budget) {
    if (task != SolverSnapshot.taskHint &&
        task != SolverSnapshot.taskSoftStuck) {
      throw ArgumentError.value(task, 'task', 'Not a SolverSnapshot task');
    }
    RangeError.checkValueInInterval(
      requestId,
      -0x80000000,
      0x7FFFFFFF,
      'requestId',
    );
  }

  /// The decoded state the search runs on.
  final GameState state;

  /// [SolverSnapshot.taskHint] or [SolverSnapshot.taskSoftStuck].
  final int task;

  /// The node budget.
  final int budget;

  /// Echoed as the result's first int.
  final int requestId;

  final SolverRun _run;
  Int32List? _result;

  /// Searches until the task is done or about [maxNodes] more nodes are
  /// stored; see [SolverRun.advance]. Returns [isDone].
  bool advance(int maxNodes) => _run.advance(maxNodes);

  /// True once the search is finished.
  bool get isDone => _run.isDone;

  /// Nodes stored so far.
  int get nodes => _run.nodes;

  /// The result in the [SolverSnapshot] layout. Throws a [StateError]
  /// before [isDone].
  Int32List get result => _result ??= _build();

  Int32List _build() {
    final search = _run.result;
    final out = Int32List(SolverSnapshot.resultLength)
      ..[SolverSnapshot.resultRequestId] = requestId
      ..[SolverSnapshot.resultVerdict] = search.verdict.index
      ..[SolverSnapshot.resultSource] = HintSource.none.index
      ..[SolverSnapshot.resultFromIndex] = SolverSnapshot.noSlot
      ..[SolverSnapshot.resultToIndex] = SolverSnapshot.noSlot
      ..[SolverSnapshot.resultNodes] = search.nodes
      ..[SolverSnapshot.resultSolutionLength] =
          search.solution?.length ?? SolverSnapshot.noSolution;
    if (task == SolverSnapshot.taskHint) {
      final hint = Solver.hintFrom(state, search);
      final move = hint.move;
      out[SolverSnapshot.resultSource] = hint.source.index;
      if (move != null) {
        final layout = GameStateBoard.peek(state).layout;
        out[SolverSnapshot.resultFromIndex] = layout.indexOf(move.from);
        out[SolverSnapshot.resultToIndex] = layout.indexOf(move.to);
      }
    }
    return out;
  }
}

/// Reads a version-1 snapshot, checking every value before it builds a
/// model, so a malformed snapshot is a [FormatException] and never a state
/// the kernel can't handle.
final class _Reader {
  _Reader(this._data);

  final Int32List _data;
  int _at = 0;

  GameState read() {
    if (_data.length < 2 || _data[0] != SolverSnapshot.version) {
      _fail(
        'Not a version ${SolverSnapshot.version} solver snapshot',
        _data.isEmpty ? null : 0,
      );
    }
    if (_data[1] != _data.length) _fail('Length field disagrees', 1);
    _at = 2;
    final schemaVersion = _next();
    final maxSize = _next();
    final generatorVersion = _optional();
    final seed = _optional();
    final id = String.fromCharCodes([
      for (var n = _count(), i = 0; i < n; i++) _nextIn(0, 0xFFFF),
    ]);
    final shelfLengths = [for (var n = _count(), i = 0; i < n; i++) _count()];
    final colors = DollColor.values;
    final shelves = <List<Slot>>[
      for (final length in shelfLengths)
        [for (var i = 0; i < length; i++) _slot(colors)],
    ];
    final Level level;
    final Board board;
    try {
      level = Level(
        id: id,
        maxSize: maxSize,
        shelves: shelves,
        schemaVersion: schemaVersion,
        generatorVersion: generatorVersion,
        seed: seed,
      );
      board = GameStateBoard.thaw(GameState.initial(level));
    } on ArgumentError catch (error) {
      // BoardLayout refuses a level with no shelf or too many slots.
      throw FormatException('Snapshot level: ${error.message}');
    }
    _readBoard(board);
    if (_at != _data.length) _fail('Trailing data', _at);
    return GameStateBoard.adopt(board);
  }

  Slot _slot(List<DollColor> colors) {
    final kind = _nextIn(SolverSnapshot._kindOpen, SolverSnapshot._kindLocked);
    final unlock = _nextIn(0, colors.length);
    final ice = _next();
    final count = _count();
    final nests = [for (var i = 0; i < count; i++) _nest(colors)];
    switch (kind) {
      case SolverSnapshot._kindTower:
        if (unlock != 0 || nests.isEmpty) _fail('Bad tower', _at);
        return TowerSlot(nests, ice: ice);
      case SolverSnapshot._kindLocked:
        if (unlock == 0 || nests.length > 1) _fail('Bad glass case', _at);
        return LockedSlot(
          unlockColor: colors[unlock - 1],
          nest: nests.isEmpty ? null : nests.single,
          ice: ice,
        );
      default:
        if (unlock != 0 || nests.length > 1) _fail('Bad open slot', _at);
        return OpenSlot(nest: nests.isEmpty ? null : nests.single, ice: ice);
    }
  }

  Nest _nest(List<DollColor> colors) {
    final code = _nextCode(colors, allowGold: false);
    if (code == NestCode.empty) _fail('Empty nest', _at - 1);
    return NestCode.toNest(code);
  }

  void _readBoard(Board board) {
    final layout = board.layout;
    final completed = _nextIn(0, layout.totalSets);
    final opened = _next();
    final extra = _nextIn(0, LayoutLimits.maxExtraSlots);
    final moves = _next();
    if (_next() != board.cells.length) _fail('Cell count', _at - 1);
    for (var cell = 0; cell < board.cells.length; cell++) {
      board.cells[cell] = _nextCode(DollColor.values, allowGold: true);
    }
    board
      ..completedSets = completed
      ..openedMask = opened
      ..extraCount = extra
      ..moveCount = moves;
    _checkSlots(board);
    _checkSets(board);
  }

  /// Only full sets ever leave the board (spec §4), so compared with the
  /// level's start every color has lost the same number `d` of dolls of
  /// each size 1..maxSize and none larger, and the `d`s add up to
  /// `completedSets`. A snapshot whose cells contradict its `completedSets`
  /// is malformed: the search would get a negative heuristic (`h = nests −
  /// setsRemaining`). A golden doll counts toward whatever set it joins
  /// (spec §3.5, v1.1), so a board with gold is only held to `h ≥ 0`.
  void _checkSets(Board board) {
    final layout = board.layout;
    final remaining = layout.totalSets - board.completedSets;
    var nests = 0;
    for (final code in board.cells) {
      if (code != NestCode.empty) nests++;
    }
    if (nests < remaining) {
      _fail('$nests nests cannot hold the $remaining sets left', null);
    }
    final lost = Int32List(DollColor.values.length * _sizes);
    final gold =
        _countDolls(layout.initialCells, lost, 1) ||
        _countDolls(board.cells, lost, -1);
    if (gold) return;
    final maxSize = layout.maxSize;
    var sets = 0;
    for (var color = 0; color < DollColor.values.length; color++) {
      final row = color * _sizes;
      final sets0 = lost[row + 1];
      for (var size = 1; size < _sizes; size++) {
        final expected = size <= maxSize ? sets0 : 0;
        if (lost[row + size] != expected || sets0 < 0) {
          _fail('Color $color lost dolls that are not whole sets', null);
        }
      }
      sets += sets0;
    }
    if (sets != board.completedSets) {
      _fail(
        'The cells lost $sets sets, but completedSets is '
        '${board.completedSets}',
        null,
      );
    }
  }

  // Doll sizes 1..6, indexed directly.
  static const int _sizes = 7;

  /// Adds [sign] per doll of [cells] to [counts] (color × size). Returns
  /// true when a cell holds a golden doll or the wild color.
  static bool _countDolls(List<int> cells, Int32List counts, int sign) {
    var gold = false;
    for (final code in cells) {
      if (code == NestCode.empty) continue;
      final color = NestCode.color(code);
      if (NestCode.gold(code) != 0 || NestCode.isWildColor(color)) {
        gold = true;
        continue;
      }
      final row = color * _sizes;
      for (
        var size = NestCode.inner(code);
        size <= NestCode.outer(code);
        size++
      ) {
        counts[row + size] += sign;
      }
    }
    return gold;
  }

  /// The kernel's invariants (design §2): only towers and cases open; a
  /// tower still in play holds a gapless stack; everything else uses its
  /// first cell only; extra slots not added yet are empty.
  void _checkSlots(Board board) {
    final layout = board.layout;
    final opened = board.openedMask;
    for (var slot = 0; slot < layout.slotCount; slot++) {
      final isOpened = ((opened >> slot) & 1) == 1;
      final kind = layout.kind[slot];
      final start = layout.cellOffset[slot];
      final end = start + layout.capacity[slot];
      if (isOpened && kind == BoardLayout.kindOpen) {
        _fail('Opened mask marks open slot $slot', null);
      }
      var used = start + 1;
      if (kind == BoardLayout.kindTower && !isOpened) {
        used = start;
        while (used < end && board.cells[used] != NestCode.empty) {
          used++;
        }
        if (used == start) _fail('Tower $slot is empty but not opened', null);
      }
      for (var cell = used; cell < end; cell++) {
        if (board.cells[cell] != NestCode.empty) {
          _fail('Slot $slot has a nest in an unused cell', null);
        }
      }
      if (slot >= board.activeSlotCount &&
          board.cells[start] != NestCode.empty) {
        _fail('Extra slot $slot is not in play but holds a nest', null);
      }
    }
    if (opened >= (1 << layout.slotCount)) {
      _fail('Opened mask has bits past the last slot', null);
    }
  }

  int _nextCode(List<DollColor> colors, {required bool allowGold}) {
    final code = _nextIn(0, 0x1FFF);
    if (code == NestCode.empty) return code;
    final outer = NestCode.outer(code);
    final length = NestCode.length(code);
    final gold = NestCode.gold(code);
    if (NestCode.color(code) >= colors.length ||
        outer < 1 ||
        outer > 6 ||
        length < 1 ||
        length > outer ||
        gold > 6 ||
        (!allowGold && gold != 0)) {
      _fail('Bad nest code $code', _at - 1);
    }
    return code;
  }

  int? _optional() {
    final present = _nextIn(0, 1);
    final hi = _nextIn(0, SolverSnapshot._maxSplit ~/ SolverSnapshot._split);
    final lo = _nextIn(0, SolverSnapshot._split - 1);
    if (present == 0) {
      if (hi != 0 || lo != 0) _fail('Absent value with data', _at - 1);
      return null;
    }
    return hi * SolverSnapshot._split + lo;
  }

  /// A count of items still to read: each takes at least one int, so it
  /// can't exceed what is left, which also bounds every allocation.
  int _count() => _nextIn(0, _data.length - _at - 1);

  int _next() => _nextIn(0, SolverSnapshot._maxInt32);

  int _nextIn(int min, int max) {
    if (_at >= _data.length) _fail('Snapshot ends early', null);
    final value = _data[_at];
    if (value < min || value > max) _fail('$value not in [$min, $max]', _at);
    _at++;
    return value;
  }

  Never _fail(String message, int? offset) => throw FormatException(
    'Malformed solver snapshot: $message',
    _data,
    offset,
  );
}
