/// The in-app reduce-motion override (spec-prop §16, E14; settings key
/// `reduceMotion`; docs/plans/m7-design.md §4, §14).
///
/// The app root turns it into `MediaQuery.disableAnimations`, so every
/// reader of that flag (`context.reduceMotion`, `LottieFxView`, the board's
/// `MotionSpec`) follows it. Sounds and haptics keep their strength.
/// [storageValue] is what gets persisted, so renaming an enum value never
/// breaks saved settings.
enum ReduceMotionMode {
  /// Follow the operating system's setting (the default).
  system('system'),

  /// Always reduce motion.
  on('on'),

  /// Never reduce motion, whatever the system says.
  off('off');

  const ReduceMotionMode(this.storageValue);

  /// The settings box's value (a storage contract: never rename one).
  final String storageValue;

  /// Whether motion is reduced, given the system's own flag
  /// ([systemDisablesAnimations], `MediaQuery.disableAnimations` as the
  /// platform reports it).
  bool resolve({required bool systemDisablesAnimations}) => switch (this) {
    ReduceMotionMode.system => systemDisablesAnimations,
    ReduceMotionMode.on => true,
    ReduceMotionMode.off => false,
  };

  /// Unknown or missing values fall back to [fallback] (the caller passes
  /// `SettingsDefaults.reduceMotion`) rather than throwing, so a corrupt or
  /// future value can't break settings loading.
  static ReduceMotionMode fromStorage(
    Object? value, {
    required ReduceMotionMode fallback,
  }) {
    for (final mode in values) {
      if (mode.storageValue == value) return mode;
    }
    return fallback;
  }
}
