// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [GameplayPage]
class GameplayRoute extends PageRouteInfo<GameplayRouteArgs> {
  GameplayRoute({
    required int levelNumber,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         GameplayRoute.name,
         args: GameplayRouteArgs(levelNumber: levelNumber, key: key),
         initialChildren: children,
       );

  static const String name = 'GameplayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameplayRouteArgs>();
      return GameplayPage(levelNumber: args.levelNumber, key: args.key);
    },
  );
}

class GameplayRouteArgs {
  const GameplayRouteArgs({required this.levelNumber, this.key});

  final int levelNumber;

  final Key? key;

  @override
  String toString() {
    return 'GameplayRouteArgs{levelNumber: $levelNumber, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameplayRouteArgs) return false;
    return levelNumber == other.levelNumber && key == other.key;
  }

  @override
  int get hashCode => levelNumber.hashCode ^ key.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const HomePage());
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SplashPage());
    },
  );
}
