import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';
import 'package:nesty_game/features/welcome_back/cubit/welcome_back_cubit.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

/// `WelcomeBackCubit` (local habit 1): the three variants and the plain
/// line, hidden while locked or solved, a dismissal kept through a resume,
/// gone on a new date.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeClock clock;
  late FakeDatabaseService settings;
  late WelcomeBackTracker tracker;
  late FakeDailyService daily;
  late _MockAnalytics analytics;
  late WelcomeBackCubit cubit;
  late LocalDate today;

  DailyStatus status({
    int streak = 0,
    bool lit = false,
    bool unlocked = true,
    bool solved = false,
    List<LocalDate> frozen = const [],
    LocalDate? on,
  }) => DailyStatus(
    today: on ?? today,
    tier: Tier.easy,
    colors: 4,
    unlocked: unlocked,
    streak: streak,
    lit: lit,
    solvedToday: solved,
    frozen: frozen,
  );

  /// A phone last opened [away] days ago, started and loaded.
  Future<void> start(DailyStatus s, {int away = 3}) async {
    await settings.setLastOpenDate(today.addDays(-away).toIso());
    daily.status = s;
    tracker.start();
    await cubit.load();
  }

  WelcomeBackState? shown() => cubit.state.data;

  setUp(() {
    clock = FakeClock();
    today = clock.today();
    settings = FakeDatabaseService();
    tracker = WelcomeBackTracker(settings, clock, FakeRemoteConfigService());
    daily = FakeDailyService(clock);
    analytics = _MockAnalytics();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    cubit = WelcomeBackCubit(tracker, daily, analytics);
  });

  tearDown(() async {
    await cubit.close();
    await tracker.dispose();
    await settings.close();
  });

  test('no streak yet: the new-streak line', () async {
    await start(status());
    expect(
      shown(),
      const WelcomeBackState.shown(
        variant: WelcomeBackVariant.newStreak,
        streak: 0,
      ),
    );
  });

  test('a paused flame keeps its number', () async {
    await start(status(streak: 6));
    expect(
      shown(),
      const WelcomeBackState.shown(
        variant: WelcomeBackVariant.paused,
        streak: 6,
      ),
    );
  });

  test('a lit flame with a freeze: freeze kept', () async {
    await start(status(streak: 6, lit: true, frozen: [today.addDays(-1)]));
    expect(
      shown(),
      const WelcomeBackState.shown(
        variant: WelcomeBackVariant.freezeKept,
        streak: 6,
      ),
    );
  });

  test('a lit flame with no freeze: the plain welcome', () async {
    await start(status(streak: 6, lit: true));
    expect((shown()! as WelcomeBackShown).variant, WelcomeBackVariant.plain);
  });

  test('hidden when not away long enough', () async {
    await start(status(streak: 3), away: 1);
    expect(shown(), const WelcomeBackState.hidden());
  });

  test('hidden while the Daily is locked', () async {
    await start(status(unlocked: false));
    expect(shown(), const WelcomeBackState.hidden());
  });

  test('hidden once today is solved, and it stays gone', () async {
    await start(status(streak: 2));
    expect(shown(), isA<WelcomeBackShown>());
    daily.status = status(streak: 3, lit: true, solved: true);
    await pumpEventQueue();
    expect(shown(), const WelcomeBackState.hidden());
    daily.status = status(streak: 3, lit: true);
    await pumpEventQueue();
    expect(shown(), isA<WelcomeBackShown>(), reason: 'the date still holds');
  });

  test('dismissing hides it and clears the date', () async {
    await start(status(streak: 2));
    cubit.dismiss();
    expect(shown(), const WelcomeBackState.hidden());
    expect(settings.welcomeBackDate, isNull);
  });

  test('a dismissal stays through a resume', () async {
    await start(status(streak: 2));
    cubit.dismiss();
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await pumpEventQueue();
    expect(shown(), const WelcomeBackState.hidden());
  });

  test('gone on a new date', () async {
    await start(status(streak: 2));
    expect(shown(), isA<WelcomeBackShown>());
    final tomorrow = today.addDays(1);
    clock.setDate(tomorrow);
    daily.status = status(streak: 2, on: tomorrow);
    cubit.refresh();
    expect(shown(), const WelcomeBackState.hidden());
  });

  test('play asks for today\'s daily and logs the event', () async {
    await start(status(streak: 2));
    final request = cubit.play();
    expect(request, daily.todayRequest);
    verify(() => analytics.logEvent('welcome_back_play')).called(1);
  });
}
