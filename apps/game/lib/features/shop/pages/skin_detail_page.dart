import 'dart:async';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_colors.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart';

/// A skin's detail (frame 7.4; docs/plans/m3-design.md §10.7): all 11
/// colors on two shelves, the size lineup, the name and description, then
/// Buy + price chip / Equip / Equipped and "You have N coins". Pushed over
/// the shell (no bottom nav).
@RoutePage()
class SkinDetailPage extends StatelessWidget implements AutoRouteWrapper {
  const SkinDetailPage({required this.skinId, super.key});

  /// A `CatalogRepository` skin id, such as `ocean`.
  final String skinId;

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<DatabaseService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
    ],
    child: BlocProvider(
      create: (_) => get<SkinDetailCubit>()..load(skinId),
      child: this,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkinDetailCubit, AsyncValue<SkinDetailState>>(
      builder: (context, state) => SkinDetailView(
        state: state,
        onRetry: () => context.read<SkinDetailCubit>().load(skinId),
        onBack: () => context.router.maybePop(),
        onBuy: context.read<SkinDetailCubit>().buy,
        // Pops this page and lands on the Shop tab's Coins (ShopPage
        // selects a navigated initialTab even when it was already open).
        onNeedCoins: () => unawaited(
          context.router.root.navigate(
            MainShellRoute(children: [ShopRoute(initialTab: ShopTab.coins)]),
          ),
        ),
        onEquip: context.read<SkinDetailCubit>().equip,
      ),
    );
  }
}

/// Frame 7.4 for a [state].
class SkinDetailView extends StatefulWidget {
  const SkinDetailView({
    required this.state,
    required this.onRetry,
    required this.onBack,
    required this.onBuy,
    required this.onNeedCoins,
    required this.onEquip,
    super.key,
  });

  final AsyncValue<SkinDetailState> state;
  final VoidCallback onRetry;

  /// The header's back arrow (NestyShop's header is `arrow_back` on every
  /// screen, the skin detail included).
  final VoidCallback onBack;

  /// Awaited: [PurchaseOutcome.bought] shows the twinkle,
  /// [PurchaseOutcome.needsCoins] calls [onNeedCoins].
  final Future<PurchaseOutcome> Function() onBuy;

  /// Opens the Shop's Coins tab: a Buy the balance can't cover (the price
  /// is orange whatever the balance, frames 7.3/7.4/7.7; FIDELITY-7).
  final VoidCallback onNeedCoins;
  final Future<bool> Function() onEquip;

  /// Frame 7.4's six-then-five shelves: `DollColor.values` in order, all
  /// 11 colors including gold.
  static final List<DollColor> lineA = DollColor.values.sublist(0, 6);
  static final List<DollColor> lineB = DollColor.values.sublist(6);

  /// The size lineup: one color at four heights.
  static const List<double> sizeHeights = [34, 44, 54, 64];

  /// Frame 7.4's colour panel: 292 tall, a 22 px shelf plank at 118 and
  /// 252, each shelf's dolls (76 tall, gap 4) standing 6 px into it.
  static const double panelHeight = 292;
  static const double plankHeight = 22;
  static const List<double> plankTops = [118, 252];
  static const double shelfDollHeight = 76;
  static const double _shelfBoxHeight = 88;
  static const double _shelfDollGap = 4;
  static const List<double> _shelfTops = [36, 170];

  @override
  State<SkinDetailView> createState() => _SkinDetailViewState();
}

class _SkinDetailViewState extends State<SkinDetailView> {
  LevelSkin? _art;
  bool _preparing = false;
  String? _preparedFor;
  bool _buying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepare();
  }

  @override
  void didUpdateWidget(SkinDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prepare();
  }

  void _prepare() {
    final skinId = widget.state.data?.skin.id;
    if (skinId == null || skinId == _preparedFor || _preparing) return;
    _preparing = true;
    final skins = context.read<SkinService>();
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    unawaited(
      skins
          .prepareShowcase(
            colors: DollColor.values,
            devicePixelRatio: dpr,
            symbols: symbols,
            skinId: skinId,
          )
          .then((art) {
            _preparing = false;
            if (!mounted) {
              art?.dispose();
              return;
            }
            final previous = _art;
            setState(() {
              _art = art;
              _preparedFor = skinId;
            });
            previous?.dispose();
          }),
    );
  }

  Future<void> _buy() async {
    if (_buying) return;
    setState(() => _buying = true);
    final outcome = await widget.onBuy();
    if (!mounted) return;
    setState(() => _buying = false);
    switch (outcome) {
      case PurchaseOutcome.bought:
        PurchaseTwinkleBurst.showOver(context);
      case PurchaseOutcome.needsCoins:
        widget.onNeedCoins();
      case PurchaseOutcome.unavailable:
        break;
    }
  }

  Future<void> _equip() async {
    await widget.onEquip();
  }

  @override
  void dispose() {
    _art?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final data = widget.state.data;
    final error = widget.state.exceptionOrNull;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l10n.skinDetailTitle,
                onBack: widget.onBack,
                coins: data?.coins,
              ),
              const SizedBox(height: 12),
              if (data != null)
                Expanded(child: _content(context, data))
              else if (error != null)
                Expanded(
                  child: Center(
                    child: RetryView(exception: error, onRetry: widget.onRetry),
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

  Widget _content(BuildContext context, SkinDetailState data) {
    final l10n = context.localizations;
    final library = context.read<FxLibrary>();
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
    final description = l10n.skinDescription(data.skin.id);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ColourPanel(
            skinId: data.skin.id,
            caption: l10n.skinDetailColors,
            art: _art,
            // The spinner until this skin's art arrives (never a flash of
            // the placeholder dolls; those draw only when it can't load).
            loading: _preparedFor != data.skin.id,
            symbols: symbols,
            library: library,
          ),
          const SizedBox(height: 12),
          NestySurface(
            style: const SurfaceStyle(
              color: Color(0xE6FFF9EC),
              shadows: [NestyShadow(color: Color(0xFFD8B07A), dy: 3)],
            ),
            radius: const BorderRadius.all(Radius.circular(22)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  height: 64,
                  width: 4 * 30 + 3 * 4,
                  child: _preparedFor != data.skin.id
                      ? const Center(child: FxSpinner(size: 28))
                      : SkinDollRow(
                          // Frame 7.4: the skin's first card colour (Ocean's
                          // lagoon), as on its Skins-tab card.
                          colors: List.filled(
                            SkinDetailView.sizeHeights.length,
                            data.skin.previewColors.firstOrNull ??
                                SkinDetailView.lineA.first,
                          ),
                          heights: SkinDetailView.sizeHeights,
                          skin: _art,
                          symbols: symbols,
                          library: library,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.skinDetailSizes,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.skinName(data.skin.id),
            style: AppTextStyles.display.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          _button(context, data),
          const SizedBox(height: 12),
          Text(
            l10n.balanceLine(data.coins),
            style: AppTextStyles.caption.copyWith(color: AppColors.textBrown),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, SkinDetailState data) {
    final l10n = context.localizations;
    if (data.equipped) {
      return TactileButton(
        label: l10n.shopEquipped,
        onPressed: null,
        variant: TactileButtonVariant.success,
        icon: NestyIcons.checkCircle,
      );
    }
    if (data.owned) {
      return TactileButton(
        label: l10n.shopEquip,
        onPressed: _buying ? null : _equip,
        variant: TactileButtonVariant.secondary,
      );
    }
    return _BuyButton(
      price: data.skin.priceCoins,
      onPressed: _buying ? null : _buy,
    );
  }
}

/// Frame 7.4's colour panel: the skin's own card colour (as on its Skins
/// card), two 22 px shelf planks, all 11 dolls on them (6 + 5), and the
/// caption pill.
class _ColourPanel extends StatelessWidget {
  const _ColourPanel({
    required this.skinId,
    required this.caption,
    required this.art,
    required this.loading,
    required this.symbols,
    required this.library,
  });

  final String skinId;
  final String caption;
  final LevelSkin? art;
  final bool loading;
  final DollSymbols symbols;
  final FxLibrary library;

  static const _radius = BorderRadius.all(Radius.circular(26));

  @override
  Widget build(BuildContext context) {
    return NestySurface(
      style: SurfaceStyle(
        gradient: SkinShopColors.cardBackground(skinId),
        shadows: const [
          NestyShadow(
            color: SkinShopColors.detailPanelHighlight,
            inset: true,
            dy: 2,
          ),
          NestyShadow(color: SkinShopColors.detailPanelEdge, dy: 6),
        ],
      ),
      radius: _radius,
      height: SkinDetailView.panelHeight,
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          children: [
            for (final top in SkinDetailView.plankTops)
              Positioned(
                left: 0,
                right: 0,
                top: top,
                child: const PlankStrip(height: SkinDetailView.plankHeight),
              ),
            if (loading)
              const Center(child: FxSpinner())
            else ...[
              _shelf(SkinDetailView._shelfTops[0], SkinDetailView.lineA),
              _shelf(SkinDetailView._shelfTops[1], SkinDetailView.lineB),
            ],
            Positioned(
              left: 12,
              top: 12,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: SkinShopColors.detailCaptionFace,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    caption,
                    style: AppTextStyleTokens.button.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SkinShopColors.detailCaptionText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One shelf of [colors], bottom-aligned in the frame's 88 px box at
  /// [top]; shrinks to fit a narrow panel rather than clip.
  Widget _shelf(double top, List<DollColor> colors) {
    const height = SkinDetailView.shelfDollHeight;
    final width =
        colors.length * height * DollArt.width / DollArt.height +
        (colors.length - 1) * SkinDetailView._shelfDollGap;
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      height: SkinDetailView._shelfBoxHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: width,
          height: SkinDetailView._shelfBoxHeight,
          child: SkinDollRow(
            colors: colors,
            heights: List.filled(colors.length, height),
            skin: art,
            symbols: symbols,
            library: library,
          ),
        ),
      ),
    );
  }
}

/// Frame 7.4's Buy button: "Buy" and a translucent coin chip with the
/// price trailing it (the Daily Play button's layout, frame 5.1), read as
/// one label. [TactileButton] has no trailing slot, so this composes
/// [TactileSurface] directly.
class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.price, required this.onPressed});

  final int price;
  final VoidCallback? onPressed;

  static const _variant = TactileButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final enabled = onPressed != null;
    final foreground = enabled ? _variant.foreground : AppColors.disabledText;
    final textShadow = enabled ? _variant.textShadow : null;
    return Padding(
      // left/right 24 in the frame; the page already pads 16.
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TactileSurface(
        style: _variant.surface(6),
        disabledStyle: SurfaceStyles.disabled,
        radius: const BorderRadius.all(Radius.circular(22)),
        onPressed: onPressed,
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        semanticLabel: l10n.shopBuySemantics(price),
        excludeChildSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.shopBuy,
                style: AppTextStyleTokens.button.copyWith(
                  fontSize: 22,
                  color: foreground,
                  shadows: textShadow == null
                      ? null
                      : [Shadow(color: textShadow, offset: const Offset(0, 2))],
                ),
                maxLines: 1,
                softWrap: false,
              ),
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: SkinShopColors.buyChipFace,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 10, 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CoinIcon(size: 22, disabled: !enabled),
                      const SizedBox(width: 6),
                      NestyNumberText(
                        price,
                        style: AppTextStyleTokens.number.copyWith(
                          fontSize: 19,
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
