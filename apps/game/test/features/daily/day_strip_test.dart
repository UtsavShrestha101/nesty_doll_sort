import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/day_strip.dart';

import '../support/screen_harness.dart';

/// The Daily's 7-day strip (frames 5.1, 5.2b): a done day, the chest and a
/// future day each carry the design's 2 dp inset ring (`inset 0 0 0 2px`).
void main() {
  testWidgets('every ringed tile draws a 2 dp ring, not a zero-size one', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Material(
        child: Center(
          child: DayStrip(
            status: DailyStatus(
              today: LocalDate(2026, 9, 26),
              tier: Tier.hard,
              colors: 5,
              unlocked: true,
              streak: 4,
              lit: true,
              run: 4,
              freezes: 1,
              cycleDone: 4,
            ),
          ),
        ),
      ),
    );
    final rings = {
      for (final surface in tester.widgetList<NestySurface>(
        find.descendant(
          of: find.byType(DayStrip),
          matching: find.byType(NestySurface),
        ),
      ))
        for (final shadow in surface.style.shadows)
          if (shadow.inset && shadow.dx == 0 && shadow.dy == 0)
            shadow.color: shadow.spread,
    };
    // An inset shadow with no spread, blur or offset paints nothing.
    expect(rings, {
      AppColorTokens.dayDoneRing: 2,
      AppColorTokens.dayChestRing: 2,
      AppColorTokens.dayFutureRing: 2,
    });
  });
}
