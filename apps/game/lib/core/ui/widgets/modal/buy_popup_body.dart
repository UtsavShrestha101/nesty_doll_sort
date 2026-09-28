import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/coin_price_button.dart';
import 'package:nesty_game/core/ui/widgets/buttons/rewarded_ad_button.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The buy-a-booster popup's body (design/README.md "3.2 / 3.3 Buy popup":
/// "ribbon title, 112px icon disc with an 8px halo, benefit line (17/700),
/// [coins] [▶ Watch ad], 'You have 830 coins'"; also the +1 Slot popup).
/// The caller wraps it in a [ModalCard] with the booster's title and a
/// close button (`ModalCard(title: ..., onClose: ..., child: BuyPopupBody(...))`).
///
/// Offline (frame 3.8), the coin button is shown disabled instead ([offline]
/// true) with a red "Connect to watch an ad" note; [onWatchAd] and
/// [adAvailable] are ignored then. Online (frame 3.2/3.3), the ad button
/// only shows while [adAvailable] (hidden entirely until M6 ads ship,
/// docs/plans/m3-design.md D73).
class BuyPopupBody extends StatelessWidget {
  const BuyPopupBody({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.haloColor,
    required this.benefitText,
    required this.price,
    required this.balanceLabel,
    required this.onBuy,
    this.onWatchAd,
    this.adAvailable = false,
    this.offline = false,
    super.key,
  });

  /// A `NestyIcons.*` glyph (undo, lightbulb, add_box).
  final IconData icon;

  /// The icon disc's radial gradient (a different one per booster).
  final Gradient iconBackground;
  final Color iconColor;

  /// The disc's 8 px halo ring.
  final Color haloColor;

  /// "Shows your next best move.", the buyUndoText/buySlotText lines.
  final String benefitText;
  final int price;

  /// "You have {count} coins" (`balanceLine`).
  final String balanceLabel;

  /// Null while it can't be afforded (the coin button shows disabled).
  final VoidCallback? onBuy;
  final VoidCallback? onWatchAd;
  final bool adAvailable;
  final bool offline;

  static const double iconDiscSize = 112;
  static const double _haloWidth = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconDisc(
          icon: icon,
          background: iconBackground,
          iconColor: iconColor,
          haloColor: haloColor,
        ),
        const SizedBox(height: 18),
        Text(
          benefitText,
          style: AppTextStyleTokens.row.copyWith(fontSize: 17, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        if (offline) ...[
          CoinPriceButton(price: price, onPressed: null),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                NestyIcons.wifiOff,
                size: 18,
                color: AppColorTokens.hardText,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.connectToWatchAd,
                style: AppTextStyleTokens.caption.copyWith(
                  fontSize: 14,
                  color: AppColorTokens.hardText,
                ),
              ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: CoinPriceButton(price: price, onPressed: onBuy),
              ),
              if (adAvailable) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: RewardedAdButton(
                    label: l10n.watchAd,
                    onPressed: onWatchAd,
                    size: TactileButtonSize.medium,
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 14),
        Text(
          balanceLabel,
          style: AppTextStyleTokens.caption.copyWith(
            fontSize: 13,
            height: 1,
            color: AppColorTokens.textMuted,
          ),
        ),
      ],
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.haloColor,
  });

  final IconData icon;
  final Gradient background;
  final Color iconColor;
  final Color haloColor;

  @override
  Widget build(BuildContext context) {
    final style = SurfaceStyle(
      gradient: background,
      shadows: [
        NestyShadow(color: haloColor, spread: BuyPopupBody._haloWidth),
        const NestyShadow(color: Color(0x1F000000), inset: true, dy: -5),
      ],
    );
    return ExcludeSemantics(
      child: NestySurface(
        style: style,
        radius: BorderRadius.circular(BuyPopupBody.iconDiscSize / 2),
        width: BuyPopupBody.iconDiscSize,
        height: BuyPopupBody.iconDiscSize,
        alignment: Alignment.center,
        child: Icon(icon, size: 64, color: iconColor),
      ),
    );
  }
}
