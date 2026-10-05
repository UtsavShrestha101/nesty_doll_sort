import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The Shop's primary buy button (frames 7.3, 7.4b; tokens `shop.
/// buyCoinChip`): the orange primary face holding the buy coin chip, a
/// translucent white pill (`rgba(255,255,255,.22)`, radius 14, padding
/// 6/10/6/6) with a 22 dp coin and the price in Fredoka 700 19 white. With a
/// [label] ("Buy" on a skin's detail, frame 7.4b) it reads "Buy" then the
/// chip.
///
/// One semantics node, `shopBuySemantics(price)`. It is never drawn disabled
/// for want of coins: a tap the balance can't cover opens "Not enough coins"
/// instead (frames 7.3b, 7.4c), so [onPressed] is null only while a purchase
/// is under way.
class ShopBuyButton extends StatelessWidget {
  const ShopBuyButton({
    required this.price,
    required this.onPressed,
    this.label,
    this.height = 40,
    this.radius = 16,
    this.edge = 5,
    this.labelSize = 24,
    this.plainPriceSize,
    this.plainCoinSize,
    super.key,
  });

  final int price;
  final VoidCallback? onPressed;

  /// "Buy"; null draws the chip alone.
  final String? label;
  final double height;
  final double radius;
  final double edge;
  final double labelSize;

  /// A grid card's button (NestyShop:41-44, :71-74): no translucent chip,
  /// just the coin and the price in Fredoka 700 at this size (15 on a skin,
  /// 13 on a theme). Null draws the detail page's chip.
  final double? plainPriceSize;

  /// The coin's size beside a plain price (18 on a skin, 15 on a theme).
  final double? plainCoinSize;

  static const _variant = TactileButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final enabled = onPressed != null;
    final foreground = enabled
        ? ShopTokens.buyCoinChipText.color!
        : AppColorTokens.disabledText;
    final label = this.label;
    return TactileSurface(
      style: _variant.surface(edge),
      disabledStyle: SurfaceStyles.disabled,
      radius: BorderRadius.circular(radius),
      onPressed: onPressed,
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      semanticLabel: l10n.shopBuySemantics(price),
      excludeChildSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label,
                style: AppTextStyleTokens.button.copyWith(
                  fontSize: labelSize,
                  color: foreground,
                  shadows: enabled && _variant.textShadow != null
                      ? [
                          Shadow(
                            color: _variant.textShadow!,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                maxLines: 1,
                softWrap: false,
              ),
              const SizedBox(width: 10),
            ],
            if (plainPriceSize case final priceSize?)
              _priceRow(enabled, foreground, priceSize, plainCoinSize ?? 18)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  color: enabled ? ShopTokens.buyCoinChipFace : null,
                  borderRadius: BorderRadius.circular(
                    ShopTokens.buyCoinChipRadius,
                  ),
                ),
                child: Padding(
                  padding: ShopTokens.buyCoinChipPadding,
                  child: _priceRow(
                    enabled,
                    foreground,
                    ShopTokens.buyCoinChipText.fontSize!,
                    ShopTokens.buyCoinChipCoinSize,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    bool enabled,
    Color foreground,
    double fontSize,
    double coinSize,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CoinIcon(size: coinSize, disabled: !enabled),
      SizedBox(width: plainPriceSize == null ? 6 : 5),
      NestyNumberText(
        price,
        style: ShopTokens.buyCoinChipText.copyWith(
          fontSize: fontSize,
          height: 1,
          color: foreground,
        ),
      ),
    ],
  );
}
