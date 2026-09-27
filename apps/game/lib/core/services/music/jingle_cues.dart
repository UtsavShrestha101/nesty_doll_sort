import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';

/// The music moves around the two jingles whose screens come in M3
/// (AUDIO.md "Jingles" and "Music rules", the owner's answer to audio plan
/// Q40), sequenced once so those screens only call [reward] or
/// [chapterComplete]. The out-of-moves jingle rides on its sheet's
/// `MusicDuck`.
@lazySingleton
class JingleCues {
  JingleCues(this._music, this._jingles);

  final MusicService _music;
  final JinglePlayer _jingles;
  final Set<Timer> _timers = {};

  /// A reward: a skin or a bought theme unlocks, the daily chest opens, a
  /// purchase completes; not the chapter's figurine (audio plan Q40).
  /// `jingle_reward` plays and the music ducks to 0.4 under it, then comes
  /// back over 800 ms when it ends (3.8 s). A jingle that doesn't play
  /// (Sound off) leaves the music alone, so it never dips for nothing.
  // TODO(M3): call from the skin unlock (7.4), the theme unlock or purchase
  // (7.7) and the daily chest (5.6).
  // TODO(M6): call when an in-app purchase completes.
  void reward() {
    final length = _jingles.playJingle(Jingle.reward);
    if (length == null) return;
    _music.duck(DuckReason.reward);
    _after(length, () => _music.unduck(DuckReason.reward));
  }

  /// The Chapter complete overlay (4.6) opens: the music fades out over
  /// 400 ms and pauses, then `jingle_chapter`, the only jingle there (audio
  /// plan Q40). The next level's `MusicService.playGame` fades `music_game`
  /// back in over 2000 ms.
  // TODO(M3): call when Chapter complete (4.6) opens; its Continue then
  // calls MusicService.playGame for the next level.
  void chapterComplete() {
    _music.stopForChapter();
    _after(MusicMix.chapterOut, () => _jingles.playJingle(Jingle.chapter));
  }

  void _after(Duration delay, VoidCallback action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      action();
    });
    _timers.add(timer);
  }

  /// Cancels what is still to come (DI reset).
  @disposeMethod
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Timers still waiting (tests).
  @visibleForTesting
  int get pending => _timers.length;
}
