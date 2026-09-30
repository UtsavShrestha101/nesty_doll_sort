import 'package:nesty_game/core/services/ticker/frame_ticker.dart';

/// A [FrameTicker] that plays frames only when a test asks (docs/plans/
/// m7-design.md P2.5, P2.13): [tick] one frame, [advance] a stretch of
/// them. Not bound by DI; tests pass it to the race cubit.
class FakeFrameTicker implements FrameTicker {
  /// A 60 fps frame, the default step.
  static const Duration frameInterval = Duration(microseconds: 16667);

  void Function(Duration elapsed)? _onTick;
  Duration _elapsed = Duration.zero;
  bool _ticking = false;
  bool _framed = false;

  /// How many times [start] was called.
  int startCount = 0;

  /// Whether [dispose] was called.
  bool isDisposed = false;

  /// The elapsed time the last tick reported (zero before the first).
  Duration get elapsed => _elapsed;

  @override
  bool get isTicking => _ticking;

  @override
  void start(void Function(Duration elapsed) onTick) {
    if (isDisposed) throw StateError('A disposed FrameTicker cannot start');
    _onTick = onTick;
    _elapsed = Duration.zero;
    _framed = false;
    _ticking = true;
    startCount++;
  }

  @override
  void stop() => _ticking = false;

  @override
  void dispose() {
    isDisposed = true;
    _ticking = false;
    _onTick = null;
  }

  /// Plays one frame, [frame] after the last one: the first frame after
  /// [start] reports `Duration.zero`, as a `Ticker`'s does. Does nothing
  /// while stopped.
  void tick([Duration frame = frameInterval]) {
    final onTick = _onTick;
    if (!_ticking || onTick == null) return;
    if (_framed) {
      _elapsed += frame;
    } else {
      _framed = true;
    }
    onTick(_elapsed);
  }

  /// Plays frames every [frame] until [by] has passed (at least one
  /// frame), stopping early if the ticker stops.
  void advance(Duration by, {Duration frame = frameInterval}) {
    var left = by;
    do {
      tick(frame);
      left -= frame;
    } while (left > Duration.zero && _ticking);
  }
}
