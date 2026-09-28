import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

/// The real [AppClock]: the device's local time (docs/plans/m3-design.md
/// §8.1).
///
/// The dev flavor's debug builds accept
/// `--dart-define=NESTY_FAKE_DATE=yyyymmdd`, so two devices (or a device and
/// a simulator) can be put on the same daily puzzle for the M3 acceptance
/// check. The date replaces today's; the time of day stays real. Profile
/// and release builds, and stg and prod, ignore it.
@LazySingleton(as: AppClock, env: [AppEnv.real])
class SystemClock implements AppClock {
  SystemClock({@ignoreParam LocalDate? fakeDate})
    : _fakeDate = fakeDate ?? _fakeDateFromEnvironment();

  /// The raw `NESTY_FAKE_DATE` define, `''` when it isn't set.
  static const String fakeDateDefine = String.fromEnvironment(
    'NESTY_FAKE_DATE',
  );

  final LocalDate? _fakeDate;

  /// The override in effect, or null (tests, logs).
  LocalDate? get fakeDate => _fakeDate;

  @override
  DateTime now() {
    final now = DateTime.now();
    final fake = _fakeDate;
    if (fake == null) return now;
    return DateTime(
      fake.year,
      fake.month,
      fake.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );
  }

  @override
  LocalDate today() => _fakeDate ?? LocalDate.fromDateTime(DateTime.now());

  /// [fakeDateDefine] as a date when this is a dev-flavor debug build and
  /// it holds a real `yyyymmdd` date; null otherwise.
  static LocalDate? _fakeDateFromEnvironment() =>
      parseFakeDate(fakeDateDefine, debug: kDebugMode, flavor: _flavor());

  /// The override [define] gives in a build that is [debug] and of
  /// [flavor]: only a dev debug build honours it, and only for a real
  /// `yyyymmdd` date.
  @visibleForTesting
  static LocalDate? parseFakeDate(
    String define, {
    required bool debug,
    required Flavor? flavor,
  }) {
    if (!debug || flavor != Flavor.dev || define.length != 8) return null;
    final value = int.tryParse(define);
    if (value == null) return null;
    final year = value ~/ 10000;
    final month = value ~/ 100 % 100;
    final day = value % 100;
    return LocalDate.isValid(year, month, day)
        ? LocalDate(year, month, day)
        : null;
  }

  static Flavor? _flavor() {
    try {
      return FlavorConfig.flavor;
    } on StateError {
      // `lib/main_<flavor>.dart` sets the flavor before DI; only a test that
      // builds the real graph without one gets here.
      return null;
    }
  }
}
