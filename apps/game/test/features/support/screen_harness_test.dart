import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/ui/support/ui_harness.dart';
import 'screen_harness.dart';

/// The overflow suite's own check (M7 review R36): it must fail on what an
/// overflow check alone passes, a small target and cut text.
void main() {
  setUpAll(loadBundledFonts);

  testWidgets('passes a 48 dp labelled button and text that fits', (
    tester,
  ) async {
    await pumpUi(
      tester,
      Center(
        child: SizedBox.square(
          dimension: 48,
          child: GestureDetector(onTap: () {}, child: const Text('Go')),
        ),
      ),
    );
    await expectAccessibleLayout(tester);
  });

  testWidgets('fails a tappable node under 48 dp', (tester) async {
    await pumpUi(
      tester,
      Center(
        child: SizedBox(
          width: 80,
          height: 30,
          child: GestureDetector(onTap: () {}, child: const Text('Use')),
        ),
      ),
    );
    TestFailure? failure;
    try {
      await expectAccessibleLayout(tester);
    } on TestFailure catch (error) {
      failure = error;
    }
    expect(failure?.message, contains('at least Size(48.0, 48.0)'));
  });

  testWidgets('fails an ellipsis', (tester) async {
    await pumpUi(
      tester,
      const Center(
        child: SizedBox(
          width: 60,
          child: Text(
            'Saturday’s puzzle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    expect(() => expectNoCutText(tester), throwsA(isA<TestFailure>()));
  });

  testWidgets('fails lines past maxLines', (tester) async {
    await pumpUi(
      tester,
      const Center(
        child: SizedBox(
          width: 40,
          child: Text('Every Rival Beaten', maxLines: 2),
        ),
      ),
    );
    expect(() => expectNoCutText(tester), throwsA(isA<TestFailure>()));
  });
}
