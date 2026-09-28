import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/ad_play_glyph.dart';
import 'package:nesty_game/core/ui/widgets/number/nesty_number_text.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Home tile: 132 tall, radius 24, surface, 5px edge. 58px colored icon
/// tile plus 15/700 label. Streak badge (flame + number) sits at top-right"
/// (design/README.md "Components"; frame 2.1's Daily Puzzle, Museum and
/// Remove Ads tiles).
///
/// [leading] is the tile's own art (a [HomeTileIcon] for Daily/Remove Ads,
/// or the museum's figurine art), [footer] an optional line under the label
/// (the museum's "15/20" bar). [badge] overlays the top-right corner (a
/// [StreakBadge]); it is hidden while [locked].
///
/// TODO(design): no frame shows the locked Daily tile (before Level 2, Q67).
/// [locked] dims the tile, disables the tap and shows a small lock glyph
/// where the streak badge would sit.
class HomeTile extends StatelessWidget {
  const HomeTile({
    required this.leading,
    required this.label,
    required this.onTap,
    this.footer,
    this.badge,
    this.locked = false,
    this.semanticLabel,
    super.key,
  });

  final Widget leading;
  final String label;
  final VoidCallback? onTap;
  final Widget? footer;
  final Widget? badge;
  final bool locked;
  final String? semanticLabel;

  static const double height = 132;
  static const double _radius = 24;
  static const double _lockedOpacity = 0.55;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
      NestyShadow(color: Color(0x335A3214), dy: 10, blur: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final content = Opacity(
      opacity: locked ? _lockedOpacity : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 15,
              color: AppColorTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          if (footer != null) ...[const SizedBox(height: 5), footer],
        ],
      ),
    );
    final tile = TactileSurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(_radius)),
      onPressed: locked ? null : onTap,
      width: double.infinity,
      height: height,
      semanticLabel: semanticLabel ?? label,
      excludeChildSemantics: true,
      child: content,
    );
    final badge = this.badge;
    if (badge == null && !locked) return tile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        PositionedDirectional(
          end: -6,
          top: -10,
          child: IgnorePointer(child: locked ? const _LockBadge() : badge!),
        ),
      ],
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  static const _style = SurfaceStyle(
    color: AppColors.closeFill,
    shadows: [NestyShadow(color: AppColors.closeShade, inset: true, dy: -3)],
  );

  @override
  Widget build(BuildContext context) => const NestySurface(
    style: _style,
    radius: BorderRadius.all(Radius.circular(15)),
    width: 30,
    height: 30,
    alignment: Alignment.center,
    child: Icon(NestyIcons.lock, size: 16, color: AppColors.iconBrown),
  );
}

/// The 58×58 colored icon tile inside a [HomeTile] (Daily Puzzle's gold
/// "extension" glyph, Remove Ads' purple ad glyph; design/README.md "Home
/// tile", frame 2.1).
class HomeTileIcon extends StatelessWidget {
  const HomeTileIcon({
    required this.child,
    required this.gradient,
    required this.edgeColor,
    this.highlightOpacity = 0.35,
    super.key,
  });

  final Widget child;
  final Gradient gradient;
  final Color edgeColor;

  /// The inset top highlight's alpha (Daily's is 0.6, Remove Ads' 0.35).
  final double highlightOpacity;

  static const double size = 58;
  static const BorderRadius radius = BorderRadius.all(
    Radius.circular(AppRadii.booster),
  );

  /// The Remove Ads tile's glyph (frame 2.1): [AdPlayGlyph] with a red
  /// diagonal "no" bar.
  static Widget removeAdsGlyph({double boxWidth = 30}) {
    final k = boxWidth / 30;
    return Stack(
      alignment: Alignment.center,
      children: [
        AdPlayGlyph(boxWidth: boxWidth),
        Transform.rotate(
          angle: -40 * math.pi / 180,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColorTokens.danger,
              borderRadius: BorderRadius.circular(3 * k),
              boxShadow: [
                BoxShadow(color: AppColors.cream, spreadRadius: 2.5 * k),
              ],
            ),
            child: SizedBox(width: 62 * k, height: 6 * k),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = SurfaceStyle(
      gradient: gradient,
      shadows: [
        NestyShadow(
          color: Color.fromRGBO(255, 255, 255, highlightOpacity),
          inset: true,
          dy: 2,
        ),
        NestyShadow(color: edgeColor, dy: 4),
      ],
    );
    return NestySurface(
      style: style,
      radius: radius,
      width: size,
      height: size,
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// The streak badge on the Daily Puzzle tile: "flame + number" (design/
/// README.md "Home tile"; frame 2.1). Position it with `PositionedDirectional
/// (end: -6, top: -10)` over the tile, as [HomeTile.badge] does.
class StreakBadge extends StatelessWidget {
  const StreakBadge({required this.days, super.key});

  final int days;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.streak,
    shadows: [
      NestyShadow(color: AppColorTokens.streakEdge, dy: 3),
      NestyShadow(color: AppColors.cream, spread: 2.5),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.localizations.streakBadgeSemantics(days),
      excludeSemantics: true,
      child: NestySurface(
        style: _style,
        radius: const BorderRadius.all(Radius.circular(14)),
        height: 26,
        padding: const EdgeInsetsDirectional.fromSTEB(5, 4, 9, 4),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              NestyIcons.localFireDepartment,
              size: 18,
              color: Color(0xFFFFFFFF),
            ),
            const SizedBox(width: 1),
            NestyNumberText(
              days,
              style: AppTextStyleTokens.number.copyWith(
                fontSize: 16,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
