import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The 7-day streak strip (frame 5.1; m3-design §8.4): "day i (1–7) is done
/// for i ≤ cycleDone; day cycleDone + 1 is 'Today' when unsolved, or
/// 'Tmrw' when solved; later days locked; day 7 is the chest, open gold
/// when done."
///
/// Every cell is the same height; "Today" is lifted 4 dp (ui-spec-menus
/// §6.6, a paint-only shift, so the row's layout never changes at any width
/// or text scale) on the primary gradient with white text, and the 34 dp
/// discs carry the state (a check, a lock, the `redeem` chest).
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
  /// Today's lift (ui-spec-menus §6.6).
  static const double liftToday = 4;

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
        color: AppColorTokens.dayDoneFace,
        shadows: [NestyShadow(color: AppColorTokens.dayDoneRing, inset: true)],
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
          colors: [AppColorTokens.dayTodayTop, AppColorTokens.primary],
        ),
        shadows: [NestyShadow(color: AppColorTokens.primaryEdge, dy: 5)],
      );
      dot = AppColorTokens.cream;
      icon = AppColorTokens.primary;
      glyph = NestyIcons.playArrow;
      label = l10n.dailyToday;
    } else if (isChest) {
      style = done
          ? const SurfaceStyle(
              gradient: AppGradientTokens.daily,
              shadows: [NestyShadow(color: AppColorTokens.dayOpenEdge, dy: 5)],
            )
          : const SurfaceStyle(
              color: AppColorTokens.dayChestFace,
              shadows: [
                NestyShadow(color: AppColorTokens.dayChestRing, inset: true),
              ],
            );
      dot = done ? AppColorTokens.dayOpenDot : AppColorTokens.dayChestDot;
      icon = AppColorTokens.coinText;
      glyph = NestyIcons.redeem;
      label = l10n.dailyDay;
    } else {
      style = const SurfaceStyle(
        color: AppColorTokens.dayFutureFace,
        shadows: [
          NestyShadow(color: AppColorTokens.dayFutureRing, inset: true),
        ],
      );
      dot = AppColorTokens.dayFutureDot;
      icon = AppColorTokens.dayFutureGlyph;
      glyph = NestyIcons.lock;
      label = isTomorrow ? l10n.dailyTomorrow : l10n.dailyDay;
    }
    final textColor = isToday
        ? const Color(0xFFFFFFFF)
        : AppColorTokens.textBrown;
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
      child: Transform.translate(
        offset: Offset(0, isToday ? -liftToday : 0),
        child: NestySurface(
          style: style,
          radius: const BorderRadius.all(Radius.circular(18)),
          height: 96,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scales down at a large text scale, never cut ("Today" at 1.3×
              // on a 360 dp phone).
              ShrinkToFitText(
                label,
                maxLines: 1,
                style: AppTextStyleTokens.tierChip.copyWith(
                  fontSize: 11,
                  color: textColor,
                ),
              ),
              SizedBox.square(
                dimension: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  child: Icon(glyph, size: 22, color: icon),
                ),
              ),
              Text(
                '$day',
                style: AppTextStyleTokens.tierChip.copyWith(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
