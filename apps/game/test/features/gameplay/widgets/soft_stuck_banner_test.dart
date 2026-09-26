import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

Widget _banner({
  required bool visible,
  VoidCallback? onUndo,
  VoidCallback? onRestart,
}) => Scaffold(
  body: Stack(
    children: [
      Positioned(
        left: SoftStuckBanner.side,
        right: SoftStuckBanner.side,
        top: 59 + SoftStuckBanner.top,
        child: SoftStuckBanner(
          visible: visible,
          onUndo: onUndo,
          onRestart: onRestart,
        ),
      ),
    ],
  ),
);

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('hidden, it draws nothing and takes no touches', (tester) async {
    await pumpScreen(tester, _banner(visible: false, onUndo: () {}));
    expect(find.text('Hmm, this looks stuck'), findsNothing);
  });

  testWidgets('slides in with frame 3.4 copy; Undo sends undo', (tester) async {
    var undos = 0;
    await pumpScreen(tester, _banner(visible: false, onUndo: () => undos++));
    await pumpScreen(tester, _banner(visible: true, onUndo: () => undos++));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hmm, this looks stuck'), findsOneWidget);
    expect(find.text('Try Undo? You can keep playing too.'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(undos, 1);

    // The next board change clears it: it fades out, then is gone.
    await pumpScreen(tester, _banner(visible: false, onUndo: () => undos++));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hmm, this looks stuck'), findsNothing);
  });

  testWidgets('with nothing to undo it suggests Restart, and keeps saying '
      'so while it slides out (review FIDELITY-6)', (tester) async {
    var restarts = 0;
    void restart() => restarts++;
    await pumpScreen(tester, _banner(visible: false, onRestart: restart));
    await pumpScreen(tester, _banner(visible: true, onRestart: restart));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Try Restart? You can keep playing too.'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    await tester.tap(find.text('Restart'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(restarts, 1);

    // The restart clears it; mid-way out, the copy and button still hold
    // even though an Undo now exists.
    await pumpScreen(
      tester,
      _banner(visible: false, onUndo: () {}, onRestart: restart),
    );
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Try Restart? You can keep playing too.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hmm, this looks stuck'), findsNothing);
  });

  testWidgets('with an Undo, Undo it is, even if Restart is offered too', (
    tester,
  ) async {
    await pumpScreen(tester, _banner(visible: false, onUndo: () {}));
    await pumpScreen(
      tester,
      _banner(visible: true, onUndo: () {}, onRestart: () {}),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Try Undo? You can keep playing too.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _banner(visible: true, onUndo: () {}),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final banner = tester.getRect(find.byType(SoftStuckBanner));
        expect(banner.left, 20);
        expect(banner.right, size.width - 20);
      });
    }
  }
}
