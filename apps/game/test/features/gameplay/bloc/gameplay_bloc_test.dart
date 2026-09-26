import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import '../../../helpers/level_fixtures.dart';
import 'support/bloc_fixtures.dart';
import 'support/scripted_solver_service.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

typedef _State = AsyncValue<GameplayState>;

/// Adds [GameplayStarted] for level 1, then [events] in order.
void _startThen(GameplayBloc bloc, [List<GameplayEvent> events = const []]) {
  bloc.add(const GameplayStarted(1));
  events.forEach(bloc.add);
}

/// Taps [from] then [to] (tap-tap move).
List<GameplayEvent> _tapMove(String from, String to) => [
  SlotTapped(from),
  SlotTapped(to),
];

void main() {
  final start = GameState.initial(tutorialLevel);
  final entry = entryFor(tutorialLevel);

  group('Started', () {
    blocTest<GameplayBloc, _State>(
      'loads the level into a session and resets the board',
      build: buildBloc,
      act: _startThen,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.entry, 'entry', entry)
              .having((d) => d.board, 'board', start)
              .having((d) => d.levelNumber, 'levelNumber', 1)
              .having((d) => d.setsCompleted, 'setsCompleted', 0)
              .having((d) => d.totalSets, 'totalSets', 1)
              .having((d) => d.status, 'status', GameplayStatus.playing)
              .having(
                (d) => d.freeUndosLeft,
                'freeUndosLeft',
                RemoteConfigKeys.freeUndosPerLevel.defaultValue,
              )
              .having((d) => d.canUndo, 'canUndo', isFalse)
              .having(
                (d) => d.hintsLeft,
                'hintsLeft',
                BoosterKind.hint.starterGift,
              )
              .having((d) => d.canHint, 'canHint', isTrue)
              .having(
                (d) => d.extraSlotsLeft,
                'extraSlotsLeft',
                BoosterKind.extraSlot.starterGift,
              )
              .having((d) => d.canAddSlot, 'canAddSlot', isTrue)
              .having((d) => d.coins, 'coins', 0)
              .having((d) => d.unlimitedBoosters, 'unlimited', isFalse)
              .having((d) => d.moveSeq, 'moveSeq', 0)
              .having((d) => d.effectSeq, 'effectSeq', 1)
              .having(
                (d) => d.effect,
                'effect',
                BoardResetEffect(
                  snapshot: start,
                  reason: BoardResetReason.start,
                ),
              ),
        ),
      ],
      verify: (bloc) => expect(bloc.session?.level, tutorialLevel),
    );

    blocTest<GameplayBloc, _State>(
      'a level past the bundle is missing content',
      build: buildBloc,
      act: (bloc) => bloc.add(const GameplayStarted(2)),
      expect: () => [
        isA<AsyncValueError<GameplayState>>().having(
          (s) => s.exception.kind,
          'kind',
          AppExceptionKind.content,
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'input before a level is loaded does nothing',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const SlotTapped(red1))
        ..add(const HintPressed())
        ..add(const UndoPressed())
        ..add(const NextLevelPressed()),
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'the free undos come from Remote Config',
      build: () => buildBloc(
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 5),
      ),
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).freeUndosLeft, 5),
    );
  });

  group('tap policy (frame 2.6)', () {
    blocTest<GameplayBloc, _State>(
      'a tap on a pickable nest selects it',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [const SlotTapped(red1)]),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', red1)
              .having((d) => d.effectSeq, 'effectSeq', 2)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(selected: red1),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a tap on the selected nest cancels',
      build: buildBloc,
      act: (bloc) =>
          _startThen(bloc, [const SlotTapped(red1), const SlotTapped(red1)]),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(previous: red1),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'with nothing selected, a tap on an empty slot is ignored',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [const SlotTapped(emptyTop)]),
      skip: 1,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'with nothing selected, a tap on an iced nest is ignored',
      build: () => buildBloc(entries: [entryFor(icedLevel)]),
      act: (bloc) => _startThen(bloc, [const SlotTapped(red2)]),
      skip: 1,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'a tap on a legal target moves through core',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, _tapMove(red1, red2)),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having((d) => d.moveSeq, 'moveSeq', 1)
              .having((d) => d.effectSeq, 'effectSeq', 3)
              .having((d) => d.status, 'status', GameplayStatus.playing)
              .having((d) => d.canUndo, 'canUndo', isTrue)
              .having(
                (d) => d.effect,
                'effect',
                isA<MoveAppliedEffect>()
                    .having((e) => e.byDrag, 'byDrag', isFalse)
                    .having(
                      (e) => e.result.move,
                      'move',
                      const Move(red1, red2),
                    )
                    .having(
                      (e) => e.result.events.whereType<NestedInto>().single,
                      'nested',
                      isA<NestedInto>().having(
                        (n) => n.direction,
                        'direction',
                        NestDirection.inside,
                      ),
                    ),
              ),
        ),
      ],
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.board, bloc.session!.state);
        final applied = data.effect! as MoveAppliedEffect;
        expect(data.board, applied.result.state);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a tap on a pickable nest of the wrong size is invalid, not a switch',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, _tapMove(red3, red1)),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having((d) => d.board, 'board', start)
              .having((d) => d.moveSeq, 'moveSeq', 0)
              .having(
                (d) => d.effect,
                'effect',
                const MoveRejectedEffect(
                  source: red3,
                  target: red1,
                  reason: InvalidMoveReason.sizeMismatch,
                ),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a tap on an iced target is invalid with core\'s reason',
      build: () => buildBloc(entries: [entryFor(icedLevel)]),
      act: (bloc) => _startThen(bloc, _tapMove(red1, red2)),
      skip: 2,
      expect: () => [
        effectIs(
          const MoveRejectedEffect(
            source: red1,
            target: red2,
            reason: InvalidMoveReason.targetFrozen,
          ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'after an invalid tap the next tap selects again',
      build: buildBloc,
      act: (bloc) =>
          _startThen(bloc, [..._tapMove(red3, red1), const SlotTapped(red1)]),
      skip: 3,
      expect: () => [effectIs(const SelectionChangedEffect(selected: red1))],
    );
  });

  group('drag and drop', () {
    blocTest<GameplayBloc, _State>(
      'a drag start selects and a drop on a legal target moves',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red1),
        const SlotDragDropped(red2),
      ]),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', red1)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(selected: red1, byDrag: true),
              ),
        ),
        effectIs(
          isA<MoveAppliedEffect>()
              .having((e) => e.byDrag, 'byDrag', isTrue)
              .having((e) => e.result.move, 'move', const Move(red1, red2)),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a drop on nothing cancels the drag',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red1),
        const SlotDragDropped(null),
      ]),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(previous: red1, byDrag: true),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a drop back on its own slot cancels the drag',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red1),
        const SlotDragDropped(red1),
      ]),
      skip: 2,
      expect: () => [
        effectIs(const SelectionChangedEffect(previous: red1, byDrag: true)),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a drop on another slot that is not a legal target is invalid',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red3),
        const SlotDragDropped(red1),
      ]),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having(
                (d) => d.effect,
                'effect',
                const MoveRejectedEffect(
                  source: red3,
                  target: red1,
                  reason: InvalidMoveReason.sizeMismatch,
                  byDrag: true,
                ),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a drag from an unpickable slot does nothing, and neither does its drop',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(emptyTop),
        const SlotDragDropped(red2),
      ]),
      skip: 1,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'dragging the nest a tap lifted settles nothing',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotTapped(red1),
        const SlotDragStarted(red1),
      ]),
      skip: 2,
      expect: () => [
        effectIs(const SelectionChangedEffect(selected: red1, byDrag: true)),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'dragging another nest while one is lifted switches to it',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotTapped(red3),
        const SlotDragStarted(red1),
      ]),
      skip: 2,
      expect: () => [
        effectIs(
          const SelectionChangedEffect(
            previous: red3,
            selected: red1,
            byDrag: true,
          ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'Undo from a second finger ends the drag: its drop applies no phantom '
      'move (review CORRECTNESS-2)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        ..._tapMove(red1, red2),
        const SlotDragStarted(red3),
        const UndoPressed(),
        const SlotDragDropped(emptyTop),
      ]),
      skip: 4,
      expect: () => [
        effectIs(
          isA<BoardResetEffect>().having(
            (e) => e.reason,
            'reason',
            BoardResetReason.undo,
          ),
        ),
      ],
      verify: (bloc) {
        expect(dataOf(bloc).board, start);
        expect(dataOf(bloc).selectedSlotId, isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'Restart from a second finger ends the drag too',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red3),
        const RestartPressed(),
        const SlotDragDropped(emptyTop),
      ]),
      skip: 2,
      expect: () => [
        effectIs(
          isA<BoardResetEffect>().having(
            (e) => e.reason,
            'reason',
            BoardResetReason.restart,
          ),
        ),
      ],
      verify: (bloc) => expect(dataOf(bloc).board, start),
    );

    blocTest<GameplayBloc, _State>(
      'a drag released while paused puts the doll down (a cancel by drag), '
      'so it flies home on Resume (review CORRECTNESS-3)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red1),
        const PauseChanged(paused: true),
        const SlotDragDropped(null),
        const PauseChanged(paused: false),
      ]),
      skip: 3,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.paused, 'paused', isTrue)
              .having((d) => d.selectedSlotId, 'selected', isNull)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(previous: red1, byDrag: true),
              ),
        ),
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.paused, 'paused', isFalse)
              .having((d) => d.selectedSlotId, 'selected', isNull),
        ),
      ],
      verify: (bloc) => expect(dataOf(bloc).board, start),
    );

    blocTest<GameplayBloc, _State>(
      'a tap during a drag ends the drag, so its late drop does nothing',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted(red1),
        const SlotTapped(red2),
        const SlotDragDropped(null),
      ]),
      skip: 2,
      expect: () => [
        effectIs(
          isA<MoveAppliedEffect>().having((e) => e.byDrag, 'byDrag', isFalse),
        ),
      ],
    );
  });

  group('undo', () {
    blocTest<GameplayBloc, _State>(
      'reverts the last move and uses a free undo',
      build: buildBloc,
      act: (bloc) =>
          _startThen(bloc, [..._tapMove(red1, red2), const UndoPressed()]),
      skip: 3,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.board, 'board', start)
              .having((d) => d.moveSeq, 'moveSeq', 2)
              .having((d) => d.freeUndosLeft, 'freeUndosLeft', 1)
              .having((d) => d.canUndo, 'canUndo', isFalse)
              .having(
                (d) => d.effect,
                'effect',
                BoardResetEffect(
                  snapshot: start,
                  reason: BoardResetReason.undo,
                  undo: UndoResult(
                    revertedMove: const Move(red1, red2),
                    restoredState: start,
                  ),
                ),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'with nothing to undo does nothing',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [const UndoPressed()]),
      skip: 1,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'stops when the free undos run out (the coin path is M3)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        for (var i = 0; i < 3; i++) ...[
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
        ],
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.freeUndosLeft, 0);
        expect(data.canUndo, isFalse);
        // The third undo was refused: the third move is still on the board.
        expect(bloc.session!.undosUsed, 2);
        expect(bloc.session!.canUndo, isTrue);
        expect(data.board.slot(emptyTop).isEmpty, isFalse);
      },
    );

    blocTest<GameplayBloc, _State>(
      'unlimited boosters (dev flavor) never run out of undos',
      build: () => buildBloc(save: FakeSaveService(unlimitedBoosters: true)),
      act: (bloc) => _startThen(bloc, [
        for (var i = 0; i < 3; i++) ...[
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
        ],
      ]),
      verify: (bloc) {
        expect(bloc.session!.undosUsed, 3);
        expect(dataOf(bloc).board, start);
        expect(dataOf(bloc).unlimitedBoosters, isTrue);
      },
    );

    blocTest<GameplayBloc, _State>(
      'clears the selection and the hint with the board reset',
      build: buildBloc,
      act: (bloc) async {
        _startThen(bloc, _tapMove(red1, emptyTop));
        bloc.add(const HintPressed());
        await settle();
        bloc
          ..add(const SlotTapped(red3))
          ..add(const UndoPressed());
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.effect, isA<BoardResetEffect>());
        expect(data.selectedSlotId, isNull);
        expect(data.hint, isNull);
      },
    );
  });

  group('restart', () {
    blocTest<GameplayBloc, _State>(
      'resets the board, keeping the extra slots and the undo count',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const ExtraSlotPressed(),
        ..._tapMove(red1, emptyTop),
        const UndoPressed(),
        ..._tapMove(red3, 'x0'),
        const RestartPressed(),
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        final restarted = data.effect! as BoardResetEffect;
        expect(restarted.reason, BoardResetReason.restart);
        expect(data.board.extraSlotCount, 1);
        expect(data.board.slotIds.last, 'x0');
        expect(data.board.slot('x0').isEmpty, isTrue);
        expect(data.board.slot(red3).isEmpty, isFalse);
        expect(data.board.moveCount, 0);
        expect(restarted.snapshot, data.board);
        expect(data.freeUndosLeft, 1);
        expect(data.canUndo, isFalse);
        expect(data.status, GameplayStatus.playing);
      },
    );

    blocTest<GameplayBloc, _State>(
      'works from the Out-of-Moves sheet',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: (bloc) => _startThen(bloc, [
        ..._tapMove('r0c0', 'r0c3'),
        const RestartPressed(),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.playing);
        expect(dataOf(bloc).board, GameState.initial(outOfMovesLevel));
      },
    );
  });

  group('extra slot', () {
    blocTest<GameplayBloc, _State>(
      'adds at most 2 per level, each from the inventory',
      build: () => buildBloc(save: saveWith(extraSlots: 5)),
      act: (bloc) => _startThen(bloc, [
        const ExtraSlotPressed(),
        const ExtraSlotPressed(),
        const ExtraSlotPressed(),
      ]),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.moveSeq, 'moveSeq', 1)
              .having((d) => d.extraSlotsLeft, 'extraSlotsLeft', 4)
              .having((d) => d.canAddSlot, 'canAddSlot', isTrue)
              .having(
                (d) => d.effect,
                'effect',
                isA<ExtraSlotAddedEffect>().having(
                  (e) => e.result.slotId,
                  'slotId',
                  'x0',
                ),
              ),
        ),
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.extraSlotsLeft, 'extraSlotsLeft', 3)
              .having((d) => d.canAddSlot, 'canAddSlot', isFalse)
              .having((d) => d.board.extraSlotCount, 'extras', 2)
              .having(
                (d) => d.effect,
                'effect',
                isA<ExtraSlotAddedEffect>().having(
                  (e) => e.result.slotId,
                  'slotId',
                  'x1',
                ),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'with an empty inventory does nothing',
      build: () => buildBloc(save: saveWith(extraSlots: 0)),
      act: (bloc) => _startThen(bloc, [const ExtraSlotPressed()]),
      skip: 1,
      expect: () => const <_State>[],
      verify: (bloc) => expect(dataOf(bloc).canAddSlot, isFalse),
    );

    blocTest<GameplayBloc, _State>(
      'is free in debug builds: the inventory is untouched, the limit holds',
      build: () =>
          buildBloc(save: saveWith(extraSlots: 0), freeExtraSlots: true),
      act: (bloc) => _startThen(bloc, [
        const ExtraSlotPressed(),
        const ExtraSlotPressed(),
        const ExtraSlotPressed(),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).board.extraSlotCount, 2);
        expect(dataOf(bloc).extraSlotsLeft, 0);
        expect(dataOf(bloc).canAddSlot, isFalse);
      },
    );

    blocTest<GameplayBloc, _State>(
      'rescues an out-of-moves board',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: (bloc) => _startThen(bloc, [
        ..._tapMove('r0c0', 'r0c3'),
        const ExtraSlotPressed(),
      ]),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>().having(
            (d) => d.status,
            'status',
            GameplayStatus.outOfMoves,
          ),
        ),
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.playing)
              .having((d) => d.effect, 'effect', isA<ExtraSlotAddedEffect>()),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'keeps the selection: the lifted nest re-pitches with its row',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const SlotTapped(red1),
        const ExtraSlotPressed(),
        const SlotTapped('x0'),
      ]),
      verify: (bloc) {
        final applied = dataOf(bloc).effect! as MoveAppliedEffect;
        expect(applied.result.move, const Move(red1, 'x0'));
      },
    );
  });

  group('hint', () {
    final solverHint = Solver.hint(start).move!;

    blocTest<GameplayBloc, _State>(
      'shows the solver\'s move and uses one hint',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [const HintPressed()]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.hint, 'hint', solverHint)
              .having((d) => d.hintsLeft, 'hintsLeft', 2)
              .having((d) => d.effect, 'effect', HintShownEffect(solverHint)),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'any tap clears it first, then plays the tap',
      build: buildBloc,
      act: (bloc) async {
        _startThen(bloc, [const HintPressed()]);
        await settle();
        bloc.add(const SlotTapped(red1));
      },
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.hint, 'hint', isNull)
              .having((d) => d.effect, 'effect', const HintClearedEffect()),
        ),
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.effectSeq, 'effectSeq', 4)
              .having(
                (d) => d.effect,
                'effect',
                const SelectionChangedEffect(selected: red1),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'an ignored tap still clears it',
      build: buildBloc,
      act: (bloc) async {
        _startThen(bloc, [const HintPressed()]);
        await settle();
        bloc.add(const SlotTapped(emptyTop));
      },
      skip: 2,
      expect: () => [effectIs(const HintClearedEffect())],
    );

    blocTest<GameplayBloc, _State>(
      'a result for an older board is dropped, and nothing is charged',
      build: () => buildBloc(solver: ScriptedSolverService(holdHints: true)),
      act: (bloc) async {
        _startThen(bloc, [const HintPressed(), ..._tapMove(red1, emptyTop)]);
        await settle();
        final solver = scriptedSolverOf(bloc);
        expect(solver.heldHints, hasLength(1));
        solver.heldHints.single.complete(Solver.hint(start));
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.hint, isNull);
        expect(data.effect, isA<MoveAppliedEffect>());
        expect(data.hintsLeft, BoosterKind.hint.starterGift);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a second press while one is asked does not ask twice',
      build: () => buildBloc(solver: ScriptedSolverService(holdHints: true)),
      act: (bloc) async {
        _startThen(bloc, [const HintPressed(), const HintPressed()]);
        await settle();
      },
      verify: (bloc) =>
          expect(scriptedSolverOf(bloc).hintRequests, hasLength(1)),
    );

    blocTest<GameplayBloc, _State>(
      'a proven dead end shows no move, sets soft stuck and costs nothing',
      build: () => buildBloc(
        solver: ScriptedSolverService(
          onHint: (_) => const HintResult(
            source: HintSource.none,
            verdict: SolveVerdict.unsolvable,
            nodes: 12,
          ),
        ),
      ),
      act: (bloc) => _startThen(bloc, [const HintPressed()]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.softStuck, 'softStuck', isTrue)
              .having((d) => d.hint, 'hint', isNull)
              .having((d) => d.hintsLeft, 'hintsLeft', 3)
              // A HUD change only: no new board effect.
              .having((d) => d.effectSeq, 'effectSeq', 1),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a failed search falls back to core\'s fallback hint',
      build: () =>
          buildBloc(solver: ScriptedSolverService(onHint: (_) => null)),
      act: (bloc) => _startThen(bloc, [const HintPressed()]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [effectIs(HintShownEffect(Solver.fallbackHint(start)!))],
    );

    blocTest<GameplayBloc, _State>(
      'with no hints left does nothing and asks nothing',
      build: () =>
          buildBloc(solver: ScriptedSolverService(), save: saveWith(hints: 0)),
      act: (bloc) => _startThen(bloc, [const HintPressed()]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => const <_State>[],
      verify: (bloc) {
        expect(dataOf(bloc).canHint, isFalse);
        expect(scriptedSolverOf(bloc).hintRequests, isEmpty);
      },
    );

    blocTest<GameplayBloc, _State>(
      'unlimited boosters (dev flavor) never use up hints',
      build: () => buildBloc(save: FakeSaveService(unlimitedBoosters: true)),
      act: (bloc) => _startThen(bloc, [
        const HintPressed(),
        ..._tapMove(red1, emptyTop),
        const HintPressed(),
      ]),
      wait: const Duration(milliseconds: 40),
      verify: (bloc) {
        expect(dataOf(bloc).hint, isNotNull);
        expect(dataOf(bloc).hintsLeft, BoosterKind.hint.starterGift);
        expect(dataOf(bloc).canHint, isTrue);
      },
    );
  });

  group('soft stuck (spec §2.3)', () {
    ScriptedSolverService stuckSolver({bool hold = false}) =>
        ScriptedSolverService(
          onSoftStuck: (_) => SolveVerdict.unsolvable,
          holdSoftStuck: hold,
        );

    test('is checked 300 ms after a board change', () {
      expect(GameplayBloc.softStuckDelay, const Duration(milliseconds: 300));
    });

    blocTest<GameplayBloc, _State>(
      'is set when the solver proves the board after a move unsolvable',
      build: () => buildBloc(solver: stuckSolver()),
      act: (bloc) => _startThen(bloc, _tapMove(red1, emptyTop)),
      wait: const Duration(milliseconds: 40),
      skip: 3,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.softStuck, 'softStuck', isTrue)
              .having((d) => d.effectSeq, 'effectSeq', 3),
        ),
      ],
      verify: (bloc) => expect(scriptedSolverOf(bloc).softStuckRequests, [
        dataOf(bloc).board,
      ]),
    );

    blocTest<GameplayBloc, _State>(
      'is cleared by the next move',
      build: () {
        late final ScriptedSolverService solver;
        solver = ScriptedSolverService(
          onSoftStuck: (_) => solver.softStuckRequests.length == 1
              ? SolveVerdict.unsolvable
              : SolveVerdict.solved,
        );
        return buildBloc(solver: solver);
      },
      act: (bloc) async {
        _startThen(bloc, _tapMove(red1, emptyTop));
        await settle(const Duration(milliseconds: 40));
        expect(dataOf(bloc).softStuck, isTrue);
        _tapMove(emptyTop, red1).forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 40),
      skip: 5,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.softStuck, 'softStuck', isFalse)
              .having((d) => d.effect, 'effect', isA<MoveAppliedEffect>()),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a burst of moves asks once, for the latest board (debounced)',
      build: () => buildBloc(
        solver: ScriptedSolverService(),
        softStuckDebounce: const Duration(milliseconds: 30),
      ),
      act: (bloc) => _startThen(bloc, [
        ..._tapMove(red1, emptyTop),
        ..._tapMove(emptyTop, emptyBottom),
      ]),
      wait: const Duration(milliseconds: 80),
      verify: (bloc) => expect(scriptedSolverOf(bloc).softStuckRequests, [
        dataOf(bloc).board,
      ]),
    );

    blocTest<GameplayBloc, _State>(
      'a verdict for an older board is dropped',
      build: () => buildBloc(solver: stuckSolver(hold: true)),
      act: (bloc) async {
        _startThen(bloc, _tapMove(red1, emptyTop));
        await settle();
        final solver = scriptedSolverOf(bloc);
        expect(solver.heldSoftStuck, hasLength(1));
        _tapMove(emptyTop, red1).forEach(bloc.add);
        await settle(const Duration(milliseconds: 1));
        solver.heldSoftStuck.first.complete(SolveVerdict.unsolvable);
      },
      wait: const Duration(milliseconds: 5),
      verify: (bloc) => expect(dataOf(bloc).softStuck, isFalse),
    );

    blocTest<GameplayBloc, _State>(
      'a solved or unknown verdict shows no banner',
      build: () => buildBloc(
        solver: ScriptedSolverService(onSoftStuck: (_) => SolveVerdict.unknown),
      ),
      act: (bloc) => _startThen(bloc, _tapMove(red1, emptyTop)),
      wait: const Duration(milliseconds: 40),
      verify: (bloc) {
        expect(scriptedSolverOf(bloc).softStuckRequests, hasLength(1));
        expect(dataOf(bloc).softStuck, isFalse);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a pending hint answers instead: the check does not supersede it',
      build: () => buildBloc(
        solver: ScriptedSolverService(holdHints: true),
        softStuckDebounce: const Duration(milliseconds: 10),
      ),
      act: (bloc) =>
          _startThen(bloc, [..._tapMove(red1, emptyTop), const HintPressed()]),
      wait: const Duration(milliseconds: 40),
      verify: (bloc) {
        expect(scriptedSolverOf(bloc).hintRequests, hasLength(1));
        expect(scriptedSolverOf(bloc).softStuckRequests, isEmpty);
      },
    );
  });

  group('won', () {
    final winning = [..._tapMove(red1, red2), ..._tapMove(red2, red3)];

    blocTest<GameplayBloc, _State>(
      'pays the tier\'s Remote Config reward and advances progress',
      build: () => buildBloc(
        entries: [entryFor(tutorialLevel, tier: Tier.hard)],
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.rewardHard, 40),
      ),
      act: (bloc) => _startThen(bloc, winning),
      skip: 4,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.won)
              .having((d) => d.winReward, 'winReward', 40)
              .having((d) => d.coins, 'coins', 40)
              .having((d) => d.setsCompleted, 'setsCompleted', 1)
              .having(
                (d) => (d.effect! as MoveAppliedEffect).result.events.last,
                'last event',
                const Won(moveCount: 2),
              ),
        ),
      ],
      verify: (bloc) {
        final save = saveOf(bloc);
        expect(save.coins, 40);
        expect(save.currentLevel, 2);
      },
    );

    blocTest<GameplayBloc, _State>(
      'medium pays reward_easy',
      build: () => buildBloc(
        entries: [entryFor(tutorialLevel, tier: Tier.medium)],
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.rewardEasy, 12),
      ),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) => expect(dataOf(bloc).winReward, 12),
    );

    blocTest<GameplayBloc, _State>(
      'locks input and the boosters',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        ...winning,
        const SlotTapped(emptyTop),
        const SlotDragStarted(emptyTop),
        const UndoPressed(),
        const RestartPressed(),
        const ExtraSlotPressed(),
        const HintPressed(),
      ]),
      skip: 5,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'the winning move asks the solver nothing and cancels its work',
      build: () => buildBloc(solver: ScriptedSolverService()),
      act: (bloc) => _startThen(bloc, winning),
      wait: const Duration(milliseconds: 30),
      verify: (bloc) {
        final solver = scriptedSolverOf(bloc);
        // The first move's check was still in its debounce when the
        // winning move came, and the win cancelled it.
        expect(solver.softStuckRequests, isEmpty);
        // Once at the level start, once at the win (and once at close).
        expect(solver.cancelCount, greaterThanOrEqualTo(2));
      },
    );
  });

  group('out of moves', () {
    blocTest<GameplayBloc, _State>(
      'a move that leaves no legal move is out of moves, with no check',
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        solver: ScriptedSolverService(),
      ),
      act: (bloc) => _startThen(bloc, _tapMove('r0c0', 'r0c3')),
      wait: const Duration(milliseconds: 30),
      skip: 2,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.outOfMoves)
              .having(
                (d) => (d.effect! as MoveAppliedEffect).result.events.last,
                'last event',
                const OutOfMoves(),
              )
              .having((d) => d.canUndo, 'canUndo', isTrue),
        ),
      ],
      verify: (bloc) =>
          expect(scriptedSolverOf(bloc).softStuckRequests, isEmpty),
    );

    blocTest<GameplayBloc, _State>(
      'undo from the sheet goes back to playing',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: (bloc) =>
          _startThen(bloc, [..._tapMove('r0c0', 'r0c3'), const UndoPressed()]),
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.playing);
        expect(dataOf(bloc).board, GameState.initial(outOfMovesLevel));
      },
    );

    blocTest<GameplayBloc, _State>(
      'hint does nothing',
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        solver: ScriptedSolverService(),
      ),
      act: (bloc) =>
          _startThen(bloc, [..._tapMove('r0c0', 'r0c3'), const HintPressed()]),
      verify: (bloc) => expect(scriptedSolverOf(bloc).hintRequests, isEmpty),
    );
  });

  group('next level', () {
    final winning = [..._tapMove(red1, red2), ..._tapMove(red2, red3)];
    final second = entryFor(outOfMovesLevel, order: 2);

    blocTest<GameplayBloc, _State>(
      'loads the following level, with the sequences still counting',
      build: () => buildBloc(entries: [entry, second]),
      act: (bloc) => _startThen(bloc, [...winning, const NextLevelPressed()]),
      skip: 5,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.entry, 'entry', second)
              .having((d) => d.status, 'status', GameplayStatus.playing)
              .having((d) => d.winReward, 'winReward', 0)
              .having((d) => d.coins, 'coins', 10)
              .having((d) => d.freeUndosLeft, 'freeUndosLeft', 2)
              .having((d) => d.moveSeq, 'moveSeq', 3)
              .having((d) => d.effectSeq, 'effectSeq', 6)
              .having(
                (d) => d.effect,
                'effect',
                BoardResetEffect(
                  snapshot: GameState.initial(outOfMovesLevel),
                  reason: BoardResetReason.start,
                ),
              ),
        ),
      ],
      verify: (bloc) => expect(bloc.session!.level, outOfMovesLevel),
    );

    blocTest<GameplayBloc, _State>(
      'past the last level shows All Levels Done',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [...winning, const NextLevelPressed()]),
      skip: 5,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.allLevelsDone)
              .having((d) => d.entry, 'entry', entry)
              .having((d) => d.effectSeq, 'effectSeq', 5),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'does nothing before the win',
      build: () => buildBloc(entries: [entry, second]),
      act: (bloc) => _startThen(bloc, [const NextLevelPressed()]),
      skip: 1,
      expect: () => const <_State>[],
    );
  });

  group('pause', () {
    blocTest<GameplayBloc, _State>(
      'locks board input and boosters until resumed',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [
        const PauseChanged(paused: true),
        const SlotTapped(red1),
        const ExtraSlotPressed(),
        const HintPressed(),
        const PauseChanged(paused: false),
        const SlotTapped(red1),
      ]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.paused, 'paused', isTrue)
              .having((d) => d.effectSeq, 'effectSeq', 1),
        ),
        dataWhere(
          isA<GameplayState>().having((d) => d.paused, 'paused', isFalse),
        ),
        effectIs(const SelectionChangedEffect(selected: red1)),
      ],
    );
  });

  group('analytics (spec §14.4)', () {
    late _MockAnalytics analytics;

    setUpAll(() => registerFallbackValue(<String, Object>{}));

    setUp(() {
      analytics = _MockAnalytics();
      when(
        () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
    });

    blocTest<GameplayBloc, _State>(
      'logs the level start, restart and win',
      build: () => buildBloc(analytics: analytics),
      act: (bloc) => _startThen(bloc, [
        ..._tapMove(red1, emptyTop),
        const UndoPressed(),
        const RestartPressed(),
        ..._tapMove(red1, red2),
        ..._tapMove(red2, red3),
      ]),
      verify: (_) {
        verify(
          () => analytics.logEvent(
            'level_start',
            parameters: {'level': 1, 'tier': 'easy', 'attempt': 1},
          ),
        ).called(1);
        verify(
          () => analytics.logEvent(
            'booster_use',
            parameters: {'type': 'undo', 'source': 'free'},
          ),
        ).called(1);
        verify(
          () => analytics.logEvent('level_restart', parameters: {'level': 1}),
        ).called(1);
        verify(
          () => analytics.logEvent(
            'level_start',
            parameters: {'level': 1, 'tier': 'easy', 'attempt': 2},
          ),
        ).called(1);
        final win = verify(
          () => analytics.logEvent(
            'level_win',
            parameters: captureAny(named: 'parameters'),
          ),
        )..called(1);
        final parameters = win.captured.single as Map<String, Object>;
        expect(parameters, containsPair('level', 1));
        expect(parameters, containsPair('tier', 'easy'));
        expect(parameters, containsPair('moves', 2));
        expect(parameters, containsPair('undos', 1));
        expect(parameters, containsPair('hints', 0));
        expect(parameters, containsPair('slots', 0));
        expect(parameters['seconds'], isA<int>());
      },
    );

    blocTest<GameplayBloc, _State>(
      'logs out of moves and soft stuck',
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        analytics: analytics,
        solver: ScriptedSolverService(
          onSoftStuck: (_) => SolveVerdict.unsolvable,
        ),
      ),
      act: (bloc) async {
        _startThen(bloc, [..._tapMove('r0c1', 'r0c3')]);
        await settle(const Duration(milliseconds: 30));
        bloc
          ..add(const UndoPressed())
          ..add(const SlotTapped('r0c0'))
          ..add(const SlotTapped('r0c3'));
      },
      wait: const Duration(milliseconds: 20),
      verify: (_) {
        verify(
          () =>
              analytics.logEvent('level_soft_stuck', parameters: {'level': 1}),
        ).called(greaterThanOrEqualTo(1));
        verify(
          () => analytics.logEvent(
            'level_out_of_moves',
            parameters: {'level': 1},
          ),
        ).called(1);
      },
    );
  });
}
