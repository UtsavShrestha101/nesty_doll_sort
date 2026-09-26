import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/router/auth_guard.dart';
import 'package:nesty_admin/features/chapters/pages/chapters_page.dart';
import 'package:nesty_admin/features/daily_overrides/pages/daily_overrides_page.dart';
import 'package:nesty_admin/features/dashboard/pages/dashboard_page.dart';
import 'package:nesty_admin/features/export_bundle/pages/export_bundle_page.dart';
import 'package:nesty_admin/features/generator/pages/generator_page.dart';
import 'package:nesty_admin/features/levels/pages/level_editor_page.dart';
import 'package:nesty_admin/features/levels/pages/levels_page.dart';
import 'package:nesty_admin/features/login/pages/login_page.dart';
import 'package:nesty_admin/features/museum_items/pages/museum_items_page.dart';
import 'package:nesty_admin/features/not_authorized/pages/not_authorized_page.dart';
import 'package:nesty_admin/features/shell/pages/admin_shell_page.dart';
import 'package:nesty_admin/features/skins/pages/skins_page.dart';
import 'package:nesty_admin/features/themes/pages/themes_page.dart';

part 'app_router.gr.dart';

/// The Levels section's own stack: the list, with the editor pushed on top
/// (spec §15 #2, #3), so going back from the editor returns to the list.
const levelsTab = EmptyShellRoute('LevelsTab');

/// Every screen of the admin panel. `app_router.gr.dart` is generated — never
/// edit it; rerun build_runner after touching a `@RoutePage`.
///
/// Paths are explicit because this is a web app: they are the URLs people
/// bookmark and share (`/#/levels/L0024`). Pass data through the generated
/// route constructors (`LevelEditorRoute(levelId: 'L0024')`), never by
/// building path strings.
@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this._authGuard);

  final AuthGuard _authGuard;

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: '/login', guards: [_authGuard]),
    AutoRoute(
      page: NotAuthorizedRoute.page,
      path: '/not-authorized',
      guards: [_authGuard],
    ),
    // The authenticated shell: navigation rail + one tab per spec §15 screen.
    // Its children are covered by the shell's guard.
    AutoRoute(
      page: AdminShellRoute.page,
      path: '/',
      initial: true,
      guards: [_authGuard],
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard', initial: true),
        AutoRoute(
          page: levelsTab.page,
          path: 'levels',
          children: [
            AutoRoute(page: LevelsRoute.page, path: '', initial: true),
            AutoRoute(page: LevelEditorRoute.page, path: ':levelId'),
          ],
        ),
        AutoRoute(page: GeneratorRoute.page, path: 'generator'),
        AutoRoute(page: ChaptersRoute.page, path: 'chapters'),
        AutoRoute(page: SkinsRoute.page, path: 'skins'),
        AutoRoute(page: ThemesRoute.page, path: 'themes'),
        AutoRoute(page: MuseumItemsRoute.page, path: 'museum-items'),
        AutoRoute(page: DailyOverridesRoute.page, path: 'daily-overrides'),
        AutoRoute(page: ExportBundleRoute.page, path: 'export-bundle'),
      ],
    ),
    // Typos and stale bookmarks go to the root, where AuthGuard picks Login,
    // Not authorized or the Dashboard.
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
