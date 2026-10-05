import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/spinner_pulse.dart';
import 'package:nesty_game/features/gameplay/widgets/generating_overlay.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// "Setting up the shelves…" while a generated request resolves (frame
/// 12.5; `layout.generating`): the dim, the 236-wide card at top 360, the
/// spinner and the line, touches absorbed but Pause reachable, and one busy
/// live node.
void main() {
  setUpAll(loadBundledFonts);

  /// A Pause stand-in under the overlay, in the HUD's corner, and a board
  /// button under it.
  Widget stage(void Function(String) tapped, {Widget? overlay}) => Scaffold(
    body: Stack(
      children: [
        Positioned(
          left: 16,
          top: 66,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => tapped('pause'),
            child: const ColoredBox(color: Color(0xFFFF0000)),
          ),
        ),
        Positioned(
          left: 100,
          top: 400,
          width: 100,
          height: 60,
          child: GestureDetector(
            onTap: () => tapped('board'),
            child: const ColoredBox(color: Color(0xFF00FF00)),
          ),
        ),
        overlay ?? GeneratingOverlay(library: FakeFxLibrary()),
      ],
    ),
  );

  testWidgets('the card: 236 wide, top 360 of the design, centred, with the '
      'line and no number', (tester) async {
    await pumpScreen(tester, stage((_) {}));
    await tester.pump();
    final card = tester.getRect(find.byKey(GeneratingOverlay.cardKey));
    expect(card.width, 236);
    expect(card.top, closeTo(360, 0.5));
    expect(card.center.dx, closeTo(195, 0.5));
    expect(find.text('Setting up the shelves…'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
      reason: 'the fallback ring while ui_spinner is missing (rule 3)',
    );
  });

  testWidgets('it absorbs touches on the board but not on Pause', (
    tester,
  ) async {
    final taps = <String>[];
    await pumpScreen(tester, stage(taps.add));
    await tester.tap(find.byType(GestureDetector).at(1), warnIfMissed: false);
    await tester.tap(find.byType(GestureDetector).first);
    expect(taps, ['pause']);
  });

  testWidgets('one live, busy node with the line', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, stage((_) {}));
    final node = tester.getSemantics(
      find.bySemanticsLabel('Setting up the shelves…'),
    );
    expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpScreen(
          tester,
          Scaffold(
            body: Stack(
              children: [GeneratingOverlay(library: FakeFxLibrary())],
            ),
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump();
        expectNoLayoutErrors(tester);
        expectNoCutText(tester);
      });
    }
  }

  testWidgets('reduced motion (12.5, motion.spinner): frame 0 and the opacity '
      'pulses 1 -> 0.45 -> 1 over 1,600 ms, looping', (tester) async {
    await pumpScreen(tester, stage((_) {}), reduceMotion: true);
    double opacity() => tester
        .widget<FadeTransition>(
          find.descendant(
            of: find.byType(SpinnerPulse),
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity
        .value;
    await tester.pump();
    expect(opacity(), closeTo(1, 0.01));
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity(), closeTo(0.45, 0.02), reason: 'the low at half a turn');
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity(), closeTo(1, 0.02), reason: 'back up at 1,600 ms');
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity(), closeTo(0.45, 0.02), reason: 'and it loops');
  });

  testWidgets('with motion allowed there is no pulse', (tester) async {
    await pumpScreen(tester, stage((_) {}));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(SpinnerPulse),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });
}
