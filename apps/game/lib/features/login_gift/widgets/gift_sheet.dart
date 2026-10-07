import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_anchors.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_day_tile.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_metrics.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_reward_label.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_scrim.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_tally.dart';

/// The daily gift's sheet (frames 13.3–13.8; `gift.sheet`), opened only by
/// Home's gift button: the title and its calm sub line, the whole track of
/// seven days with what each pays (Days 1–6 three across, Day 7 the wide
/// tile below with the chest), then Claim, or once today's gift is yours
/// the claimed line and "Tomorrow: …" (the waiting state, when the phone's
/// clock went back, shows "Next gift: …" alone, with no Claim and no date).
/// No countdown and no clock text anywhere (D92). Over [LoginGiftCubit],
/// provided by [show].
///
/// Claiming Days 1–6 pays at once and the sheet stays open: today's tile
/// sinks to done, Claim cross-fades to the lines, and the gift flies home
/// (`gift.claim`): coins from the tile to the coin pill through a hole in
/// the scrim, a hint or a slot to the tally under the pill ([GiftTally]).
/// Claiming Day 7 pays at once too, then the sheet closes (280 ms) with the
/// grant so the button can open the chest (`GiftChestModal`).
class GiftSheet extends StatefulWidget {
  const GiftSheet({
    this.anchors,
    this.feedback,
    this.uiArt,
    this.safeTop,
    this.scrim,
    super.key,
  });

  /// Home's coin pill, read live at the claim (null: nothing to fly to, the
  /// pill updates at once).
  final GiftAnchors? anchors;

  /// Sound and haptics for a claim; none in a test without them.
  final FeedbackSink? feedback;
  final UiArtLibrary? uiArt;

  /// The top safe area under the sheet (the modal route strips it).
  final double? safeTop;

  /// The route's scrim, whose hole a coin claim opens.
  final GiftScrim? scrim;

  /// Opens the sheet over Home. It resolves with the Day 7 grant when the
  /// player claimed Day 7 (the caller opens the chest), else null. Nothing
  /// else opens it: no code path shows it on its own (D92).
  static Future<LoginGiftGrant?> show(
    BuildContext context, {
    GiftAnchors? anchors,
    FeedbackSink? feedback,
    UiArtLibrary? uiArt,
  }) {
    final cubit = context.read<LoginGiftCubit>();
    // Reads today again, so a date that changed while Home sat open shows.
    unawaited(cubit.refresh());
    final safeTop = MediaQuery.viewPaddingOf(context).top;
    final navigator = Navigator.of(context);
    final localizations = MaterialLocalizations.of(context);
    final scrim = GiftScrim();
    return navigator.push(
      GiftSheetRoute<LoginGiftGrant>(
        scrim: scrim,
        isScrollControlled: true,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        barrierLabel: localizations.scrimLabel,
        barrierOnTapHint: localizations.scrimOnTapHint(
          localizations.bottomSheetLabel,
        ),
        backgroundColor: const Color(0x00000000),
        // In with `motion.ui.sheetIn`; out over Day 7's 280 ms
        // (`gift.claim.day7`), the same for a plain close.
        sheetAnimationStyle: const AnimationStyle(
          duration: Duration(milliseconds: UiMotionTokens.sheetInMs),
          reverseDuration: Duration(
            milliseconds: GiftClaimTokens.day7SheetCloseMs,
          ),
        ),
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: GiftSheet(
            anchors: anchors,
            feedback: feedback,
            uiArt: uiArt,
            safeTop: safeTop,
            scrim: scrim,
          ),
        ),
      ),
    );
  }

  /// The sheet stops this far under the safe top (the language sheet's).
  static const double topGap = 72;

  /// The sheet's title is one line and scales to this before its short form
  /// takes over (`textFit.giftSheet`).
  static const double titleMinScale = 0.85;

  /// The Claim button, for tests.
  @visibleForTesting
  static const Key claimKey = Key('gift-claim');

  /// The calm lines shown once claimed or while waiting, for tests.
  @visibleForTesting
  static const Key calmKey = Key('gift-calm');

  /// The sheet's surface, for tests.
  @visibleForTesting
  static const Key surfaceKey = Key('gift-sheet');

  /// The scaled reference size of the frames' flight paths.
  static const Size referenceScreen = Size(390, 844);

  /// The hint's path control point in the `claimHint` scene (from a row-2
  /// tile to the tally); tokens name only the coins' one.
  static const Offset hintPathControl = Offset(300, 240);

  /// How many coin sprites a claim of [coins] flies: one per 10, 2 to 6
  /// (`gift.claim.coins.sprites`: 20 → 2, 40 → 4, 100 → 6). A look, not
  /// the reward: the amount is the track's.
  static int coinSpritesFor(int coins) =>
      (coins ~/ GiftClaimTokens.coinsSpriteEvery).clamp(
        GiftClaimTokens.coinsSpritesMin,
        GiftClaimTokens.coinsSpritesMax,
      );

  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> with TickerProviderStateMixin {
  final _tileKeys = List.generate(
    LoginGiftRules.trackLength,
    (_) => GlobalKey(),
  );
  RewardFlightHandle? _coinFlight;

  /// Coins are in the air: the pill is held below the balance.
  bool _coinsInFlight = false;
  final List<RewardFlightHandle> _tallyFlights = [];
  GiftTallyHandle? _tally;
  LoginGiftCubit? _cubit;
  Timer? _reducedRing;

  /// What this sheet just claimed, for the screen reader's "Gift claimed".
  LoginGiftReward? _claimed;

  late final AnimationController _hole;
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _hole = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: GiftClaimTokens.tileSinkMs),
      reverseDuration: const Duration(
        milliseconds: GiftClaimTokens.coinsPillHoleCloseMs,
      ),
    )..addListener(() => widget.scrim?.holeOpen = _hole.value);
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: ChestCollectTokens.pillRingInMs),
      reverseDuration: const Duration(
        milliseconds: ChestCollectTokens.pillRingOutMs,
      ),
    )..addListener(() => widget.scrim?.ring = _ring.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<LoginGiftCubit>();
  }

  @override
  void dispose() {
    _reducedRing?.cancel();
    // A sheet closed mid-flight must not leave Home's pill held below the
    // balance, nor the tally's count short: the gift is paid already.
    // (A landed flight may still be fading its trail: it goes too.)
    _coinFlight?.dispose();
    if (_coinsInFlight) {
      final cubit = _cubit;
      if (cubit != null) scheduleMicrotask(cubit.releaseCoins);
    }
    for (final flight in _tallyFlights) {
      flight.dispose();
    }
    _tally?.landAll();
    _hole.dispose();
    _ring.dispose();
    super.dispose();
  }

  Rect? _rectOf(int day) => globalRectOfKey(_tileKeys[day - 1]);

  void _cue(SoundEffect? sound, [HapticPattern? haptic]) =>
      widget.feedback?.play(FxCue(atMs: 0, sound: sound, haptic: haptic));

  /// A frame's point on the 390×844 reference, on this screen (mirrored
  /// right to left).
  Offset _scaled(Offset reference) {
    final size = MediaQuery.sizeOf(context);
    final x = reference.dx * size.width / GiftSheet.referenceScreen.width;
    final y = reference.dy * size.height / GiftSheet.referenceScreen.height;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Offset(rtl ? size.width - x : x, y);
  }

  void _claim() {
    final cubit = context.read<LoginGiftCubit>();
    final current = cubit.state.data;
    if (current == null || !current.canClaim) return;
    final day = current.nextDay;
    final isChest = day == LoginGiftRules.trackLength;
    final reduce = context.reduceMotion;
    final from = _rectOf(day);
    final coinTo = widget.anchors?.coinDisc();
    final flyCoins =
        !isChest &&
        !reduce &&
        from != null &&
        coinTo != null &&
        current.nextReward.coins > 0;
    final grant = cubit.claim(holdCoins: isChest || flyCoins);
    if (grant == null) return;
    // `gift_claim` at 0 and a light haptic on every Claim (`gift.claim.sound`,
    // `.haptic`).
    _cue(SoundEffect.giftClaim, HapticPattern.giftClaim);
    if (isChest) {
      // Paid already (nothing is lost if the app dies mid-chest); the
      // button opens the chest over Home as the sheet closes.
      Navigator.of(context).pop(grant);
      return;
    }
    setState(() => _claimed = grant.reward);
    _payCoins(cubit, grant.reward, from, coinTo, fly: flyCoins, reduce: reduce);
    _payTally(cubit, grant.reward, from, reduce: reduce);
  }

  /// Coins: one sprite per 10, 2 to 6, from today's tile to the pill's coin
  /// disc through a hole in the scrim; the pill ticks up per landing and
  /// rings (`gift.claim.coins`). Reduce motion: the pill shows the new count
  /// at once, ringed for 400 ms.
  void _payCoins(
    LoginGiftCubit cubit,
    LoginGiftReward reward,
    Rect? from,
    Rect? to, {
    required bool fly,
    required bool reduce,
  }) {
    if (reward.coins <= 0) return;
    final pill = widget.anchors?.pill();
    widget.scrim?.pill = pill;
    if (!fly || from == null || to == null) {
      cubit.releaseCoins();
      _cue(SoundEffect.coins);
      if (pill != null) _ringBriefly();
      return;
    }
    final sprites = GiftSheet.coinSpritesFor(reward.coins);
    unawaited(_hole.forward());
    _coinsInFlight = true;
    _coinFlight = RewardFlight.launch(
      context,
      from: from,
      to: to,
      count: sprites,
      control: _scaled(GiftClaimTokens.coinsPathControl),
      trail: true,
      trailDots: ChestCollectTokens.trailCoinDots.round(),
      spriteBuilder: (context) => UiArtImage.square(
        UiArt.coinFlight,
        extent: 30,
        library: widget.uiArt,
      ),
      vsync: this,
      stagger: const Duration(milliseconds: GiftClaimTokens.coinsStaggerMs),
      flightDuration: const Duration(milliseconds: GiftClaimTokens.coinsMs),
      onLanded: (i) {
        if (i == 0) {
          // `coins` as the first coin lands, and the ring comes on.
          _cue(SoundEffect.coins);
          unawaited(_ring.forward());
        }
        cubit.coinsLanded((reward.coins * (i + 1) / sprites).round());
      },
      onAllLanded: () {
        _coinsInFlight = false;
        cubit
          ..coinsLanded(reward.coins)
          ..releaseCoins();
        if (!mounted) return;
        unawaited(_ring.reverse());
        unawaited(_hole.reverse());
      },
    );
  }

  /// Reduce motion's ring (or a claim with nothing to fly): the hole and
  /// the ring at once, for `claimPillRingMs`.
  void _ringBriefly() {
    _hole.value = 1;
    _ring.value = 1;
    _reducedRing?.cancel();
    _reducedRing = Timer(
      const Duration(milliseconds: GiftReducedMotionTokens.claimPillRingMs),
      () {
        if (!mounted) return;
        _hole.value = 0;
        _ring.value = 0;
      },
    );
  }

  /// A hint or a slot: the tally slides out under the pill and the sprite
  /// flies from today's tile to its disc (`gift.claim.hint`, `.slot`); a
  /// light haptic as it lands. Reduce motion: no flight; the tally fades in
  /// with the new count.
  void _payTally(
    LoginGiftCubit cubit,
    LoginGiftReward reward,
    Rect? from, {
    required bool reduce,
  }) {
    final totals = cubit.state.data;
    final entries = [
      if (reward.hints > 0)
        GiftTallyEntry(
          kind: GiftTallyKind.hint,
          added: reward.hints,
          total: totals?.hints ?? reward.hints,
        ),
      if (reward.slots > 0)
        GiftTallyEntry(
          kind: GiftTallyKind.slot,
          added: reward.slots,
          total: totals?.slots ?? reward.slots,
        ),
    ];
    if (entries.isEmpty) return;
    final pill = widget.anchors?.pill();
    final tally = pill == null
        ? null
        : GiftTally.show(
            context,
            pill: pill,
            entries: entries,
            reduceMotion: reduce,
          );
    _tally = tally;
    if (tally == null || reduce || from == null) {
      tally?.landAll();
      _cue(null, HapticPattern.giftClaim);
      return;
    }
    for (final entry in entries) {
      final to = tally.discOf(entry.kind);
      if (to == null) continue;
      final flight = RewardFlight.launch(
        context,
        from: from,
        to: to,
        count: 1,
        control: _scaled(GiftSheet.hintPathControl),
        trail: true,
        trailDots: ChestCollectTokens.trailHintDots.round(),
        spriteBuilder: (context) => UiArtImage.square(
          entry.kind == GiftTallyKind.hint
              ? UiArt.hintFlight
              : UiArt.slotFlight,
          extent: entry.kind == GiftTallyKind.hint
              ? GiftClaimTokens.hintSpriteSize
              : GiftClaimTokens.slotSpriteSize,
          library: widget.uiArt,
        ),
        vsync: this,
        flightDuration: Duration(
          milliseconds: entry.kind == GiftTallyKind.hint
              ? GiftClaimTokens.hintMs
              : GiftClaimTokens.slotMs,
        ),
        onLanded: (_) {
          tally.land(entry.kind);
          _cue(null, HapticPattern.giftClaim);
        },
      );
      if (flight != null) _tallyFlights.add(flight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final metrics = GiftSheetMetrics.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            media.size.height -
            (widget.safeTop ?? media.viewPadding.top) -
            GiftSheet.topGap,
      ),
      child: BlocBuilder<LoginGiftCubit, AsyncValue<LoginGiftState>>(
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, value) {
          final gift = value.data;
          if (gift == null) return const SizedBox.shrink();
          return _surface(context, gift, metrics);
        },
      ),
    );
  }

  static const _sheetStyle = SurfaceStyle(
    gradient: GiftSheetTokens.face,
    shadows: GiftSheetTokens.shadow,
  );

  Widget _surface(
    BuildContext context,
    LoginGiftState gift,
    GiftSheetMetrics metrics,
  ) {
    final l10n = context.localizations;
    final side = metrics.paddingSide;
    final bottom = metrics.paddingBottom(
      MediaQuery.maybeViewPaddingOf(context)?.bottom ?? 0,
    );
    return NestySurface(
      key: GiftSheet.surfaceKey,
      style: _sheetStyle,
      radius: const BorderRadius.vertical(
        top: Radius.circular(GiftSheetTokens.radius),
      ),
      width: double.infinity,
      padding: EdgeInsets.only(top: metrics.paddingTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.fromSize(
            size: GiftSheetTokens.grabberSize,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: GiftSheetTokens.grabberColor,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
          ),
          SizedBox(height: metrics.titleGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: side),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.titleHeight),
              child: Center(
                child: Semantics(
                  header: true,
                  namesRoute: true,
                  child: FitText(
                    l10n.giftTitle,
                    short: l10n.giftTitleShort,
                    minScale: GiftSheet.titleMinScale,
                    style: GiftTypeTokens.title.copyWith(
                      fontSize: metrics.titleSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: metrics.subGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: side),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.subHeight),
              child: Text(
                l10n.giftSubtitle,
                textAlign: TextAlign.center,
                style: context.scriptStyle(
                  GiftTypeTokens.sub.copyWith(fontSize: metrics.subSize),
                  role: ScriptTextRole.body,
                ),
              ),
            ),
          ),
          Flexible(
            // On a short phone at 1.3× text the days scroll rather than
            // overflow; the padding keeps the rings and edges inside the
            // clip.
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, metrics.gridGap, side, bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _grid(gift, metrics),
                  SizedBox(height: metrics.day7GapAbove),
                  _dayTile(gift, LoginGiftRules.trackLength, metrics),
                  SizedBox(height: metrics.footerGap),
                  _footer(context, gift, metrics),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayTile(LoginGiftState gift, int day, GiftSheetMetrics metrics) =>
      KeyedSubtree(
        key: _tileKeys[day - 1],
        child: GiftDayTile(
          day: day,
          reward: gift.track[day - 1],
          tileState: gift.tileStateOf(day),
          wide: day == LoginGiftRules.trackLength,
          metrics: metrics,
          uiArt: widget.uiArt,
        ),
      );

  /// Days 1–6, three across (`gift.sheet.grid`).
  Widget _grid(LoginGiftState gift, GiftSheetMetrics metrics) {
    const columns = GiftSheetTokens.gridColumns;
    const rows = (LoginGiftRules.trackLength - 1) ~/ columns;
    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) SizedBox(height: metrics.tileGap),
          Row(
            children: [
              for (var col = 0; col < columns; col++) ...[
                if (col > 0) SizedBox(width: metrics.tileGap),
                Expanded(
                  child: _dayTile(gift, row * columns + col + 1, metrics),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  /// Claim, or the lines; they cross-fade over `gift.sheet.footer.swap`
  /// (200 ms) in a box that keeps the footer's height, so nothing moves.
  Widget _footer(
    BuildContext context,
    LoginGiftState gift,
    GiftSheetMetrics metrics,
  ) {
    final l10n = context.localizations;
    final Widget child;
    if (gift.canClaim) {
      child = Center(
        key: GiftSheet.claimKey,
        child: TactileButton(label: l10n.giftClaim, onPressed: _claim),
      );
    } else {
      child = KeyedSubtree(
        key: GiftSheet.calmKey,
        child: _CalmLines(gift: gift, claimed: _claimed),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.footerHeight),
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds: context.reduceMotion
              ? GiftReducedMotionTokens.claimCrossFadeMs
              : GiftSheetTokens.footerSwapMs,
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, ?current],
        ),
        child: child,
      ),
    );
  }
}

/// The footer's lines (13.4, 13.8; `type.gift.line1`, `.line2`): "Today's
/// gift is yours." over "Tomorrow: …" once claimed; "Next gift: …" alone
/// while waiting. They wrap freely (`textFit.giftSheet`); "Tomorrow: …"
/// takes the short slot phrase when it would wrap past two lines (copy.md
/// "Short forms"). One live region reads them, after "Gift claimed: …"
/// when this sheet just claimed.
class _CalmLines extends StatelessWidget {
  const _CalmLines({required this.gift, required this.claimed});

  final LoginGiftState gift;
  final LoginGiftReward? claimed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final isClaimed = gift.phase == LoginGiftPhase.claimed;
    final line1 = isClaimed ? l10n.giftClaimedLine : null;
    final line1Style = context.scriptStyle(
      GiftTypeTokens.line1,
      role: ScriptTextRole.title,
    );
    final line2Style = context.scriptStyle(
      GiftTypeTokens.line2,
      role: ScriptTextRole.body,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        String line2Of({required bool short}) {
          final next = giftRewardLabel(
            l10n,
            gift.nextReward,
            shortSlots: short,
          );
          return isClaimed ? l10n.giftTomorrow(next) : l10n.giftNext(next);
        }

        var line2 = line2Of(short: false);
        if (gift.nextReward.slots > 0 &&
            _wrapsPastTwo(context, line2, line2Style, constraints.maxWidth)) {
          line2 = line2Of(short: true);
        }
        final spoken = [
          if (claimed case final reward?)
            l10n.giftA11yClaimed(giftRewardSemantics(l10n, reward)),
          ?line1,
          line2,
        ];
        return Semantics(
          container: true,
          liveRegion: true,
          label: l10n.joinSentences(spoken),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (line1 != null) ...[
                  Text(line1, textAlign: TextAlign.center, style: line1Style),
                  const SizedBox(height: 5),
                ],
                BalancedText(
                  line2,
                  style: line2Style,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _wrapsPastTwo(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    if (!maxWidth.isFinite) return false;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    )..layout(maxWidth: maxWidth);
    final over = painter.didExceedMaxLines;
    painter.dispose();
    return over;
  }
}
