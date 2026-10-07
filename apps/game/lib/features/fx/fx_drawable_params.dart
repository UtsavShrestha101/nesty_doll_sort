import 'dart:ui' show Color, Offset;

import 'package:nesty_game/core/ui/tokens/ui_token_types.dart'
    show RibbonColors;
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
  /// [stretchY] compensates a host that stretches the whole composition
  /// vertically (the tall ice, 1.05): the height factor is `k / stretchY`,
  /// so the doll keeps its proportions.
  void setSize(FxRole role, double? k, {double stretchY = 1}) {
    _sizes[role.index] = k == null ? null : Offset(k, k / stretchY);
    _revision++;
  }

  /// `fx_glass_unlock_tall`'s `case_size` null (`FxSpec.scaleNulls`; m7-3
  /// LOTTIE.md "= the case_size null"): the tall case scales with the sealed
  /// doll, `h / (150 · fs)` like `doll_size` (phase 4 architecture §2.3).
  /// Null keeps the authored scale. Lane B's delegate reads it.
  double? get caseScale => _caseScale;
  set caseScale(double? value) {
    if (value == _caseScale) return;
    _caseScale = value;
    _caseScaleOffset = value == null ? null : Offset(value, value);
    _revision++;
  }

  double? _caseScale;
  Offset? _caseScaleOffset;

  /// [caseScale] as the delegate's value (built once when it is set).
  Offset? get caseScaleOffset => _caseScaleOffset;

  /// The padlock's ping (E.13): the unlock symbol's scale (its image layer's,
  /// about its own anchor) is multiplied by this while a tap on a sealed case
  /// plays (1 = as authored, up to 1.15 and back over 160 ms). The golden
  /// lock is part of the case's art, so it stays.
  double get padlockPing => _padlockPing;
  set padlockPing(double value) {
    if (value == _padlockPing) return;
    _padlockPing = value;
    _revision++;
  }

  double _padlockPing = 1;

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

  // ── Named tint fills and widths (LOTTIE.md "Tint and width"; m7-4). ──

  /// The colour the clip gives the fill [name] (`FxSpec.tintFills`: a
  /// ribbon's `band_fill`, `edge_fill`, `tail_fill`, `fold_fill`, the family
  /// counter's `pill_fill`), or null for the authored one. `hi_fill` stays
  /// as authored (white).
  Color? tintOf(String name) => _tints[name];

  /// Sets or clears one tint fill.
  void setTint(String name, Color? color) {
    if (color == null) {
      if (_tints.remove(name) == null) return;
    } else {
      if (_tints[name] == color) return;
      _tints[name] = color;
    }
    _revision++;
  }

  final Map<String, Color> _tints = {};

  /// Recolours a ribbon (`ui_win_ribbon`, `ui_chapter_ribbon`) by its four
  /// named fills; null restores the authored colours. A ribbon is built from
  /// named fills, not a colour matrix (m7-4 4.3, 4.15).
  void setRibbonColors(RibbonColors? colors) {
    setTint('band_fill', colors?.band);
    setTint('edge_fill', colors?.edge);
    setTint('tail_fill', colors?.tail);
    setTint('fold_fill', colors?.fold);
  }

  /// The family counter's pill width (`pill_rect` and `glow_rect` through
  /// `rectangleSize`, the doll mark moved with it); null keeps the authored
  /// 70.
  double? get pillWidth => _pillWidth;
  set pillWidth(double? value) {
    if (value == _pillWidth) return;
    _pillWidth = value;
    _revision++;
  }

  double? _pillWidth;

  /// A ribbon's band width (`ui_win_ribbon`, `ui_chapter_ribbon`; LOTTIE.md
  /// m7-5): `band_rect` and `edge_rect` take it, `hi_rect` stays 16 dp
  /// narrower and `tail_l` / `tail_r` move by the half-difference, so the
  /// tails stay 22 dp past the band. Null keeps the authored band (290 and
  /// 336). `FxRibbon.bandWidthFor` gives the screen's.
  double? get ribbonBandWidth => _ribbonBandWidth;
  set ribbonBandWidth(double? value) {
    if (value == _ribbonBandWidth) return;
    _ribbonBandWidth = value;
    _revision++;
  }

  double? _ribbonBandWidth;

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

  /// `doll_reveal`'s `drop` null: how far above the stand the new top
  /// starts, in composition units — the tower's own step for a nest buried
  /// at depth 1, `(surfaceY − buriedBaseY(1)) / s` (LOTTIE.md v3 "Reveal
  /// drop"). Null: the authored 18 (`FxTiming.revealDropUnits`).
  double? get revealDropUnits => _revealDropUnits;
  set revealDropUnits(double? value) {
    if (value == _revealDropUnits) return;
    _revealDropUnits = value;
    _revision++;
  }

  double? _revealDropUnits;

  // ── The wobble's hand-off to the move (m7-5 item 14). ──

  /// `doll_move`'s starting tilt, in degrees: the angle the dropped doll's
  /// `doll_pick` wobble showed. Its `doll` null eases from this to 0 over
  /// the move's first `MotionTokens.pickWobbleToMoveMs` (80 ms, easeOut),
  /// overlapping the flight, so the move starts at once and never snaps.
  /// Null: as authored (no tilt).
  double? get unwindFrom => _unwindFrom;
  set unwindFrom(double? value) {
    if (value == _unwindFrom) return;
    _unwindFrom = value;
    _revision++;
  }

  double? _unwindFrom;

  // ── Motion. ──

  /// Reduced motion (D48): `doll_invalid`'s `target` and `fx_ice`'s `ice`
  /// shakes are held at rest.
  bool get reducedMotion => _reducedMotion;
  set reducedMotion(bool value) {
    if (value == _reducedMotion) return;
    _reducedMotion = value;
    _revision++;
  }

  bool _reducedMotion = false;

  // ── Captured while drawing (outputs, no revision). ──

  /// The remapped `travel` point of the last draw, in reference units (the
  /// canvas of a board-space file): where `fx_sparkle` spawns along the
  /// fly (m2-lottie-design §6 "Sparkle trail"). Null before a board-space
  /// clip has drawn.
  Offset? trailPoint;

  /// The text null's position and uniform scale in the last draw
  /// (`counter`, `ribbon`), reset to its rest values before each draw
  /// because a hold skips the position callback (m2-lottie-design §12):
  /// `ui_chapter_ribbon`'s `ribbon` null holds from 0 to 138.
  Offset textNullPosition = Offset.zero;
  double textNullScale = 1;

  /// `doll_pick`'s `doll` null rotation (degrees) in the last draw: the
  /// wobble's angle, handed to the `doll_move` that takes over on a drop
  /// ([unwindFrom]).
  double pickRotation = 0;

  /// The composition frame the clip draws, set by `FxDrawable.draw` before
  /// each draw: the clock of a hook timed in the clip ([unwindFrom]).
  double frame = 0;

  /// Back to "as authored" (a clip returned to its pool).
  void reset() {
    for (var i = 0; i < _sizes.length; i++) {
      _sizes[i] = null;
    }
    _rimColor = null;
    _tintColor = null;
    _tints.clear();
    _pillWidth = null;
    _ribbonBandWidth = null;
    _travelSrc = null;
    _travelDst = null;
    _targetPos = null;
    _revealDropUnits = null;
    _caseScale = null;
    _caseScaleOffset = null;
    _padlockPing = 1;
    trailPoint = null;
    textNullPosition = Offset.zero;
    textNullScale = 1;
    _unwindFrom = null;
    pickRotation = 0;
    frame = 0;
    _revision++;
  }
}
