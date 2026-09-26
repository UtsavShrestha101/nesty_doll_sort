import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_icon.dart';
import 'package:nesty_game/core/ui/widgets/number/nesty_number_text.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Coin price button: primary gradient with a 22px coin and '60 coins'.
/// Disabled: `#E8DCCB`, text `#A48B72`, gray coin, sunk inner shadow"
/// (design/README.md "Components", frames 3.2, 3.8).
///
/// Disabled when [onPressed] is null (can't afford it).
class CoinPriceButton extends StatelessWidget {
  const CoinPriceButton({
    required this.price,
    required this.onPressed,
    this.size = TactileButtonSize.medium,
    this.expand = true,
    super.key,
  });

  final int price;
  final VoidCallback? onPressed;
  final TactileButtonSize size;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TactileButton(
      label: context.localizations.coinPrice(price),
      onPressed: onPressed,
      size: size,
      expand: expand,
      leading: CoinIcon(size: 22, disabled: !enabled, ring: enabled),
    );
  }
}

/// The compact gold price chip beside a sheet row's ▶ button: 40 tall, a
/// 20 px coin and the bare number (NestyOverlay OOM "+1 Slot" row).
class CoinPriceChip extends StatelessWidget {
  const CoinPriceChip({
    required this.price,
    required this.onPressed,
    super.key,
  });

  final int price;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TactileSurface(
      style: SurfaceStyles.coinChip,
      disabledStyle: SurfaceStyles.disabled,
      radius: BorderRadius.circular(14),
      onPressed: onPressed,
      height: 40,
      padding: const EdgeInsetsDirectional.only(start: 6, end: 10),
      semanticLabel: context.localizations.coinPrice(price),
      excludeChildSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: 20, disabled: !enabled),
          const SizedBox(width: 4),
          NestyNumberText(
            price,
            style: AppTextStyleTokens.number.copyWith(
              fontSize: 15,
              color: enabled ? AppColorTokens.coinText : AppColors.disabledText,
            ),
          ),
        ],
      ),
    );
  }
}
