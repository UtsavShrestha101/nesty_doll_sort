import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';

import '../../../helpers/level_fixtures.dart';
import 'support/bloc_fixtures.dart';
import 'support/scripted_level_resolver.dart';
import 'support/scripted_solver_service.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

/// A [FakeDailyService] whose [progressAfterSolve] always relights a
/// paused streak that already had days (`DailyProgress.relitOn`), so a
/// `dailyRelit` test never depends on the real gentle-streak algorithm
/// (`StreakDailyService`, the meta-services lane's).
final class _RelitDaily extends FakeDailyService {
  _RelitDaily(super.clock);

  @override
  DailyProgress progressAfterSolve(LocalDate date) =>
      DailyProgress(streak: 5, run: 1, lastDate: date, done: [date]);
}

/// A [FakeSaveService] that keeps every in-progress board it was asked to
/// save, oldest first (review CORRECTNESS-1).
class _RecordingSaveService extends FakeSaveService {
  final List<InProgressLevel> saved = [];

  @override
  void saveInProgress(InProgressLevel level) {
    saved.add(level);
    super.saveInProgress(level);
  }
}

typedef _State = AsyncValue<GameplayState>;

/// Adds [GameplayStarted] for level 1, then [events] in order.
void _startThen(GameplayBloc bloc, [List<GameplayEvent> events = const []]) {
  bloc.add(const GameplayStarted(PlayRequest.campaign(1)));
  events.forEach(bloc.add);
}

/// Taps [from] then [to] (tap-tap move).
List<GameplayEvent> _tapMove(String from, String to) => [
  SlotTapped(from),
  SlotTapped(to),
];

void main() {
  final start = GameState.initial(defaultLevel);
  final entry = entryFor(defaultLevel);

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
              .having((d) => d.restored, 'restored', isFalse)
              .having((d) => d.tutorial, 'tutorial', isNull)
              .having((d) => d.intro, 'intro', isNull)
              .having(
                (d) => d.undoPrice,
                'undoPrice',
                RemoteConfigKeys.priceUndo.defaultValue,
              )
              .having(
                (d) => d.hintPrice,
                'hintPrice',
                RemoteConfigKeys.priceHint.defaultValue,
              )
              .having(
                (d) => d.slotPrice,
                'slotPrice',
                RemoteConfigKeys.priceSlot.defaultValue,
              )
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
      verify: (bloc) => expect(bloc.session?.level, defaultLevel),
    );

    blocTest<GameplayBloc, _State>(
      'a level past the bundle is missing content',
      build: buildBloc,
      act: (bloc) => bloc.add(const GameplayStarted(PlayRequest.campaign(2))),
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

  group('generated start (m3-design §6.4)', () {
    blocTest<GameplayBloc, _State>(
      'a generated request shows loading, then the resolved board',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              outOfMovesLevel,
              rewardCoins: 25,
            ),
          },
        ),
      ),
      act: (bloc) => bloc.add(const GameplayStarted(PlayRequest.bonus(1))),
      expect: () => [
        isA<AsyncValueLoading<GameplayState>>().having(
          (s) => s.data,
          'data',
          isNull,
        ),
        dataWhere(
          isA<GameplayState>()
              .having(
                (d) => d.play.request,
                'request',
                const PlayRequest.bonus(1),
              )
              .having(
                (d) => d.board,
                'board',
                GameState.initial(outOfMovesLevel),
              ),
        ),
      ],
    );

    blocTest<GameplayBloc, _State>(
      'a bundled (campaign) request never shows loading first',
      build: buildBloc,
      act: _startThen,
      expect: () => [isA<AsyncValueData<GameplayState>>()],
    );

    blocTest<GameplayBloc, _State>(
      'null (nothing to play) still shows loading first for a generated '
      'request, then the content error',
      build: () => buildBloc(resolver: ScriptedLevelResolver()),
      act: (bloc) => bloc.add(const GameplayStarted(PlayRequest.bonus(1))),
      expect: () => [
        isA<AsyncValueLoading<GameplayState>>(),
        isA<AsyncValueError<GameplayState>>().having(
          (s) => s.exception.kind,
          'kind',
          AppExceptionKind.content,
        ),
      ],
    );
  });

  group('restore (m3-design §3.4)', () {
    InProgressLevel savedProgress(
      GameSession session, {
      PlayRequest request = const PlayRequest.campaign(1),
      String? levelId,
      int levelVersion = 1,
    }) => InProgressLevel(
      request: request,
      levelId: levelId ?? defaultLevel.id,
      levelVersion: levelVersion,
      session: GameSessionCodec.encode(session),
    );

    blocTest<GameplayBloc, _State>(
      'resumes a saved board that matches the request, level id and version',
      build: () {
        final save = FakeSaveService();
        final progressed = GameSession(defaultLevel)..move(red1, emptyTop);
        save.saveInProgress(savedProgress(progressed));
        return buildBloc(save: save);
      },
      act: _startThen,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.restored, 'restored', isTrue)
              .having((d) => d.board.moveCount, 'moveCount', 1)
              .having((d) => d.board.slot(emptyTop).isEmpty, 'moved', isFalse)
              .having(
                (d) => d.effect,
                'effect',
                isA<BoardResetEffect>().having(
                  (e) => e.reason,
                  'reason',
                  BoardResetReason.start,
                ),
              ),
        ),
      ],
      verify: (bloc) {
        expect(bloc.session!.undosUsed, 0);
        expect(saveOf(bloc).inProgressFor(PlayKind.campaign), isNotNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      "starts fresh and clears the slot when the level id doesn't match",
      build: () {
        final save = FakeSaveService();
        final progressed = GameSession(defaultLevel)..move(red1, emptyTop);
        save.saveInProgress(savedProgress(progressed, levelId: 'T9999'));
        return buildBloc(save: save);
      },
      act: _startThen,
      verify: (bloc) {
        expect(dataOf(bloc).restored, isFalse);
        expect(dataOf(bloc).board, start);
        expect(saveOf(bloc).inProgressFor(PlayKind.campaign), isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'starts fresh when the saved session fails to decode',
      build: () {
        final save = FakeSaveService();
        save.saveInProgress(
          InProgressLevel(
            request: const PlayRequest.campaign(1),
            levelId: defaultLevel.id,
            levelVersion: 1,
            session: const {'bad': true},
          ),
        );
        return buildBloc(save: save);
      },
      act: _startThen,
      verify: (bloc) {
        expect(dataOf(bloc).restored, isFalse);
        expect(dataOf(bloc).board, start);
        expect(saveOf(bloc).inProgressFor(PlayKind.campaign), isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      "starts fresh when the level version doesn't match",
      build: () {
        final save = FakeSaveService();
        save.saveInProgress(
          savedProgress(GameSession(defaultLevel), levelVersion: 2),
        );
        return buildBloc(save: save);
      },
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).restored, isFalse),
    );

    blocTest<GameplayBloc, _State>(
      'saves after every applied move, undo, restart and +1 Slot, never for '
      'a rejected move',
      build: () => buildBloc(save: CountingSaveService()),
      act: (bloc) => _startThen(bloc, [
        ..._tapMove(red3, red1), // rejected: size mismatch
        ..._tapMove(red1, red2), // applied: 1 save
        const UndoPressed(), // applied: 1 save
        const RestartPressed(), // applied: 1 save
        const ExtraSlotPressed(), // applied: 1 save
      ]),
      verify: (bloc) =>
          expect((saveOf(bloc) as CountingSaveService).saveInProgressCalls, 4),
    );

    // Review CORRECTNESS-1: the status is core's, at restore as after a
    // move, so a board saved out of moves (the sheet was up when the app
    // was killed) comes back out of moves, and its sheet can open again.
    blocTest<GameplayBloc, _State>(
      'a restored out-of-moves board comes back out of moves, with the '
      "sheet's undo working",
      build: () {
        final save = saveWithIntrosSeen();
        final stuck = GameSession(outOfMovesLevel)..move('r0c0', 'r0c3');
        expect(stuck.isOutOfMoves, isTrue);
        save.saveInProgress(savedProgress(stuck, levelId: outOfMovesLevel.id));
        return buildBloc(
          entries: [entryFor(outOfMovesLevel)],
          solver: ScriptedSolverService(),
          save: save,
        );
      },
      act: (bloc) async {
        _startThen(bloc);
        await settle(const Duration(milliseconds: 30));
        expect(dataOf(bloc).status, GameplayStatus.outOfMoves);
        expect(dataOf(bloc).restored, isTrue);
        expect(dataOf(bloc).canUndo, isTrue);
        // Out of moves asks the solver nothing (as after the move itself).
        expect(scriptedSolverOf(bloc).softStuckRequests, isEmpty);
        bloc.add(const UndoPressed());
      },
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.playing);
        expect(dataOf(bloc).board, GameState.initial(outOfMovesLevel));
      },
    );

    blocTest<GameplayBloc, _State>(
      'a restored won board (killed before its win was recorded) records '
      'the win and pays once',
      build: () {
        final save = FakeSaveService();
        final won = GameSession(defaultLevel)
          ..move(red1, red2)
          ..move(red2, red3);
        expect(won.isWon, isTrue);
        save.saveInProgress(savedProgress(won));
        return buildBloc(
          entries: [entry, entryFor(outOfMovesLevel, order: 2)],
          save: save,
        );
      },
      act: _startThen,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.won)
              .having((d) => d.restored, 'restored', isTrue)
              .having(
                (d) => d.winReward,
                'winReward',
                RemoteConfigKeys.rewardEasy.defaultValue,
              )
              .having(
                (d) => d.nextRequest,
                'nextRequest',
                const PlayRequest.campaign(2),
              )
              .having((d) => d.intro, 'intro', isNull),
        ),
      ],
      verify: (bloc) {
        final save = saveOf(bloc);
        expect(save.coins, RemoteConfigKeys.rewardEasy.defaultValue);
        expect(save.currentLevel, 2);
        expect(save.inProgressFor(PlayKind.campaign), isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a restored board still in play gets its soft-stuck check',
      build: () {
        final save = FakeSaveService();
        final progressed = GameSession(defaultLevel)..move(red1, emptyTop);
        save.saveInProgress(savedProgress(progressed));
        return buildBloc(
          save: save,
          solver: ScriptedSolverService(
            onSoftStuck: (_) => SolveVerdict.unsolvable,
          ),
        );
      },
      act: _startThen,
      wait: const Duration(milliseconds: 40),
      verify: (bloc) {
        expect(scriptedSolverOf(bloc).softStuckRequests, [dataOf(bloc).board]);
        expect(dataOf(bloc).softStuck, isTrue);
      },
    );

    blocTest<GameplayBloc, _State>(
      'the winning move is never saved as the in-progress board',
      build: () => buildBloc(save: _RecordingSaveService()),
      act: (bloc) =>
          _startThen(bloc, [..._tapMove(red1, red2), ..._tapMove(red2, red3)]),
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.won);
        final saved = (saveOf(bloc) as _RecordingSaveService).saved;
        expect(saved, hasLength(1), reason: 'only the first move');
        for (final level in saved) {
          final decoded = GameSessionCodec.decode(level.session, defaultLevel);
          expect(decoded.session!.isWon, isFalse);
        }
      },
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
      'with nothing selected, a tap on an empty slot nudges it and moves '
      'nothing (E.13, Q39)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, [const SlotTapped(emptyTop)]),
      skip: 1,
      expect: () => [
        effectIs(const SlotNudgeEffect(emptyTop, SlotNudgeKind.emptyStand)),
      ],
      verify: (bloc) {
        expect(dataOf(bloc).moveSeq, 0);
        expect(dataOf(bloc).selectedSlotId, isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'with nothing selected, a tap on an iced nest bumps its ice (E.13)',
      build: () =>
          buildBloc(entries: [entryFor(icedLevel)], save: saveWithIntrosSeen()),
      act: (bloc) => _startThen(bloc, [const SlotTapped(red2)]),
      skip: 1,
      expect: () => [effectIs(const SlotNudgeEffect(red2, SlotNudgeKind.iced))],
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
      "a tap on an iced target is invalid with core's reason",
      build: () =>
          buildBloc(entries: [entryFor(icedLevel)], save: saveWithIntrosSeen()),
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
      'a drag from an unpickable slot does nothing, and neither does its '
      'drop',
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
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        save: saveWithIntrosSeen(),
      ),
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
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        save: saveWithIntrosSeen(),
      ),
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
      "shows the solver's move and uses one hint",
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
      // The tap clears the hint first, then nudges the empty stand (E.13).
      expect: () => [
        effectIs(const HintClearedEffect()),
        effectIs(const SlotNudgeEffect(emptyTop, SlotNudgeKind.emptyStand)),
      ],
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
      "a failed search falls back to core's fallback hint",
      build: () =>
          buildBloc(solver: ScriptedSolverService(onHint: (_) => null)),
      act: (bloc) => _startThen(bloc, [const HintPressed()]),
      wait: const Duration(milliseconds: 20),
      skip: 1,
      expect: () => [effectIs(HintShownEffect(Solver.fallbackHint(start)!))],
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

  group('coin boosters (m3-design §7.3)', () {
    group('undo', () {
      List<GameplayEvent> exhaustFreeUndos() => [
        for (var i = 0; i < 2; i++) ...[
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
        ],
        ..._tapMove(red1, emptyTop),
      ];

      blocTest<GameplayBloc, _State>(
        'shows the coin offer once the free undos run out',
        build: buildBloc,
        act: (bloc) =>
            _startThen(bloc, [...exhaustFreeUndos(), const UndoPressed()]),
        verify: (bloc) {
          final data = dataOf(bloc);
          expect(data.freeUndosLeft, 0);
          expect(data.canUndo, isTrue);
          expect(
            data.offer,
            const BoosterOffer(
              type: BoosterType.undo,
              price: 20, // RemoteConfigKeys.priceUndo's default
            ),
          );
          expect(data.board.slot(emptyTop).isEmpty, isFalse);
        },
      );

      blocTest<GameplayBloc, _State>(
        'confirming spends the coins and undoes',
        build: () {
          final save = FakeSaveService()..addCoins(100);
          return buildBloc(save: save);
        },
        act: (bloc) => _startThen(bloc, [
          ...exhaustFreeUndos(),
          const UndoPressed(),
          const BoosterPurchaseConfirmed(BoosterType.undo),
        ]),
        verify: (bloc) {
          final data = dataOf(bloc);
          expect(data.offer, isNull);
          expect(data.board, start);
          expect(saveOf(bloc).coins, 80);
        },
      );

      blocTest<GameplayBloc, _State>(
        'unaffordable: confirming changes nothing',
        build: buildBloc,
        act: (bloc) => _startThen(bloc, [
          ...exhaustFreeUndos(),
          const UndoPressed(),
          const BoosterPurchaseConfirmed(BoosterType.undo),
        ]),
        verify: (bloc) {
          final data = dataOf(bloc);
          expect(data.offer, isNotNull);
          expect(data.board.slot(emptyTop).isEmpty, isFalse);
          expect(saveOf(bloc).coins, 0);
        },
      );

      // Review CORRECTNESS-7: a second confirm (a double-fired Buy, a
      // repeated accessibility action) reaches the bloc after the first
      // closed the offer. It must charge nothing, and the HUD's balance
      // must match the save.
      blocTest<GameplayBloc, _State>(
        'a second confirm after the offer closed charges nothing',
        build: () {
          final config = FakeRemoteConfigService()
            ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 0);
          return buildBloc(
            config: config,
            save: FakeSaveService(
              remoteConfig: config,
              initial: const SaveDocument(coins: 1000),
            ),
          );
        },
        act: (bloc) => _startThen(bloc, [
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
          const BoosterPurchaseConfirmed(BoosterType.undo),
          const BoosterPurchaseConfirmed(BoosterType.undo),
        ]),
        verify: (bloc) {
          final price = RemoteConfigKeys.priceUndo.defaultValue;
          expect(dataOf(bloc).board, start);
          expect(saveOf(bloc).coins, 1000 - price);
          expect(dataOf(bloc).coins, saveOf(bloc).coins);
        },
      );

      blocTest<GameplayBloc, _State>(
        'a confirm with no offer up, or for another booster, does nothing',
        build: () => buildBloc(
          save: FakeSaveService(initial: const SaveDocument(coins: 1000)),
        ),
        act: (bloc) => _startThen(bloc, [
          ..._tapMove(red1, emptyTop),
          const BoosterPurchaseConfirmed(BoosterType.undo),
          const BoosterPurchaseConfirmed(BoosterType.slot),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).board.moveCount, 1);
          expect(dataOf(bloc).board.extraSlotCount, 0);
          expect(saveOf(bloc).coins, 1000);
        },
      );

      blocTest<GameplayBloc, _State>(
        'a confirm for another type than the offer does nothing',
        build: () {
          final config = FakeRemoteConfigService()
            ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 0);
          return buildBloc(
            config: config,
            save: FakeSaveService(
              remoteConfig: config,
              initial: const SaveDocument(coins: 1000),
            ),
          );
        },
        act: (bloc) => _startThen(bloc, [
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
          const BoosterPurchaseConfirmed(BoosterType.slot),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).offer?.type, BoosterType.undo);
          expect(dataOf(bloc).board.extraSlotCount, 0);
          expect(saveOf(bloc).coins, 1000);
        },
      );

      blocTest<GameplayBloc, _State>(
        'dismissing clears the offer',
        build: buildBloc,
        act: (bloc) => _startThen(bloc, [
          ...exhaustFreeUndos(),
          const UndoPressed(),
          const BoosterPurchaseDismissed(),
        ]),
        verify: (bloc) => expect(dataOf(bloc).offer, isNull),
      );

      blocTest<GameplayBloc, _State>(
        'board input and the other boosters are ignored while it is up',
        build: buildBloc,
        act: (bloc) => _startThen(bloc, [
          ...exhaustFreeUndos(),
          const UndoPressed(),
          const SlotTapped(red2),
          const HintPressed(),
          const ExtraSlotPressed(),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).selectedSlotId, isNull);
          expect(dataOf(bloc).hint, isNull);
          expect(dataOf(bloc).board.extraSlotCount, 0);
        },
      );
    });

    group('extra slot', () {
      blocTest<GameplayBloc, _State>(
        'shows the coin offer once the inventory runs out',
        build: () => buildBloc(save: saveWith(extraSlots: 0)),
        act: (bloc) => _startThen(bloc, [const ExtraSlotPressed()]),
        verify: (bloc) {
          expect(
            dataOf(bloc).offer,
            const BoosterOffer(type: BoosterType.slot, price: 150),
          );
          expect(dataOf(bloc).board.extraSlotCount, 0);
        },
      );

      blocTest<GameplayBloc, _State>(
        'confirming spends the coins and adds the slot',
        build: () {
          final save = saveWith(extraSlots: 0)..addCoins(200);
          return buildBloc(save: save);
        },
        act: (bloc) => _startThen(bloc, [
          const ExtraSlotPressed(),
          const BoosterPurchaseConfirmed(BoosterType.slot),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).offer, isNull);
          expect(dataOf(bloc).board.extraSlotCount, 1);
          expect(saveOf(bloc).coins, 50);
        },
      );

      blocTest<GameplayBloc, _State>(
        'unaffordable: confirming changes nothing',
        build: () => buildBloc(save: saveWith(extraSlots: 0)),
        act: (bloc) => _startThen(bloc, [
          const ExtraSlotPressed(),
          const BoosterPurchaseConfirmed(BoosterType.slot),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).offer, isNotNull);
          expect(dataOf(bloc).board.extraSlotCount, 0);
        },
      );
    });

    group('hint', () {
      blocTest<GameplayBloc, _State>(
        'shows the coin offer once the inventory runs out, asking nothing',
        build: () => buildBloc(
          save: saveWith(hints: 0),
          solver: ScriptedSolverService(),
        ),
        act: (bloc) => _startThen(bloc, [const HintPressed()]),
        verify: (bloc) {
          expect(
            dataOf(bloc).offer,
            const BoosterOffer(type: BoosterType.hint, price: 60),
          );
          expect(scriptedSolverOf(bloc).hintRequests, isEmpty);
        },
      );

      blocTest<GameplayBloc, _State>(
        'confirming closes the offer and asks the solver, charging on '
        'arrival',
        build: () {
          final save = saveWith(hints: 0)..addCoins(200);
          return buildBloc(save: save);
        },
        act: (bloc) => _startThen(bloc, [
          const HintPressed(),
          const BoosterPurchaseConfirmed(BoosterType.hint),
        ]),
        wait: const Duration(milliseconds: 20),
        verify: (bloc) {
          expect(dataOf(bloc).offer, isNull);
          expect(dataOf(bloc).hint, isNotNull);
          expect(saveOf(bloc).coins, 140);
        },
      );

      blocTest<GameplayBloc, _State>(
        'a proven dead end charges nothing (D22)',
        build: () {
          final save = saveWith(hints: 0)..addCoins(200);
          return buildBloc(
            save: save,
            solver: ScriptedSolverService(
              onHint: (_) => const HintResult(
                source: HintSource.none,
                verdict: SolveVerdict.unsolvable,
                nodes: 12,
              ),
            ),
          );
        },
        act: (bloc) => _startThen(bloc, [
          const HintPressed(),
          const BoosterPurchaseConfirmed(BoosterType.hint),
        ]),
        wait: const Duration(milliseconds: 20),
        verify: (bloc) {
          expect(dataOf(bloc).softStuck, isTrue);
          expect(dataOf(bloc).hint, isNull);
          expect(saveOf(bloc).coins, 200);
        },
      );

      blocTest<GameplayBloc, _State>(
        'unaffordable: confirming changes nothing and asks nothing',
        build: () => buildBloc(
          save: saveWith(hints: 0),
          solver: ScriptedSolverService(),
        ),
        act: (bloc) => _startThen(bloc, [
          const HintPressed(),
          const BoosterPurchaseConfirmed(BoosterType.hint),
        ]),
        verify: (bloc) {
          expect(dataOf(bloc).offer, isNotNull);
          expect(scriptedSolverOf(bloc).hintRequests, isEmpty);
        },
      );
    });
  });

  group('relaxed mode (m7-design §10)', () {
    List<GameplayEvent> undoCycles(int count) => [
      for (var i = 0; i < count; i++) ...[
        ..._tapMove(red1, emptyTop),
        const UndoPressed(),
      ],
    ];

    blocTest<GameplayBloc, _State>(
      'undo is free and unlimited, never an offer or a spend, past the '
      'usual free-undo limit',
      build: () =>
          buildBloc(settings: FakeDatabaseService()..setRelaxedMode(true)),
      act: (bloc) => _startThen(bloc, undoCycles(5)),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.relaxed, isTrue);
        expect(data.offer, isNull);
        expect(data.board, start);
        expect(saveOf(bloc).coins, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'the free-undo budget keeps counting while relaxed, with nothing '
      'shown for it',
      build: () =>
          buildBloc(settings: FakeDatabaseService()..setRelaxedMode(true)),
      act: (bloc) => _startThen(bloc, undoCycles(3)),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.freeUndosLeft, 0, reason: 'the 2 free undos were spent');
        expect(data.offer, isNull, reason: 'relaxed never shows the count');
        expect(saveOf(bloc).coins, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a toggle made mid-level (Pause -> Settings) applies to the level '
      'in play: it closes a pending undo offer, and undo turns free '
      '(read live, D104)',
      build: buildBloc,
      act: (bloc) {
        _startThen(bloc, [...undoCycles(2), ..._tapMove(red1, emptyTop)]);
        bloc
          ..add(const UndoPressed()) // 0 free undos left: the coin offer
          ..add(const RelaxedModeChanged(relaxed: true))
          ..add(const UndoPressed());
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.relaxed, isTrue);
        expect(data.offer, isNull);
        expect(data.board, start, reason: 'the pending move was undone free');
        expect(saveOf(bloc).coins, 0, reason: 'never spent');
      },
    );

    blocTest<GameplayBloc, _State>(
      'toggling relaxed off mid-level restores the normal coin offer once '
      'the free undos are gone',
      build: () =>
          buildBloc(settings: FakeDatabaseService()..setRelaxedMode(true)),
      act: (bloc) {
        _startThen(bloc, [...undoCycles(2), ..._tapMove(red1, emptyTop)]);
        bloc
          ..add(const RelaxedModeChanged(relaxed: false))
          ..add(const UndoPressed());
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.relaxed, isFalse);
        expect(
          data.offer,
          const BoosterOffer(type: BoosterType.undo, price: 20),
        );
      },
    );

    blocTest<GameplayBloc, _State>(
      'hint and +1 Slot are unchanged: still gated by the inventory',
      build: () => buildBloc(
        settings: FakeDatabaseService()..setRelaxedMode(true),
        save: saveWith(hints: 0, extraSlots: 0),
        solver: ScriptedSolverService(),
      ),
      act: (bloc) =>
          _startThen(bloc, [const HintPressed(), const ExtraSlotPressed()]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.offer?.type, BoosterType.hint, reason: 'asked first');
        expect(scriptedSolverOf(bloc).hintRequests, isEmpty);
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
      "pays the tier's Remote Config reward and advances progress",
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, tier: Tier.hard)],
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
      'medium pays reward_medium (Q5, D64)',
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, tier: Tier.medium)],
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.rewardEasy, 7)
          ..setOverride(RemoteConfigKeys.rewardMedium, 12),
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

    blocTest<GameplayBloc, _State>(
      'a win clears the in-progress board in the same update (m3-design §3.5)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) =>
          expect(saveOf(bloc).inProgressFor(PlayKind.campaign), isNull),
    );

    blocTest<GameplayBloc, _State>(
      'a campaign win that completes its chapter pays the chapter reward '
      'once and adds the museum date (m3-design §9.3)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.campaign(1): playEntryFor(
              const PlayRequest.campaign(1),
              defaultLevel,
              chapterId: 'ch01',
              completesChapter: true,
              rewardCoins: 10,
            ),
          },
          nextOf: (_) => const PlayRequest.campaign(2),
        ),
      ),
      act: (bloc) => _startThen(bloc, winning),
      skip: 4,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.won)
              .having((d) => d.completedChapterId, 'completedChapterId', 'ch01')
              .having((d) => d.chapterReward, 'chapterReward', 150)
              .having(
                (d) => d.nextRequest,
                'nextRequest',
                const PlayRequest.campaign(2),
              ),
        ),
      ],
      verify: (bloc) {
        final save = saveOf(bloc);
        expect(save.coins, 10 + 150);
        expect(save.document.museum, ['ch01']);
        expect(save.document.museumCollected['ch01'], isNotNull);
        expect(save.inProgressFor(PlayKind.campaign), isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a chapter already in the museum is not paid again',
      build: () => buildBloc(
        save: FakeSaveService(initial: const SaveDocument(museum: ['ch01'])),
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.campaign(1): playEntryFor(
              const PlayRequest.campaign(1),
              defaultLevel,
              chapterId: 'ch01',
              completesChapter: true,
            ),
          },
        ),
      ),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        expect(dataOf(bloc).completedChapterId, isNull);
        expect(dataOf(bloc).chapterReward, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a bonus win prefetches the next bonus level (m3-design §7.4)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              defaultLevel,
            ),
          },
          nextOf: (_) => const PlayRequest.bonus(2),
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.bonus(1)));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final resolver = resolverOf(bloc) as ScriptedLevelResolver;
        expect(resolver.prefetched, [const PlayRequest.bonus(2)]);
        expect(dataOf(bloc).nextRequest, const PlayRequest.bonus(2));
      },
    );

    blocTest<GameplayBloc, _State>(
      'a daily win pays daily_reward with no ×3 and carries the new streak',
      build: () {
        final clock = FakeClock();
        return buildBloc(
          resolver: ScriptedLevelResolver(
            entries: {
              const PlayRequest.daily(20260926): playEntryFor(
                const PlayRequest.daily(20260926),
                defaultLevel,
                rewardCoins: 50,
              ),
            },
          ),
          daily: FakeDailyService(clock),
          clock: clock,
        );
      },
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.daily(20260926)));
        winning.forEach(bloc.add);
      },
      // One more than the campaign `winning` tests: a daily request is
      // generated, so `_dispatchStart` emits `AsyncValue.loading` first
      // (m3-design §6.4 item 1) before the resolved board.
      skip: 5,
      expect: () => [
        dataWhere(
          isA<GameplayState>()
              .having((d) => d.status, 'status', GameplayStatus.won)
              .having((d) => d.winReward, 'winReward', 50)
              .having((d) => d.dailyStreak, 'dailyStreak', 1)
              .having((d) => d.nextRequest, 'nextRequest', isNull),
        ),
      ],
      verify: (bloc) {
        final save = saveOf(bloc);
        expect(save.coins, 50);
        expect(save.document.daily.streak, 1);
        expect(save.document.daily.inProgress, isNull);
      },
    );

    // M7 review R6: only today's date counts toward the streak (m3-design
    // §8.2, D76, Q70). Thursday's daily, started at 23:55 on a run of 3 and
    // won at 00:03 on Friday, pays its coins and adds to `done` only.
    late FakeClock midnightClock;
    blocTest<GameplayBloc, _State>(
      'a daily won after midnight pays but neither extends nor relights '
      'the streak',
      build: () {
        var run = const DailyProgress();
        for (final day in [21, 22, 23]) {
          run = StreakDailyService.solveForTest(run, LocalDate(2026, 9, day));
        }
        final clock = midnightClock = FakeClock(
          now: DateTime(2026, 9, 24, 23, 55),
        );
        final config = FakeRemoteConfigService();
        final save = FakeSaveService(
          initial: SaveDocument(currentLevel: 5, highestLevel: 5, daily: run),
          remoteConfig: config,
        );
        return buildBloc(
          resolver: ScriptedLevelResolver(
            entries: {
              const PlayRequest.daily(20260924): playEntryFor(
                const PlayRequest.daily(20260924),
                defaultLevel,
                rewardCoins: 50,
              ),
            },
          ),
          config: config,
          save: save,
          daily: StreakDailyService(save, clock, config),
          clock: clock,
        );
      },
      act: (bloc) async {
        bloc.add(const GameplayStarted(PlayRequest.daily(20260924)));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        midnightClock.set(DateTime(2026, 9, 25, 0, 3));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.status, GameplayStatus.won);
        expect(data.winReward, 50);
        expect(data.dailyStreak, 3);
        expect(data.dailyRelit, isFalse);
        final daily = saveOf(bloc).document.daily;
        expect(saveOf(bloc).coins, 50);
        expect(daily.streak, 3);
        expect(daily.run, 3);
        expect(daily.lastDate, LocalDate(2026, 9, 23));
        expect(daily.done, contains(LocalDate(2026, 9, 24)));
        expect(daily.inProgress, isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a daily win that relit a paused streak sets dailyRelit '
      '(m7-design §8)',
      build: () {
        final clock = FakeClock();
        return buildBloc(
          resolver: ScriptedLevelResolver(
            entries: {
              const PlayRequest.daily(20260926): playEntryFor(
                const PlayRequest.daily(20260926),
                defaultLevel,
              ),
            },
          ),
          daily: _RelitDaily(clock),
          clock: clock,
        );
      },
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.daily(20260926)));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) => expect(dataOf(bloc).dailyRelit, isTrue),
    );

    blocTest<GameplayBloc, _State>(
      'records the moves and the level\'s first best (m7-design §11)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 2);
        expect(data.bestMoves, 2);
        expect(data.previousBest, isNull);
        expect(
          saveOf(bloc).bestMovesFor(LevelBests.key(defaultLevel.id, 1)),
          2,
        );
      },
    );

    blocTest<GameplayBloc, _State>(
      "keeps the lower of the level's previous best and this win's moves "
      '(m7-design §11)',
      build: () => buildBloc(
        save: FakeSaveService(
          initial: SaveDocument(
            levelBests: {LevelBests.key(defaultLevel.id, 1): 1},
          ),
        ),
      ),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 2);
        expect(data.bestMoves, 1, reason: 'the old best of 1 stands');
        expect(data.previousBest, 1);
      },
    );

    blocTest<GameplayBloc, _State>(
      "opens the chapter's milestone chest at level 10; from here on the "
      'figurine is the nearer goal (m7-design §9)',
      build: () => buildBloc(entries: [entryFor(defaultLevel, order: 10)]),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.campaign(10)));
        winning.forEach(bloc.add);
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(
          data.chest,
          const ChestGrant(
            source: ChestSource.campaign,
            number: 10,
            coins: 100,
            hints: 1,
          ),
        );
        expect(data.chestLevelsLeft, isNull);
        expect(saveOf(bloc).document.chests.opened, [10]);
      },
    );

    blocTest<GameplayBloc, _State>(
      "a bonus win's chest counts down to the next one, 10 right after "
      'this one (m7-design §9)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(10): playEntryFor(
              const PlayRequest.bonus(10),
              defaultLevel,
            ),
          },
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.bonus(10)));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(
          data.chest,
          const ChestGrant(
            source: ChestSource.bonus,
            number: 10,
            coins: 100,
            hints: 1,
          ),
        );
        expect(data.chestLevelsLeft, 10);
      },
    );

    blocTest<GameplayBloc, _State>(
      "adds the won board's records and reports the outcome's new badges "
      '(m7-design §12)',
      build: buildBloc,
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        expect(saveOf(bloc).document.records.families, 1);
        expect(saveOf(bloc).document.records.dolls, 2);
        expect(dataOf(bloc).newBadges, contains(BadgeId.firstFamily));
      },
    );

    blocTest<GameplayBloc, _State>(
      "the player's first win ever sets firstWin (E9, m7-design §13)",
      build: buildBloc,
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) => expect(dataOf(bloc).firstWin, isTrue),
    );

    blocTest<GameplayBloc, _State>(
      'firstWin stays false once the player has already won a level',
      build: () => buildBloc(
        save: FakeSaveService(
          initial: const SaveDocument(stats: SaveStats(wins: 1)),
        ),
      ),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) => expect(dataOf(bloc).firstWin, isFalse),
    );

    blocTest<GameplayBloc, _State>(
      'firstWin is only ever true for a campaign win (m7-design §13)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              defaultLevel,
            ),
          },
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.bonus(1)));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) => expect(dataOf(bloc).firstWin, isFalse),
    );
  });

  group('stars (spec-prop §7.10; m7-design P3.6)', () {
    // The optimal solve of `defaultLevel` (par 2): red1 into red2, then the
    // pair into red3.
    final winning = [..._tapMove(red1, red2), ..._tapMove(red2, red3)];

    // The same win, but with a pointless shuffle first (red1 to the empty
    // slot beside it, then on): a legal, one-move-over-par solve.
    final winningOverPar = [
      ..._tapMove(red1, emptyBottom),
      ..._tapMove(emptyBottom, red2),
      ..._tapMove(red2, red3),
    ];

    blocTest<GameplayBloc, _State>(
      'an optimal win earns 3 stars; nothing shows on a first win',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 2);
        expect(data.stars, 3);
        expect(data.previousStars, isNull);
        expect(data.starsNewBest, isFalse, reason: 'not a replay');
        expect(data.starTarget, isNull, reason: 'never on a first win (Q118)');
        expect(data.starTip, isFalse);
        expect(saveOf(bloc).document.levelStars, {defaultLevel.id: 3});
      },
    );

    blocTest<GameplayBloc, _State>(
      'a daily, bonus and race win compute no stars (they have no par)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              defaultLevel,
            ),
          },
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.bonus(1)));
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.stars, isNull);
        expect(data.previousStars, isNull);
        expect(data.starTarget, isNull);
        expect(data.starTip, isFalse);
        expect(saveOf(bloc).document.levelStars, isEmpty);
      },
    );

    blocTest<GameplayBloc, _State>(
      'moves over par earn fewer stars at a tighter Remote Config slack',
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, par: 2)],
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.star3SlackPct, 0)
          ..setOverride(RemoteConfigKeys.star2SlackPct, 60),
      ),
      act: (bloc) => _startThen(bloc, winningOverPar),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 3);
        // threshold(2, 0) = 2 (below 3 moves); threshold(2, 60) = 4 (at or
        // above): 2 stars.
        expect(data.stars, 2);
        expect(data.starTip, isTrue, reason: 'the first win below 3 stars');
      },
    );

    blocTest<GameplayBloc, _State>(
      'moves further over par at an even tighter slack earn 1 star, never '
      'fewer',
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, par: 2)],
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.star3SlackPct, 0)
          ..setOverride(RemoteConfigKeys.star2SlackPct, 0),
      ),
      act: (bloc) => _startThen(bloc, winningOverPar),
      verify: (bloc) => expect(dataOf(bloc).stars, 1),
    );

    blocTest<GameplayBloc, _State>(
      'a hint since the last Restart caps an otherwise-perfect win at 2 '
      'stars (Q116)',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) async {
        _startThen(bloc, [const HintPressed()]);
        await settle();
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) => expect(dataOf(bloc).stars, 2),
    );

    blocTest<GameplayBloc, _State>(
      "a hint, then Restart, then a win doesn't cap the stars",
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) async {
        _startThen(bloc, [const HintPressed()]);
        await settle();
        bloc.add(const RestartPressed());
        winning.forEach(bloc.add);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) => expect(dataOf(bloc).stars, 3),
    );

    blocTest<GameplayBloc, _State>(
      'a hint, a kill and a restore still cap the stars (Q116, across '
      'InProgressLevel.hinted)',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) async {
        _startThen(bloc, [const HintPressed()]);
        await settle();
      },
      verify: (bloc) async {
        // The hint persisted the in-progress board (m7-design P3.6): a
        // fresh bloc over the same save restores it with `hinted` still
        // set, even though the board itself hasn't changed.
        final revived = buildBloc(
          entries: [entryFor(defaultLevel, par: 2)],
          save: saveOf(bloc),
        );
        addTearDown(revived.close);
        revived.add(const GameplayStarted(PlayRequest.campaign(1)));
        winning.forEach(revived.add);
        await settle();
        expect(dataOf(revived).stars, 2);
      },
    );

    blocTest<GameplayBloc, _State>(
      'an extra slot on the board caps the stars, including after Restart '
      '(Q116: extra slots survive undo and restart, D22)',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) => _startThen(bloc, [
        const ExtraSlotPressed(),
        const RestartPressed(),
        ...winning,
      ]),
      verify: (bloc) => expect(dataOf(bloc).stars, 2),
    );

    blocTest<GameplayBloc, _State>(
      "relaxed mode's undo never caps the stars: undoing and redoing a "
      'move nets out to the same moves at the win',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) => _startThen(bloc, [
        const RelaxedModeChanged(relaxed: true),
        ..._tapMove(red1, red2),
        const UndoPressed(),
        ..._tapMove(red1, red2),
        ..._tapMove(red2, red3),
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 2);
        expect(data.stars, 3);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a replay that raises the stars reports the new best and the target '
      'only below 3 stars over it (Q118)',
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, order: 1, par: 2)],
        save: FakeSaveService(
          initial: SaveDocument(
            highestLevel: 2,
            levelStars: {defaultLevel.id: 1},
          ),
        ),
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.star3SlackPct, 0)
          ..setOverride(RemoteConfigKeys.star2SlackPct, 60),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.replay(1)));
        winningOverPar.forEach(bloc.add);
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 3);
        expect(data.stars, 2);
        expect(data.previousStars, 1);
        expect(data.starsNewBest, isTrue);
        // threshold(2, 0) = 2: the replay's 3 moves were over it.
        expect(data.starTarget, 2);
        expect(saveOf(bloc).document.levelStars, {defaultLevel.id: 2});
      },
    );

    blocTest<GameplayBloc, _State>(
      'an assisted replay at or under the 3-star target shows no target '
      'line, whatever it earns',
      build: () => buildBloc(
        entries: [entryFor(defaultLevel, order: 1, par: 2)],
        save: FakeSaveService(initial: const SaveDocument(highestLevel: 2)),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.replay(1)));
        bloc.add(const ExtraSlotPressed());
        winning.forEach(bloc.add);
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.winMoves, 2, reason: 'still the par solve');
        expect(data.stars, 2, reason: 'capped by the extra slot');
        expect(data.starTarget, isNull, reason: 'moves were not over t3');
      },
    );

    blocTest<GameplayBloc, _State>(
      'stars change no coins, chest, progress or badge',
      build: () => buildBloc(entries: [entryFor(defaultLevel, par: 2)]),
      act: (bloc) => _startThen(bloc, winning),
      verify: (bloc) {
        final data = dataOf(bloc);
        final save = saveOf(bloc);
        expect(data.stars, 3);
        expect(data.winReward, Tier.easy.defaultRewardCoins);
        expect(save.coins, data.winReward);
        expect(save.currentLevel, 2);
        expect(save.document.chests.opened, isEmpty);
        expect(save.document.records.badges, contains(BadgeId.firstFamily.id));
      },
    );
  });

  group('replay (m7-design §6)', () {
    /// A save that has already won order 1, so `PlayRequest.replay(1)`
    /// resolves (`SaveService.highestLevel` must be past the order).
    FakeSaveService pastLevel1() =>
        FakeSaveService(initial: const SaveDocument(highestLevel: 2));

    final winning = [..._tapMove(red1, red2), ..._tapMove(red2, red3)];

    blocTest<GameplayBloc, _State>(
      'never saves the board in progress, even after a move',
      build: () {
        final save = CountingSaveService()..currentLevel = 2;
        return buildBloc(save: save);
      },
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.replay(1)));
        _tapMove(red1, red2).forEach(bloc.add);
      },
      verify: (bloc) {
        final save = saveOf(bloc) as CountingSaveService;
        expect(save.saveInProgressCalls, 0);
        expect(save.inProgressFor(PlayKind.campaign), isNull);
      },
    );

    blocTest<GameplayBloc, _State>(
      'shows no tutorial cue, whatever tutorialDone says',
      build: () => buildBloc(
        entries: [entryFor(tutorialLevel, order: 1)],
        save: pastLevel1(),
      ),
      act: (bloc) => bloc.add(const GameplayStarted(PlayRequest.replay(1))),
      verify: (bloc) => expect(dataOf(bloc).tutorial, isNull),
    );

    blocTest<GameplayBloc, _State>(
      'shows no intro card, whatever seenIntros says',
      build: () => buildBloc(
        entries: [entryFor(icedLevel, order: 1)],
        save: pastLevel1(),
      ),
      act: (bloc) => bloc.add(const GameplayStarted(PlayRequest.replay(1))),
      verify: (bloc) => expect(dataOf(bloc).intro, isNull),
    );

    blocTest<GameplayBloc, _State>(
      'a win pays no coins, opens no chest and moves nothing, but still '
      'records the best moves and counts in the records; Continue has '
      'nothing to play (back to Chapters)',
      build: () => buildBloc(save: pastLevel1()),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.replay(1)));
        winning.forEach(bloc.add);
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        final save = saveOf(bloc);
        expect(data.isReplay, isTrue);
        expect(data.winReward, 0);
        expect(data.chest, isNull);
        expect(data.chestLevelsLeft, isNull);
        expect(data.winMoves, 2);
        expect(data.bestMoves, 2);
        expect(data.nextRequest, isNull);
        expect(save.coins, 0);
        expect(save.currentLevel, 1, reason: 'a replay never advances it');
        expect(save.document.museum, isEmpty);
        expect(save.document.stats.wins, 1, reason: 'still counts in stats');
        expect(save.bestMovesFor(LevelBests.key(defaultLevel.id, 1)), 2);
      },
    );
  });

  group('out of moves', () {
    blocTest<GameplayBloc, _State>(
      'a move that leaves no legal move is out of moves, with no check',
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        solver: ScriptedSolverService(),
        save: saveWithIntrosSeen(),
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
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        save: saveWithIntrosSeen(),
      ),
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
        save: saveWithIntrosSeen(),
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

    blocTest<GameplayBloc, _State>(
      '"Play Bonus Level N" starts it in the same page (m3-design §6.4 '
      'item 1)',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.campaign(1): playEntryFor(
              const PlayRequest.campaign(1),
              defaultLevel,
              bundleEntry: entry,
            ),
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              outOfMovesLevel,
            ),
          },
          nextOf: (_) => const PlayRequest.bonus(1),
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.campaign(1)));
        winning.forEach(bloc.add);
        bloc
          ..add(const NextLevelPressed())
          ..add(const GameplayStarted(PlayRequest.bonus(1)));
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        expect(dataOf(bloc).play.request, const PlayRequest.bonus(1));
        expect(dataOf(bloc).status, GameplayStatus.playing);
      },
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

  group('tutorial (m3-design §10.4)', () {
    late _MockAnalytics analytics;

    setUpAll(() => registerFallbackValue(<String, Object>{}));

    setUp(() {
      analytics = _MockAnalytics();
      when(
        () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
    });

    // tutorialLevel (real id L0001, `test/helpers/level_fixtures.dart`):
    // red3@r0c0, red2@r0c2, red1@r1c1 — exactly m3-design §10.4's script
    // (step 1/2: r0c2 → r0c0; step 3: r1c1 → r0c0).
    final l1Entry = entryFor(tutorialLevel);

    const level2Json = '''
    {
      "schemaVersion": 1,
      "id": "L0002",
      "maxSize": 3,
      "shelves": [
        [ {"type": "open", "nest": ["red3"]} ],
        [ {"type": "open", "nest": ["red2"]} ]
      ]
    }
    ''';
    final level2 = levelFrom(level2Json);
    final l2Entry = entryFor(level2);

    blocTest<GameplayBloc, _State>(
      'step 1: only a tap on r0c2 is accepted; everything else is ignored',
      build: () => buildBloc(entries: [l1Entry]),
      act: (bloc) => _startThen(bloc, [
        const SlotTapped(red1),
        const SlotDragStarted(red2),
        const UndoPressed(),
        const RestartPressed(),
      ]),
      skip: 1,
      expect: () => const <_State>[],
      verify: (bloc) => expect(
        dataOf(bloc).tutorial,
        const TutorialCue(
          step: 1,
          kind: TutorialCueKind.tapSource,
          from: red2,
          to: red3,
        ),
      ),
    );

    blocTest<GameplayBloc, _State>(
      'step 1 to 2: tapping r0c2 selects it and logs tutorial_step 1',
      build: () => buildBloc(entries: [l1Entry], analytics: analytics),
      act: (bloc) => _startThen(bloc, [const SlotTapped(red2)]),
      verify: (bloc) {
        expect(dataOf(bloc).selectedSlotId, red2);
        expect(
          dataOf(bloc).tutorial,
          const TutorialCue(
            step: 2,
            kind: TutorialCueKind.tapTarget,
            from: red2,
            to: red3,
          ),
        );
        verify(
          () => analytics.logEvent('tutorial_step', parameters: {'step': 1}),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'step 2: a tap anywhere but r0c0 is ignored',
      build: () => buildBloc(entries: [l1Entry]),
      act: (bloc) =>
          _startThen(bloc, [const SlotTapped(red2), const SlotTapped(red1)]),
      verify: (bloc) => expect(dataOf(bloc).selectedSlotId, red2),
    );

    blocTest<GameplayBloc, _State>(
      'step 2 completes: the move applies and logs tutorial_step 2',
      build: () => buildBloc(entries: [l1Entry], analytics: analytics),
      act: (bloc) =>
          _startThen(bloc, [const SlotTapped(red2), const SlotTapped(red3)]),
      verify: (bloc) {
        expect(dataOf(bloc).board.moveCount, 1);
        expect(
          dataOf(bloc).tutorial,
          const TutorialCue(
            step: 3,
            kind: TutorialCueKind.tapSource,
            from: red1,
            to: red3,
          ),
        );
        verify(
          () => analytics.logEvent('tutorial_step', parameters: {'step': 2}),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'step 3 completes the family, wins L1 and logs tutorial_step 3',
      build: () => buildBloc(entries: [l1Entry], analytics: analytics),
      act: (bloc) => _startThen(bloc, [
        const SlotTapped(red2),
        const SlotTapped(red3),
        const SlotTapped(red1),
        const SlotTapped(red3),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.won);
        expect(dataOf(bloc).tutorial, isNull);
        verify(
          () => analytics.logEvent('tutorial_step', parameters: {'step': 3}),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'restore mid-tutorial resumes the right step',
      build: () {
        final save = FakeSaveService();
        final progressed = GameSession(tutorialLevel)..move(red2, red3);
        save.saveInProgress(
          InProgressLevel(
            request: const PlayRequest.campaign(1),
            levelId: tutorialLevel.id,
            levelVersion: 1,
            session: GameSessionCodec.encode(progressed),
          ),
        );
        return buildBloc(entries: [l1Entry], save: save);
      },
      act: _startThen,
      verify: (bloc) {
        expect(dataOf(bloc).restored, isTrue);
        expect(
          dataOf(bloc).tutorial,
          const TutorialCue(
            step: 3,
            kind: TutorialCueKind.tapSource,
            from: red1,
            to: red3,
          ),
        );
      },
    );

    blocTest<GameplayBloc, _State>(
      'L2 step 4: only the drag from r0c0 to r1c0 is accepted, and it '
      'swallows',
      build: () => buildBloc(entries: [l2Entry], analytics: analytics),
      act: (bloc) => _startThen(bloc, [
        const SlotTapped('r0c0'),
        const SlotDragStarted('r1c0'),
        const SlotDragStarted('r0c0'),
        const SlotDragDropped('r1c0'),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).board.slot('r1c0').isEmpty, isFalse);
        expect(dataOf(bloc).board.moveCount, 1);
        verify(
          () => analytics.logEvent('tutorial_step', parameters: {'step': 4}),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      "L2's swallow marks the tutorial done",
      build: () => buildBloc(entries: [l2Entry]),
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted('r0c0'),
        const SlotDragDropped('r1c0'),
      ]),
      verify: (bloc) => expect(saveOf(bloc).document.tutorialDone, isTrue),
    );

    blocTest<GameplayBloc, _State>(
      'a drag dropped elsewhere cancels back to the first cue',
      build: () => buildBloc(entries: [l2Entry]),
      act: (bloc) => _startThen(bloc, [
        const SlotDragStarted('r0c0'),
        const SlotDragDropped(null),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).selectedSlotId, isNull);
        expect(dataOf(bloc).board.moveCount, 0);
        expect(
          dataOf(bloc).tutorial,
          const TutorialCue(
            step: 4,
            kind: TutorialCueKind.drag,
            from: 'r0c0',
            to: 'r1c0',
          ),
        );
      },
    );

    blocTest<GameplayBloc, _State>(
      'once already done, there is no cue at all',
      build: () => buildBloc(
        entries: [l1Entry],
        save: FakeSaveService()..markTutorialDone(),
      ),
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).tutorial, isNull),
    );
  });

  group('intro cards (m3-design §10.4)', () {
    const multiMechanicJson = '''
    {
      "schemaVersion": 1,
      "id": "T0005",
      "maxSize": 3,
      "shelves": [
        [ {"type": "tower", "stack": [["red2"], ["red1"]]},
          {"type": "locked", "unlockColor": "blue", "nest": ["blue2"]},
          {"type": "open", "nest": ["blue3"]},
          {"type": "open", "nest": null} ]
      ]
    }
    ''';
    final multiMechanicLevel = levelFrom(multiMechanicJson);

    blocTest<GameplayBloc, _State>(
      'the first unseen mechanic on the board shows at start, locking input',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: _startThen,
      verify: (bloc) {
        expect(dataOf(bloc).intro, IntroMechanic.towers);
        expect(dataOf(bloc).acceptsInput, isFalse);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a board with no mechanic shows no intro',
      build: buildBloc,
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).intro, isNull),
    );

    blocTest<GameplayBloc, _State>(
      'a mechanic already seen shows no intro',
      build: () => buildBloc(
        entries: [entryFor(outOfMovesLevel)],
        save: FakeSaveService()..markIntroSeen(IntroMechanic.towers),
      ),
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).intro, isNull),
    );

    blocTest<GameplayBloc, _State>(
      'board input is ignored while the card is up',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: (bloc) => _startThen(bloc, [const SlotTapped('r0c2')]),
      skip: 1,
      expect: () => const <_State>[],
    );

    blocTest<GameplayBloc, _State>(
      'Got it marks it seen and shows the next unseen mechanic',
      build: () => buildBloc(entries: [entryFor(multiMechanicLevel)]),
      act: (bloc) => _startThen(bloc, [const IntroDismissed()]),
      verify: (bloc) {
        expect(dataOf(bloc).intro, IntroMechanic.glass);
        expect(saveOf(bloc).document.seenIntros, [IntroMechanic.towers.id]);
      },
    );

    blocTest<GameplayBloc, _State>(
      'dismissing the last mechanic unlocks play',
      build: () => buildBloc(entries: [entryFor(outOfMovesLevel)]),
      act: (bloc) => _startThen(bloc, [const IntroDismissed()]),
      verify: (bloc) {
        expect(dataOf(bloc).intro, isNull);
        expect(dataOf(bloc).acceptsInput, isTrue);
      },
    );

    blocTest<GameplayBloc, _State>(
      'restore shows the intro again if still unseen',
      build: () {
        final save = FakeSaveService();
        final progressed = GameSession(outOfMovesLevel);
        save.saveInProgress(
          InProgressLevel(
            request: const PlayRequest.campaign(1),
            levelId: outOfMovesLevel.id,
            levelVersion: 1,
            session: GameSessionCodec.encode(progressed),
          ),
        );
        return buildBloc(entries: [entryFor(outOfMovesLevel)], save: save);
      },
      act: _startThen,
      verify: (bloc) => expect(dataOf(bloc).intro, IntroMechanic.towers),
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
        save: saveWithIntrosSeen(),
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

    blocTest<GameplayBloc, _State>(
      "logs bonus_level_start at a bonus level's start, but not its restart",
      build: () => buildBloc(
        analytics: analytics,
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.bonus(1): playEntryFor(
              const PlayRequest.bonus(1),
              defaultLevel,
            ),
          },
        ),
      ),
      act: (bloc) => bloc
        ..add(const GameplayStarted(PlayRequest.bonus(1)))
        ..add(const RestartPressed()),
      verify: (_) {
        verify(
          () => analytics.logEvent('bonus_level_start', parameters: {'n': 1}),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'logs chapter_complete when a campaign win completes its chapter',
      build: () => buildBloc(
        analytics: analytics,
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.campaign(1): playEntryFor(
              const PlayRequest.campaign(1),
              defaultLevel,
              chapterId: 'ch03',
              completesChapter: true,
            ),
          },
        ),
      ),
      act: (bloc) =>
          _startThen(bloc, [..._tapMove(red1, red2), ..._tapMove(red2, red3)]),
      verify: (_) {
        verify(
          () => analytics.logEvent(
            'chapter_complete',
            parameters: {'chapter': 3},
          ),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'logs daily_complete with the streak after a daily win',
      build: () => buildBloc(
        analytics: analytics,
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.daily(20260926): playEntryFor(
              const PlayRequest.daily(20260926),
              defaultLevel,
            ),
          },
        ),
      ),
      act: (bloc) {
        bloc.add(const GameplayStarted(PlayRequest.daily(20260926)));
        [..._tapMove(red1, red2), ..._tapMove(red2, red3)].forEach(bloc.add);
      },
      verify: (_) {
        verify(
          () => analytics.logEvent('daily_complete', parameters: {'streak': 1}),
        ).called(1);
      },
    );
  });
}
