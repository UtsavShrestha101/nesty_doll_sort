import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/stars_chip.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';

import '../../features/support/screen_harness.dart';
import 'support/ui_harness.dart';

/// The menu widgets phase 4 adds (menus spec 0.2, 0.5): the stars chip and
/// the text link.
void main() {
  setUpAll(loadBundledFonts);

  group('StarsChip', () {
    testWidgets('reads "39/60" beside an 18 dp star, 28 tall by default', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const Center(child: StarsChip(earned: 39, total: 60)),
      );
      expect(find.text('39/60'), findsOneWidget);
      expect(tester.getSize(find.byType(StarsChip)).height, 28);
      final star = tester.widget<UiArtImage>(find.byType(UiArtImage));
      expect(star.art, UiArt.starFilled);
      expect(star.size, const Size(18, 18));
      final text = tester.widget<Text>(find.text('39/60'));
      expect(text.style!.fontSize, 14);
    });

    testWidgets('Home\'s chip is 30 tall with a 20 dp star and Fredoka 15 '
        '(NestyHub:25)', (tester) async {
      await pumpUi(
        tester,
        const Center(
          child: StarsChip(earned: 3, total: 60, height: StarsChip.homeHeight),
        ),
      );
      expect(tester.getSize(find.byType(StarsChip)).height, 30);
      final star = tester.widget<UiArtImage>(find.byType(UiArtImage));
      expect(star.size, const Size(20, 20));
      expect(tester.widget<Text>(find.text('3/60')).style!.fontSize, 15);
    });

    testWidgets('`all` (Bonus Endless chip, frame 12.2) reads the campaign '
        'total', (tester) async {
      await pumpUi(
        tester,
        const Center(child: StarsChip(earned: 120, total: 600, all: true)),
      );
      expect(find.text('120/600'), findsOneWidget);
    });

    testWidgets('is one node: "39 of 60 stars"', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        const Center(child: StarsChip(earned: 39, total: 60)),
      );
      expect(find.bySemanticsLabel('39 of 60 stars'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('perfect swaps the sand line for the gold one and adds the '
        'ring', (tester) async {
      NestySurface surface() =>
          tester.widget<NestySurface>(find.byType(NestySurface));
      await pumpUi(
        tester,
        const Center(child: StarsChip(earned: 60, total: 60)),
      );
      expect(surface().style.shadows, hasLength(1));
      expect(surface().style.shadows.single.color, AppColorTokens.surfaceTrack);

      await pumpUi(
        tester,
        const Center(child: StarsChip(earned: 60, total: 60, perfect: true)),
      );
      final shadows = surface().style.shadows;
      expect(shadows, hasLength(2));
      expect(shadows.first.color, ChaptersTokens.perfectChipInset.color);
      expect(shadows.first.inset, isTrue);
      expect(shadows.last.color, ChaptersTokens.perfectChipRing.color);
      expect(shadows.last.spread, 3);
    });
  });

  group('TextLink', () {
    Future<void> pumpLink(
      WidgetTester tester, {
      VoidCallback? onPressed,
      bool accent = false,
      RecordingFeedback? feedback,
    }) => pumpUi(
      tester,
      Center(
        child: TextLink(label: 'Not now', onPressed: onPressed, accent: accent),
      ),
      feedback: feedback,
    );

    testWidgets('the face is 36 tall and the touch target 48 dp', (
      tester,
    ) async {
      await pumpLink(tester, onPressed: () {});
      final target = tester.getSize(
        find.ancestor(
          of: find.text('Not now'),
          matching: find.byType(TouchTarget),
        ),
      );
      expect(target.height, 48);
      expect(target.width, greaterThanOrEqualTo(48));
      final text = tester.widget<Text>(find.text('Not now'));
      expect(text.style!.fontSize, 16);
      expect(text.style!.color, AppColorTokens.textSecondary);
      expect(text.style!.decoration, isNot(TextDecoration.underline));
    });

    testWidgets('a tap in the margin above the face still presses it, with '
        'the button sound and haptic', (tester) async {
      var taps = 0;
      final feedback = RecordingFeedback();
      await pumpLink(tester, onPressed: () => taps++, feedback: feedback);
      final box = tester.getRect(find.text('Not now'));
      await tester.tapAt(box.topCenter - const Offset(0, 11));
      expect(taps, 1);
      expect(feedback.activations, 1);
    });

    testWidgets('pressed, it takes #6E4526; released, it goes back', (
      tester,
    ) async {
      await pumpLink(tester, onPressed: () {});
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Not now')),
      );
      await tester.pump();
      expect(
        tester.widget<Text>(find.text('Not now')).style!.color,
        TextLinkTokens.pressed,
      );
      await gesture.up();
      await tester.pump();
      expect(
        tester.widget<Text>(find.text('Not now')).style!.color,
        AppColorTokens.textSecondary,
      );
    });

    testWidgets('the accent sibling is orange', (tester) async {
      await pumpLink(tester, onPressed: () {}, accent: true);
      expect(
        tester.widget<Text>(find.text('Not now')).style!.color,
        AppColorTokens.primaryEdge,
      );
    });

    testWidgets('disabled it does nothing and reads as disabled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final feedback = RecordingFeedback();
      await pumpLink(tester, feedback: feedback);
      await tester.tap(find.text('Not now'));
      expect(feedback.activations, 0);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Not now'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      handle.dispose();
    });

    testWidgets('is one button node with its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLink(tester, onPressed: () {});
      final node = tester.getSemantics(find.bySemanticsLabel('Not now'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
            '$scale× text', (tester) async {
          await pumpScreen(
            tester,
            Material(
              child: Center(
                child: TextLink(label: 'Not now', onPressed: () {}),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
        });
      }
    }
  });
}
