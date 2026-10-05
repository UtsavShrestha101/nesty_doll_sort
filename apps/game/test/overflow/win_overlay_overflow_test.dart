import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow", §11, §12): the win overlay
/// (frame 2.8) with its chapter card, its daily-streak card (frame 5.4),
/// its replay variant, its chest-countdown variant and its badge toasts, at
/// the five acceptance sizes and both text scales. Behaviour is covered by
/// `test/features/gameplay/overlays/win_overlay_test.dart` and
/// `win_chapter_card_test.dart`, which sweep `screenSizes`; this file
/// extends the same worst-case data (five families, a high reward) to the
/// wider M7 grid, and adds the M7 fields (`winMoves`, `bestMoves`,
/// `chestLevelsLeft`, `isReplay`, `newBadges`) `WinSummary` gained after the
/// contracts stage.
void main() {
  setUpAll(loadBundledFonts);

  const chapter = ChapterProgress(
    chapterId: 'ch03',
    number: 3,
    done: 16,
    total: 20,
    isFirstLevel: false,
  );

  const families = [
    DollColor.red,
    DollColor.blue,
    DollColor.green,
    DollColor.purple,
    DollColor.orange,
  ];

  Widget overlay({
    int? dailyStreak,
    bool dailyRelit = false,
    int? winMoves,
    int? bestMoves,
    int? chestLevelsLeft,
    bool isReplay = false,
    List<BadgeId> newBadges = const [],
    int? stars,
    bool starsNewBest = false,
    int? starTarget,
    bool starTip = false,
    bool starsCapped = false,
    int? bonusNumber,
    bool share = false,
  }) => WinOverlay(
    summary: WinSummary(
      reward: isReplay ? 0 : 1240,
      families: families,
      chapter: chapter,
      dailyStreak: dailyStreak,
      dailyRelit: dailyRelit,
      winMoves: winMoves,
      bestMoves: bestMoves,
      chestLevelsLeft: chestLevelsLeft,
      isReplay: isReplay,
      newBadges: newBadges,
      stars: stars,
      starsNewBest: starsNewBest,
      starTarget: starTarget,
      starTip: starTip,
      starsCapped: starsCapped,
      bonusNumber: bonusNumber,
      dailyDate: LocalDate(2026, 9, 26),
    ),
    share: share ? FakeShareService() : null,
    library: FakeFxLibrary(),
    onContinue: () {},
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'the chapter card fits ${size.width.toInt()}×${size.height.toInt()} '
        'at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            overlay(winMoves: 188, bestMoves: 12),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(seconds: 2));
          await expectAccessibleLayout(tester);
          expect(find.byType(WinChapterCard), findsOneWidget);
        },
      );

      testWidgets('the daily-streak card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(dailyStreak: 132),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        await expectAccessibleLayout(tester);
        expect(find.byType(DailyStreakCard), findsOneWidget);
      });

      testWidgets('the relit daily-streak card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(dailyStreak: 132, dailyRelit: true, winMoves: 24),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        await expectAccessibleLayout(tester);
      });

      testWidgets('the chest-countdown card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 24, bestMoves: 24, chestLevelsLeft: 3),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        await expectAccessibleLayout(tester);
      });

      testWidgets('the replay variant fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 24, bestMoves: 18, isReplay: true),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        await expectAccessibleLayout(tester);
      });

      testWidgets(
        'the badge toasts fit ${size.width.toInt()}×${size.height.toInt()} '
        'at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            overlay(
              winMoves: 24,
              bestMoves: 24,
              newBadges: const [BadgeId.firstFamily, BadgeId.tallOrder],
            ),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(seconds: 2));
          await expectAccessibleLayout(tester);
          // Lets both staggered `BadgeToast`s (900 ms + 350 ms apart) run
          // their own 3 s auto-dismiss and fade out, so no timer is left
          // pending at teardown.
          await tester.pump(const Duration(seconds: 6));
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets('a 3-star reveal, with its flourish, fits '
          '${size.width.toInt()}×${size.height.toInt()} at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 12, bestMoves: 12, stars: 3),
          size: size,
          textScale: scale,
        );
        // Past the reveal's own start (1,300 ms at 1×) and all three
        // stars' pops, plus the 3★ flourish's glow (600 ms) and settle.
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
      });

      testWidgets(
        'a replay\'s "New best!", target line and one-time tip all fit '
        '${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            overlay(
              winMoves: 12,
              bestMoves: 12,
              isReplay: true,
              stars: 2,
              starsNewBest: true,
              starTarget: 10,
              starTip: true,
            ),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(seconds: 3));
          await expectAccessibleLayout(tester);
        },
      );

      for (final stars in [1, 2, 3]) {
        testWidgets('a $stars★ campaign card fits ${size.width.toInt()}×'
            '${size.height.toInt()} at $scale× text', (tester) async {
          await pumpScreen(
            tester,
            overlay(winMoves: 13, bestMoves: 12, stars: stars),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(seconds: 4));
          await expectAccessibleLayout(tester);
        });
      }

      testWidgets('the helper note fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 13, stars: 2, starsCapped: true),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
        // Every height keeps the note now (m7-4 4.12: the card blends by
        // height, no 760 switch).
        expect(find.byKey(WinOverlay.noteKey), findsOneWidget);
      });

      testWidgets('the one-time tip fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 13, stars: 2, starTip: true),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
      });

      testWidgets('the Bonus Endless card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(winMoves: 18, bonusNumber: 7, chestLevelsLeft: 3),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
      });

      testWidgets('the daily card with Share fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(dailyStreak: 5, winMoves: 18, share: true),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
        expect(find.byKey(WinOverlay.shareKey), findsOneWidget);
      });

      testWidgets('the tallest replay card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          overlay(
            winMoves: 18,
            bestMoves: 16,
            isReplay: true,
            stars: 2,
            starsNewBest: true,
            starTarget: 15,
            starTip: true,
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 3));
        await expectAccessibleLayout(tester);
        // The button keeps its 48 dp even where the card scales down.
        final button = tester.getRect(
          find.widgetWithText(TactileButton, testL10n.winBackToChapters),
        );
        expect(button.height, greaterThanOrEqualTo(48));
        expect(button.bottom, lessThanOrEqualTo(size.height));
      });
    }
  }
}
