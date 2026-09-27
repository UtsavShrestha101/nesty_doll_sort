import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/music/music_service.dart';

/// A [MusicService] method.
enum MusicCommand {
  playHome,
  playGame,
  duck,
  unduck,
  stopForChapter,
  pauseForAd,
  resumeAfterAd,
  setEnabled,
  setVolume,
}

/// One [MusicService] call, as [FakeMusicService] recorded it.
@immutable
final class MusicCall {
  const MusicCall(this.command, [this.argument]);

  const MusicCall.playHome() : this(MusicCommand.playHome);
  const MusicCall.playGame() : this(MusicCommand.playGame);
  const MusicCall.duck(DuckReason reason) : this(MusicCommand.duck, reason);
  const MusicCall.unduck(DuckReason reason) : this(MusicCommand.unduck, reason);
  const MusicCall.stopForChapter() : this(MusicCommand.stopForChapter);
  const MusicCall.pauseForAd() : this(MusicCommand.pauseForAd);
  const MusicCall.resumeAfterAd() : this(MusicCommand.resumeAfterAd);
  const MusicCall.setEnabled(bool enabled)
    : this(MusicCommand.setEnabled, enabled);
  const MusicCall.setVolume(double volume)
    : this(MusicCommand.setVolume, volume);

  final MusicCommand command;

  /// The [DuckReason], the enabled flag or the volume; null for the rest.
  final Object? argument;

  @override
  bool operator ==(Object other) =>
      other is MusicCall &&
      other.command == command &&
      other.argument == argument;

  @override
  int get hashCode => Object.hash(command, argument);

  @override
  String toString() => argument == null
      ? 'MusicCall.${command.name}()'
      : 'MusicCall.${command.name}($argument)';
}

/// Silent [MusicService] that records every call and keeps the state they
/// add up to, so tests can assert "the win overlay ducked the music" or
/// "Home asked for music_home" without an audio engine. Fake env only
/// (tests and `NESTY_FAKE_SERVICES` debug builds), so the history can't
/// grow in a release build.
@LazySingleton(as: MusicService, env: [AppEnv.fake])
class FakeMusicService implements MusicService {
  final List<MusicCall> _calls = [];
  final Map<DuckReason, int> _ducks = {};

  /// Every call, oldest first.
  @visibleForTesting
  List<MusicCall> get calls => List.unmodifiable(_calls);

  /// The track the last [playHome] or [playGame] asked for.
  @visibleForTesting
  MusicTrack? track;

  /// The reasons ducking the music now (each duck not yet unducked).
  @visibleForTesting
  Set<DuckReason> get ducking => Set.unmodifiable(_ducks.keys);

  /// The last [setEnabled].
  @visibleForTesting
  bool enabled = true;

  /// Between [pauseForAd] and [resumeAfterAd].
  @visibleForTesting
  bool adPaused = false;

  /// [stopForChapter] held until the next play.
  @visibleForTesting
  bool chapterStopped = false;

  @visibleForTesting
  double volume = 0.5;

  @visibleForTesting
  void clear() => _calls.clear();

  @override
  void playHome() {
    _calls.add(const MusicCall.playHome());
    track = MusicTrack.home;
    chapterStopped = false;
  }

  @override
  void playGame() {
    _calls.add(const MusicCall.playGame());
    track = MusicTrack.game;
    chapterStopped = false;
  }

  @override
  void duck(DuckReason reason) {
    _calls.add(MusicCall.duck(reason));
    _ducks[reason] = (_ducks[reason] ?? 0) + 1;
  }

  @override
  void unduck(DuckReason reason) {
    _calls.add(MusicCall.unduck(reason));
    final count = _ducks[reason] ?? 0;
    if (count > 1) {
      _ducks[reason] = count - 1;
    } else {
      _ducks.remove(reason);
    }
  }

  @override
  void stopForChapter() {
    _calls.add(const MusicCall.stopForChapter());
    chapterStopped = true;
  }

  @override
  void pauseForAd() {
    _calls.add(const MusicCall.pauseForAd());
    adPaused = true;
  }

  @override
  void resumeAfterAd() {
    _calls.add(const MusicCall.resumeAfterAd());
    adPaused = false;
  }

  @override
  void setEnabled(bool enabled) {
    _calls.add(MusicCall.setEnabled(enabled));
    this.enabled = enabled;
  }

  @override
  void setVolume(double volume) {
    _calls.add(MusicCall.setVolume(volume));
    this.volume = volume;
  }

  @override
  Future<void> dispose() async {
    _calls.clear();
    _ducks.clear();
  }
}
