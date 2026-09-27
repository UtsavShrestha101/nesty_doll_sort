import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';

/// One [AudioService.play] call, as [FakeAudioService] recorded it.
typedef PlayedSound = ({SoundEffect effect, int? dollSize, int? comboStep});

/// Silent [AudioService] and [JinglePlayer] that records every call, so
/// tests can assert "this move clacked at size 4" or "the sheet played
/// jingle_oom" without an audio engine. Fake env only (tests and
/// `NESTY_FAKE_SERVICES` debug builds), so the history can't grow in a
/// release build. `AudioModule` hands it out under both interfaces.
@LazySingleton(env: [AppEnv.fake])
class FakeAudioService implements AudioService, JinglePlayer {
  /// The shipped jingles' lengths (AUDIO.md "Files").
  static const Map<Jingle, Duration> shippedJingleLengths = {
    Jingle.chapter: Duration(milliseconds: 4875),
    Jingle.reward: Duration(milliseconds: 3759),
    Jingle.outOfMoves: Duration(milliseconds: 4380),
  };

  final List<PlayedSound> _played = [];
  final List<Jingle> _jingles = [];

  /// Every play, oldest first.
  @visibleForTesting
  List<PlayedSound> get played => List.unmodifiable(_played);

  /// Every jingle played, oldest first.
  @visibleForTesting
  List<Jingle> get jingles => List.unmodifiable(_jingles);

  /// True once [preload] ran.
  @visibleForTesting
  bool preloaded = false;

  /// What [playJingle] returns for each jingle; a missing one plays as not
  /// played (null), like a jingle that failed to load.
  @visibleForTesting
  Map<Jingle, Duration> jingleLengths = shippedJingleLengths;

  @visibleForTesting
  void clear() {
    _played.clear();
    _jingles.clear();
  }

  @override
  Future<void> preload() async => preloaded = true;

  @override
  Future<void> dispose() async => clear();

  @override
  void play(SoundEffect effect, {int? dollSize, int? comboStep}) =>
      _played.add((effect: effect, dollSize: dollSize, comboStep: comboStep));

  @override
  Duration? playJingle(Jingle jingle) {
    _jingles.add(jingle);
    return jingleLengths[jingle];
  }
}
