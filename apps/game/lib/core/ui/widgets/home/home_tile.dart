import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/ad_play_glyph.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
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
/// or vs Computer's portrait), [footer] an optional line under the label
/// ("After Level 2", the Computer tag). [badge] overlays the top-right
/// corner (a [StreakBadge]).
///
/// [locked] (frames 12.3, 9.1: Daily before Level 2, vs Computer before Level
/// 20) dims the tile to 60 %, disables the tap and hides [badge]; the
/// footer says why, and a screen reader reads it as the value. No lock glyph
/// sits on the tile itself: vs Computer's portrait carries its own.
///
/// [tileHeight] is 132 (frame 2.1) and 112 on a short screen (`HomeShortTokens`,
/// frame 2.1b); the content scales down inside it rather than clip, at 1.3×
/// text or a narrow tile.
class HomeTile extends StatelessWidget {
  const HomeTile({
    required this.leading,
    required this.label,
    required this.onTap,
    this.footer,
    this.badge,
    this.locked = false,
    this.semanticLabel,
    this.semanticValue,
    this.tileHeight = height,
    super.key,
  });

  final Widget leading;
  final String label;
  final VoidCallback? onTap;
  final Widget? footer;
  final Widget? badge;
  final bool locked;
  final String? semanticLabel;

  /// Read after the label: a locked tile passes its footer's reason
  /// ("After Level 2"), which the tile's single node would otherwise hide.
  final String? semanticValue;

  /// The tile's height in `layout.home.tiles` (frame 2.1).
  static const double height = HomeTokens.tilesHeight;

  /// The tile's height on this screen: [height], or 112 on a short one.
  final double tileHeight;

  static const double _radius = 24;
  static const double _lockedOpacity = 0.6;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            // The label wraps at the tile's own width before the whole
            // column scales.
            constraints: const BoxConstraints(maxWidth: 110),
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
          ),
        ),
      ),
    );
    final tile = TactileSurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(_radius)),
      onPressed: locked ? null : onTap,
      width: double.infinity,
      height: tileHeight,
      semanticLabel: semanticLabel ?? label,
      semanticValue: semanticValue,
      excludeChildSemantics: true,
      child: content,
    );
    final badge = this.badge;
    if (badge == null || locked) return tile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        // Frame 2.1: the badge hangs 8 dp past the right edge and 14 above.
        PositionedDirectional(
          end: -8,
          top: -14,
          child: IgnorePointer(child: badge),
        ),
      ],
    );
  }
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

/// The streak badge on the Daily Puzzle tile (frames 2.1, 12.2; menus spec
/// 1.1, 6.5): a 26 tall pill with a flame and the day count.
///
/// * [StreakLook.lit]: `gradient.streak`, a white flame and the count.
/// * [StreakLook.paused]: the resting `streakPaused` colours, never red (Q96).
/// * [StreakLook.relit]: the lit look with a 3 dp `relitGlow` ring, faded in
///   over 400 ms once (a static ring under reduce motion).
/// * [StreakLook.zero]: an unlit flame and no number (frame 12.2).
///
/// Position it with `PositionedDirectional(end: -8, top: -14)` over the tile,
/// as [HomeTile.badge] does.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.days,
    this.look = StreakLook.lit,
    super.key,
  });

  final int days;
  final StreakLook look;

  static const _litStyle = SurfaceStyle(
    gradient: AppGradientTokens.streak,
    shadows: [
      NestyShadow(color: AppColorTokens.streakEdge, dy: 3),
      NestyShadow(color: AppColors.cream, spread: 2.5),
    ],
  );

  static const _restingStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColorTokens.streakPausedTop, AppColorTokens.streakPaused],
    ),
    shadows: [
      NestyShadow(color: AppColorTokens.streakPausedEdge, dy: 3),
      NestyShadow(color: AppColors.cream, spread: 2.5),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final resting = look == StreakLook.paused || look == StreakLook.zero;
    final flameColor = resting
        ? AppColorTokens.streakPausedGlyph
        : const Color(0xFFFFFFFF);
    final pill = NestySurface(
      style: resting ? _restingStyle : _litStyle,
      radius: const BorderRadius.all(Radius.circular(14)),
      height: 26,
      padding: EdgeInsetsDirectional.fromSTEB(
        5,
        4,
        look == StreakLook.zero ? 5 : 9,
        4,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(NestyIcons.localFireDepartment, size: 16, color: flameColor),
          if (look != StreakLook.zero) ...[
            const SizedBox(width: 1),
            NestyNumberText(
              days,
              style: AppTextStyleTokens.number.copyWith(
                fontSize: 15,
                color: flameColor,
              ),
            ),
          ],
        ],
      ),
    );
    final Widget face = look == StreakLook.relit
        ? _RelitRing(child: pill)
        : pill;
    if (look == StreakLook.zero) return ExcludeSemantics(child: face);
    return Semantics(
      label: look == StreakLook.paused
          ? l10n.streakBadgeSemanticsPaused(days)
          : l10n.streakBadgeSemantics(days),
      excludeSemantics: true,
      child: face,
    );
  }
}

/// [StreakLook.relit]'s ring: 3 dp of `relitGlow` around the pill, fading in
/// over 400 ms once, no loop (menus spec 6.5). Under reduce motion it is
/// just there.
class _RelitRing extends StatelessWidget {
  const _RelitRing({required this.child});

  final Widget child;

  static const _ringWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final ring = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 + _ringWidth),
        border: Border.all(color: AppColorTokens.relitGlow, width: _ringWidth),
      ),
      child: child,
    );
    if (context.reduceMotion) return ring;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: ring,
    );
  }
}
