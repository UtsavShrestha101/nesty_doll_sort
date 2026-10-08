import 'dart:async';
import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/router/widget_link.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';
import 'package:nesty_render/nesty_render.dart';

/// Spec §10.2 #1, frame 1.1: the Sunny Toy Shop background, the wordmark
/// with its cherry doll, the "DOLL SORT" chip, three cherry dolls idling on
/// a plank (`doll_idle`) and `ui_splash_loader` following the real load
/// (the Lottie files, the skin and shelf dolls, the save and levels, the
/// sounds), captioned "Dusting the shelves…". Then Home, or Level 1 on a
/// save with no level won (E9, m7-design §13).
@RoutePage()
class SplashPage extends StatelessWidget implements AutoRouteWrapper {
  const SplashPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
      RepositoryProvider.value(value: get<ShowcaseDolls>()),
      RepositoryProvider.value(value: get<DatabaseService>()),
    ],
    child: BlocProvider(
      create: (context) =>
          get<SplashCubit>()..load(devicePixelRatio: _pixelRatioOf(context)),
      child: this,
    ),
  );

  /// The screen's pixel ratio, read without depending on `MediaQuery`: a
  /// provider's `create` and a tap callback may not register a dependency
  /// (the splash loads once; its shelf dolls don't follow a later change).
  static double _pixelRatioOf(BuildContext context) =>
      context
          .getInheritedWidgetOfExactType<MediaQuery>()
          ?.data
          .devicePixelRatio ??
      1;

  /// Where the splash goes once loading ends: Level 1 on a first launch, else
  /// Home, with the Daily over it when the widget's link is waiting and the
  /// Daily is unlocked (plan-local-habits §4). A pending link is always
  /// consumed, and a first launch's Level 1 wins over it.
  static List<PageRouteInfo> _launchStack(SplashState? state) {
    final widgetLink = get<WidgetLink>();
    final wantsDaily = widgetLink.takePending();
    if (state?.opensFirstLevel ?? false) {
      return [
        GameplayRoute(
          request: const PlayRequest.campaign(1),
          entrance: GameplayEntrance.fromSplash,
        ),
      ];
    }
    return [
      const MainShellRoute(children: [HomeRoute()]),
      if (wantsDaily && get<DailyService>().isUnlocked) const DailyRoute(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, AsyncValue<SplashState>>(
      listenWhen: (previous, current) => !previous.hasData && current.hasData,
      // replaceAll: Splash must not stay underneath on the back stack. A save
      // with no level won opens Level 1's tutorial with nothing under it or
      // in between (E9, m7-design §13; spec-prop §10.1); its first win's
      // Continue goes Home. Otherwise Home, the shell's middle tab
      // (m3-design §10.1).
      listener: (context, state) =>
          unawaited(context.router.replaceAll(_launchStack(state.data))),
      builder: (context, state) => SplashView(
        progress: state.data?.progress ?? 0,
        error: state.exceptionOrNull,
        onRetry: () => context.read<SplashCubit>().load(
          devicePixelRatio: _pixelRatioOf(context),
        ),
        background: context.read<SkinService>().background,
        library: context.read<FxLibrary>(),
        showcase: context.read<ShowcaseDolls>(),
        symbols: context.read<DatabaseService>().symbolsMode.dollSymbols,
      ),
    );
  }
}

/// Frame 1.1's layout for a [progress] (0–1), or a retry when the offline
/// content failed to load ([error]).
///
/// The design's block (wordmark at y 250 to the caption at ~725 on 844)
/// keeps its spacing; it moves up or down with the screen height and
/// shrinks only when a screen is shorter than the block itself.
class SplashView extends StatefulWidget {
  const SplashView({
    required this.progress,
    required this.onRetry,
    this.error,
    this.background,
    this.library,
    this.showcase,
    this.symbols = DollSymbols.subtle,
    super.key,
  });

  final double progress;
  final AppException? error;
  final VoidCallback onRetry;
  final ThemeBackground? background;
  final FxLibrary? library;
  final ShowcaseDolls? showcase;

  /// The Color symbols mode of the placeholder dolls. The art bakes in its
  /// own (`ShowcaseDolls`), so this shows only when that can't load.
  final DollSymbols symbols;

  /// The art's dim behind an error card: `color.scrimLight` (frames 12.10,
  /// 12.11; `layout.splash.errors`, m7-6 item 17).
  static const Color errorDim = AppColorTokens.scrimLight;

  /// The top fade (`layout.splash.topFade`), for tests.
  @visibleForTesting
  static const Key topFadeKey = Key('splash-top-fade');

  /// Design y 240 → 750.
  static const double blockHeight = 510;
  static const double _blockTop = 240;

  /// NestyMenus `trio`: cherry dolls on the plank at x 128/195/262, heights
  /// 76/108/58, loops of 2.6/3/2.3 s starting .4/0/.8 s in.
  static const dolls = [
    (dx: -67.0, height: 76.0, periodS: 2.6, phaseS: 0.4),
    (dx: 0.0, height: 108.0, periodS: 3.0, phaseS: 0.0),
    (dx: 67.0, height: 58.0, periodS: 2.3, phaseS: 0.8),
  ];

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final LottieFxController _loader = LottieFxController(FxId.uiSplashLoader);

  /// The top fade's gradient over its 240 dp box (built once).
  static final LinearGradient _topFade = SplashTokens.topFadeFill.resolve(
    SplashTokens.topFadeHeight,
  );

  @override
  void initState() {
    super.initState();
    _seek();
  }

  @override
  void didUpdateWidget(SplashView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) _seek();
  }

  // The loader's frame is the progress in percent (LOTTIE.md).
  void _seek() => _loader.seek(100 * widget.progress.clamp(0.0, 1.0));

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    return Scaffold(
      backgroundColor: ChapterTheme.ch01.fallbackColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ThemeBackgroundView(
            theme: ChapterTheme.ch01,
            background: widget.background,
          ),
          // NestyMenus: `radial-gradient(ellipse 80% 55% at 50% 40%, …)`.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.8,
                colors: [
                  Color(0xBFFFFAEB),
                  Color(0x33FFF0D2),
                  Color(0x00000000),
                ],
                stops: [0, 0.7, 1],
              ),
            ),
          ),
          // layout.splash.topFade (m7-5 item 11): solid cream down to 120 dp,
          // clear at 240, over the theme art (its chapter-1 arch and halo
          // are not meant to show) and under the logo and the status bar.
          Positioned(
            key: SplashView.topFadeKey,
            left: 0,
            right: 0,
            top: 0,
            height: SplashTokens.topFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: _topFade),
              ),
            ),
          ),
          LayoutBuilder(builder: _block),
          // Frames 12.10, 12.11: the art dims, the loader and caption hide,
          // and one card says what to do (top 470, left/right 28).
          if (error != null) ...[
            const ColoredBox(color: SplashView.errorDim),
            // A screen too short for that lifts the card, and a taller one
            // scrolls, rather than shrinking its button under 48 dp.
            SafeArea(
              child: CustomSingleChildLayout(
                delegate: const _CardTop(top: 470 - 59, side: 28),
                child: SingleChildScrollView(
                  child: ErrorCard(
                    icon: error.errorIcon,
                    title: error.errorTitle(context.localizations),
                    body: error.errorBody(context.localizations),
                    primaryLabel: context.localizations.retry,
                    onPrimary: widget.onRetry,
                    compact: true,
                    namesRoute: true,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _block(BuildContext context, BoxConstraints constraints) {
    final height = constraints.maxHeight;
    final width = constraints.maxWidth;
    const block = SplashView.blockHeight;
    // At 844 the block starts at y 240, as designed.
    final top = math.max(
      0.0,
      (height - block) * SplashView._blockTop / (844 - block),
    );
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Align(
        alignment: Alignment.topCenter,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: block,
            child: ValueListenableBuilder<LevelSkin?>(
              valueListenable: widget.showcase?.current ?? _noSkin,
              builder: (context, skin, _) => _content(context, width, skin),
            ),
          ),
        ),
      ),
    );
  }

  static final ValueNotifier<LevelSkin?> _noSkin = ValueNotifier(null);

  Widget _content(BuildContext context, double width, LevelSkin? skin) {
    final l10n = context.localizations;
    final center = width / 2;
    // Design y − 240.
    const plankTop = 566 - SplashView._blockTop;
    const base = 578 - SplashView._blockTop;
    const loaderTop = 690 - SplashView._blockTop;
    final loaderWidth = math.max(0.0, width - 2 * 56);
    // layout.fallbackDoll.splash (m7-6 item 20): the plank shows no dolls
    // until the skin is decoded, then its three cherry dolls fade in over
    // 200 ms. The placeholder draws only when the load is over and no art
    // came (rule 3), never as a placeholder that swaps. The wordmark's doll
    // keeps its own crossfade.
    final dollsReady = skin != null || widget.progress >= 1;
    final fade = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: FallbackDollTokens.splashFadeInMs);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          // NestyMenus: the 88 px line box at y 250 and the chip 18 below
          // it. The Wordmark's box adds its outline above the line and its
          // drop edge below, so both are taken off here.
          top: 250 - SplashView._blockTop - WordmarkSize.large.outline,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wordmark(dollRenderer: skin?.restRenderer),
              SizedBox(height: 18 - WordmarkSize.large.drop),
              const _DollSortChip(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: plankTop,
          child: PlankStrip(sprites: skin?.sprites),
        ),
        for (final d in SplashView.dolls)
          LottieDoll.positioned(
            centerX: center + d.dx,
            baseY: base,
            doll: AnimatedSwitcher(
              duration: fade,
              switchInCurve: UiMotionTokens.curveEaseOut,
              switchOutCurve: UiMotionTokens.curveEaseOut,
              child: !dollsReady
                  ? const SizedBox.shrink()
                  : LottieDoll(
                      key: const ValueKey('splash-doll'),
                      id: FxId.dollIdle,
                      color: DollColor.red,
                      height: d.height,
                      images: skin?.images,
                      renderer: skin?.restRenderer,
                      symbols: widget.symbols,
                      library: widget.library,
                      // doll_idle is 3 s; the design's loops run 2.3–3 s.
                      speed: (3 / d.periodS).clamp(0.8, 1.2),
                      phaseMs: d.phaseS * 1000,
                    ),
            ),
          ),
        if (widget.error == null)
          Positioned(
            left: (width - loaderWidth) / 2,
            width: loaderWidth,
            top: loaderTop,
            child: Semantics(
              label: l10n.splashLoading,
              value: l10n.progressPercent(widget.progress.clamp(0.0, 1.0)),
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 22,
                  child: LottieFxView(
                    id: FxId.uiSplashLoader,
                    controller: _loader,
                    library: widget.library,
                    fallback: NestyProgressBar(
                      value: widget.progress,
                      striped: true,
                      tone: NestyProgressTone.orange,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget.error == null)
          Positioned(
            left: 16,
            right: 16,
            top: loaderTop + 22 + 12,
            child: Text(
              l10n.splashCaption,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 15,
                height: 1,
                color: AppColors.textBrown,
              ),
            ),
          ),
      ],
    );
  }
}

/// The "DOLL SORT" chip under the wordmark (NestyMenus: the primary
/// gradient, a 4 px `#C4631E` edge, 18/700 white, +0.12 em).
class _DollSortChip extends StatelessWidget {
  const _DollSortChip();

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.primary,
    shadows: [
      NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.primaryEdge, dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Text(
      context.localizations.splashDollSort,
      textScaler: TextScaler.noScaling,
      style: AppTextStyleTokens.cardTitle.copyWith(
        fontSize: 18,
        height: 1,
        letterSpacing: context.script.tracking(18 * 0.12),
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}

/// Puts the error card [top] below the safe area's top and [side] in from
/// each edge (frames 12.10, 12.11: y 470 of the design), lifting it when the
/// screen is too short for that so its bottom keeps a margin; a card taller
/// than the screen scrolls (`SingleChildScrollView` inside).
class _CardTop extends SingleChildLayoutDelegate {
  const _CardTop({required this.top, required this.side});

  final double top;
  final double side;

  static const double _margin = 16;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: math.max(0, constraints.maxWidth - 2 * side),
        maxWidth: math.max(0, constraints.maxWidth - 2 * side),
        maxHeight: math.max(0, constraints.maxHeight - 2 * _margin),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    side,
    math
        .max(_margin, math.min(top, size.height - childSize.height - _margin))
        .toDouble(),
  );

  @override
  bool shouldRelayout(_CardTop oldDelegate) =>
      oldDelegate.top != top || oldDelegate.side != side;
}
