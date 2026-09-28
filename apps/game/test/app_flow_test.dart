import 'dart:async';
import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import 'core/ui/support/ui_harness.dart';
import 'helpers/test_dependencies.dart';

/// The main flow on the whole app over the fake DI graph (spec §10.1;
/// m2-lottie-design §17 "Screens and UI"): Splash → Home → PLAY → the board
/// laid out with its HUD and boosters, taking a tap → Pause → Home, with
/// the music following it (AUDIO.md "Music rules"): home after the splash,
/// game in the level, ducked under Pause, home again.
///
/// The same path runs on a simulator with the real services in
/// `integration_test/playthrough_test.dart`.
void main() {
  setUpAll(loadBundledFonts);
  setUp(configureTestDependencies);
  tearDown(resetDependencies);

  /// Pumps past route transitions without settling: once the `GameWidget`
  /// is up, Flame schedules a frame every tick.
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  testWidgets('boots through Splash to Home, plays level 1, pauses and '
      'goes Home', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final music = get<MusicService>() as FakeMusicService;

    await tester.pumpWidget(App(router: get<AppRouter>()));
    // The router parses the initial route asynchronously.
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('Dusting the shelves…'), findsOneWidget);
    expect(music.calls, isEmpty, reason: 'the splash is silent');

    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    expect(music.calls, [const MusicCall.playHome()]);
    final play = find.bySemanticsLabel('Play level 1');
    expect(play, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(play);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(music.calls.last, const MusicCall.playGame());
    for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    // The board is up: the Flame game laid level 1 out (2 shelves × 3
    // slots, frame 2.2) and has a slot component for each.
    final gameWidget = find.byType(GameWidget<NestyGame>);
    expect(gameWidget, findsOneWidget);
    final game = tester.widget<GameWidget<NestyGame>>(gameWidget).game!;
    final geometry = game.geometry;
    expect(geometry, isNotNull);
    expect(geometry!.shelves, hasLength(2));
    expect(geometry.slots.map((s) => s.id), [
      'r0c0',
      'r0c1',
      'r0c2',
      'r1c0',
      'r1c1',
      'r1c2',
    ]);
    expect(game.board.slots.keys, containsAll(geometry.slots.map((s) => s.id)));

    // A tap on red2's column goes Flutter gestures → Flame → the bloc,
    // which lifts it (spec §2.2 tap–tap).
    final bloc = tester.element(find.byType(GameplayView)).read<GameplayBloc>();
    final red2 = geometry.slot('r0c2');
    await tester.tapAt(
      tester.getTopLeft(gameWidget) +
          Offset(red2.centerX, geometry.shelves[red2.row].hitCenterY),
    );
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(bloc.state.data!.selectedSlotId, 'r0c2');
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(music.ducking, {DuckReason.pause});

    await tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Home'),
      ),
    );
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    // Nothing was won: Home still offers level 1.
    expect(get<SaveService>().currentLevel, 1);
    expect(find.bySemanticsLabel('Play level 1'), findsOneWidget);
    expect(music.track, MusicTrack.home);
    expect(music.ducking, isEmpty, reason: 'the dialog went with the level');
    expect(music.calls, [
      const MusicCall.playHome(),
      const MusicCall.playGame(),
      const MusicCall.duck(DuckReason.pause),
      const MusicCall.playHome(),
      const MusicCall.unduck(DuckReason.pause),
    ]);
    expect(tester.takeException(), isNull);
  });

  /// The bottom nav's own label, disambiguated from same-named text
  /// elsewhere on the page (Home's Museum tile also reads "Museum").
  Finder navLabel(String label) => find.descendant(
    of: find.byType(NestyBottomNav),
    matching: find.text(label),
  );

  /// Settles [future] when its work spans both clocks: real disk I/O
  /// (`HiveDatabaseService`, `HiveSaveService`'s write queue) completes on
  /// the real event loop, but the continuations registered from inside
  /// `testWidgets`' fake-async zone only run when it pumps. So neither
  /// `tester.runAsync` alone nor pumping alone finishes it; alternating the
  /// two does.
  Future<void> settle(WidgetTester tester, Future<void> future) async {
    var done = false;
    unawaited(future.whenComplete(() => done = true));
    for (var i = 0; i < 200 && !done; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(done, isTrue, reason: 'the disk work settled');
  }

  testWidgets(
    '(a) resume: PLAY continues the saved board after a full teardown and '
    'rebuild on the same Hive dir',
    (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final tempDir = Directory.systemTemp.createTempSync('nesty_resume');
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      // The fake env's in-memory `SaveService`/`DatabaseService` are swapped
      // for the real Hive-backed ones on a temp directory, so the "kill and
      // relaunch" is a real round trip through disk (the same override
      // pattern `app_router_test.dart` uses for one service). Everything
      // else stays the fake env's doubles. Opening Hive and resetting DI
      // are real I/O, so they run under `tester.runAsync`.
      Future<void> bootOnTempDir() async {
        await tester.runAsync(() async {
          await configureTestDependencies();
          final database = await HiveDatabaseService.open(
            directory: tempDir.path,
          );
          await get.unregister<DatabaseService>();
          get.registerSingleton<DatabaseService>(database);
          final save = HiveSaveService(database, get<RemoteConfigService>());
          await get.unregister<SaveService>();
          get.registerSingleton<SaveService>(save);
        });
        await tester.pumpWidget(App(router: get<AppRouter>()));
        await tester.pump();
        await pumpFor(tester, const Duration(seconds: 1));
        expect(find.byType(HomePage), findsOneWidget);
      }

      /// Home's PLAY, which resumes the saved board when there is one
      /// (m3-design §3.4).
      Future<GameplayBloc> playLevel3() async {
        // Level 3's label names its tier ("Play level 3, Hard").
        await tester.tap(find.bySemanticsLabel(RegExp(r'^Play level 3\b')));
        await pumpFor(tester, const Duration(seconds: 1));
        expect(find.byType(GameplayPage), findsOneWidget);
        return tester.element(find.byType(GameplayView)).read<GameplayBloc>();
      }

      Future<void> send(GameplayBloc bloc, GameplayEvent event) async {
        bloc.add(event);
        await pumpFor(tester, const Duration(milliseconds: 400));
      }

      // --- First launch: Home's PLAY on level 3 (past the L1/L2 tutorial),
      // two moves, undo one, add an extra slot. ---
      await bootOnTempDir();
      get<SaveService>().currentLevel = 3;
      await pumpFor(tester, const Duration(milliseconds: 300));
      final bloc = await playLevel3();
      final start = bloc.state.data!;
      // L0003 (`FixtureLevels`): red1 (r1c2) into red2 (r2c1), then yellow1
      // (r0c1) into yellow2 (r1c0). Neither completes a set (each needs a
      // third doll), so the history survives and nothing is won.
      for (final slot in ['r1c2', 'r2c1', 'r0c1', 'r1c0']) {
        await send(bloc, SlotTapped(slot));
      }
      await send(bloc, const UndoPressed());
      await send(bloc, const ExtraSlotPressed());

      final before = bloc.state.data!;
      expect(before.status, GameplayStatus.playing);
      // The red move stands (red2 holds red1 too); the undone yellow move
      // doesn't (yellow1 is back on its own slot).
      expect(before.board.slot('r1c2').isEmpty, isTrue);
      expect(before.board.slot('r2c1').nests.single.length, 2);
      expect(before.board.slot('r0c1').isEmpty, isFalse);
      expect(
        before.freeUndosLeft,
        start.freeUndosLeft - 1,
        reason: 'one free undo spent',
      );

      // --- "Kill": unmount the app (closing every page cubit and the
      // bloc), let the write queue land on disk and close Hive. The
      // relaunch below drops the whole DI graph. ---
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await settle(tester, get<SaveService>().flush());
      await settle(tester, get<DatabaseService>().close());

      // --- Relaunch on the SAME Hive dir: PLAY picks the board back up. ---
      await bootOnTempDir();
      expect(get<SaveService>().currentLevel, 3, reason: 'progress persisted');
      final restoredBloc = await playLevel3();
      final after = restoredBloc.state.data!;
      expect(after.restored, isTrue);
      expect(after.board, before.board, reason: 'the identical board');
      expect(after.freeUndosLeft, before.freeUndosLeft, reason: 'undos left');
      expect(
        after.extraSlotsLeft,
        before.extraSlotsLeft,
        reason: 'extra slots left',
      );
      final restoredGame = tester
          .widget<GameWidget<NestyGame>>(find.byType(GameWidget<NestyGame>))
          .game!;
      // The board lays the restored +1 Slot out too (3×3 plus `x0`).
      expect(
        restoredGame.geometry!.slots.map((s) => s.id),
        contains('x0'),
        reason: '+1 slot',
      );
      expect(tester.takeException(), isNull);

      // Nothing left in flight for the teardown's DI reset.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await settle(tester, get<SaveService>().flush());
      await settle(tester, get<DatabaseService>().close());
    },
  );

  testWidgets('(b) Home -> Daily -> back; Daily -> Play -> Pause -> Home', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The daily unlocks after Level 2 (m3-design §8.3); a fresh save would
    // show its locked state instead.
    await get.unregister<SaveService>();
    get.registerSingleton<SaveService>(
      FakeSaveService(
        initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
      ),
    );

    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.text('Daily Puzzle'));
    await tester.pumpAndSettle();
    expect(find.byType(DailyView), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(DailyView), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.text('Daily Puzzle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsOneWidget);

    // The fake date's daily brings towers and glass in, so it opens on
    // their intro cards one after the other (m3-design §10.4), each holding
    // input until dismissed.
    for (var i = 0; i < 4 && find.text('Got it').evaluate().isNotEmpty; i++) {
      await tester.tap(find.text('Got it'));
      await pumpFor(tester, const Duration(milliseconds: 500));
    }
    expect(find.text('Got it'), findsNothing);

    // Pause's Home goes to the Home tab, past Daily (m3-design §1 routes).
    await tester.tap(find.bySemanticsLabel('Pause'));
    await pumpFor(tester, const Duration(milliseconds: 400));
    await tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Home'),
      ),
    );
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsNothing);
    expect(find.byType(DailyView), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('(g) a daily win: Back to Daily returns to the Daily screen', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Unlocked (Level 2 won), and hints that never run out: the solver's
    // own hints win the generated daily without scripting its board.
    await get.unregister<SaveService>();
    get.registerSingleton<SaveService>(
      FakeSaveService(
        unlimitedBoosters: true,
        initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
      ),
    );

    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('Daily Puzzle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await pumpFor(tester, const Duration(seconds: 1));
    for (var i = 0; i < 4 && find.text('Got it').evaluate().isNotEmpty; i++) {
      await tester.tap(find.text('Got it'));
      await pumpFor(tester, const Duration(milliseconds: 500));
    }

    final bloc = tester.element(find.byType(GameplayView)).read<GameplayBloc>();
    for (var i = 0; i < 40; i++) {
      if (bloc.state.data!.status != GameplayStatus.playing) break;
      bloc.add(const HintPressed());
      await pumpFor(tester, const Duration(milliseconds: 300));
      final hint = bloc.state.data!.hint;
      expect(hint, isNotNull, reason: 'hint $i');
      bloc.add(SlotTapped(hint!.from));
      await pumpFor(tester, const Duration(milliseconds: 200));
      bloc.add(SlotTapped(hint.to));
      await pumpFor(tester, const Duration(milliseconds: 900));
    }
    expect(bloc.state.data!.status, GameplayStatus.won);
    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.text('Back to Daily'), findsOneWidget);

    // The page's own PopScope turns a maybePop into Pause; this must pop.
    await tester.tap(find.text('Back to Daily'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsNothing);
    expect(find.byType(DailyView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // A 16:9 Android phone's body is too short for frame 2.1's fixed tile y:
  // the tiles must still sit fully above the nav (found on the API 35
  // emulator's 411x731, where they hid under it).
  for (final size in const [Size(411, 731), Size(360, 640)]) {
    testWidgets(
      '(h) Home at ${size.width.toInt()}x${size.height.toInt()}: the tiles '
      'stay above the nav',
      (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1
          ..padding = const FakeViewPadding(top: 24);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(App(router: get<AppRouter>()));
        await tester.pump();
        await pumpFor(tester, const Duration(seconds: 1));
        expect(find.byType(HomePage), findsOneWidget);

        final nav = tester.getRect(find.byType(NestyBottomNav));
        final tiles = find.byType(HomeTile);
        expect(tiles, findsNWidgets(3));
        for (var i = 0; i < 3; i++) {
          expect(
            tester.getRect(tiles.at(i)).bottom,
            lessThanOrEqualTo(nav.top),
            reason: 'tile $i',
          );
        }
        // PLAY stays above the tiles.
        expect(
          tester.getRect(find.bySemanticsLabel('Play level 1')).bottom,
          lessThanOrEqualTo(tester.getRect(tiles.first).top),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('(c) Home -> Museum tab', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));

    await tester.tap(navLabel('Museum'));
    await tester.pumpAndSettle();
    expect(find.byType(MuseumPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('(d) Home -> Shop tab -> Skins', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));

    await tester.tap(navLabel('Shop'));
    await tester.pumpAndSettle();
    expect(find.byType(ShopPage), findsOneWidget);
    // ShopPage's default `initialTab` is Skins (frame 7.3).
    expect(find.text('Skins'), findsOneWidget);
    expect(find.byType(SkinGridCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('(e) Settings toggles', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));

    await tester.tap(find.bySemanticsLabel('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(SettingsPage), findsOneWidget);

    final database = get<DatabaseService>();
    expect(database.soundEnabled, isTrue);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is NestyToggle && w.semanticLabel == 'Sound',
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.soundEnabled, isFalse);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('(f) Pause -> Settings -> back to the paused level', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));

    final play = find.bySemanticsLabel('Play level 1');
    await tester.tap(play);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.byType(PauseDialog), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(SettingsPage), findsOneWidget);
    // The level stays paused underneath (m3-design §10.1).
    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.byType(PauseDialog), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
