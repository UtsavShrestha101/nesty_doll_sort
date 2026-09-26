import 'dart:ui' show Color, Offset;

import 'package:nesty_game/features/fx/fx_image_source.dart';

/// The per-use inputs of one pooled drawable, read by its value delegates
/// on every draw (m2-lottie-design §2 rule 2: delegates are set once, when
/// the pooled clip is created; what changes per use lives here). Plus the
/// few values the delegates capture for the game while the clip draws (the
/// sparkle trail point, the text null's transform).
///
/// Every setter is per event (a clip started, a level laid out), never per
/// frame, and bumps [revision] so a recorded rest picture knows to
/// re-record. A null input means "as authored".
final class FxDrawableParams {
  /// Bumped by every input change; see `LottieFxComponent`'s rest picture.
  int get revision => _revision;
  int _revision = 0;

  /// Marks a change the setters can't see (the caller rewrote the clip's
  /// `FxImageRequest` fields of a resting clip).
  void markChanged() => _revision++;

  // ── Sizes (LOTTIE.md "Doll size"; m2-lottie-design §5). ──

  final List<Offset?> _sizes = List.filled(
    FxRole.values.length,
    null,
    growable: false,
  );

  /// The `<role>_size` null's scale, or null for the authored one.
  Offset? sizeOf(FxRole role) => _sizes[role.index];

  /// Sets `<role>_size` to [k] (1 = a 150-unit doll); null restores the
  /// authored scale. `FxLayout.applyDollHeights` computes the factors.
  void setSize(FxRole role, double? k) {
    _sizes[role.index] = k == null ? null : Offset(k, k);
    _revision++;
  }

  // ── Fills (LOTTIE.md "Doll size, rim and tint"). ──

  /// `rim_tint` (`doll_nest`, `doll_swallow`): the outer doll's
  /// `DollSwatch.rimColor` (gold: `#E9BE4E`).
  Color? get rimColor => _rimColor;
  set rimColor(Color? value) {
    _rimColor = value;
    _revision++;
  }

  Color? _rimColor;

  /// `tint`: `DollSwatch.base` in `doll_reveal`; `#FFF3B0` or `#F5B418` in
  /// `fx_twinkle`.
  Color? get tintColor => _tintColor;
  set tintColor(Color? value) {
    _tintColor = value;
    _revision++;
  }

  Color? _tintColor;

  // ── Board-space travel (m2-lottie-design §6), in reference units. ──

  /// Where the `travel` null starts (null: the authored S).
  Offset? get travelSrc => _travelSrc;
  Offset? _travelSrc;

  /// Where it ends (null: the authored T).
  Offset? get travelDst => _travelDst;
  Offset? _travelDst;

  /// Sets both travel points (reference units: `BoardFit.toReference`).
  void setTravel(Offset? src, Offset? dst) {
    _travelSrc = src;
    _travelDst = dst;
    _revision++;
  }

  /// `doll_invalid`'s `target_pos`: the target base (null: authored
  /// (300, 500)).
  Offset? get targetPos => _targetPos;
  set targetPos(Offset? value) {
    _targetPos = value;
    _revision++;
  }

  Offset? _targetPos;

  // ── Workarounds and motion. ──

  /// Reduced motion (D48): `doll_invalid`'s `target` and `fx_ice`'s `ice`
  /// shakes are held at rest.
  bool get reducedMotion => _reducedMotion;
  set reducedMotion(bool value) {
    if (value == _reducedMotion) return;
    _reducedMotion = value;
    _revision++;
  }

  bool _reducedMotion = false;

  /// `fx_glass_unlock`: blends the 11-unit settle onto the stand into the
  /// freed doll's last hop (m2-lottie-design §9.2). On by default; the
  /// fallback (a post-clip drop) turns it off.
  bool get unlockSettle => _unlockSettle;
  set unlockSettle(bool value) {
    if (value == _unlockSettle) return;
    _unlockSettle = value;
    _revision++;
  }

  bool _unlockSettle = true;

  // ── Captured while drawing (outputs, no revision). ──

  /// The remapped `travel` point of the last draw, in reference units (the
  /// canvas of a board-space file): where `fx_sparkle` spawns along the
  /// fly (m2-lottie-design §6 "Sparkle trail"). Null before a board-space
  /// clip has drawn.
  Offset? trailPoint;

  /// The text null's position and uniform scale in the last draw
  /// (`counter`, `ribbon`), reset to its rest values before each draw
  /// because a hold skips the position callback (m2-lottie-design §12).
  Offset textNullPosition = Offset.zero;
  double textNullScale = 1;

  /// Back to "as authored" (a clip returned to its pool).
  void reset() {
    for (var i = 0; i < _sizes.length; i++) {
      _sizes[i] = null;
    }
    _rimColor = null;
    _tintColor = null;
    _travelSrc = null;
    _travelDst = null;
    _targetPos = null;
    _unlockSettle = true;
    trailPoint = null;
    textNullPosition = Offset.zero;
    textNullScale = 1;
    _revision++;
  }
}
