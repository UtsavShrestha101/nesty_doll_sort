import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';

/// One platform impact of a pattern.
enum HapticPulse { light, medium, selection }

/// The pulses of every [HapticPattern] (tokens.json `haptics`, spec §11.2),
/// played in order with [delayBefore] between them.
abstract final class HapticPatterns {
  /// tokens `haptics.complete`: "mediumImpact, then lightImpact after 80 ms".
  static const successGap = Duration(milliseconds: 80);

  /// tokens `haptics.invalid`: "lightImpact twice, 60 ms apart".
  static const softErrorGap = Duration(milliseconds: 60);

  /// The pulses of [pattern], with the pause before each (zero for the
  /// first).
  static List<(Duration delayBefore, HapticPulse pulse)> of(
    HapticPattern pattern,
  ) => switch (pattern) {
    HapticPattern.pick || HapticPattern.iceCrack => _light,
    HapticPattern.nest || HapticPattern.unlock => _medium,
    // tokens: complete = "success", win = "success".
    HapticPattern.complete || HapticPattern.win => _success,
    HapticPattern.invalid => _softError,
    HapticPattern.button => _selection,
  };

  static const _light = [(Duration.zero, HapticPulse.light)];
  static const _medium = [(Duration.zero, HapticPulse.medium)];
  static const _selection = [(Duration.zero, HapticPulse.selection)];
  static const _success = [
    (Duration.zero, HapticPulse.medium),
    (successGap, HapticPulse.light),
  ];
  static const _softError = [
    (Duration.zero, HapticPulse.light),
    (softErrorGap, HapticPulse.light),
  ];
}

/// Real [HapticsService] on Flutter's built-in [HapticFeedback], no extra
/// package needed. Multi-pulse patterns are timed with [Future.delayed]
/// (tests inject the delay).
// TODO(M7): tune by feel on devices (BACKLOG M7, moved from M3's "Audio
// and haptics": it needs the owner's hands on real phones).
@LazySingleton(as: HapticsService, env: [AppEnv.real])
class SystemHapticsService implements HapticsService {
  SystemHapticsService(
    this._database, {
    @ignoreParam Future<void> Function(Duration duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final DatabaseService _database;
  final Future<void> Function(Duration duration) _delay;

  @override
  Future<void> play(HapticPattern pattern) async {
    // Read the setting on every call: it's an in-memory Hive read, and it
    // means a toggle in Settings applies immediately without any wiring.
    if (!_database.hapticsEnabled) return;
    for (final (delayBefore, pulse) in HapticPatterns.of(pattern)) {
      if (delayBefore > Duration.zero) {
        await _delay(delayBefore);
        // Turned off mid-pattern: stop there.
        if (!_database.hapticsEnabled) return;
      }
      try {
        await _pulse(pulse);
      } on PlatformException {
        // No vibrator, or the platform refused: haptics are a nicety, never
        // an error (CLAUDE.md rule 3).
        return;
      }
    }
  }

  static Future<void> _pulse(HapticPulse pulse) => switch (pulse) {
    HapticPulse.light => HapticFeedback.lightImpact(),
    HapticPulse.medium => HapticFeedback.mediumImpact(),
    HapticPulse.selection => HapticFeedback.selectionClick(),
  };
}
