// GameSessionCodec: the in-progress session's JSON (spec §13.3,
// docs/plans/m3-design.md §4, D69).
//
// Spec §13.3: `"inProgress": { "levelId": "L0024", "levelVersion": 2,
//   "state": {...}, "undo": [...] }` … "The in-progress level is saved on
//   every move and on app pause. On resume it's restored if the
//   `levelVersion` still matches. Otherwise the level restarts."
// Spec §18 M3: "Kill the app mid-level → it resumes exactly where it was."
// Spec §2.4: "Undo reverts the last move. The undo history is cleared
//   whenever a set completes. Completions and unlocks are permanent."
//   "Restart is always free and resets the level to its start."
// Spec §3.2: "Only the top nest can be picked up or merged into." "You
//   cannot place a new nest onto a tower." "An empty tower becomes a normal
//   open slot."
// Spec §3.3: "The case breaks and the slot becomes an open slot the moment
//   the first full set of its `unlockColor` completes."
// Spec §3.4: "It can't be picked from or dropped onto. Each full set
//   completed anywhere lowers every ice counter by 1 … At 0 the ice
//   shatters and the slot works normally."
// Spec §3.6: "Adds one temporary open slot at the right end of the bottom
//   shelf … It lasts until the level ends. Max 2 per level."
// Spec §2.1: "sizes must be consecutive and decreasing", "Full set: a nest
//   containing every size from `maxSize` down to 1. When it forms, it
//   completes."
// m3-design §4, format 1:
//   { "format": 1, "levelId": "L0024", "undosUsed": 1, "state": <board>,
//     "history": [ {"before": <board>, "move": ["r0c2", "r0c0"]}, … ] }
//   <board> = { "moves", "sets", "extra", "opened", "slots" }
//   Decode checks, stopping at the first failing group: 1 the format, then
//   the keys, types and tokens; 2 levelId; 3 every board is a board of the
//   level; 4 the history replays through Rules.tryMove; 5 undosUsed ≥ 0.
//
// Every JSON string and event list below is worked out by hand from those
// rules on the spec §5.1 example level, not captured from the codec.
//
// Platform-neutral (no dart:io): the admin (web) and the game (VM) must read
// a save alike, so this file also runs with `dart test -p chrome` and
// `-p node`.
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart' show specExampleLevel;
import '../parity/vectors/session_vectors.dart';
import '../rules/support/boards.dart';

// The spec §5.1 example (L0042, maxSize 4), 3 sets: red, blue, green.
//   r0: open [red4, red3] | open empty | tower [[blue2], [green4], [red2, red1]]
//   r1: locked(red) [green3, green2, green1] | open [blue4, blue3] ice 2
//       | open [blue1]
final Level level = specExampleLevel();

/// The scenario every round-trip test walks, one action per step: a move
/// `from>to`, `undo`, `extra` (+1 slot) or `restart`.
const List<String> scenario = [
  'r1c2>r0c1', // A1: blue1 placed on the empty open slot.
  'r0c1>r1c2', // A2: and back.
  'undo', // A3: reverts A2; undosUsed 1.
  'extra', // A4: x0 joins the bottom shelf.
  'r0c0>r0c2', // A5: red swallows the tower's top: the red set completes,
  //               green4 is revealed, the red case breaks, ice 2 → 1, and
  //               the history is cleared.
  'r0c2>r0c0', // A6: green4 placed; the tower reveals blue2.
  'extra', // A7: x1, with an undo entry already in the history.
  'r0c1>x1', // A8: blue1 onto the new slot.
  'restart', // A9: the start again, with both extra slots and undosUsed 1.
  'r0c0>r0c2', // B1: the red set again.
  'r0c2>r1c0', // B2: green4 swallows the broken case's green3..1: the green
  //               set completes and the ice shatters (2 − 2 = 0).
  'r0c2>r1c1', // B3: blue2 inside blue4, blue3: the tower empties.
  'r1c2>r1c1', // B4: blue1 completes blue: won.
];

GameSession run(List<String> actions, {Level? on}) {
  final session = GameSession(on ?? level);
  for (final action in actions) {
    act(session, action);
  }
  return session;
}

/// Applies [action] to [session]; fails the test when it does nothing.
void act(GameSession session, String action) {
  switch (action) {
    case 'undo':
      expect(session.undo(), isNotNull, reason: action);
    case 'extra':
      expect(session.addExtraSlot(), isNotNull, reason: action);
    case 'restart':
      session.restart();
    default:
      final move = mv(action);
      expect(
        session.move(move.from, move.to),
        isA<MoveApplied>(),
        reason: action,
      );
  }
}

/// The session after the first [steps] actions of [scenario].
GameSession step(int steps) => run(scenario.take(steps).toList());

/// [session]'s JSON as the save stores it: through a string and back, so it
/// is a fresh, mutable copy parsed like real input.
Map<String, Object?> jsonOf(GameSession session) =>
    jsonDecode(jsonEncode(GameSessionCodec.encode(session)))
        as Map<String, Object?>;

/// The board at [where] of [json]: `state` or `history/<i>`.
Map<String, Object?> boardOf(Map<String, Object?> json, String where) {
  if (where == 'state') return json['state']! as Map<String, Object?>;
  final index = int.parse(where.substring('history/'.length));
  final entry = (json['history']! as List)[index] as Map<String, Object?>;
  return entry['before']! as Map<String, Object?>;
}

/// The slot contents of the board at [where] of [json].
Map<String, Object?> slotsOf(Map<String, Object?> json, String where) =>
    boardOf(json, where)['slots']! as Map<String, Object?>;

/// Decodes [json], expects no session, and returns its issues as plain maps.
List<Map<String, Object?>> issuesOf(Object? json, {Level? on}) {
  final result = GameSessionCodec.decode(json, on ?? level);
  expect(result.session, isNull, reason: '${result.issues}');
  expect(result.isOk, isFalse);
  expect(result.issues, isNotEmpty);
  for (final issue in result.issues) {
    expect(issue.severity, IssueSeverity.error);
    expect(issue.message, isNotEmpty);
  }
  return [
    for (final issue in result.issues)
      {
        'code': issue.code,
        'path': issue.path,
        'slotId': issue.slotId,
        'args': issue.args,
      },
  ];
}

Map<String, Object?> issue(
  String code, {
  String path = '',
  String? slotId,
  Map<String, Object> args = const {},
}) => {'code': code, 'path': path, 'slotId': slotId, 'args': args};

Map<String, Object?> badBoard(String where, {String? slotId}) => issue(
  IssueCodes.sessionBadBoard,
  path: where == 'state' ? '/state' : '/$where/before',
  slotId: slotId,
  args: {'board': where},
);

Map<String, Object?> badHistory(int index) => issue(
  IssueCodes.sessionBadHistory,
  path: '/history/$index',
  args: {'index': index},
);

/// Expects [restored] to be [live] resumed: the same board, the same history
/// (events included), the same undos used, and the same JSON again.
void expectSameSession(GameSession restored, GameSession live) {
  expect(restored.level, live.level);
  expect(restored.state, live.state);
  expect(restored.history, live.history);
  expect(restored.undosUsed, live.undosUsed);
  expect(restored.canUndo, live.canUndo);
  expect(restored.canAddExtraSlot, live.canAddExtraSlot);
  expect(
    jsonEncode(GameSessionCodec.encode(restored)),
    jsonEncode(GameSessionCodec.encode(live)),
  );
}

/// Encodes [live], parses the text back and decodes it; expects no issue and
/// returns the resumed session.
GameSession roundTrip(GameSession live) {
  final text = jsonEncode(GameSessionCodec.encode(live));
  final result = GameSessionCodec.decode(jsonDecode(text), live.level);
  expect(result.issues, isEmpty, reason: text);
  expect(result.isOk, isTrue);
  final restored = result.session!;
  expectSameSession(restored, live);
  return restored;
}

Nest n(String tokens) => nest(tokens);

void main() {
  test('format is 1 (m3-design §4)', () {
    expect(GameSessionCodec.format, 1);
  });

  group('encode writes the m3-design §4 shape', () {
    test('the starting board', () {
      expect(jsonEncode(GameSessionCodec.encode(step(0))), startJson);
    });

    test('an extra slot added mid-history, an undo and a broken case', () {
      expect(jsonEncode(GameSessionCodec.encode(step(8))), afterA8Json);
    });

    test('a restart keeps the extra slots and undosUsed (D22)', () {
      expect(jsonEncode(GameSessionCodec.encode(step(9))), afterRestartJson);
    });

    test('an emptied tower and a broken case are both opened', () {
      expect(jsonEncode(GameSessionCodec.encode(step(12))), afterB3Json);
    });

    test('the won board', () {
      final won = step(13);
      expect(won.isWon, isTrue);
      expect(jsonEncode(GameSessionCodec.encode(won)), wonJson);
    });

    test('a completion clears the history (spec §2.4)', () {
      final session = step(5);
      expect(session.history, isEmpty);
      final json = GameSessionCodec.encode(session);
      expect(json['history'], isEmpty);
      expect((json['state']! as Map)['sets'], 1);
      expect((json['state']! as Map)['opened'], ['r1c0']);
    });

    test('keys in canonical order; the result is unmodifiable', () {
      final json = GameSessionCodec.encode(step(8));
      expect(json.keys, ['format', 'levelId', 'undosUsed', 'state', 'history']);
      final state = json['state']! as Map<String, Object?>;
      expect(state.keys, ['moves', 'sets', 'extra', 'opened', 'slots']);
      expect((state['slots']! as Map).keys, step(8).state.slotIds);
      final entry = (json['history']! as List).first as Map<String, Object?>;
      expect(entry.keys, ['before', 'move']);
      expect(() => json['format'] = 2, throwsUnsupportedError);
      expect(() => state['moves'] = 0, throwsUnsupportedError);
      expect(() => (json['history']! as List).clear(), throwsUnsupportedError);
    });

    test('is stable: the same session gives the same string', () {
      final session = step(8);
      final first = jsonEncode(GameSessionCodec.encode(session));
      expect(jsonEncode(GameSessionCodec.encode(session)), first);
      expect(jsonEncode(GameSessionCodec.encode(step(8))), first);
    });
  });

  group('round trip', () {
    for (var steps = 0; steps <= scenario.length; steps++) {
      final name = steps == 0 ? 'start' : 'after ${scenario[steps - 1]}';
      test('step $steps ($name)', () => roundTrip(step(steps)));
    }

    test('decode reads the hand-written JSON back into the live session', () {
      for (final (steps, json) in [
        (0, startJson),
        (8, afterA8Json),
        (9, afterRestartJson),
        (12, afterB3Json),
        (13, wonJson),
      ]) {
        final result = GameSessionCodec.decode(jsonDecode(json), level);
        expect(result.issues, isEmpty, reason: json);
        expectSameSession(result.session!, step(steps));
      }
    });

    test('re-derives each entry\'s events (spec §4 event order)', () {
      final restored = GameSessionCodec.decode(
        jsonDecode(afterA8Json),
        level,
      ).session!;
      expect(restored.history.map((e) => e.move), [
        mv('r0c2>r0c0'),
        mv('r0c1>x1'),
      ]);
      // A6: green4 leaves the tower, which reveals blue2 with nothing below.
      expect(restored.history[0].events, [
        Picked(
          slotId: 'r0c2',
          nest: n('green4'),
          fromTower: true,
          leftEmptyTower: false,
        ),
        Placed(fromId: 'r0c2', slotId: 'r0c0', nest: n('green4')),
        Revealed(slotId: 'r0c2', nest: n('blue2'), hiddenBelow: 0),
      ]);
      // A8: blue1 onto the second extra slot.
      expect(restored.history[1].events, [
        Picked(
          slotId: 'r0c1',
          nest: n('blue1'),
          fromTower: false,
          leftEmptyTower: false,
        ),
        Placed(fromId: 'r0c1', slotId: 'x1', nest: n('blue1')),
      ]);
      // Each entry keeps its own extra slots: x1 came after A6.
      expect(restored.history[0].before.extraSlotCount, 1);
      expect(restored.history[1].before.extraSlotCount, 2);
      expect(restored.state.extraSlotCount, 2);
    });

    test('an emptied tower\'s entry says so', () {
      final restored = GameSessionCodec.decode(
        jsonDecode(afterB3Json),
        level,
      ).session!;
      expect(restored.history.single.events, [
        Picked(
          slotId: 'r0c2',
          nest: n('blue2'),
          fromTower: true,
          leftEmptyTower: true,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r1c1',
          direction: NestDirection.inside,
          moving: n('blue2'),
          target: n('blue4 blue3'),
          merged: n('blue4 blue3 blue2'),
        ),
      ]);
      expect(restored.state.slot('r0c2'), OpenSlot());
      expect(restored.state.slot('r1c0'), OpenSlot());
      expect(
        restored.state.slot('r1c1'),
        OpenSlot(nest: n('blue4 blue3 blue2')),
      );
    });

    test('ice and broken cases come back from the completed sets', () {
      // After A5 (1 set): ice 2 → 1, the red case is open (spec §3.3, §3.4).
      final a5 = roundTrip(step(5));
      expect(a5.state.slot('r1c1').ice, 1);
      expect(a5.state.slot('r1c0'), OpenSlot(nest: n('green3 green2 green1')));
      expect(Rules.isInteractable(a5.state, 'r1c1'), isFalse);
      // After B2 (2 sets): the ice shattered.
      final b2 = roundTrip(step(11));
      expect(b2.state.slot('r1c1'), OpenSlot(nest: n('blue4 blue3')));
      expect(Rules.isInteractable(b2.state, 'r1c1'), isTrue);
    });

    test('undo after a restore walks back like the live session', () {
      final live = step(8);
      final restored = roundTrip(live);
      for (final session in [live, restored]) {
        // Undo A8: back to before#1 (it had both extra slots).
        final first = session.undo()!;
        expect(first.revertedMove, mv('r0c1>x1'));
        expect(session.state.moveCount, 3);
        expect(session.state.slot('r0c1'), OpenSlot(nest: n('blue1')));
        // Undo A6: back to before#0, raised to the current 2 extra slots.
        final second = session.undo()!;
        expect(second.revertedMove, mv('r0c2>r0c0'));
        expect(session.state.moveCount, 2);
        expect(session.state.extraSlotCount, 2);
        expect(session.state.slot('x1'), OpenSlot());
        expect(
          session.state.slot('r0c2'),
          TowerSlot([n('blue2'), n('green4')]),
        );
        // A5 completed a set, so nothing further back (spec §2.4).
        expect(session.undo(), isNull);
        expect(session.undosUsed, 3);
      }
      expectSameSession(restored, live);
    });

    test('a restored session plays on exactly like the live one', () {
      final live = step(4);
      final restored = roundTrip(live);
      const script = [
        'r0c0>r0c1', // rejected: red onto blue
        'r0c0>r0c2',
        'undo', // nothing: the completion cleared the history
        'r1c1>r0c0', // rejected: iced source
        'r0c2>r0c0',
        'extra',
        'r0c1>x1',
        'undo',
        'extra', // nothing: both extra slots are in
        'r0c0>x1',
        'restart',
        'r0c0>r0c2',
        'r0c2>r1c0',
        'r0c2>r1c1',
        'r1c2>r1c1',
      ];
      for (final action in script) {
        final Object? a;
        final Object? b;
        switch (action) {
          case 'undo':
            a = live.undo();
            b = restored.undo();
          case 'extra':
            a = live.addExtraSlot();
            b = restored.addExtraSlot();
          case 'restart':
            live.restart();
            restored.restart();
            a = b = null;
          default:
            final move = mv(action);
            a = live.move(move.from, move.to);
            b = restored.move(move.from, move.to);
        }
        expect(b, a, reason: action);
        expectSameSession(restored, live);
      }
      expect(restored.isWon, isTrue);
    });

    test('decodes against a level equal to, not identical with, the saved '
        'one', () {
      final copy = LevelCodec.decode(LevelCodec.encode(level)).level!;
      expect(copy, level);
      expect(copy, isNot(same(level)));
      final result = GameSessionCodec.decode(jsonOf(step(8)), copy);
      expect(result.issues, isEmpty);
      expect(result.session!.level, same(copy));
      // Equal levels give equal boards: GameState compares levels by value.
      expect(result.session!.state, step(8).state);
      expect(jsonEncode(GameSessionCodec.encode(result.session!)), afterA8Json);
    });

    test('integers are read by value: 4.0 is 4 (D29)', () {
      final json = jsonOf(step(8));
      json['format'] = 1.0;
      json['undosUsed'] = 1.0;
      boardOf(json, 'state')['moves'] = 4.0;
      boardOf(json, 'history/1')['extra'] = 2.0;
      final result = GameSessionCodec.decode(json, level);
      expect(result.issues, isEmpty);
      expectSameSession(result.session!, step(8));
    });

    test('slot keys in any order read the same', () {
      final json = jsonOf(step(8));
      final slots = slotsOf(json, 'state');
      final reversed = Map.fromEntries(slots.entries.toList().reversed);
      boardOf(json, 'state')['slots'] = reversed;
      final result = GameSessionCodec.decode(json, level);
      expect(result.issues, isEmpty);
      expectSameSession(result.session!, step(8));
    });

    test('random play on generated boards round-trips after every action', () {
      // Boards with towers, glass cases and ice from the curve (spec §3.7:
      // towers from 16, cases from 31, ice from 51). Only the board-building
      // stage runs, so the boards need not be solvable.
      final boards = [
        for (final number in [16, 20, 31, 36, 51, 56, 60, 76, 130])
          ?Generator.buildAttempt(DifficultyCurve.bonusParams(number), 0),
        level,
      ];
      expect(
        boards.where((l) => l.shelves.expand((s) => s).any((s) => s.ice > 0)),
        isNotEmpty,
      );
      expect(
        boards.where(
          (l) => l.shelves.expand((s) => s).any((s) => s is LockedSlot),
        ),
        isNotEmpty,
      );
      final seen = <String, int>{};
      void count(String what) => seen[what] = (seen[what] ?? 0) + 1;

      final prng = Prng(20260927);
      for (final board in boards) {
        final live = GameSession(board);
        var twin = roundTrip(live);
        for (var i = 0; i < 160; i++) {
          if (live.isWon || live.isOutOfMoves) {
            live.restart();
            twin.restart();
            count('restart');
          }
          final roll = prng.nextInt(100);
          final Object? a;
          final Object? b;
          if (roll < 65) {
            // A legal move, preferring merges so sets complete.
            final moves = live.legalMoves();
            final merges = [
              for (final move in moves)
                if (!live.state.slot(move.to).isEmpty) move,
            ];
            final pool = merges.isNotEmpty && prng.nextInt(4) != 0
                ? merges
                : moves;
            final move = prng.pick(pool);
            a = live.move(move.from, move.to);
            b = twin.move(move.from, move.to);
          } else if (roll < 72) {
            // Any two slots: usually rejected, which must change nothing.
            final ids = live.state.slotIds;
            final from = prng.pick(ids);
            final to = prng.pick(ids);
            a = live.move(from, to);
            b = twin.move(from, to);
          } else if (roll < 88) {
            a = live.undo();
            b = twin.undo();
            if (a != null) count('undo');
          } else if (roll < 96) {
            a = live.addExtraSlot();
            b = twin.addExtraSlot();
            if (a != null && live.canUndo) count('extra mid-history');
          } else {
            live.restart();
            twin.restart();
            a = b = null;
            count('restart');
          }
          expect(b, a, reason: '${board.id} step $i');
          if (a case MoveApplied(:final events, :final completedSet)) {
            if (completedSet) count('completed');
            // Named by hand: runtimeType names are minified in dart2js.
            for (final event in events) {
              count(switch (event) {
                Revealed() => 'Revealed',
                Unlocked() => 'Unlocked',
                IceCracked() => 'IceCracked',
                IceShattered() => 'IceShattered',
                _ => 'other event',
              });
            }
          }
          if (live.history.length >= 3) count('history of 3+');
          final restored = roundTrip(live);
          expectSameSession(twin, live);
          // Now and then carry on from the restored copy instead.
          if (i % 7 == 0) twin = restored;
        }
      }
      // Not vacuous: every case the codec must carry happened.
      for (final what in [
        'Revealed',
        'Unlocked',
        'IceCracked',
        'IceShattered',
        'completed',
        'undo',
        'extra mid-history',
        'restart',
        'history of 3+',
      ]) {
        expect(seen[what], isNotNull, reason: '$what never happened: $seen');
      }
    });
  });

  group('decode rejects (group 1: format, keys, types, tokens)', () {
    test('another format, and reads nothing more', () {
      final json = jsonOf(step(8))
        ..['format'] = 2
        ..['levelId'] = 7
        ..['extra'] = true;
      expect(issuesOf(json), [
        issue(
          IssueCodes.sessionUnsupportedFormat,
          path: '/format',
          args: {'found': 2},
        ),
      ]);
    });

    test('a value that is not an object', () {
      for (final json in <Object?>[null, 1, 'x', true, <Object?>[]]) {
        expect(issuesOf(json), [
          issue(
            IssueCodes.wrongType,
            args: {'field': 'session', 'expected': 'object'},
          ),
        ], reason: '$json');
      }
    });

    test('missing keys, in canonical order', () {
      expect(issuesOf(<String, Object?>{}), [
        for (final field in [
          'format',
          'levelId',
          'undosUsed',
          'state',
          'history',
        ])
          issue(IssueCodes.missingField, args: {'field': field}),
      ]);
      final json = jsonOf(step(8));
      boardOf(json, 'history/1').remove('opened');
      expect(issuesOf(json), [
        issue(
          IssueCodes.missingField,
          path: '/history/1/before',
          args: {'field': 'opened'},
        ),
      ]);
    });

    test('a missing or mistyped format is reported, and the rest read', () {
      final json = jsonOf(step(0))
        ..remove('format')
        ..['undosUsed'] = 'one';
      expect(issuesOf(json), [
        issue(IssueCodes.missingField, args: {'field': 'format'}),
        issue(
          IssueCodes.wrongType,
          path: '/undosUsed',
          args: {'field': 'undosUsed', 'expected': 'integer'},
        ),
      ]);
      expect(issuesOf(jsonOf(step(0))..['format'] = '1'), [
        issue(
          IssueCodes.wrongType,
          path: '/format',
          args: {'field': 'format', 'expected': 'integer'},
        ),
      ]);
    });

    test('wrong types', () {
      Map<String, Object?> json() => jsonOf(step(8));
      final cases = <String, (Map<String, Object?>, Map<String, Object?>)>{
        'levelId': (
          json()..['levelId'] = 42,
          issue(
            IssueCodes.wrongType,
            path: '/levelId',
            args: {'field': 'levelId', 'expected': 'string'},
          ),
        ),
        'undosUsed 1.5': (
          json()..['undosUsed'] = 1.5,
          issue(
            IssueCodes.wrongType,
            path: '/undosUsed',
            args: {'field': 'undosUsed', 'expected': 'integer'},
          ),
        ),
        'undosUsed 2^53': (
          json()..['undosUsed'] = 9007199254740992,
          issue(
            IssueCodes.wrongType,
            path: '/undosUsed',
            args: {'field': 'undosUsed', 'expected': 'integer'},
          ),
        ),
        'state': (
          json()..['state'] = <Object?>[],
          issue(
            IssueCodes.wrongType,
            path: '/state',
            args: {'field': 'state', 'expected': 'object'},
          ),
        ),
        'history': (
          json()..['history'] = <String, Object?>{},
          issue(
            IssueCodes.wrongType,
            path: '/history',
            args: {'field': 'history', 'expected': 'array'},
          ),
        ),
        'history entry': (
          json()..['history'] = [null],
          issue(
            IssueCodes.wrongType,
            path: '/history/0',
            args: {'field': 'entry', 'expected': 'object'},
          ),
        ),
        'before': (
          json()
            ..['history'] = [
              {
                'before': 'x',
                'move': ['r0c0', 'r0c1'],
              },
            ],
          issue(
            IssueCodes.wrongType,
            path: '/history/0/before',
            args: {'field': 'before', 'expected': 'object'},
          ),
        ),
        'moves': (
          json()..['state'] = {...boardOf(json(), 'state'), 'moves': '4'},
          issue(
            IssueCodes.wrongType,
            path: '/state/moves',
            args: {'field': 'moves', 'expected': 'integer'},
          ),
        ),
        'opened': (
          json()..['state'] = {...boardOf(json(), 'state'), 'opened': 'r1c0'},
          issue(
            IssueCodes.wrongType,
            path: '/state/opened',
            args: {'field': 'opened', 'expected': 'array'},
          ),
        ),
        'an opened id': (
          json()
            ..['state'] = {
              ...boardOf(json(), 'state'),
              'opened': [3],
            },
          issue(
            IssueCodes.wrongType,
            path: '/state/opened/0',
            args: {'field': 'slotId', 'expected': 'string'},
          ),
        ),
        'slots': (
          json()
            ..['state'] = {...boardOf(json(), 'state'), 'slots': <Object?>[]},
          issue(
            IssueCodes.wrongType,
            path: '/state/slots',
            args: {'field': 'slots', 'expected': 'object'},
          ),
        ),
      };
      for (final MapEntry(key: name, value: (input, expected))
          in cases.entries) {
        expect(issuesOf(input), [expected], reason: name);
      }
    });

    test('a slot, a nest or a doll of the wrong type', () {
      final json = jsonOf(step(8));
      slotsOf(json, 'state')
        ..['r0c0'] = 'green4'
        ..['r0c2'] = ['blue2']
        ..['r1c0'] = [
          ['green3', 2, 'green1'],
        ];
      expect(issuesOf(json), [
        issue(
          IssueCodes.wrongType,
          path: '/state/slots/r0c0',
          slotId: 'r0c0',
          args: {'field': 'slot', 'expected': 'array'},
        ),
        issue(
          IssueCodes.wrongType,
          path: '/state/slots/r0c2/0',
          slotId: 'r0c2',
          args: {'field': 'nest', 'expected': 'array'},
        ),
        issue(
          IssueCodes.wrongType,
          path: '/state/slots/r1c0/0/1',
          slotId: 'r1c0',
          args: {'field': 'doll', 'expected': 'string'},
        ),
      ]);
    });

    test('bad doll tokens (spec §5.1)', () {
      final json = jsonOf(step(8));
      slotsOf(json, 'history/0')
        ..['r0c1'] = [
          ['Blue1'],
        ]
        ..['r0c2'] = [
          ['blue7'],
          ['green'],
        ]
        ..['r1c1'] = [
          ['cyan4', 'blue3'],
        ];
      expect(issuesOf(json), [
        for (final (slot, at, token) in [
          ('r0c1', '0/0', 'Blue1'),
          ('r0c2', '0/0', 'blue7'),
          ('r0c2', '1/0', 'green'),
          ('r1c1', '0/0', 'cyan4'),
        ])
          issue(
            IssueCodes.badDollToken,
            path: '/history/0/before/slots/$slot/$at',
            slotId: slot,
            args: {'token': token},
          ),
      ]);
    });

    test('gold is not supported yet (spec §3.5 is v1.1, D22)', () {
      final json = jsonOf(step(0));
      slotsOf(json, 'state')['r0c1'] = [
        ['gold2'],
      ];
      expect(issuesOf(json), [
        issue(
          IssueCodes.goldNotSupported,
          path: '/state/slots/r0c1/0/0',
          slotId: 'r0c1',
          args: {'token': 'gold2'},
        ),
      ]);
    });

    test('a move that is not a pair of slot ids', () {
      for (final move in <Object?>[
        'r0c2>r0c0',
        <Object?>['r0c2'],
        <Object?>['r0c2', 'r0c0', 'r0c1'],
      ]) {
        final json = jsonOf(step(8));
        ((json['history']! as List)[0] as Map)['move'] = move;
        expect(issuesOf(json), [
          issue(
            IssueCodes.wrongType,
            path: '/history/0/move',
            args: {'field': 'move', 'expected': 'pair'},
          ),
        ], reason: '$move');
      }
      final json = jsonOf(step(8));
      ((json['history']! as List)[1] as Map)['move'] = ['r0c1', null];
      expect(issuesOf(json), [
        issue(
          IssueCodes.wrongType,
          path: '/history/1/move/1',
          args: {'field': 'slotId', 'expected': 'string'},
        ),
      ]);
    });

    test('unknown keys: per object, sorted, after its known fields', () {
      final json = jsonOf(step(8))
        ..['zeta'] = 1
        ..['10'] = 2;
      boardOf(json, 'state')
        ..['b'] = 1
        ..['a'] = 2;
      ((json['history']! as List)[1] as Map)['events'] = <Object?>[];
      expect(issuesOf(json), [
        for (final path in [
          '/state/a',
          '/state/b',
          '/history/1/events',
          '/10',
          '/zeta',
        ])
          issue(
            IssueCodes.unknownField,
            path: path,
            args: {'field': path.substring(path.lastIndexOf('/') + 1)},
          ),
      ]);
    });

    test('schema issues stop decoding before the level id is compared', () {
      final json = jsonOf(step(0))
        ..['levelId'] = 'L0001'
        ..['undosUsed'] = null;
      expect(issuesOf(json), [
        issue(
          IssueCodes.wrongType,
          path: '/undosUsed',
          args: {'field': 'undosUsed', 'expected': 'integer'},
        ),
      ]);
    });
  });

  group('decode rejects (group 2: another level)', () {
    test('levelId is not the level\'s id', () {
      final json = jsonOf(step(8))..['levelId'] = 'L0001';
      boardOf(json, 'state')['moves'] = -1; // never looked at
      expect(issuesOf(json), [
        issue(
          IssueCodes.sessionLevelMismatch,
          path: '/levelId',
          args: {'expected': 'L0042', 'found': 'L0001'},
        ),
      ]);
    });
  });

  group('decode rejects (group 3: a board that is not one of the level)', () {
    // One broken board of the scenario after [steps] actions at [where],
    // edited by [edit]; exactly one issue for it.
    void expectBadBoard(
      String name,
      int steps,
      String where,
      void Function(Map<String, Object?> board) edit, {
      String? slotId,
    }) {
      test(name, () {
        final json = jsonOf(step(steps));
        edit(boardOf(json, where));
        expect(issuesOf(json), [badBoard(where, slotId: slotId)]);
      });
    }

    Map<String, Object?> slots(Map<String, Object?> board) =>
        board['slots']! as Map<String, Object?>;

    // Counters.
    expectBadBoard('extra above 2 (spec §3.6)', 0, 'state', (b) {
      b['extra'] = 3;
    });
    expectBadBoard('extra below 0', 0, 'state', (b) => b['extra'] = -1);
    expectBadBoard('negative moves', 0, 'state', (b) => b['moves'] = -1);
    expectBadBoard('moves past the engine\'s 32-bit counter', 0, 'state', (b) {
      b['moves'] = 0x80000000;
    });
    expectBadBoard('sets above the level\'s 3', 13, 'state', (b) {
      b['sets'] = 4;
    });
    expectBadBoard('negative sets', 0, 'state', (b) => b['sets'] = -1);

    // The slot ids of the board.
    expectBadBoard('a slot of the board missing', 8, 'history/1', (b) {
      slots(b).remove('r0c1');
    }, slotId: 'r0c1');
    expectBadBoard('an extra slot that is not in play', 0, 'state', (b) {
      slots(b)['x0'] = <Object?>[];
    }, slotId: 'x0');
    expectBadBoard('a slot the level does not have', 0, 'state', (b) {
      slots(b)['r2c0'] = <Object?>[];
    }, slotId: 'r2c0');

    // `opened`.
    expectBadBoard('an opened id that is not on the board', 0, 'state', (b) {
      b['opened'] = ['x0'];
    }, slotId: 'x0');
    expectBadBoard('an opened id twice', 8, 'state', (b) {
      b['opened'] = ['r1c0', 'r1c0'];
    }, slotId: 'r1c0');
    expectBadBoard('an open slot marked opened', 0, 'state', (b) {
      b['opened'] = ['r0c1'];
    }, slotId: 'r0c1');

    // Nests (spec §2.1).
    expectBadBoard('an empty nest', 0, 'state', (b) {
      slots(b)['r0c1'] = [<Object?>[]];
    }, slotId: 'r0c1');
    expectBadBoard('a nest of two colors', 0, 'state', (b) {
      slots(b)
        ..['r0c0'] = [
          ['red4', 'blue3'],
        ]
        ..['r1c1'] = [
          ['red3'],
        ];
    }, slotId: 'r0c0');
    expectBadBoard('sizes that are not consecutive', 0, 'state', (b) {
      slots(b)
        ..['r0c0'] = [
          ['red4', 'red2'],
        ]
        ..['r0c1'] = [
          ['red3'],
        ];
    }, slotId: 'r0c0');
    expectBadBoard('a doll above maxSize 4', 0, 'state', (b) {
      slots(b)['r0c1'] = [
        ['red5'],
      ];
    }, slotId: 'r0c1');
    expectBadBoard('a full set still on the board', 0, 'state', (b) {
      slots(b)
        ..['r0c0'] = [
          ['red4', 'red3', 'red2', 'red1'],
        ]
        ..['r0c2'] = [
          ['blue2'],
          ['green4'],
        ];
    }, slotId: 'r0c0');

    // Capacities (spec §3.1, §3.2).
    expectBadBoard('two nests in an open slot', 0, 'state', (b) {
      slots(b)
        ..['r0c1'] = [
          ['blue1'],
          ['red4', 'red3'],
        ]
        ..['r0c0'] = <Object?>[]
        ..['r1c2'] = <Object?>[];
    }, slotId: 'r0c1');
    expectBadBoard('two nests in a glass case', 0, 'state', (b) {
      slots(b)
        ..['r1c0'] = [
          ['green3', 'green2', 'green1'],
          ['blue1'],
        ]
        ..['r1c2'] = <Object?>[];
    }, slotId: 'r1c0');
    expectBadBoard('a tower deeper than it started', 0, 'state', (b) {
      slots(b)
        ..['r0c2'] = [
          ['blue2'],
          ['green4'],
          ['red2', 'red1'],
          ['blue1'],
        ]
        ..['r1c2'] = <Object?>[];
    }, slotId: 'r0c2');
    expectBadBoard('two nests in an emptied tower', 12, 'state', (b) {
      slots(b)
        ..['r0c2'] = [
          ['blue4', 'blue3', 'blue2'],
          ['blue1'],
        ]
        ..['r1c1'] = <Object?>[]
        ..['r1c2'] = <Object?>[];
    }, slotId: 'r0c2');

    // The engine's invariants (shared with SolverSnapshot.decode).
    expectBadBoard('a tower with no nest that is not opened', 12, 'state', (b) {
      b['opened'] = ['r1c0'];
    }, slotId: 'r0c2');
    expectBadBoard('dolls lost that are not whole sets', 0, 'state', (b) {
      slots(b)['r1c2'] = <Object?>[];
    });
    expectBadBoard('a set gone but not counted', 5, 'state', (b) {
      b['sets'] = 0;
    });
    expectBadBoard('a set counted but still on the board', 0, 'state', (b) {
      b['sets'] = 1;
    });

    // Boards play can't reach (spec §3.2–§3.4).
    expectBadBoard('a case broken with no set of its color', 0, 'state', (b) {
      b['opened'] = ['r1c0'];
    }, slotId: 'r1c0');
    expectBadBoard(
      'a case still locked after its color completed',
      5,
      'state',
      (b) {
        b['opened'] = <Object?>[];
      },
      slotId: 'r1c0',
    );
    expectBadBoard('a locked case whose nest changed', 0, 'state', (b) {
      slots(b)
        ..['r1c0'] = [
          ['green3', 'green2'],
        ]
        ..['r0c1'] = [
          ['green1'],
        ];
    }, slotId: 'r1c0');
    expectBadBoard('an iced slot whose nest changed', 0, 'state', (b) {
      slots(b)
        ..['r1c1'] = [
          ['blue4'],
        ]
        ..['r0c1'] = [
          ['blue3'],
        ];
    }, slotId: 'r1c1');
    expectBadBoard('nests under a tower\'s top that changed', 0, 'state', (b) {
      slots(b)['r0c2'] = [
        ['green4'],
        ['blue2'],
        ['red2', 'red1'],
      ];
    }, slotId: 'r0c2');
    expectBadBoard('a tower\'s top missing dolls it started with', 0, 'state', (
      b,
    ) {
      slots(b)
        ..['r0c2'] = [
          ['blue2'],
          ['green4'],
          ['red1'],
        ]
        ..['r0c1'] = [
          ['red2'],
        ];
    }, slotId: 'r0c2');

    test('one issue per bad board, state first', () {
      final json = jsonOf(step(8));
      boardOf(json, 'state')['extra'] = 3;
      boardOf(json, 'history/1')['sets'] = 9;
      slotsOf(json, 'history/0').remove('x0');
      expect(issuesOf(json), [
        badBoard('state'),
        badBoard('history/0', slotId: 'x0'),
        badBoard('history/1'),
      ]);
    });

    test('bad boards stop decoding before the history is replayed', () {
      final json = jsonOf(step(8));
      ((json['history']! as List)[0] as Map)['move'] = ['r1c2', 'r0c0'];
      boardOf(json, 'state')['moves'] = -4;
      expect(issuesOf(json), [badBoard('state')]);
    });

    test('a level the engine cannot lay out', () {
      final empty = Level(id: 'L0042', maxSize: 4, shelves: const []);
      expect(issuesOf(jsonOf(step(0)), on: empty), [badBoard('state')]);
    });
  });

  group('decode rejects (group 4: a history that does not replay)', () {
    test('a move the rules reject', () {
      final json = jsonOf(step(8));
      // r1c2 is empty on before#0.
      ((json['history']! as List)[0] as Map)['move'] = ['r1c2', 'r0c0'];
      expect(issuesOf(json), [badHistory(0)]);
    });

    test('a move to an unknown slot', () {
      final json = jsonOf(step(8));
      ((json['history']! as List)[1] as Map)['move'] = ['r0c1', 'x2'];
      expect(issuesOf(json), [badHistory(1)]);
    });

    test('a move that does not lead to the next board', () {
      final json = jsonOf(step(8));
      // blue1 onto x0 leaves x1 empty, but the state has blue1 on x1.
      ((json['history']! as List)[1] as Map)['move'] = ['r0c1', 'x0'];
      expect(issuesOf(json), [badHistory(1)]);
    });

    test('a move count that does not follow', () {
      final json = jsonOf(step(8));
      boardOf(json, 'state')['moves'] = 5;
      expect(issuesOf(json), [badHistory(1)]);
    });

    test('every entry that fails gets its issue', () {
      final json = jsonOf(step(8));
      ((json['history']! as List)[0] as Map)['move'] = ['r1c2', 'r0c0'];
      boardOf(json, 'state')['moves'] = 5;
      expect(issuesOf(json), [badHistory(0), badHistory(1)]);
    });

    test('an entry whose move completes a set (spec §2.4)', () {
      // The start, then A5's red set with the history kept: not a history a
      // session can have, since a completion clears it.
      final start = jsonOf(step(0));
      final completed = jsonOf(run(['r0c0>r0c2']));
      completed['history'] = [
        {
          'before': start['state'],
          'move': ['r0c0', 'r0c2'],
        },
      ];
      expect(issuesOf(completed), [badHistory(0)]);
    });

    test('extra slots that go down between boards (spec §3.6)', () {
      // After A6: one entry (before has x0) and the state with x0. Give the
      // before an x1 the state doesn't have.
      final json = jsonOf(step(6));
      boardOf(json, 'history/0')['extra'] = 2;
      slotsOf(json, 'history/0')['x1'] = <Object?>[];
      expect(issuesOf(json), [badHistory(0)]);
    });

    test('a history before a completion the state already counts', () {
      // before#0 of A8 put in front of the won board.
      final json = jsonOf(step(13));
      json['history'] = [(jsonOf(step(8))['history']! as List)[1]];
      expect(issuesOf(json), [badHistory(0)]);
    });

    test('the history is checked before undosUsed', () {
      final json = jsonOf(step(8))..['undosUsed'] = -1;
      boardOf(json, 'state')['moves'] = 5;
      expect(issuesOf(json), [badHistory(1)]);
    });
  });

  group('decode rejects (group 5: undosUsed)', () {
    test('a negative undosUsed', () {
      final json = jsonOf(step(8))..['undosUsed'] = -1;
      expect(issuesOf(json), [
        issue(
          IssueCodes.valueOutOfRange,
          path: '/undosUsed',
          args: {
            'field': 'undosUsed',
            'value': -1,
            'min': 0,
            'max': 9007199254740991,
          },
        ),
      ]);
    });
  });

  group('GameSessionDecodeResult', () {
    test('ok: a session and no issue', () {
      final result = GameSessionCodec.decode(jsonOf(step(3)), level);
      expect(result.isOk, isTrue);
      expect(result.issues, isEmpty);
      expect(result.toString(), contains('ok: true'));
    });

    test('its issues are unmodifiable', () {
      final result = GameSessionCodec.decode(null, level);
      expect(() => result.issues.clear(), throwsUnsupportedError);
    });

    test('never throws, whatever the input', () {
      final inputs = <Object?>[
        <String, Object?>{'format': 1},
        <String, Object?>{'format': 1, 'levelId': 'L0042', 'undosUsed': 0},
        <Object?, Object?>{1: 2, 'format': 1},
        {
          'format': 1,
          'levelId': 'L0042',
          'undosUsed': 0,
          'state': {'slots': null},
          'history': [
            {'move': <Object?>[]},
          ],
        },
        jsonOf(step(8))..['state'] = boardOf(jsonOf(step(0)), 'state'),
        jsonOf(step(13))..['history'] = jsonOf(step(12))['history'],
      ];
      for (final input in inputs) {
        expect(
          GameSessionCodec.decode(input, level).isOk,
          isFalse,
          reason: '$input',
        );
      }
    });
  });
}
