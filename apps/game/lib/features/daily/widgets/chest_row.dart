import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';

/// The "Day 7 chest · 300 coins" row (frame 5.1): its sub-caption is "N
/// days to go, counting today" (unsolved), "N days to go" (solved) or
/// "Opened today" (chest day solved, m3-design §8.4).
class ChestRow extends StatelessWidget {
  const ChestRow({required this.status, required this.chestCoins, super.key});

  final DailyStatus status;
  final int chestCoins;

  /// The chest art's box in the row (ui-spec-menus §6.6: 58×48).
  static const double chestArtWidth = 58;

  static const _style = SurfaceStyle(
    color: Color(0xE5FFF9EC), // rgba(255,249,236,.9)
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 3)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final sub = status.solvedToday
        ? (status.daysToChest <= 0
              ? l10n.dailyChestOpenedToday
              : l10n.dailyChestToGo(status.daysToChest))
        : l10n.dailyChestToGoToday(status.daysToChest);
    return NestySurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const ChestIcon(size: chestArtWidth),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dailyChestRow(chestCoins),
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyleTokens.row.copyWith(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.textBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
