import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';

/// Silent [HapticsService] that records every pattern, so tests can assert
/// "this move ticked" without a platform channel. Fake env only.
@LazySingleton(as: HapticsService, env: [AppEnv.fake])
class FakeHapticsService implements HapticsService {
  final List<HapticPattern> _played = [];

  /// Every pattern played, oldest first.
  @visibleForTesting
  List<HapticPattern> get played => List.unmodifiable(_played);

  HapticPattern? get lastPattern => _played.isEmpty ? null : _played.last;

  int get playCount => _played.length;

  @visibleForTesting
  void clear() => _played.clear();

  @override
  Future<void> play(HapticPattern pattern) async => _played.add(pattern);
}
