import 'dart:async';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/shop_look.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_game/features/shop/widgets/tag_pop.dart';
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
  /// [PurchaseOutcome.needsCoins] opens `NotEnoughCoinsDialog`, whose "Go to
  /// Shop" calls [onNeedCoins].
  final Future<PurchaseOutcome> Function() onBuy;

  /// Opens the Shop's Coins tab, from `NotEnoughCoinsDialog`'s "Go to Shop"
  /// (D112: a Buy the balance can't cover, frames 7.3/7.4/7.7, shows that
  /// dialog first instead of jumping straight there).
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

  /// A purchase tapped here is in flight, and whether its celebration has
  /// played; the button built as it lands is the swap's and pops
  /// (`motion.purchaseItem`, m7-4 4.11).
  bool _buyPending = false;
  bool _celebrated = false;
  bool _popButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepare();
  }

  @override
  void didUpdateWidget(SkinDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prepare();
    final wasOwned = oldWidget.state.data?.owned ?? false;
    if (_buyPending && !wasOwned && (widget.state.data?.owned ?? false)) {
      _swapped();
    }
  }

  void _swapped() {
    if (_celebrated) return;
    _celebrated = true;
    _popButton = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _popButton = false);
    PurchaseTwinkleBurst.celebrate(context);
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

  Future<void> _buy(SkinDetailState data) async {
    if (_buying) return;
    setState(() => _buying = true);
    _buyPending = true;
    _celebrated = false;
    final outcome = await widget.onBuy();
    _buyPending = false;
    if (!mounted) return;
    setState(() => _buying = false);
    switch (outcome) {
      case PurchaseOutcome.bought:
        _swapped();
      case PurchaseOutcome.needsCoins:
        unawaited(
          NotEnoughCoinsDialog.show(
            context,
            price: data.skin.priceCoins,
            balance: data.coins,
            itemName: context.localizations.skinNameOf(data.skin.id),
            onGoToShop: widget.onNeedCoins,
          ),
        );
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
      body: CreamPage(
        child: SafeArea(
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
                      child: RetryView(
                        exception: error,
                        onRetry: widget.onRetry,
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SkinDetailState data) {
    final l10n = context.localizations;
    final library = context.read<FxLibrary>();
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
    final description = l10n.skinDescriptionOf(data.skin.id);
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
          const SizedBox(height: 16),
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
                      color: AppColorTokens.textBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),
          Text(
            l10n.skinNameOf(data.skin.id),
            style: AppTextStyles.display.copyWith(
              fontSize: 30,
              height: 1,
              color: AppColorTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              // text-wrap: pretty (NestyShop dDesc): no lone last word.
              child: Text(
                bindLastWord(description),
                style: context.scriptStyle(
                  ShopTypeTokens.description,
                  role: ScriptTextRole.body,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 43),
          _button(context, data),
          const SizedBox(height: 20),
          Text(
            l10n.balanceLine(data.coins),
            style: ShopTypeTokens.balance,
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
      return TagPop(
        key: const ValueKey('button-equipped'),
        animate: _popButton,
        child: TactileButton(
          label: l10n.shopEquipped,
          onPressed: null,
          variant: TactileButtonVariant.success,
          icon: NestyIcons.checkCircle,
        ),
      );
    }
    if (data.owned) {
      return TagPop(
        key: const ValueKey('button-owned'),
        animate: _popButton,
        child: TactileButton(
          label: l10n.shopEquip,
          onPressed: _buying ? null : _equip,
          variant: TactileButtonVariant.secondary,
        ),
      );
    }
    return Padding(
      // left/right 24 in the frame; the page already pads 16.
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ShopBuyButton(
        price: data.skin.priceCoins,
        label: l10n.shopBuy,
        onPressed: _buying ? null : () => _buy(data),
        height: 60,
        radius: 22,
        edge: 6,
        labelSize: 22,
      ),
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

  static const _radius = BorderRadius.all(
    Radius.circular(ShopTokens.detailPanelRadius),
  );

  @override
  Widget build(BuildContext context) {
    return NestySurface(
      style: SurfaceStyle(
        gradient: ShopLook.panel(skinId),
        shadows: [
          ...ShopTokens.detailPanelHighlight,
          NestyShadow(
            color: ShopLook.edge(skinId),
            dy: ShopTokens.detailPanelEdgeWidth,
          ),
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
                decoration: BoxDecoration(
                  color: ShopLook.captionFace(skinId),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    caption,
                    style: ShopTokens.detailPanelTagText.copyWith(
                      color: ShopLook.caption(skinId),
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
