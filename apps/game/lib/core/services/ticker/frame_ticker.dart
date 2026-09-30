/// A clock that calls back once per displayed frame, for code that must
/// step with the screen: vs Computer's race clock (spec-prop §7.7;
/// docs/plans/m7-design.md P2.5, P2.8).
///
/// The race's rival moves only inside a frame's tick, and a player's move
/// is applied inside its input task, so a win the player makes before a
/// frame is always seen before that frame's rival move: spec-prop §7.7's
/// "on the same frame the player wins". A wall clock (`AppClock`) or a
/// `Timer` would fire between frames and need its own arbitration.
///
/// The real implementation, `SchedulerFrameTicker`, is a raw Flutter
/// `Ticker`, registered as a factory for both environments (one per race).
/// `FakeFrameTicker` plays frames by hand in tests.
abstract interface class FrameTicker {
  /// Starts calling [onTick] once per frame with the time since this start:
  /// the first frame after it reports `Duration.zero`. Starting a ticker
  /// that is ticking restarts it from zero with [onTick].
  void start(void Function(Duration elapsed) onTick);

  /// Stops the ticks; [start] resumes them from zero. Does nothing when
  /// stopped.
  void stop();

  /// Whether [start] was called and neither [stop] nor [dispose] since.
  bool get isTicking;

  /// Stops for good and lets go of the callback. The ticker can't start
  /// again.
  void dispose();
}
