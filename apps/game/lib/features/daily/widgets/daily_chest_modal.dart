import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';

/// The day-7 chest (frame 5.6), on opening Daily while `chestPending`:
/// "7-day streak!", the open chest, "+300", Collect. "Double it" is hidden
/// until M6 (`TODO(M6)`).
class DailyChestModal extends StatelessWidget {
  const DailyChestModal({
    required this.coins,
    required this.onCollect,
    super.key,
  });

  final int coins;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Stack(
      fit: StackFit.expand,
      children: [
        const Scrim(),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ModalCard(
              ribbon: RibbonTitle.streak(l10n.dailyChestTitle),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ChestIcon.open(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 38),
                      const SizedBox(width: 10),
                      Text(
                        l10n.winCoins(coins),
                        style: AppTextStyleTokens.h1.copyWith(
                          fontSize: 34,
                          height: 1,
                          color: AppColors.chestLockRing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.dailyChestBody,
                    textAlign: TextAlign.center,
                    style: AppTextStyleTokens.row.copyWith(
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBrown,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // TODO(M6): "Double it" (a rewarded ad) sits above Collect.
                  TactileButton(
                    label: l10n.dailyChestCollect,
                    onPressed: onCollect,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
