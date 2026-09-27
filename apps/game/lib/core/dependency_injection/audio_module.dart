import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';

/// One service plays both the SFX and the jingles (they share the SFX bus,
/// the engine and the preload, AUDIO.md "Jingles"), so each environment
/// registers that one instance under [AudioService] and [JinglePlayer].
/// The concrete registrations carry the dispose hook.
@module
abstract class AudioModule {
  @LazySingleton(env: [AppEnv.real])
  AudioService realAudio(SoLoudAudioService audio) => audio;

  @LazySingleton(env: [AppEnv.real])
  JinglePlayer realJingles(SoLoudAudioService audio) => audio;

  @LazySingleton(env: [AppEnv.fake])
  AudioService fakeAudio(FakeAudioService audio) => audio;

  @LazySingleton(env: [AppEnv.fake])
  JinglePlayer fakeJingles(FakeAudioService audio) => audio;
}
