import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/overlays/past_day_win_card.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/win_result_chips.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/screen_harness.dart';

const _chapter = ChapterProgress(
  chapterId: 'ch03',
  number: 3,
  done: 16,
  total: 20,
  isFirstLevel: false,
);

Widget _overlay({
  int reward = 25,
  List<DollColor> families = const [
    DollColor.red,
    DollColor.blue,
    DollColor.green,
    DollColor.purple,
  ],
  ChapterProgress chapter = _chapter,
  RecordingCues? feedback,
  VoidCallback? onContinue,
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
  LocalDate? dailyDate,
  LocalDate? pastDate,
  ShareService? share,
  VoidCallback? onTipShown,
}) => WinOverlay(
  summary: WinSummary(
    reward: reward,
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
    dailyDate: dailyDate,
    pastDate: pastDate,
  ),
  share: share,
  onTipShown: onTipShown,
  feedback: feedback,
  library: FakeFxLibrary(),
  onContinue: onContinue ?? () {},
);

final _long = DateFormat('EEEEdMMMM', 'en').format(DateTime(2026, 10, 10));

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('frame 2.8: ribbon, families, "+N", chapter card, Continue', (
    tester,
  ) async {
    await pumpScreen(tester, _overlay());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
    expect(find.byType(LottieDoll), findsNWidgets(4));
    expect(find.text('Chapter 3'), findsOneWidget);
    expect(find.text('16 / 20'), findsOneWidget);
    expect(find.text('Next up: The Baker Family'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // The ×3 video is M6: hidden, as offline.
    expect(find.text('×3 coins'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the coins count up from 700 ms with the coins cue', (
    tester,
  ) async {
    final feedback = RecordingCues();
    await pumpScreen(tester, _overlay(feedback: feedback));
    // win + its haptic at the open (LOTTIE.md "Win overlay").
    expect(feedback.played.single.sound, SoundEffect.win);
    expect(feedback.played.single.haptic, HapticPattern.win);
    expect(find.text('+0'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 699));
    expect(find.text('+0'), findsOneWidget);
    expect(feedback.played, hasLength(1));

    await tester.pump(const Duration(milliseconds: 2));
    expect(feedback.played.last.sound, SoundEffect.coins);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('+25'), findsOneWidget);
    expect(find.bySemanticsLabel('25 coins'), findsOneWidget);
  });

  testWidgets('reduced motion halves the schedule (D48)', (tester) async {
    final feedback = RecordingCues();
    await pumpScreen(tester, _overlay(feedback: feedback), reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 351));
    expect(feedback.played.last.sound, SoundEffect.coins);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('+25'), findsOneWidget);
  });

  testWidgets('Continue calls back', (tester) async {
    var continued = 0;
    await pumpScreen(tester, _overlay(onContinue: () => continued++));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(continued, 1);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the last level of a chapter says the prize is next', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _overlay(
        chapter: const ChapterProgress(
          chapterId: 'ch01',
          number: 1,
          done: 20,
          total: 20,
          isFirstLevel: false,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chapter complete! Your prize is next.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  group('the moves caption (E7; m7-design §11, §15.3)', () {
    testWidgets('a kept best: "Moves N · Best M"', (tester) async {
      await pumpScreen(tester, _overlay(winMoves: 18, bestMoves: 16));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Moves 18 · Best 16'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('no kept best (daily, bonus, race): "Moves N" alone', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay(winMoves: 9));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Moves 9'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('neither set (an older caller): no caption at all', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay());
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Moves'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  // Frame 14.3d: a past day's win pays nothing and moves nothing.
  group('a past day (frame 14.3d)', () {
    testWidgets('its title, Moves, the date card and Back to Daily; no coins, '
        'streak, Share or ×3', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(
        tester,
        _overlay(
          reward: 0,
          pastDate: LocalDate(2026, 10, 10),
          winMoves: 18,
          share: FakeShareService(),
          feedback: feedback,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.bySemanticsLabel('Puzzle solved!'), findsOneWidget);
      expect(find.text('Moves 18'), findsOneWidget);
      expect(find.byType(PastDayWinCard), findsOneWidget);
      expect(find.text(_long), findsOneWidget);
      expect(find.text('Played later, just for fun.'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Back to Daily'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.text('Share'), findsNothing);
      expect(find.textContaining('+'), findsNothing);
      expect(find.byType(DailyStreakCard), findsNothing);
      expect(find.byType(WinChapterCard), findsNothing);
      expect(find.byType(WinCoinPill), findsNothing);
      // Only the open's `win` cue: never `coins` (nothing is paid).
      expect(feedback.played, hasLength(1));
      expect(feedback.played.single.sound, SoundEffect.win);
    });

    testWidgets('the screen reader hears one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        _overlay(reward: 0, pastDate: LocalDate(2026, 10, 10), winMoves: 18),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.bySemanticsLabel(
          '$_long solved in 18 moves. Played later, just for fun.',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('a replay (E7; m7-design §6, §11)', () {
    testWidgets('no coin pill, count-up or coins sound; the reason line; '
        '"Back to Chapters"', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(
        tester,
        _overlay(
          isReplay: true,
          winMoves: 12,
          bestMoves: 9,
          feedback: feedback,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('+'), findsNothing);
      expect(
        find.text('A replay for fun: coins come from new levels.'),
        findsOneWidget,
      );
      expect(find.text('Moves 12 · Best 9'), findsOneWidget);
      expect(find.text('Back to Chapters'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      // Only the open's `win` cue: never `coins` (no reward to count up).
      expect(feedback.played, hasLength(1));
      expect(feedback.played.single.sound, SoundEffect.win);
    });

    // Frame 11.4: the reason sits in its own cream card under the moves
    // chip, and no coin chip shows.
    testWidgets('the reason is a cream card under the moves chip, with no '
        'coin chip', (tester) async {
      await pumpScreen(
        tester,
        _overlay(isReplay: true, stars: 2, winMoves: 18, bestMoves: 16),
      );
      await tester.pump(const Duration(seconds: 2));
      final reason = find.text('A replay for fun: coins come from new levels.');
      expect(
        find.ancestor(of: reason, matching: find.byType(ReplayReasonCard)),
        findsOneWidget,
      );
      expect(find.byType(WinCoinPill), findsNothing);
      expect(
        tester.getBottomLeft(find.byType(WinMovesChip)).dy,
        lessThan(tester.getTopLeft(find.byType(ReplayReasonCard)).dy),
      );
      expect(
        tester.getTopLeft(find.byType(StarRow)).dy,
        lessThan(tester.getTopLeft(find.byType(WinMovesChip)).dy),
      );
    });

    testWidgets('below 3 stars the target row shows; at 3 it does not', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _overlay(isReplay: true, stars: 2, starTarget: 15),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('3 stars at 15 moves or fewer'), findsOneWidget);
      await pumpScreen(tester, _overlay(isReplay: true, stars: 3));
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('3 stars at'), findsNothing);
    });

    testWidgets('a new best puts "New best!" on the moves chip', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _overlay(
          isReplay: true,
          stars: 3,
          starsNewBest: true,
          winMoves: 12,
          bestMoves: 12,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      final chip = tester.getRect(find.byType(WinMovesChip));
      final best = tester.getRect(find.byKey(WinMovesChip.newBestKey));
      expect(find.text('New best!'), findsOneWidget);
      expect(best.center.dx, closeTo(chip.center.dx, 0.5));
      expect(best.top, lessThan(chip.top), reason: 'on its top edge');
      expect(find.bySemanticsLabel('New best, 3 of 3 stars'), findsOneWidget);
    });

    testWidgets('the chapter card hides "Next up" even on a mid-chapter '
        'level', (tester) async {
      await pumpScreen(tester, _overlay(isReplay: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Next up:'), findsNothing);
    });
  });

  group('badge toasts (E8; m7-design §12)', () {
    testWidgets('one per newBadges, staggered, after the overlay opens', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _overlay(newBadges: const [BadgeId.firstFamily, BadgeId.glassBreaker]),
      );
      // copy.md G.8: "Badge earned · {name}", then the badge's line.
      await tester.pump(const Duration(milliseconds: 899));
      expect(find.textContaining('Badge earned'), findsNothing);
      await tester.pump(const Duration(milliseconds: 2));
      expect(find.text('Badge earned · Snug as a Doll'), findsOneWidget);
      expect(find.text('You nested your first family.'), findsOneWidget);
      expect(find.text('Badge earned · Glass Act'), findsNothing);
      // One at a time: the first fades out after 2.5 s, the next waits
      // 300 ms after that (Q136).
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Badge earned · Glass Act'), findsOneWidget);
      expect(find.text('Badge earned · Snug as a Doll'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('none with an empty list', (tester) async {
      await pumpScreen(tester, _overlay());
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Badge earned'), findsNothing);
    });
  });

  for (final size in screenSizes) {
    testWidgets('the ribbon: its 410 × 110 canvas at full size, centred, the '
        'anchor (205, 55) on the screen\'s centre line, the band 290 or the '
        'screen − 70, ${size.width.toInt()} wide (LOTTIE.md m7-5)', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay(), size: size);
      await tester.pump(const Duration(milliseconds: 300));
      final row = tester.getRect(find.byKey(WinOverlay.ribbonKey));
      // The card scales down as a whole on a short screen (FittedBox).
      final fit = row.height / 110;
      expect(fit, lessThanOrEqualTo(1));
      final canvas = tester.getRect(
        find.descendant(
          of: find.byKey(WinOverlay.ribbonKey),
          matching: find.byType(LottieTextOverlay),
        ),
      );
      expect(canvas.width, closeTo(410 * fit, 0.01));
      expect(canvas.height, closeTo(110 * fit, 0.01));
      expect(canvas.center.dx, closeTo(size.width / 2, 0.01));
      expect(row.center.dx, closeTo(size.width / 2, 0.01));
      expect(canvas.center.dy, closeTo(row.center.dy, 0.01));
      // A narrow phone narrows the band through the named rects, and the
      // title's box with it; the ribbon and its tails fit with 13 dp or
      // more to spare.
      final view = tester.widget<LottieFxView>(
        find.descendant(
          of: find.byKey(WinOverlay.ribbonKey),
          matching: find.byType(LottieFxView),
        ),
      );
      final band = math.min(290.0, size.width - 70);
      expect(view.controller!.params.ribbonBandWidth, band);
      expect(view.labelStyle!.maxWidth, band - 24);
      expect((size.width - (band + 44) * fit) / 2, greaterThanOrEqualTo(13));
      expectNoLayoutErrors(tester);
      await tester.pump(const Duration(seconds: 2));
    });
  }

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _overlay(
            reward: 1240,
            families: const [
              DollColor.red,
              DollColor.blue,
              DollColor.green,
              DollColor.purple,
              DollColor.orange,
            ],
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        expectNoLayoutErrors(tester);
        // Continue stays on screen.
        final button = tester.getRect(find.text('Continue'));
        expect(button.bottom, lessThanOrEqualTo(size.height));
        expect(find.byType(LottieDoll), findsNWidgets(5));
      });
    }
  }

  group('stars (m7-design P3.7)', () {
    testWidgets('no stars, no daily/bonus/race win: no StarRow at all', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(StarRow), findsNothing);
    });

    testWidgets('none on the daily card, even with stars set by mistake', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay(dailyStreak: 5, stars: 3));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(StarRow), findsNothing);
    });

    testWidgets('the ui_stars canvas sits at (75, 176) of the design screen '
        '(top 117 below the safe area), 240 × 110, above the plank and '
        'the card', (tester) async {
      await pumpScreen(tester, _overlay(stars: 2));
      await tester.pump(const Duration(seconds: 2));
      final row = tester.getRect(find.byType(StarRow));
      expect(row.size, const Size(240, 110));
      expect(row.left, closeTo(75, 0.01));
      // The design's y 176, on this harness' 59 dp safe area.
      expect(row.top, closeTo(176, 0.01));
      expect(
        row.bottom,
        lessThan(tester.getTopLeft(find.byType(WinChapterCard)).dy),
      );
    });

    testWidgets('a replay below 3 stars shows too (only daily/bonus/race '
        'have none)', (tester) async {
      await pumpScreen(tester, _overlay(isReplay: true, stars: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(StarRow), findsOneWidget);
    });

    testWidgets('each star\'s cue starts its segment: star_1, star_2, star_3 '
        '333 ms apart from 1,300 ms, a light haptic each', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(tester, _overlay(stars: 3, feedback: feedback));
      await tester.pump(const Duration(milliseconds: 1299));
      final before = feedback.played.length;

      await tester.pump(const Duration(milliseconds: 2));
      expect(feedback.played.length, before + 1);
      expect(feedback.played.last.sound, SoundEffect.star1);
      expect(feedback.played.last.haptic, HapticPattern.pick);

      await tester.pump(const Duration(milliseconds: 333));
      expect(feedback.played.last.sound, SoundEffect.star2);
      await tester.pump(const Duration(milliseconds: 333));
      expect(feedback.played.last.sound, SoundEffect.star3);
      expect(
        feedback.played.where((c) => c.haptic == HapticPattern.complete),
        isEmpty,
        reason: 'the success haptic waits for the flourish to end',
      );
      // star_3's segment ends at 2,300 ms, then the flourish (1,000 ms), then
      // the success haptic at 3,300 ms.
      await tester.pump(const Duration(milliseconds: 1300));
      expect(feedback.played.last.sound, SoundEffect.star3);
      await tester.pump(const Duration(milliseconds: 40));
      expect(feedback.played.last.haptic, HapticPattern.complete);
      expect(feedback.played.last.sound, isNull);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('below 3 stars: no flourish cue', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(tester, _overlay(stars: 2, feedback: feedback));
      await tester.pump(const Duration(seconds: 4));
      expect(
        feedback.played.where((cue) => cue.haptic == HapticPattern.complete),
        isEmpty,
      );
      expect(
        feedback.played.map((c) => c.sound).whereType<SoundEffect>(),
        containsAllInOrder([SoundEffect.star1, SoundEffect.star2]),
      );
      expect(
        feedback.played.where((c) => c.sound == SoundEffect.star3),
        isEmpty,
      );
    });

    testWidgets('reduced motion (Q146): one cue for the highest star and one '
        'light haptic, no flourish', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(
        tester,
        _overlay(stars: 3, feedback: feedback),
        reduceMotion: true,
      );
      await tester.pump(const Duration(seconds: 4));
      final starCues = feedback.played.where(
        (c) =>
            c.sound == SoundEffect.star1 ||
            c.sound == SoundEffect.star2 ||
            c.sound == SoundEffect.star3,
      );
      expect(starCues, hasLength(1));
      expect(starCues.single.sound, SoundEffect.star3);
      expect(starCues.single.haptic, HapticPattern.pick);
      expect(
        feedback.played.where((c) => c.haptic == HapticPattern.complete),
        isEmpty,
      );
    });
  });

  group('the win card\'s layout (frames 11.2, 11.4, 10.1, 12.4)', () {
    testWidgets('the campaign card: chips at 420, the progress card at 500, '
        'Continue at 646', (tester) async {
      await pumpScreen(tester, _overlay(stars: 3, winMoves: 13));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(WinCoinPill), findsOneWidget);
      expect(find.byType(WinMovesChip), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(WinMovesChip)).dy,
        closeTo(420, 0.5),
      );
      expect(
        tester.getTopLeft(find.byType(WinChapterCard)).dy,
        closeTo(500, 0.5),
      );
      expect(
        tester.getTopLeft(find.widgetWithText(TactileButton, 'Continue')).dy,
        closeTo(646, 0.5),
      );
    });

    testWidgets('the chest line keeps the chapter\'s bar and count; only the '
        'next line and the tile change (C2)', (tester) async {
      await pumpScreen(tester, _overlay(stars: 2, chestLevelsLeft: 3));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Chapter 3'), findsOneWidget);
      expect(find.text('16 / 20'), findsOneWidget);
      expect(find.text('3 levels to the chest'), findsOneWidget);
      expect(find.textContaining('Next up'), findsNothing);
    });

    testWidgets('Bonus Endless: "Bonus Level 7", "7 / 10" and the chest line, '
        'no stars', (tester) async {
      await pumpScreen(
        tester,
        _overlay(bonusNumber: 7, chestLevelsLeft: 3, winMoves: 18, reward: 25),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Bonus Level 7'), findsOneWidget);
      expect(find.text('7 / 10'), findsOneWidget);
      expect(find.text('3 levels to the chest'), findsOneWidget);
      expect(find.text('Moves 18'), findsOneWidget);
      expect(find.byType(StarRow), findsNothing);
    });

    testWidgets('the 16:9 card (winStarsShort): stars at 128, buttons at 522 '
        'with no note to show', (tester) async {
      await pumpScreen(
        tester,
        _overlay(stars: 2),
        size: const Size(390, 693),
        padding: const EdgeInsets.only(top: 59, bottom: 34),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getTopLeft(find.byType(StarRow)).dy, closeTo(128, 0.5));
      expect(find.byKey(WinOverlay.noteKey), findsNothing);
      expect(
        tester.getTopLeft(find.widgetWithText(TactileButton, 'Continue')).dy,
        closeTo(522, 0.5),
      );
    });

    testWidgets('the 16:9 card keeps the helper note (tip or helper, never '
        'both): the pill at 486, the card moved up, buttons at 548 '
        '(m7-4 4.12; frame 11.2g, scene winShortCap: the reason takes the '
        "tip's row, with the families at 64 dp, m7-5 item 22)", (tester) async {
      var tipShown = 0;
      await pumpScreen(
        tester,
        _overlay(
          stars: 2,
          starTip: true,
          starsCapped: true,
          onTipShown: () => tipShown++,
        ),
        size: const Size(390, 693),
        padding: const EdgeInsets.only(top: 59, bottom: 34),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getTopLeft(find.byType(StarRow)).dy, closeTo(128, 0.5));
      expect(
        find.text('Wins with a hint or an extra slot earn up to 2 stars.'),
        findsOneWidget,
      );
      expect(find.textContaining('Fewer moves earn more stars'), findsNothing);
      expect(tipShown, 0, reason: 'the helper note wins; the tip waits');
      expect(
        tester.getTopLeft(find.byKey(WinOverlay.noteKey)).dy,
        closeTo(486, 1),
      );
      expect(
        tester.getTopLeft(find.widgetWithText(TactileButton, 'Continue')).dy,
        closeTo(548, 0.5),
      );
      // 11.2g: the families at 64 (winStarsShort.notePill.withTip).
      expect(WinStarsShortTokens.notePillWithTipHopDollHeight, 64);
      for (final doll in tester.widgetList<LottieDoll>(
        find.byType(LottieDoll),
      )) {
        expect(doll.height, 64);
      }
      expect(find.byType(LottieDoll), findsNWidgets(4));
    });

    testWidgets('the 16:9 card shows the tip, once, when that is the note', (
      tester,
    ) async {
      var tipShown = 0;
      await pumpScreen(
        tester,
        _overlay(stars: 2, starTip: true, onTipShown: () => tipShown++),
        size: const Size(390, 693),
        padding: const EdgeInsets.only(top: 59, bottom: 34),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(WinOverlay.noteKey), findsOneWidget);
      expect(tipShown, 1);
    });

    testWidgets('a 731 dp phone blends the two cards by height: the stars '
        'and the button sit between the 693 and 844 values', (tester) async {
      await pumpScreen(
        tester,
        _overlay(stars: 2),
        size: const Size(390, 731),
        padding: const EdgeInsets.only(top: 59, bottom: 34),
      );
      await tester.pump(const Duration(seconds: 2));
      final t = (731 - 693) / (844 - 693);
      expect(
        tester.getTopLeft(find.byType(StarRow)).dy,
        closeTo(128 + (176 - 128) * t, 0.6),
      );
      expect(
        tester.getTopLeft(find.widgetWithText(TactileButton, 'Continue')).dy,
        closeTo(522 + (646 - 522) * t, 0.6),
      );
    });
  });

  group('the note and the tip (Q145, D191)', () {
    testWidgets('a capped win shows the helper note, and the tip is not '
        'recorded', (tester) async {
      var tipShown = 0;
      await pumpScreen(
        tester,
        _overlay(
          stars: 2,
          starsCapped: true,
          starTip: true,
          onTipShown: () => tipShown++,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text('Wins with a hint or an extra slot earn up to 2 stars.'),
        findsOneWidget,
      );
      expect(find.textContaining('Fewer moves earn more stars'), findsNothing);
      expect(tipShown, 0);
      expect(
        tester.getTopLeft(find.byKey(WinOverlay.noteKey)).dy,
        closeTo(602, 1),
      );
    });

    testWidgets('the tip shows once and is recorded the moment it shows', (
      tester,
    ) async {
      var tipShown = 0;
      await pumpScreen(
        tester,
        _overlay(stars: 2, starTip: true, onTipShown: () => tipShown++),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text(
          'Fewer moves earn more stars. Replay any level from Chapters.',
        ),
        findsOneWidget,
      );
      expect(tipShown, 1);
    });

    testWidgets('neither shows without either flag', (tester) async {
      await pumpScreen(tester, _overlay(stars: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(WinOverlay.noteKey), findsNothing);
    });

    testWidgets('a replay shows the tip at 612, not the helper note '
        'alongside it', (tester) async {
      await pumpScreen(
        tester,
        _overlay(isReplay: true, stars: 2, starTip: true, starTarget: 15),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(WinOverlay.noteKey), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.widgetWithText(TactileButton, 'Back to Chapters'))
            .dy,
        closeTo(668, 0.5),
      );
    });
  });

  group('the daily card\'s Share (frame 10.1; D188)', () {
    testWidgets('Share sits above Back to Daily and hands the OS sheet '
        'G.6\'s text with the families in board order', (tester) async {
      final share = FakeShareService();
      await pumpScreen(
        tester,
        _overlay(
          dailyStreak: 5,
          winMoves: 18,
          families: const [DollColor.purple, DollColor.yellow],
          dailyDate: LocalDate(2026, 9, 26),
          share: share,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      final shareButton = find.byKey(WinOverlay.shareKey);
      final back = find.widgetWithText(TactileButton, 'Back to Daily');
      expect(shareButton, findsOneWidget);
      expect(
        tester.getBottomLeft(shareButton).dy,
        lessThan(tester.getTopLeft(back).dy),
      );
      expect(find.bySemanticsLabel('Share today’s result'), findsOneWidget);
      await tester.tap(shareButton);
      await tester.pump();
      expect(share.shared.single, startsWith('Nesty Daily · Sep 26\n'));
      expect(share.shared.single, contains('⭐ ☀️'));
      expect(share.shared.single, endsWith('Solved in 18 moves · Day 5 🔥'));
      expect(share.origins.single, isNotNull);
    });

    testWidgets('a campaign win has no Share', (tester) async {
      await pumpScreen(tester, _overlay(stars: 2, share: FakeShareService()));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(WinOverlay.shareKey), findsNothing);
    });

    testWidgets('the daily card keeps the chips and shows the moves there, '
        'not on the streak card', (tester) async {
      await pumpScreen(
        tester,
        _overlay(dailyStreak: 5, winMoves: 18, share: FakeShareService()),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(WinMovesChip), findsOneWidget);
      expect(find.text('Moves 18'), findsOneWidget);
      expect(find.text('5-day streak'), findsOneWidget);
    });
  });

  group('twinkles and toasts', () {
    testWidgets('three fx_twinkle points on the campaign card (E.17)', (
      tester,
    ) async {
      await pumpScreen(tester, _overlay(stars: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LottieTwinkle), findsNWidgets(3));
      final positions = [
        for (final t in tester.widgetList(find.byType(LottieTwinkle)))
          tester.getCenter(find.byWidget(t)),
      ];
      expect(positions[0].dx, closeTo(52, 0.5));
      expect(positions[0].dy, closeTo(112, 0.5));
      expect(positions[1].dx, closeTo(338, 0.5));
      expect(positions[2].dy, closeTo(396, 0.5));
    });

    testWidgets('the badge toasts sit at the design y 60 on the card\'s own '
        'host', (tester) async {
      await pumpScreen(
        tester,
        _overlay(stars: 2, newBadges: const [BadgeId.firstFamily]),
      );
      await tester.pump(const Duration(milliseconds: 1200));
      final toast = find.text('Badge earned · Snug as a Doll');
      expect(toast, findsOneWidget);
      // ToastHost.badgeTop 60 on the 59 dp safe area: 1 dp below its top.
      expect(
        tester
            .getTopLeft(
              find.ancestor(of: toast, matching: find.byType(Padding)).first,
            )
            .dy,
        lessThan(120),
      );
      await tester.pump(const Duration(seconds: 4));
    });
  });

  // The device run after the M7 review: on the 16:9 emulator (411 × 731 dp)
  // the block above the button scales down, and since R23 the button kept
  // its full width, so it stood ~10 dp wider than the card on each side.
  // Frame 2.8 draws the card and Continue at one width: the button keeps
  // its height (R23's 48 dp) and takes the scaled card's width.
  group('the button under a scaled block (review R23; the device run '
      'after the review)', () {
    Future<void> expectButtonUnderCard(
      WidgetTester tester, {
      required Size size,
      required String label,
      required bool scaled,
    }) async {
      final card = tester.getRect(
        find.byWidgetPredicate(
          (w) => w is WinChapterCard || w is ReplayReasonCard,
        ),
      );
      final button = tester.getRect(find.widgetWithText(TactileButton, label));
      if (scaled) {
        expect(
          card.width,
          lessThan(size.width - 56 - 1),
          reason: 'the block scales down on this screen',
        );
      } else {
        expect(card.width, closeTo(size.width - 56, 0.01));
        // Unchanged where it fits: 28 from each edge.
        expect(button.top, greaterThanOrEqualTo(card.bottom));
      }
      expect(button.left, closeTo(card.left, 0.5));
      expect(button.right, closeTo(card.right, 0.5));
      expect(button.height, greaterThanOrEqualTo(48));
      expect(button.top, greaterThanOrEqualTo(card.bottom));
      expect(button.bottom, lessThanOrEqualTo(size.height));
      expectNoLayoutErrors(tester);
    }

    testWidgets('411 × 731 (the API 35 emulator): the short card fits '
        'without scaling', (tester) async {
      const size = Size(411, 731);
      await pumpScreen(
        tester,
        _overlay(
          reward: 1240,
          families: const [
            DollColor.red,
            DollColor.blue,
            DollColor.green,
            DollColor.purple,
            DollColor.orange,
          ],
          winMoves: 35,
          bestMoves: 35,
          stars: 2,
        ),
        size: size,
        padding: const EdgeInsets.only(top: 24),
      );
      await tester.pump(const Duration(seconds: 3));
      await expectButtonUnderCard(
        tester,
        size: size,
        label: 'Continue',
        scaled: false,
      );
    });

    testWidgets('360 × 640 at 1.3× (the tallest replay card): Back to '
        'Chapters keeps 48 dp and the card\'s width', (tester) async {
      const size = Size(360, 640);
      await pumpScreen(
        tester,
        _overlay(
          winMoves: 12,
          bestMoves: 12,
          isReplay: true,
          stars: 2,
          starsNewBest: true,
          starTarget: 10,
          starTip: true,
        ),
        size: size,
        textScale: 1.3,
      );
      await tester.pump(const Duration(seconds: 3));
      await expectButtonUnderCard(
        tester,
        size: size,
        label: 'Back to Chapters',
        scaled: true,
      );
    });

    testWidgets('390 × 844, where it fits: nothing scales and Continue '
        'sits at 646', (tester) async {
      const size = Size(390, 844);
      await pumpScreen(tester, _overlay(winMoves: 7, bestMoves: 7, stars: 2));
      await tester.pump(const Duration(seconds: 3));
      await expectButtonUnderCard(
        tester,
        size: size,
        label: 'Continue',
        scaled: false,
      );
    });
  });

  group('WinSummary.familiesOf', () {
    test('one per completed colour, in first-seen board order', () {
      final level = levelFrom('''
{
  "schemaVersion": 1, "id": "T1", "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue2", "blue1"]},
      {"type": "open", "nest": ["red3"]} ],
    [ {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');
      final session = GameSession(level);
      expect(WinSummary.familiesOf(level, session.state), isEmpty);
      session.move('r1c0', 'r0c2');
      expect(WinSummary.familiesOf(level, session.state), [DollColor.red]);
      session.move('r0c1', 'r0c0');
      // Blue shows first: it comes first on the board.
      expect(WinSummary.familiesOf(level, session.state), [
        DollColor.blue,
        DollColor.red,
      ]);
    });
  });
}
