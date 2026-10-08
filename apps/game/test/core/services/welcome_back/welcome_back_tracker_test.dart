import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';

/// [WelcomeBackTracker]: the gap is read before `lastOpenDate` is written,
/// at the start and at every resume.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeClock clock;
  late FakeDatabaseService settings;
  late WelcomeBackTracker tracker;
  late LocalDate today;

  setUp(() {
    clock = FakeClock();
    today = clock.today();
    settings = FakeDatabaseService();
    tracker = WelcomeBackTracker(settings, clock, FakeRemoteConfigService());
  });

  tearDown(() async {
    await tracker.dispose();
    await settings.close();
  });

  test('a first launch writes today and sets no card', () {
    tracker.start();
    expect(settings.lastOpenDate, today.toIso());
    expect(settings.welcomeBackDate, isNull);
    expect(tracker.welcomeBackDate, isNull);
  });

  test('start reads the stored date before writing it', () async {
    await settings.setLastOpenDate(today.addDays(-3).toIso());
    final changes = <LocalDate?>[];
    tracker.changes.listen(changes.add);
    tracker.start();
    expect(settings.welcomeBackDate, today.toIso());
    expect(settings.lastOpenDate, today.toIso());
    expect(tracker.welcomeBackDate, today);
    await pumpEventQueue();
    expect(changes, [today]);
  });

  test('a resume on a new date after days away sets the card', () {
    tracker.start();
    clock.setDate(today.addDays(4));
    resume();
    expect(tracker.welcomeBackDate, today.addDays(4));
    expect(settings.lastOpenDate, today.addDays(4).toIso());
  });

  test('a dismissal stays through a resume the same day', () async {
    await settings.setLastOpenDate(today.addDays(-3).toIso());
    tracker.start();
    tracker.dismiss();
    expect(settings.welcomeBackDate, isNull);
    resume();
    expect(tracker.welcomeBackDate, isNull);
  });

  test('a clock wound back keeps the mark and shows nothing', () {
    tracker.start();
    clock.setDate(today.addDays(-5));
    resume();
    expect(settings.lastOpenDate, today.toIso());
    expect(tracker.welcomeBackDate, isNull);
  });
}

/// A resume, as `AppLifecycleListener` delivers it.
void resume() {
  WidgetsBinding.instance.handleAppLifecycleStateChanged(
    AppLifecycleState.inactive,
  );
  WidgetsBinding.instance.handleAppLifecycleStateChanged(
    AppLifecycleState.resumed,
  );
}
