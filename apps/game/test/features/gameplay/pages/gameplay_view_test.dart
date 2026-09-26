import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/controlled_skin_service.dart';
import '../../support/screen_harness.dart';
import '../bloc/support/bloc_fixtures.dart';
import '../bloc/support/scripted_solver_service.dart';

/// The page on a real bloc over fakes, with a recording board in place of
/// Flame: the test plays the board's side (its layouts and reports).
final class _Screen {
  _Screen._(this.bloc, this.factory, this.database, this.homes);

  final GameplayBloc bloc;
  final FakeBoardFactory factory;
  final FakeDatabaseService database;
  final List<int> homes;

  FakeGameplayBoard get board => factory.board!;
  GameplayState get state => bloc.state.data!;

  /// A tap on [slot], as the board forwards it.
  Future<void> tap(WidgetTester tester, String slot) async {
    board.callbacks.onIntent(SlotTapped(slot));
    // Past the bloc's soft-stuck debounce (5 ms in tests).
    await tester.pump(const Duration(milliseconds: 20));
  }

  /// Moves [from] → [to] by two taps.
  Future<void> move(WidgetTester tester, String from, String to) async {
    await tap(tester, from);
    await tap(tester, to);
  }
}

Future<_Screen> _pump(
  WidgetTester tester, {
  List<LevelBundleEntry>? entries,
  int level = 1,
  bool drivesOutcomes = true,
  ScriptedSolverService? solver,
  SkinService? skins,
  FakeRemoteConfigService? config,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  final used = entries ?? [entryFor(tutorialLevel)];
  final bloc = buildBloc(entries: used, solver: solver, config: config);
  addTearDown(bloc.close);
  final factory = FakeBoardFactory(drivesOutcomes: drivesOutcomes);
  final database = FakeDatabaseService();
  final homes = <int>[];
  await pumpScreen(
    tester,
    BlocProvider.value(
      value: bloc..add(GameplayStarted(level)),
      child: GameplayView(
        levelNumber: level,
        services: GameplayServices(
          skins: skins ?? FakeSkinService(),
          levels: FakeLevelRepository(entries: used),
          database: database,
          fx: FakeFxLibrary(),
          feedback: RecordingCues(),
        ),
        onHome: () => homes.add(1),
        boardFactory: factory.call,
      ),
    ),
    size: size,
    textScale: textScale,
    reduceMotion: reduceMotion,
  );
  await tester.pump();
  return _Screen._(bloc, factory, database, homes);
}

/// The tutorial won: red2 into red3, then red1 into both (the board's
/// reports come from the test).
Future<void> _win(WidgetTester tester, _Screen screen) async {
  await screen.move(tester, red2, red3);
  await screen.move(tester, red1, red3);
  expect(screen.state.status, GameplayStatus.won);
}

/// Builds what the last change asked for, then plays the overlay
/// entrances and banners to their end (`tokens.motion.ui` ≤ 280 ms).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('starts the level on the board with the HUD and boosters', (
    tester,
  ) async {
    final screen = await _pump(tester);
    expect(screen.board.applied.single, isA<BoardResetEffect>());
    expect(
      (screen.board.applied.single as BoardResetEffect).reason,
      BoardResetReason.start,
    );
    expect(screen.board.padding, safeAreaOf(const Size(390, 844)));
    expect(screen.board.reduceMotion, isFalse);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.bySemanticsLabel('0 of 1 family done'), findsOneWidget);
    for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('prepares the art for each layout the board reports', (
    tester,
  ) async {
    final screen = await _pump(tester);
    expect(screen.board.skins, isEmpty);
    screen.board.layOut(screen.state.board);
    await tester.pump();
    expect(screen.board.skins, hasLength(1));
    expect(screen.board.skins.single, isNotNull);
  });

  testWidgets('forwards the board intents and plays every effect', (
    tester,
  ) async {
    final screen = await _pump(tester);
    await screen.tap(tester, red2);
    expect(screen.state.selectedSlotId, red2);
    expect(screen.board.applied.last, isA<SelectionChangedEffect>());
    await screen.tap(tester, red3);
    expect(screen.board.applied.last, isA<MoveAppliedEffect>());
  });

  testWidgets('win: the counter bumps when the family lands, the overlay '
      'opens when the board has played it, Continue loads the next level', (
    tester,
  ) async {
    final second = levelFrom(tutorialLevelJson);
    final screen = await _pump(
      tester,
      entries: [entryFor(tutorialLevel), entryFor(second, order: 2)],
    );
    await _win(tester, screen);
    // The bloc has won, but the board is still playing the batch.
    expect(find.bySemanticsLabel('0 of 1 family done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    screen.board.callbacks.onFamilyLanded(1, 1, 1.5);
    await tester.pump();
    expect(find.bySemanticsLabel('1 of 1 family done'), findsOneWidget);

    screen.board.callbacks.onWon();
    await _settle(tester);
    expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
    expect(screen.board.overlayOpen, isTrue);
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(screen.state.levelNumber, 2);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Level 2'), findsOneWidget);
    expect(screen.board.overlayOpen, isFalse);
    expect(
      (screen.board.applied.last as BoardResetEffect).reason,
      BoardResetReason.start,
    );
    expect(find.bySemanticsLabel('0 of 1 family done'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  group('Continue and the next level\'s art (review CORRECTNESS-1)', () {
    // L2 adds blue: L1's skin holds only red, and a colour a skin lacks
    // draws nothing, so L2 must never show with L1's skin.
    final redBlue = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T0102",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["red2", "red1"]} ],
    [ {"type": "open", "nest": ["blue2", "blue1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');

    Future<(_Screen, ControlledSkinService)> wonLevel1(
      WidgetTester tester,
    ) async {
      final skins = ControlledSkinService();
      final screen = await _pump(
        tester,
        entries: [entryFor(tutorialLevel), entryFor(redBlue, order: 2)],
        skins: skins,
      );
      screen.board.layOut(screen.state.board);
      skins.complete(0);
      await tester.pump();
      expect(screen.board.skins, [skins.made[0]]);
      await _win(tester, screen);
      screen.board.callbacks.onFamilyLanded(1, 1, 1.5);
      screen.board.callbacks.onWon();
      await _settle(tester);
      return (screen, skins);
    }

    testWidgets('the win overlay prepares the next level for the board\'s '
        'layout; Continue waits for it, and the layout the board reports '
        'adopts it in the same frame', (tester) async {
      final (screen, skins) = await wonLevel1(tester);
      expect(skins.requests, hasLength(2));
      expect(skins.requests[1].level, redBlue);

      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.state.levelNumber, 1, reason: 'the art is on its way');
      expect(find.text('Continue'), findsOneWidget);

      final next = skins.complete(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(screen.state.levelNumber, 2);
      expect(
        (screen.board.applied.last as BoardResetEffect).reason,
        BoardResetReason.start,
      );
      // The board lays level 2 out: its art is handed over at once, before
      // any frame, and nothing is asked for again.
      screen.board.layOut(screen.state.board);
      expect(screen.board.skins.last, same(next));
      expect(skins.requests, hasLength(2));
      expect(skins.made[0].disposed, isTrue);
      expect(next.disposed, isFalse);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('art that is slow to land never holds Continue for long '
        '(rule 3); the board adopts it when it lands', (tester) async {
      final (screen, skins) = await wonLevel1(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump(GameplayView.nextArtWait);
      await tester.pump(const Duration(milliseconds: 50));
      expect(screen.state.levelNumber, 2);
      screen.board.layOut(screen.state.board);
      expect(screen.board.skins, [skins.made[0]], reason: 'still preparing');
      final next = skins.complete(1);
      await tester.pump();
      expect(screen.board.skins.last, same(next));
      expect(skins.requests, hasLength(2), reason: 'the same request');
      await tester.pump(const Duration(seconds: 2));
    });
  });

  testWidgets('won: the HUD and the booster bar keep their look while the '
      'set flies, and take no touch (frame 2.5, review FIDELITY-2)', (
    tester,
  ) async {
    final screen = await _pump(tester);
    await _win(tester, screen);
    await tester.pump();
    final pause = tester.widget<IconTactileButton>(
      find.byType(IconTactileButton),
    );
    expect(pause.onPressed, isNotNull);
    final restart = tester.widget<BoosterButton>(
      find.widgetWithText(BoosterButton, 'Restart'),
    );
    expect(restart.onPressed, isNotNull);
    await tester.tap(find.bySemanticsLabel('Pause'), warnIfMissed: false);
    await tester.tap(find.text('Restart'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsNothing);
    expect(screen.state.status, GameplayStatus.won);
    expect(screen.board.applied.last, isA<MoveAppliedEffect>());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('won: the HUD keeps the old balance until the next level '
      '(frames 1.5 and 2.8, Q57)', (tester) async {
    final second = levelFrom(tutorialLevelJson);
    final screen = await _pump(
      tester,
      entries: [entryFor(tutorialLevel), entryFor(second, order: 2)],
    );
    int hudCoins() => tester.widget<CoinPill>(find.byType(CoinPill)).coins;
    final before = screen.state.coins;
    expect(hudCoins(), before);

    await _win(tester, screen);
    final reward = screen.state.winReward;
    expect(reward, greaterThan(0));
    expect(screen.state.coins, before + reward);
    // The set is still flying: the bloc has paid, the HUD hasn't.
    expect(hudCoins(), before);

    screen.board.callbacks.onFamilyLanded(1, 1, 1.5);
    screen.board.callbacks.onWon();
    await _settle(tester);
    // Past the overlay's count-up (700 ms + 600 ms).
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Continue'), findsOneWidget);
    expect(hudCoins(), before);

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(screen.state.levelNumber, 2);
    expect(hudCoins(), before + reward);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('soft stuck with nothing to undo suggests Restart, and Undo '
      'doesn\'t glow (review FIDELITY-6)', (tester) async {
    final screen = await _pump(
      tester,
      // No free undos: Undo can't help (the coin path is M3).
      config: FakeRemoteConfigService()
        ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 0),
      solver: ScriptedSolverService(
        onSoftStuck: (state) =>
            state.moveCount > 0 ? SolveVerdict.unsolvable : SolveVerdict.solved,
      ),
    );
    await screen.move(tester, red2, red3);
    await _settle(tester);
    expect(screen.state.softStuck, isTrue);
    expect(screen.state.canUndo, isFalse);
    expect(find.text('Try Restart? You can keep playing too.'), findsOneWidget);
    expect(find.byType(BoosterGlow), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(SoftStuckBanner),
        matching: find.text('Restart'),
      ),
    );
    await _settle(tester);
    expect(
      (screen.board.applied.last as BoardResetEffect).reason,
      BoardResetReason.restart,
    );
    expect(screen.state.softStuck, isFalse);
    expect(find.text('Hmm, this looks stuck'), findsNothing);
  });

  testWidgets('Continue after the last level shows All Levels Done (4.9)', (
    tester,
  ) async {
    final screen = await _pump(tester);
    await _win(tester, screen);
    screen.board.callbacks.onWon();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.state.status, GameplayStatus.allLevelsDone);
    expect(find.text("You've finished all levels!"), findsOneWidget);
    await tester.tap(find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(screen.homes, hasLength(1));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a board without a timeline: outcomes follow the bloc', (
    tester,
  ) async {
    final screen = await _pump(tester, drivesOutcomes: false);
    await _win(tester, screen);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('1 of 1 family done'), findsOneWidget);
    expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('pause: locks the level, Resume unlocks, Restart restarts', (
    tester,
  ) async {
    final screen = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Level 1 · Easy'), findsOneWidget);
    expect(screen.state.paused, isTrue);
    expect(screen.board.paused, isTrue);

    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsNothing);
    expect(screen.state.paused, isFalse);
    expect(screen.board.paused, isFalse);

    await screen.move(tester, red2, red3);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Restart'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsNothing);
    expect(
      (screen.board.applied.last as BoardResetEffect).reason,
      BoardResetReason.restart,
    );
    expect(screen.state.board.moveCount, 0);
  });

  testWidgets('pause toggles write the settings; Home leaves', (tester) async {
    final screen = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await _settle(tester);
    final sound = screen.database.soundEnabled;
    await tester.tap(find.bySemanticsLabel('Sound'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.database.soundEnabled, !sound);
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(screen.homes, hasLength(1));
  });

  testWidgets('the back button and leaving the app open the pause dialog', (
    tester,
  ) async {
    await _pump(tester);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsNothing);

    // Hidden, the app draws no frames; the dialog is there on return.
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _settle(tester);
    expect(find.text('Paused'), findsOneWidget);
  });

  testWidgets('out of moves: the sheet opens on the board report and its '
      'rows act', (tester) async {
    final screen = await _pump(tester, entries: [entryFor(outOfMovesLevel)]);
    await screen.move(tester, 'r0c0', 'r0c3');
    expect(screen.state.status, GameplayStatus.outOfMoves);
    expect(find.text('No moves left!'), findsNothing);

    screen.board.callbacks.onOutOfMoves();
    await _settle(tester);
    expect(find.text('No moves left!'), findsOneWidget);
    expect(screen.board.overlayOpen, isTrue);

    await tester.tap(find.text('Take back your last move'));
    await _settle(tester);
    expect(find.text('No moves left!'), findsNothing);
    expect(screen.board.overlayOpen, isFalse);
    expect(
      (screen.board.applied.last as BoardResetEffect).reason,
      BoardResetReason.undo,
    );
  });

  testWidgets('a dismissed sheet stays closed until moves run out again', (
    tester,
  ) async {
    final screen = await _pump(
      tester,
      entries: [entryFor(outOfMovesLevel)],
      drivesOutcomes: false,
    );
    await screen.move(tester, 'r0c0', 'r0c3');
    await _settle(tester);
    expect(find.text('No moves left!'), findsOneWidget);
    await tester.tapAt(const Offset(195, 100));
    await _settle(tester);
    expect(find.text('No moves left!'), findsNothing);
    // Another touch changes the state but not the dead end.
    await screen.tap(tester, 'r0c1');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No moves left!'), findsNothing);
  });

  testWidgets('soft stuck shows the banner and it undoes (3.4)', (
    tester,
  ) async {
    final screen = await _pump(
      tester,
      // Stuck after the move (moveCount 1); solvable again after Undo,
      // which re-checks.
      solver: ScriptedSolverService(
        onSoftStuck: (state) =>
            state.moveCount > 0 ? SolveVerdict.unsolvable : SolveVerdict.solved,
      ),
    );
    await screen.move(tester, red2, red3);
    await _settle(tester);
    expect(screen.state.softStuck, isTrue);
    expect(find.text('Hmm, this looks stuck'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(SoftStuckBanner),
        matching: find.text('Undo'),
      ),
    );
    await _settle(tester);
    expect(screen.state.softStuck, isFalse);
    expect(find.text('Hmm, this looks stuck'), findsNothing);
  });

  testWidgets('the first level of a chapter names it (4.7, L21)', (
    tester,
  ) async {
    final second = levelFrom(tutorialLevelJson);
    await _pump(
      tester,
      entries: [
        entryFor(tutorialLevel),
        entryFor(second, order: 2, chapterId: 'ch02'),
      ],
      level: 2,
    );
    await tester.pump();
    expect(find.byType(ChapterRibbon), findsOneWidget);
    expect(
      find.bySemanticsLabel('CHAPTER 2 · Rainy Café Corner'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(ChapterRibbon), findsNothing);
  });

  testWidgets('the first chapter opens without a ribbon', (tester) async {
    await _pump(tester);
    await tester.pump();
    expect(find.byType(ChapterRibbon), findsNothing);
  });

  testWidgets('reduced motion reaches the board (D48)', (tester) async {
    final screen = await _pump(tester, reduceMotion: true);
    expect(screen.board.reduceMotion, isTrue);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        final screen = await _pump(tester, size: size, textScale: scale);
        expectNoLayoutErrors(tester);
        await tester.tap(find.bySemanticsLabel('Pause'));
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        await tester.tap(find.text('Resume'));
        await tester.pump(const Duration(milliseconds: 300));
        await _win(tester, screen);
        screen.board.callbacks.onWon();
        await tester.pump(const Duration(seconds: 2));
        expectNoLayoutErrors(tester);
      });

      testWidgets('the chapter ribbon fits ${size.width.toInt()} wide at '
          '$scale× text', (tester) async {
        final second = levelFrom(tutorialLevelJson);
        await _pump(
          tester,
          entries: [
            entryFor(tutorialLevel),
            entryFor(second, order: 2, chapterId: 'ch02'),
          ],
          level: 2,
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final ribbon = tester.getRect(find.byType(ChapterRibbon));
        expect(ribbon.left, greaterThanOrEqualTo(0));
        expect(ribbon.right, lessThanOrEqualTo(size.width));
        // Over the top shelf, clear of the HUD's family counter.
        expect(
          ribbon.center.dy,
          safeAreaOf(size).top + ChapterRibbon.centerTop,
        );
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }
}
