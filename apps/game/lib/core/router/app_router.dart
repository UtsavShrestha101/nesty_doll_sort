import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/shell/pages/main_shell_page.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

part 'app_router.gr.dart';

/// Every screen of the game (docs/plans/m3-design.md §10.1).
/// `app_router.gr.dart` is generated — never edit it; rerun build_runner
/// after touching a `@RoutePage`.
///
/// Spec §10.1 flow: Splash → Home → Gameplay, and Home → Daily · Museum ·
/// Shop · Settings. Home, Shop and Museum are the tabs of the bottom-nav
/// shell; Settings, Daily, Skin detail and Gameplay are pushed over it,
/// full screen. Pass data through the generated route constructors
/// (`GameplayRoute(request: PlayRequest.campaign(3))`), never through path
/// strings. Win, Out of Moves, Pause, the booster popup, the intro cards,
/// Chapter complete and All Levels Done are overlays of the gameplay page,
/// not routes (auto-route rules); the dev level picker is a sheet on Home.
@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this._contentReady);

  /// Everything after the splash opens only once it has loaded the levels.
  final ContentReadyGuard _contentReady;

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
    AutoRoute(page: SkinDetailRoute.page, guards: [_contentReady]),
    AutoRoute(page: GameplayRoute.page, guards: [_contentReady]),
  ];
}

/// The screens after the splash need the offline content it loads (spec
/// §10.2 #1, §13.4; CLAUDE.md rule 3): the bundled levels.
///
/// - Before the splash has loaded them (a restored or deep-linked route),
///   navigation goes back to the splash, which loads and then opens Home.
/// - A campaign level that doesn't exist (below 1, or past the last
///   bundled one) never opens a board: the bloc would have no level to
///   load. Home and Continue show All Levels Done or Bonus Endless instead
///   (frame 4.9). Bonus and daily requests are generated, so they always
///   pass.
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
        args.request is CampaignPlay &&
        (args.request.number < 1 ||
            _levels.entryAt(args.request.number) == null)) {
      resolver.next(false);
      return;
    }
    resolver.next();
  }
}
