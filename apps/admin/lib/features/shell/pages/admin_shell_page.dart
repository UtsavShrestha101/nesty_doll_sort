import 'package:nesty_admin/app/session_cubit/session_cubit.dart';
import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/router/app_router.dart';

/// One navigation-rail entry. The route and its label live together so the
/// rail index and the tab index can never drift apart.
typedef _Section = ({
  PageRouteInfo<Object?> route,
  IconData icon,
  String label,
});

/// The signed-in admin's frame: a navigation rail with one tab per spec §15
/// screen, and the active tab beside it (an `AutoTabsRouter` dashboard, shown
/// as a rail because the admin is a desktop web app).
///
/// TODO(design): narrow-window layout and rail styling (design/admin/*.png).
@RoutePage()
class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    // Spec §15 screen order. The Level editor (#3) is not a tab: it is
    // pushed inside the Levels tab (see `levelsTab` in app_router.dart).
    final sections = <_Section>[
      (
        route: const DashboardRoute(),
        icon: Icons.dashboard_outlined,
        label: l10n.dashboardTitle,
      ),
      (
        route: levelsTab(),
        icon: Icons.view_list_outlined,
        label: l10n.levelsTitle,
      ),
      (
        route: const GeneratorRoute(),
        icon: Icons.auto_awesome_outlined,
        label: l10n.generatorTitle,
      ),
      (
        route: const ChaptersRoute(),
        icon: Icons.menu_book_outlined,
        label: l10n.chaptersTitle,
      ),
      (
        route: const SkinsRoute(),
        icon: Icons.palette_outlined,
        label: l10n.skinsTitle,
      ),
      (
        route: const ThemesRoute(),
        icon: Icons.wallpaper_outlined,
        label: l10n.themesTitle,
      ),
      (
        route: const MuseumItemsRoute(),
        icon: Icons.museum_outlined,
        label: l10n.museumItemsTitle,
      ),
      (
        route: const DailyOverridesRoute(),
        icon: Icons.calendar_month_outlined,
        label: l10n.dailyOverridesTitle,
      ),
      (
        route: const ExportBundleRoute(),
        icon: Icons.download_outlined,
        label: l10n.exportBundleTitle,
      ),
    ];

    return AutoTabsRouter(
      routes: [for (final section in sections) section.route],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
                labelType: NavigationRailLabelType.all,
                // Nine sections outgrow a short browser window.
                scrollable: true,
                trailingAtBottom: true,
                trailing: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    tooltip: l10n.signOut,
                    icon: const Icon(Icons.logout),
                    onPressed: context.read<SessionCubit>().signOut,
                  ),
                ),
                destinations: [
                  for (final section in sections)
                    NavigationRailDestination(
                      icon: Icon(section.icon),
                      label: Text(section.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
