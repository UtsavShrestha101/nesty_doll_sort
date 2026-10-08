import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/a11y_join_extension.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_game/core/ui/widgets/text/shrink_to_fit_text.dart';
import 'package:nesty_game/features/welcome_back/cubit/welcome_back_cubit.dart';

/// Home's welcome-back card (local habit 1, plan-local-habits §1; frames
/// 14.1a to 14.1e, tokens `habits.welcomeBack`): inline under the chapter
/// card, never a modal or a sheet. The whole card is the Play button; its
/// close is a 28 dp disc in a 48 dp target.
///
/// No countdown, no loss and no red: it welcomes and offers, and closing it
/// is final for the day. Pure view: the cubit decides whether it shows and
/// what the button starts. Its box reaches [targetOutset] past the card's
/// top and right edge, so the close's 48 dp target is inside the widget's
/// own bounds (a hit test never leaves them); Home offsets it.
class WelcomeBackCard extends StatefulWidget {
  const WelcomeBackCard({
    required this.variant,
    required this.streak,
    required this.onPlay,
    required this.onClose,
    super.key,
  });

  final WelcomeBackVariant variant;

  /// The streak's number (the paused line names it).
  final int streak;
  final VoidCallback onPlay;

  /// Called once the card has faded out (the close's own exit).
  final VoidCallback onClose;

  /// How far the close's 48 dp target reaches past the card's top and right
  /// edge: (48 - 28) / 2 minus the disc's 6 dp inset.
  static const double targetOutset =
      (HabitsWelcomeTokens.dismissTarget -
              HabitsWelcomeTokens.dismissFaceSize) /
          2 -
      HabitsWelcomeTokens.dismissTop;

  /// Whether a line of [lines] lines at this width is within the body's
  /// two-line limit (textFit.habitsWelcome.body).
  static int bodyLines({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextScaler scaler,
    required TextDirection direction,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth > 0 ? maxWidth : 0);
    final lines = painter.computeLineMetrics().length;
    painter.dispose();
    return lines;
  }

  @override
  State<WelcomeBackCard> createState() => _WelcomeBackCardState();
}

class _WelcomeBackCardState extends State<WelcomeBackCard>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(vsync: this);
  late final AnimationController _out = AnimationController(vsync: this);
  bool _started = false;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = context.reduceMotion;
    _in.duration = Duration(
      milliseconds: _reduce
          ? HabitsWelcomeTokens.reducedMotionInMs
          : HabitsWelcomeTokens.motionInMs,
    );
    _out.duration = Duration(
      milliseconds: _reduce
          ? HabitsWelcomeTokens.reducedMotionOutMs
          : HabitsWelcomeTokens.motionOutMs,
    );
    if (_started) return;
    _started = true;
    // With Home's first frame, never later and never on its own.
    _in.forward();
  }

  @override
  void dispose() {
    _in.dispose();
    _out.dispose();
    super.dispose();
  }

  void _close() {
    if (_out.isAnimating || _out.isCompleted) return;
    _out.forward().whenComplete(() {
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final (full, short) = switch (widget.variant) {
      WelcomeBackVariant.newStreak || WelcomeBackVariant.plain => (
        l10n.welcomeBackNew,
        l10n.welcomeBackNewShort,
      ),
      WelcomeBackVariant.paused => (
        l10n.welcomeBackPaused(widget.streak),
        l10n.welcomeBackPausedShort(widget.streak),
      ),
      WelcomeBackVariant.freezeKept => (
        l10n.welcomeBackFreeze,
        l10n.welcomeBackFreezeShort,
      ),
    };
    final inset = WelcomeBackCard.targetOutset;
    final card = Padding(
      padding: EdgeInsets.only(top: inset, right: inset),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: HabitsWelcomeTokens.cardMinHeight,
        ),
        child: TactileSurface(
          style: const SurfaceStyle(
            gradient: HabitsWelcomeTokens.cardFace,
            shadows: HabitsWelcomeTokens.cardShadow,
          ),
          radius: BorderRadius.circular(HabitsWelcomeTokens.cardRadius),
          padding: HabitsWelcomeTokens.cardPadding,
          alignment: AlignmentDirectional.centerStart,
          onPressed: widget.onPlay,
          // Title, line, then the action, as one button.
          semanticLabel: l10n.joinSentences([
            l10n.welcomeBackTitle,
            full,
            l10n.welcomeBackPlaySemantics,
          ]),
          excludeChildSemantics: true,
          child: _Content(
            variant: widget.variant,
            title: l10n.welcomeBackTitle,
            full: full,
            short: short,
            play: l10n.welcomeBackPlay,
          ),
        ),
      ),
    );
    final dismiss = PositionedDirectional(
      top: 0,
      end: 0,
      child: TactileSurface(
        style: const SurfaceStyle(
          color: HabitsWelcomeTokens.dismissColor,
          shadows: HabitsWelcomeTokens.dismissShade,
          pressTravel: 2,
        ),
        radius: BorderRadius.circular(HabitsWelcomeTokens.dismissFaceSize / 2),
        width: HabitsWelcomeTokens.dismissFaceSize,
        height: HabitsWelcomeTokens.dismissFaceSize,
        onPressed: _close,
        semanticLabel: l10n.welcomeBackHideSemantics,
        excludeChildSemantics: true,
        minTouchSize: const Size.square(HabitsWelcomeTokens.dismissTarget),
        child: const Icon(
          NestyIcons.close,
          size: HabitsWelcomeTokens.dismissGlyphSize,
          color: HabitsWelcomeTokens.dismissGlyphColor,
        ),
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_in, _out]),
      child: Stack(clipBehavior: Clip.none, children: [card, dismiss]),
      builder: (context, child) {
        final tIn = HabitsWelcomeTokens.motionInCurve.transform(_in.value);
        final tOut = HabitsWelcomeTokens.motionOutCurve.transform(_out.value);
        return Opacity(
          opacity: (tIn * (1 - tOut)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              _reduce ? 0 : (1 - tIn) * HabitsWelcomeTokens.motionInRise,
            ),
            child: Transform.scale(
              scale: _reduce
                  ? 1
                  : 1 - (1 - HabitsWelcomeTokens.motionOutScale) * tOut,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// The disc, the words and the Play pill, laid out by what fits: beside the
/// text while the line takes two lines or fewer, else the short form with
/// Play under it, right-aligned (also at 1.3x text).
class _Content extends StatelessWidget {
  const _Content({
    required this.variant,
    required this.title,
    required this.full,
    required this.short,
    required this.play,
  });

  final WelcomeBackVariant variant;
  final String title;
  final String full;
  final String short;
  final String play;

  static const _maxLines = TextFitTokens.habitsWelcomeBodyMaxLines;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.scriptStyle(
      HabitsWelcomeTokens.body,
      role: ScriptTextRole.body,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final big =
        scaler.scale(1) >= TextFitTokens.habitsWelcomePlayUnderAtTextScale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pillWidth = _PlayPill.widthOf(context, play, scaler, direction);
        const lead = HabitsWelcomeTokens.discSize + HabitsWelcomeTokens.cardGap;
        final sideWidth =
            width - lead - HabitsWelcomeTokens.cardGap - pillWidth;
        // Room the close's disc leaves (6 + 28 from the card's edge, less the
        // card's 12 padding).
        const closeRoom =
            HabitsWelcomeTokens.dismissTop +
            HabitsWelcomeTokens.dismissFaceSize -
            12;
        final underWidth = width - lead - closeRoom;
        int lines(String text, double w) => WelcomeBackCard.bodyLines(
          text: text,
          style: bodyStyle,
          maxWidth: w,
          scaler: scaler,
          direction: direction,
        );
        final side = !big && lines(full, sideWidth) <= _maxLines;
        final shown = side || lines(full, underWidth) <= _maxLines
            ? full
            : short;
        final text = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShrinkToFitText(
              title,
              style: HabitsWelcomeTokens.title,
              textAlign: TextAlign.start,
              maxLines: 2,
              minFontScale: TextFitTokens.habitsWelcomeTitleMinScale,
            ),
            Text(shown, style: bodyStyle),
          ],
        );
        final disc = _Disc(variant: variant);
        if (side) {
          // Play sits 12 dp from the card's bottom and right (the content's
          // own bottom-right corner); the disc and the words centre in the
          // card's height beside it.
          return Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      HabitsWelcomeTokens.cardMinHeight -
                      HabitsWelcomeTokens.cardPadding.vertical,
                ),
                child: Row(
                  children: [
                    disc,
                    const SizedBox(width: HabitsWelcomeTokens.cardGap),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: HabitsWelcomeTokens.cardGap + pillWidth,
                        ),
                        child: text,
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: _PlayPill(label: play),
              ),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                disc,
                const SizedBox(width: HabitsWelcomeTokens.cardGap),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: closeRoom),
                    child: text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: HabitsWelcomeTokens.playUnderGap),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _PlayPill(label: play),
            ),
          ],
        );
      },
    );
  }
}

/// The 48 dp flame (lit, with a freeze's badge, or resting) or the Daily's
/// puzzle piece when there is no streak yet. Never a number, never red.
class _Disc extends StatelessWidget {
  const _Disc({required this.variant});

  final WelcomeBackVariant variant;

  @override
  Widget build(BuildContext context) {
    final (style, radius, glyph, size, color) = switch (variant) {
      WelcomeBackVariant.paused => (
        const SurfaceStyle(
          gradient: HabitsWelcomeTokens.discPausedFace,
          shadows: HabitsWelcomeTokens.discPausedEdge,
        ),
        HabitsWelcomeTokens.discSize / 2,
        NestyIcons.localFireDepartment,
        HabitsWelcomeTokens.discPausedGlyphSize,
        HabitsWelcomeTokens.discPausedGlyphColor,
      ),
      WelcomeBackVariant.newStreak || WelcomeBackVariant.plain => (
        const SurfaceStyle(
          gradient: HabitsWelcomeTokens.discNewFace,
          shadows: HabitsWelcomeTokens.discNewEdge,
        ),
        HabitsWelcomeTokens.discNewRadius,
        NestyIcons.extension,
        HabitsWelcomeTokens.discNewGlyphSize,
        HabitsWelcomeTokens.discNewGlyphColor,
      ),
      WelcomeBackVariant.freezeKept => (
        const SurfaceStyle(
          gradient: HabitsWelcomeTokens.discFreezeFace,
          shadows: HabitsWelcomeTokens.discFreezeEdge,
        ),
        HabitsWelcomeTokens.discSize / 2,
        NestyIcons.localFireDepartment,
        HabitsWelcomeTokens.discFreezeGlyphSize,
        HabitsWelcomeTokens.discFreezeGlyphColor,
      ),
    };
    final badge = variant == WelcomeBackVariant.freezeKept;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: HabitsWelcomeTokens.discSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: NestySurface(
                style: style,
                radius: BorderRadius.circular(radius),
                alignment: Alignment.center,
                child: Icon(glyph, size: size, color: color),
              ),
            ),
            if (badge)
              PositionedDirectional(
                end: HabitsWelcomeTokens.discFreezeBadgeRight,
                bottom: HabitsWelcomeTokens.discFreezeBadgeBottom,
                child: NestySurface(
                  style: const SurfaceStyle(
                    color: HabitsWelcomeTokens.discFreezeBadgeFace,
                    shadows: HabitsWelcomeTokens.discFreezeBadgeShadow,
                  ),
                  radius: BorderRadius.circular(
                    HabitsWelcomeTokens.discFreezeBadgeSize / 2,
                  ),
                  width: HabitsWelcomeTokens.discFreezeBadgeSize,
                  height: HabitsWelcomeTokens.discFreezeBadgeSize,
                  alignment: Alignment.center,
                  child: const Icon(
                    NestyIcons.acUnit,
                    size: HabitsWelcomeTokens.discFreezeBadgeGlyphSize,
                    color: HabitsWelcomeTokens.discFreezeBadgeGlyphColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The Play pill: a look only (the whole card is the button).
class _PlayPill extends StatelessWidget {
  const _PlayPill({required this.label});

  final String label;

  static double widthOf(
    BuildContext context,
    String label,
    TextScaler scaler,
    TextDirection direction,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: context.scriptStyle(HabitsWelcomeTokens.playLabel),
      ),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return HabitsWelcomeTokens.playPadding.horizontal +
        HabitsWelcomeTokens.playTriangle.width +
        HabitsWelcomeTokens.playGap +
        width;
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: NestySurface(
        style: const SurfaceStyle(
          gradient: HabitsWelcomeTokens.playFace,
          shadows: HabitsWelcomeTokens.playEdge,
        ),
        radius: BorderRadius.circular(HabitsWelcomeTokens.playRadius),
        padding: HabitsWelcomeTokens.playPadding,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HabitsWelcomeTokens.playHeight,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: HabitsWelcomeTokens.playTriangle,
                painter: _TrianglePainter(),
              ),
              const SizedBox(width: HabitsWelcomeTokens.playGap),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: context.scriptStyle(HabitsWelcomeTokens.playLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = HabitsWelcomeTokens.playTriangleColor,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}
