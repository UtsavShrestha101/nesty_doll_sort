import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/features/daily/widgets/daily_locked_card.dart';
import 'package:nesty_game/features/daily/widgets/month_card.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// Local habit 2's month card (docs/plans/plan-local-habits.md "2. A month
/// of played days"): the five sizes at both text scales, in this run's
/// locale (`--dart-define=NESTY_TEST_LOCALE=<code>`). `expectAccessibleLayout`
/// includes the readability floor, so the weekday header and the day numbers
/// are checked in `ja` and `hi` (no text drawn below 75 % of its style, none
/// cut). The page's own scroll is covered by `daily_overflow_test.dart`.
void main() {
  setUpAll(loadBundledFonts);

  DailyStatus statusOf(
    LocalDate today, {
    List<LocalDate> done = const [],
    List<LocalDate> frozen = const [],
  }) => DailyStatus(
    today: today,
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    streak: 3,
    lit: true,
    run: 3,
    freezes: 1,
    done: done,
    frozen: frozen,
  );

  final states = {
    // 2026-08-01 is a Saturday: a six-row month on a Sunday start.
    'a six-row month': statusOf(
      LocalDate(2026, 8, 31),
      done: [for (var d = 1; d <= 31; d += 2) LocalDate(2026, 8, d)],
      frozen: [LocalDate(2026, 8, 2), LocalDate(2026, 8, 30)],
    ),
    'the 31st, today solved': statusOf(
      LocalDate(2026, 10, 31),
      done: [LocalDate(2026, 10, 31), LocalDate(2026, 10, 30)],
    ),
    'a four-row month, nothing played': statusOf(LocalDate(2027, 2, 14)),
    'a leap February': statusOf(
      LocalDate(2028, 2, 10),
      done: [LocalDate(2028, 2, 9)],
    ),
  };

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: status) in states.entries) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text '
          '($name)',
          (tester) async {
            await pumpScreen(
              tester,
              Material(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MonthCard(status: status),
                ),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 100));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  }

  // Frame 12.14, the Daily before Level 2 (the same sizes and scales).
  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('the locked Daily card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          Material(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DailyLockedCard(playLevelNumber: 2, onPlay: () {}),
            ),
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectAccessibleLayout(tester);
      });
    }
  }
}
