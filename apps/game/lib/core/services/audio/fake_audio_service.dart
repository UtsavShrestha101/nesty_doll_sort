import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';

/// Silent [AudioService].
///
/// TODO(M3): drop `AppEnv.real` from `env` once the real audio service exists.
@LazySingleton(as: AudioService, env: [AppEnv.fake, AppEnv.real])
class FakeAudioService implements AudioService {
  @override
  Future<void> preload() async {}

  @override
  void play(SoundEffect effect) {}
}
