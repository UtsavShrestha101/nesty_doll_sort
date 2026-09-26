import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The design's surfaces, from tokens.json `shadow` where it has the stack
/// and from the App Flow frames otherwise (the element is noted on each).
abstract final class SurfaceStyles {
  static const _white = Color(0xFFFFFFFF);
  static const _highlight = NestyShadow(color: _white, inset: true, dy: 2);

  /// Pills and icon buttons: tokens `shadow.raised` → `shadow.pressed`.
  static const raised = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: AppShadowTokens.raised,
    pressedShadows: AppShadowTokens.pressed,
  );

  /// The coin pill: a 4 px edge (NestyBoard HUD coin pill).
  static const coinPill = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      _highlight,
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
      NestyShadow(color: Color(0x335A3214), dy: 8, blur: 12),
    ],
  );

  /// Booster buttons: tokens `shadow.booster`.
  static const booster = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: AppShadowTokens.booster,
  );

  /// Modal cards: tokens `shadow.card`.
  static const card = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: AppShadowTokens.card,
  );

  /// Bottom sheets: tokens `shadow.sheet`.
  static const sheet = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: AppShadowTokens.sheet,
  );

  /// Sheet rows and Pause tiles: white, 5 px edge, no drop (NestyOverlay
  /// OOM rows, Pause Restart/Home/Settings tiles).
  static const row = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      _highlight,
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  /// The recommended sheet row: [row] plus a 3 px green ring (OOM +1 Slot).
  static const rowHighlighted = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      _highlight,
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
      NestyShadow(color: AppColorTokens.successRing, spread: 3),
    ],
  );

  /// A control that can't be used: flat, sunk, no edge (NestyOverlay 3.8
  /// disabled coin button). Used for every disabled tactile control.
  static const disabled = SurfaceStyle(
    color: AppColors.disabledFace,
    shadows: [
      NestyShadow(color: Color(0x2E5A2D0F), inset: true, dy: 2, blur: 3),
    ],
  );

  /// The 36 px close button: a 3 px inner bottom shade that shrinks to 1 px
  /// as it moves down 2 px (Design System "icon buttons").
  static const closeButton = SurfaceStyle(
    color: AppColors.closeFill,
    shadows: [NestyShadow(color: AppColors.closeShade, inset: true, dy: -3)],
    pressedShadows: [
      NestyShadow(color: AppColors.closeShade, inset: true, dy: -1),
    ],
    pressTravel: 2,
  );

  /// The compact coin price chip (NestyOverlay OOM +1 Slot row).
  static const coinChip = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.coinChipTop, AppColors.coinChipBottom],
    ),
    shadows: [NestyShadow(color: AppColors.coinChipEdge, dy: 4)],
  );

  /// The compact ▶ ad button (NestyOverlay OOM +1 Slot row).
  static const adChip = SurfaceStyle(
    gradient: AppGradientTokens.ad,
    shadows: [NestyShadow(color: AppColorTokens.adEdge, dy: 4)],
  );

  /// "Reward added" (NestyOverlay 2.9): flat lilac with a 2 px inner ring.
  static const adClaimed = SurfaceStyle(
    color: AppColors.adClaimedFace,
    shadows: [
      NestyShadow(color: AppColors.adClaimedRing, inset: true, spread: 2),
    ],
  );

  /// The progress bar's sunk track (NestyOverlay win card, NestyMenus
  /// splash loader).
  static const progressTrack = SurfaceStyle(
    color: AppColorTokens.surfaceTrack,
    shadows: AppShadowTokens.sunk,
  );
}
