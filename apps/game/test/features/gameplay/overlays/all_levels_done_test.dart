import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

void main() {
  setUpAll(loadBundledFonts);

  const families = [
    DollColor.red,
    DollColor.yellow,
    DollColor.green,
    DollColor.blue,
    DollColor.purple,
    DollColor.pink,
  ];

  testWidgets('frame 4.9 copy, five hopping dolls, Back to Home', (
    tester,
  ) async {
    var home = 0;
    await pumpScreen(
      tester,
      AllLevelsDone(
        families: families,
        library: FakeFxLibrary(),
        onHome: () => home++,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("You've finished all levels!"), findsOneWidget);
    expect(
      find.text('New chapters are coming — play bonus levels meanwhile.'),
      findsOneWidget,
    );
    expect(find.byType(LottieDoll), findsNWidgets(5));
    // Bonus Endless is M3.
    expect(find.textContaining('Bonus'), findsNothing);
    await tester.tap(find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(home, 1);
  });

  // Review FIDELITY-11: NestyOverlay isBonus has one call to action, the
  // teal button, and "Back to Home" as a quiet Fredoka 16/700 #8A5B3A text
  // 16 below it, not a second button.
  testWidgets('with a bonus level: the teal button, and Back to Home as a '
      'text link 16 below it with a 48 dp touch area', (tester) async {
    var home = 0;
    var bonus = 0;
    await pumpScreen(
      tester,
      AllLevelsDone(
        families: families,
        library: FakeFxLibrary(),
        onHome: () => home++,
        bonusNumber: 1,
        onPlayBonus: () => bonus++,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final teal = find.widgetWithText(TactileButton, 'Play Bonus Level 1');
    expect(teal, findsOneWidget);
    expect(find.byType(TactileButton), findsOneWidget, reason: 'one button');

    final link = find.text('Back to Home');
    final style = tester.widget<Text>(link).style!;
    expect(style.fontFamily, 'Fredoka');
    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, AppColorTokens.textSecondary);
    expect(
      tester.getTopLeft(link).dy - tester.getBottomLeft(teal).dy,
      closeTo(16, 0.5),
    );
    final target = find.ancestor(of: link, matching: find.byType(TouchTarget));
    expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(target).width, greaterThanOrEqualTo(48));

    // The link's text bottom sits the card's 22 padding above its bottom.
    final card = find.byType(ModalCard);
    expect(
      tester.getBottomLeft(card).dy - tester.getBottomLeft(link).dy,
      closeTo(22, 0.5),
    );

    await tester.tap(link);
    await tester.pump(const Duration(milliseconds: 200));
    expect(home, 1);
    await tester.tap(teal);
    await tester.pump(const Duration(milliseconds: 200));
    expect(bonus, 1);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          AllLevelsDone(
            families: families,
            library: FakeFxLibrary(),
            onHome: () {},
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
      });
    }
  }
}
