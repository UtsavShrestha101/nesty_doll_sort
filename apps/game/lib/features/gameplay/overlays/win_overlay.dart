import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';
import 'package:nesty_game/features/gameplay/game/timeline/win_overlay_schedule.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_render/nesty_render.dart';

/// What the win overlay celebrates.
@immutable
final class WinSummary {
  const WinSummary({
    required this.reward,
    required this.families,
    required this.chapter,
  });

  /// Coins the win paid (the "+N").
  final int reward;

  /// One hopping doll per completed colour, in board order.
  final List<DollColor> families;

  /// The chapter card (frame 2.8 "Chapter 3 · 16 / 20").
  final ChapterProgress chapter;

  /// One doll per colour that made a family on [board], in the order the
  /// colours first appear on [level]'s board (frame 2.8's plank).
  static List<DollColor> familiesOf(Level level, GameState board) {
    final seen = <DollColor>{};
    void add(DollColor color) {
      if (!color.isWild && board.completedOf(color) > 0) seen.add(color);
    }

    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        for (final nest in slot.nests) {
          add(nest.color);
        }
        if (slot is LockedSlot) add(slot.unlockColor);
      }
    }
    return seen.toList(growable: false);
  }
}

/// Frame 2.8, Level complete (spec §10.2 #4; m2-lottie-design §7 "Win
/// overlay", D47), timed by [WinOverlaySchedule] from the overlay's open:
/// - the scrim, and `fx_confetti` bursting from the ribbon (not under
///   reduced motion);
/// - `ui_win_ribbon` with the localized "Level Complete!" (§12);
/// - each completed family's doll hopping on a plank (`doll_win_hop`, 150 ms
///   apart), drawn from the level's part rasters;
/// - at 700 ms `fx_coin_burst` on the "+N" pill's coin and the count-up to
///   the reward, with the `coins` sound; `win` and its haptic at the open;
/// - `fx_twinkle` around the families;
/// - the chapter card, then Continue.
///
/// TODO(M6): the ×3 rewarded-video button and its "Reward added" state
/// (frames 2.8, 2.9); hidden until ads exist, as the design does offline.
class WinOverlay extends StatefulWidget {
  const WinOverlay({
    required this.summary,
    required this.onContinue,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    this.feedback,
    this.library,
    super.key,
  });

  final WinSummary summary;
  final VoidCallback onContinue;

  /// The level's part rasters (`LevelSkin.images`) for the hopping dolls.
  final FxImageSource? images;

  /// Draws the dolls still when there are no rasters.
  final DollRenderer? renderer;
  final DollSymbols symbols;

  /// Plays the overlay's `win` and `coins` cues; null is silent.
  final FeedbackSink? feedback;
  final FxLibrary? library;

  /// The ribbon's centre below the safe-area top (NestyOverlay: 150 on a
  /// 59 safe area); the confetti bursts from here.
  static const double ribbonCenter = 91;

  /// `ui_win_ribbon`'s canvas (`LottieLabelStyles.winRibbon.canvas`): the
  /// ribbon row is this tall, and the canvas is drawn in it at
  /// `LottieRibbonFit.scaleFor` of the screen width, centred on the row, so
  /// at full size on a 390 dp screen it overhangs both edges (LOTTIE.md v3;
  /// the tails pass them by up to 6 dp during the pop, owner-accepted).
  static const Size ribbonCanvas = Size(410, 110);

  /// The ribbon's row, for tests.
  @visibleForTesting
  static const Key ribbonKey = Key('win-ribbon');

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  final LottieFxController _ribbon = LottieFxController(FxId.uiWinRibbon);
  final LottieFxController _confetti = LottieFxController(FxId.fxConfetti);
  final LottieFxController _burst = LottieFxController(FxId.fxCoinBurst);
  late final AnimationController _countUp = AnimationController(vsync: this);
  late final CurvedAnimation _countCurve = CurvedAnimation(
    parent: _countUp,
    curve: UiMotionTokens.curveEaseOut,
  );
  final List<Timer> _timers = [];
  WinOverlaySchedule? _schedule;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_schedule != null) return;
    final motion = MotionSpec.of(reduceMotion: context.reduceMotion);
    final schedule = WinOverlaySchedule.of(
      motion,
      families: widget.summary.families.length,
    );
    _schedule = schedule;
    _ribbon.playWhole();
    _confetti.playWhole();
    _burst.rest(0);
    _countUp.duration = Duration(
      milliseconds: (schedule.countUpEndMs - schedule.countUpStartMs).round(),
    );
    for (final cue in schedule.cues) {
      _at(cue.atMs, () => widget.feedback?.play(cue));
    }
    _at(schedule.coinBurstAtMs, _burst.playWhole);
    _at(schedule.countUpStartMs, () => _countUp.forward());
  }

  void _at(double ms, VoidCallback action) {
    if (ms <= 0) {
      action();
      return;
    }
    _timers.add(
      Timer(Duration(microseconds: (ms * 1000).round()), () {
        if (mounted) action();
      }),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _countCurve.dispose();
    _countUp.dispose();
    _ribbon.dispose();
    _confetti.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _schedule!;
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    // fx_confetti's canvas is the reference screen, scaled W/390 about its
    // burst point (195, 190), which lands on the ribbon (lottie §5).
    final confettiScale = width / 390;
    return OverlayEntrance(
      kind: OverlayEntranceKind.fade,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          Positioned(
            left: 0,
            top: padding.top + WinOverlay.ribbonCenter - 190 * confettiScale,
            width: width,
            height: 844 * confettiScale,
            child: IgnorePointer(
              child: LottieFxView(
                id: FxId.fxConfetti,
                controller: _confetti,
                library: widget.library,
              ),
            ),
          ),
          content,
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.topCenter,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth,
                child: _content(context, schedule),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WinOverlaySchedule schedule) {
    final l10n = context.localizations;
    final summary = widget.summary;
    final title = l10n.winTitle;
    const canvas = WinOverlay.ribbonCanvas;
    final ribbonScale = LottieRibbonFit.scaleFor(
      MediaQuery.sizeOf(context).width,
    );
    return Padding(
      // The ribbon canvas' top (150 − 55 on a 59 safe area).
      padding: EdgeInsets.only(
        top: WinOverlay.ribbonCenter - canvas.height / 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            key: WinOverlay.ribbonKey,
            width: double.infinity,
            height: canvas.height,
            // The canvas may be wider than the screen: it overflows the row
            // on both sides, centred on the anchor (205, 55).
            child: OverflowBox(
              minWidth: canvas.width * ribbonScale,
              maxWidth: canvas.width * ribbonScale,
              minHeight: canvas.height * ribbonScale,
              maxHeight: canvas.height * ribbonScale,
              child: LottieTextOverlay(
                label: title,
                style: LottieLabelStyles.winRibbon,
                lottie: LottieFxView(
                  id: FxId.uiWinRibbon,
                  controller: _ribbon,
                  library: widget.library,
                  label: title,
                  fallback: const CustomPaint(painter: WinRibbonPainter()),
                ),
              ),
            ),
          ),
          _Families(
            families: summary.families,
            startsMs: schedule.hopStartsMs,
            images: widget.images,
            renderer: widget.renderer,
            symbols: widget.symbols,
            library: widget.library,
          ),
          const SizedBox(height: 24),
          _CoinPill(
            reward: summary.reward,
            countUp: _countCurve,
            burst: LottieFxView(
              id: FxId.fxCoinBurst,
              controller: _burst,
              library: widget.library,
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: WinChapterCard(progress: summary.chapter),
          ),
          // NestyOverlay: the buttons start at 630, 60 below the 86-tall
          // card (484–570). With the ×3 button hidden (M6), Continue is the
          // first of them.
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
            child: TactileButton(
              label: l10n.winContinue,
              onPressed: widget.onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

/// The families hopping on their plank (NestyOverlay `hop`: a 30 px plank
/// at y 350, bases at 361, `min(84, 330 / n)` apart, 104 tall, 88 above
/// four families), with a few twinkles around them.
class _Families extends StatelessWidget {
  const _Families({
    required this.families,
    required this.startsMs,
    required this.images,
    required this.renderer,
    required this.symbols,
    required this.library,
  });

  final List<DollColor> families;
  final List<double> startsMs;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FxLibrary? library;

  /// From the ribbon canvas' bottom (y 205) to the plank's (380).
  static const double height = 175;
  static const double _plankTop = 145;
  static const double _base = 156;

  // TODO(design): LOTTIE.md puts fx_twinkle on the win overlay but no
  // frame places it; these sit around the plank.
  static const _twinkles = [
    (dx: -137.0, top: 22.0, size: 22.0, periodMs: 2200.0, phaseMs: 0.0),
    (dx: 105.0, top: 6.0, size: 26.0, periodMs: 2400.0, phaseMs: 700.0),
    (dx: -150.0, top: 104.0, size: 16.0, periodMs: 2000.0, phaseMs: 1300.0),
    (dx: 138.0, top: 110.0, size: 18.0, periodMs: 2300.0, phaseMs: 1800.0),
  ];

  /// Family [i]'s hop start (150 ms apart, halved under reduced motion).
  Duration _delay(int i) => Duration(
    microseconds: i < startsMs.length ? (startsMs[i] * 1000).round() : 0,
  );

  @override
  Widget build(BuildContext context) {
    final n = families.length;
    final pitch = n == 0 ? 0.0 : (330 / n).clamp(0.0, 84.0);
    final dollHeight = n > 4 ? 88.0 : 104.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = constraints.maxWidth / 2;
        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 10,
                right: 10,
                top: _plankTop,
                child: PlankStrip(height: 30),
              ),
              for (final t in _twinkles)
                Positioned(
                  left: center + t.dx - t.size / 2,
                  top: t.top,
                  child: LottieTwinkle(
                    size: t.size,
                    periodMs: t.periodMs,
                    phaseMs: t.phaseMs,
                    library: library,
                  ),
                ),
              for (var i = 0; i < n; i++)
                LottieDoll.positioned(
                  centerX: center + (i - (n - 1) / 2) * pitch,
                  baseY: _base,
                  doll: LottieDoll(
                    id: FxId.dollWinHop,
                    color: families[i],
                    height: dollHeight,
                    images: images,
                    renderer: renderer,
                    symbols: symbols,
                    library: library,
                    startDelay: _delay(i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The "+25" pill (NestyOverlay: 10/20/10/10 padding, radius 26, a 38 px
/// coin, 30/700 `#8C5E12`), counting up from 0 with [countUp], and
/// `fx_coin_burst` anchored (80, 100) on its coin.
class _CoinPill extends StatelessWidget {
  const _CoinPill({
    required this.reward,
    required this.countUp,
    required this.burst,
  });

  final int reward;
  final Animation<double> countUp;
  final Widget burst;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  /// The coin's centre in the pill: 10 padding + a 38 px coin.
  static const Offset _coin = Offset(29, 29);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Semantics(
      label: l10n.coinsSemantics(reward),
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NestySurface(
            style: _style,
            radius: const BorderRadius.all(Radius.circular(26)),
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 20, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 38),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: countUp,
                  builder: (context, _) => Text(
                    l10n.winCoins((reward * countUp.value).round()),
                    style: AppTextStyleTokens.number.copyWith(
                      fontSize: 30,
                      height: 1,
                      color: AppColorTokens.coinText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: _coin.dx - 80,
            top: _coin.dy - 100,
            width: 160,
            height: 140,
            child: IgnorePointer(child: burst),
          ),
        ],
      ),
    );
  }
}

/// The ribbon's rest look without its file (rule 3, R10): what
/// `ui_win_ribbon` holds on after its pop (frame 18), on the 410×110 canvas
/// around the anchor (205, 55). The 336×56 band (radius 16, `#F28A3B`)
/// over its `#C4631F` edge 6 below, a 30 % white highlight, and the
/// `#E07A2E` tails 22 past the band with a 12 notch and a `#9E4A14` fold
/// under it (LOTTIE.md v3, as the Win screen mock).
final class WinRibbonPainter extends CustomPainter {
  const WinRibbonPainter();

  static const _anchor = Offset(205, 55);

  static final Paint _tail = Paint()..color = const Color(0xFFE07A2E);
  static final Paint _fold = Paint()..color = const Color(0xFF9E4A14);
  static final Paint _edge = Paint()..color = const Color(0xFFC4631F);
  static final Paint _face = Paint()..color = const Color(0xFFF28A3B);
  static final Paint _highlight = Paint()..color = const Color(0x4DFFFFFF);

  static final RRect _band = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: 336, height: 56),
    const Radius.circular(16),
  );
  static final RRect _shine = RRect.fromRectAndRadius(
    Rect.fromCenter(center: const Offset(0, -23), width: 320, height: 5),
    const Radius.circular(2.5),
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / WinOverlay.ribbonCanvas.width,
        size.height / WinOverlay.ribbonCanvas.height,
      )
      ..translate(_anchor.dx, _anchor.dy);
    for (final side in const [-1.0, 1.0]) {
      canvas
        ..drawPath(_tailPath(side), _tail)
        ..drawPath(_foldPath(side), _fold);
    }
    canvas
      ..drawRRect(_band.shift(const Offset(0, 6)), _edge)
      ..drawRRect(_band, _face)
      ..drawRRect(_shine, _highlight)
      ..restore();
  }

  static Path _tailPath(double side) => Path()
    ..moveTo(154 * side, -14)
    ..lineTo(190 * side, -14)
    ..lineTo(178 * side, 8)
    ..lineTo(190 * side, 38)
    ..lineTo(154 * side, 38)
    ..close();

  static Path _foldPath(double side) => Path()
    ..moveTo(154 * side, 28)
    ..lineTo(168 * side, 28)
    ..lineTo(168 * side, 38)
    ..close();

  @override
  bool shouldRepaint(WinRibbonPainter oldDelegate) => false;
}
