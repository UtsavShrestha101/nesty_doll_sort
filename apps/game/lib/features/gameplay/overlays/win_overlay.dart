import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/share/daily_share_text.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_ribbon.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';
import 'package:nesty_game/features/gameplay/game/timeline/win_overlay_schedule.dart';
import 'package:nesty_game/features/gameplay/overlays/celebration_layout.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/overlays/win_result_chips.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart';

/// What the win overlay celebrates.
@immutable
final class WinSummary {
  const WinSummary({
    required this.reward,
    required this.families,
    required this.chapter,
    this.dailyStreak,
    this.dailyRelit = false,
    this.winMoves,
    this.bestMoves,
    this.chestLevelsLeft,
    this.isReplay = false,
    this.newBadges = const <BadgeId>[],
    this.stars,
    this.starsNewBest = false,
    this.starTarget,
    this.starTip = false,
    this.starsCapped = false,
    this.bonusNumber,
    this.dailyDate,
  });

  /// Coins the win paid (the "+N"); 0 on a replay (E7; m7-design §11).
  final int reward;

  /// One hopping doll per completed colour, in board order.
  final List<DollColor> families;

  /// The chapter card (frame 2.8 "Chapter 3 · 16 / 20"); still computed for
  /// a daily win (the background and the ribbon read it) but not shown,
  /// since [dailyStreak] replaces it with the streak card (frame 5.4).
  final ChapterProgress chapter;

  /// Set only for the daily puzzle (m3-design §8.4): the streak after this
  /// solve, frame 5.4's variant instead of [chapter]'s card.
  final int? dailyStreak;

  /// The solve restarted a paused streak (`DailyProgress.relitOn`; E2;
  /// m7-design §8): the streak card's lines say so instead of the usual
  /// count-and-hint pair. Only meaningful with [dailyStreak] set.
  final bool dailyRelit;

  /// This win's moves (`GameState.moveCount`), for the moves caption (E7;
  /// m7-design §11); null before the bloc reports it.
  final int? winMoves;

  /// The level's best moves after this win, for a bundled level (a
  /// campaign win or a replay); null for a board that keeps no best
  /// (daily, bonus, race), whose caption shows [winMoves] alone.
  final int? bestMoves;

  /// Levels left to the next milestone chest when it is nearer than the
  /// chapter's figurine (E5; m7-design §9): the chapter card's countdown
  /// row replaces its figurine bar. Null for a replay, a daily, or when the
  /// figurine is nearer.
  final int? chestLevelsLeft;

  /// A replay from Chapters (E7; m7-design §6, §11): no coin pill, count-up
  /// or burst; [winReplayReason] sits where the pill would; the chapter
  /// card hides its "Next up" line; the button reads "Back to Chapters".
  final bool isReplay;

  /// Badges this win earned, in the order to toast them (E8; m7-design
  /// §12): one [BadgeToast] each, a little after the overlay opens.
  final List<BadgeId> newBadges;

  /// This win's stars, 1–3 (`GameplayState.stars`; spec-prop §7.10;
  /// m7-design P3.7); null for daily, bonus, race or a level without a
  /// par — no stars show, on the card or anywhere else.
  final int? stars;

  /// A replay raised the level's best stars (`GameplayState.starsNewBest`):
  /// the card's "New best!".
  final bool starsNewBest;

  /// The replay card's 3-star target, only below 3 stars and only on a
  /// replay whose moves were over it (`GameplayState.starTarget`, Q118).
  final int? starTarget;

  /// The first win ever below 3 stars (`GameplayState.starTip`, Q119): the
  /// card's one-time tip.
  final bool starTip;

  /// A hint or an extra slot held the win to 2 stars
  /// (`GameplayState.starsCapped`, Q145): the card's helper note.
  final bool starsCapped;

  /// A Bonus Endless win's level number: the progress card counts the
  /// 10-level chest cycle (frame 12.4).
  final int? bonusNumber;

  /// The daily's date, for the Share text (frame 10.1).
  final LocalDate? dailyDate;

  /// The win card's moves caption (E7; m7-design §11, §15.3): "Moves N ·
  /// Best M" with a kept best, "Moves N" alone otherwise; null with
  /// neither (an older caller, or before the bloc reports them).
  String? movesCaption(AppLocalizations l10n) {
    final moves = winMoves;
    if (moves == null) return null;
    final best = bestMoves;
    return best == null
        ? l10n.winMovesOnly(moves)
        : l10n.winMovesBest(moves, best);
  }

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

/// Level complete (frames 2.8, 11.2–11.2d, 11.4–11.4c, 10.1, 12.4; spec §10.2
/// #4; docs/plans/m7-design.md P4.7; ui-spec-game §2.2), timed by
/// [WinOverlaySchedule] from the overlay's open:
/// - the scrim, and `fx_confetti` bursting from the ribbon (not under
///   reduced motion), with three `fx_twinkle`s behind the ribbon;
/// - `ui_win_ribbon` with the localized "Level Complete!" (§12);
/// - `ui_stars` (`StarRow.reveal`) revealing this win's stars from 1,300 ms,
///   each with its sound and haptic (a campaign win or a replay);
/// - each completed family's doll hopping on a plank (`doll_win_hop`, 150 ms
///   apart), drawn from the level's part rasters;
/// - at 700 ms `fx_coin_burst` on the "+N" chip's coin and the count-up to
///   the reward, with the `coins` sound (none on a replay), beside the moves
///   chip ("New best!" on it after a replay that raised the stars);
/// - the progress card (a replay's reason card), the helper note or the
///   one-time tip, then Continue (Share above Back to Daily on the daily).
///
/// The badge toasts queue on a host of their own at y 60, so they leave with
/// the card (`ToastHost`, Q122, Q136).
///
/// TODO(M6): the ×3 rewarded-video button and its "Reward added" state
/// (frames 2.8, 2.9); hidden until ads exist, as the design does offline,
/// where Continue takes its slot (C12).
class WinOverlay extends StatelessWidget {
  const WinOverlay({
    required this.summary,
    required this.onContinue,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    this.feedback,
    this.library,
    this.uiArt,
    this.share,
    this.onTipShown,
    super.key,
  });

  final WinSummary summary;
  final VoidCallback onContinue;

  /// The level's part rasters (`LevelSkin.images`) for the hopping dolls.
  final FxImageSource? images;

  /// Draws the dolls still when there are no rasters.
  final DollRenderer? renderer;
  final DollSymbols symbols;

  /// Plays the overlay's `win`, `coins` and star cues; null is silent.
  final FeedbackSink? feedback;
  final FxLibrary? library;

  /// The UI art behind `ui_stars` (the DI one by default).
  final UiArtLibrary? uiArt;

  /// The daily card's Share (`DailyShareText.of` then the OS sheet); null
  /// hides the button.
  final ShareService? share;

  /// The card showed the one-time tip: the view records it
  /// (`SaveService.markStarTipShown`, D191) so it waits for a card that can
  /// show it.
  final VoidCallback? onTipShown;

  /// The ribbon's centre below the safe-area top (NestyOverlay: 150 on a
  /// 59 safe area); the confetti bursts from here.
  static const double ribbonCenter = 91;

  /// `ui_win_ribbon`'s canvas (`LottieLabelStyles.winRibbon.canvas`): the
  /// ribbon row is this tall, and the canvas is drawn in it at full size,
  /// centred on the row, so it overhangs both edges of a phone narrower
  /// than 410 dp. What it draws fits: the 290 band with its tails to 334,
  /// or a band of the screen − 70 on a narrower phone (LOTTIE.md m7-5).
  static const Size ribbonCanvas = Size(410, 110);

  /// The ribbon's row, for tests.
  @visibleForTesting
  static const Key ribbonKey = Key('win-ribbon');

  /// The note or tip pill, for tests.
  @visibleForTesting
  static const Key noteKey = Key('win-note');

  /// The daily card's Share button, for tests.
  @visibleForTesting
  static const Key shareKey = Key('win-share');

  @override
  Widget build(BuildContext context) => ToastHost(
    top: ToastHost.badgeTop,
    child: _WinOverlayBody(
      summary: summary,
      onContinue: onContinue,
      images: images,
      renderer: renderer,
      symbols: symbols,
      feedback: feedback,
      library: library,
      uiArt: uiArt,
      share: share,
      onTipShown: onTipShown,
    ),
  );
}

class _WinOverlayBody extends StatefulWidget {
  const _WinOverlayBody({
    required this.summary,
    required this.onContinue,
    required this.images,
    required this.renderer,
    required this.symbols,
    required this.feedback,
    required this.library,
    required this.uiArt,
    required this.share,
    required this.onTipShown,
  });

  final WinSummary summary;
  final VoidCallback onContinue;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FeedbackSink? feedback;
  final FxLibrary? library;
  final UiArtLibrary? uiArt;
  final ShareService? share;
  final VoidCallback? onTipShown;

  @override
  State<_WinOverlayBody> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<_WinOverlayBody>
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
  final GlobalKey _shareKey = GlobalKey();
  WinOverlaySchedule? _schedule;
  late CelebrationLayout _layout;
  late CelebrationVariant _variant;
  bool _showHelper = false;
  bool _showTip = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_schedule != null) return;
    final summary = widget.summary;
    final motion = MotionSpec.of(reduceMotion: context.reduceMotion);
    final schedule = WinOverlaySchedule.of(
      motion,
      families: summary.families.length,
      stars: summary.stars,
    );
    _schedule = schedule;
    final isReplay = summary.isReplay;
    _variant = isReplay
        ? CelebrationVariant.replay
        : summary.stars == null || summary.dailyStreak != null
        ? CelebrationVariant.plain
        : CelebrationVariant.campaign;
    // The helper note wins over the tip: one note, never both. Every height
    // has room for it now (the card blends by height, `layout.sizeBlend`,
    // m7-4 4.12), so it shows wherever the card has stars. The tip is
    // recorded only when it shows (D191).
    final canNote =
        _variant != CelebrationVariant.plain && summary.stars != null;
    _showHelper = canNote && summary.starsCapped;
    _showTip = canNote && !_showHelper && summary.starTip;
    _layout = CelebrationLayout.of(
      _variant,
      screenHeight: MediaQuery.sizeOf(context).height,
      families: summary.families.length,
      withNote: _showHelper || _showTip,
    );
    _ribbon.playWhole();
    _confetti.playWhole();
    _burst.rest(0);
    _countUp.duration = Duration(
      milliseconds: (schedule.countUpEndMs - schedule.countUpStartMs).round(),
    );
    for (final cue in schedule.cues) {
      // A replay pays no coins (E7; m7-design §11): no `coins` sound, burst
      // or count-up: only the open's `win` cue plays.
      if (isReplay && cue.sound == SoundEffect.coins) continue;
      _at(cue.atMs, () => widget.feedback?.play(cue));
    }
    if (!isReplay) {
      _at(schedule.coinBurstAtMs, _burst.playWhole);
      _at(schedule.countUpStartMs, () => _countUp.forward());
    }
    // A badge earned toast each, a little after the overlay opens and one
    // after the other (E8; m7-design §12); the queue spaces them (Q136).
    final badges = summary.newBadges;
    for (var i = 0; i < badges.length; i++) {
      final badge = badges[i];
      _at(motion.ms(_badgeToastStartMs + _badgeToastStaggerMs * i), () {
        if (mounted) BadgeToast.show(context, badge);
      });
    }
    if (_showTip) _at(0, () => widget.onTipShown?.call());
  }

  /// A few hundred ms after the overlay opens (past the ribbon's pop),
  /// before the coin pill would draw attention (§9.7, hand-picked: no frame
  /// times the badge toasts).
  static const double _badgeToastStartMs = 900;
  static const double _badgeToastStaggerMs = 350;

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

  /// `StarRow.reveal`'s `onStar` (m7-design P4.7): star [star] (1-based)
  /// starts, so its cue plays now. Under reduced motion there is one cue,
  /// for the highest star.
  void _onStar(int star) {
    final cues = _schedule?.starCues ?? const <FxCue>[];
    if (cues.isEmpty) return;
    widget.feedback?.play(cues[star.clamp(1, cues.length) - 1]);
  }

  /// The success haptic after the 3-star flourish.
  void _onFlourishEnd() {
    final cue = _schedule?.starFlourishCue;
    if (cue != null) widget.feedback?.play(cue);
  }

  Future<void> _share() {
    final summary = widget.summary;
    final service = widget.share;
    final date = summary.dailyDate;
    final streak = summary.dailyStreak;
    if (service == null || date == null || streak == null) {
      return Future.value();
    }
    final box = _shareKey.currentContext?.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    final text = DailyShareText.of(
      context.localizations,
      localeName: Localizations.localeOf(context).toString(),
      data: (
        date: date,
        families: summary.families,
        moves: summary.winMoves ?? 0,
        streakDay: streak,
        streakLit: streak > 0,
      ),
    );
    return service.shareText(text, origin: origin);
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
          if (widget.summary.dailyStreak == null)
            ..._twinkles(width, padding.top),
          content,
        ],
      ),
      // On a short phone the block above the button scales down to fit,
      // but the button keeps its height under it: scaled with the rest, it
      // fell under 48 dp at 360 × 640 once the stars and the tip were in
      // (review R23). It takes the scaled card's width, so the two keep
      // frame 2.8's one width (the device run after the review). Where
      // everything fits, the button sits at `buttonsTop` exactly.
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => _BlockOverButton(
            inset: _cardInset,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: _content(context, schedule),
                ),
              ),
              _buttons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// The three `fx_twinkle`s (E.17; `layout.winTwinkles`): above the scrim,
  /// behind the ribbon, 2.0–2.4 s with a phase each; still under reduced
  /// motion.
  List<Widget> _twinkles(double width, double safeTop) {
    const periods = [2000.0, 2400.0, 2200.0];
    const phases = [0.0, 700.0, 1300.0];
    const sizes = [22.0, 26.0, 18.0];
    final points = WinTwinklesTokens.points;
    return [
      for (var i = 0; i < points.length; i++)
        Positioned(
          left: points[i].dx * width / 390 - sizes[i] / 2,
          top: safeTop + CelebrationLayout.below(points[i].dy) - sizes[i] / 2,
          child: LottieTwinkle(
            size: sizes[i],
            periodMs: periods[i],
            phaseMs: phases[i],
            library: widget.library,
          ),
        ),
    ];
  }

  /// The card's and the button's side inset at full size (NestyOverlay:
  /// both at left/right 28).
  static const double _cardInset = 28;

  Widget _content(BuildContext context, WinOverlaySchedule schedule) {
    final l10n = context.localizations;
    final summary = widget.summary;
    final layout = _layout;
    final dailyStreak = summary.dailyStreak;
    final isReplay = summary.isReplay;
    final fullTitle = dailyStreak == null ? l10n.winTitle : l10n.dailyWinTitle;
    // textFit.winRibbon: the short form when the full title would shrink
    // below its minScale (the daily's title has none).
    // The band is 290, or the screen − 70 on a narrower phone (m7-5), and
    // the title's box narrows with it.
    final bandWidth = FxRibbon.win.bandWidthFor(
      MediaQuery.sizeOf(context).width,
    );
    _ribbon.params.ribbonBandWidth = bandWidth;
    final ribbonStyle = FxRibbon.win.labelFor(bandWidth);
    final title = dailyStreak == null
        ? RibbonLabel.pick(
            context,
            style: ribbonStyle,
            full: fullTitle,
            short: l10n.winTitleShort,
            minScale: TextFitTokens.winRibbonMinScale,
          )
        : fullTitle;
    final movesCaption = summary.movesCaption(l10n);
    const canvas = WinOverlay.ribbonCanvas;
    final coinChip = WinCoinPill(
      reward: summary.reward,
      countUp: _countCurve,
      burst: LottieFxView(
        id: FxId.fxCoinBurst,
        controller: _burst,
        library: widget.library,
      ),
    );
    final movesChip = movesCaption == null
        ? null
        : WinMovesChip(text: movesCaption, newBest: summary.starsNewBest);
    final note = _showHelper
        ? l10n.starsHelperNote
        : _showTip
        ? l10n.starsFirstTip
        : null;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: layout.blockHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: CelebrationLayout.below(layout.cardTop),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: CelebrationLayout.below(layout.ribbonCanvasTop),
                  height: canvas.height,
                  // The ribbon's title names the overlay's route (review
                  // R11).
                  child: Semantics(
                    header: true,
                    namesRoute: true,
                    child: SizedBox(
                      key: WinOverlay.ribbonKey,
                      width: double.infinity,
                      height: canvas.height,
                      // The canvas may be wider than the screen: it overflows
                      // the row on both sides, centred on the anchor
                      // (205, 55).
                      child: OverflowBox(
                        minWidth: canvas.width,
                        maxWidth: canvas.width,
                        minHeight: canvas.height,
                        maxHeight: canvas.height,
                        child: LottieTextOverlay(
                          label: title,
                          semanticLabel: fullTitle,
                          style: ribbonStyle,
                          lottie: LottieFxView(
                            id: FxId.uiWinRibbon,
                            controller: _ribbon,
                            library: widget.library,
                            label: title,
                            labelStyle: ribbonStyle,
                            fallback: CustomPaint(
                              painter: RibbonRestPainter(
                                ribbon: FxRibbon.win,
                                colors: WinRibbonTokens.defaultColors,
                                bandWidth: bandWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (layout.hasStars && summary.stars != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: CelebrationLayout.below(layout.starsTop!),
                    child: Center(
                      child: StarRow.reveal(
                        count: summary.stars!,
                        delay: Duration(
                          milliseconds: schedule.starsStartMs.round(),
                        ),
                        onStar: _onStar,
                        onFlourishEnd: _onFlourishEnd,
                        newBest: summary.starsNewBest,
                        library: widget.library,
                        artLibrary: widget.uiArt,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: _Families(
                    families: summary.families,
                    startsMs: schedule.hopStartsMs,
                    plankTop: CelebrationLayout.below(layout.plankTop),
                    dollHeight: layout.dollHeight,
                    images: widget.images,
                    renderer: widget.renderer,
                    symbols: widget.symbols,
                    library: widget.library,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: CelebrationLayout.below(layout.chipsTop),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isReplay) coinChip,
                        if (!isReplay && movesChip != null)
                          const SizedBox(width: WinStarsTokens.coinRowGap),
                        ?movesChip,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _cardInset),
            child: isReplay
                ? ReplayReasonCard(starTarget: summary.starTarget)
                : dailyStreak == null
                ? WinChapterCard(
                    progress: summary.chapter,
                    chestLevelsLeft: summary.chestLevelsLeft,
                    bonusNumber: summary.bonusNumber,
                  )
                : DailyStreakCard(
                    streak: dailyStreak,
                    relit: summary.dailyRelit,
                    library: widget.library,
                  ),
          ),
          if (note != null) ...[
            SizedBox(height: layout.noteGap),
            KeyedSubtree(
              key: WinOverlay.noteKey,
              child: WinNotePill(text: note),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    final l10n = context.localizations;
    final summary = widget.summary;
    final gap = _layout.buttonsGap;
    final canShare =
        summary.dailyStreak != null &&
        widget.share != null &&
        summary.dailyDate != null;
    // Its side insets come from [_BlockOverButton]: the card's, scaled.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canShare) ...[
            KeyedSubtree(
              key: _shareKey,
              child: TactileButton(
                key: WinOverlay.shareKey,
                label: l10n.dailyShare,
                semanticLabel: l10n.dailyShareSemantics,
                variant: TactileButtonVariant.secondary,
                icon: IconUses.shareFor(defaultTargetPlatform),
                onPressed: () => unawaited(_share()),
              ),
            ),
            SizedBox(height: gap),
          ],
          TactileButton(
            label: summary.isReplay
                ? l10n.winBackToChapters
                : summary.dailyStreak == null
                ? l10n.winContinue
                : l10n.dailyBackToDaily,
            onPressed: widget.onContinue,
          ),
        ],
      ),
    );
  }
}

/// The win overlay's block over its button: `children` are the block (a
/// scale-down [FittedBox]) and the button, in that order.
///
/// The block gets the height the button leaves and is centred at the top;
/// its laid-out width gives the scale it took. The button keeps its own
/// height, so its target stays whole (review R23), and is laid out at the
/// card's width at that scale, `(W − 2 × inset) × scale`, centred under
/// the block. At scale 1 this is the plain column it was: the button 28
/// from each edge, right under the block.
class _BlockOverButton extends MultiChildRenderObjectWidget {
  const _BlockOverButton({required this.inset, required super.children})
    : assert(children.length == 2, 'the block, then the button');

  final double inset;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBlockOverButton(inset);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBlockOverButton renderObject,
  ) => renderObject.inset = inset;
}

final class _BlockOverButtonParentData
    extends ContainerBoxParentData<RenderBox> {}

final class _RenderBlockOverButton extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BlockOverButtonParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BlockOverButtonParentData> {
  _RenderBlockOverButton(this._inset);

  double _inset;
  set inset(double value) {
    if (value == _inset) return;
    _inset = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BlockOverButtonParentData) {
      child.parentData = _BlockOverButtonParentData();
    }
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      constraints.biggest;

  @override
  void performLayout() {
    final block = firstChild!;
    final button = childAfter(block)!;
    final width = constraints.maxWidth;
    final fullButton = math.max(0.0, width - 2 * _inset);
    // The button's height doesn't depend on its width (a fixed-height
    // face): measure it at full size, then lay the block out above it.
    button.layout(
      BoxConstraints.tightFor(width: fullButton),
      parentUsesSize: true,
    );
    final buttonHeight = button.size.height;
    block.layout(
      BoxConstraints(
        maxWidth: width,
        maxHeight: math.max(0.0, constraints.maxHeight - buttonHeight),
      ),
      parentUsesSize: true,
    );
    final scale = width > 0 ? math.min(1.0, block.size.width / width) : 1.0;
    final buttonWidth = fullButton * scale;
    if (buttonWidth != fullButton) {
      button.layout(
        BoxConstraints.tightFor(width: buttonWidth),
        parentUsesSize: true,
      );
    }
    (block.parentData! as _BlockOverButtonParentData).offset = Offset(
      (width - block.size.width) / 2,
      0,
    );
    (button.parentData! as _BlockOverButtonParentData).offset = Offset(
      (width - button.size.width) / 2,
      block.size.height,
    );
    // The whole safe area, as the column it replaces took.
    size = constraints.hasBoundedHeight
        ? constraints.biggest
        : constraints.constrain(
            Size(width, block.size.height + button.size.height),
          );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// The families hopping on their plank (frame 2.8: a 30 dp plank at
/// [plankTop], bases 11 below it, `min(84, 330 / n)` apart, [dollHeight]
/// tall).
class _Families extends StatelessWidget {
  const _Families({
    required this.families,
    required this.startsMs,
    required this.plankTop,
    required this.dollHeight,
    required this.images,
    required this.renderer,
    required this.symbols,
    required this.library,
  });

  final List<DollColor> families;
  final List<double> startsMs;
  final double plankTop;
  final double dollHeight;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FxLibrary? library;

  /// Family [i]'s hop start (150 ms apart, halved under reduced motion).
  Duration _delay(int i) => Duration(
    microseconds: i < startsMs.length ? (startsMs[i] * 1000).round() : 0,
  );

  @override
  Widget build(BuildContext context) {
    final n = families.length;
    final pitch = n == 0 ? 0.0 : (330 / n).clamp(0.0, 84.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = constraints.maxWidth / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 10,
              right: 10,
              top: plankTop,
              child: const PlankStrip(height: CelebrationLayout.plankHeight),
            ),
            for (var i = 0; i < n; i++)
              LottieDoll.positioned(
                centerX: center + (i - (n - 1) / 2) * pitch,
                baseY: plankTop + CelebrationLayout.dollBaseBelowPlank,
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
        );
      },
    );
  }
}

/// The "+25" pill (NestyOverlay: 10/20/10/10 padding, radius 26, a 38 px
/// coin, 30/700 `#8C5E12`), counting up from 0 with [countUp], and
/// `fx_coin_burst` anchored (80, 100) on its coin. The race's win card
/// (frame 9.4) shows the same pill (m7-design P2.10).
class WinCoinPill extends StatelessWidget {
  const WinCoinPill({
    required this.reward,
    required this.countUp,
    required this.burst,
    super.key,
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
