/// The haptic moments of spec §11.2, as `design/tokens.json` → `haptics`
/// names them.
enum HapticPattern {
  /// Light tick when a nest is picked up.
  pick,

  /// Medium tap when a nest goes inside / swallows another (at the clack).
  nest,

  /// Success when a full set completes: medium, then light after 80 ms.
  complete,

  /// Success when the level is won.
  win,

  /// Soft error on an invalid move: light twice, 60 ms apart.
  invalid,

  /// Medium tap when a glass case breaks.
  unlock,

  /// Light tick when ice cracks. `IceShattered` has none (LOTTIE.md,
  /// PROGRESS D49).
  iceCrack,

  /// Selection click on buttons and toggles.
  button,
}

/// Plays haptics. Implementations respect the player's haptics setting
/// ("All of them can be turned off", spec §11.2), so callers just fire and
/// forget.
abstract interface class HapticsService {
  Future<void> play(HapticPattern pattern);
}
