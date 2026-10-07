import 'dart:async';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/ui/art/ui_art_image_source.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';

/// Where [ChestRewardSequence] is, driving what it shows and which taps do
/// something (m7-design chest sequence, the owner-chest lane): a screen
/// reader or a test can read this straight off the widget instead of
/// guessing from visuals.
enum ChestSequencePhase {
  /// The card and the chest are arriving (~600 ms); nothing is tappable.
  arrival,

  /// Closed, breathing gently, contents already shown. Open is live.
  idle,

  /// The anticipation wiggle then the burst (~1.2 s total); a second tap
  /// skips straight to [openIdle].
  opening,

  /// Open, contents settled at their final values; Collect is live.
  openIdle,

  /// Collect was pressed: the coin (and hint) flights are in the air, or
  /// (with nothing to fly to, or under reduced motion) already resolved and
  /// the card is fading out.
  collecting,
}

/// The shared reward-opening moment for both chests (docs/plans/
/// m7-design.md §9 the milestone chest, §15.4, P4.7; phase 4 architecture
/// §3.5; frames 10.3b–10.3d, 5.6, 5.6b; ui-spec-game §2.3): a card at
/// `layout.chestCard` (28 in from each side, top 168, or 176 for the day-7 chest) holding `ui_chest`,
/// the contents at their promised amounts from the first frame (spec-prop
/// §1.1 rule 2: shown before it opens), an Open, and a Collect that flies
/// six coins (and a hint) to wherever they belong. Nothing here grants
/// anything: the win's save update already paid it (m7-design §9 step 3);
/// [onCollect] only dismisses.
///
/// The chest is the `ui_chest` Lottie, its segments the file's own markers:
/// `arrive` then `idle` looping, `wiggle` on Open, `open` then `open_idle`
/// looping, with `fx_dust_puff` at the landing. `SoundEffect.chestWiggle`
/// plays at the wiggle, `chestOpen` and a medium haptic when the lid goes,
/// `jingle_reward` 250 ms later, the chips pop 150 ms apart (the coin chip
/// keeps its text). Collect plays `coins` and flies 6 `coin_flight` sprites
/// (700 ms, 60 ms apart) and a `hint_flight` (650 ms), with a light haptic
/// as the hint lands. If the Lottie can't load, the SVG art stands in
/// (rule 3).
///
/// The rays are `ui_chest`'s own, swaying ±6° (m7-4 1.7: no full turn, and
/// none drawn over the Lottie).
///
/// Reduce motion: a 200 ms crossfade from `idle` to `open`'s last frame,
/// no wiggle or flights; the chips appear together; `chest_open` and
/// `jingle_reward` still play, with one light haptic.
///
/// [coinTarget] and [hintTarget] are read live, at Collect (never cached):
/// null means there is nothing to fly to on this screen, so the reward
/// counts up in place instead. [onCoinsRevealed] is called with the
/// cumulative total as each coin sprite lands, releasing a HUD coin hold
/// one tick at a time; [onHintLanded] once, when the hint sprite lands (or
/// immediately, with nothing to fly to).
class ChestRewardSequence extends StatefulWidget {
  const ChestRewardSequence({
    required this.title,
    required this.body,
    required this.coins,
    required this.onCollect,
    this.streakRibbon = false,
    this.openBody,
    this.caption,
    this.hints = 0,
    this.slots = 0,
    this.feedback,
    this.jingleCues,
    this.library,
    this.uiArt,
    this.coinTarget,
    this.hintTarget,
    this.slotTarget,
    this.onCoinsRevealed,
    this.onHintLanded,
    this.onSlotLanded,
    this.onCollectStart,
    this.cardTop,
    this.closedChestSize = 130,
    this.openChestSize = 200,
    super.key,
  });

  /// The ribbon's text (`RibbonTitle` by default, [streakRibbon]'s
  /// `RibbonTitle.streak`).
  final String title;
  final bool streakRibbon;

  /// Shown while closed and opening; also while open when [openBody] is
  /// null (the chests: the same line throughout, contents already shown).
  final String body;

  /// Replaces [body] once open.
  final String? openBody;

  /// An optional second line under [body], shown in every phase.
  final String? caption;

  final int coins;

  /// Zero hides the hint chip and its flight entirely (the day-7 chest).
  final int hints;

  /// Extra slots the chest holds (the daily gift's Day 7, plan-login-gift
  /// section 7.5b); zero hides the chip. With a [slotTarget] Collect flies
  /// `slot_flight` to it (frame 13.6d: Home's tally); without one the slot
  /// joins the player's boosters in place.
  final int slots;

  /// Dismisses the sequence once Collect has finished; grants nothing.
  final VoidCallback onCollect;

  final FeedbackSink? feedback;
  final JingleCues? jingleCues;
  final FxLibrary? library;

  /// The UI art behind `ui_chest` and the flight sprites (the DI one by
  /// default).
  final UiArtLibrary? uiArt;

  final RewardFlightTarget? coinTarget;
  final RewardFlightTarget? hintTarget;

  /// Where the slot flies (the daily gift's tally disc), read live at
  /// Collect, after [onCollectStart].
  final RewardFlightTarget? slotTarget;
  final ValueChanged<int>? onCoinsRevealed;
  final VoidCallback? onHintLanded;

  /// The slot sprite landed (or, with nothing to fly to or under reduced
  /// motion, Collect resolved it in place).
  final VoidCallback? onSlotLanded;

  /// Collect was pressed, before any sprite flies: the daily gift shows
  /// its tally here so the slot has somewhere to land.
  final VoidCallback? onCollectStart;

  /// The card's top on the 390×844 reference; null is the milestone
  /// chest's `cardTop` (168), or `cardTopDay7` (176) with [streakRibbon].
  /// The daily gift's Day 7 passes `cardTopDay7` with the house ribbon
  /// (`gift.chest.tint`: none).
  final double? cardTop;

  /// Kept for the callers of the earlier stand-in; the Lottie's box
  /// ([chestCanvas]) sets the chest's size now.
  final double closedChestSize;
  final double openChestSize;

  /// `ui_chest`'s 200×200 canvas at 100 % (`FxSpec`). It plays at
  /// `ChestCardTokens.lottieScale` over the `artBox` as an overlay that
  /// takes no layout space (m7-4 6.4, 8.3).
  static const chestCanvas = Size(200, 200);

  /// Where the chest's base sits in [chestCanvas] (LOTTIE.md: chest base
  /// (100, 186)); it lands on the art box's bottom centre.
  static const Offset chestBase = Offset(100, 186);

  /// Arrival: `ui_chest`'s `arrive` segment (`motion.chest.arriveMs`).
  static const int arrivalMs = ChestMotionTokens.arriveMs;

  /// The anticipation wiggle (`motion.chest.wiggleMs`).
  static const int wiggleMs = ChestMotionTokens.wiggleMs;

  /// The burst: `open` (`motion.chest.burstMs`).
  static const int burstMs = ChestMotionTokens.burstMs;

  /// Reduced motion's whole Open step: the crossfade.
  static const int reducedOpenMs = 200;

  /// The chest's art box in the card (`layout.chestCard.artBox`, 156×130):
  /// the canvas overflows it as an overlay (frames 10.3b, 10.3c).
  static const Size artBox = ChestCardTokens.artBox;

  /// The card's fade once Collect starts, before [onCollect].
  static const int exitFadeMs = 220;

  /// Coin sprites per flight (`motion.chest.collect.coins`).
  static const int coinSpriteCount = ChestMotionTokens.collectCoins;
  static const int collectStaggerMs = ChestMotionTokens.collectCoinStaggerMs;
  static const int collectFlightMs = ChestMotionTokens.collectCoinFlightMs;

  /// The chest's Lottie, for tests.
  @visibleForTesting
  static const Key chestKey = Key('chest-lottie');

  /// The card, for tests.
  @visibleForTesting
  static const Key cardKey = Key('chest-card');

  /// The dim behind the card, for tests.
  @visibleForTesting
  static const Key dimKey = Key('chest-dim');

  @override
  State<ChestRewardSequence> createState() => _ChestRewardSequenceState();
}

class _ChestRewardSequenceState extends State<ChestRewardSequence>
    with TickerProviderStateMixin {
  ChestSequencePhase _phase = ChestSequencePhase.arrival;
  bool _reduceMotion = false;
  bool _started = false;

  final List<Timer> _timers = [];
  final GlobalKey _coinChipKey = GlobalKey();
  final GlobalKey _hintChipKey = GlobalKey();
  final GlobalKey _slotChipKey = GlobalKey();
  RewardFlightHandle? _coinFlight;
  RewardFlightHandle? _hintFlight;
  RewardFlightHandle? _slotFlight;

  final LottieFxController _chest = LottieFxController(FxId.uiChest);
  final LottieFxController _dustPuff = LottieFxController(FxId.fxDustPuff);
  UiArtImageSource? _source;
  UiArtLibrary? _art;
  double? _ratio;

  /// How many chips have popped (0–2), each 150 ms after the last.
  int _popped = 0;

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );
  late final AnimationController _exitFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: ChestRewardSequence.exitFadeMs),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareArt();
    if (_started) return;
    _started = true;
    _reduceMotion = context.reduceMotion;
    if (_reduceMotion) {
      _chest.seek(_frameOf('idle', end: false));
      _enterIdle();
    } else {
      _chest.playMarker('arrive', thenMarker: 'idle');
      // The landing (fx_dust_puff) at the end of `arrive`'s fall.
      _at(ChestRewardSequence.arrivalMs * 0.65, _dustPuff.playWhole);
      _at(ChestRewardSequence.arrivalMs.toDouble(), _enterIdle);
    }
  }

  void _prepareArt() {
    final art = widget.uiArt ?? UiArtLibrary.of(context);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    if (art == null || (identical(art, _art) && ratio == _ratio)) return;
    _art = art;
    _ratio = ratio;
    final source = _source = UiArtImageSource(art);
    unawaited(
      source
          .prepare(
            devicePixelRatio: ratio,
            only: const [FxImageSlot.chestClosed, FxImageSlot.chestOpen],
          )
          .then((_) {
            // A raster that lands after a resting frame drew: repaint it.
            if (mounted && !_chest.isPlaying) _chest.seek(_restFrame);
          }),
    );
  }

  double _restFrame = 0;

  double _frameOf(String marker, {required bool end}) {
    for (final m in fxSpecOf(FxId.uiChest).markers) {
      if (m.name == marker) return _restFrame = end ? m.end : m.start;
    }
    return _restFrame;
  }

  void _enterIdle() {
    if (!mounted) return;
    setState(() => _phase = ChestSequencePhase.idle);
  }

  // Timers: every discrete cue (sound, haptic, jingle, a phase change that
  // isn't an animation's own end) goes through here, so a skip can cancel
  // every one still pending in a single call.

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

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _cue(SoundEffect? sound, [HapticPattern? haptic]) {
    if (sound == null && haptic == null) return;
    widget.feedback?.play(FxCue(atMs: 0, sound: sound, haptic: haptic));
  }

  // Open (tap guard: only from idle).

  void _open() {
    if (_phase != ChestSequencePhase.idle) return;
    setState(() => _phase = ChestSequencePhase.opening);
    if (_reduceMotion) {
      _openReduced();
      return;
    }
    _chest.playMarker('wiggle');
    _cue(SoundEffect.chestWiggle);
    const wiggle = ChestRewardSequence.wiggleMs;
    // `open` starts as the wiggle ends: the lid's sound and the medium
    // haptic at once, the reward jingle 250 ms after.
    _at(wiggle.toDouble(), () {
      _chest.playMarker('open', thenMarker: 'open_idle');
      _cue(SoundEffect.chestOpen, HapticPattern.nest);
      _popChip(1);
    });
    _at(wiggle + ChestMotionTokens.chipStaggerMs.toDouble(), () => _popChip(2));
    _at(
      wiggle + ChestMotionTokens.rewardJingleAfterOpenMs.toDouble(),
      () => widget.jingleCues?.reward(),
    );
    _at(
      (wiggle + ChestRewardSequence.burstMs).toDouble(),
      () => setState(() => _phase = ChestSequencePhase.openIdle),
    );
  }

  void _popChip(int n) {
    if (!mounted) return;
    setState(() => _popped = n);
    _pop
      ..reset()
      ..forward();
  }

  /// A second tap while it opens: every pending cue is dropped and the open
  /// ends now; the sound, jingle and haptic still land, just at once.
  void _skipToOpenEnd() {
    if (_phase != ChestSequencePhase.opening) return;
    final started = _popped > 0;
    _cancelTimers();
    _chest.playMarker('open_idle', loop: true);
    _frameOf('open_idle', end: false);
    if (!started) _cue(SoundEffect.chestOpen, HapticPattern.nest);
    widget.jingleCues?.reward();
    setState(() {
      _popped = 2;
      _phase = ChestSequencePhase.openIdle;
    });
  }

  void _openReduced() {
    _cue(SoundEffect.chestOpen, HapticPattern.pick);
    _frameOf('open', end: true);
    setState(() => _popped = 2);
    _at(
      ChestMotionTokens.rewardJingleAfterOpenMs.toDouble(),
      () => widget.jingleCues?.reward(),
    );
    _at(
      ChestRewardSequence.reducedOpenMs.toDouble(),
      () => setState(() => _phase = ChestSequencePhase.openIdle),
    );
  }

  // Collect (tap guard: only from openIdle).

  void _collect() {
    if (_phase != ChestSequencePhase.openIdle) return;
    setState(() => _phase = ChestSequencePhase.collecting);
    _exitFade.forward();
    _cue(SoundEffect.coins);
    widget.onCollectStart?.call();
    if (_reduceMotion) {
      widget.onCoinsRevealed?.call(widget.coins);
      if (widget.hints > 0) widget.onHintLanded?.call();
      if (widget.slots > 0) widget.onSlotLanded?.call();
      _at(ChestRewardSequence.exitFadeMs.toDouble(), widget.onCollect);
      return;
    }
    var pending = 3;
    void oneDone() {
      if (--pending == 0 && mounted) widget.onCollect();
    }

    _collectCoins(oneDone);
    _collectHint(oneDone);
    _collectSlot(oneDone);
  }

  Rect? _globalRectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _collectCoins(VoidCallback done) {
    final from = _globalRectOf(_coinChipKey);
    final to = widget.coinTarget?.call();
    if (from == null || to == null) {
      // Nothing to fly to: the count releases in place.
      _at(ChestRewardSequence.exitFadeMs.toDouble(), () {
        widget.onCoinsRevealed?.call(widget.coins);
        done();
      });
      return;
    }
    _coinFlight = RewardFlight.launch(
      context,
      from: from,
      to: to,
      count: ChestRewardSequence.coinSpriteCount,
      trail: true,
      trailDots: ChestCollectTokens.trailCoinDots.round(),
      spriteBuilder: (context) =>
          _Sprite(UiArt.coinFlight, size: 30, library: widget.uiArt),
      vsync: this,
      stagger: const Duration(
        milliseconds: ChestRewardSequence.collectStaggerMs,
      ),
      flightDuration: const Duration(
        milliseconds: ChestRewardSequence.collectFlightMs,
      ),
      onLanded: (i) => widget.onCoinsRevealed?.call(
        (widget.coins * (i + 1) / ChestRewardSequence.coinSpriteCount).round(),
      ),
      onAllLanded: () {
        widget.onCoinsRevealed?.call(widget.coins);
        done();
      },
    );
  }

  void _collectHint(VoidCallback done) {
    if (widget.hints <= 0) {
      done();
      return;
    }
    final from = _globalRectOf(_hintChipKey);
    final to = widget.hintTarget?.call();
    if (from == null || to == null) {
      widget.onHintLanded?.call();
      done();
      return;
    }
    _hintFlight = RewardFlight.launch(
      context,
      from: from,
      to: to,
      count: 1,
      trail: true,
      trailDots: ChestCollectTokens.trailHintDots.round(),
      spriteBuilder: (context) =>
          _Sprite(UiArt.hintFlight, size: 40, library: widget.uiArt),
      vsync: this,
      flightDuration: const Duration(
        milliseconds: ChestMotionTokens.collectHintFlightMs,
      ),
      onLanded: (_) {
        widget.onHintLanded?.call();
        _cue(null, HapticPattern.pick);
      },
      onAllLanded: done,
    );
  }

  /// The slot (the daily gift's Day 7): `slot_flight` at 40 over 650 ms
  /// to [ChestRewardSequence.slotTarget] with the hint's three-dot trail and
  /// a light haptic as it lands (`gift.claim.slot`, frame 13.6d).
  void _collectSlot(VoidCallback done) {
    if (widget.slots <= 0) {
      done();
      return;
    }
    final from = _globalRectOf(_slotChipKey);
    final to = widget.slotTarget?.call();
    if (from == null || to == null) {
      widget.onSlotLanded?.call();
      done();
      return;
    }
    _slotFlight = RewardFlight.launch(
      context,
      from: from,
      to: to,
      count: 1,
      trail: true,
      trailDots: ChestCollectTokens.trailHintDots.round(),
      spriteBuilder: (context) => _Sprite(
        UiArt.slotFlight,
        size: GiftClaimTokens.slotSpriteSize,
        library: widget.uiArt,
      ),
      vsync: this,
      flightDuration: const Duration(milliseconds: GiftClaimTokens.slotMs),
      onLanded: (_) {
        widget.onSlotLanded?.call();
        _cue(null, HapticPattern.pick);
      },
      onAllLanded: done,
    );
  }

  @override
  void dispose() {
    _cancelTimers();
    _coinFlight?.dispose();
    _hintFlight?.dispose();
    _slotFlight?.dispose();
    _chest.dispose();
    _dustPuff.dispose();
    _pop.dispose();
    _exitFade.dispose();
    super.dispose();
  }

  // Build.

  bool get _isOpen =>
      _phase == ChestSequencePhase.openIdle ||
      _phase == ChestSequencePhase.collecting;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final collecting = _phase == ChestSequencePhase.collecting;
    return Stack(
      fit: StackFit.expand,
      children: [
        // The dim lightens to rgba(60,30,10,.18) as Collect starts (10.3d).
        AnimatedOpacity(
          key: ChestRewardSequence.dimKey,
          opacity: collecting ? 0.18 / 0.55 : 1,
          duration: const Duration(
            milliseconds: ChestRewardSequence.exitFadeMs,
          ),
          child: const Scrim(),
        ),
        Positioned(
          left: ChestCardTokens.cardLeft,
          right: ChestCardTokens.cardRight,
          top:
              top +
              (widget.cardTop ??
                  (widget.streakRibbon
                      ? ChestCardTokens.cardTopDay7
                      : ChestCardTokens.cardTop)) -
              59,
          bottom: 8,
          child: FadeTransition(
            opacity: ReverseAnimation(_exitFade),
            // A short phone or 1.3× text scales the card down rather than
            // clipping it.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, _) => SizedBox(
                  key: ChestRewardSequence.cardKey,
                  width:
                      MediaQuery.sizeOf(context).width -
                      ChestCardTokens.cardLeft -
                      ChestCardTokens.cardRight,
                  child: ModalCard(
                    ribbon: _ribbon(),
                    padding: ChestCardTokens.cardPadding,
                    child: _cardContent(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  RibbonTitle _ribbon() => widget.streakRibbon
      ? RibbonTitle.streak(widget.title)
      : RibbonTitle(widget.title);

  Widget _cardContent(BuildContext context) {
    final bodyText = _isOpen ? (widget.openBody ?? widget.body) : widget.body;
    final caption = widget.caption;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The art box, 156×130, with `ui_chest` at 1.2 over it as an
        // overlay that takes no layout space (`layout.chestCard`, frames
        // 10.3b, 10.3c, 5.6; m7-4 6.4, 8.3): the chest base lands on the
        // box's bottom centre, and the canvas may draw past the card top.
        SizedBox(
          width: ChestRewardSequence.artBox.width,
          height: ChestRewardSequence.artBox.height,
          child: _chestArt(),
        ),
        const SizedBox(height: ChestCardTokens.cardGap),
        Text(bodyText, textAlign: TextAlign.center, style: _bodyStyle),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColorTokens.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: ChestCardTokens.cardGap),
        _chipsRow(context),
        // The buttons' own margin-top 4 on top of the gap (NestyMeta).
        const SizedBox(height: ChestCardTokens.cardGap + 4),
        _actionButton(context),
      ],
    );
  }

  /// Nunito 600 16/23 `#7A5234` (ui-spec-game §2.3 "Body").
  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: 'Nunito',
    fontFamilyFallback: AppFontTokens.bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 23 / 16,
    color: AppColors.textBrown,
  );

  // The chest itself.

  /// The art box's overlay: the 200×200 canvas at `lottieScale`, placed so
  /// the chest's base (100, 186) is the box's bottom centre.
  Widget _chestArt() {
    const scale = ChestCardTokens.lottieScale;
    final canvas = ChestRewardSequence.chestCanvas * scale;
    final base = ChestRewardSequence.chestBase * scale;
    final box = ChestRewardSequence.artBox;
    final left = box.width / 2 - base.dx;
    final top = box.height - base.dy;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: left,
          top: top,
          width: canvas.width,
          height: canvas.height,
          child: _chestVisual(Offset(-left, -top)),
        ),
      ],
    );
  }

  /// [artOrigin] is where the art box's top-left sits in the canvas, for the
  /// SVG fallback.
  Widget _chestVisual(Offset artOrigin) {
    final box = ChestRewardSequence.artBox;
    // The still art when the Lottie can't load: the SVG fills the same
    // 156×130 box the frame draws.
    Widget fallbackArt({required bool open}) => Padding(
      padding: EdgeInsets.only(left: artOrigin.dx, top: artOrigin.dy),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(
          size: box,
          child: Center(
            child: open
                ? ChestIcon.open(size: box.width)
                : ChestIcon(size: box.width),
          ),
        ),
      ),
    );
    // SizedBox.expand: a loaded Lottie view is a CustomPaint of its own
    // 200×200 canvas, and the Stack hands it loose constraints, so without
    // this it drew at 1.0 (a 101 dp chest, off-centre) instead of the 240 dp
    // box at 1.2 (121 dp; phase 5 audit f10-3b).
    final lottie = SizedBox.expand(
      child: LottieFxView(
        key: ChestRewardSequence.chestKey,
        id: FxId.uiChest,
        controller: _chest,
        library: widget.library,
        images: _source,
        fallback: fallbackArt(open: _isOpen),
      ),
    );
    if (_reduceMotion) {
      // A 200 ms crossfade idle → open's last frame (no wiggle).
      return ExcludeSemantics(
        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: ChestRewardSequence.reducedOpenMs,
          ),
          child: _StillChest(
            key: ValueKey(_popped > 0 || _isOpen ? 'open' : 'closed'),
            frame: _popped > 0 || _isOpen
                ? _frameOf('open', end: true)
                : _frameOf('idle', end: false),
            open: _popped > 0 || _isOpen,
            source: _source,
            library: widget.library,
            fallback: fallbackArt(open: _popped > 0 || _isOpen),
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 140,
                height: 70,
                child: LottieFxView(
                  id: FxId.fxDustPuff,
                  controller: _dustPuff,
                  library: widget.library,
                ),
              ),
            ),
          ),
          lottie,
        ],
      ),
    );
  }

  // The contents chips.

  Widget _chipsRow(BuildContext context) {
    final l10n = context.localizations;
    final coinChip = _popping(
      1,
      RewardChip(
        key: _coinChipKey,
        kind: RewardChipKind.coin,
        label: l10n.chestContentsCoins(widget.coins),
      ),
    );
    final others = <Widget>[
      if (widget.slots > 0)
        _popping(
          2,
          RewardChip(
            key: _slotChipKey,
            kind: RewardChipKind.slot,
            label: l10n.chestContentsSlot(widget.slots),
            short: l10n.chestContentsSlotShort(widget.slots),
          ),
        ),
      if (widget.hints > 0)
        _popping(
          2,
          RewardChip(
            key: _hintChipKey,
            kind: RewardChipKind.hint,
            label: l10n.chestContentsHint(widget.hints),
          ),
        ),
    ];
    final Widget arranged = widget.slots > 0
        // Three chips, or two with long labels, wrap onto a second line
        // instead of shrinking below the readable size (the daily gift's
        // Day 7: coins and a slot).
        ? Wrap(
            alignment: WrapAlignment.center,
            spacing: ChestCardTokens.contentsGap,
            runSpacing: 8,
            children: [coinChip, ...others],
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                coinChip,
                for (final chip in others) ...[
                  const SizedBox(width: ChestCardTokens.contentsGap),
                  chip,
                ],
              ],
            ),
          );
    return Semantics(
      liveRegion: _isOpen,
      // "Chest. Inside: 100 coins, 1 hint." (copy.md A11y `a11y_chest_contents`).
      label: l10n.chestSemantics(_contentsSemantics(l10n)),
      child: ExcludeSemantics(child: arranged),
    );
  }

  String _contentsSemantics(AppLocalizations l10n) {
    if (widget.slots <= 0) {
      return widget.hints > 0
          ? l10n.chestContentsSemantics(widget.coins, widget.hints)
          : l10n.coinsSemantics(widget.coins);
    }
    if (widget.hints <= 0) {
      // "100 coins, 1 extra slot" (copy.md `gift_a11y_chest_contents`).
      return l10n.giftA11yChestContents(
        l10n.giftCoins(widget.coins),
        l10n.giftSlots(widget.slots),
      );
    }
    // Coins, hints and slots (no gift holds all three today): the coins and
    // hints phrase, then the slots, through the ARB's list separator.
    return l10n.joinList([
      l10n.chestContentsSemantics(widget.coins, widget.hints),
      l10n.giftSlots(widget.slots),
    ]);
  }

  /// Chip [n] (1-based) pops when the lid goes: scale 0.82 → 1 and opacity
  /// 0.6 → 1, 150 ms apart; a chip that hasn't popped yet keeps its rest
  /// look (its text is the promised amount either way).
  Widget _popping(int n, Widget chip) {
    if (_reduceMotion || _popped != n) return chip;
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_pop.value);
        return Opacity(
          opacity: 0.6 + 0.4 * t,
          child: Transform.scale(scale: 0.82 + 0.18 * t, child: child),
        );
      },
      child: chip,
    );
  }

  // The action button: what a tap does, by phase.

  Widget _actionButton(BuildContext context) {
    final l10n = context.localizations;
    final VoidCallback? action = switch (_phase) {
      ChestSequencePhase.arrival => null,
      ChestSequencePhase.idle => _open,
      ChestSequencePhase.opening => _skipToOpenEnd,
      ChestSequencePhase.openIdle => _collect,
      ChestSequencePhase.collecting => null,
    };
    final label = _isOpen ? l10n.dailyChestCollect : l10n.chestOpen;
    return ExcludeSemantics(
      excluding: _phase == ChestSequencePhase.arrival,
      child: Opacity(
        opacity: _phase == ChestSequencePhase.arrival ? 0 : 1,
        child: TactileButton(label: label, onPressed: action),
      ),
    );
  }
}

/// `ui_chest` held on one frame (the reduced-motion crossfade's two ends).
class _StillChest extends StatefulWidget {
  const _StillChest({
    required this.frame,
    required this.open,
    required this.source,
    required this.library,
    required this.fallback,
    super.key,
  });

  final double frame;
  final bool open;
  final FxImageSource? source;
  final FxLibrary? library;
  final Widget fallback;

  @override
  State<_StillChest> createState() => _StillChestState();
}

class _StillChestState extends State<_StillChest> {
  late final LottieFxController _controller = LottieFxController(FxId.uiChest)
    ..seek(widget.frame);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: LottieFxView(
      id: FxId.uiChest,
      controller: _controller,
      library: widget.library,
      images: widget.source,
      fallback: widget.fallback,
    ),
  );
}

/// A flight sprite: one [UiArt] in a [size] box (a coin's 30, the hint's 40).
class _Sprite extends StatelessWidget {
  const _Sprite(this.art, {required this.size, this.library});

  final UiArt art;
  final double size;
  final UiArtLibrary? library;

  @override
  Widget build(BuildContext context) =>
      UiArtImage.square(art, extent: size, library: library);
}

/// Which chip a [RewardChip] is.
enum RewardChipKind { coin, hint, slot }

/// One contents chip of a chest (ui-spec-game §1 "Chip"; `layout.chestCard.
/// contents`): 44 tall, radius 22, a 30 dp disc (the coin's face, or the
/// hint's lightbulb on `#FFE7A0 → #F5C518`, or the slot's box on green), then Fredoka 700 18 `#5B3A21`
/// on `#FFFDF7`.
class RewardChip extends StatelessWidget {
  const RewardChip({
    required this.kind,
    required this.label,
    this.short,
    super.key,
  });

  final RewardChipKind kind;
  final String label;

  /// The label's short form (the slot chip's "+1", copy.md "Short forms"),
  /// drawn when the full one doesn't fit the row at textFit.chestChips'
  /// 0.85; null only scales.
  final String? short;

  static const _style = SurfaceStyle(
    color: Color(0xFFFFFDF7),
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final short = this.short;
    if (short == null) return _chip(label);
    // The chip's room: the row's width less its disc, gap and padding.
    const chrome = 7 + ChestCardTokens.contentsIcon + 10 + 16;
    return LayoutBuilder(
      builder: (context, constraints) => _chip(
        FitText.pick(
          full: label,
          short: short,
          style: DefaultTextStyle.of(context).style.merge(_labelStyle),
          maxWidth: constraints.maxWidth - chrome,
          scaler: MediaQuery.textScalerOf(context),
          direction: Directionality.of(context),
          minScale: TextFitTokens.chestChipsMinScale,
        ),
      ),
    );
  }

  Widget _chip(String shown) => NestySurface(
    style: _style,
    radius: BorderRadius.circular(ChestCardTokens.contentsChipRadius),
    height: ChestCardTokens.contentsChipHeight,
    padding: const EdgeInsetsDirectional.fromSTEB(7, 0, 16, 0),
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (kind) {
          RewardChipKind.coin => const CoinIcon(
            size: ChestCardTokens.contentsIcon,
          ),
          RewardChipKind.hint => Container(
            width: ChestCardTokens.contentsIcon,
            height: ChestCardTokens.contentsIcon,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE7A0), Color(0xFFF5C518)],
              ),
              boxShadow: [
                BoxShadow(color: Color(0xFFC9960A), offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(
              NestyIcons.lightbulb,
              size: 19,
              color: Color(0xFF8C5E12),
            ),
          ),
          // `chest.slotChip`: ui/chest/chip_slot.svg at 30, the coin and
          // hint discs' size (frame 13.6b).
          RewardChipKind.slot => UiArtImage.square(
            UiArt.chipSlot,
            extent: ChestSlotChipTokens.discSize,
          ),
        },
        const SizedBox(width: 10),
        Text(
          shown,
          semanticsLabel: shown == label ? null : label,
          style: _labelStyle,
        ),
      ],
    ),
  );

  static final TextStyle _labelStyle = AppTextStyleTokens.number.copyWith(
    fontSize: 18,
    height: 1,
    color: const Color(0xFF5B3A21),
  );
}
