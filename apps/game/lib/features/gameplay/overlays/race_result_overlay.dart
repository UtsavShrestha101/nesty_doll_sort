import 'dart:async';

import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/music/music_duck.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/widgets/race/race_coin_chip.dart';
import 'package:nesty_game/core/ui/widgets/race/versus_ribbon.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';
import 'package:nesty_game/features/gameplay/game/timeline/win_overlay_schedule.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_text_link.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart'
    show WinSummary;
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart'
    show GameplayOverlay;
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_render/nesty_render.dart' show DollRenderer, DollSymbols;

/// What a result card's button asks for, held while 9.6's card is up
/// (`_RaceResultLayerState._pending`).
enum _Exit { rematch, newRace, back }

/// A race's result over the board (frames 9.4, 9.5, 9.6; phase 4 architecture
/// §6.6): [RaceWinCard] for [GameplayOverlay.raceWin], [RaceLossCard] for
/// [GameplayOverlay.raceLoss], from the [race]'s state, with the music
/// ducked to `sound.musicDuck.raceResult` (0.3) while it is up.
///
/// - Two buttons and no third control: system back returns to rival select
///   (lead note 9), as "Back to races" did.
/// - Badge toasts sit at the scoped [ToastHost]'s top 60, above the ribbon,
///   one at a time, and leave with the card (D187).
/// - A first win that unlocked the next rival shows 9.6 ([RivalUnlockedCard])
///   once, as 9.4 closes: any button on 9.4 (or system back) opens it first.
///   Its New race starts a fresh race against the unlocked rival
///   (`RaceCubit.chooseNextRival`, then the view's own New race); Not now
///   does what the player tapped on 9.4. A Rematch's win never unlocks
///   anything, so it shows once per rival (`outcome.unlockedRival`).
/// - While [continuing] (Rematch or New race is loading its board) every
///   button is a no-op, so a second tap sends nothing.
///
/// The view hands it the skin's part rasters ([images], [renderer],
/// [symbols]) for the dolls on the plank; without them the placeholder doll
/// draws (rule 3).
class RaceResultLayer extends StatefulWidget {
  const RaceResultLayer({
    required this.race,
    required this.overlay,
    required this.state,
    required this.services,
    required this.continuing,
    required this.onRematch,
    required this.onNewRace,
    required this.onBackToRaces,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final RaceCubit race;

  /// [GameplayOverlay.raceWin] or [GameplayOverlay.raceLoss].
  final GameplayOverlay overlay;

  /// The bloc's state (the level and board the dolls come from).
  final GameplayState state;
  final GameplayServices services;
  final bool continuing;
  final VoidCallback onRematch;
  final VoidCallback onNewRace;

  /// Back to rival select (the system back on the card does the same).
  final VoidCallback onBackToRaces;

  /// The level skin's part rasters and renderer, for the plank's dolls.
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;

  @override
  State<RaceResultLayer> createState() => _RaceResultLayerState();
}

class _RaceResultLayerState extends State<RaceResultLayer> {
  /// 9.6 is up, holding what to do when it closes.
  _Exit? _pending;

  /// 9.6 was shown for this race's outcome: never twice.
  bool _unlockShown = false;

  void _perform(_Exit exit) {
    if (widget.continuing) return;
    switch (exit) {
      case _Exit.rematch:
        widget.onRematch();
      case _Exit.newRace:
        widget.onNewRace();
      case _Exit.back:
        widget.onBackToRaces();
    }
  }

  /// Any exit of 9.4: 9.6 first when this win unlocked a rival, once.
  void _exit(_Exit exit, int? unlockedRival) {
    if (widget.continuing) return;
    if (widget.overlay == GameplayOverlay.raceWin &&
        unlockedRival != null &&
        !_unlockShown) {
      setState(() {
        _unlockShown = true;
        _pending = exit;
      });
      return;
    }
    _perform(exit);
  }

  void _unlockedNewRace(int rival) {
    if (widget.continuing) return;
    widget.race.chooseNextRival(rival);
    _perform(_Exit.newRace);
  }

  void _unlockedNotNow() {
    final exit = _pending ?? _Exit.back;
    _perform(exit);
  }

  @override
  void didUpdateWidget(RaceResultLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new result (Rematch or New race, then another finish) starts clean.
    if (oldWidget.overlay != widget.overlay) {
      _pending = null;
      _unlockShown = false;
    }
  }

  @override
  Widget build(BuildContext context) => MusicDuck(
    music: widget.services.music,
    reason: DuckReason.raceResult,
    child: ToastHost(
      top: ToastHost.badgeTop,
      child: BlocBuilder<RaceCubit, AsyncValue<RaceState>>(
        bloc: widget.race,
        builder: (context, raceValue) {
          final raceState = raceValue.data;
          if (raceState == null) return const SizedBox.shrink();
          final unlocked = raceState.outcome?.unlockedRival;
          final services = widget.services;
          final Widget card;
          if (_pending != null && unlocked != null) {
            card = RivalUnlockedCard(
              key: const ValueKey('rivalUnlocked'),
              rival: unlocked,
              jingles: services.jingles,
              onNewRace: () => _unlockedNewRace(unlocked),
              onNotNow: _unlockedNotNow,
            );
          } else if (widget.overlay == GameplayOverlay.raceWin) {
            card = RaceWinCard(
              rival: raceState.rival,
              families: _families(),
              rewardCoins: raceState.outcome?.coins ?? 0,
              newBadges: raceState.outcome?.newBadges ?? const [],
              feedback: services.feedback,
              jingles: services.jingles,
              library: services.fx,
              images: widget.images,
              renderer: widget.renderer,
              symbols: widget.symbols,
              onRematch: () => _exit(_Exit.rematch, unlocked),
              onNewRace: () => _exit(_Exit.newRace, unlocked),
            );
          } else {
            card = RaceLossCard(
              rival: raceState.rival,
              families: _families(),
              jingles: services.jingles,
              library: services.fx,
              images: widget.images,
              renderer: widget.renderer,
              symbols: widget.symbols,
              onRematch: () => _exit(_Exit.rematch, null),
              onNewRace: () => _exit(_Exit.newRace, null),
            );
          }
          // System back is "Back to races" (9.2), or 9.6's Not now.
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              if (_pending != null) {
                _unlockedNotNow();
              } else {
                _exit(_Exit.back, unlocked);
              }
            },
            child: card,
          );
        },
      ),
    ),
  );

  /// The families the player completed on this board, in board order (a
  /// loss shows only these, frame 9.5).
  List<DollColor> _families() =>
      WinSummary.familiesOf(widget.state.entry.level, widget.state.board);
}

/// The shared top of both results: the plank at `y 350` (291 below the safe
/// top) with the player's completed families on it, bases at 361, `min(84,
/// 330 / n)` apart, 104 tall (88 above four), under the [VersusRibbon] whose
/// centre sits 91 below the safe top. [hop] makes the dolls hop, 150 ms
/// apart (9.4); without it they stand still on the plank (9.5).
class _RaceHeaderBlock extends StatelessWidget {
  const _RaceHeaderBlock({
    required this.title,
    required this.shortTitle,
    required this.families,
    required this.hop,
    required this.startsMs,
    required this.images,
    required this.renderer,
    required this.symbols,
    required this.library,
    this.twinkle = false,
  });

  final String title;
  final String shortTitle;
  final List<DollColor> families;
  final bool hop;
  final List<double> startsMs;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FxLibrary? library;
  final bool twinkle;

  /// The block's height down to the plank's bottom.
  static const double height = 321;
  static const double _plankTop = 291;
  static const double _base = _plankTop + 11;
  static const double _ribbonCenter = 91;

  @override
  Widget build(BuildContext context) {
    final n = families.length;
    final pitch = n == 0 ? 0.0 : (330 / n).clamp(0.0, 84.0);
    final dollHeight = n > 4 ? 88.0 : 104.0;
    final width = MediaQuery.sizeOf(context).width;
    final ribbonScale = width >= 390 ? 1.0 : width / 390;
    final ribbonSize = VersusRibbon.canvas * ribbonScale;
    // Still dolls: the file rests on frame 0 when motion is reduced.
    Widget doll(int i, double center) => LottieDoll.positioned(
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
        startDelay: Duration(
          microseconds: hop && i < startsMs.length
              ? (startsMs[i] * 1000).round()
              : 0,
        ),
      ),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center = constraints.maxWidth / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (twinkle)
                for (var i = 0; i < WinTwinklesTokens.points.length; i++)
                  Positioned(
                    left:
                        WinTwinklesTokens.points[i].dx * width / 390 -
                        _twinkleSize / 2,
                    top: WinTwinklesTokens.points[i].dy - 59 - _twinkleSize / 2,
                    child: LottieTwinkle(
                      size: _twinkleSize,
                      periodMs: 2000.0 + 200 * i,
                      phaseMs: 700.0 * i,
                      library: library,
                    ),
                  ),
              const Positioned(
                left: 10,
                right: 10,
                top: _plankTop,
                child: PlankStrip(height: 30),
              ),
              for (var i = 0; i < n; i++)
                if (hop)
                  doll(i, center)
                else
                  // Standing still: a paused ambient loop, as under reduced
                  // motion (D48).
                  Positioned.fill(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(disableAnimations: true),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [doll(i, center)],
                      ),
                    ),
                  ),
              Positioned(
                left: 0,
                right: 0,
                top: _ribbonCenter - ribbonSize.height / 2,
                height: ribbonSize.height,
                child: OverflowBox(
                  minWidth: ribbonSize.width,
                  maxWidth: ribbonSize.width,
                  child: VersusRibbon(
                    title: title,
                    shortTitle: shortTitle,
                    library: library,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const double _twinkleSize = 22;
}

/// The rival's card of both results (frames 9.4, 9.5): [RivalPortrait] 56,
/// the name and [ComputerTag], and the body line (`raceWinBody`,
/// `raceLossBody`) on an `InfoCard` (left/right 28, radius 22, cream at
/// .97, a 5 dp `#D8B07A` edge). Read as one "{name}, Computer. {body}".
class _RivalCard extends StatelessWidget {
  const _RivalCard({
    required this.rival,
    required this.body,
    required this.reaction,
    required this.library,
  });

  final int rival;
  final String body;

  /// The portrait's one-shot: a nod on 9.4, a hop on 9.5 (`ui_rival_react`).
  final RivalReaction reaction;
  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(rival);
    return Semantics(
      label: l10n.joinSentences([l10n.raceRivalSemantics(name), body]),
      container: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReplayCardTokens.cardFill,
          borderRadius: const BorderRadius.all(
            Radius.circular(ReplayCardTokens.cardRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: ReplayCardTokens.cardEdge.color,
              offset: Offset(0, ReplayCardTokens.cardEdge.width),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(
            children: [
              RivalReact(
                number: rival,
                size: 56,
                reaction: reaction,
                library: library,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              name,
                              style: AppTextStyleTokens.cardTitle.copyWith(
                                fontSize: 18,
                                color: AppColorTokens.textPrimary,
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ComputerTag.responsive(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: AppTextStyleTokens.bodySmall.copyWith(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: AppColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two buttons of both results at y 630 (571 below the safe top): the
/// [primary] `VersusButton`, then the [secondary] `SecondaryButton`, 14
/// apart, each 58 tall, inset 28. 9.4 is New race then Rematch; 9.5
/// Rematch then New race.
class _Buttons extends StatelessWidget {
  const _Buttons({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TactileButton(
        label: primaryLabel,
        variant: TactileButtonVariant.versus,
        onPressed: onPrimary,
      ),
      const SizedBox(height: 14),
      TactileButton(
        label: secondaryLabel,
        variant: TactileButtonVariant.secondary,
        onPressed: onSecondary,
      ),
    ],
  );
}

/// The block both results share: it lays [children] out at the frames'
/// 390 dp design width, top-aligned below the safe area, and scales the
/// whole block down when the screen is shorter or the text larger (a card
/// never scrolls or overflows: `_BlockOverButton`'s rule, 9.4 "Text scale").
class _ResultShell extends StatelessWidget {
  const _ResultShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The screen reader's announcement of the result, a hidden live region
/// (`raceAnnounceWon`, `raceAnnounceLost`).
class _Announce extends StatelessWidget {
  const _Announce(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Semantics(liveRegion: true, label: text, child: const SizedBox.shrink());
}

/// Frame 9.4, "You won the race!" (vs Computer; spec-prop §7.7; phase 4
/// ui-spec-game §2.1): the ribbon in versus's indigo, the player's completed
/// families hopping on the plank, the reward chip "+20 coins" (shown in
/// advance on the select card already, spec-prop §1.1 rule 2, and paid once,
/// `SaveService.recordRaceWin`; no moves chip, no stars: Q88, D125), the
/// rival's card, then New race and Rematch.
///
/// 2.8's celebration, timed by [WinOverlaySchedule] from the card's open:
/// `fx_confetti` from the ribbon (not under reduced motion), `jingle_versus_win`
/// at 0 in place of the `win` sound with the win haptic, `fx_twinkle` at
/// E.17's points, then `fx_coin_burst` on the chip's coin, the `coins`
/// sound and the count-up. Badge toasts queue at 900 ms on the layer's host.
/// Reduced motion: no confetti, hop or burst; the count-up at half length.
class RaceWinCard extends StatefulWidget {
  const RaceWinCard({
    required this.rival,
    required this.rewardCoins,
    required this.onRematch,
    required this.onNewRace,
    this.families = const <DollColor>[],
    this.newBadges = const <BadgeId>[],
    this.feedback,
    this.jingles,
    this.library,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final int rival;
  final int rewardCoins;

  /// The player's completed families, in board order.
  final List<DollColor> families;

  /// One toast each, queued (E8; m7-design §12).
  final List<BadgeId> newBadges;

  final VoidCallback onRematch;
  final VoidCallback onNewRace;

  /// Plays the card's win haptic and `coins` cue; null is silent.
  final FeedbackSink? feedback;

  /// Plays `jingle_versus_win`; null is silent.
  final JinglePlayer? jingles;
  final FxLibrary? library;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;

  /// The ribbon's centre below the safe-area top (`CelebrationLayout.plain`:
  /// 91): the confetti bursts from here.
  static const double ribbonCenter = 91;

  @override
  State<RaceWinCard> createState() => _RaceWinCardState();
}

class _RaceWinCardState extends State<RaceWinCard>
    with SingleTickerProviderStateMixin {
  final LottieFxController _confetti = LottieFxController(FxId.fxConfetti);
  final LottieFxController _burst = LottieFxController(FxId.fxCoinBurst);
  late final AnimationController _countUp = AnimationController(vsync: this);
  late final CurvedAnimation _countCurve = CurvedAnimation(
    parent: _countUp,
    curve: UiMotionTokens.curveEaseOut,
  );
  final List<Timer> _timers = [];
  WinOverlaySchedule? _schedule;

  /// After the card opens, before the badge toasts (hand-picked, as
  /// `WinOverlay`'s own).
  static const double _badgeToastAtMs = 900;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_schedule != null) return;
    final motion = MotionSpec.of(reduceMotion: context.reduceMotion);
    final schedule = WinOverlaySchedule.of(
      motion,
      families: widget.families.length,
    );
    _schedule = schedule;
    final paid = widget.rewardCoins > 0;
    if (schedule.confetti != null) _confetti.playWhole();
    _burst.rest(0);
    _countUp.duration = Duration(
      milliseconds: (schedule.countUpEndMs - schedule.countUpStartMs).round(),
    );
    // The jingle replaces the `win` sound; the win haptic stays.
    widget.jingles?.playJingle(Jingle.versusWin);
    widget.feedback?.play(const FxCue(atMs: 0, haptic: HapticPattern.win));
    for (final cue in schedule.cues) {
      if (cue.sound != SoundEffect.coins || !paid) continue;
      _at(cue.atMs, () => widget.feedback?.play(cue));
    }
    if (paid) {
      _at(schedule.coinBurstAtMs, _burst.playWhole);
      _at(schedule.countUpStartMs, () => _countUp.forward());
    } else {
      _countUp.value = 1;
    }
    for (final badge in widget.newBadges) {
      _at(motion.ms(_badgeToastAtMs), () => BadgeToast.show(context, badge));
    }
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
    _confetti.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(widget.rival);
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    // fx_confetti's canvas is the reference screen, scaled W/390 about its
    // burst point (195, 190), which lands on the ribbon (lottie §5).
    final confettiScale = width / 390;
    final confetti = _schedule?.confetti != null;
    final hopStarts = _schedule?.hopStartsMs ?? const <double>[];
    return OverlayEntrance(
      kind: OverlayEntranceKind.fade,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          if (confetti)
            Positioned(
              left: 0,
              top: padding.top + RaceWinCard.ribbonCenter - 190 * confettiScale,
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
      child: _ResultShell(
        children: [
          _Announce(l10n.raceAnnounceWon),
          _RaceHeaderBlock(
            title: l10n.raceWinTitle,
            shortTitle: l10n.raceWinTitleShort,
            families: widget.families,
            hop: true,
            startsMs: hopStarts,
            images: widget.images,
            renderer: widget.renderer,
            symbols: widget.symbols,
            library: widget.library,
            twinkle: !context.reduceMotion,
          ),
          const SizedBox(height: 24),
          Center(
            child: RaceCoinChip(
              reward: widget.rewardCoins,
              countUp: _countCurve,
              burst: LottieFxView(
                id: FxId.fxCoinBurst,
                controller: _burst,
                library: widget.library,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _RivalCard(
              rival: widget.rival,
              body: l10n.raceWinBody(name),
              // The player finished first: the rival nods.
              reaction: RivalReaction.lose,
              library: widget.library,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _Buttons(
              primaryLabel: l10n.raceNewRace,
              secondaryLabel: l10n.raceRematch,
              onPrimary: widget.onNewRace,
              onSecondary: widget.onRematch,
            ),
          ),
        ],
      ),
    );
  }
}

/// Frame 9.5, "So close! Rematch?" (m7-design P2.10; ui-spec-game §2.1):
/// the same shell as 9.4 with no coin chip and no confetti, in the plain
/// `scrim` (never `scrimStrong`), no red anywhere. Only the families the
/// player completed, standing still on the plank; the rival's card with its
/// warm body ("{rival} finished first this time. A rematch costs nothing.");
/// Rematch (primary) then New race. `jingle_versus_lose` plays at the open,
/// under the layer's 0.3 duck, with no haptic and no twinkle. No reward, no
/// move count, no comparison (vs-computer rule 10).
class RaceLossCard extends StatefulWidget {
  const RaceLossCard({
    required this.rival,
    required this.onRematch,
    required this.onNewRace,
    this.families = const <DollColor>[],
    this.jingles,
    this.library,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final int rival;
  final VoidCallback onRematch;
  final VoidCallback onNewRace;

  /// The player's completed families, in board order.
  final List<DollColor> families;

  /// Plays `jingle_versus_lose`; null is silent.
  final JinglePlayer? jingles;
  final FxLibrary? library;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;

  @override
  State<RaceLossCard> createState() => _RaceLossCardState();
}

class _RaceLossCardState extends State<RaceLossCard> {
  bool _played = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_played) return;
    _played = true;
    widget.jingles?.playJingle(Jingle.versusLose);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(widget.rival);
    return OverlayEntrance(
      kind: OverlayEntranceKind.fade,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          content,
        ],
      ),
      child: _ResultShell(
        children: [
          _Announce(l10n.raceAnnounceLost),
          _RaceHeaderBlock(
            title: l10n.raceLossTitle,
            shortTitle: l10n.raceLossTitleShort,
            families: widget.families,
            hop: false,
            startsMs: const [],
            images: widget.images,
            renderer: widget.renderer,
            symbols: widget.symbols,
            library: widget.library,
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _RivalCard(
              rival: widget.rival,
              body: l10n.raceLossBody(name),
              // The rival finished first: it hops.
              reaction: RivalReaction.win,
              library: widget.library,
            ),
          ),
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _Buttons(
              primaryLabel: l10n.raceRematch,
              secondaryLabel: l10n.raceNewRace,
              onPrimary: widget.onRematch,
              onSecondary: widget.onNewRace,
            ),
          ),
        ],
      ),
    );
  }
}

/// Frame 9.6, "New rival unlocked!" (ui-spec-game §2.1; m7-4 4.1): a card,
/// once per rival, that interposes before 9.4's chosen action (any button, or
/// back). The versus pill, gold rays behind the 128 dp portrait (emphasis
/// ring), the name and [ComputerTag], the skill line, and "{rival} is ready
/// to race."; "Race {rival}" (a fresh race against this rival) and Not now
/// (carry on with 9.4's action). `jingle_reward` plays as the card lands
/// (`sound.events.rivalUnlocked`), no haptic. The rays turn slowly (24 s),
/// not under reduced motion; it fades in.
class RivalUnlockedCard extends StatefulWidget {
  const RivalUnlockedCard({
    required this.rival,
    required this.onNewRace,
    required this.onNotNow,
    this.jingles,
    super.key,
  });

  /// The rival just unlocked, 2 or 3.
  final int rival;

  /// "Race {rival}": a fresh race against the new rival.
  final VoidCallback onNewRace;
  final VoidCallback onNotNow;

  /// Plays `jingle_reward` as the card lands; null is silent.
  final JinglePlayer? jingles;

  /// The card's top and sides (ui-spec-game §2.1: modal top 176, 28).
  static const double cardTop = 176 - 59;
  static const double side = 28;

  @override
  State<RivalUnlockedCard> createState() => _RivalUnlockedCardState();
}

class _RivalUnlockedCardState extends State<RivalUnlockedCard> {
  bool _played = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_played) return;
    _played = true;
    widget.jingles?.playJingle(Jingle.reward);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final rival = widget.rival;
    final name = l10n.raceRivalName(rival);
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          ModalPlacement(
            cardTop: RivalUnlockedCard.cardTop,
            side: RivalUnlockedCard.side,
            clearance: RibbonTitle.overhang,
            child: content,
          ),
        ],
      ),
      child: ModalCard(
        ribbon: RibbonTitle(
          l10n.raceRivalUnlockedTitle,
          gradient: AppGradientTokens.versus,
          edgeColor: AppColorTokens.versusEdge,
        ),
        padding: const EdgeInsets.fromLTRB(
          22,
          44,
          22,
          22 - OverlayTextLink.slack,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l10n.joinSentences([
                l10n.raceRivalSemantics(name),
                l10n.raceRivalUnlockedBody(name),
              ]),
              container: true,
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The portrait and its ring are 142 dp; the rays (270,
                  // `chestModal.glow`) spill past it, behind the card's text.
                  SizedBox(
                    height: 146,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        OverflowBox(
                          maxWidth: _Rays.extent,
                          maxHeight: _Rays.extent,
                          child: _Rays(spin: !context.reduceMotion),
                        ),
                        RivalPortrait(number: rival, size: 128, emphasis: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTextStyleTokens.cardTitle.copyWith(
                            fontSize: 26,
                            color: AppColorTokens.textPrimary,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                        const SizedBox(width: 8),
                        ComputerTag.responsive(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.raceRivalSkill(rival),
                    style: AppTextStyleTokens.row.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColorTokens.versusEdge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.raceRivalUnlockedBody(name),
                    textAlign: TextAlign.center,
                    style: context.scriptStyle(
                      AppTextStyles.bodySmall.copyWith(
                        fontSize: 16,
                        height: 23 / 16,
                      ),
                      role: ScriptTextRole.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TactileButton(
              label: l10n.raceRivalUnlockedRace(name),
              variant: TactileButtonVariant.versus,
              onPressed: widget.onNewRace,
            ),
            const SizedBox(height: 16 - OverlayTextLink.slack),
            OverlayTextLink(label: l10n.notNow, onPressed: widget.onNotNow),
          ],
        ),
      ),
    );
  }
}

/// The gold rays behind 9.6's portrait (`chestModal.glow`: rays
/// `repeating-conic-gradient(rgba(255,200,90,.55) 0 9°, 0 9° 24°)` under a
/// radial mask, clear at 68 %), turning once in 24 s. Still under reduced
/// motion.
class _Rays extends StatefulWidget {
  const _Rays({required this.spin});

  final bool spin;

  /// `chestModal.glow`: 270 dp.
  static const double extent = 270;

  @override
  State<_Rays> createState() => _RaysState();
}

class _RaysState extends State<_Rays> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void initState() {
    super.initState();
    // Built now, never first in dispose. Started after the first frame: a
    // repeat notifies its listeners at once, which inside a LayoutBuilder's
    // build (the modal's placement) marks the transition dirty out of scope.
    final controller = _controller;
    if (widget.spin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.spin) controller.repeat();
      });
    }
  }

  @override
  void didUpdateWidget(_Rays oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spin && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.spin && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RotationTransition(
      turns: _controller,
      child: const CustomPaint(
        size: Size.square(_Rays.extent),
        painter: _RaysPainter(),
      ),
    ),
  );
}

final class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  static const _rayDeg = 9.0;
  static const _periodDeg = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // Rays fade out towards the rim: clear from 68 % of the radius.
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x8CFFC85A), Color(0x8CFFC85A), Color(0x00FFC85A)],
        stops: [0, 0.4, 0.68],
      ).createShader(rect);
    for (var a = 0.0; a < 360; a += _periodDeg) {
      canvas.drawArc(
        rect,
        a * 3.141592653589793 / 180,
        _rayDeg * 3.141592653589793 / 180,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => false;
}
