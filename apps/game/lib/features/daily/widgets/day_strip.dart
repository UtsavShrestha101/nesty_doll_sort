import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The 7-day streak strip (frame 5.1; m3-design §8.4): "day i (1–7) is done
/// for i ≤ cycleDone; day cycleDone + 1 is 'Today' when unsolved, or
/// 'Tmrw' when solved; later days locked; day 7 is the chest, open gold
/// when done."
///
/// Every cell is the same height: the frame lifts "Today" by 8 dp and
/// raises it above its neighbours (`NestyMenus` `d.hgt`/`d.lift`), which
/// this keeps flat instead, so the row stays simple to lay out at every
/// width and text scale (`TODO(design)`: no lift, no wobble).
class DayStrip extends StatelessWidget {
  const DayStrip({required this.status, super.key});

  final DailyStatus status;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var day = 1; day <= 7; day++) ...[
        if (day > 1) const SizedBox(width: 6),
        Expanded(
          child: _DayCell(day: day, status: status),
        ),
      ],
    ],
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.status});

  final int day;
  final DailyStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final isChest = day == 7;
    final done = day <= status.cycleDone;
    final isToday =
        !isChest && day == status.cycleDone + 1 && !status.solvedToday;
    final isTomorrow =
        !isChest && day == status.cycleDone + 1 && status.solvedToday;

    final SurfaceStyle style;
    final Color dot;
    final Color icon;
    final IconData glyph;
    final String label;
    if (done && !isChest) {
      style = const SurfaceStyle(
        color: AppColors.dayDoneFace,
        shadows: [NestyShadow(color: AppColors.dayDoneRing, inset: true)],
      );
      dot = AppColorTokens.success;
      icon = const Color(0xFFFFFFFF);
      glyph = NestyIcons.check;
      label = l10n.dailyDay;
    } else if (isToday) {
      style = const SurfaceStyle(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.dayTodayTop, AppColorTokens.primary],
        ),
        shadows: [NestyShadow(color: AppColorTokens.primaryEdge, dy: 5)],
      );
      dot = AppColors.cream;
      icon = AppColorTokens.primary;
      glyph = NestyIcons.playArrow;
      label = l10n.dailyToday;
    } else if (isChest) {
      style = done
          ? const SurfaceStyle(
              gradient: AppGradientTokens.daily,
              shadows: [NestyShadow(color: AppColors.dayChestOpenEdge, dy: 5)],
            )
          : const SurfaceStyle(
              color: AppColors.dayChestPendingFace,
              shadows: [
                NestyShadow(color: AppColors.dayChestPendingRing, inset: true),
              ],
            );
      dot = done ? AppColors.dayChestOpenDot : AppColors.dayChestPendingDot;
      icon = AppColors.dayChestPendingIcon;
      glyph = NestyIcons.redeem;
      label = l10n.dailyDay;
    } else {
      style = const SurfaceStyle(
        color: AppColors.dayLockedFace,
        shadows: [NestyShadow(color: AppColors.dayLockedRing, inset: true)],
      );
      dot = AppColors.dayLockedDot;
      icon = AppColors.dayLockedIcon;
      glyph = NestyIcons.lock;
      label = isTomorrow ? l10n.dailyTomorrow : l10n.dailyDay;
    }
    final textColor = isToday ? const Color(0xFFFFFFFF) : AppColors.textBrown;
    // One ARB sentence per state (RULES-2), so a locale can reorder it and
    // a screen reader says "Tomorrow" where the strip prints "Tmrw".
    final semanticsState = isChest
        ? 'chest'
        : done
        ? 'done'
        : isToday
        ? 'today'
        : isTomorrow
        ? 'tomorrow'
        : 'locked';

    return Semantics(
      label: l10n.dailyDaySemantics(semanticsState, day),
      excludeSemantics: true,
      child: NestySurface(
        style: style,
        radius: const BorderRadius.all(Radius.circular(16)),
        height: 96,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyleTokens.tierChip.copyWith(
                fontSize: 10.5,
                color: textColor,
              ),
              maxLines: 1,
            ),
            SizedBox.square(
              dimension: 28,
              child: DecoratedBox(
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                child: Icon(glyph, size: 19, color: icon),
              ),
            ),
            Text(
              '$day',
              style: AppTextStyleTokens.tierChip.copyWith(
                fontSize: 13,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
