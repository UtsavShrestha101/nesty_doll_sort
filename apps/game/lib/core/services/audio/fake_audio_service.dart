import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';

/// One [AudioService.play] call, as [FakeAudioService] recorded it.
typedef PlayedSound = ({SoundEffect effect, int? dollSize, int? comboStep});

/// Silent [AudioService] that records every call, so tests can assert "this
/// move clacked at size 4" without an audio engine. Fake env only (tests
/// and `NESTY_FAKE_SERVICES` debug builds), so the history can't grow in a
/// release build.
@LazySingleton(as: AudioService, env: [AppEnv.fake])
class FakeAudioService implements AudioService {
  final List<PlayedSound> _played = [];

  /// Every play, oldest first.
  @visibleForTesting
  List<PlayedSound> get played => List.unmodifiable(_played);

  /// True once [preload] ran.
  @visibleForTesting
  bool preloaded = false;

  @visibleForTesting
  void clear() => _played.clear();

  @override
  Future<void> preload() async => preloaded = true;

  @override
  Future<void> dispose() async => _played.clear();

  @override
  void play(SoundEffect effect, {int? dollSize, int? comboStep}) =>
      _played.add((effect: effect, dollSize: dollSize, comboStep: comboStep));
}
