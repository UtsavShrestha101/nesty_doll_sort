import 'dart:ui' show Color, Offset;

import 'package:flutter/animation.dart' show Curves;
import 'package:lottie/lottie.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_images.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_text_overlay.dart';

/// Builds the `LottieDelegates` of one drawable from its file's [FxSpec]
/// (m2-lottie-design §2–§13): every workaround for lottie 3.6.1 and the
/// export lives here, driven by mutable per-clip state.
///
/// Rules this follows (verified in docs/plans/lottie-analysis/):
/// - Built once per drawable, after `LottieDrawable(composition)` exists
///   (§2 rule 1), never swapped (rule 2): the closures read the clip's
///   [FxDrawableParams], [FxImages] and [FxPlayer], which change per use.
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
  /// `doll_reveal`: the colour doll covers the silhouette from the wipe's
  /// end (12 f, 200 ms); the silhouette is hidden from here so the ground
  /// shadow isn't drawn twice at the hand-off (m2-lottie-design §7).
  static const revealWipeEndFrame = 12.0;

  /// `doll_invalid`'s `target` null at rest (reduced motion holds it).
  static const invalidTargetRest = Offset.zero;

  /// `fx_ice`'s `ice` null at rest (the ice's top-left, LOTTIE.md).
  static const iceRest = Offset(42, 40);

  /// The delegates of one drawable of [spec]:
  /// - image slots from [images], each image layer's scale and anchor
  ///   compensated for the raster it gets (§3);
  /// - `<role>_size`, `rim_tint` and `tint` from [params] (§5);
  /// - the `travel` remap with the hold fix, and the sparkle trail (§6);
  /// - `doll_invalid`'s `target_pos`; the reduced-motion shake hold on
  ///   `target` and `ice` (§13);
  /// - `fx_glass_unlock`'s `padlock_ping` hidden at rest (§8) and the
  ///   11-unit settle (§9.2); `doll_reveal`'s silhouette hidden after the
  ///   wipe (§7);
  /// - text layers hidden, and the text null's transform captured (§12).
  static LottieDelegates build(
    FxSpec spec, {
    required FxDrawableParams params,
    required FxImages images,
    required FxPlayer player,
  }) {
    final values = <ValueDelegate<Object?>>[];

    for (final layer in spec.imageLayers) {
      final hook = _Compensation(layer, images);
      values
        ..add(
          ValueDelegate.transformScale(
            layer.keyPath,
            callback: (f) =>
                hook.scale(f.startValue, f.endValue, f.linearKeyframeProgress),
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

    final travel = spec.travel;
    if (travel != null) {
      final hook = _Travel(travel, params, player);
      values
        ..add(
          ValueDelegate.transformPosition(
            const ['travel'],
            callback: (f) => hook.position(
              f.startValue,
              f.endValue,
              f.interpolatedKeyframeProgress,
            ),
          ),
        )
        ..add(
          ValueDelegate.transformAnchorPoint(const [
            'travel',
          ], callback: (_) => hook.anchor()),
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
      case FxId.fxGlassUnlock:
        final settle = _Settle(params, player);
        values
          ..add(
            ValueDelegate.transformOpacity(
              const ['padlock_ping'],
              callback: (f) => player.isResting
                  ? 0
                  : _lerpInt(
                      f.startValue,
                      f.endValue,
                      f.linearKeyframeProgress,
                    ),
            ),
          )
          ..add(
            ValueDelegate.transformPosition(
              const ['doll'],
              callback: (f) => settle.position(
                f.startValue,
                f.endValue,
                f.interpolatedKeyframeProgress,
              ),
            ),
          );
      case FxId.dollReveal:
        values.add(
          ValueDelegate.transformOpacity(
            const ['doll_silhouette'],
            callback: (f) => player.frame >= revealWipeEndFrame
                ? 0
                : _lerpInt(f.startValue, f.endValue, f.linearKeyframeProgress),
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
/// draws (m2-lottie-design §3): scale `k / raster.scale`, anchor
/// `(a − raster.origin) × raster.scale`.
final class _Compensation {
  _Compensation(this.layer, this.images)
    : _scale = layer.scale,
      _anchor = layer.anchor;

  final FxImageLayer layer;
  final FxImages images;

  FxRaster? _raster;
  bool _synced = false;
  Offset _scale;
  Offset _anchor;

  Offset scale(Offset? start, Offset? end, double eased) {
    final raster = images.rasterFor(layer.slot);
    if (!layer.scaleAnimated) {
      _sync(raster);
      return _scale;
    }
    // The authored animated scale, divided by the raster's (C0 probe).
    final r = raster == null ? 1.0 : raster.scale;
    final s = start ?? layer.scale;
    final e = end ?? s;
    return Offset(
      (s.dx + (e.dx - s.dx) * eased) / r,
      (s.dy + (e.dy - s.dy) * eased) / r,
    );
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
    final r = raster == null ? 1.0 : raster.scale;
    final origin = raster == null ? Offset.zero : raster.origin;
    _scale = Offset(layer.scale.dx / r, layer.scale.dy / r);
    _anchor = Offset(
      (layer.anchor.dx - origin.dx) * r,
      (layer.anchor.dy - origin.dy) * r,
    );
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

/// The `travel` null of a board-space file (m2-lottie-design §6): the
/// position callback projects the authored point on S→T and maps it onto
/// src→dst, keeping the easing and overshoot; where lottie skips it (a
/// hold), the anchor callback moves the null onto the remapped hold point.
final class _Travel {
  _Travel(this.travel, this.params, this.player)
    : _dx = travel.t.dx - travel.s.dx,
      _dy = travel.t.dy - travel.s.dy,
      _invLength2 =
          1 /
          ((travel.t.dx - travel.s.dx) * (travel.t.dx - travel.s.dx) +
              (travel.t.dy - travel.s.dy) * (travel.t.dy - travel.s.dy));

  final FxTravel travel;
  final FxDrawableParams params;
  final FxPlayer player;
  final double _dx;
  final double _dy;
  final double _invLength2;

  /// Set by [position], read and cleared by [anchor]: `getMatrix` reads a
  /// layer's position before its anchor, so an unset flag means lottie
  /// returned a held keyframe without calling [position] (probe T10).
  bool _ran = false;

  FxHold? _hold;
  Offset? _holdSrc;
  Offset? _holdDst;
  Offset _holdAnchor = Offset.zero;
  Offset _holdPoint = Offset.zero;

  Offset position(Offset? start, Offset? end, double eased) {
    _ran = true;
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

  Offset anchor() {
    if (_ran) {
      _ran = false;
      return Offset.zero;
    }
    final hold = travel.nearestHold(player.frame);
    if (hold == null) return Offset.zero;
    final src = params.travelSrc ?? travel.s;
    final dst = params.travelDst ?? travel.t;
    if (!identical(hold, _hold) ||
        !identical(src, _holdSrc) ||
        !identical(dst, _holdDst)) {
      _syncHold(hold, src, dst);
    }
    params.trailPoint = _holdPoint;
    return _holdAnchor;
  }

  void _syncHold(FxHold hold, Offset src, Offset dst) {
    // ── End of hot path. ── (once per hold and travel change)
    _hold = hold;
    _holdSrc = src;
    _holdDst = dst;
    _holdPoint = travel.remap(hold.value, src, dst);
    // The null stays at the held keyframe `v`, so translating by −a with
    // a = v − remap(v) puts it on remap(v).
    _holdAnchor = hold.value - _holdPoint;
    // ── Hot path: resumed. ──
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

/// `fx_glass_unlock`'s `doll` null: the authored hop plus the 11-unit
/// settle, eased in over the last hop (m2-lottie-design §9.2), so the file
/// ends with the doll on the stand surface where its sprite rests. Frames
/// 0–42 are a hold (no callback), where the settle is 0 anyway.
final class _Settle {
  _Settle(this.params, this.player);

  final FxDrawableParams params;
  final FxPlayer player;

  static const _start = FxTiming.unlockHopStartFrame;
  static const _span =
      FxTiming.unlockHopEndFrame - FxTiming.unlockHopStartFrame;

  Offset position(Offset? start, Offset? end, double eased) {
    final s = start ?? Offset.zero;
    final e = end ?? s;
    final x = s.dx + (e.dx - s.dx) * eased;
    final y = s.dy + (e.dy - s.dy) * eased;
    final t = (player.frame - _start) / _span;
    if (!params.unlockSettle || t <= 0) return Offset(x, y);
    final k = Curves.easeInOut.transform(t >= 1 ? 1 : t);
    return Offset(x, y + FxTiming.unlockSettleUnits * k);
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

int _lerpInt(int? start, int? end, double eased) {
  if (start == null) return 100;
  if (end == null || end == start) return start;
  return (start + (end - start) * eased).round();
}

// ── End of hot path. ──
