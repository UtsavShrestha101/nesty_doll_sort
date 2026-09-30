import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// One Themes-tab tile (frame 7.7; menus spec 8.2): the chapter's own crop
/// of its background art (158×74, radius 16, `ThemeThumbnail`), its name,
/// then In use (green ring) / Use / a locked "lock · Ch N" chip on the crop
/// with the price button (the buy coin chip) below. A locked crop stays in
/// full colour here, unlike Chapters' greyed rows.
class ThemeGridCard extends StatelessWidget {
  const ThemeGridCard({
    required this.theme,
    required this.owned,
    required this.inUse,
    required this.coins,
    required this.onUse,
    required this.onBuy,
    required this.onGoToCoins,
    super.key,
  });

  final ThemeInfo theme;
  final bool owned;
  final bool inUse;

  /// The player's balance, for `NotEnoughCoinsDialog` (D112).
  final int coins;
  final VoidCallback onUse;

  /// Awaited by the caller, which shows the purchase celebration on
  /// [PurchaseOutcome.bought] and, on [PurchaseOutcome.needsCoins], opens
  /// `NotEnoughCoinsDialog` (D112).
  final Future<PurchaseOutcome> Function() onBuy;

  /// `NotEnoughCoinsDialog`'s "Go to Shop": switches the already-open Shop
  /// to its Coins tab.
  final VoidCallback onGoToCoins;

  static const double thumbnailHeight = 74;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final ring = inUse ? AppColorTokens.success : null;
    return NestySurface(
      style: SurfaceStyle(
        gradient: AppGradientTokens.surface,
        shadows: [
          ...AppShadowTokens.raised,
          if (ring != null) NestyShadow(color: ring, spread: 3),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(26)),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                ThemeThumbnail(
                  theme: ChapterTheme.byId(theme.id) ?? ChapterTheme.ch01,
                  size: Size(constraints.maxWidth, thumbnailHeight),
                  radius: 16,
                ),
                if (!owned)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: _LockChip(number: theme.chapterNumber),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            // Scales down rather than cut (m7-design §15's shared rule;
            // "Rainy Café Corner" at 1.3× on 360 dp, review R29).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.chapterName(theme.id),
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 19,
                  color: AppColorTokens.textPrimary,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          const SizedBox(height: 7),
          // Frame 7.7 draws Use at 30 and the price at 38 in a fixed-height
          // cell: each answers across 48 dp over the gap above it and the
          // card's padding below instead of growing the card (review R19).
          if (inUse)
            _InUsePill(label: l10n.themeInUse)
          else if (owned)
            TouchSlop(
              child: _UseButton(label: l10n.themeUse, onTap: onUse),
            )
          else
            TouchSlop(
              child: _LockedBuyButton(
                themeId: theme.id,
                price: theme.priceCoins,
                coins: coins,
                onTap: onBuy,
                onGoToCoins: onGoToCoins,
              ),
            ),
        ],
      ),
    );
  }
}

/// The locked theme's top-right "lock · Ch N" chip.
class _LockChip extends StatelessWidget {
  const _LockChip({required this.number});

  final int number;

  // Frame 7.7: `rgba(60,30,10,.7)` with white Fredoka 700 12.
  static const _face = Color(0xB33C1E0A);
  static const _text = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: _face,
      borderRadius: BorderRadius.all(Radius.circular(9)),
    ),
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 3, 7, 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(NestyIcons.lock, size: 13, color: _text),
          const SizedBox(width: 2),
          Text(
            context.localizations.themeChapterLock(number),
            style: AppTextStyleTokens.button.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InUsePill extends StatelessWidget {
  const _InUsePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      color: AppColorTokens.successTint,
      shadows: [
        NestyShadow(color: AppColorTokens.successRing, inset: true, spread: 2),
      ],
    ),
    radius: const BorderRadius.all(Radius.circular(12)),
    height: 30,
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColorTokens.successEdge,
      ),
    ),
  );
}

class _UseButton extends StatelessWidget {
  const _UseButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TactileSurface(
    style: SurfaceStyles.raised,
    radius: const BorderRadius.all(Radius.circular(12)),
    onPressed: onTap,
    height: 30,
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.iconBrown,
      ),
    ),
  );
}

class _LockedBuyButton extends StatefulWidget {
  const _LockedBuyButton({
    required this.themeId,
    required this.price,
    required this.coins,
    required this.onTap,
    required this.onGoToCoins,
  });

  final String themeId;
  final int price;
  final int coins;
  final Future<PurchaseOutcome> Function() onTap;
  final VoidCallback onGoToCoins;

  @override
  State<_LockedBuyButton> createState() => _LockedBuyButtonState();
}

class _LockedBuyButtonState extends State<_LockedBuyButton> {
  bool _buying = false;

  Future<void> _tap() async {
    if (_buying) return;
    setState(() => _buying = true);
    final outcome = await widget.onTap();
    if (!mounted) return;
    setState(() => _buying = false);
    switch (outcome) {
      case PurchaseOutcome.bought:
        PurchaseTwinkleBurst.celebrate(context);
      case PurchaseOutcome.needsCoins:
        unawaited(
          NotEnoughCoinsDialog.show(
            context,
            price: widget.price,
            balance: widget.coins,
            itemName: context.localizations.chapterName(widget.themeId),
            onGoToShop: widget.onGoToCoins,
          ),
        );
      case PurchaseOutcome.unavailable:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ShopBuyButton(
    price: widget.price,
    onPressed: _buying ? null : _tap,
    height: 38,
    radius: 14,
    edge: 4,
  );
}
