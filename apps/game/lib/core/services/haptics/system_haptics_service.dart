import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';

/// Real [HapticsService] on Flutter's built-in [HapticFeedback] — no extra
/// package needed.
@LazySingleton(as: HapticsService, env: [AppEnv.real])
class SystemHapticsService implements HapticsService {
  SystemHapticsService(this._database);

  final DatabaseService _database;

  @override
  Future<void> play(HapticPattern pattern) async {
    // Read the setting on every call: it's an in-memory Hive read, and it
    // means a toggle in Settings applies immediately without any wiring.
    if (!_database.hapticsEnabled) return;
    // TODO(M3): tune by feel on devices; a true multi-pulse "success pattern"
    // for `complete` may need the `vibration` package (spec §13.2).
    switch (pattern) {
      case HapticPattern.pick:
        await HapticFeedback.lightImpact();
      case HapticPattern.nest:
        await HapticFeedback.mediumImpact();
      case HapticPattern.complete:
        await HapticFeedback.heavyImpact();
      case HapticPattern.invalid:
        await HapticFeedback.selectionClick();
    }
  }
}
