import 'dart:async';
import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/home/widgets/home_chapter_card.dart';
import 'package:nesty_game/features/home/widgets/home_layout.dart';
import 'package:nesty_game/features/settings/widgets/follows_symbols_mode.dart';
import 'package:nesty_game/features/shell/pages/main_shell_page.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_render/nesty_render.dart';

/// Spec §10.2 #2, frame 2.1's hero: the player's chapter background, the
/// coin pill, the small wordmark and the settings gear, five dolls idling
/// on a plank (`doll_idle`, seeded 0.8–1.2 speeds and phases) under
/// twinkles (`fx_twinkle`), PLAY with "Level N" (or "Bonus Level N" past
/// the bundle, m3-design §7.4) and its tier or BONUS badge, the chapter card
/// with its star total and the Records button beside it (J.1, frames 2.1,
/// 12.1-12.3), and the Daily / vs Computer / Remove Ads tiles (frame 9.1).
/// The dev flavor adds a level picker.
@RoutePage()
class HomePage extends StatelessWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
      RepositoryProvider.value(value: get<ShowcaseDolls>()),
      RepositoryProvider.value(value: get<LevelRepository>()),
      RepositoryProvider.value(value: get<DatabaseService>()),
    ],
    child: BlocProvider(create: (_) => get<HomeCubit>()..load(), child: this),
  );

  @override
  Widget build(BuildContext context) {
    // Settings opens over Home: the shelf follows a Color symbols change
    // made there (D91; ShowcaseDolls prepares its art again).
    return SymbolsModeBuilder(
      builder: (context, symbols) => _view(context, symbols),
    );
  }

  Widget _view(BuildContext context, DollSymbols symbols) {
    return BlocBuilder<HomeCubit, AsyncValue<HomeState>>(
      builder: (context, state) => HomeView(
        state: state,
        onRetry: context.read<HomeCubit>().load,
        onPlay: (request) => unawaited(
          context.router.root.push(GameplayRoute(request: request)),
        ),
        onDaily: () => unawaited(context.router.root.push(const DailyRoute())),
        onRelitGlowEnd: context.read<HomeCubit>().relitGlowFinished,
        onMuseum: () =>
            context.tabsRouter.setActiveIndex(MainShellPage.museumIndex),
        onChapters: () =>
            unawaited(context.router.root.push(const ChaptersRoute())),
        onRecords: () =>
            unawaited(context.router.root.push(const RecordsRoute())),
        onVsComputer: () =>
            unawaited(context.router.root.push(const RivalSelectRoute())),
        onShop: (tab) => unawaited(
          context.router.root.navigate(
            MainShellRoute(children: [ShopRoute(initialTab: tab)]),
          ),
        ),
        onSettings: () =>
            unawaited(context.router.root.push(const SettingsRoute())),
        background: context.read<SkinService>().background,
        library: context.read<FxLibrary>(),
        showcase: context.read<ShowcaseDolls>(),
        levels: context.read<LevelRepository>(),
        symbols: symbols,
      ),
    );
  }
}

/// [HomeView]'s default for [HomeView.onChapters]/[HomeView.onRecords].
void _doNothing() {}

/// Frame 2.1 for a [state]. [onPlay] opens a level (the play button, the
/// dev picker); [onDaily], [onMuseum], [onShop] and [onSettings] are the
/// tiles, the coin pill's "+" and the gear. [onChapters] and [onRecords]
/// (m7-design §15.8) default to doing nothing, so a caller that doesn't
/// care about them (an older test) still compiles.
class HomeView extends StatefulWidget {
  const HomeView({
    required this.state,
    required this.onRetry,
    required this.onPlay,
    required this.onDaily,
    this.onRelitGlowEnd,
    required this.onMuseum,
    required this.onShop,
    required this.onSettings,
    this.onChapters = _doNothing,
    this.onRecords = _doNothing,
    this.onVsComputer = _doNothing,
    this.background,
    this.library,
    this.showcase,
    this.levels,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final AsyncValue<HomeState> state;
  final VoidCallback onRetry;
  final ValueChanged<PlayRequest> onPlay;
  final VoidCallback onDaily;

  /// The relit glow ran out (`HomeCubit.relitGlowFinished`).
  final VoidCallback? onRelitGlowEnd;
  final VoidCallback onMuseum;
  final ValueChanged<ShopTab> onShop;
  final VoidCallback onSettings;
  final VoidCallback onChapters;
  final VoidCallback onRecords;

  /// Opens rival select once `raceUnlocked` (E10 phase 2; m7-design P2.10).
  /// A locked tile ignores it (`HomeTile.locked`).
  final VoidCallback onVsComputer;
  final ThemeBackground? background;
  final FxLibrary? library;
  final ShowcaseDolls? showcase;

  /// For the dev level picker.
  final LevelRepository? levels;
  final DollSymbols symbols;

  /// The tiles row's side margin (frame 2.1: 22 dp).
  static const double tilesSide = 22;

  /// The gap the hero keeps above the tiles (design 560 to 584).
  static const double heroTilesGap = 24;

  /// NestyMenus `idle`: tangerine, leaf, cherry, sky and grape on the
  /// plank, x 58/128/206/284/348, heights 104/70/128/88/60.
  static const dolls = [
    (color: DollColor.orange, dx: -137.0, height: 104.0),
    (color: DollColor.green, dx: -67.0, height: 70.0),
    (color: DollColor.red, dx: 11.0, height: 128.0),
    (color: DollColor.blue, dx: 89.0, height: 88.0),
    (color: DollColor.purple, dx: 153.0, height: 60.0),
  ];

  /// NestyMenus `twinkles`: glyph boxes at (x, y) of [size].
  static const twinkles = [
    (x: 96.0, y: 206.0, size: 16.0),
    (x: 250.0, y: 190.0, size: 20.0),
    (x: 330.0, y: 262.0, size: 14.0),
    (x: 36.0, y: 290.0, size: 12.0),
  ];

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Frame 2.1's y where the twinkles' coordinates start.
  static const double _designHeroTop = 180;

  /// Seeded, so Home looks the same on every visit (and in tests).
  static final _idle = () {
    final random = math.Random(21);
    return [
      for (var i = 0; i < HomeView.dolls.length; i++)
        (
          speed: 0.8 + 0.4 * random.nextDouble(),
          phaseMs: 3000 * random.nextDouble(),
        ),
    ];
  }();

  static final _twinklePhases = () {
    final random = math.Random(5);
    return [
      for (var i = 0; i < HomeView.twinkles.length; i++)
        (
          periodMs: 2000 + 400 * random.nextDouble(),
          phaseMs: 2000 * random.nextDouble(),
        ),
    ];
  }();

  static final ValueNotifier<LevelSkin?> _noSkin = ValueNotifier(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The shelf rasters stay while a level covers Home, so coming back never
    // flashes placeholder dolls while they are rasterized again (review
    // FIDELITY-4). They cost little on top of the level's: the part raster
    // cache keeps its own handles of them anyway (m2-lottie-design §4
    // budget, PROGRESS D58).
    _prepareShowcase();
  }

  void _prepareShowcase() {
    final showcase = widget.showcase;
    if (showcase == null) return;
    unawaited(
      showcase.prepare(
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      ),
    );
  }

  void _openPicker() {
    final levels = widget.levels;
    if (levels == null) return;
    unawaited(
      LevelPickerSheet.show(
        context,
        levels: levels,
        onPick: (order) => widget.onPlay(PlayRequest.campaign(order)),
        // Scrolls the sheet to where the player already is (owner-fixes
        // lane, 2026-09-28): Home's own PLAY request is a campaign level
        // whenever the dev picker's button even shows (`levels != null`
        // above already gates the whole button on the dev flavor), so this
        // is the level it would otherwise open next.
        currentOrder: switch (widget.state.data?.playRequest) {
          CampaignPlay(:final order) => order,
          _ => null,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final home = state.data;
    final theme =
        ChapterTheme.byId(home?.themeId ?? 'ch01') ?? ChapterTheme.ch01;
    final error = state.exceptionOrNull;
    return Scaffold(
      backgroundColor: theme.fallbackColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ThemeBackgroundView(theme: theme, background: widget.background),
          if (home != null)
            ValueListenableBuilder<LevelSkin?>(
              valueListenable: widget.showcase?.current ?? _noSkin,
              builder: (context, skin, _) => _hero(context, home, skin),
            )
          else if (error != null)
            SafeArea(
              child: Center(
                child: RetryView(exception: error, onRetry: widget.onRetry),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, HomeState home, LevelSkin? skin) {
    final padding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Every number is measured from the safe area's top, then blended
        // between the tall frame (2.1) and the short one (2.1b) on the
        // body's height.
        final body = constraints.maxHeight - padding.top;
        final layout = HomeLayout.forBody(body);
        final top = padding.top + layout.heroTop;
        final tilesTop = padding.top + layout.tilesTopIn(body);
        final room = tilesTop - HomeView.heroTilesGap - top;
        final blockHeight = layout.heroBottom - layout.heroTop;
        final cardTop = padding.top + layout.chapterCardTop;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: top,
              height: math.max(0.0, math.min(blockHeight, room)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  height: blockHeight,
                  child: _heroBlock(context, home, skin, width, layout),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              // The row is 48 (its targets, review R18), 1 px over the
              // frame's 46 on each side, so the faces stay where they were.
              top: padding.top + 5 - 1,
              child: _Header(
                coins: home.coins,
                onAdd: () => widget.onShop(ShopTab.coins),
                onSettings: widget.onSettings,
              ),
            ),
            Positioned(
              left: HomeTokens.chapterCardLeft,
              right: HomeTokens.recordsButtonRight,
              top: cardTop,
              child: _CardRow(
                home: home,
                onChapters: widget.onChapters,
                onRecords: widget.onRecords,
              ),
            ),
            if (LevelPickerSheet.isAvailable && widget.levels != null)
              Positioned(
                left: 16,
                // Under the chapter card; the compact face's 48 dp target
                // reaches 5 px above it (review R38).
                top: cardTop + HomeChapterCard.minHeight + 8,
                child: TactileButton(
                  label: context.localizations.devLevelPickerTitle,
                  icon: NestyIcons.shuffle,
                  variant: TactileButtonVariant.secondary,
                  size: TactileButtonSize.compact,
                  expand: false,
                  minTouchSize: const Size.square(48),
                  onPressed: _openPicker,
                ),
              ),
            Positioned(
              left: HomeView.tilesSide,
              right: HomeView.tilesSide,
              top: tilesTop,
              child: _TilesRow(
                home: home,
                height: layout.tilesHeight,
                onDaily: widget.onDaily,
                onRelitGlowEnd: widget.onRelitGlowEnd,
                onRemoveAds: () => widget.onShop(ShopTab.noAds),
                onVsComputer: widget.onVsComputer,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _heroBlock(
    BuildContext context,
    HomeState home,
    LevelSkin? skin,
    double width,
    HomeLayout layout,
  ) {
    final center = width / 2;
    // The block's origin is `layout.heroTop`: the plank sits 192 dp below
    // it (frame 2.1's 372 - 180) whatever the screen.
    const plankTop = 192.0;
    const base = plankTop + 12;
    final playTop = plankTop + (layout.playTop - layout.plankTop);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < HomeView.twinkles.length; i++)
          _twinkle(center, HomeView.twinkles[i], _twinklePhases[i]),
        Positioned(
          left: 0,
          right: 0,
          top: plankTop,
          child: PlankStrip(sprites: skin?.sprites),
        ),
        for (var i = 0; i < HomeView.dolls.length; i++)
          LottieDoll.positioned(
            centerX: center + HomeView.dolls[i].dx * layout.dollScale,
            baseY: base,
            doll: LottieDoll(
              id: FxId.dollIdle,
              color: HomeView.dolls[i].color,
              height: HomeView.dolls[i].height * layout.dollScale,
              images: skin?.images,
              renderer: skin?.restRenderer,
              symbols: widget.symbols,
              library: widget.library,
              speed: _idle[i].speed,
              phaseMs: _idle[i].phaseMs,
            ),
          ),
        Positioned(
          left: 36,
          right: 36,
          top: playTop,
          child: _PlayButtonFor(
            request: home.playRequest,
            tier: home.tier,
            height: layout.playHeight,
            onPressed: () => widget.onPlay(home.playRequest),
          ),
        ),
      ],
    );
  }

  Widget _twinkle(
    double center,
    ({double x, double y, double size}) t,
    ({double periodMs, double phaseMs}) timing,
  ) {
    // The Lottie star glows past its glyph: a box twice the glyph's size,
    // centred where the design's glyph sits.
    final box = t.size * 2;
    final cx = center + t.x + t.size / 2 - 195;
    final cy = t.y + t.size / 2 - _designHeroTop;
    return Positioned(
      left: cx - box / 2,
      top: cy - box / 2,
      child: LottieTwinkle(
        size: box,
        periodMs: timing.periodMs,
        phaseMs: timing.phaseMs,
        library: widget.library,
      ),
    );
  }
}

/// PLAY's big line: "Level N" for a campaign board, "Bonus Level N" past
/// the bundle (m3-design §7.4, frame 4.10's teal pill; `PlayButton.title`).
class _PlayButtonFor extends StatelessWidget {
  const _PlayButtonFor({
    required this.request,
    required this.tier,
    required this.height,
    required this.onPressed,
  });

  final PlayRequest request;
  final Tier tier;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final number = request.number;
    return PlayButton(
      level: number,
      tier: tier,
      height: height,
      bonus: request is BonusPlay,
      title: request is BonusPlay ? l10n.bonusLevelTitle(number) : null,
      onPressed: onPressed,
    );
  }
}

/// Home's header (NestyMenus: top 64 on a 59 safe area): the coin pill (its
/// "+" opens the Shop's Coins tab), the 30 px wordmark and the 46 px
/// settings gear. The row is 48 tall so both controls get a 48 dp target
/// (spec §10.3, review R18); their faces keep the frame's sizes.
class _Header extends StatelessWidget {
  const _Header({
    required this.coins,
    required this.onAdd,
    required this.onSettings,
  });

  final int coins;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  /// Kept clear on each side of the wordmark, so a huge balance at 1.3×
  /// text shrinks before it touches it (the wordmark stays centred).
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _CoinPillTarget(coins: coins, onAdd: onAdd),
            ),
          ),
          const SizedBox(width: _gap),
          const Wordmark(size: WordmarkSize.small),
          const SizedBox(width: _gap),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconTactileButton(
                icon: NestyIcons.settings,
                semanticLabel: context.localizations.settings,
                onPressed: onSettings,
                size: 46,
                iconSize: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Home coin pill (its "+" opens the Shop) inside a 48 dp target that
/// stays 48 however far the `FittedBox` shrinks a huge balance at 1.3×
/// text: the target and the button's screen-reader node sit outside the
/// scale, and a touch anywhere in it presses the pill (review R18).
class _CoinPillTarget extends StatelessWidget {
  const _CoinPillTarget({required this.coins, required this.onAdd});

  final int coins;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    void activate() {
      TactileFeedback.of(context)?.activate();
      onAdd();
    }

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: context.localizations.coinPillShopSemantics(coins),
      onTap: activate,
      child: ExcludeSemantics(
        child: TouchTarget(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: CoinPill(coins: coins, onAdd: onAdd),
          ),
        ),
      ),
    );
  }
}

/// The chapter card and the Records button (frame 2.1): the card fills the
/// row, the button is 62 wide beside it, both as tall as the taller.
class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.home,
    required this.onChapters,
    required this.onRecords,
  });

  final HomeState home;
  final VoidCallback onChapters;
  final VoidCallback onRecords;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: HomeChapterCard(
            chapterNumber: home.chapterNumber,
            chapterId: home.chapterId,
            stars: home.chapterStars,
            starsPossible: home.chapterStarsPossible,
            bonus: home.isBonus,
            onTap: onChapters,
          ),
        ),
        // Frame 2.1: the card ends 88 from the edge, the button starts 78.
        const SizedBox(width: 10),
        HomeRecordsButton(
          label: context.localizations.homeRecordsButton,
          onTap: onRecords,
        ),
      ],
    ),
  );
}

/// The Daily / vs Computer / Remove Ads tiles (frames 2.1, 9.1; m3-design
/// §10.3, m7-design §15.8): 132 tall (112 on a short screen), radius 24,
/// gap 12; Remove Ads hides once `adsRemoved`, and the two others widen.
///
/// D111 (the owner's simulator review, 2026-09-28): Home has no Museum tile:
/// the bottom nav's Museum tab covers it, so [HomeView.onMuseum] stays on
/// `HomeView`'s own public constructor (a caller may still pass it) but
/// nothing here reads it.
class _TilesRow extends StatelessWidget {
  const _TilesRow({
    required this.home,
    required this.height,
    required this.onDaily,
    required this.onRelitGlowEnd,
    required this.onRemoveAds,
    required this.onVsComputer,
  });

  final HomeState home;
  final double height;
  final VoidCallback onDaily;
  final VoidCallback? onRelitGlowEnd;

  /// Opens the Shop's No Ads tab (m3-design §10.3).
  final VoidCallback onRemoveAds;
  final VoidCallback onVsComputer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locked = !home.dailyUnlocked;
    final streak = home.dailyStreak;
    final look = home.streakLook;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: HomeTile(
            tileHeight: height,
            leading: const HomeTileIcon(
              gradient: AppGradientTokens.daily,
              edgeColor: AppColorTokens.dailyEdge,
              highlightOpacity: 0.6,
              child: Icon(
                NestyIcons.extension,
                size: 34,
                color: AppColorTokens.coinText,
              ),
            ),
            label: l10n.homeDailyTile,
            footer: locked
                ? Text(
                    l10n.homeDailyLocked(DailyService.unlockAfterLevel),
                    style: _footerStyle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  )
                : null,
            // Frame 12.2: a streak of 0 still draws its unlit flame.
            badge: StreakBadge(
              days: streak,
              look: look,
              onRelitGlowEnd: onRelitGlowEnd,
            ),
            locked: locked,
            // The footer says why it is locked; the tile's node reads it
            // too (review R15). An open tile reads its streak.
            semanticValue: locked
                ? l10n.homeDailyLocked(DailyService.unlockAfterLevel)
                : switch (look) {
                    StreakLook.zero => null,
                    StreakLook.paused => l10n.streakBadgeSemanticsPaused(
                      streak,
                    ),
                    StreakLook.lit ||
                    StreakLook.relit => l10n.streakBadgeSemantics(streak),
                  },
            onTap: onDaily,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VsComputerTile(
            home: home,
            height: height,
            onTap: onVsComputer,
          ),
        ),
        if (!home.adsRemoved) ...[
          const SizedBox(width: 12),
          Expanded(
            child: HomeTile(
              tileHeight: height,
              leading: HomeTileIcon(
                gradient: AppGradientTokens.ad,
                edgeColor: AppColorTokens.adEdge,
                child: HomeTileIcon.removeAdsGlyph(),
              ),
              label: l10n.homeRemoveAdsTile,
              onTap: onRemoveAds,
            ),
          ),
        ],
      ],
    );
  }

  /// "After Level 2" (NestyHub:39, :43): Nunito 800 12, `#8A5B3A`.
  static final _footerStyle = AppTextStyleTokens.caption.copyWith(
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
    color: AppColorTokens.textSecondary,
  );
}

/// The "vs Computer" tile (frames 9.1 locked, 2.1 open; menus spec 1.1):
/// rival 1's portrait in a 62 dp disc, the label, and the Computer tag under
/// it (spec-prop §1.1 rule 5: a computer is always labelled one). Locked
/// until `raceUnlockLevel`: the locked portrait with a lock chip and "After
/// Level 20", dimmed and inert, no shake and no haptic; unlocked, a tap opens
/// rival select (9.2) on the root router.
class _VsComputerTile extends StatelessWidget {
  const _VsComputerTile({
    required this.home,
    required this.height,
    required this.onTap,
  });

  final HomeState home;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locked = !home.raceUnlocked;
    final lockedLine = l10n.homeVsComputerLocked(home.raceUnlockLevel);
    return HomeTile(
      tileHeight: height,
      leading: _VersusPortrait(locked: locked),
      label: l10n.homeVsComputerTile,
      footer: locked
          ? Text(
              lockedLine,
              style: _TilesRow._footerStyle,
              textAlign: TextAlign.center,
              maxLines: 3,
            )
          : LayoutBuilder(
              // The tag drops to its glyph when the full tag is wider than
              // the tile (textFit short form), instead of scaling the
              // whole column below the readability floor. The label above
              // ("vs Computer") keeps the word (rule 5; D271).
              builder: (context, constraints) => ComputerTag(
                glyphOnly: ComputerTag.glyphOnlyForRow(
                  context,
                  lead: '',
                  leadStyle: RivalStripTokens.tagText,
                  gap: 0,
                  maxWidth: constraints.maxWidth,
                  minScale: 1,
                ),
              ),
            ),
      locked: locked,
      // Locked, one sentence says so (copy.md A11y `a11y_home_versus_locked`);
      // open, the tile says what it does (`a11y_home_versus`).
      semanticLabel: locked
          ? l10n.homeVsComputerLockedSemantics(home.raceUnlockLevel)
          : l10n.homeVsComputerSemantics,
      onTap: onTap,
    );
  }
}

/// vs Computer's 62 dp portrait disc (frame 2.1): rival 1's art on a cream
/// disc with a 2 dp white ring; locked, the locked portrait plus a 24 dp lock
/// chip at its bottom-right (frame 9.1).
class _VersusPortrait extends StatelessWidget {
  const _VersusPortrait({required this.locked});

  final bool locked;

  static const double size = 62;

  static const _ring = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: AppColorTokens.surfaceWhite, spread: 2),
      NestyShadow(color: Color(0x1F5A3214), dy: 2, blur: 4),
    ],
  );

  static const _chip = SurfaceStyle(
    color: AppColorTokens.textSecondary,
    shadows: [NestyShadow(color: AppColorTokens.surfaceWhite, spread: 2)],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        NestySurface(
          style: _ring,
          radius: BorderRadius.circular(size / 2),
          width: size,
          height: size,
          alignment: Alignment.center,
          child: UiArtImage.square(
            UiArt.rival(locked ? null : 1),
            extent: size - 4,
          ),
        ),
        if (locked)
          PositionedDirectional(
            end: -2,
            bottom: -2,
            child: NestySurface(
              style: _chip,
              radius: BorderRadius.circular(12),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(
                NestyIcons.lock,
                size: 14,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
      ],
    ),
  );
}
