import 'dart:async';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';

/// The failure states a device can't reach on its own (phase 5,
/// architecture.md §1.3 and decision 13): `faults_test.dart` picks one with
/// `--dart-define=NESTY_FAULT_SCENARIO=<name>`.
enum FaultScenario {
  /// Frame 9.3f: every race board fails to generate.
  raceFailed('race_failed'),

  /// Frame 10.2c: the phone grants notifications after the offer's Yes.
  reminderGranted('reminder_granted'),

  /// Frames 10.2d and 10.2f: the phone refuses them.
  reminderDenied('reminder_denied'),

  /// Frame 12.5: a bonus board is held in generation until the test lets it
  /// go, so the generating card stays up for its shot.
  generating('generating'),

  /// Frame 12.6: every bonus board fails to generate.
  bonusFailed('bonus_failed'),

  /// Frame 12.10: the splash's first load fails as a full disk.
  storage('storage'),

  /// Frame 12.11: the splash's first load fails on the bundled content.
  content('content'),

  /// Frame 10.8's splash with the showcase art in: the level load is held
  /// until the test has shot the splash, so the shot doesn't race the
  /// handover to level 1 (the playthrough's own timing can't wait for it).
  splashLoaded('splash_loaded');

  const FaultScenario(this.define);

  /// The `NESTY_FAULT_SCENARIO` value.
  final String define;

  static FaultScenario parse(String define) => values.firstWhere(
    (scenario) => scenario.define == define,
    orElse: () => throw ArgumentError.value(
      define,
      'NESTY_FAULT_SCENARIO',
      'one of ${values.map((s) => s.define).join(', ')}',
    ),
  );
}

/// Installs [scenario]'s fault through the test-only seam
/// `bootstrap(beforeRunApp:)` (5a-c's C-SEAM): after DI is configured and
/// before `runApp`, it wraps the real service in a decorator and registers
/// that in its place with GetIt's `allowReassignment`. Nothing in `lib/`
/// knows about faults (CLAUDE.md rule 4: the DI stays annotations-only).
///
/// Every decorator delegates to the service the DI built, so the app's state
/// stays in one instance. The save itself is never replaced: bootstrap has
/// already handed it to `SaveLifecycleFlusher` and `DailyService` by then,
/// and a second save would split the game's state. The splash's two error
/// views depend only on the failure's `AppExceptionKind`, so both come from
/// the level repository's first `load`.
final class FaultServices {
  FaultServices(this.scenario);

  final FaultScenario scenario;

  final Completer<void> _release = Completer<void>();

  /// The fake notification service installed by the reminder scenarios.
  FakeNotificationService? notifications;

  /// Lets a generation held by [FaultScenario.generating] go on.
  void release() {
    if (!_release.isCompleted) _release.complete();
  }

  /// The `beforeRunApp` callback.
  Future<void> install() async {
    get.allowReassignment = true;
    try {
      switch (scenario) {
        case FaultScenario.raceFailed:
          _wrapGenerator(failWhen: (params) => _isRace(params));
        case FaultScenario.bonusFailed:
          _wrapGenerator(failWhen: (params) => _isBonus(params));
        case FaultScenario.generating:
          // Held until the test has its shot, or 15 s from the request at
          // most, so a missed release never hangs the run.
          _wrapGenerator(
            holdWhen: (params) => _isBonus(params),
            hold: () => Future.any([
              _release.future,
              Future<void>.delayed(const Duration(seconds: 15)),
            ]),
          );
        case FaultScenario.reminderGranted:
          await _replaceNotifications(NotificationPermission.granted);
        case FaultScenario.reminderDenied:
          await _replaceNotifications(NotificationPermission.denied);
        case FaultScenario.storage:
          _failFirstLevelLoad(AppExceptionKind.storage);
        case FaultScenario.content:
          _failFirstLevelLoad(AppExceptionKind.content);
        case FaultScenario.splashLoaded:
          _holdLevelLoad();
      }
    } finally {
      get.allowReassignment = false;
    }
  }

  static bool _isRace(GeneratorParams params) =>
      (params.id ?? '').startsWith('race-');

  static bool _isBonus(GeneratorParams params) =>
      (params.id ?? '').startsWith('bonus-');

  void _wrapGenerator({
    bool Function(GeneratorParams params)? failWhen,
    bool Function(GeneratorParams params)? holdWhen,
    Future<void> Function()? hold,
  }) {
    final inner = get<LevelGeneratorService>();
    get.registerLazySingleton<LevelGeneratorService>(
      () => FaultyLevelGeneratorService(
        inner,
        failWhen: failWhen,
        holdWhen: holdWhen,
        hold: hold,
      ),
    );
  }

  /// A fake notification service answering [answer], and a fresh
  /// `DailyReminder` over it: bootstrap has already started the real one
  /// over the platform's service, so it is disposed and replaced (it is
  /// the only holder of `NotificationService`).
  Future<void> _replaceNotifications(NotificationPermission answer) async {
    final fake = FakeNotificationService()..permissionAnswer = answer;
    notifications = fake;
    final started = get<DailyReminder>();
    await started.dispose();
    get
      ..registerLazySingleton<NotificationService>(() => fake)
      ..registerLazySingleton<DailyReminder>(
        () => DailyReminder(
          get<NotificationService>(),
          get<DatabaseService>(),
          get<DailyService>(),
          clock: get<AppClock>(),
        ),
        dispose: (reminder) => reminder.dispose(),
      );
    get<DailyReminder>().start();
  }

  /// The splash waits for the level repository, the skin and the showcase
  /// dolls together: holding the first alone keeps it up after the art.
  /// Held until [release], or 60 s at most so a missed release can't hang.
  void _holdLevelLoad() {
    final inner = get<LevelRepository>();
    get.registerLazySingleton<LevelRepository>(
      () => HeldLevelRepository(
        inner,
        Future.any([
          _release.future,
          Future<void>.delayed(const Duration(seconds: 60)),
        ]),
      ),
    );
  }

  void _failFirstLevelLoad(AppExceptionKind kind) {
    final inner = get<LevelRepository>();
    get.registerLazySingleton<LevelRepository>(
      () => FailingOnceLevelRepository(inner, kind),
    );
  }
}

/// [LevelGeneratorService] that answers null (the interface's failure: it
/// never throws) where [failWhen] holds, and first waits for what [hold]
/// returns where [holdWhen] holds; otherwise the real generator's level.
final class FaultyLevelGeneratorService implements LevelGeneratorService {
  FaultyLevelGeneratorService(
    this._inner, {
    this.failWhen,
    this.holdWhen,
    this.hold,
  });

  final LevelGeneratorService _inner;
  final bool Function(GeneratorParams params)? failWhen;
  final bool Function(GeneratorParams params)? holdWhen;
  final Future<void> Function()? hold;

  @override
  Future<GeneratedLevel?> generate(GeneratorParams params) async {
    if (failWhen?.call(params) ?? false) return null;
    if (holdWhen?.call(params) ?? false) await hold?.call();
    return _inner.generate(params);
  }

  @override
  void dispose() => _inner.dispose();
}

/// [LevelRepository] whose first [load] fails with an [AppException] of
/// [kind]; the splash's Try again then loads the real bundle.
final class FailingOnceLevelRepository implements LevelRepository {
  FailingOnceLevelRepository(this._inner, this.kind);

  final LevelRepository _inner;
  final AppExceptionKind kind;
  bool _failed = false;

  @override
  Future<void> load() async {
    if (!_failed) {
      _failed = true;
      throw AppException(kind, message: 'faults_test: ${kind.name}');
    }
    await _inner.load();
  }

  @override
  int get levelCount => _inner.levelCount;

  @override
  LevelBundleEntry? entryAt(int order) => _inner.entryAt(order);
}

/// [LevelRepository] whose [load] first waits for [hold].
final class HeldLevelRepository implements LevelRepository {
  HeldLevelRepository(this._inner, this._hold);

  final LevelRepository _inner;
  final Future<void> _hold;

  @override
  Future<void> load() async {
    await _hold;
    await _inner.load();
  }

  @override
  int get levelCount => _inner.levelCount;

  @override
  LevelBundleEntry? entryAt(int order) => _inner.entryAt(order);
}
