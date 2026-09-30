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

  static const _variant = TactileButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final enabled = onPressed != null;
    final foreground = enabled
        ? ShopTokens.buyCoinChipText.color!
        : AppColors.disabledText;
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: enabled ? ShopTokens.buyCoinChipFace : null,
                borderRadius: BorderRadius.circular(
                  ShopTokens.buyCoinChipRadius,
                ),
              ),
              child: Padding(
                padding: ShopTokens.buyCoinChipPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CoinIcon(
                      size: ShopTokens.buyCoinChipCoinSize,
                      disabled: !enabled,
                    ),
                    const SizedBox(width: 6),
                    NestyNumberText(
                      price,
                      style: ShopTokens.buyCoinChipText.copyWith(
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
    );
  }
}
