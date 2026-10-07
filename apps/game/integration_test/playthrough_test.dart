import 'dart:async' show unawaited;
import 'dart:convert' show jsonEncode;
import 'dart:io' show Platform;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/race/versus_ribbon.dart';
import 'package:nesty_game/features/chapters/pages/chapters_page.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_button.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/museum/widgets/figurine_modal.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';
import 'package:nesty_game/features/records/pages/records_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;
import 'package:nesty_render/nesty_render.dart';

import 'support/phone_language.dart';
import 'support/race_solver.dart';

/// The dev flavor on a simulator or emulator, with every real service
/// (bundled levels, the skin, the 29 Lottie files, SoLoud's SFX, jingles
/// and music, the isolate solver): Splash → level 1 and level 2 played to
/// the win overlay → level 9's hint and two extra slots with a doll on one
/// (the owner's frames 3.1 and 3.6) → level 16's tower reveal into Out of
/// Moves → Pause, with Music off and on → Home → level 21's chapter ribbon
/// (BACKLOG M2 "On-device playthrough", PROGRESS D57; spec §10.1). M3 adds
/// the shell tabs, the Museum and its modals, the Shop, Settings and its
/// language sheet, the Daily (5.1, 5.3–5.5), the tutorial and intro cards,
/// the priced Out-of-Moves row and booster popup, Pause → Settings,
/// chapter complete, All Levels Done and the bonus pill.
///
/// M7 (m7-design §13, §18; BACKLOG M7): the splash opens level 1 with no
/// screen in between (E9), and the time from `main()` to its first
/// playable frame is reported (E13, `NESTY_E13`); the first win's Continue
/// goes Home, with its three tiles (D111); Chapters, a replay of level 1
/// with its best moves, and Records (E7, E8); the Shop's "Not enough coins"
/// dialog (D112) and an equip; Settings' reduce-motion sheet (E14); level
/// 30's milestone chest, opened and collected (E5); one segment per new
/// mechanic, opened by the levels lane's teaching moves and finished by the
/// solver's hints: level 16's towers card, level 31's glass and its card,
/// level 51's ice and its card, level 71's size-5 family and level 130's
/// size-6 families, with the level picker scrolled most of the way down;
/// the Daily after level 31, so each schedule level shows its own card;
/// Chapters at chapter 7; and level 200, the last bundled level, into
/// chapter complete and All Levels Done. M7 phase 2 (m7-design P2.13): after
/// level 20, vs Computer against rival 1, won with the solver's moves (the
/// rival slowed by `NESTY_RACE_PACE_MS`). M7 phase 3 (m7-design P3.13):
/// level 1's 3 stars on its win card and in Chapters, a 4-move replay's 2
/// stars and its 3-star target (the level keeps 3), Records' star rows,
/// the Daily's Share (never tapped) and the reminder offer answered "No
/// thanks" (the OS never asked), and Settings' reminder row, off. M7 phase 4
/// (m7-design P4.1–P4.10, Claude Design's m7-3): the first launch fades into
/// level 1 (frame 10.8, D194), level 1's "STEP n OF 3" chips with step 3's
/// (copy.md E), Home's chapter card and Records button (2.1), Chapters'
/// level card (10.4b) opening the replay, Records' stats grid (10.6), the
/// Museum's cabinet labels (6.1), the Shop's buy chips, Settings' inline
/// Reduce motion control (10.2e), the +1 Slot limit (12.9), the daily win
/// card's Share (10.1, never tapped; the solved card has none, D188), the
/// reminder offer as a dialog (10.2), and the rival-1 win's 9.4 then the 9.6
/// card on the way back to the races.
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
///   --dart-define=NESTY_FAKE_DATE=20260926 \
///   --dart-define=NESTY_RACE_PACE_MS=600000 -d <device>
/// ```
///
/// The fixed date makes the daily (whose board, and so any intro card it
/// shows, comes from the date) the same on every run and device. Start
/// from a fresh install (uninstall first): the file expects a fresh save.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The game runs as it does for a player: Flame's loop and every Lottie
  // get the frames they ask for, not only the ones the test pumps.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'opens level 1 from the splash and plays it and level 2 to the win '
    'overlay, shows a hint and two extra slots on level 9, meets towers and '
    'runs out of moves on level 16, pauses and goes home, opens chapter 2 '
    'on level 21, opens the milestone chest and plays each new mechanic '
    'and the daily to level 200',
    (tester) async {
      pinEnglishPhone(tester);
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
        await _playthrough(binding, tester, logs);
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
    timeout: const Timeout(Duration(minutes: 25)),
  );
}

Future<void> _playthrough(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  List<String> logs,
) async {
  final shots = _Screenshots(binding, tester);
  final board = _Board(tester, shots);
  final music = _Music(tester);

  final launch = Stopwatch()..start();
  app.main();
  // E13 is read from the app's own progress, not from this loop: the loop
  // waits behind every screenshot (on Android the first one converts the
  // surface) and behind a busy host. A 4 ms timer notes the first moment
  // level 1 is playable and the first moment the splash is gone after it
  // was seen. It uses unguarded finders: `_tester.element` throws from a
  // timer ("Guarded function conflict").
  final e13 = _E13Poller(launch)..start();

  // Splash (frame 1.1) while the levels, the skin, the Lottie files and
  // the sounds load: first as it opens, then (if it is still up) once
  // the skin's shelf dolls have landed.
  await tester.pumpUntil(
    () => find.byType(SplashPage).evaluate().isNotEmpty,
    reason: 'the splash',
  );
  // E9: every route the root router stacks from the splash (its initial
  // route) to level 1's first playable frame. The router notifies on each
  // change, so even a screen replaced within a frame is caught.
  final router = get<AppRouter>();
  final routesSeen = <String>{};
  void noteRoutes() =>
      routesSeen.addAll([for (final route in router.stackData) route.name]);
  noteRoutes();
  router.addListener(noteRoutes);
  // Phase 5 F-SPL (decision 1 of architecture.md §6): the splash draws
  // E.19's fallback dolls from its first frame and crossfades to the art.
  // Shot about 100 ms after the splash is first on screen (the placeholder
  // dolls, frame 1.1), again once the shelf dolls' art has landed, and
  // about 1.5 s in if the splash is still up then. Each shot's time since the
  // splash appeared goes into the report (`splash`).
  final splashSeen = launch.elapsed;
  final splashShots = <String, int>{};
  Future<void> splashShot(String name) async {
    splashShots[name] = (launch.elapsed - splashSeen).inMilliseconds;
    await shots.take(name);
  }

  bool splashUp() => find.byType(SplashPage).evaluate().isNotEmpty;
  await tester.pumpUntil(
    () => launch.elapsed - splashSeen >= const Duration(milliseconds: 100),
    reason: 'the splash 100 ms in',
    step: const Duration(milliseconds: 4),
  );
  if (splashUp()) await splashShot('00_splash');
  // 00b_splash_loaded (frame 10.8) is shot by faults_test's `splash_loaded`
  // scenario, which holds the splash until the art is current: here the art
  // lands only 300-500 ms before the handover, so a shot waiting for it
  // always hit the transition and, on a slow phone, missed the splash.
  await tester.pumpUntil(
    () =>
        !splashUp() ||
        launch.elapsed - splashSeen >= const Duration(milliseconds: 1500),
    timeout: const Duration(seconds: 10),
    reason: 'the splash 1.5 s in',
    step: const Duration(milliseconds: 16),
  );
  if (splashUp()) await splashShot('00c_splash_1500ms');
  binding.reportData = {...?binding.reportData, 'splash': splashShots};

  // ── E9 and E13 (m7-design §13; brainstorm §3): a fresh install goes
  // from the splash straight into level 1's tutorial, with no Home under it
  // and no screen in between. The time from `main()` to level 1's first
  // playable frame (its own art laid out, the board taking input) is
  // reported for the owner's device check, and so is the time until the
  // splash's exit transition has ended (level 1 alone on screen): the
  // navigator keeps the splash mounted while level 1 slides in over it. ──
  var homeShown = false;
  bool noHome() {
    if (find.byType(HomePage).evaluate().isNotEmpty) homeShown = true;
    return true;
  }

  await tester.pumpUntil(
    () => noHome() && board.playable(1),
    timeout: const Duration(seconds: 60),
    reason: 'level 1 straight from the splash (E9)',
    step: const Duration(milliseconds: 16),
  );
  final loopPlayable = launch.elapsed;
  await tester.pumpUntil(
    () => noHome() && find.byType(SplashPage).evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: "the splash's exit transition to level 1",
    step: const Duration(milliseconds: 16),
  );
  final loopAlone = launch.elapsed;
  e13.stop();
  // The poller's checks wait for the end of the playthrough: a clock that
  // fails costs the run its E13 reading, not every check after this one.
  _reportE13(
    binding,
    playable: e13.playable ?? loopPlayable,
    alone: e13.alone ?? loopAlone,
    loopPlayable: loopPlayable,
    loopAlone: loopAlone,
    levelsCheckMs: levelsCheckMs(logs),
    poller: e13,
  );
  router.removeListener(noteRoutes);
  noteRoutes();
  expect(homeShown, isFalse, reason: 'E9: no Home before level 1');
  expect(routesSeen, {
    SplashRoute.name,
    GameplayRoute.name,
  }, reason: 'E9: the splash, then level 1, with no screen in between');
  expect(
    [for (final route in router.stackData) route.name],
    [GameplayRoute.name],
    reason: 'E9: level 1 alone on the stack, no Home underneath',
  );
  // Frame 10.8 (D194): the first launch fades into level 1 over 400 ms
  // instead of the platform's page transition. E13 still counts to the
  // first playable frame, which the board reaches under the fade (it takes
  // input as soon as it is laid out); "alone" now includes the fade's end.
  final entry = router.stackData.single.args;
  expect(entry, isA<GameplayRouteArgs>());
  expect(
    (entry! as GameplayRouteArgs).entrance,
    GameplayEntrance.fromSplash,
    reason: 'the first launch fades in (frame 10.8)',
  );
  expect(board.playable(1), isTrue);
  // The art's first frames.
  await tester.pumpFor(const Duration(milliseconds: 500));
  // Every file loaded: the 35 Lottie files, the 23 SFX and 5 jingles.
  expect(get<FxLibrary>().failed, isEmpty);
  final audio = get<AudioService>() as SoLoudAudioService;
  await tester.pumpUntilDone(audio.jinglesLoaded, reason: 'the jingles');
  expect(audio.loadedFiles, {
    ...SoundTokens.allFiles,
    ...SoundTokens.jingleFiles,
  });
  // The level's loop fades in (800 ms): a new player's first music is the
  // level's, never Home's.
  await music.expectPlaying(MusicTrack.game);
  final save = get<SaveService>();

  // ── Level 1: red3 · red2 · red1 (maxSize 3, one family) ──
  expect(
    board.state.board.slot('r0c0'),
    _open(DollColor.red, outer: 3, length: 1),
  );
  await shots.take('02_l1_board');

  // The scripted tutorial (frame 1.3, step 1; m3-design §10.4) shows on a
  // fresh save's first board: the scrim, the hole, the arc and the hand,
  // gating input to red2 (the only move it accepts).
  await tester.pumpUntil(
    () => find.byType(TutorialOverlay).evaluate().isNotEmpty,
    reason: 'the L1 tutorial cue',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  // "STEP n OF 3" on all three of level 1's steps (copy.md E; lead note 6).
  expect(find.text('STEP 1 OF 3'), findsOneWidget);
  // m7-4 8.1 (`layout.tutorial`): the scrim dims the HUD and the booster
  // bar with a hole that keeps Pause lit and tappable, and the tip sits in
  // the HUD row beside it, clear of the family counter.
  _expectTutorialHud(tester, 'STEP 1 OF 3');
  await shots.take('02c_l1_tutorial');

  // Tap-tap (spec §2.2): red2 lifts (doll_pick lift, then the wobble
  // loop and the select glow; frame 2.3)…
  await board.tap('r0c2');
  await tester.pumpUntil(
    () => board.state.selectedSlotId == 'r0c2',
    reason: 'r0c2 selected',
  );
  await tester.pumpFor(const Duration(milliseconds: 450));
  expect(find.text('STEP 2 OF 3'), findsOneWidget);
  await shots.take('03_selection');
  // Frame 1.4 (step 2, "Now tap the big one", the target glowing): the
  // step's card settled, for the fidelity pair (architecture.md §1.3).
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text('STEP 2 OF 3'), findsOneWidget);
  _expectTutorialHud(tester, 'STEP 2 OF 3');
  await shots.take('04b2_l1_tutorial_step2');

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
  // Step 3 (the last): red1 into the nest, with its own chip.
  await tester.pumpUntil(
    () => find.text('STEP 3 OF 3').evaluate().isNotEmpty,
    reason: "the L1 tutorial's step 3",
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('04c_l1_tutorial_step3');

  // red1 completes the family (frame 2.5): doll_complete from t0 =
  // 667 ms (the shine, the hops from t0 + 300, the flight to the counter
  // from t0 + 700 with the dust puff and the sparkle trail), then Won
  // at the batch end + 250 ms.
  final complete = await board.move('r1c1', 'r0c0');
  await board.shotAt('05_family_complete', complete, 667 + 420);
  await board.shotAt('05b_family_flying', complete, 667 + 880);
  expect(board.state.status, GameplayStatus.won);

  // Win (frames 1.5, 2.8): ribbon, confetti, the hopping family, "+10",
  // the moves line (m7 §11) and first_family's badge toast (m7 §12).
  await board.waitForWinOverlay();
  expect(find.text('Moves 2 · Best 2'), findsOneWidget);
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('06_win');
  // The win overlay ducks the music to 0.3 while it is up.
  await music.expectPlaying(MusicTrack.game, duck: DuckReason.win.factor);
  // Stars (D125; m7-design P3.7, P3.13, P4.7): the tutorial's path is par
  // (2 moves), so 3 stars, `ui_stars` revealing them from 1,300 ms, 333 ms
  // apart, then the flourish; a 3-star win shows no tip.
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(board.state.stars, 3);
  expect(find.bySemanticsLabel(_starsLabel(3)), findsOneWidget);
  expect(find.text(_starTip), findsNothing);
  await shots.take('06a_win_stars');

  // ── E9: the first win's Continue goes Home (m7-design §13), never level
  // 2. Home (frame 2.1, D193): the chapter card with its stars and the
  // Records button beside it, then Daily, vs Computer and Remove Ads, no
  // Museum tile (D111).
  await board.continueHome(level: 2);
  // The route transition and the idle dolls' first loop.
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('01_home');
  expect(
    find.descendant(of: find.byType(HomePage), matching: find.byType(HomeTile)),
    findsNWidgets(3),
  );
  await music.expectPlaying(MusicTrack.home);

  // ── Chapters (E7, m7 §15.1; frame 10.4), opened from Home's chapter
  // card (Q92), and a replay of level 1 from its level card (10.4b): no
  // tutorial, "Moves 2 · Best 2", no coins, and Back to Chapters (m7 §6,
  // §11). ──
  await _openChapters(tester);
  // Level 1's cell shows its 3 stars (m7-design P3.7).
  const level1Cell = 'Level 1, 3 stars. Best 2 moves.';
  expect(find.bySemanticsLabel(level1Cell), findsOneWidget);
  await shots.take('01h_chapters');
  final coinsBeforeReplay = save.coins;
  // A won cell opens its level card (10.4b): the stars, the target and
  // the best; Play replays it.
  await tester.tap(find.bySemanticsLabel(level1Cell));
  await tester.pumpUntil(
    () => find.byType(LevelCard).evaluate().isNotEmpty,
    reason: "level 1's level card",
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('01h2_chapters_level_card');
  await tester.tap(
    find.descendant(of: find.byType(LevelCard), matching: find.text('Play')),
  );
  await board.waitForLevel(1);
  // A replay shows the plain level pill: no "Replay" tag (owner, D170).
  expect(find.text('Replay'), findsNothing);
  expect(find.byType(TutorialOverlay), findsNothing);
  await shots.take('01i_replay_board');
  // The replay takes 4 moves, two over par: red2 steps onto two empty
  // stands before it nests (every step checked with `Rules.tryMove`). At
  // the default slack (20 % / 60 %) par 2's 3-star line is 3 moves and its
  // 2-star line 4 (spec-prop §7.10), so the card shows 2 stars, the
  // replay's 3-star target and no "New best!", and the level keeps its 3.
  const replayLine = 'r0c2>r0c1 r0c1>r1c2 r1c2>r0c0 r1c1>r0c0';
  _expectLegalWinningLine(board.state.board, replayLine);
  await board.playLine(replayLine);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 2000));
  expect(find.text('Moves 4 · Best 2'), findsOneWidget);
  expect(board.state.stars, 2);
  expect(find.bySemanticsLabel(_starsLabel(2)), findsOneWidget);
  expect(find.text('3 stars at 3 moves or fewer'), findsOneWidget);
  expect(find.text('New best!'), findsNothing);
  // This save's first win below 3 stars: the one-time tip (Q119).
  expect(find.text(_starTip), findsOneWidget);
  await shots.take('01j_replay_win');
  expect(save.coins, coinsBeforeReplay, reason: 'a replay pays nothing');
  expect(save.document.levelStars['L0001'], 3, reason: 'never lowered');
  await tester.tap(find.text('Back to Chapters'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(ChaptersPage).evaluate().isNotEmpty,
    reason: 'back on Chapters',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(find.bySemanticsLabel(level1Cell), findsOneWidget);
  await _backFrom(tester, ChaptersPage);

  // Records (E8, m7 §15.2; frame 10.6): the stats grid, the races card
  // with each rival's Computer tag, "Best moves by level" and the badge
  // grid; its Stars cell (m7-design P3.7): 3 of the bundle's 600.
  await _openFromHome(tester, 'Records', RecordsPage);
  await shots.take('01k_records');
  await tester.scrollUntilVisible(
    find.text('Stars'),
    200,
    scrollable: find
        .descendant(
          of: find.byType(RecordsPage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  expect(find.text('3 of 600'), findsOneWidget);
  await shots.take('01k2_records_stars');
  await _backFrom(tester, RecordsPage);

  // ── M3 shell tabs, the Shop and Settings (frames 2.1 nav, 7.3/7.4/7.7,
  // 8.1/8.2): a side trip from Home, back to Home, before level 2. The
  // Museum shows its intro line, the next family and each locked shelf's
  // chapter and levels (the owner's review). ──
  await tester.tap(_nav('Museum'));
  await tester.pumpUntil(
    () => find.byType(MuseumPage).evaluate().isNotEmpty,
    reason: 'the Museum tab',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('01b_museum');
  // The next figurine's modal (chapter 1's, still to earn), then a locked
  // one further along (frame 6.3).
  await _openFigurine(
    tester,
    RegExp(r'^The Classic Family, next to come home\.'),
  );
  await shots.take('01b2_museum_next_modal');
  await _closeFigurine(tester);
  await _openFigurine(tester, 'The Baker Family, not home yet. Chapter 3.');
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

  // D112 (the owner's review): a price the balance can't cover opens "Not
  // enough coins" first, and its "Go to Shop" lands on the Coins tab.
  Finder skinCard(String name, Finder matching) => find.descendant(
    of: find.widgetWithText(SkinGridCard, name),
    matching: matching,
  );
  await tester.tap(skinCard('Ocean', find.byType(ShopBuyButton)));
  await tester.pumpUntil(
    () => find.byType(NotEnoughCoinsDialog).evaluate().isNotEmpty,
    reason: 'the Not enough coins dialog',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('01d2_shop_not_enough_coins');
  await tester.tap(find.text('Go to Shop'));
  await tester.pumpUntil(
    () => find.byType(NotEnoughCoinsDialog).evaluate().isEmpty,
    reason: 'the dialog closed',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('01d3_shop_coins_tab');

  // An equip moves "Equipped" at once (the owner's review, frame 7.3).
  // The test grants Ocean's coins (buying equips it), then goes back to
  // Classic and takes the coins back, so the rest of the run is as before.
  final coinsBeforeShop = save.coins;
  save.addCoins(5000);
  await tester.tap(find.text('Skins'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(skinCard('Ocean', find.byType(ShopBuyButton)));
  await tester.pumpUntil(
    () => skinCard('Ocean', find.text('Equipped')).evaluate().isNotEmpty,
    reason: 'Ocean equipped at once',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('01d4_shop_equipped');
  await tester.tap(skinCard('Classic', find.text('Equip')));
  await tester.pumpUntil(
    () => skinCard('Classic', find.text('Equipped')).evaluate().isNotEmpty,
    reason: 'Classic equipped again',
  );
  save.spendCoins(save.coins - coinsBeforeShop);
  await _artReady(tester, 'the Skins cards');

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
  await _routeSettled(tester, SettingsPage);
  await shots.take('01f_settings');
  // Below the fold on a 731 dp tall phone (the API 35 emulator), under
  // phase 4's Relaxed mode, Reduce motion and Color symbols rows: bring it
  // up first (the device run, 2026-09-30).
  final language = find.text('Language');
  await Scrollable.ensureVisible(tester.element(language), alignment: 0.5);
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(language);
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
  // M7's rows (m7 §15.5; frame 10.2e): Relaxed mode, and Reduce motion's
  // inline Off · On · System control. On writes the setting at once;
  // System puts the default back for the rest of the run.
  final reduceMotion = find.byType(SettingsSegmentedRow<ReduceMotionMode>);
  Finder segment(String label) =>
      find.descendant(of: reduceMotion, matching: find.text(label));
  await tester.ensureVisible(reduceMotion);
  await tester.pumpFor(const Duration(milliseconds: 300));
  final database = get<DatabaseService>();
  expect(database.reduceMotion, ReduceMotionMode.system);
  await tester.tap(segment('On'));
  await tester.pumpUntil(
    () => database.reduceMotion == ReduceMotionMode.on,
    reason: 'Reduce motion On',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  await shots.take('01g2_settings_reduce_motion');
  await tester.tap(segment('System'));
  await tester.pumpUntil(
    () => database.reduceMotion == ReduceMotionMode.system,
    reason: 'Reduce motion back to System',
  );
  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── Level 2 from Home's PLAY (the first win moved Home on to it). ──
  // BACKLOG M7 "the gameplay skin lands within the route transition": the
  // time from the push to the level's own skin on the board (placeholder
  // dolls until then), and to the route's transition end, reported as
  // `skinLand` for the device stage to judge (architecture.md §4 row 875).
  final push = Stopwatch()..start();
  await tester.tap(find.bySemanticsLabel('Play level 2'));
  await tester.pumpUntil(
    () =>
        find.byType(GameWidget<NestyGame>).evaluate().isNotEmpty &&
        board.bloc.state.data?.levelNumber == 2 &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "level 2's skin after the push",
    step: const Duration(milliseconds: 4),
  );
  final skinLand = push.elapsed;
  await tester.pumpUntil(
    () {
      final page = find.byType(GameplayView).evaluate().firstOrNull;
      return page != null &&
          (ModalRoute.of(page)?.animation?.isCompleted ?? false);
    },
    reason: "level 2's route transition",
    step: const Duration(milliseconds: 4),
  );
  _reportSkinLand(
    binding,
    level: 2,
    skinLand: skinLand,
    routeDone: push.elapsed,
  );
  await board.waitForLevel(2);
  await shots.take('07_l2_board');
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
  expect(
    find.bySemanticsLabel('Pause').hitTestable(),
    findsOneWidget,
    reason: 'Pause stays tappable through the scrim (m7-4 8.1)',
  );
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
  // The level's limit (12.9): the +1 Slot face goes sunk with "2/2".
  expect(find.bySemanticsLabel('+Slot, 2 of 2 used'), findsOneWidget);
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
  (save as InMemorySaveService).debugUnlimitedBoosters = false;
  for (final kind in [BoosterKind.hint, BoosterKind.extraSlot]) {
    while (save.boosterCount(kind) > 0) {
      save.useBooster(kind);
    }
  }
  // Towers arrive here, on spec §3.7's schedule: level 16 opens on their
  // intro card (frame 4.1, m3-design §10.4), which holds the board until
  // "Got it" and never shows again on this save.
  await board.jumpTo(16, 'Hard', idle: false);
  await board.dismissIntro(IntroMechanic.towers, shot: '10_l16_towers_intro');
  await shots.take('10_l16_board');
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
  await _routeSettled(tester, SettingsPage);
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
  // The daily gift (frame 13.1): level 2's win unlocked it, so Home's
  // header wears the button with its ready dot. Not tapped: the claim has
  // its own check (`login_gift_test.dart`) and later steps stay as they were.
  expect(find.byType(GiftButton), findsOneWidget);
  expect(find.byKey(GiftButton.dotKey), findsOneWidget);
  await shots.take('13b_home_gift_ready');
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
  await _openFigurine(tester, 'The Classic Family, home in your Museum');
  await shots.take('16c_museum_earned_modal');
  await _closeFigurine(tester);
  await tester.tap(_nav('Home'));
  await tester.pumpUntil(
    () => find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── vs Computer (E10; m7-design P2.13; mode-vs-computer.md "Tests →
  // Integration"): level 20's win opened the mode (`race_unlock_level`
  // 20). Home's tile → rival select (9.2) → rival 1 → the race board
  // (9.3), regenerated from `raceParams(1, 1, 20)` (core's `race-1-1@20`)
  // → Start → the solver's moves → "You won the race!" (9.4), +20 coins,
  // then system back shows 9.6 (Button unlocked) before rival select, the
  // Computer tag on every rival screen. ──
  await _raceRival1(tester, shots, board);
  await music.expectPlaying(MusicTrack.home);

  // ── Level 30, chapter 2's level 10: the milestone chest (E5, m7 §9,
  // §15.4; the owner's chest request). The win pays it (a kill loses
  // nothing); after Continue it arrives closed with its contents shown,
  // Open bursts it, and Collect flies the coins to the HUD's pill and the
  // hint to the Hint button, then level 31 loads on the same page. ──
  await board.jumpTo(30, 'Super Hard');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  expect(board.state.chest, isNotNull, reason: 'level 30 pays the chest');
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tester.tap(find.text('Continue'));
  await board.collectMilestoneChest(next: 31, shotPrefix: '19');

  // ── Level 31 (chapter 2): glass cases (spec §3.3) arrive here, on their
  // intro card (frame 4.2), the chest's Continue having loaded the level
  // under it. Red completes on the first move and breaks the case (the
  // levels lane's teaching order, checked with `Rules.tryMove`); the
  // solver's hints finish the level, so a re-tune of the rest of the board
  // (the owner's review, Q107) doesn't break the run. ──
  await board.dismissIntro(IntroMechanic.glass, shot: '20_l31_glass_intro');
  await shots.take('20_l31_board');
  // The case's slot events start as the family flies (t0 + 700, t0 = the
  // nest's landing at 667; `_planComplete`), and `fx_glass_unlock` shatters
  // 400 ms in (design/README.md motion): mid-shatter, shards flying.
  final unlock = await board.move('r1c0', 'r1c3');
  await board.shotAt('20b_l31_case_breaks', unlock, 667 + 700 + 430);
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('20c_l31_win');
  await board.continueTo(32);
  await board.openPause();
  await board.pauseToHome(level: 32);

  // ── Daily (frame 5.1; m3-design §10.5): level 2's win unlocked it
  // (m3-design §8.3), and it is still unsolved today (streak 0). It comes
  // after level 31 so that levels 16 and 31 each open on their own
  // mechanic's intro card, as they do for a player who skips the daily. ──
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await _routeSettled(tester, DailyPage);
  await _artReady(tester, 'the Daily preview');
  await shots.take('09a_daily_unlocked');

  // ── Daily win (frames 5.3–5.5; m3-design §8.4, §8.5): Play opens the
  // same gameplay page with the date pill (5.3). No move is scripted —
  // the puzzle is generated from the date (NESTY_FAKE_DATE's here, the
  // real one otherwise), so it can change with it — the solver's own
  // hints finish it instead (spec §6.3), the same
  // path level 9's Hint already exercised above.
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
  // brings towers and glass, whose cards levels 16 and 31 have shown by
  // now, so it opens with none (each card shows once per save, m3-design
  // §10.4). A date whose board meets a new mechanic first opens on its
  // cards, one after the other: each is shot and dismissed.
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
  // E3 (frame 10.1, D188): Share sits on the daily win card, above Back to
  // Daily. It is never tapped here: the OS share sheet can't be dismissed
  // from `flutter drive` (the host tests check the text it hands over).
  final share = find.bySemanticsLabel('Share today’s result');
  expect(share, findsOneWidget);
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

  // ── E3 and E4 (m7-design P3.10, P3.13, P4.6): the solved card (5.5) has
  // no Share (it moved to the win card, D188), and the one-time reminder
  // offer opens over it as a dialog (10.2). "No thanks" closes it: marked
  // offered, still off, nothing scheduled, and the OS never asked (only
  // "Yes, remind me" asks, which a device run never taps: iOS's permission
  // alert can't be tapped from here either). ──
  expect(share, findsNothing, reason: 'no Share on the solved card');
  const offerTitle = 'Want a note when tomorrow’s puzzle is ready?';
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isNotEmpty,
    reason: 'the reminder offer over the solved card',
  );
  expect(get<DatabaseService>().reminder.offered, isTrue);
  await tester.ensureVisible(find.text('No thanks'));
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('09a5_daily_offer');
  await tester.tap(find.text('No thanks'));
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isEmpty,
    reason: 'No thanks hides the offer',
  );
  final reminder = get<DatabaseService>().reminder;
  expect(reminder.offered && !reminder.on, isTrue, reason: '$reminder');
  expect(get<DailyReminder>().status.settings.on, isFalse);
  bool? pending;
  unawaited(
    get<NotificationService>().hasPendingDaily().then((p) => pending = p),
  );
  await tester.pumpUntil(
    () => pending != null,
    reason: 'the pending reminder read',
  );
  expect(pending, isFalse, reason: 'nothing scheduled after No thanks');
  await shots.take('09a5b_daily_solved');
  // 5.6's day-7 chest needs a 7-day streak, which one run with a fixed
  // `NESTY_FAKE_DATE` can't build: `daily_states_test.dart` (scenario
  // `chest`, a seeded 6-day streak) opens it on a device instead.

  await tester.tap(find.bySemanticsLabel('Back'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // Settings now shows the reminder row (the daily is unlocked, Q139), off
  // after "No thanks", with no time row (m7-design P3.10).
  await tester.tap(find.bySemanticsLabel('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings',
  );
  await _routeSettled(tester, SettingsPage);
  final reminderToggle = find.byWidgetPredicate(
    (widget) =>
        widget is NestyToggle && widget.semanticLabel == 'Daily reminder',
  );
  await tester.scrollUntilVisible(
    reminderToggle,
    200,
    scrollable: find
        .descendant(
          of: find.byType(SettingsPage),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  expect(tester.widget<NestyToggle>(reminderToggle).value, isFalse);
  expect(find.text('Time'), findsNothing, reason: 'no Time row while off');
  await shots.take('09a6_settings_reminder_off');
  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isEmpty,
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));

  // ── Level 51 (chapter 3): ice (spec §3.4) and its intro card (frame
  // 4.3), the first iced board this save meets. Navy completes on the
  // first move and shatters the ice (the teaching order); the hints finish
  // it. ──
  await board.jumpTo(51, 'Easy', idle: false);
  await board.dismissIntro(IntroMechanic.ice, shot: '21_l51_ice_intro');
  await shots.take('21a_l51_board');
  // As for the case: the ice's `shatter` segment starts as the family
  // flies (t0 + 700) and runs about 550 ms.
  final shatter = await board.move('r0c0', 'r2c0');
  await board.shotAt('21b_l51_ice_shatters', shatter, 667 + 700 + 230);
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('21c_l51_win');
  await board.continueTo(52);
  await board.openPause();
  await board.pauseToHome(level: 52);

  // ── Level 71 (chapter 4): size-5 dolls (spec §3.7), purple nested four
  // deep on the top shelf by the teaching order, then the hints finish it.
  // Taller dolls need no intro card. ──
  await board.jumpTo(71, 'Easy');
  await shots.take('22_l71_board');
  await board.playLine('r0c0>r0c3 r0c1>r0c3 r0c2>r0c3');
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('22a_l71_five_tall');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('22b_l71_win');
  await board.continueTo(72);
  await board.openPause();
  await board.pauseToHome(level: 72);

  // ── Level 130 (chapter 7): the first size-6 "super hard" level (spec
  // §3.7). The first five moves of its 26-move optimal line (the levels
  // lane's report) nest yellow 6-5-4-3 and teal 5-4-3-2-1, two size-6
  // families under way; the hints finish it. The level picker is shot
  // scrolled most of the way down: no tile over its title or Home (the
  // NestySheet clip fix). Level 130 is also chapter 7's chest level. ──
  await board.jumpTo(
    130,
    'Super Hard',
    pickerShot: '23a_level_picker_scrolled',
  );
  await shots.take('23_l130_board');
  await board.playLine('r0c1>r1c0 r0c1>r1c0 r2c2>r0c1 r0c2>r2c2 r0c2>r2c2');
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('23_l130_tall_nests');
  await board.solveWithHints();
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('23b_l130_win');
  await tester.tap(find.text('Continue'));
  await board.collectMilestoneChest(next: 131);
  await board.openPause();
  await board.pauseToHome(level: 131);
  // Chapters at chapter 7 (the owner's review): six finished chapters
  // folded, the current level standing out, the chest (level 10) and
  // finale (level 20) marks, and "Level 131 of 200".
  await _openChapters(tester);
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('23c_chapters_ch7');
  await _backFrom(tester, ChaptersPage);

  // ── Level 200, the grand finale and the last bundled level (chapter
  // 10's level 20; 35 moves, every mechanic): chapter complete, then All
  // Levels Done (frame 4.9) and its teal "Play Bonus Level 1" (frame
  // 4.10's HUD pill). ──
  await board.jumpTo(200, 'Super Hard');
  await board.solveWithHints(maxMoves: 50);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('24_l200_win');
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(ChapterCompleteOverlay).evaluate().isNotEmpty,
    reason: 'chapter 10 complete',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('24a_chapter_10_complete');
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
  // E13's clock (after the splash): it saw level 1 playable, and no later
  // than the loop did.
  expect(
    e13.playable,
    isNotNull,
    reason: 'E13: the poller saw level 1 playable (${e13.describe()})',
  );
  expect(
    e13.playable! <= loopPlayable,
    isTrue,
    reason: 'E13: the app-side mark is not after the loop',
  );
}

/// The rival-1 segment (m7-design P2.13, mode-vs-computer.md "Tests →
/// Integration"), from Home and back to it. The rival's pace comes from
/// `--dart-define=NESTY_RACE_PACE_MS=600000`, which only a dev debug build
/// honours (`RaceRules.parsePaceOverride`; README "Testing"): one rival
/// move every 10 minutes ± 20 %, so the player's solution always lands
/// first, while the rival stays as it plays (spec-prop §7.7).
Future<void> _raceRival1(
  WidgetTester tester,
  _Screenshots shots,
  _Board board,
) async {
  final config = get<RemoteConfigService>();
  expect(
    RaceRules.paceMs(1, config),
    600000,
    reason:
        'run with --dart-define=NESTY_RACE_PACE_MS=600000 (README "Testing")',
  );
  final save = get<SaveService>();
  expect(RaceRules.modeUnlocked(save.document.highestLevel, config), isTrue);
  expect(RaceRules.stageLevel(save.document.highestLevel), 20);
  final coinsBefore = save.document.coins;

  // 9.1: the tile, unlocked (the Computer tag under it), opens rival
  // select.
  final tile = find.descendant(
    of: find.byType(HomePage),
    matching: find.text('vs Computer'),
  );
  expect(tile, findsOneWidget);
  await shots.take('25_home_vs_computer');
  await tester.tap(tile);
  await tester.pumpUntil(
    () => find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'rival select',
  );
  await _routeSettled(tester, RivalSelectPage, settle: 400);
  // 9.2: three rivals, each with its Computer tag; only rival 1 can race
  // yet, selected, and one Start races the selected rival.
  expect(find.byType(ComputerTag), findsNWidgets(3));
  expect(find.text('Win 20 coins'), findsOneWidget);
  expect(find.text('Start'), findsOneWidget);
  await shots.take('25a_rival_select');

  // 9.3 before Start: the rival's strip in the HUD row, the Start button
  // over booster slots 2 and 3, no boosters.
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.isRace == true &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'the race board with its skin',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(save.document.race.rivals[0].raceNo, 1);
  final generated = Generator.generateWithRetries(
    DifficultyCurve.raceParams(rival: 1, raceNo: 1, highestWonLevel: 20),
  );
  expect(generated, isA<GeneratorSuccess>());
  expect(
    board.state.entry.level,
    (generated as GeneratorSuccess).level,
    reason: 'the race board is race-1-1@20',
  );
  expect(find.byType(RivalStrip), findsOneWidget);
  expect(find.byType(ComputerTag), findsOneWidget, reason: 'on the strip');
  expect(find.text('Ready when you are'), findsOneWidget);
  expect(find.text('Start'), findsOneWidget);
  for (final label in ['Hint', '+Slot']) {
    expect(find.text(label), findsNothing, reason: label);
  }
  await shots.take('25b_race_ready');

  // Start: no countdown; the solver's moves, tap by tap, while the rival
  // thinks.
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () => board.state.raceLive,
    reason: 'the race running',
  );
  await RaceSolver.play(
    RaceSolver.line(board.state.board),
    move: board.move,
    afterMove: (i) async {
      if (i != 1) return;
      await tester.pumpFor(const Duration(milliseconds: 300));
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Hint'), findsNothing);
      await shots.take('25c_race_running');
    },
  );

  // 9.4 once the winning batch has played: never 2.8's Continue. Two
  // buttons, New race and Rematch (lead note 9).
  await tester.pumpUntil(
    () => find.byType(RaceWinCard).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the race win card',
  );
  expect(find.byType(WinOverlay), findsNothing);
  // The ribbon's title is painted by the Lottie label (m7-4), not a Text.
  expect(
    find.byWidgetPredicate(
      (w) => w is VersusRibbon && w.title == 'You won the race!',
    ),
    findsOneWidget,
  );
  expect(save.document.coins, coinsBefore + 20, reason: 'race_reward_1');
  expect(save.document.race.rivals[0].wins, 1);
  expect(save.document.race.rivals[1].unlocked, isTrue);
  await tester.pumpFor(const Duration(milliseconds: 1500));
  expect(find.text('+20 coins'), findsOneWidget);
  expect(find.byType(ComputerTag), findsWidgets);
  expect(find.text('New race'), findsOneWidget);
  expect(find.text('Rematch'), findsOneWidget);
  expect(find.text('Back to races'), findsNothing);
  // m7-4 (`ui_rival_react`): Pebble's portrait nods (`lose`), and the
  // versus ribbon wears its named fills (4.3).
  expect(
    find.descendant(
      of: find.byType(RaceWinCard),
      matching: find.byType(RivalReact),
    ),
    findsOneWidget,
  );
  await shots.take('25d_race_win');
  // Past the first_race badge toast (2.5 s, over the card).
  await tester.pumpFor(const Duration(milliseconds: 3000));

  // System back is Back to races; the first win's 9.6 card comes first,
  // once per rival (Q131, D192), with jingle_reward as it lands. m7-4 4.1:
  // [Race Button] races the new rival, [Not now] carries on with what was
  // asked of 9.4 (here Back to races).
  await tester.binding.handlePopRoute();
  await tester.pumpUntil(
    () => find.byType(RivalUnlockedCard).evaluate().isNotEmpty,
    reason: 'the 9.6 card',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.text('New rival unlocked!'), findsOneWidget);
  expect(find.text('Race Button'), findsOneWidget);
  expect(find.text('Not now'), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(RivalUnlockedCard),
      matching: find.byType(ComputerTag),
    ),
    findsOneWidget,
  );
  await shots.take('25e_rival_unlocked');

  // Not now: back to rival select, where rival 2 can race now.
  await tester.tap(find.text('Not now'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'back to rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text('New'), findsOneWidget, reason: 'rival 2, not raced yet');
  expect(find.text('Start'), findsOneWidget);
  // m7-4 4.5: the New rival is the pick (9.2b).
  expect(
    tester
        .element(find.byType(RivalSelectView))
        .read<RivalSelectCubit>()
        .state
        .data!
        .selected,
    2,
  );
  await shots.take('25f_rival_select_after');
  await _backFrom(tester, RivalSelectPage);
  await tester.pumpUntil(
    () => find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Home after the race',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
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

/// E13 (brainstorm §3): on a fresh install, the time from `main()` to level
/// 1's first [playable] frame, and until it is [alone] on screen (the
/// splash's exit transition over), as `reportData`
/// (`build/integration_response_data.json`, kept by `nesty-test` as
/// `playthrough.json`; the driver also writes `e13.json` beside the
/// screenshots) and a `NESTY_E13` log line. The native launch before
/// `main()` isn't in it: the owner's device check notes the seconds from the
/// tap on the icon (Q114).
void _reportE13(
  IntegrationTestWidgetsFlutterBinding binding, {
  required Duration playable,
  required Duration alone,
  required Duration loopPlayable,
  required Duration loopAlone,
  required int? levelsCheckMs,
  required _E13Poller poller,
}) {
  // The bundle's decode and rules check is CPU only and unchanged between
  // runs, so its time is the host's speed: a quiet iOS simulator takes about
  // 200 ms and a quiet emulator about 550 ms (5f-startup). Twice that is a
  // busy host, and E13 is then flagged, not trusted.
  final quietMs = Platform.isAndroid ? 550 : 200;
  final noisy = levelsCheckMs == null || levelsCheckMs > 2 * quietMs;
  final data = {
    // From the 4 ms poller: the app's own time (5f-startup).
    'launchToLevel1PlayableMs': playable.inMilliseconds,
    'launchToLevel1AloneMs': alone.inMilliseconds,
    // As the test loop saw them, behind the screenshots (the old reading).
    'loopPlayableMs': loopPlayable.inMilliseconds,
    'loopAloneMs': loopAlone.inMilliseconds,
    'levelsCheckMs': levelsCheckMs,
    'quietLevelsCheckMs': quietMs,
    'noisy': noisy,
    // The poller's health: without a reading the two times above are the
    // loop's, and the test fails at its end.
    'pollerSaw': poller.playable != null,
    'pollerTicks': poller.ticks,
    'pollerErrors': poller.errors,
    'pollerFirstError': poller.firstError,
  };
  binding.reportData = {...?binding.reportData, 'e13': data};
  // ignore: avoid_print
  print('NESTY_E13 ${jsonEncode(data)}');
}

/// `[nesty.levels] checked 200 levels in N ms on …` from [logs], or null.
int? levelsCheckMs(List<String> logs) {
  final pattern = RegExp(r'\[nesty\.levels\] checked \d+ levels in (\d+) ms');
  for (final line in logs) {
    final match = pattern.firstMatch(line);
    if (match != null) return int.parse(match.group(1)!);
  }
  return null;
}

/// E13's clock: after every frame the app draws, it notes from the app's own
/// state the first frame level 1 is playable and the first frame the splash
/// is gone once it was seen. Per frame, not on a timer: a 4 ms timer walked
/// the tree only every ~38 ms on a busy host and missed level 1's playable
/// window before the tutorial locks the board (the iPhone, 2026-10-05 gate).
/// Its finders are unguarded (`evaluate()` and `read`, not `_tester.element`),
/// which a frame callback may call, and it never throws.
final class _E13Poller {
  _E13Poller(this._clock);

  final Stopwatch _clock;
  bool _running = false;
  bool _splashSeen = false;

  Duration? playable;
  Duration? alone;

  /// How many frames it looked at, how often a look threw, and the first.
  int ticks = 0;
  int errors = 0;
  String? firstError;

  String describe() =>
      'ticks $ticks, errors $errors'
      '${firstError == null ? '' : ', first: $firstError'}';

  void start() {
    _running = true;
    // A persistent callback can't be removed: once stopped it does nothing.
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      if (!_running) return;
      ticks++;
      try {
        _poll();
      } on Object catch (error) {
        errors++;
        firstError ??= '$error';
      }
    });
  }

  void stop() => _running = false;

  void _poll() {
    final splashUp = find.byType(SplashPage).evaluate().isNotEmpty;
    if (splashUp) _splashSeen = true;
    playable ??= _levelOnePlayable() ? _clock.elapsed : null;
    if (playable != null && _splashSeen && !splashUp) {
      alone ??= _clock.elapsed;
    }
    if (playable != null && alone != null) stop();
  }

  /// The same condition as `_Board.playable(1)`.
  bool _levelOnePlayable() {
    final views = find.byType(GameplayView).evaluate();
    if (views.isEmpty) return false;
    final widgets = find.byType(GameWidget<NestyGame>).evaluate();
    if (widgets.isEmpty) return false;
    final data = views.first.read<GameplayBloc>().state.data;
    if (data == null || data.levelNumber != 1) return false;
    final game = (widgets.first.widget as GameWidget<NestyGame>).game;
    final timeline = game?.board.timeline;
    return game != null &&
        game.geometry != null &&
        game.skin != null &&
        timeline != null &&
        game.board.board == data.board &&
        timeline.isIdle &&
        !timeline.inputLocked;
  }
}

/// The gameplay skin's landing after a route push (BACKLOG M7, architecture
/// §4 row 875): [skinLand] from the tap to the level's own skin on the
/// board, [routeDone] to the route's transition end, as `reportData`
/// (`skinLand`, kept by `nesty-test` in `playthrough.json`) and a
/// `NESTY_SKIN_LAND` log line. Recorded, not held to a threshold here: the
/// device stage judges it against the 400 ms fade.
void _reportSkinLand(
  IntegrationTestWidgetsFlutterBinding binding, {
  required int level,
  required Duration skinLand,
  required Duration routeDone,
}) {
  final data = {
    'level': level,
    'skinLandMs': skinLand.inMilliseconds,
    'routeDoneMs': routeDone.inMilliseconds,
  };
  binding.reportData = {...?binding.reportData, 'skinLand': data};
  // ignore: avoid_print
  print('NESTY_SKIN_LAND ${jsonEncode(data)}');
}

/// Home's chapter card (frame 2.1, Q92): it opens Chapters.
Future<void> _openChapters(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel(RegExp(r'Opens Chapters\.$')));
  await tester.pumpUntil(
    () => find.byType(ChaptersPage).evaluate().isNotEmpty,
    reason: 'Chapters from the chapter card',
  );
  await _routeSettled(tester, ChaptersPage, settle: 400);
}

/// Home's Records button (frame 2.1) opens [page].
Future<void> _openFromHome(WidgetTester tester, String label, Type page) async {
  await tester.tap(
    find.descendant(of: find.byType(HomePage), matching: find.text(label)),
  );
  await tester.pumpUntil(
    () => find.byType(page).evaluate().isNotEmpty,
    reason: label,
  );
  await _routeSettled(tester, page, settle: 400);
}

/// [page]'s route has finished its transition in, then [settle] ms more. A
/// fixed wait can be short on a slow device: the platform's page transition
/// (a slide on iOS) was still showing the screen under Settings at 300 ms.
Future<void> _routeSettled(
  WidgetTester tester,
  Type page, {
  int settle = 200,
}) async {
  await tester.pumpUntil(() {
    final element = find.byType(page).evaluate().firstOrNull;
    if (element == null) return false;
    return ModalRoute.of(element)?.animation?.isCompleted ?? false;
  }, reason: 'the $page transition in');
  await tester.pumpFor(Duration(milliseconds: settle));
}

/// [page]'s own header back arrow, back to Home.
Future<void> _backFrom(WidgetTester tester, Type page) async {
  await tester.tap(
    find.descendant(
      of: find.byType(page),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(page).evaluate().isEmpty,
    reason: 'back from $page',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
}

/// `starsSemantics(count)`, the one semantics node of every `StarRow`
/// (m7-design P3.7).
String _starsLabel(int count) => '$count of 3 stars';

/// The tutorial's HUD (m7-4 8.1, `layout.tutorial`): Pause takes taps
/// through the scrim's hole, and the step's tip ([step] its chip) sits in
/// the HUD row, its top above Pause's bottom.
void _expectTutorialHud(WidgetTester tester, String step) {
  final pause = find.bySemanticsLabel('Pause');
  expect(pause.hitTestable(), findsOneWidget, reason: 'Pause through the hole');
  expect(
    tester.getTopLeft(find.text(step)).dy,
    lessThan(tester.getBottomLeft(pause).dy),
    reason: 'the tip in the HUD row',
  );
}

/// `starsFirstTip`, the one-time tip under the first win below 3 stars.
const String _starTip =
    'Fewer moves earn more stars. Replay any level from Chapters.';

/// Plays [line] (`from>to` moves separated by spaces) on [start] with
/// core's own rules: every move must be legal, and only the last one wins.
void _expectLegalWinningLine(GameState start, String line) {
  var state = start;
  final steps = line.split(' ');
  for (var i = 0; i < steps.length; i++) {
    final [from, to] = steps[i].split('>');
    final result = Rules.tryMove(state, Move(from, to));
    expect(result, isA<MoveApplied>(), reason: '${steps[i]} is legal');
    state = (result as MoveApplied).state;
    expect(
      state.isWon,
      i == steps.length - 1,
      reason: 'only the last move of "$line" wins',
    );
  }
}

/// The bottom nav's own label, apart from any other "Museum" or "Shop"
/// text on screen (the Museum's own heading, the Shop's).
Finder _nav(String label) => find.descendant(
  of: find.byType(NestyBottomNav),
  matching: find.text(label),
);

/// A Museum cabinet figurine's modal (frames 6.2, 6.3), by the niche's
/// screen-reader label (6.1, copy.md m7-4 A11y: "The Classic Family, home in
/// your Museum", "The Classic Family, next to come home. 19 levels to go.",
/// "The Baker Family, not home yet. Chapter 3.").
Future<void> _openFigurine(WidgetTester tester, Pattern label) async {
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

  /// Level [number]'s board takes input: laid out with its own art, and the
  /// timeline idle and unlocked (E13's "first playable frame").
  bool playable(int number) {
    if (find.byType(GameplayView).evaluate().isEmpty) return false;
    if (_gameWidget.evaluate().isEmpty) return false;
    final data = bloc.state.data;
    if (data == null || data.levelNumber != number) return false;
    final timeline = game.board.timeline;
    return game.geometry != null &&
        game.skin != null &&
        timeline != null &&
        game.board.board == data.board &&
        timeline.isIdle &&
        !timeline.inputLocked;
  }

  /// Plays [line], tap-tap moves written `from>to` and separated by spaces.
  Future<void> playLine(String line) async {
    for (final step in line.split(' ')) {
      final [from, to] = step.split('>');
      await move(from, to);
    }
  }

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

  /// Home's dev "Jump to a level" picker (dev flavor): level [number],
  /// whose tile is labelled with its [tier]. The picker scrolls (200
  /// levels, grouped by chapter), so the tile is scrolled into view first;
  /// [pickerShot] names a screenshot of the sheet right then. With [idle]
  /// false it returns once the board is laid out with its art, for a level
  /// that opens on an intro card.
  Future<void> jumpTo(
    int number,
    String tier, {
    Duration settle = const Duration(milliseconds: 800),
    String? pickerShot,
    bool idle = true,
  }) async {
    final picker = find.byType(LevelPickerSheet);
    await _tester.tap(find.text('Jump to a level'));
    await _tester.pumpUntil(
      () => picker.evaluate().isNotEmpty,
      reason: 'the level picker',
    );
    await _tester.pumpFor(const Duration(milliseconds: 500));
    final tile = find.descendant(of: picker, matching: find.text('$number'));
    await _tester.ensureVisible(tile);
    await _tester.pumpFor(const Duration(milliseconds: 400));
    expect(
      find.bySemanticsLabel('Level $number · $tier'),
      findsOneWidget,
      reason: 'level $number is $tier',
    );
    if (pickerShot != null) await _shots.take(pickerShot);
    await _tester.tap(tile);
    if (idle) {
      await waitForLevel(number, settle: settle);
      return;
    }
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isNotEmpty &&
          bloc.state.data?.levelNumber == number &&
          game.geometry != null &&
          game.skin != null,
      timeout: const Duration(seconds: 30),
      reason: 'level $number with its skin',
    );
  }

  /// The board opened on [mechanic]'s intro card (frames 4.1–4.3,
  /// m3-design §10.4) and no other: [shot] once the card has settled, then
  /// "Got it" dismisses it and the board takes input.
  Future<void> dismissIntro(
    IntroMechanic mechanic, {
    required String shot,
  }) async {
    await _tester.pumpUntil(
      () => state.intro == mechanic,
      reason: 'the ${mechanic.name} intro card',
    );
    expect(find.byType(IntroMechanicCard), findsOneWidget);
    await _tester.pumpFor(const Duration(milliseconds: 600));
    await _shots.take(shot);
    await _tester.tap(find.text('Got it'));
    await _tester.pumpUntil(
      () => state.intro == null,
      reason: 'the ${mechanic.name} intro card dismissed',
    );
    await waitIdle();
    await _tester.pumpFor(const Duration(milliseconds: 300));
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

  /// The first win's Continue (E9, m7-design §13): Home, which offers
  /// [level], never the next board.
  Future<void> continueHome({required int level}) async {
    await _tester.tap(find.text('Continue'));
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isEmpty &&
          find.byType(HomePage).evaluate().isNotEmpty &&
          find.bySemanticsLabel('Play level $level').evaluate().isNotEmpty,
      timeout: const Duration(seconds: 30),
      reason: 'Home with level $level after the first win (E9)',
    );
  }

  /// The milestone chest after a chest level's Continue (E5, m7 §15.4, the
  /// owner-chest sequence): it arrives closed with its contents shown, Open
  /// bursts it and Collect flies the coins to the HUD's pill and the hint
  /// to the Hint button; then level [next] loads on the same page. With
  /// [shotPrefix], four screenshots: closed, mid-burst, open, coins flying.
  Future<void> collectMilestoneChest({
    required int next,
    String? shotPrefix,
  }) async {
    await _tester.pumpUntil(
      () => find.byType(MilestoneChestModal).evaluate().isNotEmpty,
      reason: 'the milestone chest',
    );
    await _tester.pumpFor(
      const Duration(milliseconds: ChestRewardSequence.arrivalMs + 300),
    );
    if (shotPrefix != null) await _shots.take('${shotPrefix}a_chest_closed');
    await _tester.tap(find.text('Open'));
    await _tester.pumpFor(
      const Duration(milliseconds: ChestRewardSequence.wiggleMs + 250),
    );
    if (shotPrefix != null) await _shots.take('${shotPrefix}b_chest_burst');
    await _tester.pumpUntil(
      () => find.text('Collect').evaluate().isNotEmpty,
      reason: 'the chest open',
    );
    await _tester.pumpFor(const Duration(milliseconds: 500));
    if (shotPrefix != null) await _shots.take('${shotPrefix}c_chest_open');
    final previousSkin = game.skin;
    await _tester.tap(find.text('Collect'));
    await _tester.pumpFor(
      const Duration(
        milliseconds:
            ChestRewardSequence.collectFlightMs ~/ 2 +
            2 * ChestRewardSequence.collectStaggerMs,
      ),
    );
    if (shotPrefix != null) {
      await _shots.take('${shotPrefix}d_chest_coins_flying');
    }
    await _tester.pumpUntil(
      () => find.byType(MilestoneChestModal).evaluate().isEmpty,
      timeout: const Duration(seconds: 10),
      reason: 'the chest collected',
    );
    await waitForLevel(next, previousSkin: previousSkin);
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
