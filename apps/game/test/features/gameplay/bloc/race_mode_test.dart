// The gameplay bloc's race mode (spec-prop §7.7; docs/plans/m7-design.md
// P2.6), on the frozen gate (test/contracts/m7_phase2_test.dart's "the
// bloc's race gate" pins that taps are refused until `RaceGateChanged(open:
// true)`, and again once it closes). This file covers the rest of P2.13's
// race-bloc bullet list: no offer or spend for Hint and +1 Slot,
// `canHint`/`canAddSlot` false, Undo free past `free_undos_per_level`, a
// win writes nothing to the save and persists nothing, no tutorial cue or
// intro card, no spec §14.4 level event (`booster_use` still logs), and a
// mid-drag drop when the gate shuts puts the doll down without moving it.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import 'support/bloc_fixtures.dart';
import 'support/scripted_level_resolver.dart';
import 'support/scripted_solver_service.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

/// A [FakeSaveService] that keeps every in-progress board it was asked to
/// save, oldest first: a race must never call `saveInProgress` at all
/// (m7-design P2.6 "no restore, no `_persistProgress`"), not even for a
/// move that doesn't win.
class _RecordingSaveService extends FakeSaveService {
  final List<InProgressLevel> saved = [];

  @override
  void saveInProgress(InProgressLevel level) {
    saved.add(level);
    super.saveInProgress(level);
  }
}

typedef _State = AsyncValue<GameplayState>;

const _race = PlayRequest.race(rival: 1, raceNo: 1);

/// [GameplayStarted] for [request], then the race gate opening, then
/// [events] (m7-design P2.6: the page opens the gate once the cubit's
/// clock starts).
void _raceStartThen(
  GameplayBloc bloc,
  PlayRequest request, [
  List<GameplayEvent> events = const [],
]) {
  bloc.add(GameplayStarted(request));
  bloc.add(const RaceGateChanged(open: true));
  events.forEach(bloc.add);
}

/// Taps [from] then [to] (tap-tap move), as `gameplay_bloc_test.dart`'s own
/// private helper does.
List<GameplayEvent> _tapMove(String from, String to) => [
  SlotTapped(from),
  SlotTapped(to),
];

void main() {
  GameplayBloc raceBloc({
    SaveService? save,
    AnalyticsService? analytics,
    SolverService? solver,
    LevelResolver? resolver,
    Level? level,
  }) => buildBloc(
    resolver:
        resolver ??
        ScriptedLevelResolver(
          entries: {_race: playEntryFor(_race, level ?? defaultLevel)},
        ),
    save: save,
    analytics: analytics,
    solver: solver,
  );

  group('Hint and +1 Slot are off (m7-design P2.6, spec-prop §7.7)', () {
    blocTest<GameplayBloc, _State>(
      'canHint and canAddSlot are false; pressing them does nothing: no '
      'offer, no spend',
      build: raceBloc,
      act: (bloc) => _raceStartThen(bloc, _race, [
        const HintPressed(),
        const ExtraSlotPressed(),
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.canHint, isFalse);
        expect(data.canAddSlot, isFalse);
        expect(data.offer, isNull);
        expect(saveOf(bloc).coins, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'still nothing with a full wallet and the debug free slot on',
      build: () => buildBloc(
        resolver: ScriptedLevelResolver(
          entries: {_race: playEntryFor(_race, defaultLevel)},
        ),
        save: saveWith(hints: 3, extraSlots: 3),
        freeExtraSlots: true,
      ),
      act: (bloc) => _raceStartThen(bloc, _race, [
        const HintPressed(),
        const ExtraSlotPressed(),
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.offer, isNull);
        expect(data.hint, isNull);
        expect(data.board.extraSlotCount, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'a stray purchase confirm for hint or slot never spends (belt and '
      'suspenders: no offer is ever up to confirm)',
      build: raceBloc,
      act: (bloc) => _raceStartThen(bloc, _race, [
        const BoosterPurchaseConfirmed(BoosterType.hint),
        const BoosterPurchaseConfirmed(BoosterType.slot),
      ]),
      verify: (bloc) => expect(saveOf(bloc).coins, 0),
    );
  });

  group('Undo and Restart are free and unlimited (m7-design P2.6)', () {
    blocTest<GameplayBloc, _State>(
      'Undo stays free past the usual free-undo limit, never an offer or a '
      'spend',
      build: raceBloc,
      act: (bloc) => _raceStartThen(bloc, _race, [
        for (var i = 0; i < 5; i++) ...[
          ..._tapMove(red1, emptyTop),
          const UndoPressed(),
        ],
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.offer, isNull);
        expect(data.board, GameState.initial(defaultLevel));
        expect(saveOf(bloc).coins, 0);
      },
    );

    blocTest<GameplayBloc, _State>(
      'Undo and Restart do nothing before the gate opens',
      build: raceBloc,
      act: (bloc) {
        bloc
          ..add(const GameplayStarted(_race))
          ..add(const UndoPressed())
          ..add(const RestartPressed());
      },
      // The race's own loading state, then the started (ready) state: no
      // further state from Undo or Restart while the gate is shut.
      skip: 2,
      expect: () => const <_State>[],
    );

    test('and again once the gate shuts', () async {
      final bloc = raceBloc();
      addTearDown(bloc.close);
      _raceStartThen(bloc, _race);
      await settle();
      bloc.add(const RaceGateChanged(open: false));
      await settle();
      final closed = dataOf(bloc);
      expect(closed.raceLive, isFalse);

      bloc
        ..add(const UndoPressed())
        ..add(const RestartPressed());
      await settle();
      expect(dataOf(bloc), same(closed));
    });

    blocTest<GameplayBloc, _State>(
      'a mid-drag drop when the gate shuts puts the doll down without '
      'moving it',
      build: raceBloc,
      act: (bloc) {
        _raceStartThen(bloc, _race, [const SlotDragStarted(red1)]);
        bloc.add(const RaceGateChanged(open: false));
        bloc.add(const SlotDragDropped(emptyTop));
      },
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.selectedSlotId, isNull);
        expect(data.board, GameState.initial(defaultLevel));
      },
    );
  });

  group('Nothing extra (m7-design P2.6 "no cue, no intro card")', () {
    blocTest<GameplayBloc, _State>(
      'no tutorial cue on L0001, whatever tutorialDone says',
      build: () => raceBloc(level: tutorialLevel),
      act: (bloc) => _raceStartThen(bloc, _race),
      verify: (bloc) => expect(dataOf(bloc).tutorial, isNull),
    );

    blocTest<GameplayBloc, _State>(
      'no intro card, even on a board with an unseen mechanic: input is '
      'open once the gate is',
      build: () => raceBloc(level: outOfMovesLevel),
      act: (bloc) => _raceStartThen(bloc, _race),
      verify: (bloc) {
        expect(dataOf(bloc).intro, isNull);
        expect(dataOf(bloc).acceptsInput, isTrue);
      },
    );
  });

  group('A win (m7-design P2.6)', () {
    blocTest<GameplayBloc, _State>(
      'sets status won and winMoves only: no coins, chest, figurine, '
      'currentLevel, best moves, firstWin or nextRequest',
      build: () => raceBloc(save: _RecordingSaveService()),
      act: (bloc) => _raceStartThen(bloc, _race, [
        ..._tapMove(red1, emptyTop),
        const UndoPressed(), // a non-winning move first: still nothing saved
        ..._tapMove(red1, red2),
        ..._tapMove(red2, red3),
      ]),
      verify: (bloc) {
        final data = dataOf(bloc);
        expect(data.status, GameplayStatus.won);
        expect(data.winMoves, 2);
        expect(data.winReward, 0);
        expect(data.chest, isNull);
        expect(data.chestLevelsLeft, isNull);
        expect(data.newBadges, isEmpty);
        expect(data.firstWin, isFalse);
        expect(data.nextRequest, isNull);
        expect(data.bestMoves, isNull);
        expect(data.previousBest, isNull);
        expect(data.completedChapterId, isNull);
        final save = saveOf(bloc) as _RecordingSaveService;
        expect(save.coins, 0);
        expect(save.currentLevel, 1);
        expect(
          save.saved,
          isEmpty,
          reason: 'nothing persisted, not even a mid-race move',
        );
      },
    );
  });

  group('Analytics: none of spec §14.4\'s level events (m7-design P2.6)', () {
    late _MockAnalytics analytics;

    setUpAll(() => registerFallbackValue(<String, Object>{}));

    setUp(() {
      analytics = _MockAnalytics();
      when(
        () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
      ).thenAnswer((_) async {});
    });

    blocTest<GameplayBloc, _State>(
      'no level_start, level_restart or level_win; booster_use still logs',
      build: () => raceBloc(analytics: analytics),
      act: (bloc) => _raceStartThen(bloc, _race, [
        ..._tapMove(red1, emptyTop),
        const UndoPressed(),
        const RestartPressed(),
        ..._tapMove(red1, red2),
        ..._tapMove(red2, red3),
      ]),
      verify: (_) {
        verifyNever(
          () => analytics.logEvent(
            'level_start',
            parameters: any(named: 'parameters'),
          ),
        );
        verifyNever(
          () => analytics.logEvent(
            'level_restart',
            parameters: any(named: 'parameters'),
          ),
        );
        verifyNever(
          () => analytics.logEvent(
            'level_win',
            parameters: any(named: 'parameters'),
          ),
        );
        verify(
          () => analytics.logEvent(
            'booster_use',
            parameters: {'type': 'undo', 'source': 'free'},
          ),
        ).called(1);
      },
    );

    blocTest<GameplayBloc, _State>(
      'no level_out_of_moves',
      build: () => raceBloc(analytics: analytics, level: outOfMovesLevel),
      // r0c0's top (blue1) onto the empty r0c3 leaves the board dead
      // (`outOfMovesLevel`'s own doc comment).
      act: (bloc) => _raceStartThen(bloc, _race, [
        const SlotTapped('r0c0'),
        const SlotTapped('r0c3'),
      ]),
      verify: (bloc) {
        expect(dataOf(bloc).status, GameplayStatus.outOfMoves);
        verifyNever(
          () => analytics.logEvent(
            'level_out_of_moves',
            parameters: any(named: 'parameters'),
          ),
        );
      },
    );

    blocTest<GameplayBloc, _State>(
      'no level_soft_stuck, but the check and the banner stay',
      build: () => raceBloc(
        analytics: analytics,
        solver: ScriptedSolverService(
          onSoftStuck: (_) => SolveVerdict.unsolvable,
        ),
      ),
      act: (bloc) async {
        _raceStartThen(bloc, _race, [..._tapMove(red1, emptyTop)]);
        await settle(const Duration(milliseconds: 30));
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        expect(dataOf(bloc).softStuck, isTrue);
        verifyNever(
          () => analytics.logEvent(
            'level_soft_stuck',
            parameters: any(named: 'parameters'),
          ),
        );
      },
    );
  });
}
