import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The two seamless loops (AUDIO.md "Music loops"; tokens.json
/// `sound.music`).
enum MusicTrack {
  /// `music_home`, Toy Shop Waltz: Splash, Home and the meta screens.
  home,

  /// `music_game`, Quiet Shelves: every level (main, daily and bonus).
  game;

  /// The file's base name (tokens.json `sound.music.*.file`).
  String get file => switch (this) {
    MusicTrack.home => SoundTokens.musicHome,
    MusicTrack.game => SoundTokens.musicGame,
  };
}

/// Why the music ducks, with the factor it ducks to (tokens.json
/// `sound.musicDuck`). Ducks don't stack: the lowest active factor wins.
enum DuckReason {
  /// The Level complete overlay (2.8), 0.3.
  win,

  /// The Out of moves sheet (3.5), 0.4.
  outOfMoves,

  /// A reward's jingle, 0.4.
  reward,

  /// The Pause dialog (3.9), 0.5.
  pause,

  /// A race's result card (9.4, 9.5), 0.3 (tokens.json
  /// `sound.musicDuck.raceResult`; phase 4 architecture §3.11).
  raceResult;

  /// Music volume × this while ducked (`SoundTokens.musicDuckFactors`,
  /// keyed by the enum name; `music_mix_test` checks they match).
  double get factor => SoundTokens.musicDuckFactors[name] ?? 1;
}

/// The music (spec §11.3, AUDIO.md "Music rules", tokens.json
/// `sound.musicFadeMs`, `sound.musicDuck`). Every call is synchronous,
/// cheap, and never throws: a loop that can't load is silence (rule 3).
///
/// The real implementation is `SoLoudMusicService`; tests and the fake env
/// use `FakeMusicService`, which records the calls. Callers say what is on
/// screen and the service decides what is heard: the route observer picks
/// the track, `MusicDuck` ducks while an overlay is up, and the Music
/// setting (`DatabaseService.musicEnabledChanges`) reaches [setEnabled]
/// without the toggles calling it.
abstract interface class MusicService {
  /// `music_home`: from silence it fades in over `start` (1200 ms);
  /// from the game loop it crossfades (800 ms), resuming where it stopped.
  void playHome();

  /// `music_game`, the same way. After [stopForChapter] it fades in over
  /// `chapterIn` (2000 ms), also when it already is the track.
  void playGame();

  /// Ducks the music while [reason] holds: in over `duckIn` (200 ms). Calls
  /// are counted, so each needs its own [unduck].
  void duck(DuckReason reason);

  /// Ends one [duck] for [reason]: back over `duckOut` (800 ms) once no
  /// lower factor holds.
  void unduck(DuckReason reason);

  /// The Chapter complete overlay (4.6) opens: fades out over `chapterOut`
  /// (400 ms) and pauses until the next [playGame] or [playHome].
  void stopForChapter();

  /// An interstitial or rewarded ad is about to show: pauses at once.
  // TODO(M6): AdsService calls this before every show, and resumeAfterAd
  // in a `finally` when the ad closes (BACKLOG M6 "Ads").
  void pauseForAd();

  /// The ad closed: fades back in over `resume` (600 ms), unless another
  /// pause (the app in the background) still holds.
  void resumeAfterAd();

  /// The Music setting: off fades out over `toggleOff` (300 ms) and pauses;
  /// on resumes and fades in over `toggleOn` (600 ms). While off nothing
  /// plays, across routes, ads and the app's lifecycle.
  void setEnabled(bool enabled);

  /// The music volume, 0–1 (default `SoundTokens.musicVolumeDefault`, 0.5);
  /// the ducks scale it.
  void setVolume(double volume);

  /// Frees the loops (DI reset); unusable afterwards.
  Future<void> dispose();
}
