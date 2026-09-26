import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

part 'app_router.gr.dart';

/// Every screen of the game. `app_router.gr.dart` is generated — never edit
/// it; rerun build_runner after touching a `@RoutePage`.
///
/// Spec §10.1 flow: Splash → Home → Gameplay. Pass data through the generated
/// route constructors (`GameplayRoute(levelNumber: 3)`), never through path
/// strings.
@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  // TODO(M3): Win, Pause, Settings, Daily, Museum, Shop (spec §10.2).
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: GameplayRoute.page),
  ];
}
