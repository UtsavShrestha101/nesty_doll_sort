/// The haptic moments of spec §11.2.
enum HapticPattern {
  /// Light tick when a nest is picked up.
  pick,

  /// Medium tap when a nest goes inside / swallows another.
  nest,

  /// Success pattern when a full set completes.
  complete,

  /// Soft error on an invalid drop.
  invalid,
}

/// Plays haptics. Implementations respect the player's haptics setting
/// ("All of them can be turned off", spec §11.2), so callers just fire and
/// forget.
abstract interface class HapticsService {
  Future<void> play(HapticPattern pattern);
}
