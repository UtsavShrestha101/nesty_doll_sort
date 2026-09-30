import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the transient toast
/// (`NestyToast`, frames 5.2/8.3) and the M7 "Badge earned!" toast
/// (`BadgeToast`, §12, §15.2) at the five acceptance sizes and both text
/// scales, over a long title and message (the worst case for wrapping).
void main() {
  setUpAll(loadBundledFonts);

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'NestyToast fits ${size.width.toInt()}×${size.height.toInt()} at '
        '$scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            const Align(
              alignment: Alignment.topCenter,
              child: NestyToast(
                tone: NestyBannerTone.warning,
                icon: NestyIcons.acUnit,
                title: 'A freeze covered a much longer weekday than usual',
                message:
                    "You'll earn a new one next week, once the ISO week "
                    'turns over on Monday morning as usual.',
              ),
            ),
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
        },
      );

      for (final badge in BadgeId.values) {
        testWidgets('${badge.id} BadgeToast fits ${size.width.toInt()}×'
            '${size.height.toInt()} at $scale× text', (tester) async {
          await pumpScreen(
            tester,
            Scaffold(
              body: Builder(
                builder: (context) => Center(
                  // The test's own trigger, not part of the screen.
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    onTap: () => BadgeToast.show(context, badge),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await tester.tap(find.text('open'));
          await tester.pump(const Duration(milliseconds: 250));
          await expectAccessibleLayout(tester);
          // Lets the toast's own auto-dismiss timer
          // (`NestyToast.defaultDuration`, 3 s) and fade-out finish, so no
          // timer is left pending at teardown (the pattern
          // `daily_page_test.dart` uses for the same widget).
          await tester.pump(const Duration(seconds: 4));
        });
      }
    }
  }
}
