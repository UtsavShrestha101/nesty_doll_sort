import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

part 'app_router.gr.dart';

/// Every screen of the game. `app_router.gr.dart` is generated — never edit
/// it; rerun build_runner after touching a `@RoutePage`.
///
/// Spec §10.1 flow: Splash → Home → Gameplay. Pass data through the generated
/// route constructors (`GameplayRoute(levelNumber: 3)`), never through path
/// strings. Win, Out of Moves, Pause and All Levels Done are overlays of the
/// gameplay page, not routes (auto-route rules); the dev level picker is a
/// sheet on Home.
@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this._contentReady);

  /// Home and Gameplay open only once the splash has loaded the levels.
  final ContentReadyGuard _contentReady;

  @override
  RouteType get defaultRouteType => const RouteType.material();

  // TODO(M3): Settings, Daily, Museum, Shop (spec §10.2).
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page, guards: [_contentReady]),
    AutoRoute(page: GameplayRoute.page, guards: [_contentReady]),
  ];
}

/// Home and Gameplay need the offline content the splash loads (spec
/// §10.2 #1, §13.4; CLAUDE.md rule 3): the bundled levels.
///
/// - Before the splash has loaded them (a restored or deep-linked route),
///   navigation goes back to the splash, which loads and then opens Home.
/// - A level that doesn't exist (past the last bundled one) never opens a
///   board: the bloc would have no level to load. Home shows All Levels
///   Done instead (frame 4.9).
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
        (args.levelNumber < 1 || _levels.entryAt(args.levelNumber) == null)) {
      resolver.next(false);
      return;
    }
    resolver.next();
  }
}
