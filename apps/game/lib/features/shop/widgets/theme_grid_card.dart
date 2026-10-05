import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/tag_pop.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// One Themes-tab tile (frame 7.7; menus spec 8.2): the chapter's own crop
/// of its background art (158×74, radius 16, `ThemeThumbnail`), its name,
/// then In use (green ring) / Use / a locked "lock · Ch N" chip on the crop
/// with the price button (the buy coin chip) below. A locked crop stays in
/// full colour here, unlike Chapters' greyed rows.
class ThemeGridCard extends StatefulWidget {
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
  State<ThemeGridCard> createState() => _ThemeGridCardState();
}

class _ThemeGridCardState extends State<ThemeGridCard> {
  bool _buying = false;

  /// A purchase tapped on this card is in flight, and whether its
  /// celebration has played (see `SkinGridCard`).
  bool _buyPending = false;
  bool _celebrated = false;

  /// The footer built now is the swap's: it comes in with `motion.tagPop`.
  bool _popFooter = false;

  @override
  void didUpdateWidget(ThemeGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        _swapped();
      case PurchaseOutcome.needsCoins:
        unawaited(
          NotEnoughCoinsDialog.show(
            context,
            price: widget.theme.priceCoins,
            balance: widget.coins,
            itemName: context.localizations.chapterName(widget.theme.id),
            onGoToShop: widget.onGoToCoins,
          ),
        );
      case PurchaseOutcome.unavailable:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final owned = widget.owned;
    final inUse = widget.inUse;
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
                  size: Size(
                    constraints.maxWidth,
                    ThemeGridCard.thumbnailHeight,
                  ),
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
                // `shop.cardName` themes: Fredoka 700 14/1.15.
                style: ShopTokens.cardNameTheme.copyWith(
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
            TagPop(
              key: const ValueKey('footer-in-use'),
              animate: _popFooter,
              child: _InUsePill(label: l10n.themeInUse),
            )
          else if (owned)
            TagPop(
              key: const ValueKey('footer-owned'),
              animate: _popFooter,
              child: TouchSlop(
                child: _UseButton(label: l10n.themeUse, onTap: widget.onUse),
              ),
            )
          else
            TouchSlop(
              child: ShopBuyButton(
                price: theme.priceCoins,
                onPressed: _buying ? null : _buy,
                height: 30,
                radius: 12,
                edge: 3,
                plainPriceSize: 13,
                plainCoinSize: 15,
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
              fontSize: 11,
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
        color: AppColorTokens.iconBrown,
      ),
    ),
  );
}
