import 'dart:async';
import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_game/features/settings/widgets/follows_symbols_mode.dart';
import 'package:nesty_game/features/shell/pages/main_shell_page.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_render/nesty_render.dart';

/// Spec §10.2 #2, frame 2.1's hero: the player's chapter background, the
/// coin pill, the small wordmark and the settings gear, five dolls idling
/// on a plank (`doll_idle`, seeded 0.8–1.2 speeds and phases) under
/// twinkles (`fx_twinkle`), PLAY with "Level N" (or "Bonus Level N" past
/// the bundle, m3-design §7.4) and its tier badge, and the Daily / Museum /
/// Remove Ads tiles (§10.3). The dev flavor adds a level picker.
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
        onMuseum: () =>
            context.tabsRouter.setActiveIndex(MainShellPage.museumIndex),
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

/// Frame 2.1 for a [state]. [onPlay] opens a level (the play button, the
/// dev picker); [onDaily], [onMuseum], [onShop] and [onSettings] are the
/// tiles, the coin pill's "+" and the gear.
class HomeView extends StatefulWidget {
  const HomeView({
    required this.state,
    required this.onRetry,
    required this.onPlay,
    required this.onDaily,
    required this.onMuseum,
    required this.onShop,
    required this.onSettings,
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
  final VoidCallback onMuseum;
  final ValueChanged<ShopTab> onShop;
  final VoidCallback onSettings;
  final ThemeBackground? background;
  final FxLibrary? library;
  final ShowcaseDolls? showcase;

  /// For the dev level picker.
  final LevelRepository? levels;
  final DollSymbols symbols;

  /// The hero block: design y 180 (the twinkles) to 560 (under PLAY).
  static const double heroTop = 180;
  static const double heroHeight = 380;

  /// The tiles row: design y 584, 132 tall (frame 2.1; m3-design §10.3).
  static const double tilesTop = 584;
  static const double tilesSide = 22;

  /// The gap the hero keeps above the tiles (design 560 to 584).
  static const double heroTilesGap = tilesTop - heroTop - heroHeight;

  /// The least room under the tiles on a screen too short for the frame's
  /// y (a 16:9 Android phone's body is about 630 tall): the tiles then sit
  /// this far above the body's bottom (the nav) and the hero scales down
  /// into what is left above them.
  // TODO(design): frame 2.1 has no short-screen variant; 12 is a guess.
  static const double tilesBottomGap = 12;

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
        final top = padding.top + HomeView.heroTop - 59;
        final tilesTop = math.min(
          padding.top + HomeView.tilesTop - 59,
          constraints.maxHeight -
              padding.bottom -
              HomeView.tilesBottomGap -
              HomeTile.height,
        );
        final room = tilesTop - HomeView.heroTilesGap - top;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: top,
              height: math.max(0.0, math.min(HomeView.heroHeight, room)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  height: HomeView.heroHeight,
                  child: _heroBlock(context, home, skin, width),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: padding.top + 5,
              child: _Header(
                coins: home.coins,
                onAdd: () => widget.onShop(ShopTab.coins),
                onSettings: widget.onSettings,
              ),
            ),
            if (LevelPickerSheet.isAvailable && widget.levels != null)
              Positioned(
                left: 16,
                top: padding.top + 5 + 46 + 14,
                child: TactileButton(
                  label: context.localizations.devLevelPickerTitle,
                  icon: NestyIcons.shuffle,
                  variant: TactileButtonVariant.secondary,
                  size: TactileButtonSize.compact,
                  expand: false,
                  onPressed: _openPicker,
                ),
              ),
            Positioned(
              left: HomeView.tilesSide,
              right: HomeView.tilesSide,
              top: tilesTop,
              child: _TilesRow(
                home: home,
                onDaily: widget.onDaily,
                onMuseum: widget.onMuseum,
                onRemoveAds: () => widget.onShop(ShopTab.noAds),
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
  ) {
    final center = width / 2;
    // Design y − 180.
    const plankTop = 372 - HomeView.heroTop;
    const base = 384 - HomeView.heroTop;
    const playTop = 446 - HomeView.heroTop;
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
            centerX: center + HomeView.dolls[i].dx,
            baseY: base,
            doll: LottieDoll(
              id: FxId.dollIdle,
              color: HomeView.dolls[i].color,
              height: HomeView.dolls[i].height,
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
    final cy = t.y + t.size / 2 - HomeView.heroTop;
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
    required this.onPressed,
  });

  final PlayRequest request;
  final Tier tier;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final number = request.number;
    return PlayButton(
      level: number,
      tier: tier,
      title: request is BonusPlay ? l10n.bonusLevelTitle(number) : null,
      onPressed: onPressed,
    );
  }
}

/// Home's header (NestyMenus: top 64 on a 59 safe area): the coin pill (its
/// "+" opens the Shop's Coins tab), the 30 px wordmark and the 46 px
/// settings gear.
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
      height: 46,
      child: Row(
        children: [
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CoinPill(coins: coins, onAdd: onAdd),
              ),
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

/// The Daily / Museum / Remove Ads tiles (frame 2.1; m3-design §10.3): 132
/// tall, radius 24, gap 12; Remove Ads hides once `adsRemoved` and the other
/// two widen to share its width.
class _TilesRow extends StatelessWidget {
  const _TilesRow({
    required this.home,
    required this.onDaily,
    required this.onMuseum,
    required this.onRemoveAds,
  });

  final HomeState home;
  final VoidCallback onDaily;
  final VoidCallback onMuseum;

  /// Opens the Shop's No Ads tab (m3-design §10.3).
  final VoidCallback onRemoveAds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locked = !home.dailyUnlocked;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: HomeTile(
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
                ? Text(l10n.homeDailyLocked, style: _footerStyle)
                : null,
            badge: home.dailyStreak > 0
                ? StreakBadge(days: home.dailyStreak)
                : null,
            locked: locked,
            onTap: onDaily,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeTile(
            leading: _MuseumArt(state: home),
            label: l10n.homeMuseumTile,
            footer: _MuseumFooter(state: home),
            onTap: onMuseum,
          ),
        ),
        if (!home.adsRemoved) ...[
          const SizedBox(width: 12),
          Expanded(
            child: HomeTile(
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

  static final _footerStyle = AppTextStyleTokens.cardTitle.copyWith(
    fontSize: 12,
    height: 1,
    color: AppColors.textBrown,
  );
}

/// The next uncollected figurine's locked art (`FigurineImage`, shared with
/// the Museum cabinet and its modal), or the museum glyph once
/// [HomeState.museumAllCollected] (`TODO(design)`, m3-design §10.6).
class _MuseumArt extends StatelessWidget {
  const _MuseumArt({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final figurineId = state.museumFigurineId;
    if (figurineId == null) {
      return const Icon(
        NestyIcons.museum,
        size: 40,
        color: AppColors.iconBrown,
      );
    }
    return FigurineImage(figurineId: figurineId, locked: true, size: 62);
  }
}

/// The "15/20" bar of the current chapter, or a plain collection count in
/// Bonus Endless (`TODO(design)`, m3-design §10.3, §10.6).
class _MuseumFooter extends StatelessWidget {
  const _MuseumFooter({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final done = state.museumAllCollected
        ? state.museumCollectedCount
        : state.museumDone;
    final total = state.museumAllCollected
        ? state.museumCollectedTotal
        : state.museumTotal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 8,
          child: NestyProgressBar(
            value: total == 0 ? 0 : done / total,
            height: 8,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          l10n.homeMuseumProgress(done, total),
          style: AppTextStyleTokens.cardTitle.copyWith(
            fontSize: 12,
            height: 1,
            color: AppColors.textBrown,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
