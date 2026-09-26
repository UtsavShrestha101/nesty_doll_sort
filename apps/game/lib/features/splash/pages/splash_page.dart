import 'dart:async';
import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';
import 'package:nesty_render/nesty_render.dart';

/// Spec §10.2 #1, frame 1.1: the Sunny Toy Shop background, the wordmark
/// with its cherry doll, the "DOLL SORT" chip, three cherry dolls idling on
/// a plank (`doll_idle`) and `ui_splash_loader` following the real load
/// (the Lottie files, the skin and shelf dolls, the save and levels, the
/// sounds), captioned "Dusting the shelves…". Then Home.
@RoutePage()
class SplashPage extends StatelessWidget implements AutoRouteWrapper {
  const SplashPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
      RepositoryProvider.value(value: get<ShowcaseDolls>()),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, AsyncValue<SplashState>>(
      listenWhen: (previous, current) => !previous.hasData && current.hasData,
      // replaceAll: Splash must not stay underneath Home on the back stack.
      listener: (context, _) =>
          unawaited(context.router.replaceAll([const HomeRoute()])),
      builder: (context, state) => SplashView(
        progress: state.data?.progress ?? 0,
        error: state.exceptionOrNull,
        onRetry: () => context.read<SplashCubit>().load(
          devicePixelRatio: _pixelRatioOf(context),
        ),
        background: context.read<SkinService>().background,
        library: context.read<FxLibrary>(),
        showcase: context.read<ShowcaseDolls>(),
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
    super.key,
  });

  final double progress;
  final AppException? error;
  final VoidCallback onRetry;
  final ThemeBackground? background;
  final FxLibrary? library;
  final ShowcaseDolls? showcase;

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
          if (error != null)
            SafeArea(
              child: Center(
                child: RetryView(exception: error, onRetry: widget.onRetry),
              ),
            )
          else
            LayoutBuilder(builder: _block),
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
    // The shelf dolls and the wordmark's doll wait for the skin's art (about
    // a second after the splash opens) and fade in, instead of flashing the
    // procedural placeholder first (Q58). With no showcase no art is coming,
    // so the placeholder draws them (rule 3). A showcase whose art fails
    // leaves them hidden here, and Home draws its placeholder dolls.
    final dollsShown = widget.showcase == null || skin != null;
    final fade = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: UiMotionTokens.modalInMs);
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
              Wordmark(dollRenderer: skin?.restRenderer, dollShown: dollsShown),
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
            doll: AnimatedOpacity(
              opacity: dollsShown ? 1 : 0,
              duration: fade,
              curve: UiMotionTokens.curveEaseOut,
              child: LottieDoll(
                id: FxId.dollIdle,
                color: DollColor.red,
                height: d.height,
                images: skin?.images,
                renderer: skin?.restRenderer,
                library: widget.library,
                // doll_idle is 3 s; the design's loops run 2.3–3 s.
                speed: (3 / d.periodS).clamp(0.8, 1.2),
                phaseMs: d.phaseS * 1000,
              ),
            ),
          ),
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
        letterSpacing: 18 * 0.12,
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}
