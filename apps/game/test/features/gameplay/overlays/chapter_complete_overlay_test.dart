import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

Widget _overlay({
  int chapterNumber = 1,
  String chapterName = 'Sunny Toy Shop',
  String figurineId = 'classic',
  int coins = 150,
  String? nextLine = 'Next: Chapter 2 · Rainy Café Corner',
  VoidCallback? onContinue,
}) => ChapterCompleteOverlay(
  chapterNumber: chapterNumber,
  chapterName: chapterName,
  figurineId: figurineId,
  coins: coins,
  nextLine: nextLine,
  onContinue: onContinue ?? () {},
);

void main() {
  setUpAll(loadBundledFonts);

  // Review FIDELITY-1: NestyOverlay isChapter's 34 px line under "CHAPTER 3
  // COMPLETE" is the figurine just earned ("The Baker Family"), not the
  // chapter's name.
  testWidgets("frame 4.6: the title, the figurine's name, the museum line, "
      'the coins and the next-chapter line', (tester) async {
    await pumpScreen(tester, _overlay());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CHAPTER 1 COMPLETE'), findsOneWidget);
    expect(find.text('The Classic Family'), findsOneWidget);
    expect(find.text('Sunny Toy Shop'), findsNothing);
    expect(find.text('Added to your Museum!'), findsOneWidget);
    expect(find.text('+150 coins'), findsOneWidget);
    expect(find.text('Next: Chapter 2 · Rainy Café Corner'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('frame 4.6 for chapter 3 names the Baker Family', (tester) async {
    await pumpScreen(
      tester,
      _overlay(
        chapterNumber: 3,
        chapterName: 'Sweet Bakery',
        figurineId: 'baker',
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CHAPTER 3 COMPLETE'), findsOneWidget);
    expect(find.text('The Baker Family'), findsOneWidget);
  });

  testWidgets('a figurine with no name yet falls back to the chapter name', (
    tester,
  ) async {
    await pumpScreen(tester, _overlay(figurineId: 'unnamed'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sunny Toy Shop'), findsOneWidget);
  });

  testWidgets('past the last catalog chapter: no next-chapter line', (
    tester,
  ) async {
    await pumpScreen(tester, _overlay(nextLine: null));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Next:'), findsNothing);
  });

  testWidgets('Continue calls back', (tester) async {
    var continued = 0;
    await pumpScreen(tester, _overlay(onContinue: () => continued++));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(continued, 1);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(tester, _overlay(), size: size, textScale: scale);
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        expect(find.text('CHAPTER 1 COMPLETE'), findsOneWidget);
      });
    }
  }
}
