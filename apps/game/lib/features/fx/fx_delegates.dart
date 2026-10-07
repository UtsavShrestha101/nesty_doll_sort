import 'dart:ui' show Color, Offset;

import 'package:lottie/lottie.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_images.dart';
import 'package:nesty_game/features/fx/fx_ribbon.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_text_overlay.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// Builds the `LottieDelegates` of one drawable from its file's [FxSpec]
/// (m2-lottie-design §2–§13): everything the game overrides in the export
/// lives here, driven by mutable per-clip state.
///
/// Since LOTTIE.md v3 the export needs no workaround: no `travel` or `drop`
/// null holds, no image layer animates its transform, `padlock_ping` starts
/// at frame 1, the freed doll lands on the stand at frame 53 and
/// `doll_silhouette` ends when the wipe covers it (the sync rejects a file
/// that breaks any of these). What stays is what the game supplies: raster
/// compensation, doll sizes, colours, the remapped `travel`, the `drop`
/// start, the reduced-motion shake holds and the hidden text.
///
/// Rules this follows (verified in docs/plans/lottie-analysis/):
/// - Built once per drawable, after `LottieDrawable(composition)` exists
///   (§2 rule 1), never swapped (rule 2): the closures read the clip's
///   [FxDrawableParams] and [FxImages], which change per use.
/// - Never shared: every call makes new `ValueDelegate`s (rule 3).
/// - `LottieFrameInfo` isn't exported, so every callback is a closure with
///   an inferred parameter that forwards plain values to a typed hook
///   (rule 4).
/// - A path position's eased progress is `interpolatedKeyframeProgress`;
///   for scale, opacity and colour lottie 3.6.1 swaps the two fields and
///   the eased value is `linearKeyframeProgress` (rule 5, pinned by the
///   equivalence tests).
/// - A callback that must return a new `Offset` allocates it (PROGRESS
///   D42); everything static is cached and returned as the same object.
abstract final class FxDelegates {
  /// `doll_invalid`'s `target` null at rest (reduced motion holds it).
  static const invalidTargetRest = Offset.zero;

  /// `fx_ice`'s `ice` null at rest (the ice's top-left, LOTTIE.md).
  static const iceRest = Offset(42, 40);

  /// The delegates of one drawable of [spec]:
  /// - image slots from [images], each image layer's static scale and
  ///   anchor compensated for the raster it gets (§3);
  /// - `<role>_size`, `rim_tint` and `tint` from [params] (§5);
  /// - the `travel` remap and the sparkle trail (§6);
  /// - `doll_invalid`'s `target_pos`; the reduced-motion shake hold on
  ///   `target` and `ice` (§13);
  /// - `doll_reveal`'s `drop` start for the tower's step (§9.1);
  /// - text layers hidden, and the text null's transform captured (§12).
  static LottieDelegates build(
    FxSpec spec, {
    required FxDrawableParams params,
    required FxImages images,
  }) {
    final values = <ValueDelegate<Object?>>[];

    for (final layer in spec.imageLayers) {
      final hook = _Compensation(layer, images, params);
      values
        ..add(
          ValueDelegate.transformScale(
            layer.keyPath,
            callback: (_) => hook.scale(),
          ),
        )
        ..add(
          ValueDelegate.transformAnchorPoint(
            layer.keyPath,
            callback: (_) => hook.anchor(),
          ),
        );
    }

    for (final role in spec.roles) {
      final hook = _Size(role, params);
      values.add(
        ValueDelegate.transformScale([
          '${role.name}_size',
        ], callback: (f) => hook.scale(f.startValue)),
      );
    }

    // The scale nulls a whole piece hangs from (`fx_glass_unlock_tall`'s
    // `case_size`): the clip's factor, or the authored scale.
    for (final name in spec.scaleNulls) {
      final hook = _CaseSize(params);
      values.add(
        ValueDelegate.transformScale([
          name,
        ], callback: (f) => hook.scale(f.startValue)),
      );
    }

    for (final fill in spec.colorFills) {
      final hook = _Fill(fill, params);
      values.add(
        ValueDelegate.color(
          ['**', fill],
          callback: (f) =>
              hook.color(f.startValue, f.endValue, f.linearKeyframeProgress),
        ),
      );
    }

    // The named fills the game recolours (a ribbon's four, the counter's
    // pill): the clip's colour, or the authored one.
    for (final fill in spec.tintFills) {
      final hook = _TintFill(fill, params);
      values.add(
        ValueDelegate.color(
          ['**', fill],
          callback: (f) =>
              hook.color(f.startValue, f.endValue, f.linearKeyframeProgress),
        ),
      );
    }

    // A ribbon's band takes the screen's width through its named rects, and
    // its tails move with the band's ends (LOTTIE.md m7-5).
    final ribbon = FxRibbon.of(spec.id);
    if (ribbon != null && spec.sizedRects.isNotEmpty) {
      for (final keyPath in const [
        WinRibbonTokens.bandRectKeyPath,
        WinRibbonTokens.edgeRectKeyPath,
        WinRibbonTokens.hiRectKeyPath,
      ]) {
        final hook = _RibbonRect(ribbon, params);
        values.add(
          ValueDelegate.rectangleSize(
            keyPath,
            callback: (f) => hook.size(f.startValue),
          ),
        );
      }
      for (final (name, side) in const [('tail_l', -1.0), ('tail_r', 1.0)]) {
        final hook = _RibbonTail(ribbon, side, params);
        values.add(
          ValueDelegate.transformPosition([
            name,
          ], callback: (f) => hook.position(f.startValue)),
        );
      }
    } else if (spec.sizedRects.isNotEmpty) {
      // The family counter's pill takes any width: both rectangles and the
      // doll mark (LOTTIE.md "Tint and width"). The radius stays 13.
      final hook = _PillWidth(params);
      for (final rect in spec.sizedRects) {
        values.add(
          ValueDelegate.rectangleSize([
            '**',
            rect,
          ], callback: (f) => hook.size(f.startValue)),
        );
      }
      values.add(
        ValueDelegate.transformPosition(const [
          'icon',
        ], callback: (f) => hook.icon(f.startValue)),
      );
    }

    final travel = spec.travel;
    if (travel != null) {
      final hook = _Travel(travel, params);
      values.add(
        ValueDelegate.transformPosition(
          const ['travel'],
          callback: (f) => hook.position(
            f.startValue,
            f.endValue,
            f.interpolatedKeyframeProgress,
          ),
        ),
      );
    }

    switch (spec.id) {
      case FxId.dollInvalid:
        final target = _Static(() => params.targetPos);
        final shake = _Shake(invalidTargetRest, params);
        values
          ..add(
            ValueDelegate.transformPosition(const [
              'target_pos',
            ], callback: (f) => target.position(f.startValue)),
          )
          ..add(
            ValueDelegate.transformPosition(
              const ['target'],
              callback: (f) => shake.position(
                f.startValue,
                f.endValue,
                f.interpolatedKeyframeProgress,
              ),
            ),
          );
      case FxId.fxIce:
        final shake = _Shake(iceRest, params);
        values.add(
          ValueDelegate.transformPosition(
            const ['ice'],
            callback: (f) => shake.position(
              f.startValue,
              f.endValue,
              f.interpolatedKeyframeProgress,
            ),
          ),
        );
      case FxId.dollPick:
        // The wobble's angle, captured for the move that takes over (m7-5).
        final tilt = _PickTilt(params);
        values.add(
          ValueDelegate.transformRotation(
            const ['doll'],
            callback: (f) => tilt.rotation(
              f.startValue,
              f.endValue,
              f.linearKeyframeProgress,
            ),
          ),
        );
      case FxId.dollMove:
        final unwind = _Unwind(params);
        values.add(
          ValueDelegate.transformRotation(const [
            'doll',
          ], callback: (f) => unwind.rotation(f.startValue)),
        );
      case FxId.dollReveal:
        final drop = _Drop(params);
        values.add(
          ValueDelegate.transformPosition(
            const ['drop'],
            callback: (f) => drop.position(
              f.startValue,
              f.endValue,
              f.interpolatedKeyframeProgress,
            ),
          ),
        );
      default:
        break;
    }

    final text = FxTextHook.of(spec.id);
    if (text != null) {
      final hook = _TextCapture(params);
      values
        ..add(
          ValueDelegate.transformPosition(
            [text.nullName],
            callback: (f) => hook.position(
              f.startValue,
              f.endValue,
              f.interpolatedKeyframeProgress,
            ),
          ),
        )
        ..add(
          ValueDelegate.transformScale(
            [text.nullName],
            callback: (f) =>
                hook.scale(f.startValue, f.endValue, f.linearKeyframeProgress),
          ),
        );
    }

    return LottieDelegates(
      image: images.delegate,
      text: spec.textLayers.isEmpty ? null : _hideText,
      values: values,
    );
  }

  /// Every text layer draws no characters (PROGRESS D44): no per-character
  /// `TextPainter` layouts either (m2-lottie-design §12).
  static String _hideText(String authored) => '';
}

const _unitScale = Offset(1, 1);
const _white = Color(0xFFFFFFFF);

// ── Hot path: the delegate hooks, evaluated on every draw (several times
// per frame per clip). Cached values are returned as the same object; the
// `Offset(…)`s left are the new values lottie's callbacks must return
// (PROGRESS D42). ──

/// Scale and anchor compensation of one image layer for the raster it
/// draws (m2-lottie-design §3). The raster counts in box units and the
/// layer in asset px, [FxImageSlot.density] of them per box unit (3 for the
/// board pieces since LOTTIE.md v3). With `r = raster.scale / density` (raster
/// px per asset px): scale `k / r`, anchor `(a − origin × density) × r`.
/// The layer's own transform is static (LOTTIE.md v3), so both are
/// recomputed only when the slot's raster changes.
final class _Compensation {
  _Compensation(this.layer, this.images, this.params)
    : _density = layer.slot.density,
      _scale = layer.scale,
      _anchor = layer.anchor,
      _pings = layer.slot == FxImageSlot.unlockSymbol;

  final FxImageLayer layer;
  final FxImages images;
  final FxDrawableParams params;
  final double _density;

  /// The padlock's symbol pings when its slot is tapped (E.13): its scale is
  /// multiplied by `FxDrawableParams.padlockPing` about its own anchor.
  final bool _pings;

  FxRaster? _raster;
  bool _synced = false;
  Offset _scale;
  Offset _anchor;

  Offset scale() {
    _sync(images.rasterFor(layer.slot));
    if (_pings) {
      final ping = params.padlockPing;
      if (ping != 1) return Offset(_scale.dx * ping, _scale.dy * ping);
    }
    return _scale;
  }

  Offset anchor() {
    _sync(images.rasterFor(layer.slot));
    return _anchor;
  }

  void _sync(FxRaster? raster) {
    if (_synced && identical(raster, _raster)) return;
    _raster = raster;
    _synced = true;
    _recompute(raster);
  }

  void _recompute(FxRaster? raster) {
    // ── End of hot path. ── (only when the slot's raster changes)
    if (raster == null) {
      // The 1×1 blank draws nothing wherever it goes.
      _scale = layer.scale;
      _anchor = layer.anchor;
      return;
    }
    final r = raster.scale / _density;
    final ox = raster.origin.dx * _density;
    final oy = raster.origin.dy * _density;
    _scale = Offset(layer.scale.dx / r, layer.scale.dy / r);
    _anchor = Offset((layer.anchor.dx - ox) * r, (layer.anchor.dy - oy) * r);
    // ── Hot path: resumed. ──
  }
}

/// A `<role>_size` null: the clip's size factor, or the authored scale.
final class _Size {
  _Size(this.role, this.params);

  final FxRole role;
  final FxDrawableParams params;

  Offset scale(Offset? authored) =>
      params.sizeOf(role) ?? authored ?? _unitScale;
}

/// A scale null the clip sizes as a whole (`case_size`): its factor, or the
/// authored scale.
final class _CaseSize {
  _CaseSize(this.params);

  final FxDrawableParams params;

  Offset scale(Offset? authored) =>
      params.caseScaleOffset ?? authored ?? _unitScale;
}

/// A named fill (`rim_tint`, `tint`): the clip's colour, or the authored.
final class _Fill {
  _Fill(String name, this.params) : _rim = name == 'rim_tint';

  final FxDrawableParams params;
  final bool _rim;

  Color color(Color? start, Color? end, double eased) {
    final override = _rim ? params.rimColor : params.tintColor;
    if (override != null) return override;
    if (start == null) return _white;
    if (end == null || end == start) return start;
    // Never reached by the shipped files (every rim/tint fill is static).
    return Color.lerp(start, end, eased) ?? start;
  }
}

/// A named fill the game recolours (`FxSpec.tintFills`): the clip's colour,
/// or the authored one.
final class _TintFill {
  _TintFill(this.name, this.params);

  final String name;
  final FxDrawableParams params;

  Color color(Color? start, Color? end, double eased) {
    final override = params.tintOf(name);
    if (override != null) return override;
    if (start == null) return _white;
    if (end == null || end == start) return start;
    return Color.lerp(start, end, eased) ?? start;
  }
}

/// The family counter's width (`pill_rect`, `glow_rect` and the `icon` null):
/// the hugged width, or the authored 70. The values are built once per
/// width (a callback must return a new [Offset], PROGRESS D42).
final class _PillWidth {
  _PillWidth(this.params);

  final FxDrawableParams params;

  /// The authored rectangle's height; the width is the one we set.
  static const _height = 26.0;

  /// The doll mark sits 14 dp in from the pill's left edge (LOTTIE.md).
  static const _iconInset = 14.0;

  double? _width;
  Offset _size = Offset.zero;
  Offset _icon = Offset.zero;

  Offset size(Offset? authored) {
    final width = params.pillWidth;
    if (width == null) return authored ?? const Offset(70, _height);
    _sync(width);
    return _size;
  }

  Offset icon(Offset? authored) {
    final width = params.pillWidth;
    if (width == null) return authored ?? const Offset(-21, 0);
    _sync(width);
    return _icon;
  }

  void _sync(double width) {
    if (_width == width) return;
    _width = width;
    _size = Offset(width, _height);
    _icon = Offset(-width / 2 + _iconInset, 0);
  }
}

/// One of a ribbon's named rects (`band_rect`, `edge_rect`, `hi_rect`) for
/// the clip's band width: the authored size widened or narrowed by the
/// band's difference, so the highlight stays 16 narrower. The value is built
/// once per width (PROGRESS D42).
final class _RibbonRect {
  _RibbonRect(this.ribbon, this.params);

  final FxRibbon ribbon;
  final FxDrawableParams params;

  double? _width;
  Offset? _authored;
  Offset _size = Offset.zero;

  Offset size(Offset? authored) {
    final width = params.ribbonBandWidth;
    if (width == null || authored == null) {
      return authored ?? Offset(ribbon.band.width, ribbon.band.height);
    }
    if (_width != width || _authored != authored) {
      _width = width;
      _authored = authored;
      _size = Offset(authored.dx + width - ribbon.band.width, authored.dy);
    }
    return _size;
  }
}

/// A ribbon's tail layer (`tail_l` [side] −1, `tail_r` +1) moved with the
/// band's end: by ±(width − authored band) / 2 from its authored place.
final class _RibbonTail {
  _RibbonTail(this.ribbon, this.side, this.params);

  final FxRibbon ribbon;
  final double side;
  final FxDrawableParams params;

  double? _width;
  Offset? _authored;
  Offset _position = Offset.zero;

  Offset position(Offset? authored) {
    final width = params.ribbonBandWidth;
    final at = authored ?? Offset.zero;
    if (width == null) return at;
    if (_width != width || _authored != at) {
      _width = width;
      _authored = at;
      _position = Offset(at.dx + side * (width - ribbon.band.width) / 2, at.dy);
    }
    return _position;
  }
}

/// The `travel` null of a board-space file (m2-lottie-design §6): the
/// authored point projected on S→T and mapped onto src→dst, keeping the
/// easing and overshoot. The null never holds (LOTTIE.md v3), so lottie
/// calls this on every frame and the remapped point is also the sparkle
/// trail's.
final class _Travel {
  _Travel(this.travel, this.params)
    : _dx = travel.t.dx - travel.s.dx,
      _dy = travel.t.dy - travel.s.dy,
      _invLength2 =
          1 /
          ((travel.t.dx - travel.s.dx) * (travel.t.dx - travel.s.dx) +
              (travel.t.dy - travel.s.dy) * (travel.t.dy - travel.s.dy));

  final FxTravel travel;
  final FxDrawableParams params;
  final double _dx;
  final double _dy;
  final double _invLength2;

  Offset position(Offset? start, Offset? end, double eased) {
    final s = start ?? travel.s;
    final e = end ?? s;
    final vx = s.dx + (e.dx - s.dx) * eased;
    final vy = s.dy + (e.dy - s.dy) * eased;
    final u =
        ((vx - travel.s.dx) * _dx + (vy - travel.s.dy) * _dy) * _invLength2;
    final src = params.travelSrc ?? travel.s;
    final dst = params.travelDst ?? travel.t;
    final point = Offset(
      src.dx + (dst.dx - src.dx) * u,
      src.dy + (dst.dy - src.dy) * u,
    );
    params.trailPoint = point;
    return point;
  }
}

/// A static position the clip overrides (`target_pos`).
final class _Static {
  _Static(this.read);

  final Offset? Function() read;

  static const _authoredFallback = Offset.zero;

  Offset position(Offset? authored) => read() ?? authored ?? _authoredFallback;
}

/// A shaking null (`doll_invalid`'s `target`, `fx_ice`'s `ice`): the
/// authored path, or held at [rest] under reduced motion (D48).
final class _Shake {
  _Shake(this.rest, this.params);

  final Offset rest;
  final FxDrawableParams params;

  Offset position(Offset? start, Offset? end, double eased) {
    if (params.reducedMotion) return rest;
    return _lerp(start, end, eased, rest);
  }
}

/// `doll_reveal`'s `drop` null (LOTTIE.md v3 "Reveal drop"): the authored
/// (0, −18) → (0, 0) over frames 0–7, stretched to the tower's own step
/// (`FxDrawableParams.revealDropUnits`), so the new top starts exactly where
/// its buried silhouette stood and keeps the authored easing.
final class _Drop {
  _Drop(this.params);

  final FxDrawableParams params;

  static const _authored = FxTiming.revealDropUnits;

  Offset position(Offset? start, Offset? end, double eased) {
    final units = params.revealDropUnits;
    if (units == null) return _lerp(start, end, eased, Offset.zero);
    if (start == null) return Offset.zero;
    // One Offset per call (the callback's type, D42): the lerp and the
    // stretch in one step.
    final k = units / _authored;
    final to = end ?? start;
    return Offset(
      (start.dx + (to.dx - start.dx) * eased) * k,
      (start.dy + (to.dy - start.dy) * eased) * k,
    );
  }
}

/// `doll_pick`'s `doll` null rotation, returned unchanged and captured for
/// the `doll_move` a drop hands over to (m7-5 item 14). For a double,
/// lottie 3.6.1 passes the eased progress in `linearKeyframeProgress`
/// (rule 5).
final class _PickTilt {
  _PickTilt(this.params);

  final FxDrawableParams params;

  double rotation(double? start, double? end, double eased) {
    final from = start ?? 0;
    final to = end ?? from;
    final v = from + (to - from) * eased;
    params.pickRotation = v;
    return v;
  }
}

/// `doll_move`'s `doll` null: the dropped doll's wobble angle
/// (`FxDrawableParams.unwindFrom`) easing to 0 over the move's first
/// `MotionTokens.pickWobbleToMoveMs` (easeOut), on top of the authored 0;
/// the travel, arc and scale run as authored from the first frame. Timed in
/// the clip's own frames, so a late start or a seek stays in step.
final class _Unwind {
  _Unwind(this.params);

  final FxDrawableParams params;

  /// 80 ms in the file's 60 fps frames (4.8).
  static const double _frames =
      MotionTokens.pickWobbleToMoveMs * FxSpec.frameRate / 1000;

  double rotation(double? authored) {
    final base = authored ?? 0;
    final from = params.unwindFrom;
    if (from == null || from == 0) return base;
    final t = params.frame / _frames;
    if (t >= 1) return base;
    if (t <= 0) return base + from;
    return base + from * (1 - MotionTokens.pickWobbleToMoveCurve.transform(t));
  }
}

/// The text null's transform, returned unchanged and captured for the
/// Flutter label (m2-lottie-design §12).
final class _TextCapture {
  _TextCapture(this.params);

  final FxDrawableParams params;

  Offset position(Offset? start, Offset? end, double eased) {
    final v = _lerp(start, end, eased, params.textNullPosition);
    params.textNullPosition = v;
    return v;
  }

  Offset scale(Offset? start, Offset? end, double eased) {
    final v = _lerp(start, end, eased, _unitScale);
    params.textNullScale = v.dx;
    return v;
  }
}

/// `start → end` at [eased]; [start] itself when the value holds (no
/// allocation), [fallback] when lottie passed no value.
Offset _lerp(Offset? start, Offset? end, double eased, Offset fallback) {
  if (start == null) return fallback;
  if (end == null || end == start) return start;
  return Offset(
    start.dx + (end.dx - start.dx) * eased,
    start.dy + (end.dy - start.dy) * eased,
  );
}

// ── End of hot path. ──
