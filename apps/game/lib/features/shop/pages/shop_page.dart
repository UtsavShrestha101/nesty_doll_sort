import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shell/pages/main_shell_page.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/widgets/shop_closed_card.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/shop/widgets/theme_grid_card.dart';

/// The Shop (spec §7.4, §10.2 #12, frames 7.1–7.8;
/// docs/plans/m3-design.md §10.7): the shell's first tab, opened on
/// [initialTab] (Home's coin pill "+" asks for [ShopTab.coins], the Remove
/// Ads tile for [ShopTab.noAds]).
@RoutePage()
class ShopPage extends StatefulWidget implements AutoRouteWrapper {
  const ShopPage({this.initialTab = ShopTab.skins, super.key});

  final ShopTab initialTab;

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<DatabaseService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
    ],
    child: BlocProvider(
      create: (_) => get<ShopCubit>()..load(initialTab),
      child: this,
    ),
  );

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  /// The shell keeps this tab (and its cubit) alive, so `create` above runs
  /// once. Every `navigate(ShopRoute(initialTab: ...))` (the coin pill "+",
  /// the Remove Ads tile) builds a new [ShopPage] with the tab it asks for,
  /// even the same tab again, while a bottom-nav tap only re-activates this
  /// one: so a new widget here is a new request for [ShopPage.initialTab]
  /// (CORRECTNESS-6).
  @override
  void didUpdateWidget(ShopPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    context.read<ShopCubit>().selectTab(widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, AsyncValue<ShopState>>(
      builder: (context, state) => ShopView(
        state: state,
        onRetry: () => context.read<ShopCubit>().load(widget.initialTab),
        onBack: () =>
            context.tabsRouter.setActiveIndex(MainShellPage.homeIndex),
        onTabChanged: context.read<ShopCubit>().selectTab,
        onSkinTap: (id) =>
            unawaited(context.router.push(SkinDetailRoute(skinId: id))),
        onEquipSkin: context.read<ShopCubit>().equipSkin,
        onBuySkin: context.read<ShopCubit>().buySkin,
        onSetMatchesChapter: context.read<ShopCubit>().setMatchesChapter,
        onUseTheme: context.read<ShopCubit>().useTheme,
        onBuyTheme: context.read<ShopCubit>().buyTheme,
      ),
    );
  }
}

/// Frames 7.1–7.7 for a [state]: `ScreenHeader` + coin pill, the four
/// `NestySegmentedTabs`, then the tab's body.
class ShopView extends StatelessWidget {
  const ShopView({
    required this.state,
    required this.onRetry,
    required this.onBack,
    required this.onTabChanged,
    required this.onSkinTap,
    required this.onEquipSkin,
    required this.onBuySkin,
    required this.onSetMatchesChapter,
    required this.onUseTheme,
    required this.onBuyTheme,
    super.key,
  });

  final AsyncValue<ShopState> state;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final ValueChanged<ShopTab> onTabChanged;
  final ValueChanged<String> onSkinTap;
  final Future<bool> Function(String skinId) onEquipSkin;
  final Future<bool> Function(String skinId) onBuySkin;
  final ValueChanged<bool> onSetMatchesChapter;
  final ValueChanged<String> onUseTheme;
  final Future<bool> Function(String themeId) onBuyTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final data = state.data;
    final error = state.exceptionOrNull;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l10n.shopTitle,
                onBack: onBack,
                coins: data?.coins,
              ),
              const SizedBox(height: 12),
              if (data != null) ...[
                NestySegmentedTabs(
                  labels: [
                    l10n.shopTabCoins,
                    l10n.shopTabSkins,
                    l10n.shopTabThemes,
                    l10n.shopTabNoAds,
                  ],
                  selectedIndex: data.tab.index,
                  onChanged: (i) => onTabChanged(ShopTab.values[i]),
                ),
                const SizedBox(height: 16),
                Expanded(child: _body(context, data)),
              ] else if (error != null)
                Expanded(
                  child: Center(
                    child: RetryView(exception: error, onRetry: onRetry),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ShopState data) => switch (data.tab) {
    ShopTab.coins ||
    ShopTab.noAds => const SingleChildScrollView(child: ShopClosedCard()),
    ShopTab.skins => _SkinsTab(
      state: data,
      onSkinTap: onSkinTap,
      onEquipSkin: onEquipSkin,
      onBuySkin: onBuySkin,
    ),
    ShopTab.themes => _ThemesTab(
      state: data,
      onSetMatchesChapter: onSetMatchesChapter,
      onUseTheme: onUseTheme,
      onBuyTheme: onBuyTheme,
    ),
  };
}

/// Frame 7.3: a 2-column grid of [SkinGridCard]s.
class _SkinsTab extends StatelessWidget {
  const _SkinsTab({
    required this.state,
    required this.onSkinTap,
    required this.onEquipSkin,
    required this.onBuySkin,
  });

  final ShopState state;
  final ValueChanged<String> onSkinTap;
  final Future<bool> Function(String skinId) onEquipSkin;
  final Future<bool> Function(String skinId) onBuySkin;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.only(bottom: 24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: 196,
    ),
    itemCount: state.skins.length,
    itemBuilder: (context, index) {
      final skin = state.skins[index];
      return SkinGridCard(
        skin: skin,
        owned: state.ownsSkin(skin),
        equipped: state.isSkinEquipped(skin),
        onTap: () => onSkinTap(skin.id),
        onEquip: () => onEquipSkin(skin.id),
        onBuy: () => onBuySkin(skin.id),
      );
    },
  );
}

/// Frame 7.7: the "Match each chapter" toggle, then a 2-column grid of
/// [ThemeGridCard]s.
class _ThemesTab extends StatelessWidget {
  const _ThemesTab({
    required this.state,
    required this.onSetMatchesChapter,
    required this.onUseTheme,
    required this.onBuyTheme,
  });

  final ShopState state;
  final ValueChanged<bool> onSetMatchesChapter;
  final ValueChanged<String> onUseTheme;
  final Future<bool> Function(String themeId) onBuyTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        NestySurface(
          style: const SurfaceStyle(
            color: Color(0xE6FFF9EC),
            shadows: [NestyShadow(color: Color(0xFFD8B07A), dy: 3)],
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                NestyIcons.autoAwesome,
                size: 24,
                color: AppColors.textBrown,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.themesMatchTitle,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.themesMatchSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NestyToggle(
                value: state.matchesChapter,
                onChanged: onSetMatchesChapter,
                semanticLabel: l10n.themesMatchTitle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            // 160 fits the card at 1.0x text; 1.3x (spec §16) needs a
            // little more (its Column overflowed by 2 px at 160).
            mainAxisExtent: 172,
          ),
          itemCount: state.themes.length,
          itemBuilder: (context, index) {
            final theme = state.themes[index];
            return ThemeGridCard(
              theme: theme,
              owned: state.ownsTheme(theme),
              inUse: state.isThemeInUse(theme),
              onUse: () => onUseTheme(theme.id),
              onBuy: () => onBuyTheme(theme.id),
            );
          },
        ),
      ],
    );
  }
}
