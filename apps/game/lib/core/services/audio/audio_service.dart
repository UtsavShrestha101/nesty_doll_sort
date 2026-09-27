/// Sound effects of spec §11.3 (the owner supplies the files).
enum SoundEffect {
  pick,

  /// `clack_1..3`, pitch-shifted by doll size (bigger = lower).
  clack,
  whoosh,
  bonk,

  /// `complete_1..5`, rising chime steps for combos (spec §11.1).
  complete,
  win,
  coins,
  unlockGlass,
  iceCrack,
  iceShatter,
  button,
}

/// The sound effects (spec §11.3). Implementations respect the Sound
/// setting and never throw: a missing or failing file is silence, not a
/// crash.
///
/// The real implementation is `SoLoudAudioService` (flutter_soloud; the
/// mix rules are `SfxMix`); tests and the fake env use `FakeAudioService`.
/// The same services play the jingles (`JinglePlayer`); the music loops
/// are `MusicService`, on their own volume and the Music setting.
abstract interface class AudioService {
  /// Loads the SFX (and the jingles) into memory so the first play has no
  /// latency.
  Future<void> preload();

  /// Plays a one-shot effect. Deliberately synchronous: gameplay fires these
  /// on every move and must not await them.
  ///
  /// [dollSize] (1–6) sets the [SoundEffect.clack] pitch: the merged nest's
  /// outer size, `NestedInto.merged` (tokens.json `sound.clackPitch`).
  /// [comboStep] (1–5) picks `complete_{comboStep}` for
  /// [SoundEffect.complete]. Both are ignored by the other effects; a
  /// missing one plays size 3 / step 1.
  void play(SoundEffect effect, {int? dollSize, int? comboStep});

  /// Frees the sounds (DI reset); unusable afterwards.
  Future<void> dispose();
}
