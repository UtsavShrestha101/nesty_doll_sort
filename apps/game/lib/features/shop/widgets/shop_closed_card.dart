import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// The Coins and No Ads tabs' M3 placeholder (frame 7.1/7.8, docs/plans/
/// m3-design.md §10.7, D75, Q75): "The store is closed for now" / "Coin
/// packs and Remove Ads come in a later update."
///
/// TODO(M6): replace with the real coin packs (7.1, 7.2) and Remove
/// Ads / No-Ads Bundle (7.8) once purchases ship.
class ShopClosedCard extends StatelessWidget {
  const ShopClosedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NestySurface(
        style: SurfaceStyles.raised,
        radius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              NestyIcons.storefront,
              size: 40,
              color: AppColorTokens.iconBrown,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.shopClosedTitle,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.shopClosedBody,
              style: context.scriptStyle(
                AppTextStyles.body.copyWith(color: AppColorTokens.textBrown),
                role: ScriptTextRole.body,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
