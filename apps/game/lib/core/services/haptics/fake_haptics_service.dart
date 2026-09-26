import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';

/// Silent [HapticsService] that remembers the last pattern, so tests can
/// assert "this move ticked" without a platform channel.
@LazySingleton(as: HapticsService, env: [AppEnv.fake])
class FakeHapticsService implements HapticsService {
  HapticPattern? lastPattern;

  int playCount = 0;

  @override
  Future<void> play(HapticPattern pattern) async {
    lastPattern = pattern;
    playCount++;
  }
}
