// The solver's canonical form (spec §6.2, docs/plans/m1-core-design.md §3):
// free slots (open-like, usable, not iced) are interchangeable, so boards
// that differ only by how their contents sit in free slots get one key;
// towers, still-locked cases and iced slots keep their identity. The key is
// hashed with Hash64 and doubles as the stored node.
//
// Platform-neutral: levels are built in code.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:nesty_core/src/solver/canonical.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:test/test.dart';

import '../rules/support/boards.dart';

/// Tutorial level 1 (design TUT1).
Level tut1() => board(3, [
  [open('red3'), open(), open('red2')],
  [open(), open('red1'), open()],
]);

/// One of each slot kind: open, empty open, tower, glass case, iced open.
Level mixed() => board(3, [
  [
    open('blue3'),
    open(),
    tower(['red1', 'blue2']),
    locked(DollColor.blue, 'red3'),
  ],
  [open('blue1', 1), open('red2')],
]);

CanonicalBoard canonicalOf(GameState state) =>
    CanonicalBoard(GameStateBoard.peek(state).layout, state.extraSlotCount);

/// The canonical key words of [state].
List<int> keyOf(GameState state) {
  final canonical = canonicalOf(state);
  final board = GameStateBoard.thaw(state);
  canonical.canonicalize(board);
  final words = Int32List(canonical.keyWords);
  final length = canonical.writeKey(board, words);
  return words.sublist(0, length);
}

int bit(GameState state, String id) => 1 << state.slotIds.indexOf(id);

void main() {
  group('free slots', () {
    test('open-like and usable slots are free; the rest keep identity', () {
      final state = GameState.initial(mixed());
      final canonical = canonicalOf(state);
      final board = GameStateBoard.peek(state);
      expect(
        canonical.freeMask(board.completedSets, board.openedMask),
        bit(state, 'r0c0') | bit(state, 'r0c1') | bit(state, 'r1c1'),
        reason: 'the tower, the case and the iced slot are fixed',
      );
    });

    test('an emptied tower, a broken case and thawed ice become free', () {
      var state = GameState.initial(
        board(3, [
          [
            open('blue3'),
            open(),
            tower(['red1', 'blue2']),
            locked(DollColor.blue, 'red3'),
          ],
          [open('blue1', 1), open('red2')],
          [open('green3 green2'), open('green1')],
        ]),
      );
      state = play(state, [
        // Green completes: the ice on r1c0 thaws (spec §3.4).
        'r2c1>r2c0',
        // blue2 leaves the tower, revealing red1; blue1, no longer iced,
        // completes blue, which breaks the blue case (spec §3.3).
        'r0c2>r0c0',
        'r1c0>r0c0',
        // red1 leaves the tower, which empties and opens (spec §3.2).
        'r0c2>r1c1',
      ]);
      final canonical = canonicalOf(state);
      final packed = GameStateBoard.peek(state);
      final free = canonical.freeMask(packed.completedSets, packed.openedMask);
      for (final id in state.slotIds) {
        expect(free & bit(state, id), isNonZero, reason: '$id is free');
      }
    });

    test('extra slots in play are free', () {
      final session = GameSession(mixed())..addExtraSlot();
      final state = session.state;
      final canonical = canonicalOf(state);
      final board = GameStateBoard.peek(state);
      expect(
        canonical.freeMask(board.completedSets, board.openedMask) &
            bit(state, 'x0'),
        isNonZero,
      );
      expect(canonical.activeSlots, state.slotIds.length);
    });
  });

  group('canonicalize', () {
    test('sorts the free codes along slot order, fixed slots untouched', () {
      final state = GameState.initial(mixed());
      final canonical = canonicalOf(state);
      final board = GameStateBoard.thaw(state);
      final before = Uint16List.fromList(board.cells);
      canonical.canonicalize(board);
      final layout = board.layout;
      int cellOf(String id) =>
          board.cells[layout.cellOffset[layout.indexOf(id)]];
      // Free: r0c0 blue3, r0c1 empty, r1c1 red2 → sorted: empty, then the
      // two codes in ascending order.
      final sorted = [
        NestCode.empty,
        NestCode.of(nest('blue3')),
        NestCode.of(nest('red2')),
      ]..sort();
      expect([cellOf('r0c0'), cellOf('r0c1'), cellOf('r1c1')], sorted);
      // The tower, the case and the iced slot keep their cells.
      for (final id in ['r0c2', 'r0c3', 'r1c0']) {
        final slot = layout.indexOf(id);
        final start = layout.cellOffset[slot];
        for (var c = start; c < start + layout.capacity[slot]; c++) {
          expect(board.cells[c], before[c], reason: id);
        }
      }
      expect(canonical.isCanonical(board), isTrue);
      final once = Uint16List.fromList(board.cells);
      canonical.canonicalize(board);
      expect(board.cells, once, reason: 'idempotent');
    });

    test('the canonical board plays like the original', () {
      final state = GameState.initial(mixed());
      final canonical = canonicalOf(state);
      final board = GameStateBoard.thaw(state);
      canonical.canonicalize(board);
      final same = GameStateBoard.adopt(board);
      expect(Rules.legalMoves(same).length, Rules.legalMoves(state).length);
      expect(Rules.isOutOfMoves(same), Rules.isOutOfMoves(state));
    });
  });

  group('keys', () {
    test('states that only permute free slots have one key', () {
      final start = GameState.initial(tut1());
      // A lone nest from one open slot to another: spec §6.3's pointless
      // move, the same canonical state.
      final moved = play(start, ['r1c1>r0c1']);
      expect(moved, isNot(start));
      expect(keyOf(moved), keyOf(start));
      // Different routes to the same position after real work.
      final a = play(start, ['r1c1>r0c2', 'r0c2>r0c0']);
      final b = play(start, ['r0c2>r0c0', 'r1c1>r0c0']);
      expect(keyOf(a), keyOf(b));
    });

    test('equal levels laid out in another order of open slots agree', () {
      final permuted = board(3, [
        [open(), open('red1'), open()],
        [open('red2'), open(), open('red3')],
      ]);
      expect(
        keyOf(GameState.initial(permuted)),
        keyOf(GameState.initial(tut1())),
      );
    });

    test('tower order, iced slots and cases keep their identity', () {
      Level withTower(List<String> stack) => board(3, [
        [tower(stack), open('blue3'), open()],
        [open('red3 red2'), open('red1')],
      ]);
      expect(
        keyOf(GameState.initial(withTower(['blue2', 'blue1']))),
        isNot(keyOf(GameState.initial(withTower(['blue1', 'blue2'])))),
      );

      Level withIce(String iced, String free) => board(3, [
        [open(iced, 1), open(free), open()],
        [open('blue3'), open('blue2 blue1')],
      ]);
      expect(
        keyOf(GameState.initial(withIce('red3', 'red2 red1'))),
        isNot(keyOf(GameState.initial(withIce('red2 red1', 'red3')))),
        reason: 'an iced nest is not interchangeable with a free one',
      );

      Level withCase(String sealed, String free) => board(3, [
        [locked(DollColor.blue, sealed), open(free), open()],
        [open('blue3'), open('blue2 blue1')],
      ]);
      expect(
        keyOf(GameState.initial(withCase('red3', 'red2 red1'))),
        isNot(keyOf(GameState.initial(withCase('red2 red1', 'red3')))),
      );
    });

    test('an iced broken case is not an iced locked case', () {
      final state = GameState.initial(
        board(3, [
          [locked(DollColor.blue, 'red3', 2), open('red2 red1'), open()],
          [open('blue3'), open('blue2 blue1')],
        ]),
      );
      final canonical = canonicalOf(state);
      final sealed = GameStateBoard.thaw(state);
      final broken = Board.copyOf(sealed)..openedMask = bit(state, 'r0c0');
      final a = Int32List(canonical.keyWords);
      final b = Int32List(canonical.keyWords);
      canonical
        ..writeKey(sealed, a)
        ..writeKey(broken, b);
      expect(b, isNot(a));
    });

    test('completed sets are part of the key (ice follows them)', () {
      final start = GameState.initial(tut1());
      final canonical = canonicalOf(start);
      final board = GameStateBoard.thaw(start);
      final a = Int32List(canonical.keyWords);
      final b = Int32List(canonical.keyWords);
      canonical.writeKey(board, a);
      board.completedSets = 1;
      canonical.writeKey(board, b);
      expect(b, isNot(a));
    });

    test('hash is Hash64.ofU32s of the key words', () {
      for (final level in [tut1(), mixed()]) {
        final state = GameState.initial(level);
        final canonical = canonicalOf(state);
        final words = Int32List.fromList(keyOf(state));
        canonical.hash(words, words.length);
        final expected = Hash64.ofU32s(words);
        expect(canonical.hashHi, expected.hi);
        expect(canonical.hashLo, expected.lo);
      }
    });

    test('unpack restores the board a key was written from', () {
      var state = GameState.initial(mixed());
      state = play(state, ['r0c2>r0c0']);
      final canonical = canonicalOf(state);
      final board = GameStateBoard.thaw(state);
      canonical.canonicalize(board);
      final words = Int32List(canonical.keyWords);
      expect(canonical.writeKey(board, words), canonical.keyWords);
      final restored = GameStateBoard.thaw(GameState.initial(mixed()));
      canonical.unpack(words, 0, restored);
      expect(restored.cells, board.cells);
      expect(restored.completedSets, board.completedSets);
      expect(restored.openedMask, board.openedMask);
    });

    test('three codes per word without gold, two with gold (spec §3.5)', () {
      final plain = canonicalOf(GameState.initial(tut1()));
      expect(plain.triples, isTrue);
      final cells = GameStateBoard.peek(GameState.initial(tut1())).cells;
      expect(
        plain.keyWords,
        CanonicalBoard.headerWords + (cells.length + 2) ~/ 3,
      );

      final withGold = board(3, [
        [open('red3'), open('gold2'), open('red1')],
        [open(), open()],
      ]);
      final state = GameState.initial(withGold);
      final golden = canonicalOf(state);
      expect(golden.triples, isFalse);
      // A merged nest carries the golden doll's size in bits 10–12, which
      // only the 16-bit packing can hold; it round-trips through a key.
      final after = play(state, ['r0c1>r0c0']);
      final board2 = GameStateBoard.thaw(after);
      golden.canonicalize(board2);
      expect(board2.cells.any((code) => NestCode.gold(code) != 0), isTrue);
      final words = Int32List(golden.keyWords);
      golden.writeKey(board2, words);
      final restored = GameStateBoard.thaw(state);
      golden.unpack(words, 0, restored);
      expect(restored.cells, board2.cells);
    });
  });
}
