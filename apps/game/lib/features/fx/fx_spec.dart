import 'dart:ui' show Offset;

import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';

/// How a file is placed (LOTTIE.md "Format", m2-lottie-design §5).
enum FxKind {
  /// The canvas surrounds one game point: the file's [FxSpec.anchor] goes on
  /// it, scaled by `BoardFit.scale` (doll files) or
  /// `SlotGeometry.furnitureScale` (board pieces), or by the widget's own
  /// layout outside the board.
  inPlace,

  /// A 390×844 canvas over the whole board, in reference units:
  /// translated to `(fit.originX, fit.originY − 142·s)` and scaled by `s`.
  /// A `travel` null moves between [FxTravel.s] and [FxTravel.t] and is
  /// remapped onto the real points at runtime.
  boardSpace,

  /// Placed in place like [inPlace], and its [FxSpec.markers] name the
  /// segments: one segment per event, and the rest pose is a paused frame.
  segmented,
}

/// A named segment, in composition frames (60 fps).
final class FxMarker {
  const FxMarker(this.name, this.start, this.duration) : assert(duration >= 0);

  final String name;

  /// First frame of the segment.
  final double start;

  /// Length in frames.
  final double duration;

  /// The frame after the last one (start + duration).
  double get end => start + duration;

  double get startMs => FxSpec.msOf(start);

  double get durationMs => FxSpec.msOf(duration);

  @override
  bool operator ==(Object other) =>
      other is FxMarker &&
      other.name == name &&
      other.start == start &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(name, start, duration);

  @override
  String toString() => 'FxMarker($name, $start+$duration)';
}

/// A stretch where the `travel` null does not move: two consecutive
/// keyframes with the same value. lottie 3.6.1 returns the keyframe value
/// without calling the position callback there, so the remap needs the
/// anchor-delegate workaround (m2-lottie-design §6).
final class FxHold {
  const FxHold(this.start, this.end, this.value) : assert(end >= start);

  /// Frames, inclusive of [start], exclusive of [end].
  final double start;
  final double end;

  /// The held position, in canvas units.
  final Offset value;

  bool covers(double frame) => frame >= start && frame < end;

  @override
  bool operator ==(Object other) =>
      other is FxHold &&
      other.start == start &&
      other.end == end &&
      other.value == value;

  @override
  int get hashCode => Object.hash(start, end, value);

  @override
  String toString() => 'FxHold($start–$end at $value)';
}

/// A board-space file's `travel` null: authored from [s] toward [t]
/// (LOTTIE.md "Travel remap").
final class FxTravel {
  const FxTravel({required this.s, required this.t, this.holds = const []});

  /// The authored start point, in canvas units.
  final Offset s;

  /// The authored end point, in canvas units.
  final Offset t;

  /// Every hold of the null, in frame order.
  final List<FxHold> holds;

  /// How far along S→T the authored point [v] is: its projection on the
  /// segment, 0 at [s] and 1 at [t], below 0 or above 1 where the authored
  /// easing overshoots. Allocation-free.
  double progressOf(Offset v) {
    final dx = t.dx - s.dx;
    final dy = t.dy - s.dy;
    return ((v.dx - s.dx) * dx + (v.dy - s.dy) * dy) / (dx * dx + dy * dy);
  }

  /// [v] mapped from S→T onto [src]→[dst], keeping the authored easing and
  /// overshoot (LOTTIE.md `remapTravel`). All three points are in the same
  /// units (reference units for the board, m2-lottie-design §5). Allocates
  /// the result: lottie's position callback must return a new `Offset`
  /// (PROGRESS D42).
  Offset remap(Offset v, Offset src, Offset dst) {
    final u = progressOf(v);
    return Offset(
      src.dx + (dst.dx - src.dx) * u,
      src.dy + (dst.dy - src.dy) * u,
    );
  }

  /// The hold that covers [frame], or null while the null moves.
  FxHold? holdAt(double frame) {
    for (final hold in holds) {
      if (hold.covers(frame)) return hold;
    }
    return null;
  }

  /// The hold whose stretch is nearest [frame]: the one to compensate when
  /// the position callback was skipped, whatever lottie's frame rounding
  /// did at a boundary. Null only when there are no holds.
  FxHold? nearestHold(double frame) {
    FxHold? best;
    var bestDistance = double.infinity;
    for (final hold in holds) {
      final distance = hold.covers(frame)
          ? 0.0
          : (frame < hold.start ? hold.start - frame : frame - hold.end);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = hold;
      }
    }
    return best;
  }
}

/// One image layer, with the transform it was authored with, so the FX
/// runtime can compensate for the raster the game supplies
/// (m2-lottie-design §3).
final class FxImageLayer {
  const FxImageLayer({
    required this.keyPath,
    required this.slot,
    required this.scale,
    required this.anchor,
    this.scaleAnimated = false,
  });

  /// The lottie `KeyPath` of the layer: its name, prefixed by its precomp
  /// layer's name inside a precomp (`['shine_matte', 'lid']`).
  final List<String> keyPath;

  /// The image asset it draws.
  final FxImageSlot slot;

  /// The authored scale (1 = 100 %). For [scaleAnimated] layers, the first
  /// keyframe's value; the runtime scales the animated value instead.
  final Offset scale;

  /// The authored anchor point, in declared asset px.
  final Offset anchor;

  /// True when the scale is keyframed (`glow_ring`, `extra_slot`,
  /// `ice_shatter`): it can't be replaced by a static value, so the runtime
  /// divides the animated value by the raster scale in a callback.
  final bool scaleAnimated;
}

/// Everything the game reads from one file without loading it: timing,
/// segments, placement, the travel null and the image layers. The values
/// come from the JSON and LOTTIE.md's table and are generated into
/// `fx_spec.gen.dart` by `nesty_tools` (never written by hand); a drift
/// test keeps them equal to the shipped JSON.
///
/// Pure data: the board timeline times its clips, cues and input
/// reservations from these (m2-lottie-design §7), so it stays testable
/// without Flame or lottie.
final class FxSpec {
  const FxSpec({
    required this.id,
    required this.frames,
    required this.width,
    required this.height,
    required this.anchor,
    required this.kind,
    this.markers = const [],
    this.travel,
    this.roles = const [],
    this.imageLayers = const [],
    this.textLayers = const [],
    this.colorFills = const [],
    this.loops = false,
  }) : assert(frames > 0);

  /// Every file is 60 fps (LOTTIE.md "Format", checked at sync).
  static const double frameRate = 60;

  /// [frames] composition frames in ms at 1×.
  static double msOf(double frames) => frames * 1000 / frameRate;

  final FxId id;

  /// Length in frames (`op − ip`; every file starts at 0).
  final int frames;

  /// The canvas, in composition units (1 unit = 1 dp at 390×844).
  final double width;
  final double height;

  /// The point that goes on the game point (LOTTIE.md "Files" → Anchor),
  /// in canvas units. For [FxKind.boardSpace] files, `Offset.zero`: the
  /// canvas is placed by its top-left.
  final Offset anchor;

  final FxKind kind;

  /// Named segments, in frame order ([FxKind.segmented] files).
  final List<FxMarker> markers;

  /// The `travel` null ([FxKind.boardSpace] files).
  final FxTravel? travel;

  /// Roles whose `<role>_size` null the file has (LOTTIE.md "Doll size").
  final List<FxRole> roles;

  final List<FxImageLayer> imageLayers;

  /// Text layer names. The game hides them all and draws its own localized
  /// text (PROGRESS D44).
  final List<String> textLayers;

  /// Named fills the game recolours: `rim_tint`, `tint`.
  final List<String> colorFills;

  /// Loops for as long as it is shown (LOTTIE.md "Length": "loop").
  final bool loops;

  /// Length in ms at 1×.
  double get durationMs => msOf(frames.toDouble());

  /// The marker called [name], or null.
  FxMarker? marker(String name) {
    for (final m in markers) {
      if (m.name == name) return m;
    }
    return null;
  }

  @override
  String toString() => 'FxSpec(${id.fileName}, $frames f, ${kind.name})';
}
