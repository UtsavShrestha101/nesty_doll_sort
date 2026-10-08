// A past day's board in the gameplay bloc (local habits 3, plan-local-habits
// §3, §7.5c): it never reaches the streak, pays nothing, sells no booster
// for coins, lists only owned boosters, and logs `past_daily_complete`.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import 'support/bloc_fixtures.dart';
import 'support/scripted_level_resolver.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

/// A [FakeDailyService] that fails the test if the bloc asks it for a
/// streak: a past day never calls `progressAfterSolve`.
class _NoStreakDaily extends FakeDailyService {
  _NoStreakDaily(super.clock);

  int solves = 0;

  @override
  DailyProgress progressAfterSolve(LocalDate date) {
    solves++;
    return super.progressAfterSolve(date);
  }
}

const _past = PlayRequest.pastDaily(20260924); // two days before the clock
const _winning = [
  SlotTapped(red1),
  SlotTapped(red2),
  SlotTapped(red2),
  SlotTapped(red3),
];

GameplayBloc _build({
  required FakeSaveService save,
  _NoStreakDaily? daily,
  AnalyticsService? analytics,
  Level? level,
}) {
  final clock = FakeClock();
  return buildBloc(
    save: save,
    clock: clock,
    daily: daily ?? _NoStreakDaily(clock),
    analytics: analytics,
    resolver: ScriptedLevelResolver(
      entries: {
        _past: playEntryFor(_past, level ?? defaultLevel, rewardCoins: 0),
      },
    ),
  );
}

Future<void> _play(GameplayBloc bloc, List<GameplayEvent> events) async {
  bloc.add(const GameplayStarted(_past));
  await settle();
  events.forEach(bloc.add);
  await settle();
}

void main() {
  late _MockAnalytics analytics;

  setUpAll(() => registerFallbackValue(<String, Object>{}));

  setUp(() {
    analytics = _MockAnalytics();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
  });

  group('the win', () {
    test('never asks for a streak, pays 0 and moves nothing but the '
        'archive', () async {
      final save = FakeSaveService();
      final daily = _NoStreakDaily(FakeClock());
      final bloc = _build(save: save, daily: daily, analytics: analytics);
      final before = save.document;
      await _play(bloc, _winning);
      final state = dataOf(bloc);
      expect(state.status, GameplayStatus.won);
      expect(state.isPastDaily, isTrue);
      expect(state.pastDate, LocalDate(2026, 9, 24));
      expect(state.winReward, 0);
      expect(state.dailyStreak, isNull);
      expect(state.dailyRelit, isFalse);
      expect(state.chest, isNull);
      expect(state.nextRequest, isNull);
      expect(state.pastDailyAgain, isFalse);
      expect(daily.solves, 0);
      final after = save.document;
      expect(after.coins, before.coins);
      expect(after.daily, before.daily);
      expect(after.adCounters, before.adCounters);
      expect(after.chests, before.chests);
      expect(after.records.dailies, before.records.dailies);
      expect(after.dailyArchive.played, [LocalDate(2026, 9, 24)]);
      expect(after.dailyArchive.inProgress, isNull);
      expect(after.stats.wins, before.stats.wins + 1);
      await bloc.close();
    });

    test('a second win of the same date says again and adds nothing to '
        'played', () async {
      final save = FakeSaveService();
      final bloc = _build(save: save);
      await _play(bloc, _winning);
      bloc.add(const GameplayStarted(_past));
      await settle();
      _winning.forEach(bloc.add);
      await settle();
      expect(dataOf(bloc).pastDailyAgain, isTrue);
      expect(save.document.dailyArchive.played, hasLength(1));
      await bloc.close();
    });

    test('logs past_daily_complete with days_ago and again', () async {
      final bloc = _build(save: FakeSaveService(), analytics: analytics);
      await _play(bloc, _winning);
      verify(
        () => analytics.logEvent(
          'past_daily_complete',
          parameters: {'days_ago': 2, 'again': false},
        ),
      ).called(1);
      verifyNever(
        () => analytics.logEvent(
          'daily_complete',
          parameters: any(named: 'parameters'),
        ),
      );
      await bloc.close();
    });
  });

  group('boosters on a past day', () {
    test('a hint with none owned opens no offer, and a stale confirm buys '
        'nothing', () async {
      final save = saveWith(hints: 0, extraSlots: 0)..addCoins(500);
      final bloc = _build(save: save);
      await _play(bloc, const [HintPressed()]);
      var state = dataOf(bloc);
      expect(state.offer, isNull);
      expect(state.canHint, isFalse);
      expect(state.canAddSlot, isFalse);
      bloc
        ..add(const ExtraSlotPressed())
        ..add(const BoosterPurchaseConfirmed(BoosterType.slot))
        ..add(const BoosterPurchaseConfirmed(BoosterType.hint));
      await settle();
      state = dataOf(bloc);
      expect(state.offer, isNull);
      expect(save.coins, 500, reason: 'no coin was spent');
      expect(state.board.extraSlotCount, 0);
      await bloc.close();
    });

    test('an owned booster still works', () async {
      final save = saveWith(hints: 1, extraSlots: 1);
      final bloc = _build(save: save);
      await _play(bloc, const [ExtraSlotPressed()]);
      final state = dataOf(bloc);
      expect(state.board.extraSlotCount, 1);
      expect(save.boosterCount(BoosterKind.extraSlot), 0);
      expect(state.canHint, isTrue);
      await bloc.close();
    });

    test('spent free undos offer no coin purchase, and the sheet lists '
        'only what is owned', () async {
      final save = saveWith(hints: 0, extraSlots: 0)..addCoins(500);
      final bloc = _build(save: save);
      await _play(bloc, const [
        SlotTapped(red1),
        SlotTapped(emptyBottom),
        UndoPressed(),
        SlotTapped(red1),
        SlotTapped(emptyBottom),
        UndoPressed(),
        SlotTapped(red1),
        SlotTapped(emptyBottom),
      ]);
      expect(dataOf(bloc).freeUndosLeft, 0);
      bloc.add(const UndoPressed());
      await settle();
      final state = dataOf(bloc);
      expect(state.offer, isNull);
      expect(state.canUndo, isFalse, reason: 'not owned: not listed');
      expect(save.coins, 500);
      await bloc.close();
    });

    test('a campaign board keeps its coin offers (the rule is only the past '
        "day's)", () async {
      final save = saveWith(hints: 0, extraSlots: 0);
      final bloc = buildBloc(save: save);
      bloc.add(const GameplayStarted(PlayRequest.campaign(1)));
      await settle();
      bloc.add(const HintPressed());
      await settle();
      expect(dataOf(bloc).offer?.type, BoosterType.hint);
      expect(dataOf(bloc).isPastDaily, isFalse);
      await bloc.close();
    });
  });
}
