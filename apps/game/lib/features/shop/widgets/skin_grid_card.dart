import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/settings/widgets/follows_symbols_mode.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/shop_look.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_game/features/shop/widgets/tag_pop.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

/// One Skins-tab card (frame 7.3): [SkinInfo.previewColors]' three dolls on
/// a plank over the skin's own card colour, then Equipped (green ring) /
/// Equip / the coin price. Tapping the card (outside its footer button)
/// opens the skin's detail (frame 7.4).
///
/// The 7.5 downloading state (purple ring, spinner, "Downloading N%") is
/// built for M4 and unreachable while every skin ships bundled (D75); see
/// [downloadPercent].
class SkinGridCard extends StatefulWidget {
  const SkinGridCard({
    required this.skin,
    required this.owned,
    required this.equipped,
    required this.coins,
    required this.onTap,
    required this.onEquip,
    required this.onBuy,
    required this.onGoToCoins,
    this.downloadPercent,
    super.key,
  });

  final SkinInfo skin;
  final bool owned;
  final bool equipped;

  /// The player's balance, for `NotEnoughCoinsDialog` (D112).
  final int coins;
  final VoidCallback onTap;
  final VoidCallback onEquip;

  /// Awaited by the caller, which shows the purchase celebration on
  /// [PurchaseOutcome.bought] and, on [PurchaseOutcome.needsCoins], opens
  /// `NotEnoughCoinsDialog` (D112). Asked even when the price is more than
  /// the balance: the price is orange either way (frame 7.3).
  final Future<PurchaseOutcome> Function() onBuy;

  /// `NotEnoughCoinsDialog`'s "Go to Shop": switches the already-open Shop
  /// to its Coins tab.
  final VoidCallback onGoToCoins;

  /// TODO(M4): a skin mid-download shows this instead of Equip/Buy; no
  /// bundled skin ever sets it (frame 7.5).
  final int? downloadPercent;

  static const double previewHeight = 84;

  @override
  State<SkinGridCard> createState() => _SkinGridCardState();
}

class _SkinGridCardState extends State<SkinGridCard> with FollowsSymbolsMode {
  LevelSkin? _art;

  /// The symbols mode of the latest request. The Shop tab stays mounted
  /// while Settings opens over Home, so a change there prepares the art
  /// again; the old art stays up until the new lands (D91).
  DollSymbols? _preparedSymbols;

  /// Bumped by every request, so a superseded one's art is released on
  /// arrival instead of shown.
  int _request = 0;

  /// Until the skin's art arrives the preview shows the spinner, never the
  /// placeholder dolls; those draw only when the art couldn't be prepared
  /// (rule 3).
  bool _prepared = false;
  bool _buying = false;

  /// A purchase tapped on this card is in flight, and whether its
  /// celebration has played: the card flipping to owned while the buy is
  /// pending is the swap (a purchase made on the detail screen, under this
  /// card, plays nothing here).
  bool _buyPending = false;
  bool _celebrated = false;

  /// The footer built now is the swap's: it comes in with `motion.tagPop`.
  bool _popFooter = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepare();
  }

  @override
  void didUpdateWidget(SkinGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The price chip became Equip / Equipped under this card's own tap.
    if (_buyPending && !oldWidget.owned && widget.owned) _swapped();
  }

  /// The purchase landed (`motion.purchaseItem`): the new footer pops, the
  /// haptic fires and three sparkles play, once.
  void _swapped() {
    if (_celebrated) return;
    _celebrated = true;
    _popFooter = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _popFooter = false);
    PurchaseTwinkleBurst.celebrate(context);
  }

  @override
  void onSymbolsModeChanged(SymbolsMode mode) => _prepare();

  void _prepare() {
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
    if (symbols == _preparedSymbols) return;
    _preparedSymbols = symbols;
    final request = ++_request;
    final skins = context.read<SkinService>();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    unawaited(
      skins
          .prepareShowcase(
            colors: widget.skin.previewColors,
            devicePixelRatio: dpr,
            symbols: symbols,
            skinId: widget.skin.id,
          )
          .then((art) {
            if (!mounted || request != _request) {
              art?.dispose();
              return;
            }
            final previous = _art;
            setState(() {
              _art = art;
              _prepared = true;
            });
            previous?.dispose();
          }),
    );
  }

  Future<void> _buy() async {
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
        // Normally the card flipped to owned already (above); a state that
        // lags still gets its celebration.
        _swapped();
      case PurchaseOutcome.needsCoins:
        unawaited(
          NotEnoughCoinsDialog.show(
            context,
            price: widget.skin.priceCoins,
            balance: widget.coins,
            itemName: context.localizations.skinNameOf(widget.skin.id),
            onGoToShop: widget.onGoToCoins,
          ),
        );
      case PurchaseOutcome.unavailable:
        break;
    }
  }

  @override
  void dispose() {
    _art?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final downloading = widget.downloadPercent != null;
    final ring = widget.equipped
        ? AppColorTokens.success
        : downloading
        ? SkinDownloadColors.cardRing
        : null;
    return TactileSurface(
      style: _cardStyle(ring),
      radius: const BorderRadius.all(Radius.circular(26)),
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(10),
      // One node for the card (its tap opens the detail): the name, then
      // what the footer shows, and the footer's Equip or Buy as the node's
      // own actions, since the card's label covers the footer's button
      // (review R14).
      semanticLabel: l10n.skinNameOf(widget.skin.id),
      semanticValue: _semanticState(l10n, downloading),
      customSemanticsActions: _semanticActions(context, downloading),
      excludeChildSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
            child: Container(
              height: SkinGridCard.previewHeight,
              decoration: BoxDecoration(
                gradient: ShopLook.card(widget.skin.id),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: PlankStrip(height: 14),
                  ),
                  if (_prepared)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: SkinDollRow(
                        colors: widget.skin.previewColors,
                        heights: const [66, 54, 44],
                        skin: _art,
                        library: context.read<FxLibrary>(),
                        symbols: context
                            .read<DatabaseService>()
                            .symbolsMode
                            .dollSymbols,
                      ),
                    )
                  else
                    const Center(child: FxSpinner()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.skinNameOf(widget.skin.id),
                // `shop.cardName` skins: Fredoka 700 16/1.1.
                style: ShopTokens.cardNameSkin.copyWith(
                  color: AppColorTokens.textPrimary,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _footer(context, downloading),
        ],
      ),
    );
  }

  /// What the footer shows, for the card's screen-reader value.
  String _semanticState(AppLocalizations l10n, bool downloading) {
    if (downloading) return l10n.shopDownloading(widget.downloadPercent!);
    if (widget.equipped) return l10n.shopEquipped;
    if (widget.owned) return l10n.skinOwnedSemantics;
    return l10n.coinPrice(widget.skin.priceCoins);
  }

  /// The footer button's action, offered on the card's own node: Equip for
  /// an owned skin, Buy for one not owned (none while it is equipped,
  /// downloading or being bought).
  Map<CustomSemanticsAction, VoidCallback>? _semanticActions(
    BuildContext context,
    bool downloading,
  ) {
    if (downloading || widget.equipped) return null;
    final l10n = context.localizations;
    void withFeedback(VoidCallback action) {
      TactileFeedback.of(context)?.activate();
      action();
    }

    if (widget.owned) {
      return {
        CustomSemanticsAction(label: l10n.shopEquip): () =>
            withFeedback(widget.onEquip),
      };
    }
    if (_buying) return null;
    return {
      CustomSemanticsAction(label: l10n.shopBuy): () =>
          withFeedback(() => unawaited(_buy())),
    };
  }

  Widget _footer(BuildContext context, bool downloading) {
    final l10n = context.localizations;
    if (downloading) {
      return _DownloadingPill(percent: widget.downloadPercent!);
    }
    if (widget.equipped) {
      return TagPop(
        key: const ValueKey('footer-equipped'),
        animate: _popFooter,
        child: _StatusPill(
          label: l10n.shopEquipped,
          color: AppColorTokens.successEdge,
          ring: AppColorTokens.successRing,
          face: AppColorTokens.successTint,
          icon: NestyIcons.checkCircle,
        ),
      );
    }
    // Frame 7.3 draws Equip at 34 and the price at 38 in a fixed-height
    // cell: each answers across 48 dp over the gap above it and the card's
    // padding below, instead of growing the card (review R19).
    if (widget.owned) {
      return TagPop(
        key: const ValueKey('footer-owned'),
        animate: _popFooter,
        child: TouchSlop(
          child: _EquipButton(label: l10n.shopEquip, onTap: widget.onEquip),
        ),
      );
    }
    return TouchSlop(
      child: ShopBuyButton(
        price: widget.skin.priceCoins,
        onPressed: _buying ? null : _buy,
        height: 34,
        radius: 13,
        edge: 4,
        plainPriceSize: 15,
        plainCoinSize: 18,
      ),
    );
  }

  static SurfaceStyle _cardStyle(Color? ring) => SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      ...AppShadowTokens.raised,
      if (ring != null) NestyShadow(color: ring, spread: 3),
    ],
  );
}

/// Frame 7.3's flat green "Equipped"/"In use" pill.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.ring,
    required this.face,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color ring;
  final Color face;
  final IconData icon;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: SurfaceStyle(
      color: face,
      shadows: [NestyShadow(color: ring, inset: true, spread: 2)],
    ),
    radius: const BorderRadius.all(Radius.circular(13)),
    height: 34,
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyleTokens.button.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

/// Frame 7.3/7.7's cream "Equip"/"Use" button.
class _EquipButton extends StatelessWidget {
  const _EquipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TactileSurface(
    style: SurfaceStyles.raised,
    radius: const BorderRadius.all(Radius.circular(13)),
    onPressed: onTap,
    height: 34,
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColorTokens.iconBrown,
      ),
    ),
  );
}

/// Frame 7.5's lilac downloading pill; built for M4, never reached with a
/// bundled catalog (D75).
class _DownloadingPill extends StatelessWidget {
  const _DownloadingPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      color: SkinDownloadColors.face,
      shadows: [
        NestyShadow(color: SkinDownloadColors.pillRing, inset: true, spread: 2),
      ],
    ),
    radius: const BorderRadius.all(Radius.circular(13)),
    height: 34,
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: SkinDownloadColors.text,
            backgroundColor: SkinDownloadColors.pillRing,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          context.localizations.shopDownloading(percent),
          style: AppTextStyleTokens.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SkinDownloadColors.text,
          ),
        ),
      ],
    ),
  );
}
