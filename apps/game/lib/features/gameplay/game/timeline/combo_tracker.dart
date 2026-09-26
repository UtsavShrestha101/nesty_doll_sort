import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// Combo steps for the rising completion chime (spec §11.1, tokens.json
/// `motion.combo`; docs/plans/m2-lottie-design.md §7 "Combos").
///
/// A completion whose moment (the batch's t0: the set lands and
/// `complete_{step}` plays) falls within [windowMs] of the previous one
/// raises the step by one, up to [maxStep]; otherwise the step starts over
/// at 1. The clock is injected so tests can drive it; the board timeline
/// passes its own clock (board time, which stops while the game is paused).
final class ComboTracker {
  ComboTracker({
    required double Function() clock,
    this.windowMs = MotionTokens.comboWindowMs * 1.0,
    this.maxStep = MotionTokens.comboMaxSteps,
  }) : _clock = clock,
       assert(windowMs >= 0),
       assert(maxStep >= 1);

  final double Function() _clock;

  /// The longest gap between two completions that keeps the combo going.
  final double windowMs;

  /// The highest step (`complete_5`).
  final int maxStep;

  double? _lastAtMs;
  int _step = 0;

  /// The step of the last completion, 0 before the first.
  int get step => _step;

  /// Records a completion [delayMs] after the clock's now (a batch's t0 is
  /// in the future when the batch is scheduled) and returns its step, 1 to
  /// [maxStep].
  int register({double delayMs = 0}) => registerAt(_clock() + delayMs);

  /// Records a completion at clock time [atMs] and returns its step.
  int registerAt(double atMs) {
    final last = _lastAtMs;
    if (last != null && atMs - last <= windowMs) {
      _step = _step >= maxStep ? maxStep : _step + 1;
    } else {
      _step = 1;
    }
    _lastAtMs = atMs;
    return _step;
  }

  /// A new level or a restart starts the combo over.
  void reset() {
    _lastAtMs = null;
    _step = 0;
  }
}
