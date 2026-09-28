import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_colors.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';

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
    required this.onTap,
    required this.onEquip,
    required this.onBuy,
    this.downloadPercent,
    super.key,
  });

  final SkinInfo skin;
  final bool owned;
  final bool equipped;
  final VoidCallback onTap;
  final VoidCallback onEquip;

  /// Awaited by the caller, which shows the purchase celebration on
  /// success. Asked even when the price is more than the balance: the
  /// price is orange either way (frame 7.3), and `ShopCubit.buySkin` then
  /// opens the Coins tab (FIDELITY-7).
  final Future<bool> Function() onBuy;

  /// TODO(M4): a skin mid-download shows this instead of Equip/Buy; no
  /// bundled skin ever sets it (frame 7.5).
  final int? downloadPercent;

  static const double previewHeight = 84;

  @override
  State<SkinGridCard> createState() => _SkinGridCardState();
}

class _SkinGridCardState extends State<SkinGridCard> {
  LevelSkin? _art;
  bool _preparing = false;

  /// Until the skin's art arrives the preview shows the spinner, never the
  /// placeholder dolls; those draw only when the art couldn't be prepared
  /// (rule 3).
  bool _prepared = false;
  bool _buying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepare();
  }

  void _prepare() {
    if (_art != null || _preparing) return;
    _preparing = true;
    final skins = context.read<SkinService>();
    final symbols = context.read<DatabaseService>().symbolsMode.dollSymbols;
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
            if (!mounted) {
              art?.dispose();
              return;
            }
            setState(() {
              _art = art;
              _prepared = true;
            });
          }),
    );
  }

  Future<void> _buy() async {
    if (_buying) return;
    setState(() => _buying = true);
    final ok = await widget.onBuy();
    if (!mounted) return;
    setState(() => _buying = false);
    if (ok) PurchaseTwinkleBurst.showOver(context);
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
        ? SkinShopColors.downloadingCardRing
        : null;
    return TactileSurface(
      style: _cardStyle(ring),
      radius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(10),
      semanticLabel: l10n.skinName(widget.skin.id),
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
                gradient: SkinShopColors.cardBackground(widget.skin.id),
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
            child: Text(
              l10n.skinName(widget.skin.id),
              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          _footer(context, downloading),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, bool downloading) {
    final l10n = context.localizations;
    if (downloading) {
      return _DownloadingPill(percent: widget.downloadPercent!);
    }
    if (widget.equipped) {
      return _StatusPill(
        label: l10n.shopEquipped,
        color: AppColorTokens.success,
        face: SkinShopColors.equippedFace,
        icon: NestyIcons.checkCircle,
      );
    }
    if (widget.owned) {
      return _EquipButton(label: l10n.shopEquip, onTap: widget.onEquip);
    }
    return CoinPriceButton(
      price: widget.skin.priceCoins,
      onPressed: _buying ? null : _buy,
      size: TactileButtonSize.compact,
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
    required this.face,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color face;
  final IconData icon;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: SurfaceStyle(
      color: face,
      shadows: [NestyShadow(color: color, inset: true, spread: 2)],
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
        color: AppColors.iconBrown,
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
      color: SkinShopColors.downloadingFace,
      shadows: [
        NestyShadow(
          color: SkinShopColors.downloadingPillRing,
          inset: true,
          spread: 2,
        ),
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
            color: SkinShopColors.downloadingText,
            backgroundColor: SkinShopColors.downloadingPillRing,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          context.localizations.shopDownloading(percent),
          style: AppTextStyleTokens.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SkinShopColors.downloadingText,
          ),
        ),
      ],
    ),
  );
}
