// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AdminShellPage]
class AdminShellRoute extends PageRouteInfo<void> {
  const AdminShellRoute({List<PageRouteInfo>? children})
    : super(AdminShellRoute.name, initialChildren: children);

  static const String name = 'AdminShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminShellPage();
    },
  );
}

/// generated route for
/// [ChaptersPage]
class ChaptersRoute extends PageRouteInfo<void> {
  const ChaptersRoute({List<PageRouteInfo>? children})
    : super(ChaptersRoute.name, initialChildren: children);

  static const String name = 'ChaptersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChaptersPage();
    },
  );
}

/// generated route for
/// [DailyOverridesPage]
class DailyOverridesRoute extends PageRouteInfo<void> {
  const DailyOverridesRoute({List<PageRouteInfo>? children})
    : super(DailyOverridesRoute.name, initialChildren: children);

  static const String name = 'DailyOverridesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DailyOverridesPage();
    },
  );
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [ExportBundlePage]
class ExportBundleRoute extends PageRouteInfo<void> {
  const ExportBundleRoute({List<PageRouteInfo>? children})
    : super(ExportBundleRoute.name, initialChildren: children);

  static const String name = 'ExportBundleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExportBundlePage();
    },
  );
}

/// generated route for
/// [GeneratorPage]
class GeneratorRoute extends PageRouteInfo<void> {
  const GeneratorRoute({List<PageRouteInfo>? children})
    : super(GeneratorRoute.name, initialChildren: children);

  static const String name = 'GeneratorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GeneratorPage();
    },
  );
}

/// generated route for
/// [LevelEditorPage]
class LevelEditorRoute extends PageRouteInfo<LevelEditorRouteArgs> {
  LevelEditorRoute({
    required String levelId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         LevelEditorRoute.name,
         args: LevelEditorRouteArgs(levelId: levelId, key: key),
         rawPathParams: {'levelId': levelId},
         initialChildren: children,
       );

  static const String name = 'LevelEditorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LevelEditorRouteArgs>(
        orElse: () =>
            LevelEditorRouteArgs(levelId: pathParams.getString('levelId')),
      );
      return LevelEditorPage(levelId: args.levelId, key: args.key);
    },
  );
}

class LevelEditorRouteArgs {
  const LevelEditorRouteArgs({required this.levelId, this.key});

  final String levelId;

  final Key? key;

  @override
  String toString() {
    return 'LevelEditorRouteArgs{levelId: $levelId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LevelEditorRouteArgs) return false;
    return levelId == other.levelId && key == other.key;
  }

  @override
  int get hashCode => levelId.hashCode ^ key.hashCode;
}

/// generated route for
/// [LevelsPage]
class LevelsRoute extends PageRouteInfo<void> {
  const LevelsRoute({List<PageRouteInfo>? children})
    : super(LevelsRoute.name, initialChildren: children);

  static const String name = 'LevelsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LevelsPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const LoginPage());
    },
  );
}

/// generated route for
/// [MuseumItemsPage]
class MuseumItemsRoute extends PageRouteInfo<void> {
  const MuseumItemsRoute({List<PageRouteInfo>? children})
    : super(MuseumItemsRoute.name, initialChildren: children);

  static const String name = 'MuseumItemsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MuseumItemsPage();
    },
  );
}

/// generated route for
/// [NotAuthorizedPage]
class NotAuthorizedRoute extends PageRouteInfo<void> {
  const NotAuthorizedRoute({List<PageRouteInfo>? children})
    : super(NotAuthorizedRoute.name, initialChildren: children);

  static const String name = 'NotAuthorizedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotAuthorizedPage();
    },
  );
}

/// generated route for
/// [SkinsPage]
class SkinsRoute extends PageRouteInfo<void> {
  const SkinsRoute({List<PageRouteInfo>? children})
    : super(SkinsRoute.name, initialChildren: children);

  static const String name = 'SkinsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SkinsPage();
    },
  );
}

/// generated route for
/// [ThemesPage]
class ThemesRoute extends PageRouteInfo<void> {
  const ThemesRoute({List<PageRouteInfo>? children})
    : super(ThemesRoute.name, initialChildren: children);

  static const String name = 'ThemesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ThemesPage();
    },
  );
}
