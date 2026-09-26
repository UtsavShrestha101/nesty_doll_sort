import 'dart:async';
import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_render/nesty_render.dart';

/// Spec §10.2 #2, frame 2.1's hero: the player's chapter background, the
/// coin pill, the small wordmark and the settings gear, five dolls idling
/// on a plank (`doll_idle`, seeded 0.8–1.2 speeds and phases) under
/// twinkles (`fx_twinkle`), and PLAY with "Level N" and its tier badge.
/// The dev flavor adds a level picker.
///
/// TODO(M3): the Daily / Museum / Remove Ads tiles, the bottom nav, the
/// coin pill's "+" (Shop) and the gear (Settings).
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
    return BlocBuilder<HomeCubit, AsyncValue<HomeState>>(
      builder: (context, state) => HomeView(
        state: state,
        onRetry: context.read<HomeCubit>().load,
        onPlay: (level) =>
            unawaited(context.router.push(GameplayRoute(levelNumber: level))),
        background: context.read<SkinService>().background,
        library: context.read<FxLibrary>(),
        showcase: context.read<ShowcaseDolls>(),
        levels: context.read<LevelRepository>(),
        symbols: context.read<DatabaseService>().symbolsMode.dollSymbols,
      ),
    );
  }
}

/// Frame 2.1 for a [state]. [onPlay] opens a level (the play button, the
/// dev picker).
class HomeView extends StatefulWidget {
  const HomeView({
    required this.state,
    required this.onRetry,
    required this.onPlay,
    this.background,
    this.library,
    this.showcase,
    this.levels,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final AsyncValue<HomeState> state;
  final VoidCallback onRetry;
  final ValueChanged<int> onPlay;
  final ThemeBackground? background;
  final FxLibrary? library;
  final ShowcaseDolls? showcase;

  /// For the dev level picker.
  final LevelRepository? levels;
  final DollSymbols symbols;

  /// The hero block: design y 180 (the twinkles) to 560 (under PLAY).
  static const double heroTop = 180;
  static const double heroHeight = 380;

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

  bool _showAllDone = false;

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

  void _play(HomeState home) {
    if (home.allLevelsDone) {
      setState(() => _showAllDone = true);
      return;
    }
    widget.onPlay(home.currentLevel);
  }

  void _openPicker() {
    final levels = widget.levels;
    if (levels == null) return;
    unawaited(
      LevelPickerSheet.show(context, levels: levels, onPick: widget.onPlay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final home = state.data;
    final theme =
        ChapterTheme.byId(home?.chapterId ?? 'ch01') ?? ChapterTheme.ch01;
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
          if (home != null && _showAllDone)
            ValueListenableBuilder<LevelSkin?>(
              valueListenable: widget.showcase?.current ?? _noSkin,
              builder: (context, skin, _) => AllLevelsDone(
                families: ShowcaseDolls.colors,
                images: skin?.images,
                renderer: skin?.restRenderer,
                symbols: widget.symbols,
                library: widget.library,
                onHome: () => setState(() => _showAllDone = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, HomeState home, LevelSkin? skin) {
    final l10n = context.localizations;
    final padding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final top = padding.top + HomeView.heroTop - 59;
        final room = constraints.maxHeight - top - padding.bottom;
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
              child: _Header(coins: home.coins),
            ),
            if (LevelPickerSheet.isAvailable && widget.levels != null)
              Positioned(
                left: 16,
                top: padding.top + 5 + 46 + 14,
                child: TactileButton(
                  label: l10n.devLevelPickerTitle,
                  icon: NestyIcons.shuffle,
                  variant: TactileButtonVariant.secondary,
                  size: TactileButtonSize.compact,
                  expand: false,
                  onPressed: _openPicker,
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
          child: PlayButton(
            level: home.currentLevel,
            tier: home.tier,
            allLevelsDone: home.allLevelsDone,
            onPressed: () => _play(home),
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

/// Home's header (NestyMenus: top 64 on a 59 safe area): the coin pill,
/// the 30 px wordmark and the 46 px settings gear.
class _Header extends StatelessWidget {
  const _Header({required this.coins});

  final int coins;

  /// Kept clear on each side of the wordmark, so a huge balance at 1.3×
  /// text shrinks before it touches it (the wordmark stays centred).
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          // TODO(M3): the "+" that opens the Shop (CoinPill.onAdd).
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CoinPill(coins: coins),
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
                // TODO(M3): Settings (frame 8.1).
                onPressed: null,
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
