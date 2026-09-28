import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/nav/nesty_bottom_nav.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/museum/widgets/figurine_modal.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;
import 'package:nesty_render/nesty_render.dart';

/// The dev flavor on a simulator or emulator, with every real service
/// (bundled levels, the skin, the 29 Lottie files, SoLoud's SFX, jingles
/// and music, the isolate solver): Splash → Home → level 1 and level 2
/// played to the win overlay → level 9's hint and two extra slots with a
/// doll on one (the owner's frames 3.1 and 3.6) → level 16's tower reveal
/// into Out of Moves → Pause, with Music off and on → Home → level 21's
/// chapter ribbon (BACKLOG M2 "On-device playthrough", PROGRESS D57; spec
/// §10.1). M3 adds the shell tabs, the Museum and its modals, the Shop,
/// Settings and its language sheet, the Daily (5.1, 5.3–5.5), the
/// tutorial and intro cards, the priced Out-of-Moves row and booster
/// popup, Pause → Settings, chapter complete, All Levels Done and the
/// bonus pill.
///
/// The music can't be heard here, so it is checked through
/// `SoLoudMusicService`'s state: the loop that plays on each screen and the
/// volume each overlay ducks it to (AUDIO.md "Music rules"). No SoLoud,
/// music or Lottie failure may be logged, and every file must load.
///
/// Taps land on slot centres computed with `BoardLayout` for the screen
/// the board is on (checked against the board's own layout), so they
/// travel the real path: Flutter gestures → the Flame board → the bloc.
/// Mid-animation screenshots are taken at a fixed time of the board's
/// timeline (m2-lottie-design §7), with the engine paused while the
/// platform captures the screen. The driver saves them on the host:
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/playthrough_test.dart \
///   --dart-define=NESTY_FAKE_DATE=20260926 -d <device>
/// ```
///
/// The fixed date makes the daily (whose board, and so its intro cards,
/// comes from the date) the same on every run and device. Start from a
/// fresh install (uninstall first): the file expects a fresh save.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The game runs as it does for a player: Flame's loop and every Lottie
  // get the frames they ask for, not only the ones the test pumps.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'plays levels 1 and 2 to the win overlay, shows a hint and two extra '
    'slots on level 9, runs out of moves on level 16, pauses and goes home, '
    'and opens chapter 2 on level 21',
    (tester) async {
      // Every service logs its failures through debugPrint in debug builds.
      // The binding checks debugPrint is restored when the body ends, so it
      // is put back here, before the logs are checked.
      final logs = <String>[];
      final debugPrintBefore = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
        debugPrintBefore(message, wrapWidth: wrapWidth);
      };
      try {
        await _playthrough(binding, tester);
      } finally {
        debugPrint = debugPrintBefore;
      }
      final failures = [
        for (final line in logs)
          if (line.startsWith('[nesty.audio]') ||
              line.startsWith('[nesty.music]') ||
              line.startsWith('[nesty.fx]'))
            line,
      ];
      expect(failures, isEmpty, reason: 'SoLoud, music or Lottie failures');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<void> _playthrough(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  final shots = _Screenshots(binding, tester);
  final board = _Board(tester, shots);
  final music = _Music(tester);

  app.main();

  // Splash (frame 1.1) while the levels, the skin, the Lottie files and
  // the sounds load: first as it opens, then (if it is still up) once
  // the skin's shelf dolls have landed.
  await tester.pumpUntil(
    () => find.byType(SplashPage).evaluate().isNotEmpty,
    reason: 'the splash',
  );
  await shots.take('00_splash');
  await tester.pumpUntil(
    () =>
        find.byType(SplashPage).evaluate().isEmpty ||
        get<ShowcaseDolls>().current.value != null,
    timeout: const Duration(seconds: 60),
    reason: 'the splash art',
  );
  if (find.byType(SplashPage).evaluate().isNotEmpty) {
    await shots.take('00b_splash_loaded');
  }

  // Home (frame 2.1): level 1 (InMemorySaveService starts every launch
  // there, D13).
  await tester.pumpUntil(
    () =>
        find.byType(SplashPage).evaluate().isEmpty &&
        find.bySemanticsLabel('Play level 1').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: 'Home with level 1',
  );
  // The route transition and the idle dolls' first loop.
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('01_home');
  // Every file loaded: the 29 Lottie files, the 17 SFX and 3 jingles.
  expect(get<FxLibrary>().failed, isEmpty);
  final audio = get<AudioService>() as SoLoudAudioService;
  await tester.pumpUntilDone(audio.jinglesLoaded, reason: 'the jingles');
  expect(audio.loadedFiles, {
    ...SoundTokens.allFiles,
    ...SoundTokens.jingleFiles,
  });
  // Home's loop faded in over `start` (1200 ms) from the splash's end.
  await music.expectPlaying(MusicTrack.home);

  // ── M3 shell tabs, the Shop and Settings (frames 2.1 nav, 7.3/7.4/7.7,
  // 8.1/8.2): a side trip from Home, back to Home, before Level 1. ──
  await tester.tap(_nav('Museum'));
  await tester.pumpUntil(
    () => find.byType(MuseumPage).evaluate().isNotEmpty,
    reason: 'the Museum tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('01b_museum');
  // The next figurine's modal (chapter 1's, still to earn), then a locked
  // one further along (frame 6.3).
  await _openFigurine(tester, 'Classic · soon');
  await shots.take('01b2_museum_next_modal');
  await _closeFigurine(tester);
  await _openFigurine(tester, 'Chapter 3');
  await shots.take('01b3_museum_locked_modal');
  await _closeFigurine(tester);

  await tester.tap(_nav('Shop'));
  await tester.pumpUntil(
    () => find.byType(ShopPage).evaluate().isNotEmpty,
    reason: 'the Shop tab',
  );
  await tester.pumpUntil(
    () => find.byType(SkinGridCard).evaluate().isNotEmpty,
    reason: 'the Skins tab loaded',
  );
  await _artReady(tester, 'the Skins cards');
  await shots.take('01c_shop_skins');

  // Ocean (frame 7.4): all 11 colors, the size lineup, Buy · price.
  await tester.tap(find.text('Ocean'));
  await tester.pumpUntil(
    () => find.byType(SkinDetailPage).evaluate().isNotEmpty,
    reason: "Ocean's detail",
  );
  // The route transition, then the art (it may already be cached).
  await tester.pumpFor(const Duration(milliseconds: 400));
  await _artReady(tester, "Ocean's detail");
  await shots.take('01d_shop_skin_detail');
  // The detail's own header back arrow (frame 7.4), not the Shop's under it.
  await tester.tap(
    find.descendant(
      of: find.byType(SkinDetailPage),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(SkinDetailPage).evaluate().isEmpty,
    reason: 'back to the Shop',
  );

  // Themes (frame 7.7): "Match each chapter", In use / Use / locked.
  await tester.tap(find.text('Themes'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('01e_shop_themes');

  await tester.tap(_nav('Home'));
  await tester.pumpUntil(
    () => find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // Settings (frames 8.1, 8.2), opened from Home's gear.
  await tester.tap(find.bySemanticsLabel('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('01f_settings');
  await tester.tap(find.text('Language'));
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isNotEmpty,
    reason: 'the language sheet',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('01g_settings_language');
  await tester.tap(find.text('Done'));
  await tester.pumpUntil(
    () => find.byType(LanguageSheet).evaluate().isEmpty,
    reason: 'the sheet closed',
  );
  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── Level 1: red3 · red2 · red1 (maxSize 3, one family) ──
  await tester.tap(find.bySemanticsLabel('Play level 1'));
  await board.waitForLevel(1);
  expect(
    board.state.board.slot('r0c0'),
    _open(DollColor.red, outer: 3, length: 1),
  );
  await shots.take('02_l1_board');
  // A level crossfades to its loop (800 ms); Home's loop pauses.
  await music.expectPlaying(MusicTrack.game);

  // The scripted tutorial (frame 1.3, step 1; m3-design §10.4) shows on a
  // fresh save's first board: the scrim, the hole, the arc and the hand,
  // gating input to red2 (the only move it accepts).
  await tester.pumpUntil(
    () => find.byType(TutorialOverlay).evaluate().isNotEmpty,
    reason: 'the L1 tutorial cue',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('02c_l1_tutorial');

  // Tap-tap (spec §2.2): red2 lifts (doll_pick lift, then the wobble
  // loop and the select glow; frame 2.3)…
  await board.tap('r0c2');
  await tester.pumpUntil(
    () => board.state.selectedSlotId == 'r0c2',
    reason: 'r0c2 selected',
  );
  await tester.pumpFor(const Duration(milliseconds: 450));
  await shots.take('03_selection');

  // …and drops inside red3: doll_move to the hover point 0–267 ms, then
  // doll_nest 267–667 ms with the clack at 537 ms (frame 2.4).
  final nest = await board.drop('r0c0');
  await board.shotAt('04_nesting', nest, 250);
  await board.waitIdle();
  expect(
    board.state.board.slot('r0c0'),
    _open(DollColor.red, outer: 3, length: 2),
  );
  await tester.pumpFor(const Duration(milliseconds: 200));
  await shots.take('04b_after_nesting');

  // red1 completes the family (frame 2.5): doll_complete from t0 =
  // 667 ms (the shine, the hops from t0 + 300, the flight to the counter
  // from t0 + 700 with the dust puff and the sparkle trail), then Won
  // at the batch end + 250 ms.
  final complete = await board.move('r1c1', 'r0c0');
  await board.shotAt('05_family_complete', complete, 667 + 420);
  await board.shotAt('05b_family_flying', complete, 667 + 880);
  expect(board.state.status, GameplayStatus.won);

  // Win (frames 1.5, 2.8): ribbon, confetti, the hopping family, "+10".
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('06_win');
  // The win overlay ducks the music to 0.3 while it is up.
  await music.expectPlaying(MusicTrack.game, duck: DuckReason.win.factor);

  // Continue loads level 2 in the same page (frame 2.11), with its own
  // art from its first frame (level 2 adds blue, which level 1's skin
  // doesn't hold).
  await board.continueTo(2);
  await shots.take('07_l2_board');
  // Continue stays on the page: the same loop, unducked.
  await music.expectPlaying(MusicTrack.game);

  // ── Level 2 (spec §2.2 #3, frame 1.6): the scripted tutorial's step 4
  // (m3-design §10.4) opens on the swallow, a drag of red3 over red2+red1
  // and the only move it accepts; then blue3 swallows blue2 by tap-tap and
  // blue1 finishes. ──
  await tester.pumpUntil(
    () => find.byType(TutorialOverlay).evaluate().isNotEmpty,
    reason: 'the L2 swallow tutorial cue (step 4)',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('08a_l2_tutorial_swallow');
  await board.dragMove('r0c0', 'r1c0');
  await board.waitIdle();
  expect(board.state.setsCompleted, 1);
  await tester.pumpUntil(
    () => find.byType(TutorialOverlay).evaluate().isEmpty,
    reason: 'the tutorial ends with step 4',
  );
  // doll_move to the hover point (1.06 × blue2's height) 0–267 ms,
  // then doll_swallow 267–667 ms: the lid opens mid-air and the body
  // drops over blue2.
  final swallow = await board.move('r1c1', 'r0c1');
  await board.shotAt('08_l2_swallow', swallow, 267 + 170);
  await board.waitIdle();
  expect(
    board.state.board.slot('r0c1'),
    _open(DollColor.blue, outer: 3, length: 2),
  );
  await tester.pumpFor(const Duration(milliseconds: 200));
  await shots.take('08b_l2_swallowed');

  await board.move('r1c2', 'r0c1');
  await board.waitForWinOverlay();
  expect(board.state.levelNumber, 2);
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('09_l2_win');

  // Continue to level 3, then Pause → Home.
  await board.continueTo(3);
  await board.openPause();
  await board.pauseToHome(level: 3);
  await music.expectPlaying(MusicTrack.home);

  // ── Daily (frame 5.1; m3-design §10.5): Level 2's win just unlocked it
  // (m3-design §8.3), still unsolved today (streak 0). ──
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await _artReady(tester, 'the Daily preview');
  await shots.take('09a_daily_unlocked');

  // ── Daily win (frames 5.3–5.5; m3-design §8.4, §8.5): Play opens the
  // same gameplay page with the date pill (5.3). No move is scripted —
  // the puzzle is generated from today's real date, so it differs run to
  // run — the solver's own hints finish it instead (spec §6.3), the same
  // path level 9's Hint already exercises below.
  await tester.tap(find.text('Play'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  // The fixed date's daily (README "Testing": NESTY_FAKE_DATE=20260926)
  // brings towers and glass in, so it opens on their intro cards (frames
  // 4.1, 4.2; m3-design §10.4), one after the other.
  for (var card = 1; card <= 3; card++) {
    await tester.pumpFor(const Duration(milliseconds: 600));
    final shown = board.state.intro;
    if (shown == null) break;
    await shots.take('09a1_daily_intro_${card}_${shown.name}');
    await tester.tap(find.text('Got it'));
    // The next card (if any) replaces this one at once.
    await tester.pumpUntil(
      () => board.state.intro != shown,
      reason: 'the ${shown.name} intro card dismissed',
    );
  }
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('09a2_daily_pill');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  expect(board.state.dailyStreak, isNotNull, reason: 'the daily variant');
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('09a3_daily_win');

  // "Back to Daily" (frame 5.4's own button) pops back to the Daily page
  // pushed it from, for real, not only content-tested at the widget level
  // (gameplay-screens' handoff note).
  await tester.tap(find.text('Back to Daily'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'back on the Daily screen',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('09a4_daily_solved');
  // TODO(later): 5.6's day-7 chest modal needs a real 7-day streak
  // (`StreakDailyService`, m3-design §8.2) under the system clock this
  // file runs on — unlike `daily_fingerprint_test.dart`, it doesn't set
  // `NESTY_FAKE_DATE`, so this can't fast-forward a week. Covered instead
  // by `daily-museum-tools`'s `FakeClock`-driven widget tests.

  await tester.tap(find.bySemanticsLabel('Back'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── Level 9 from the dev level picker: the owner's hint (frame 3.1)
  // and +1 Slot (frame 3.6) cases. ──
  await board.jumpTo(9, 'Medium');
  await shots.take('09b_l9_board');
  await tester.tap(find.text('Hint'));
  await tester.pumpUntil(
    () => board.state.hint != null,
    timeout: const Duration(seconds: 10),
    reason: 'the hint',
  );
  // The solver's first move of an optimal line: brown3 swallows brown2.
  expect(board.state.hint, const Move('r0c1', 'r1c0'));
  // The arrow bobs over brown3, the glow pulses on brown2's stand and
  // the arc draws in.
  await tester.pumpFor(const Duration(milliseconds: 900));
  await shots.take('09c_l9_hint');

  // +1 Slot twice: two extra stands on the bottom shelf, each pulsing
  // its `ui_extra_slot` pad once its re-pitch ends.
  for (final slots in [1, 2]) {
    await tester.tap(find.text('+Slot'));
    await tester.pumpUntil(
      () => board.state.board.extraSlotCount == slots,
      reason: 'extra slot $slots',
    );
    await board.waitIdle();
  }
  expect(board.state.board.slotIds, containsAll(['x0', 'x1']));
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('09d_l9_extra_slots');

  // brown1 onto the first extra stand: a doll standing on the pad.
  await board.move('r2c2', 'x0');
  await board.waitIdle();
  expect(
    board.state.board.slot('x0'),
    _open(DollColor.brown, outer: 1, length: 1),
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('09e_l9_doll_on_extra');
  await board.openPause();
  await board.pauseToHome(level: 3);

  // ── Level 16 (towers, HARD) from the dev level picker: the top of
  // the r1c1 tower onto the only empty stand leaves no legal move (a
  // breadth-first search over the bundle: the shortest Out-of-Moves
  // line among levels 1–30). ──
  // The dev flavor's boosters never run out, which hides every coin
  // price. Debug-only, turn that off (README "Testing") and spend the Hint
  // and +1 Slot gifts: Hint then opens its buy popup (frame 3.3), and the
  // Out-of-Moves sheet below prices its +1 Slot row (frame 3.5). +1 Slot
  // itself stays free in debug builds (m3-design §7.3), so its own popup
  // isn't reachable here. Before the level opens: the bloc reads the
  // boosters into its state on each board change.
  final save = get<SaveService>();
  (save as InMemorySaveService).debugUnlimitedBoosters = false;
  for (final kind in [BoosterKind.hint, BoosterKind.extraSlot]) {
    while (save.boosterCount(kind) > 0) {
      save.useBooster(kind);
    }
  }
  await board.jumpTo(16, 'Hard');
  await shots.take('10_l16_board');
  // Towers were already introduced by the daily above: no card here
  // (each mechanic's card shows once per save, m3-design §10.4).
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.byType(IntroMechanicCard), findsNothing);
  await tester.tap(find.text('Hint'));
  await tester.pumpUntil(
    () => find.byType(BoosterBuyPopup).evaluate().isNotEmpty,
    reason: 'the Hint booster popup',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('10a_booster_popup_hint');
  // The scrim also reads "Close"; the last is the card's own button.
  await tester.tap(
    find
        .descendant(
          of: find.byType(BoosterBuyPopup),
          matching: find.bySemanticsLabel('Close'),
        )
        .last,
  );
  await tester.pumpUntil(
    () => find.byType(BoosterBuyPopup).evaluate().isEmpty,
    reason: 'the booster popup closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  // The top leaving r1c1 reveals the nest under it from t = 0:
  // doll_reveal's `drop` 0–7 f from its buried step, the wipe 7–19 f.
  final reveal = await board.move('r1c1', 'r0c3');
  await board.shotAt('10b_l16_reveal', reveal, 200);
  await tester.pumpUntil(
    () => find.byType(OutOfMovesSheet).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the Out-of-Moves sheet',
  );
  expect(board.state.status, GameplayStatus.outOfMoves);
  await tester.pumpFor(const Duration(milliseconds: 700));
  await shots.take('11_out_of_moves');
  save.debugUnlimitedBoosters = null;
  // The sheet ducks the music to 0.4 (and plays jingle_oom).
  await music.expectPlaying(
    MusicTrack.game,
    duck: DuckReason.outOfMoves.factor,
  );

  // Restart from the sheet, then Pause (frame 3.9) and go Home.
  await tester.tap(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('Restart'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(OutOfMovesSheet).evaluate().isEmpty &&
        board.state.status == GameplayStatus.playing,
    reason: 'the restarted board',
  );
  await board.waitIdle();
  await music.expectPlaying(MusicTrack.game);
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('12_pause');
  // Pause ducks the music to 0.5.
  await music.expectPlaying(MusicTrack.game, duck: DuckReason.pause.factor);
  // Music off is silent within 300 ms (the loop fades out and pauses);
  // on, it comes back. The toggle only writes the setting.
  await tester.tap(find.bySemanticsLabel('Music'));
  await tester.pumpFor(const Duration(milliseconds: 450));
  expect(music.service.playingTracks, isEmpty, reason: 'Music off');
  await tester.tap(find.bySemanticsLabel('Music'));
  await music.expectPlaying(MusicTrack.game, duck: DuckReason.pause.factor);
  // Pause → Settings → back to the paused level (m3-design §10.1).
  await tester.tap(
    find.descendant(
      of: find.byType(PauseDialog),
      matching: find.bySemanticsLabel('Settings'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings over the paused level',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('12b_pause_settings');
  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () =>
        find.byType(SettingsPage).evaluate().isEmpty &&
        find.byType(PauseDialog).evaluate().isNotEmpty,
    reason: 'back to the paused level',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('12c_pause_back');
  await board.pauseToHome(level: 3);
  await tester.pumpFor(const Duration(milliseconds: 700));
  await shots.take('13_home_after');
  await music.expectPlaying(MusicTrack.home);

  // ── Level 21 opens chapter 2: its ribbon (frame 4.7) plays over the
  // board for 2.6 s. ──
  await board.jumpTo(21, 'Easy', settle: const Duration(milliseconds: 300));
  await shots.take('14_l21_chapter_ribbon');
  await tester.pumpFor(const Duration(milliseconds: 2600));
  await shots.take('15_l21_board');
  await board.openPause();
  await board.pauseToHome(level: 3);

  // ── Level 20 (chapter 1's last): Chapter complete (frame 4.6). No move
  // is scripted (the same reasoning as the daily's hints above; §7.1's 200
  // launch levels means a level's exact board can still change before its
  // chapter ships). ──
  await board.jumpTo(20, 'Super Hard');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(ChapterCompleteOverlay).evaluate().isNotEmpty,
    reason: 'chapter 1 complete',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('16_chapter_complete');
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(ChapterCompleteOverlay).evaluate().isEmpty,
    reason: 'chapter complete closed',
  );
  await board.waitForLevel(21);
  await board.openPause();
  await board.pauseToHome(level: 21);
  // Chapter 1's figurine is on the shelf now (frame 6.1 with one earned),
  // and its modal (frame 6.2).
  await tester.tap(_nav('Museum'));
  await tester.pumpUntil(
    () => find.byType(MuseumPage).evaluate().isNotEmpty,
    reason: 'the Museum tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('16b_museum_earned');
  await _openFigurine(tester, 'Classic Family');
  await shots.take('16c_museum_earned_modal');
  await _closeFigurine(tester);
  await tester.tap(_nav('Home'));
  await tester.pumpUntil(
    () => find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── Level 30 (the last bundled level): All Levels Done (frame 4.9),
  // then its teal "Play Bonus Level 1" (frame 4.10's HUD pill). ──
  await board.jumpTo(30, 'Super Hard');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(AllLevelsDone).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'all levels done',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('17_all_levels_done');
  final beforeBonus = board.state.levelNumber;
  await tester.tap(find.text('Play Bonus Level 1'));
  await tester.pumpUntil(
    () =>
        find.byType(AllLevelsDone).evaluate().isEmpty &&
        board.state.levelNumber != beforeBonus &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'Bonus Level 1 with its skin',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('18_bonus_level_pill');

  expect(music.service.failedTracks, isEmpty);
}

/// Every doll preview on screen has its skin art (no `FxSpinner` left),
/// then a beat for the frame to settle.
Future<void> _artReady(WidgetTester tester, String what) async {
  await tester.pumpUntil(
    () => find.byType(FxSpinner).evaluate().isEmpty,
    timeout: const Duration(seconds: 30),
    reason: '$what with its skin art',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
}

/// The bottom nav's own label (Home's Museum tile also reads "Museum").
Finder _nav(String label) => find.descendant(
  of: find.byType(NestyBottomNav),
  matching: find.text(label),
);

/// A Museum cabinet figurine's modal (frames 6.2, 6.3), by the tile's
/// label ("Classic Family", "Classic · soon", "Chapter 3").
Future<void> _openFigurine(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pumpUntil(
    () => find.byType(FigurineModal).evaluate().isNotEmpty,
    reason: 'the $label modal',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
}

Future<void> _closeFigurine(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FigurineModal),
      matching: find.bySemanticsLabel('Close'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(FigurineModal).evaluate().isEmpty,
    reason: 'the figurine modal closed',
  );
}

/// An open slot holding the run of [length] [color] dolls from [outer] down.
OpenSlot _open(DollColor color, {required int outer, required int length}) =>
    OpenSlot(
      nest: Nest.run(color, outer: outer, length: length),
    );

/// Takes each screenshot through the platform and hands it to the driver,
/// which saves `<name>.png` on the host.
final class _Screenshots {
  _Screenshots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _surfaceConverted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_surfaceConverted) {
      // Android draws Flutter into a SurfaceView the platform can't read
      // back; the plugin swaps in an image view for the rest of the test.
      await _binding.convertFlutterSurfaceToImage();
      _surfaceConverted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}

/// The gameplay page's board: its Flame game, its bloc, and taps on slot
/// centres laid out with `BoardLayout` (spec §10.3).
final class _Board {
  _Board(this._tester, this._shots);

  final WidgetTester _tester;
  final _Screenshots _shots;

  Finder get _gameWidget => find.byType(GameWidget<NestyGame>);

  NestyGame get game =>
      _tester.widget<GameWidget<NestyGame>>(_gameWidget).game!;

  GameplayBloc get bloc =>
      _tester.element(find.byType(GameplayView)).read<GameplayBloc>();

  GameplayState get state => bloc.state.data!;

  /// The board has scheduled the bloc's latest effect (effects are queued
  /// and scheduled in the game's next tick).
  bool get _caughtUp => game.board.board == state.board;

  /// [slotId]'s column centre on its shelf's hit band, on screen: the
  /// layout `BoardLayout` computes for this board on the game's viewport
  /// (the screen minus its safe areas), which must be the one the board
  /// drew. The board lays out on Flame's float32 size, so the two agree to
  /// a small fraction of a pixel on a fractional screen width.
  Offset centreOf(String slotId) {
    final size = _tester.getSize(_gameWidget);
    final padding = MediaQuery.paddingOf(_tester.element(_gameWidget));
    final layout = BoardLayout.compute(
      boardShapeOf(state.board),
      BoardViewport(size: size, padding: padding),
    );
    final drawn = game.geometry!;
    final slot = layout.slot(slotId);
    expect(drawn.slot(slotId).centerX, closeTo(slot.centerX, 1e-3));
    expect(
      drawn.shelves[slot.row].hitCenterY,
      closeTo(layout.shelves[slot.row].hitCenterY, 1e-3),
    );
    return _tester.getTopLeft(_gameWidget) +
        Offset(slot.centerX, layout.shelves[slot.row].hitCenterY);
  }

  Future<void> tap(String slotId) => _tester.tapAt(centreOf(slotId));

  /// Tap-tap from [from] to [to] once the board is idle; returns the
  /// board's timeline time when it scheduled the move's batch.
  Future<double> move(String from, String to) async {
    await waitIdle();
    await tap(from);
    await _tester.pumpUntil(
      () => state.selectedSlotId == from,
      reason: '$from selected',
    );
    await _tester.pumpFor(const Duration(milliseconds: 250));
    return drop(to);
  }

  /// A real drag from [from] onto [to] (the L2 tutorial's step 4 accepts
  /// only a drag, m3-design §10.4): press, travel in small steps past the
  /// touch slop, release over [to]. Returns the board's timeline time when
  /// it scheduled the move's batch.
  Future<double> dragMove(String from, String to) async {
    await waitIdle();
    final before = state.moveSeq;
    final start = centreOf(from);
    final end = centreOf(to);
    final gesture = await _tester.startGesture(start);
    await _tester.pump(const Duration(milliseconds: 100));
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await gesture.moveTo(Offset.lerp(start, end, i / steps)!);
      await _tester.pump(const Duration(milliseconds: 16));
    }
    await _tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await _tester.pumpUntil(
      () => state.moveSeq > before && _caughtUp,
      reason: 'the drag onto $to applied',
      step: const Duration(milliseconds: 4),
    );
    return game.board.timeline!.nowMs;
  }

  /// Taps [to] with a nest lifted; returns the board's timeline time when it
  /// scheduled the move's batch.
  Future<double> drop(String to) async {
    final before = state.moveSeq;
    await tap(to);
    await _tester.pumpUntil(
      () => state.moveSeq > before && _caughtUp,
      reason: 'the move onto $to scheduled',
      step: const Duration(milliseconds: 4),
    );
    return game.board.timeline!.nowMs;
  }

  /// A screenshot [atMs] into the batch scheduled at [batchStart] (timeline
  /// time), with the engine paused while the platform captures it.
  Future<void> shotAt(String name, double batchStart, double atMs) async {
    final timeline = game.board.timeline!;
    await _tester.pumpUntil(
      () => timeline.nowMs >= batchStart + atMs,
      reason: '$name at $atMs ms',
      step: const Duration(milliseconds: 4),
    );
    game.pauseEngine();
    try {
      await _shots.take(name);
    } finally {
      game.resumeEngine();
    }
  }

  /// The board has played everything the bloc gave it and takes input
  /// again.
  Future<void> waitIdle() => _tester.pumpUntil(() {
    final timeline = game.board.timeline;
    return timeline != null &&
        _caughtUp &&
        timeline.isIdle &&
        !timeline.inputLocked;
  }, reason: 'the board to go idle');

  /// Applies the solver's own hint repeatedly until the level is won: a
  /// generic way to finish a board without scripting its exact moves (frame
  /// 3.1's Hint, spec §6.3), for levels this file otherwise only jumps to
  /// for a screen that needs a win (chapter complete, All Levels Done) or
  /// whose board is generated fresh each run (the daily). Never needs coins:
  /// the dev flavor's `SaveService.unlimitedBoosters` (spec §7.3) keeps Hint
  /// free.
  Future<void> solveWithHints({int maxMoves = 30}) async {
    for (var i = 0; i < maxMoves; i++) {
      if (state.status != GameplayStatus.playing) return;
      // A mechanic this save hasn't met yet opens on its intro card, which
      // holds input until dismissed (m3-design §10.4).
      for (var shown = state.intro; shown != null; shown = state.intro) {
        await _tester.pumpFor(const Duration(milliseconds: 400));
        await _tester.tap(find.text('Got it'));
        await _tester.pumpUntil(
          () => state.intro != shown,
          reason: 'the ${shown.name} intro card dismissed',
        );
      }
      await waitIdle();
      if (state.status != GameplayStatus.playing) return;
      await _tester.tap(find.text('Hint'));
      await _tester.pumpUntil(
        () => state.hint != null,
        timeout: const Duration(seconds: 15),
        reason: 'a hint',
      );
      final hint = state.hint!;
      await move(hint.from, hint.to);
    }
    fail('did not solve within $maxMoves moves');
  }

  /// Level [number] is on the board with its own art: the bloc has it, the
  /// board laid it out and the skin prepared for that layout arrived.
  Future<void> waitForLevel(
    int number, {
    Object? previousSkin,
    Duration settle = const Duration(milliseconds: 800),
  }) async {
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isNotEmpty &&
          bloc.state.data?.levelNumber == number &&
          game.geometry != null &&
          game.skin != null &&
          !identical(game.skin, previousSkin) &&
          find.byType(WinOverlay).evaluate().isEmpty,
      timeout: const Duration(seconds: 30),
      reason: 'level $number with its skin',
    );
    await waitIdle();
    // The route transition and the art's first frames.
    await _tester.pumpFor(settle);
  }

  /// Home's dev "Jump to a level" picker (dev flavor): level [number], its
  /// tile labelled with its [tier].
  Future<void> jumpTo(
    int number,
    String tier, {
    Duration settle = const Duration(milliseconds: 800),
  }) async {
    final tile = find.bySemanticsLabel('Level $number · $tier');
    await _tester.tap(find.text('Jump to a level'));
    await _tester.pumpUntil(
      () => tile.evaluate().isNotEmpty,
      reason: 'the level picker',
    );
    await _tester.pumpFor(const Duration(milliseconds: 500));
    await _tester.tap(tile);
    await waitForLevel(number, settle: settle);
  }

  /// Continue on the win overlay: level [number]'s board has its own art
  /// in the very update that lays it out, never the previous level's skin,
  /// which holds only that level's colours (a colour it lacks draws
  /// nothing; review CORRECTNESS-1).
  Future<void> continueTo(int number) async {
    final previousSkin = game.skin;
    await _tester.tap(find.text('Continue'));
    await _tester.pumpUntil(
      () => bloc.state.data?.levelNumber == number && _caughtUp,
      reason: 'level $number on the board',
      step: const Duration(milliseconds: 4),
    );
    expect(game.skin, isNotNull);
    expect(
      identical(game.skin, previousSkin),
      isFalse,
      reason: 'level $number drew with the previous level\'s skin',
    );
    await waitForLevel(number, previousSkin: previousSkin);
  }

  Future<void> waitForWinOverlay() => _tester.pumpUntil(
    () => find.byType(WinOverlay).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the win overlay',
  );

  Future<void> openPause() async {
    await _tester.tap(find.bySemanticsLabel('Pause'));
    await _tester.pumpUntil(
      () => find.byType(PauseDialog).evaluate().isNotEmpty,
      reason: 'the pause dialog',
    );
  }

  /// Pause's Home tile: back to Home, which offers [level], once the route
  /// transition is over.
  Future<void> pauseToHome({required int level}) async {
    await _tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Home'),
      ),
    );
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isEmpty &&
          find.byType(HomePage).evaluate().isNotEmpty &&
          find.bySemanticsLabel('Play level $level').evaluate().isNotEmpty,
      reason: 'Home with level $level',
    );
    await _tester.pumpFor(const Duration(milliseconds: 600));
  }
}

/// The real `SoLoudMusicService`: what plays, and how loud it is meant to
/// be, since a test can't listen.
final class _Music {
  _Music(this._tester);

  final WidgetTester _tester;

  SoLoudMusicService get service => get<MusicService>() as SoLoudMusicService;

  /// Only [track]'s loop plays (a crossfade or a fade has finished) and
  /// the music aims at the default volume × [duck], the lowest duck factor
  /// on screen.
  Future<void> expectPlaying(MusicTrack track, {double duck = 1}) async {
    final target = MusicMix.target(volume: MusicMix.defaultVolume, duck: duck);
    await _tester.pumpUntil(
      () =>
          service.currentTrack == track &&
          service.playingTracks.length == 1 &&
          service.playingTracks.single == track &&
          (service.targetVolume - target).abs() < 1e-9,
      timeout: const Duration(seconds: 5),
      reason:
          '${track.name} music alone at $target (playing '
          '${service.playingTracks}, target ${service.targetVolume})',
    );
  }
}

extension on WidgetTester {
  /// Pumps frames until [future] completes, failing after [timeout].
  Future<void> pumpUntilDone(
    Future<void> future, {
    required String reason,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    var done = false;
    unawaited(future.whenComplete(() => done = true));
    await pumpUntil(() => done, reason: reason, timeout: timeout);
  }

  /// Real time passes (the live binding draws every frame meanwhile).
  Future<void> pumpFor(Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 16));
    }
  }

  /// Pumps until [condition] holds, failing after [timeout].
  Future<void> pumpUntil(
    bool Function() condition, {
    required String reason,
    Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 50),
  }) async {
    final end = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(end)) {
        fail('Timed out after $timeout waiting for $reason');
      }
      await pump(step);
    }
  }
}
