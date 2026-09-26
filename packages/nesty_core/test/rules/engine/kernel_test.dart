// The engine under the Rules facade (docs/plans/m1-core-design.md §2–§3):
// BoardLayout compilation, the Board header and cells, the kernel's outcome
// codes, its legal-move routines (which must agree with each other and with
// tryMove), the MoveLog, and the defensive `else invalid` branch of §4.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/move_log.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:test/test.dart';

import '../../models/spec_example_level.dart' show specExampleLevel;
import '../support/boards.dart';

void main() {
  group('BoardLayout', () {
    final level = specExampleLevel();
    final layout = BoardLayout.of(level);

    test('is compiled once per level instance', () {
      expect(BoardLayout.of(level), same(layout));
      expect(BoardLayout.of(specExampleLevel()), isNot(same(layout)));
    });

    test('indexes grid slots row-major, then the reserved x0, x1', () {
      expect(layout.ids, [...level.slotIds, 'x0', 'x1']);
      expect(layout.gridSlotCount, 6);
      expect(layout.slotCount, 8);
      expect(layout.indexOf('r1c0'), 3);
      expect(layout.indexOf('x1'), 7);
      expect(layout.indexOf('nope'), -1);
      expect(layout.activeIds(0), level.slotIds);
      expect(layout.activeIds(1).last, 'x0');
      expect(layout.positionAt(6), const BoardPosition(1, 3));
    });

    test('gives each slot its cells: 1, or the tower depth', () {
      expect(layout.capacity.toList(), [1, 1, 3, 1, 1, 1, 1, 1]);
      expect(layout.cellOffset.toList(), [0, 1, 2, 5, 6, 7, 8, 9]);
      expect(layout.cellCount, 10);
      expect(layout.initialCells.toList(), [
        NestCode.of(nest('red4 red3')),
        NestCode.empty,
        NestCode.of(nest('blue2')),
        NestCode.of(nest('green4')),
        NestCode.of(nest('red2 red1')),
        NestCode.of(nest('green3 green2 green1')),
        NestCode.of(nest('blue4 blue3')),
        NestCode.of(nest('blue1')),
        NestCode.empty,
        NestCode.empty,
      ]);
    });

    test('records kinds, unlock colors, starting ice and doll counts', () {
      expect(layout.kind.toList(), [0, 0, 1, 2, 0, 0, 0, 0]);
      expect(layout.unlockColor[3], DollColor.red.index);
      expect(layout.unlockColor[0], BoardLayout.noColor);
      expect(layout.lockedByColor[DollColor.red.index], 1 << 3);
      expect(layout.initialIce.toList(), [0, 0, 0, 0, 2, 0, 0, 0]);
      expect(layout.initialDolls[DollColor.red.index], 4);
      expect(layout.initialDolls[DollColor.blue.index], 4);
      expect(layout.maxSize, 4);
      expect(layout.totalSets, 3);
    });
  });

  group('Board', () {
    final layout = BoardLayout.of(specExampleLevel());

    test('starts as the layout', () {
      final board = Board(layout);
      expect(board.cells, layout.initialCells);
      expect(board.completedSets, 0);
      expect(board.openedMask, 0);
      expect(board.extraCount, 0);
      expect(board.moveCount, 0);
      expect(board.activeSlotCount, 6);
    });

    test('copies, compares, resets', () {
      final board = Board(layout);
      Kernel.tryApply(board, 0, 2); // the red swallow: a completion
      final copy = Board.copyOf(board);
      expect(copy.sameAs(board), isTrue);
      expect(copy.contentHash, board.contentHash);
      final other = Board(layout)..copyFrom(board);
      expect(other.sameAs(board), isTrue);
      board
        ..addExtraSlot()
        ..reset(keepExtraSlots: true);
      expect(board.extraCount, 1);
      expect(board.cells, layout.initialCells);
      expect(board.completedSets, 0);
      board.reset();
      expect(board.extraCount, 0);
      expect(copy.completedSets, 1);
    });

    test('adds at most two extra slots', () {
      final board = Board(layout);
      expect(board.addExtraSlot(), isTrue);
      expect(board.addExtraSlot(), isTrue);
      expect(board.addExtraSlot(), isFalse);
      expect(board.extraCount, 2);
    });

    test('copyFrom refuses a board of another shape', () {
      final board = Board(layout);
      final small = Board(
        BoardLayout.of(
          board3([
            [open('red1'), open()],
          ]),
        ),
      );
      expect(() => board.copyFrom(small), throwsArgumentError);
    });
  });

  group('MoveOutcome', () {
    test('rejection codes follow InvalidMoveReason declaration order', () {
      final codes = [
        MoveOutcome.rejectUnknownSlot,
        MoveOutcome.rejectSameSlot,
        MoveOutcome.rejectSourceEmpty,
        MoveOutcome.rejectSourceFrozen,
        MoveOutcome.rejectSourceLocked,
        MoveOutcome.rejectTargetFrozen,
        MoveOutcome.rejectTargetLocked,
        MoveOutcome.rejectColorMismatch,
        MoveOutcome.rejectSizeMismatch,
        MoveOutcome.rejectTargetOccupied,
      ];
      expect(codes, hasLength(InvalidMoveReason.values.length));
      for (final reason in InvalidMoveReason.values) {
        expect(codes[reason.index], MoveOutcome.rejectionOf(reason));
        expect(MoveOutcome.reasonOf(codes[reason.index]), reason);
      }
      expect(() => MoveOutcome.reasonOf(1), throwsArgumentError);
    });

    test('legal outcomes carry the kind and the completion bit', () {
      final board = Board(BoardLayout.of(specExampleLevel()));
      final place = Kernel.check(board, 0, 1);
      final swallowCompletes = Kernel.check(board, 0, 2);
      final inside = Kernel.check(board, 2, 0);
      expect(MoveOutcome.kindOf(place), MoveOutcome.placed);
      expect(MoveOutcome.isMerge(place), isFalse);
      expect(MoveOutcome.kindOf(swallowCompletes), MoveOutcome.swallow);
      expect(MoveOutcome.completes(swallowCompletes), isTrue);
      expect(MoveOutcome.kindOf(inside), MoveOutcome.inside);
      expect(MoveOutcome.isMerge(inside), isTrue);
      // [red2, red1] into [red4, red3] gives red4..red1: full at maxSize 4.
      expect(MoveOutcome.completes(inside), isTrue);
    });

    test('LegalMove packs from, to and outcome in sortable order', () {
      final entry = LegalMove.pack(21, 13, 7);
      expect(LegalMove.from(entry), 21);
      expect(LegalMove.to(entry), 13);
      expect(LegalMove.outcome(entry), 7);
      expect(LegalMove.pack(1, 0, 1), greaterThan(LegalMove.pack(0, 29, 7)));
    });
  });

  group('Kernel', () {
    test('tryApply agrees with check, and a rejection changes nothing', () {
      final layout = BoardLayout.of(specExampleLevel());
      final board = Board(layout);
      final log = MoveLog();
      for (var from = -1; from <= layout.slotCount; from++) {
        for (var to = -1; to <= layout.slotCount; to++) {
          final expected = Kernel.check(board, from, to);
          final trial = Board.copyOf(board);
          log.clear();
          final outcome = Kernel.tryApply(trial, from, to, log);
          expect(outcome, expected, reason: '$from -> $to');
          if (outcome < 0) {
            expect(trial.sameAs(board), isTrue, reason: '$from -> $to');
            expect(log.from, -1, reason: '$from -> $to');
          } else {
            expect(trial.moveCount, 1);
            expect(log.outcome, outcome);
          }
        }
      }
    });

    test('the legal-move routines agree with each other and with Rules', () {
      var state = GameState.initial(specExampleLevel());
      for (final move in ['r0c0>r0c2', 'r1c0>r0c2', 'r1c2>r0c2', '']) {
        final board = GameStateBoard.peek(state);
        final buffer = Int32List(Kernel.legalMoveCapacity(board.layout));
        final count = Kernel.collectLegalMoves(board, buffer);
        final collected = [
          for (var i = 0; i < count; i++)
            (
              LegalMove.from(buffer[i]),
              LegalMove.to(buffer[i]),
              LegalMove.outcome(buffer[i]),
            ),
        ];
        final visited = <(int, int, int)>[];
        Kernel.forEachLegalMove(board, (f, t, o) => visited.add((f, t, o)));
        expect(visited, collected);
        for (final (from, to, outcome) in collected) {
          expect(Kernel.check(board, from, to), outcome);
        }
        final ids = board.layout.ids;
        expect(Rules.legalMoves(state), [
          for (final (from, to, _) in collected) Move(ids[from], ids[to]),
        ]);
        expect(Kernel.hasLegalMove(board), count > 0);
        if (move.isEmpty) break;
        state = apply(state, move).state;
      }
    });

    test('the log of a tower-to-tower completion', () {
      final state = GameState.initial(
        board3([
          [
            tower(['green3', 'red1']),
            tower(['blue3', 'red3 red2']),
            locked(DollColor.red, 'green2 green1'),
          ],
          [open('blue2 blue1', 1), open()],
        ]),
      );
      final board = GameStateBoard.thaw(state);
      final log = MoveLog();
      final outcome = Kernel.tryApply(board, 0, 1, log);
      expect(outcome, MoveOutcome.inside | MoveOutcome.completedBit);
      expect(log.from, 0);
      expect(log.to, 1);
      expect(log.moving, NestCode.of(nest('red1')));
      expect(log.target, NestCode.of(nest('red3 red2')));
      expect(log.merged, NestCode.of(nest('red3 red2 red1')));
      expect(log.sourceWasTower, isTrue);
      expect(log.sourceEmptied, isFalse);
      expect(log.sourceRevealed, NestCode.of(nest('green3')));
      expect(log.sourceHiddenBelow, 0);
      expect(log.completed, isTrue);
      expect(log.completedColor, DollColor.red.index);
      expect(log.destEmptied, isFalse);
      expect(log.destRevealed, NestCode.of(nest('blue3')));
      expect(log.unlockedMask, 1 << 2);
      expect(board.openedMask, 1 << 2);
      expect(board.completedSets, 1);
      expect(Kernel.iceOf(board, 3), 0);
      expect(Kernel.nestCount(board), 4);
    });

    test('queries per slot kind', () {
      final board = Board(BoardLayout.of(specExampleLevel()));
      expect(Kernel.isTower(board, 2), isTrue);
      expect(Kernel.height(board, 2), 3);
      expect(Kernel.top(board, 2), NestCode.of(nest('red2 red1')));
      expect(Kernel.topCell(board, 1), -1);
      expect(Kernel.height(board, 1), 0);
      expect(Kernel.isLocked(board, 3), isTrue);
      expect(Kernel.isOpenLike(board, 3), isFalse);
      expect(Kernel.iceOf(board, 4), 2);
      expect(Kernel.isInteractable(board, 4), isFalse);
      expect(Kernel.isActive(board, 6), isFalse);
      expect(Kernel.isInteractable(board, 6), isFalse);
      expect(Kernel.isOpenLike(board, 6), isTrue);
      expect(Kernel.nestCount(board), 7);
      expect(Kernel.isWon(board), isFalse);
      expect(Kernel.isOutOfMoves(board), isFalse);
    });

    test("§4's `else invalid` for an empty target that is not open", () {
      // Unreachable in play (a tower is never empty while it is a tower),
      // so forge one: empty a tower's cells without marking it opened.
      final state = GameState.initial(
        board3([
          [
            tower(['blue3', 'red2']),
            open('red1'),
          ],
        ]),
      );
      final board = GameStateBoard.thaw(state);
      board.cells
        ..[0] = NestCode.empty
        ..[1] = NestCode.empty;
      expect(Kernel.check(board, 1, 0), MoveOutcome.rejectTargetOccupied);
      expect(Kernel.hasLegalMove(board), isFalse);
      final buffer = Int32List(Kernel.legalMoveCapacity(board.layout));
      expect(Kernel.collectLegalMoves(board, buffer), 0);
    });

    test('the gold hook merges through the kernel (spec §3.5)', () {
      final state = GameState.initial(
        board3([
          [open('gold3'), open('red2 red1')],
        ]),
      );
      final board = GameStateBoard.thaw(state);
      final log = MoveLog();
      // [red2, red1] goes inside [gold3]: 2 == 3 − 1, and gold matches.
      final outcome = Kernel.tryApply(board, 1, 0, log);
      expect(outcome, MoveOutcome.inside | MoveOutcome.completedBit);
      expect(log.completedColor, DollColor.red.index);
      expect(Kernel.check(board, 0, 1), MoveOutcome.rejectSourceEmpty);
    });
  });
}

Level board3(List<List<Slot>> shelves) => board(3, shelves);
