import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/fx/spinner_pulse.dart';

import '../support/screen_harness.dart';

/// m7-4 4.17 (tokens.json `motion.spinner.reducedMotion`): the spinner rests
/// on frame 0 and pulses 1 -> 0.45 -> 1 over 1,600 ms, `easeInOut`.
void main() {
  Widget host() =>
      const Center(child: SpinnerPulse(child: SizedBox.square(dimension: 20)));

  Finder pulseFinder() => find.descendant(
    of: find.byType(SpinnerPulse),
    matching: find.byType(FadeTransition),
  );

  testWidgets('the pulse is the token\'s: 0.45 at the low, 1,600 ms', (
    tester,
  ) async {
    expect(SpinnerPulse.minOpacity, 0.45);
    expect(SpinnerPulse.period, const Duration(milliseconds: 1600));
    await pumpScreen(tester, host(), reduceMotion: true);
    final opacity = tester.widget<FadeTransition>(pulseFinder()).opacity;
    await tester.pump();
    expect(opacity.value, closeTo(1, 0.001));
    // easeInOut: slower at both ends than a straight line.
    await tester.pump(const Duration(milliseconds: 200));
    expect(opacity.value, greaterThan(1 - 0.55 * 0.25 * 1.2 / 1));
    await tester.pump(const Duration(milliseconds: 600));
    expect(opacity.value, closeTo(0.45, 0.01));
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity.value, closeTo(1, 0.01));
  });

  testWidgets('with motion allowed it is the child itself', (tester) async {
    await pumpScreen(tester, host());
    expect(pulseFinder(), findsNothing);
  });

  testWidgets('FxSpinner wears it, so every loading card pulses', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Center(child: FxSpinner()),
      reduceMotion: true,
    );
    expect(find.byType(SpinnerPulse), findsOneWidget);
    expect(pulseFinder(), findsOneWidget);
  });
}
