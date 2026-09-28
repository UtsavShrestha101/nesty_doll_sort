// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DailyPage]
class DailyRoute extends PageRouteInfo<void> {
  const DailyRoute({List<PageRouteInfo>? children})
    : super(DailyRoute.name, initialChildren: children);

  static const String name = 'DailyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const DailyPage());
    },
  );
}

/// generated route for
/// [GameplayPage]
class GameplayRoute extends PageRouteInfo<GameplayRouteArgs> {
  GameplayRoute({
    required PlayRequest request,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         GameplayRoute.name,
         args: GameplayRouteArgs(request: request, key: key),
         initialChildren: children,
       );

  static const String name = 'GameplayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameplayRouteArgs>();
      return WrappedRoute(
        child: GameplayPage(request: args.request, key: args.key),
      );
    },
  );
}

class GameplayRouteArgs {
  const GameplayRouteArgs({required this.request, this.key});

  final PlayRequest request;

  final Key? key;

  @override
  String toString() {
    return 'GameplayRouteArgs{request: $request, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameplayRouteArgs) return false;
    return request == other.request && key == other.key;
  }

  @override
  int get hashCode => request.hashCode ^ key.hashCode;
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
/// [MainShellPage]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellPage();
    },
  );
}

/// generated route for
/// [MuseumPage]
class MuseumRoute extends PageRouteInfo<void> {
  const MuseumRoute({List<PageRouteInfo>? children})
    : super(MuseumRoute.name, initialChildren: children);

  static const String name = 'MuseumRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const MuseumPage());
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SettingsPage());
    },
  );
}

/// generated route for
/// [ShopPage]
class ShopRoute extends PageRouteInfo<ShopRouteArgs> {
  ShopRoute({
    ShopTab initialTab = ShopTab.skins,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ShopRoute.name,
         args: ShopRouteArgs(initialTab: initialTab, key: key),
         initialChildren: children,
       );

  static const String name = 'ShopRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShopRouteArgs>(
        orElse: () => const ShopRouteArgs(),
      );
      return WrappedRoute(
        child: ShopPage(initialTab: args.initialTab, key: args.key),
      );
    },
  );
}

class ShopRouteArgs {
  const ShopRouteArgs({this.initialTab = ShopTab.skins, this.key});

  final ShopTab initialTab;

  final Key? key;

  @override
  String toString() {
    return 'ShopRouteArgs{initialTab: $initialTab, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShopRouteArgs) return false;
    return initialTab == other.initialTab && key == other.key;
  }

  @override
  int get hashCode => initialTab.hashCode ^ key.hashCode;
}

/// generated route for
/// [SkinDetailPage]
class SkinDetailRoute extends PageRouteInfo<SkinDetailRouteArgs> {
  SkinDetailRoute({
    required String skinId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         SkinDetailRoute.name,
         args: SkinDetailRouteArgs(skinId: skinId, key: key),
         initialChildren: children,
       );

  static const String name = 'SkinDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SkinDetailRouteArgs>();
      return WrappedRoute(
        child: SkinDetailPage(skinId: args.skinId, key: args.key),
      );
    },
  );
}

class SkinDetailRouteArgs {
  const SkinDetailRouteArgs({required this.skinId, this.key});

  final String skinId;

  final Key? key;

  @override
  String toString() {
    return 'SkinDetailRouteArgs{skinId: $skinId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SkinDetailRouteArgs) return false;
    return skinId == other.skinId && key == other.key;
  }

  @override
  int get hashCode => skinId.hashCode ^ key.hashCode;
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
