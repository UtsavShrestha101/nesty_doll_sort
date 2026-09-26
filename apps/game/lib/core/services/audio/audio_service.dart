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

/// Audio (spec §11.3). Implementations respect the sound/music settings and
/// never throw: a missing or failing file is silence, not a crash.
///
/// TODO(M2): a real flutter_soloud implementation (spec §11.3, PROGRESS D19)
/// with per-size clack pitch and the combo chime steps.
/// TODO(M3): separate SFX/music volumes and the two music loops.
abstract interface class AudioService {
  /// Loads SFX into memory so the first play has no latency.
  Future<void> preload();

  /// Plays a one-shot effect. Deliberately synchronous: gameplay fires these
  /// on every move and must not await them.
  void play(SoundEffect effect);
}
