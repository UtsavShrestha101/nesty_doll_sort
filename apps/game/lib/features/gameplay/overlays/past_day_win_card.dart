import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/ui/date_skeleton.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';

/// A past day's win card, where the streak card was (frame 14.3d, tokens
/// `habits.pastDay.win*`): a 52 dp "played later" cell with the day, the long
/// date and "Played later, just for fun." It shows no coins, streak or chest:
/// a past day pays nothing and moves nothing (spec-prop §7.5c).
class PastDayWinCard extends StatelessWidget {
  const PastDayWinCard({required this.date, required this.moves, super.key});

  final LocalDate date;

  /// The solve's moves, for the screen reader's one sentence.
  final int moves;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final long = skeletonDateFormat(
      HabitsPastDayTokens.winDateSkeleton,
      locale,
    ).format(date.startOfDay);
    return Semantics(
      container: true,
      label: l10n.pastDailyWinSemantics(long, moves),
      excludeSemantics: true,
      child: NestySurface(
        style: winInfoCardStyle,
        radius: const BorderRadius.all(Radius.circular(24)),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            NestySurface(
              style: const SurfaceStyle(
                color: HabitsDayCellTokens.laterFace,
                shadows: [
                  ...HabitsDayCellTokens.laterInner,
                  NestyShadow(
                    color: HabitsDayCellTokens.laterEdge,
                    dy: HabitsDayCellTokens.raisedEdgeDepth,
                  ),
                ],
              ),
              radius: BorderRadius.circular(HabitsMonthTokens.gridRadius),
              width: HabitsPastDayTokens.winDateCell,
              height: HabitsPastDayTokens.winDateCell,
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                maxLines: 1,
                softWrap: false,
                style: context
                    .scriptStyle(HabitsMonthTokens.gridNumber)
                    .copyWith(
                      color: HabitsDayCellTokens.laterNumberColor,
                      fontWeight: HabitsDayCellTokens.laterNumberWeight,
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.pastDailyWinDate(long),
                    style: context
                        .scriptStyle(HabitsPastDayTokens.winDateText)
                        .copyWith(color: AppColorTokens.textBrown),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.pastDailyWinLine,
                    style: HabitsPastDayTokens.cardNote.copyWith(
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
