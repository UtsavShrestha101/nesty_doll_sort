import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The bottom-nav shell (frame 2.1 "Bottom nav: Shop · Home · Museum";
/// docs/plans/m3-design.md §10.1): its tabs are [ShopRoute], [HomeRoute]
/// and [MuseumRoute], Home first shown. Open it with its child named, e.g.
/// `MainShellRoute(children: [HomeRoute()])`, since a tabs router with no
/// pending child shows its first tab.
///
/// The wood [NestyBottomNav] switches tabs through `context.tabsRouter`, and
/// [AutoTabsScaffold]'s [homeIndex] already makes a Shop/Museum back press
/// return to Home instead of leaving the shell (auto_route's
/// `RoutingController` checks it before popping).
///
/// A screen that must cover the whole shell (Settings, Daily, Skin detail,
/// Gameplay — m3-design §10.1 "pushed over the shell") pushes on the root
/// router (`context.router.root.push(...)`), never the nested one a tab's
/// own `BuildContext` resolves to.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  /// The tabs in nav order; Home is [homeIndex].
  static List<PageRouteInfo> get tabs => [
    ShopRoute(),
    const HomeRoute(),
    const MuseumRoute(),
  ];

  /// Back from Shop or Museum returns to Home.
  static const int homeIndex = 1;
  static const int shopIndex = 0;
  static const int museumIndex = 2;

  @override
  Widget build(BuildContext context) => AutoTabsScaffold(
    routes: tabs,
    homeIndex: homeIndex,
    bottomNavigationBuilder: (context, tabsRouter) => NestyBottomNav(
      items: _items(context),
      selectedIndex: tabsRouter.activeIndex,
      onChanged: tabsRouter.setActiveIndex,
    ),
  );

  static List<NestyBottomNavItem> _items(BuildContext context) {
    final l10n = context.localizations;
    return [
      NestyBottomNavItem(
        icon: NestyIcons.storefront,
        label: l10n.navShop,
        shortLabel: l10n.navShopShort,
      ),
      NestyBottomNavItem(
        icon: NestyIcons.home,
        label: l10n.home,
        shortLabel: l10n.navHomeShort,
      ),
      NestyBottomNavItem(
        icon: NestyIcons.museum,
        label: l10n.navMuseum,
        shortLabel: l10n.navMuseumShort,
      ),
    ];
  }
}
