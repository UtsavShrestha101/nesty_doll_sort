import 'package:nesty_game/features/fx/fx_spec.dart';

/// What a clip plays: composition frames [from] to [to] at [speed], once or
/// looping, or resting on one frame (docs/plans/m2-lottie-design.md §2).
///
/// Built from the file's `FxSpec` (a marker, or the whole file), never from
/// hand-typed durations. The clip's progress is `frame / durationFrames`,
/// clamped, as `LottieFxComponent` computes it.
final class FxSegment {
  const FxSegment(this.from, this.to, {this.loop = false, this.speed = 1})
    : assert(to >= from),
      assert(speed >= 0);

  /// Rests on [frame]: a paused composition, `lift`'s last frame while a
  /// doll is dragged or under reduced motion, an ice stage.
  const FxSegment.hold(double frame) : this(frame, frame);

  /// The marker [name] of [spec]. Throws [ArgumentError] for a marker the
  /// file doesn't have (the tools lane validates every marker at sync).
  factory FxSegment.marker(
    FxSpec spec,
    String name, {
    bool loop = false,
    double speed = 1,
  }) {
    final marker =
        spec.marker(name) ??
        (throw ArgumentError.value(name, 'name', 'no such marker in $spec'));
    return FxSegment(marker.start, marker.end, loop: loop, speed: speed);
  }

  /// All of [spec]: frame 0 to its last.
  factory FxSegment.whole(FxSpec spec, {bool loop = false, double speed = 1}) =>
      FxSegment(0, spec.frames.toDouble(), loop: loop, speed: speed);

  /// Rests on the last frame of the marker [name] of [spec].
  factory FxSegment.holdEndOf(FxSpec spec, String name) =>
      FxSegment.hold(FxSegment.marker(spec, name).to);

  /// First frame (inclusive).
  final double from;

  /// Last frame: a one-shot stops and holds here, a loop wraps back to
  /// [from].
  final double to;

  final bool loop;

  /// Composition frames per 1× frame: the motion spec's one-shot speed (2
  /// under reduced motion), or 1 for the loops that carry information. 0
  /// with [loop] pauses an ambient loop on [from].
  final double speed;

  /// True when the segment rests on one frame.
  bool get isHold => from == to;

  /// Length in frames.
  double get frames => to - from;

  /// How long one pass takes at [speed], in ms; 0 for a hold (and for a
  /// paused loop, which never ends).
  double get durationMs => speed == 0 ? 0 : FxSpec.msOf(frames) / speed;

  @override
  bool operator ==(Object other) =>
      other is FxSegment &&
      other.from == from &&
      other.to == to &&
      other.loop == loop &&
      other.speed == speed;

  @override
  int get hashCode => Object.hash(from, to, loop, speed);

  @override
  String toString() => isHold
      ? 'FxSegment(hold $from)'
      : 'FxSegment($from–$to${loop ? ' loop' : ''} ×$speed)';
}
