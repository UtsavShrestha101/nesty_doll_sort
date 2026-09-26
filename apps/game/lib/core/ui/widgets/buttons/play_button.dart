import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/hud/tier_chip.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// Home's big PLAY button (frame 2.1; NestyMenus): 96 tall, radius 32, an
/// 8 px edge, a cream play disc, "PLAY" over "Level 56", and the tier badge
/// tilted 8° on the top-right corner for Hard and Super Hard levels.
///
/// Once every bundled level is won ([allLevelsDone]) it reads "PLAY" over
/// "All done!" with no badge, never a level that doesn't exist, and opens
/// All Levels Done (frame 4.9; review FIDELITY-5).
/// TODO(design): no frame shows Home past the last level; M3's Bonus
/// Endless shows the bonus level here (spec §7.1).
///
/// The caller gives it its width (left/right 36 on Home).
class PlayButton extends StatelessWidget {
  const PlayButton({
    required this.level,
    required this.tier,
    required this.onPressed,
    this.allLevelsDone = false,
    super.key,
  });

  final int level;
  final Tier tier;
  final VoidCallback? onPressed;

  /// Every level is won: no level to name.
  final bool allLevelsDone;

  static const double height = 96;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.playButton,
    shadows: [
      NestyShadow(color: Color(0x66FFFFFF), inset: true, dy: 3),
      NestyShadow(color: Color(0x2EA03C0A), inset: true, dy: -4),
      NestyShadow(color: AppColorTokens.primaryEdge, dy: 8),
      NestyShadow(color: Color(0x59964614), dy: 16, blur: 26),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final badge = !allLevelsDone && TierChip.shows(tier);
    final semantics = allLevelsDone
        ? l10n.allLevelsTitle
        : badge
        ? l10n.playLevelSemantics(level, l10n.tierName(tier.id))
        : l10n.playSemantics(level);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _PlayDisc(),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homePlay,
              style: AppTextStyleTokens.buttonSmall.copyWith(
                fontSize: 14,
                letterSpacing: 14 * 0.14,
                color: AppColors.playCaption,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              allLevelsDone ? l10n.homeAllLevelsDone : l10n.levelTitle(level),
              style: AppTextStyleTokens.display.copyWith(
                fontSize: 36,
                color: const Color(0xFFFFFFFF),
                shadows: const [
                  Shadow(color: Color(0x59963C0A), offset: Offset(0, 3)),
                ],
              ),
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
    return TactileSurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(AppRadii.card)),
      onPressed: onPressed,
      width: double.infinity,
      height: height,
      semanticLabel: semantics,
      excludeChildSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: content),
              ),
            ),
          ),
          if (badge)
            PositionedDirectional(
              end: -10,
              top: -14,
              child: Transform.rotate(
                angle: 8 * math.pi / 180,
                child: _TierBadge(tier: tier),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc();

  static const _style = SurfaceStyle(
    color: AppColors.cream,
    shadows: [
      NestyShadow(color: AppColors.playDiscShade, inset: true, dy: -3),
      NestyShadow(color: Color(0x4D963C0A), dy: 3),
    ],
  );

  @override
  Widget build(BuildContext context) => const NestySurface(
    style: _style,
    radius: BorderRadius.all(Radius.circular(26)),
    width: 52,
    height: 52,
    alignment: Alignment.center,
    child: Padding(
      padding: EdgeInsetsDirectional.only(start: 6),
      child: CustomPaint(size: Size(20, 26), painter: _TrianglePainter()),
    ),
  );
}

final class _TrianglePainter extends CustomPainter {
  const _TrianglePainter();

  static final Paint _paint = Paint()..color = AppColorTokens.primary;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close(),
    _paint,
  );

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}

/// The Home badge: bigger than the HUD chip, on the tier's own gradient
/// with a 3 px cream ring (NestyMenus "HARD").
/// TODO(design): Home shows only HARD; SUPER HARD reuses its shape on the
/// purple gradient with the bolt glyph (Design System chip).
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final superHard = tier == Tier.superhard;
    final style = SurfaceStyle(
      gradient: superHard
          ? AppGradientTokens.superHard
          : AppGradientTokens.hard,
      shadows: [
        const NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
        NestyShadow(
          color: superHard
              ? AppColorTokens.superHardEdge
              : AppColorTokens.dangerEdge,
          dy: 4,
        ),
        const NestyShadow(color: AppColors.cream, spread: 3),
      ],
    );
    return NestySurface(
      style: style,
      radius: const BorderRadius.all(Radius.circular(12)),
      padding: const EdgeInsetsDirectional.fromSTEB(7, 6, 10, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            superHard ? NestyIcons.bolt : NestyIcons.localFireDepartment,
            size: 16,
            color: const Color(0xFFFFFFFF),
          ),
          const SizedBox(width: 3),
          Text(
            superHard ? l10n.tierSuperHard : l10n.tierHard,
            style: AppTextStyleTokens.tierChip.copyWith(
              fontSize: 13,
              letterSpacing: 13 * 0.06,
              color: const Color(0xFFFFFFFF),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
