import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/ad_play_glyph.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
import 'package:nesty_game/core/ui/widgets/number/nesty_number_text.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/core/ui/widgets/text/shrink_to_fit_text.dart';

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
  static const double _labelWidth = 110;
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
    // The short frame (2.1b) is 20 dp lower: its gaps tighten so a label that
    // had to step down to 0.75x (Japanese) isn't scaled again with the column.
    final compact = tileHeight < height;
    final content = Opacity(
      opacity: locked ? _lockedOpacity : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 2 : 4),
        // The label wraps or steps down at the tile's own inner width, not
        // a fixed one: three tiles share a 360 dp row, and a Japanese label
        // wider than its tile would otherwise scale the whole column below
        // the readability floor (textFit).
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = constraints.maxWidth.isFinite
                ? math.min(constraints.maxWidth, _labelWidth)
                : _labelWidth;
            const width = _labelWidth;
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: width),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leading,
                    SizedBox(height: compact ? 5 : 8),
                    // Wraps to 2 lines at the tile's width, then the font
                    // steps down to 0.75x so a long word ("Computadora")
                    // isn't broken (textFit); the column's FittedBox scales
                    // what is left.
                    ShrinkToFitText(
                      label,
                      style: AppTextStyleTokens.cardTitle.copyWith(
                        fontSize: 15,
                        color: AppColorTokens.textPrimary,
                      ),
                      minFontScale: 0.75,
                      fixedWidth: width,
                    ),
                    if (footer != null) ...[
                      SizedBox(height: compact ? 2 : 5),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: tileWidth),
                        child: footer,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
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
                BoxShadow(color: AppColorTokens.cream, spreadRadius: 2.5 * k),
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
/// * [StreakLook.relit]: the lit look with a 3 dp `relitGlow` ring for
///   `motion.relitHome`'s 2,400 ms, then a 400 ms fade (a cut under reduce
///   motion); [onRelitGlowEnd] says when it is over (m7-4 4.10).
/// * [StreakLook.zero]: an unlit flame and no number (frame 12.2).
///
/// Position it with `PositionedDirectional(end: -8, top: -14)` over the tile,
/// as [HomeTile.badge] does.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.days,
    this.look = StreakLook.lit,
    this.onRelitGlowEnd,
    super.key,
  });

  final int days;
  final StreakLook look;

  /// Called once, when a [StreakLook.relit] badge's glow has faded.
  final VoidCallback? onRelitGlowEnd;

  static const _litStyle = SurfaceStyle(
    gradient: AppGradientTokens.streak,
    shadows: [
      NestyShadow(color: AppColorTokens.streakEdge, dy: 3),
      NestyShadow(color: AppColorTokens.cream, spread: 2.5),
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
      NestyShadow(color: AppColorTokens.cream, spread: 2.5),
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
        ? _RelitRing(onEnd: onRelitGlowEnd, child: pill)
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

/// [StreakLook.relit]'s ring: 3 dp of `relitGlow` around the pill, held for
/// `motion.relitHome.glowMs` (2,400 ms) and faded over `fadeMs` (400 ms), once
/// (m7-4 4.10). Under reduce motion the fade is a cut. [onEnd] is called when
/// it is over.
class _RelitRing extends StatefulWidget {
  const _RelitRing({required this.child, this.onEnd});

  final Widget child;
  final VoidCallback? onEnd;

  static const _ringWidth = 3.0;

  static const _totalMs = RelitHomeTokens.glowMs + RelitHomeTokens.fadeMs;

  @override
  State<_RelitRing> createState() => _RelitRingState();
}

class _RelitRingState extends State<_RelitRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _RelitRing._totalMs),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onEnd?.call();
      });

  /// The glow has started: it plays once, from when Home first shows.
  bool _started = false;

  /// The glow starts only once Home is on screen. Home's cubit learns of a
  /// relight during the daily's solve, while the Daily screen and the board
  /// cover it: its tickers are muted then, but a muted ticker's clock still
  /// runs, so a glow started there would be over before Home came back
  /// (m7-4 4.10: the first Home visit after a relight shows it).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && TickerMode.valuesOf(context).enabled) {
      _started = true;
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = context.reduceMotion;
    const held = RelitHomeTokens.glowMs / _RelitRing._totalMs;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final opacity = t <= held
            ? 1.0
            : reduced
            ? 0.0
            : 1 - (t - held) / (1 - held);
        // The pill keeps its place and size: the ring (`0 0 0 3px`) is drawn
        // around it and only it fades.
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            Positioned(
              left: -_RelitRing._ringWidth,
              top: -_RelitRing._ringWidth,
              right: -_RelitRing._ringWidth,
              bottom: -_RelitRing._ringWidth,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      14 + _RelitRing._ringWidth,
                    ),
                    border: Border.all(
                      color: AppColorTokens.relitGlow,
                      width: _RelitRing._ringWidth,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
