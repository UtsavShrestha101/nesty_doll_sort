/// The five jingles (AUDIO.md "Jingles"; tokens.json `sound.events`
/// `chapterComplete`, `reward`, `outOfMoves`, `raceWon`, `raceLost`).
enum Jingle {
  /// `jingle_chapter` (4.9 s): the Chapter complete overlay (4.6) opens.
  /// It is the only jingle there (owner, audio plan Q40).
  chapter,

  /// `jingle_reward` (3.8 s): a skin or a bought theme unlocks, the daily
  /// chest opens, a purchase completes.
  reward,

  /// `jingle_oom` (4.4 s): the Out of moves sheet opens (3.5, 3.7).
  outOfMoves,

  /// `jingle_versus_win`: a race's win card (9.4) opens, in place of the
  /// level's `win` (tokens.json `sound.events.raceWon`; README's "9.5" is a
  /// typo for 9.4, DELIVERY).
  versusWin,

  /// `jingle_versus_lose`: a race's loss card (9.5) opens
  /// (`sound.events.raceLost`).
  versusLose,
}

/// Plays the jingles: one-shots on the SFX bus, so they follow the Sound
/// toggle and the SFX volume, not the Music ones (tokens.json
/// `sound.mix.jingleBus`). The music's duck around them belongs to the
/// caller (`MusicDuck`, `JingleCues`).
///
/// Its own interface, implemented by the same services as `AudioService`
/// (`SoLoudAudioService`, `FakeAudioService`: one engine, one preload);
/// `AudioModule` registers each environment's instance under both. Code
/// that only fires SFX (the board's `FeedbackSink`, the tactile controls)
/// never sees it.
abstract interface class JinglePlayer {
  /// Plays [jingle] once and returns how long it lasts, or null when it
  /// didn't play (Sound off, the app in the background, the file not
  /// loaded). Synchronous and never throws.
  Duration? playJingle(Jingle jingle);
}
