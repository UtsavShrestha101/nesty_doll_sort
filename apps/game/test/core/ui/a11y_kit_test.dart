import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// The UI kit's screen-reader nodes and 48 dp targets (spec §10.3 "Tap
/// targets are at least 48 dp", §16; m7-design §15 "nothing is narrower
/// than a 48 dp target"): the M7 review's round-2 accessibility audit
/// (R13, R16, R17, R19, R21, R24, R25) and the two tools its fixes use,
/// `TactileSurface.minTouchSize` and `TouchSlop`.
void main() {
  setUpAll(loadBundledFonts);

  /// The screen-reader node's size for [finder] (its own or the nearest
  /// one above it).
  Size nodeSize(WidgetTester tester, Finder finder) =>
      tester.getSemantics(finder).rect.size;

  group('labels read once (R13)', () {
    testWidgets('a segmented tab is "Coins", not "Coins Coins"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        NestySegmentedTabs(
          labels: const ['Coins', 'Skins'],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      expect(find.bySemanticsLabel(RegExp(r'^Coins$')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Skins$')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a bottom nav item is "Shop", not "Shop Shop"', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        NestyBottomNav(
          items: const [
            NestyBottomNavItem(icon: NestyIcons.storefront, label: 'Shop'),
            NestyBottomNavItem(icon: NestyIcons.home, label: 'Home'),
          ],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      );
      expect(find.bySemanticsLabel(RegExp(r'^Shop$')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Home$')), findsOneWidget);
      handle.dispose();
    });
  });

  group('48 dp targets', () {
    testWidgets('segmented tabs: each segment answers across 48 dp around '
        'the 46 px track (R19)', (tester) async {
      final handle = tester.ensureSemantics();
      var selected = 0;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NestySegmentedTabs(
            labels: const ['Coins', 'Skins'],
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
        feedback: RecordingFeedback(),
      );
      expect(
        tester.getSize(find.byType(NestySegmentedTabs)).height,
        NestySegmentedTabs.touchHeight,
      );
      expect(
        nodeSize(tester, find.bySemanticsLabel('Skins')).height,
        greaterThanOrEqualTo(48),
      );
      // Inside the 48 dp row, above the 46 px track.
      final box = tester.getRect(find.byType(NestySegmentedTabs));
      await tester.tapAt(Offset(box.left + box.width * 0.75, box.top + 0.5));
      await tester.pumpAndSettle();
      expect(selected, 1, reason: 'the top pixel row is part of the target');
      handle.dispose();
    });

    testWidgets("NestyCloseButton's node is its 48 dp target, not the 36 px "
        'circle (R24)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(tester, Center(child: NestyCloseButton(onPressed: () {})));
      expect(
        nodeSize(tester, find.bySemanticsLabel('Close')),
        const Size(48, 48),
      );
      handle.dispose();
    });

    testWidgets("ScreenHeader's 46 px back button is a 48 dp target (R17)", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var backs = 0;
      await pumpUi(
        tester,
        ScreenHeader(title: 'Daily Puzzle', onBack: () => backs++),
        feedback: RecordingFeedback(),
      );
      expect(
        nodeSize(tester, find.bySemanticsLabel('Back')),
        const Size(48, 48),
      );
      final button = tester.getRect(find.byType(IconTactileButton));
      // A touch in the target's margin, outside the 46 px face.
      await tester.tapAt(button.topLeft + const Offset(0.5, 0.5));
      await tester.pumpAndSettle();
      expect(backs, 1);
      handle.dispose();
    });

    testWidgets('SettingsRow is at least 48 dp tall (R21)', (tester) async {
      await pumpUi(
        tester,
        SettingsRow(
          icon: NestyIcons.bolt,
          label: 'Reduce motion',
          onTap: () {},
        ),
      );
      expect(
        tester.getSize(find.byType(SettingsRow)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('a compact TactileButton with minTouchSize keeps its 38 px '
        'face in a 48 dp node that answers in its margin', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpUi(
        tester,
        Center(
          child: TactileButton(
            label: 'Undo',
            size: TactileButtonSize.compact,
            expand: false,
            minTouchSize: const Size.square(48),
            onPressed: () => taps++,
          ),
        ),
        feedback: RecordingFeedback(),
      );
      final box = tester.getRect(find.byType(TactileButton));
      expect(box.height, 48);
      expect(nodeSize(tester, find.bySemanticsLabel('Undo')).height, 48);
      await tester.tapAt(box.topCenter + const Offset(0, 1));
      await tester.pumpAndSettle();
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('TouchSlop: a 30 px control answers, and reads, across '
        '48 dp without growing its box', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpUi(
        tester,
        Center(
          child: SizedBox(
            width: 200,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TouchSlop(
                  child: TactileSurface(
                    style: SurfaceStyles.raised,
                    radius: BorderRadius.circular(12),
                    height: 30,
                    width: double.infinity,
                    onPressed: () => taps++,
                    child: const Text('Use'),
                  ),
                ),
              ],
            ),
          ),
        ),
        feedback: RecordingFeedback(),
      );
      final face = tester.getRect(find.byType(TouchSlop));
      expect(face.height, 30, reason: 'the layout box is the face');
      // Its node takes the control's own over (merged into it).
      final node = tester.getSemantics(find.text('Use'));
      final data = node.getSemanticsData();
      expect(node.rect.height, 48);
      expect(data.label, 'Use');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await tester.tapAt(face.topCenter - const Offset(0, 8));
      await tester.pumpAndSettle();
      expect(taps, 1, reason: '8 px above the face is inside the 48 dp area');
      await tester.tapAt(face.topCenter - const Offset(0, 12));
      await tester.pumpAndSettle();
      expect(taps, 1, reason: '12 px above is outside it');
      handle.dispose();
    });
  });

  group('selected state (R16)', () {
    testWidgets('a SheetRow says which choice is active', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        Column(
          children: [
            SheetRow(
              icon: NestyIcons.bolt,
              title: 'System',
              selected: true,
              onTap: () {},
            ),
            SheetRow(
              icon: NestyIcons.bolt,
              title: 'On',
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.text('System')).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        tester.getSemantics(find.text('On')).flagsCollection.isSelected,
        Tristate.isFalse,
      );
      handle.dispose();
    });
  });

  group('text scales down instead of being cut', () {
    bool isCut(WidgetTester tester, Finder text) {
      final paragraph = tester.renderObject<RenderParagraph>(text);
      final wide = paragraph.getMaxIntrinsicWidth(double.infinity);
      return paragraph.didExceedMaxLines ||
          (paragraph.maxLines == 1 && wide > paragraph.size.width + 0.5);
    }

    testWidgets('ShrinkToFitText: a badge name fits 2 lines of a 65 dp cell '
        'at 1.3× (R25)', (tester) async {
      await pumpUi(
        tester,
        Center(
          child: SizedBox(
            width: 65,
            child: ShrinkToFitText(
              'Every Rival Beaten',
              style: AppTextStyleTokens.caption.copyWith(
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ),
        ),
        width: 360,
        height: 640,
        textScale: 1.3,
      );
      expect(isCut(tester, find.text('Every Rival Beaten')), isFalse);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Every Rival Beaten'),
      );
      // No word is broken across lines either.
      for (final word in ['Every', 'Rival', 'Beaten']) {
        final painter = TextPainter(
          text: TextSpan(text: word, style: paragraph.text.style),
          textDirection: TextDirection.ltr,
          textScaler: paragraph.textScaler,
        )..layout();
        expect(painter.width, lessThanOrEqualTo(65));
        painter.dispose();
      }
    });

    testWidgets('ShrinkToFitText keeps its size when it fits', (tester) async {
      final style = AppTextStyleTokens.caption.copyWith(fontSize: 11);
      await pumpUi(
        tester,
        Center(
          child: SizedBox(
            width: 200,
            child: ShrinkToFitText('First Family', style: style),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('First Family'));
      expect(text.style!.fontSize, 11);
    });

    testWidgets('ScreenHeader: "Chapters" at 1.3× on 360 dp scales down, '
        'never "Chapte…" (R29)', (tester) async {
      await pumpUi(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ScreenHeader(title: 'Chapters', onBack: () {}, coins: 1234567),
        ),
        width: 360,
        height: 640,
        textScale: 1.3,
      );
      expect(isCut(tester, find.text('Chapters')), isFalse);
    });
  });
}
