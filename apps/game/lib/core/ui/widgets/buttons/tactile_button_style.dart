import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The colour families of the design's buttons (design/README.md
/// "Components", NestyOverlay/NestyMenus).
///
/// Primary and ad use their tokens.json `shadow.primaryButton` /
/// `shadow.adButton` drop. Success, danger and teal have no shadow token:
/// they take the same drop geometry in their own hue.
/// TODO(design): confirm the success/danger/teal drops (and a danger
/// button at all: no frame shows one; its colours come from the Hard pill).
enum TactileButtonVariant {
  /// Tangerine: Continue, Resume, Got it.
  primary(
    face: AppGradientTokens.primary,
    edgeColor: AppColorTokens.primaryEdge,
    highlight: Color(0x59FFFFFF),
    drop: Color(0x4D964614),
    foreground: Color(0xFFFFFFFF),
    textShadow: Color(0x59963C0A),
  ),

  /// Cream: Restart level, Back.
  secondary(
    face: AppGradientTokens.secondary,
    edgeColor: AppColorTokens.surfaceEdge,
    highlight: Color(0xFFFFFFFF),
    drop: Color(0x265A3214),
    dropDy: 8,
    dropBlur: 12,
    foreground: AppColors.iconBrown,
  ),

  /// Rewarded-ad purple (§9.1).
  ad(
    face: AppGradientTokens.ad,
    edgeColor: AppColorTokens.adEdge,
    highlight: Color(0x4DFFFFFF),
    drop: Color(0x4D5028A0),
    foreground: Color(0xFFFFFFFF),
    textShadow: Color(0x5932146E),
  ),

  /// Green: "Add a slot" (Design System sheet).
  success(
    face: AppGradientTokens.success,
    edgeColor: AppColorTokens.successEdge,
    highlight: Color(0x59FFFFFF),
    drop: Color(0x4D1E5A28),
    foreground: Color(0xFFFFFFFF),
    textShadow: Color(0x4D145023),
  ),

  /// Red, in the Hard pill's colours.
  danger(
    face: AppGradientTokens.hard,
    edgeColor: AppColorTokens.dangerEdge,
    highlight: Color(0x59FFFFFF),
    drop: Color(0x40961E1E),
    foreground: Color(0xFFFFFFFF),
    textShadow: Color(0x4D781419),
  ),

  /// Bonus teal: "Play Bonus Level 1" (frame 4.9).
  teal(
    face: AppGradientTokens.bonus,
    edgeColor: AppColorTokens.bonusEdge,
    highlight: Color(0x59FFFFFF),
    drop: Color(0x400A5A50),
    foreground: Color(0xFFFFFFFF),
    textShadow: Color(0x4D05463C),
  );

  const TactileButtonVariant({
    required this.face,
    required this.edgeColor,
    required this.highlight,
    required this.drop,
    required this.foreground,
    this.dropDy = 10,
    this.dropBlur = 18,
    this.textShadow,
  });

  final Gradient face;
  final Color edgeColor;

  /// The 2 px inner top highlight.
  final Color highlight;

  /// The soft drop shadow's colour, offset and blur.
  final Color drop;
  final double dropDy;
  final double dropBlur;

  /// Label and icon colour.
  final Color foreground;

  /// The label's `0 2px 0` text shadow, if any.
  final Color? textShadow;

  /// Secondary labels are Fredoka 600 (README "16–18/600"); the rest 700.
  FontWeight get fontWeight =>
      this == secondary ? FontWeight.w600 : FontWeight.w700;

  /// This variant's surface with an edge of [edge] px. Built once per
  /// (variant, edge) and reused.
  SurfaceStyle surface(double edge) => _cache[(this, edge)] ??= SurfaceStyle(
    gradient: face,
    shadows: [
      NestyShadow(color: highlight, inset: true, dy: 2),
      NestyShadow(color: edgeColor, dy: edge),
      NestyShadow(color: drop, dy: dropDy, blur: dropBlur),
    ],
  );

  static final Map<(TactileButtonVariant, double), SurfaceStyle> _cache = {};
}

/// Button sizes, from the frames:
/// * [large]: 58 tall, r22, 6 px edge, 21 px label (Win Continue, Got it).
/// * [medium]: 56, r20, 5 px, 20 px (Pause Resume, buy popup).
/// * [small]: 48, r18, 5 px, 17 px (Design System "Restart level").
/// * [compact]: 38, r14, 4 px, 15 px (the soft-stuck banner's Undo).
enum TactileButtonSize {
  large(
    height: 58,
    radius: 22,
    edge: 6,
    fontSize: 21,
    secondaryFontSize: 18,
    iconSize: 22,
    padding: 22,
  ),
  medium(
    height: 56,
    radius: 20,
    edge: 5,
    fontSize: 20,
    secondaryFontSize: 18,
    iconSize: 22,
    padding: 20,
  ),
  small(
    height: 48,
    radius: 18,
    edge: 5,
    fontSize: 17,
    secondaryFontSize: 17,
    iconSize: 21,
    padding: 18,
  ),
  compact(
    height: 38,
    radius: 14,
    edge: 4,
    fontSize: 15,
    secondaryFontSize: 15,
    iconSize: 20,
    padding: 14,
  );

  const TactileButtonSize({
    required this.height,
    required this.radius,
    required this.edge,
    required this.fontSize,
    required this.secondaryFontSize,
    required this.iconSize,
    required this.padding,
  });

  final double height;
  final double radius;

  /// The solid bottom edge at rest.
  final double edge;
  final double fontSize;
  final double secondaryFontSize;
  final double iconSize;

  /// Horizontal padding inside the face.
  final double padding;

  /// Icon (or leading glyph) to label gap.
  double get gap => this == compact ? 4 : 8;
}
