import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/widget_link.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/shell/pages/main_shell_page.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

part 'app_router.gr.dart';

/// Every screen of the game (docs/plans/m3-design.md §10.1,
/// docs/plans/m7-design.md §2, §15, P2.8). `app_router.gr.dart` is generated —
/// never edit it; rerun build_runner after touching a `@RoutePage`.
///
/// Spec §10.1 flow (spec-prop §10.1): Splash → Level 1 on a first launch
/// or Home, then Gameplay, and Home → Daily · Museum · Shop · Settings ·
/// vs Computer · Chapters · Records. Home, Shop and Museum are the tabs of
/// the bottom-nav shell; Settings, Daily, Chapters, Records, rival select,
/// Skin detail and Gameplay are pushed over it, full screen. A race is the
/// gameplay page with `PlayRequest.race` (m7-design P2.8), never a page of
/// its own. Pass data through the generated route constructors
/// (`GameplayRoute(request: PlayRequest.campaign(3))`), never through path
/// strings. Win, Out of Moves, Pause, the booster popup, the intro cards,
/// Chapter complete and All Levels Done are overlays of the gameplay page,
/// not routes (auto-route rules); the dev level picker is a sheet on Home.
@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this._contentReady, this._widgetLink);

  /// Everything after the splash opens only once it has loaded the levels.
  final ContentReadyGuard _contentReady;

  final WidgetLink _widgetLink;

  /// The `deepLinkBuilder` `App` passes to `config` (stage 4 contract §4):
  /// the home-screen widget's `<scheme>://daily` is kept as a pending launch
  /// target through the splash on a cold start, and opens the Daily over
  /// Home on a warm one. Every other link is handled as auto_route does by
  /// default.
  FutureOr<DeepLink> deepLinkBuilder(PlatformDeepLink link) {
    return switch (_widgetLink.resolve(link.uri, initial: link.initial)) {
      WidgetLinkAction.passThrough => link,
      // The splash is the initial route; it loads, then reads the target.
      WidgetLinkAction.viaSplash => DeepLink.defaultPath,
      WidgetLinkAction.openDaily => DeepLink.single(
        const DailyRoute(),
        navigate: false,
      ),
      WidgetLinkAction.stay => DeepLink.none,
    };
  }

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(
      page: MainShellRoute.page,
      guards: [_contentReady],
      children: [
        AutoRoute(page: ShopRoute.page),
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: MuseumRoute.page),
      ],
    ),
    AutoRoute(page: SettingsRoute.page, guards: [_contentReady]),
    AutoRoute(page: DailyRoute.page, guards: [_contentReady]),
    AutoRoute(page: ChaptersRoute.page, guards: [_contentReady]),
    AutoRoute(page: RecordsRoute.page, guards: [_contentReady]),
    AutoRoute(page: RivalSelectRoute.page, guards: [_contentReady]),
    AutoRoute(page: SkinDetailRoute.page, guards: [_contentReady]),
    // The first launch fades into Level 1 (frame 10.8); every other entry
    // keeps the platform transition, still 300 ms (phase 4 §3.13).
    CustomRoute<void>(
      page: GameplayRoute.page,
      guards: [_contentReady],
      transitionsBuilder: GameplayTransitions.build,
      duration: GameplayTransitions.duration,
      reverseDuration: GameplayTransitions.reverseDuration,
    ),
  ];
}

/// The screens after the splash need the offline content it loads (spec
/// §10.2 #1, §13.4; CLAUDE.md rule 3): the bundled levels.
///
/// - Before the splash has loaded them (a restored or deep-linked route),
///   navigation goes back to the splash, which loads and then opens Home.
/// - A campaign level or a replay that doesn't exist (below 1, or past
///   the last bundled one) never opens a board: the bloc would have no
///   level to load. Home and Continue show All Levels Done or Bonus Endless
///   instead (frame 4.9); Chapters only offers levels it has. Bonus,
///   daily and race requests are generated, so they always pass (a race
///   the save refuses resolves to nothing, and the page's failure card
///   leads back, m7-design P2.4).
@lazySingleton
class ContentReadyGuard extends AutoRouteGuard {
  ContentReadyGuard(this._levels);

  final LevelRepository _levels;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_levels.levelCount <= 0) {
      resolver.next(false);
      unawaited(router.replaceAll([const SplashRoute()]));
      return;
    }
    final args = resolver.route.args;
    if (args is GameplayRouteArgs &&
        args.request.isBundled &&
        (args.request.number < 1 ||
            _levels.entryAt(args.request.number) == null)) {
      resolver.next(false);
      return;
    }
    resolver.next();
  }
}
