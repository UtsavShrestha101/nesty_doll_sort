import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

const _midChapter = ChapterProgress(
  chapterId: 'ch03',
  number: 3,
  done: 16,
  total: 20,
  isFirstLevel: false,
);

const _lastLevel = ChapterProgress(
  chapterId: 'ch01',
  number: 1,
  done: 20,
  total: 20,
  isFirstLevel: false,
);

void main() {
  setUpAll(loadBundledFonts);

  group('WinChapterCard (frame 2.8)', () {
    testWidgets('"Chapter N", the progress bar and "Next up: <figurine>"', (
      tester,
    ) async {
      await pumpScreen(tester, const WinChapterCard(progress: _midChapter));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Chapter 3'), findsOneWidget);
      expect(find.text('16 / 20'), findsOneWidget);
      expect(find.text('Next up: The Baker Family'), findsOneWidget);
    });

    testWidgets('the chapter\'s last level: "Chapter complete!" instead of '
        '"Next up"', (tester) async {
      await pumpScreen(tester, const WinChapterCard(progress: _lastLevel));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Chapter complete! Your prize is next.'),
        findsOneWidget,
      );
      expect(find.textContaining('Next up:'), findsNothing);
    });

    for (final size in screenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            const WinChapterCard(progress: _midChapter),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 300));
          expectNoLayoutErrors(tester);
        });
      }
    }
  });

  group('DailyStreakCard, the win overlay\'s daily variant (frame 5.4)', () {
    testWidgets('"{N}-day streak" and the Day 7 chest hint', (tester) async {
      await pumpScreen(tester, const DailyStreakCard(streak: 5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('5-day streak'), findsOneWidget);
      expect(find.text('Two more days to the Day 7 chest'), findsOneWidget);
    });

    testWidgets('a 1-day streak', (tester) async {
      await pumpScreen(tester, const DailyStreakCard(streak: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1-day streak'), findsOneWidget);
      expect(find.text('Six more days to the Day 7 chest'), findsOneWidget);
    });

    testWidgets('day 7 itself: "Your Day 7 chest is ready!"', (tester) async {
      await pumpScreen(tester, const DailyStreakCard(streak: 7));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('7-day streak'), findsOneWidget);
      expect(find.text('Your Day 7 chest is ready!'), findsOneWidget);
    });

    for (final size in screenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            const DailyStreakCard(streak: 3),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 300));
          expectNoLayoutErrors(tester);
        });
      }
    }
  });
}
