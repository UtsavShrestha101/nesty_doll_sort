import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
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

    testWidgets('the chest line (C2, frame 10.3): the bar and count stay '
        "the chapter's; only the next line and the tile change", (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const WinChapterCard(progress: _midChapter, chestLevelsLeft: 3),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Chapter 3'), findsOneWidget);
      expect(find.text('16 / 20'), findsOneWidget);
      expect(find.text('3 levels to the chest'), findsOneWidget);
      expect(find.textContaining('Next up:'), findsNothing);
      // The closed chest's art in the tile (78 % of 62).
      final art = tester.widget<UiArtImage>(find.byType(UiArtImage));
      expect(art.art, UiArt.chestClosed);
      expect(art.size.width, closeTo(62 * 0.78, 0.01));
      final bar = tester.widget<NestyProgressBar>(
        find.byType(NestyProgressBar),
      );
      expect(bar.value, closeTo(_midChapter.fraction, 0.0001));
    });

    testWidgets('Bonus Endless (frame 12.4): the bonus label, the 10-level '
        'cycle for both count and bar, the chest line', (tester) async {
      await pumpScreen(
        tester,
        const WinChapterCard(
          progress: _midChapter,
          bonusNumber: 7,
          chestLevelsLeft: 3,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Bonus Level 7'), findsOneWidget);
      expect(find.text('7 / 10'), findsOneWidget);
      expect(find.text('3 levels to the chest'), findsOneWidget);
      final bar = tester.widget<NestyProgressBar>(
        find.byType(NestyProgressBar),
      );
      expect(bar.value, closeTo(0.7, 0.0001));
    });

    test('a bonus level\'s place in the cycle: 1–10', () {
      expect(
        [
          for (final n in [1, 9, 10, 11, 20]) WinChapterCard.bonusPosition(n),
        ],
        [1, 9, 10, 1, 10],
      );
    });

    testWidgets('the chest that just opened (levels left = 10): no countdown '
        'line', (tester) async {
      await pumpScreen(
        tester,
        const WinChapterCard(
          progress: _midChapter,
          bonusNumber: 10,
          chestLevelsLeft: 10,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('10 / 10'), findsOneWidget);
      expect(find.textContaining('levels to the chest'), findsNothing);
    });

    testWidgets('the chest line is never cut at 1.3× on a narrow card '
        '(review R26)', (tester) async {
      await pumpScreen(
        tester,
        const WinChapterCard(progress: _midChapter, chestLevelsLeft: 9),
        size: const Size(360, 640),
        textScale: 1.3,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('9 levels to the chest'), findsOneWidget);
      expectNoCutText(tester);
    });

    testWidgets('a replay hides "Next up" but keeps the figurine tile', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const WinChapterCard(progress: _midChapter, isReplay: true),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Next up:'), findsNothing);
      expect(find.byType(UiArtImage), findsNothing);
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

  group('ReplayReasonCard (frames 10.5, 11.4–11.4b)', () {
    testWidgets('the reason, and no target at 3 stars', (tester) async {
      await pumpScreen(tester, const ReplayReasonCard());
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('A replay for fun: coins come from new levels.'),
        findsOneWidget,
      );
      expect(find.textContaining('3 stars at'), findsNothing);
    });

    testWidgets('below 3 stars a target row with the empty star art (Q118)', (
      tester,
    ) async {
      await pumpScreen(tester, const ReplayReasonCard(starTarget: 15));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('3 stars at 15 moves or fewer'), findsOneWidget);
      final art = tester.widget<UiArtImage>(find.byType(UiArtImage));
      expect(art.art, UiArt.starEmpty);
      expect(art.size, const Size(22, 22));
    });

    testWidgets('the reason and the target are one screen-reader node each', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const ReplayReasonCard(starTarget: 15));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.bySemanticsLabel('A replay for fun: coins come from new levels.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('3 stars at 15 moves or fewer'),
        findsOneWidget,
      );
      handle.dispose();
    });

    for (final size in screenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            const ReplayReasonCard(starTarget: 15),
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

    testWidgets('relit (E2; m7-design §8, §15.7): "Streak relit!" and its '
        'body instead of the count and the chest hint', (tester) async {
      await pumpScreen(tester, const DailyStreakCard(streak: 13, relit: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Streak relit!'), findsOneWidget);
      expect(find.text('Your 13-day streak is glowing again.'), findsOneWidget);
      expect(find.text('13-day streak'), findsNothing);
      expect(find.textContaining('Day 7 chest'), findsNothing);
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
