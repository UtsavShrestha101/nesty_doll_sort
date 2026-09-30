import 'dart:async';
import 'dart:math' as math;
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
/// `layout.chestCard` (28 in from each side, top 214) holding `ui_chest`,
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
/// Reduce motion: a 200 ms crossfade from `idle` to `open`'s last frame,
/// no wiggle, rays or flights; the chips appear together; `chest_open` and
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
    this.feedback,
    this.jingleCues,
    this.library,
    this.uiArt,
    this.coinTarget,
    this.hintTarget,
    this.onCoinsRevealed,
    this.onHintLanded,
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
  final ValueChanged<int>? onCoinsRevealed;
  final VoidCallback? onHintLanded;

  /// Kept for the callers of the earlier stand-in; the Lottie's box
  /// (`ChestCardTokens.lottieSize`) sets the chest's size now.
  final double closedChestSize;
  final double openChestSize;

  /// Arrival: `ui_chest`'s `arrive` segment (`motion.chest.arriveMs`).
  static const int arrivalMs = ChestMotionTokens.arriveMs;

  /// The anticipation wiggle (`motion.chest.wiggleMs`).
  static const int wiggleMs = ChestMotionTokens.wiggleMs;

  /// The burst: `open` (`motion.chest.burstMs`).
  static const int burstMs = ChestMotionTokens.burstMs;

  /// Reduced motion's whole Open step: the crossfade.
  static const int reducedOpenMs = 200;

  /// The card's fade once Collect starts, before [onCollect].
  static const int exitFadeMs = 220;

  /// Coin sprites per flight (`motion.chest.collect.coins`).
  static const int coinSpriteCount = ChestMotionTokens.collectCoins;
  static const int collectStaggerMs = ChestMotionTokens.collectCoinStaggerMs;
  static const int collectFlightMs = ChestMotionTokens.collectCoinFlightMs;

  /// The rays' turn (frame 10.3c: `chestModal.glow` rotates; no token times
  /// it, so a slow constant).
  static const int raysTurnMs = 24000;

  /// The chest's Lottie, for tests.
  @visibleForTesting
  static const Key chestKey = Key('chest-lottie');

  /// The card, for tests.
  @visibleForTesting
  static const Key cardKey = Key('chest-card');

  /// The dim behind the card, for tests.
  @visibleForTesting
  static const Key dimKey = Key('chest-dim');

  /// The rays behind the open chest, for tests.
  @visibleForTesting
  static const Key raysKey = Key('chest-rays');

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
  RewardFlightHandle? _coinFlight;
  RewardFlightHandle? _hintFlight;

  final LottieFxController _chest = LottieFxController(FxId.uiChest);
  final LottieFxController _dustPuff = LottieFxController(FxId.fxDustPuff);
  UiArtImageSource? _source;
  UiArtLibrary? _art;
  double? _ratio;

  /// How many chips have popped (0–2), each 150 ms after the last.
  int _popped = 0;

  /// The rays turn only while the chest is open.
  late final AnimationController _rays = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: ChestRewardSequence.raysTurnMs),
  );
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
      _rays.repeat();
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
    if (!started) {
      _cue(SoundEffect.chestOpen, HapticPattern.nest);
      _rays.repeat();
    }
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
    _rays.stop();
    _exitFade.forward();
    _cue(SoundEffect.coins);
    if (_reduceMotion) {
      widget.onCoinsRevealed?.call(widget.coins);
      if (widget.hints > 0) widget.onHintLanded?.call();
      _at(ChestRewardSequence.exitFadeMs.toDouble(), widget.onCollect);
      return;
    }
    var pending = 2;
    void oneDone() {
      if (--pending == 0 && mounted) widget.onCollect();
    }

    _collectCoins(oneDone);
    _collectHint(oneDone);
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

  @override
  void dispose() {
    _cancelTimers();
    _coinFlight?.dispose();
    _hintFlight?.dispose();
    _chest.dispose();
    _dustPuff.dispose();
    _rays.dispose();
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
          top: top + ChestCardTokens.cardTop - 59,
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
        SizedBox.fromSize(
          size: ChestCardTokens.lottieSize,
          child: _chestVisual(),
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
        _chipsRow(context),
        const SizedBox(height: 14),
        _actionButton(context),
      ],
    );
  }

  /// Nunito 600 16/23 `#7A5234` (ui-spec-game §2.3 "Body").
  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 23 / 16,
    color: AppColors.textBrown,
  );

  // The chest itself.

  Widget _chestVisual() {
    final fallback = ChestIcon(
      size: 156,
      key: ValueKey(_isOpen ? 'fallback-open' : 'fallback-closed'),
    );
    final lottie = LottieFxView(
      key: ChestRewardSequence.chestKey,
      id: FxId.uiChest,
      controller: _chest,
      library: widget.library,
      images: _source,
      fallback: Center(
        child: _isOpen ? const ChestIcon.open(size: 156) : fallback,
      ),
    );
    if (_reduceMotion) {
      // A 200 ms crossfade idle → open's last frame (no wiggle, no rays).
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
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (_opened) _raysLayer(),
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

  /// The lid has gone up (the rays show on `open` and `open_idle` only).
  bool get _opened => _popped > 0;

  Widget _raysLayer() => IgnorePointer(
    child: OverflowBox(
      maxWidth: ChestModalTokens.glowSize,
      maxHeight: ChestModalTokens.glowSize,
      child: RotationTransition(
        turns: _rays,
        child: const CustomPaint(
          key: ChestRewardSequence.raysKey,
          size: Size.square(ChestModalTokens.glowSize),
          painter: _RaysPainter(),
        ),
      ),
    ),
  );

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
    final chips = <Widget>[coinChip];
    if (widget.hints > 0) {
      chips
        ..add(const SizedBox(width: ChestCardTokens.contentsGap))
        ..add(
          _popping(
            2,
            RewardChip(
              key: _hintChipKey,
              kind: RewardChipKind.hint,
              label: l10n.chestContentsHint(widget.hints),
            ),
          ),
        );
    }
    return Semantics(
      liveRegion: _isOpen,
      label: widget.hints > 0
          ? l10n.chestContentsSemantics(widget.coins, widget.hints)
          : l10n.coinsSemantics(widget.coins),
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(mainAxisSize: MainAxisSize.min, children: chips),
        ),
      ),
    );
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
    super.key,
  });

  final double frame;
  final bool open;
  final FxImageSource? source;
  final FxLibrary? library;

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
  Widget build(BuildContext context) => LottieFxView(
    id: FxId.uiChest,
    controller: _controller,
    library: widget.library,
    images: widget.source,
    fallback: Center(
      child: widget.open
          ? const ChestIcon.open(size: 156)
          : const ChestIcon(size: 156),
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

/// The lit rays behind the open chest (`chestModal.glow`): a
/// `repeating-conic-gradient` of 9° lit in every 24°, masked radially, solid
/// to 0.2 of the radius and clear from 0.68.
final class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final lit = ChestModalTokens.glowRayLitDeg * math.pi / 180;
    final period = ChestModalTokens.glowRayPeriodDeg * math.pi / 180;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          ChestModalTokens.glowRayColor,
          ChestModalTokens.glowRayColor,
          ChestModalTokens.glowRayColor.withValues(alpha: 0),
        ],
        stops: [
          0,
          ChestModalTokens.glowMaskSolid,
          ChestModalTokens.glowMaskClear,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var a = 0.0; a < 2 * math.pi; a += period) {
      canvas.drawArc(rect, a, lit, true, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => false;
}

/// Which chip a [RewardChip] is.
enum RewardChipKind { coin, hint }

/// One contents chip of a chest (ui-spec-game §1 "Chip"; `layout.chestCard.
/// contents`): 44 tall, radius 22, a 30 dp disc (the coin's face, or the
/// hint's lightbulb on `#FFE7A0 → #F5C518`), then Fredoka 700 18 `#5B3A21`
/// on `#FFFDF7`.
class RewardChip extends StatelessWidget {
  const RewardChip({required this.kind, required this.label, super.key});

  final RewardChipKind kind;
  final String label;

  static const _style = SurfaceStyle(
    color: Color(0xFFFFFDF7),
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
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
        },
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyleTokens.number.copyWith(
            fontSize: 18,
            height: 1,
            color: const Color(0xFF5B3A21),
          ),
        ),
      ],
    ),
  );
}
