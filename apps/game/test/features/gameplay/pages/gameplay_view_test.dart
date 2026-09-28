import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/controlled_skin_service.dart';
import '../../support/screen_harness.dart';
import '../bloc/support/bloc_fixtures.dart';
import '../bloc/support/scripted_level_resolver.dart';
import '../bloc/support/scripted_solver_service.dart';

/// Half the chapter ribbon's width at rest on its canvas: 380 dp (LOTTIE.md
/// v3 "Ribbons": 336 band + 22 dp tails each side).
const double _ribbonRestHalfWidth = 190;

/// The page on a real bloc over fakes, with a recording board in place of
/// Flame: the test plays the board's side (its layouts and reports).
final class _Screen {
  _Screen._(
    this.bloc,
    this.factory,
    this.database,
    this.homes,
    this.music,
    this.jingles,
  );

  final GameplayBloc bloc;
  final FakeBoardFactory factory;
  final FakeDatabaseService database;
  final List<int> homes;
  final FakeMusicService music;
  final FakeAudioService jingles;

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
  PlayRequest? request,
  bool drivesOutcomes = true,
  ScriptedSolverService? solver,
  SkinService? skins,
  FakeRemoteConfigService? config,
  SaveService? save,
  LevelResolver? resolver,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = false,
  Future<void> Function(FakeDatabaseService database)? onSettings,
}) async {
  // The board shape only (id T0001, never gated by the M3 tutorial script,
  // which keys on the real L0001/L0002 ids, m3-design §10.4): tests that
  // aren't specifically about the tutorial use this instead of the real
  // `tutorialLevel`/`L0001`, so a scripted cue never silently swallows their
  // taps (bloc lane's known_issues on this file).
  final used = entries ?? [entryFor(defaultLevel)];
  final usedRequest = request ?? PlayRequest.campaign(level);
  final bloc = buildBloc(
    entries: used,
    solver: solver,
    config: config,
    save: save,
    resolver: resolver,
  );
  addTearDown(bloc.close);
  final factory = FakeBoardFactory(drivesOutcomes: drivesOutcomes);
  final database = FakeDatabaseService();
  final homes = <int>[];
  final music = FakeMusicService();
  final jingles = FakeAudioService();
  final jingleCues = JingleCues(music, jingles);
  addTearDown(jingleCues.dispose);
  await pumpScreen(
    tester,
    BlocProvider.value(
      value: bloc..add(GameplayStarted(usedRequest)),
      child: GameplayView(
        request: usedRequest,
        services: GameplayServices(
          skins: skins ?? FakeSkinService(),
          levels: FakeLevelRepository(entries: used),
          resolver: resolverOf(bloc),
          save: saveOf(bloc),
          database: database,
          fx: FakeFxLibrary(),
          feedback: RecordingCues(),
          music: music,
          jingles: jingles,
          jingleCues: jingleCues,
        ),
        onHome: () => homes.add(1),
        onSettings: () async => onSettings?.call(database),
        boardFactory: factory.call,
      ),
    ),
    size: size,
    textScale: textScale,
    reduceMotion: reduceMotion,
  );
  await tester.pump();
  return _Screen._(bloc, factory, database, homes, music, jingles);
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
    final second = levelFrom(defaultLevelJson);
    final screen = await _pump(
      tester,
      entries: [entryFor(defaultLevel), entryFor(second, order: 2)],
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
        entries: [entryFor(defaultLevel), entryFor(redBlue, order: 2)],
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
    final second = levelFrom(defaultLevelJson);
    final screen = await _pump(
      tester,
      entries: [entryFor(defaultLevel), entryFor(second, order: 2)],
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
    // `canUndo` only means "there is a move in history" (`session.canUndo`,
    // m3-design §7.3): under the M3 coin-offer economy it stays true with 0
    // free undos (the press opens the offer instead), so the only way
    // there is genuinely nothing to undo is a completing move, which clears
    // the history outright (spec §2.4). Two families, one of which
    // completes in a single move while the other stays untouched, so the
    // board keeps playing (not won) with an empty history.
    final level = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T0201",
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
    final screen = await _pump(
      tester,
      entries: [entryFor(level)],
      solver: ScriptedSolverService(
        onSoftStuck: (state) =>
            state.moveCount > 0 ? SolveVerdict.unsolvable : SolveVerdict.solved,
      ),
    );
    // r0c2 (red2 over red1) onto r0c0 (red3): the red family completes.
    await screen.move(tester, 'r0c2', 'r0c0');
    await _settle(tester);
    expect(screen.state.status, GameplayStatus.playing, reason: 'blue is left');
    expect(screen.state.softStuck, isTrue);
    expect(
      screen.state.canUndo,
      isFalse,
      reason: 'the completing move cleared the history (spec §2.4)',
    );
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

  group('a Continue whose next level fails (review CORRECTNESS-3)', () {
    // Bonus Endless: bonus 2 can't be made (the resolver answers null, as
    // for a generator/isolate failure), so NextLevelPressed ends in an
    // AsyncValueError that still carries the won state.
    ScriptedLevelResolver failingBonus() => ScriptedLevelResolver(
      entries: {
        const PlayRequest.bonus(1): playEntryFor(
          const PlayRequest.bonus(1),
          defaultLevel,
        ),
      },
      nextOf: (request) => switch (request) {
        BonusPlay(:final number) => PlayRequest.bonus(number + 1),
        _ => null,
      },
    );

    Finder inFailure(String text) => find.descendant(
      of: find.byKey(const ValueKey(GameplayOverlay.continueFailed)),
      matching: find.text(text),
    );

    testWidgets('offers Try again, which retries, and Back to Home', (
      tester,
    ) async {
      final resolver = failingBonus();
      final screen = await _pump(
        tester,
        request: const PlayRequest.bonus(1),
        resolver: resolver,
      );
      await _win(tester, screen);
      screen.board.callbacks.onWon();
      await _settle(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      expect(screen.bloc.state, isA<AsyncValueError<GameplayState>>());
      expect(inFailure('Something went wrong.'), findsOneWidget);
      expect(inFailure('Try again'), findsOneWidget);
      expect(inFailure('Back to Home'), findsOneWidget);

      // Still failing: the card stays, and Try again works again.
      await tester.tap(inFailure('Try again'));
      await _settle(tester);
      expect(inFailure('Try again'), findsOneWidget);

      // The generator recovers: Try again plays bonus 2.
      resolver.entries[const PlayRequest.bonus(2)] = playEntryFor(
        const PlayRequest.bonus(2),
        levelFrom(defaultLevelJson),
      );
      await tester.tap(inFailure('Try again'));
      await _settle(tester);
      expect(screen.state.play.request, const PlayRequest.bonus(2));
      expect(screen.state.status, GameplayStatus.playing);
      expect(
        find.byKey(const ValueKey(GameplayOverlay.continueFailed)),
        findsNothing,
      );
      expect(screen.board.overlayOpen, isFalse);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets("Chapter complete's Continue gets the same card", (
      tester,
    ) async {
      final screen = await _pump(
        tester,
        entries: [entryFor(defaultLevel, chapterId: 'ch01')],
        resolver: ScriptedLevelResolver(
          entries: {
            const PlayRequest.campaign(1): playEntryFor(
              const PlayRequest.campaign(1),
              defaultLevel,
              chapterId: 'ch01',
              completesChapter: true,
            ),
          },
          nextOf: (_) => const PlayRequest.campaign(2),
        ),
      );
      await _win(tester, screen);
      screen.board.callbacks.onWon();
      await _settle(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      expect(find.text('CHAPTER 1 COMPLETE'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      expect(find.text('CHAPTER 1 COMPLETE'), findsNothing);
      expect(inFailure('Try again'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Back to Home and the back button leave', (tester) async {
      final screen = await _pump(
        tester,
        request: const PlayRequest.bonus(1),
        resolver: failingBonus(),
      );
      await _win(tester, screen);
      screen.board.callbacks.onWon();
      await _settle(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      await tester.tap(inFailure('Back to Home'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.homes, hasLength(1));
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.homes, hasLength(2));
    });
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

  group('music (AUDIO.md "Music rules")', () {
    testWidgets('the page never picks a track itself (the route observer '
        'does), and nothing ducks without an overlay', (tester) async {
      final screen = await _pump(tester);
      await screen.move(tester, red2, red3);
      await _settle(tester);
      expect(screen.music.calls, isEmpty);
      expect(screen.jingles.jingles, isEmpty);
    });

    testWidgets('the win overlay ducks the music to 0.3 while it is up; '
        'Continue brings it back', (tester) async {
      final second = levelFrom(defaultLevelJson);
      final screen = await _pump(
        tester,
        entries: [entryFor(defaultLevel), entryFor(second, order: 2)],
      );
      await _win(tester, screen);
      expect(screen.music.ducking, isEmpty, reason: 'the set still flies');
      screen.board.callbacks.onWon();
      await _settle(tester);
      expect(screen.music.calls, [const MusicCall.duck(DuckReason.win)]);
      expect(DuckReason.win.factor, SoundTokens.musicDuckWin);

      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.state.levelNumber, 2);
      expect(screen.music.ducking, isEmpty);
      expect(screen.music.calls, [
        const MusicCall.duck(DuckReason.win),
        const MusicCall.unduck(DuckReason.win),
      ]);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('out of moves: the sheet ducks the music to 0.4 and plays '
        'jingle_oom once the duck is in; closing it lifts the duck', (
      tester,
    ) async {
      final screen = await _pump(
        tester,
        entries: [entryFor(outOfMovesLevel)],
        // The board's tower would otherwise lock input behind the unseen
        // "towers" intro card (m3-design §10.4): this test is about the
        // out-of-moves sheet, not the card.
        save: saveWithIntrosSeen(),
      );
      await screen.move(tester, 'r0c0', 'r0c3');
      screen.board.callbacks.onOutOfMoves();
      await tester.pump();
      expect(screen.music.ducking, {DuckReason.outOfMoves});
      expect(screen.jingles.jingles, isEmpty);
      await tester.pump(
        const Duration(milliseconds: SoundTokens.musicFadeDuckInMs),
      );
      expect(screen.jingles.jingles, [Jingle.outOfMoves]);

      await tester.tap(find.text('Take back your last move'));
      await _settle(tester);
      expect(find.text('No moves left!'), findsNothing);
      expect(screen.music.ducking, isEmpty);
      expect(screen.jingles.jingles, [Jingle.outOfMoves], reason: 'once');
    });

    testWidgets('a sheet open when the chapter ribbon leaves keeps its duck '
        'and plays jingle_oom once', (tester) async {
      final screen = await _pump(
        tester,
        entries: [
          entryFor(defaultLevel),
          entryFor(outOfMovesLevel, order: 2, chapterId: 'ch02'),
        ],
        level: 2,
        save: saveWithIntrosSeen(),
      );
      expect(find.byType(ChapterRibbon), findsOneWidget);
      await screen.move(tester, 'r0c0', 'r0c3');
      screen.board.callbacks.onOutOfMoves();
      await tester.pump();
      expect(find.text('No moves left!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(ChapterRibbon), findsNothing);
      expect(find.text('No moves left!'), findsOneWidget);
      expect(screen.music.calls, [const MusicCall.duck(DuckReason.outOfMoves)]);
      expect(screen.jingles.jingles, [Jingle.outOfMoves]);
    });

    testWidgets('a sheet dismissed before the duck is in plays no jingle', (
      tester,
    ) async {
      final screen = await _pump(
        tester,
        entries: [entryFor(outOfMovesLevel)],
        drivesOutcomes: false,
        save: saveWithIntrosSeen(),
      );
      await screen.move(tester, 'r0c0', 'r0c3');
      await tester.pump();
      expect(screen.music.ducking, {DuckReason.outOfMoves});
      await tester.tapAt(const Offset(195, 100));
      await _settle(tester);
      expect(screen.music.ducking, isEmpty);
      expect(screen.jingles.jingles, isEmpty);
    });

    testWidgets('Pause ducks the music to 0.5; Resume lifts it', (
      tester,
    ) async {
      final screen = await _pump(tester);
      await tester.tap(find.bySemanticsLabel('Pause'));
      await _settle(tester);
      expect(screen.music.ducking, {DuckReason.pause});
      await tester.tap(find.text('Resume'));
      await _settle(tester);
      expect(screen.music.ducking, isEmpty);
      expect(screen.music.calls, [
        const MusicCall.duck(DuckReason.pause),
        const MusicCall.unduck(DuckReason.pause),
      ]);
    });

    testWidgets("Pause's Music toggle writes the setting, which the music "
        'service follows; Sound gates the SFX and jingles as they play', (
      tester,
    ) async {
      final screen = await _pump(tester);
      final changes = <bool>[];
      final subscription = screen.database.musicEnabledChanges.listen(
        changes.add,
      );
      addTearDown(subscription.cancel);
      await tester.tap(find.bySemanticsLabel('Pause'));
      await _settle(tester);

      await tester.tap(find.bySemanticsLabel('Music'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(screen.database.musicEnabled, isFalse);
      expect(changes, [false]);
      await tester.tap(find.bySemanticsLabel('Music'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(changes, [false, true]);

      await tester.tap(find.bySemanticsLabel('Sound'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(screen.database.soundEnabled, isFalse);
      // The page never calls setEnabled itself: one path, the setting.
      expect(
        screen.music.calls.map((c) => c.command),
        isNot(contains(MusicCommand.setEnabled)),
      );
    });
  });

  // Review CORRECTNESS-4: Settings is a route over the level, and its
  // toggles are the same settings as the pause dialog's.
  testWidgets('Pause → Settings → back: the dialog re-reads the toggles and '
      'the board takes the new Color symbols, with its art re-prepared', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    final back = Completer<void>();
    var opened = 0;
    final screen = await _pump(
      tester,
      skins: skins,
      onSettings: (database) async {
        opened++;
        await database.setMusicEnabled(false);
        await database.setSymbolsMode(SymbolsMode.large);
        await back.future;
      },
    );
    screen.board.layOut(screen.state.board);
    skins.complete(0);
    await tester.pump();
    expect(screen.board.symbols, DollSymbols.subtle);
    expect(skins.requests.single.symbols, DollSymbols.subtle);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await _settle(tester);
    PauseSettings dialogSettings() =>
        tester.widget<PauseDialog>(find.byType(PauseDialog)).settings;
    expect(dialogSettings().music, isTrue);
    await tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Settings'),
      ),
    );
    await tester.pump();
    expect(opened, 1);

    back.complete();
    await _settle(tester);
    expect(dialogSettings().music, isFalse);
    expect(screen.board.symbols, DollSymbols.large);
    expect(skins.requests, hasLength(2));
    expect(skins.requests.last.symbols, DollSymbols.large);
    skins.complete(1);
    await tester.pump();
    expect(screen.board.skins.last, same(skins.made[1]));
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
    final screen = await _pump(
      tester,
      entries: [entryFor(outOfMovesLevel)],
      save: saveWithIntrosSeen(),
    );
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

  group('a restored outcome (review CORRECTNESS-1)', () {
    // The board only reports outcomes after playing a move's batch, and a
    // restore is a start reset: the page opens the overlay itself.
    testWidgets('a board saved out of moves opens its sheet again, and its '
        'undo plays', (tester) async {
      final save = saveWithIntrosSeen();
      final stuck = GameSession(outOfMovesLevel)..move('r0c0', 'r0c3');
      save.saveInProgress(
        InProgressLevel(
          request: const PlayRequest.campaign(1),
          levelId: outOfMovesLevel.id,
          levelVersion: 1,
          session: GameSessionCodec.encode(stuck),
        ),
      );
      final screen = await _pump(
        tester,
        entries: [entryFor(outOfMovesLevel)],
        save: save,
      );
      await _settle(tester);
      expect(screen.state.status, GameplayStatus.outOfMoves);
      expect(find.text('No moves left!'), findsOneWidget);
      expect(screen.board.overlayOpen, isTrue);

      await tester.tap(find.text('Take back your last move'));
      await _settle(tester);
      expect(find.text('No moves left!'), findsNothing);
      expect(screen.state.status, GameplayStatus.playing);
      expect(screen.board.overlayOpen, isFalse);
    });

    testWidgets('a board saved won opens the win overlay with its reward', (
      tester,
    ) async {
      final save = FakeSaveService();
      final won = GameSession(defaultLevel)
        ..move(red1, red2)
        ..move(red2, red3);
      save.saveInProgress(
        InProgressLevel(
          request: const PlayRequest.campaign(1),
          levelId: defaultLevel.id,
          levelVersion: 1,
          session: GameSessionCodec.encode(won),
        ),
      );
      final screen = await _pump(
        tester,
        entries: [
          entryFor(defaultLevel),
          entryFor(levelFrom(defaultLevelJson), order: 2),
        ],
        save: save,
      );
      await _settle(tester);
      expect(screen.state.status, GameplayStatus.won);
      expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.state.levelNumber, 2);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('out of moves: the sheet\'s prices come from the state '
      '(m3-design §7.3, frame 3.5)', () {
    Future<void> openSheet(
      WidgetTester tester, {
      required int extraSlots,
      FakeRemoteConfigService? config,
    }) async {
      // `free_undos_per_level` is read through the save's Remote Config.
      final save = FakeSaveService(remoteConfig: config);
      while (save.boosterCount(BoosterKind.extraSlot) > extraSlots) {
        save.useBooster(BoosterKind.extraSlot);
      }
      for (final mechanic in IntroMechanic.values) {
        save.markIntroSeen(mechanic);
      }
      final screen = await _pump(
        tester,
        entries: [entryFor(outOfMovesLevel)],
        save: save,
        config: config,
      );
      await screen.move(tester, 'r0c0', 'r0c3');
      screen.board.callbacks.onOutOfMoves();
      await _settle(tester);
      expect(find.text('No moves left!'), findsOneWidget);
    }

    Finder inSheet(String text) => find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text(text),
    );

    testWidgets('free undos spent and no +1 Slot held: price_undo and '
        'price_slot', (tester) async {
      await openSheet(
        tester,
        extraSlots: 0,
        config: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 0),
      );
      expect(
        inSheet('${RemoteConfigKeys.priceUndo.defaultValue}'),
        findsOneWidget,
      );
      expect(
        inSheet('${RemoteConfigKeys.priceSlot.defaultValue}'),
        findsOneWidget,
      );
      expect(inSheet('0'), findsNothing);
    });

    testWidgets('a +1 Slot held: no price on its row', (tester) async {
      await openSheet(tester, extraSlots: 1);
      expect(
        inSheet('${RemoteConfigKeys.priceSlot.defaultValue}'),
        findsNothing,
      );
      expect(inSheet('0'), findsNothing);
    });
  });

  testWidgets('a dismissed sheet stays closed until moves run out again', (
    tester,
  ) async {
    final screen = await _pump(
      tester,
      entries: [entryFor(outOfMovesLevel)],
      drivesOutcomes: false,
      save: saveWithIntrosSeen(),
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
    final second = levelFrom(defaultLevelJson);
    await _pump(
      tester,
      entries: [
        entryFor(defaultLevel),
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

  group('Chapter complete (4.6) and the daily win variant (5.4)', () {
    testWidgets('a win that completes its chapter opens Chapter complete after '
        'Continue, which then loads the next level (m3-design §9.3)', (
      tester,
    ) async {
      final second = levelFrom(defaultLevelJson);
      final resolver = ScriptedLevelResolver(
        entries: {
          const PlayRequest.campaign(1): playEntryFor(
            const PlayRequest.campaign(1),
            defaultLevel,
            chapterId: 'ch01',
            completesChapter: true,
            rewardCoins: 10,
          ),
          const PlayRequest.campaign(2): playEntryFor(
            const PlayRequest.campaign(2),
            second,
            chapterId: 'ch02',
          ),
        },
        nextOf: (_) => const PlayRequest.campaign(2),
      );
      final screen = await _pump(
        tester,
        entries: [
          entryFor(defaultLevel, chapterId: 'ch01'),
          entryFor(second, order: 2, chapterId: 'ch02'),
        ],
        resolver: resolver,
      );
      await _win(tester, screen);
      screen.board.callbacks.onFamilyLanded(1, 1, 1.5);
      await tester.pump();
      screen.board.callbacks.onWon();
      await _settle(tester);
      expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await _settle(tester);
      // Chapter complete, not the next level yet.
      expect(find.bySemanticsLabel('Level Complete!'), findsNothing);
      expect(screen.state.levelNumber, 1);
      expect(find.text('CHAPTER 1 COMPLETE'), findsOneWidget);
      // The figurine just earned, not the chapter (review FIDELITY-1).
      expect(find.text('The Classic Family'), findsOneWidget);
      expect(find.text('Added to your Museum!'), findsOneWidget);
      expect(find.text('+150 coins'), findsOneWidget);
      expect(find.text('Next: Chapter 2 · Rainy Café Corner'), findsOneWidget);
      // JingleCues.chapterComplete() faded the music out at once.
      expect(screen.music.calls, contains(const MusicCall.stopForChapter()));

      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(screen.music.calls, contains(const MusicCall.playGame()));
      expect(screen.state.levelNumber, 2);
      expect(find.text('CHAPTER 1 COMPLETE'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('a daily win: "Daily solved!", the streak card instead of the '
        'chapter card, and "Back to Daily" (frame 5.4)', (tester) async {
      const request = PlayRequest.daily(20260926);
      final resolver = ScriptedLevelResolver(
        entries: {
          request: playEntryFor(request, defaultLevel, rewardCoins: 50),
        },
      );
      final screen = await _pump(tester, request: request, resolver: resolver);
      await _win(tester, screen);
      screen.board.callbacks.onFamilyLanded(1, 1, 1.5);
      await tester.pump();
      screen.board.callbacks.onWon();
      await _settle(tester);
      expect(find.bySemanticsLabel('Daily solved!'), findsOneWidget);
      expect(find.bySemanticsLabel('Level Complete!'), findsNothing);
      expect(find.text('1-day streak'), findsOneWidget);
      expect(find.byType(WinChapterCard), findsNothing);
      expect(find.text('Back to Daily'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });

  group('The purchase-offer popup, the tutorial overlay and intro cards '
      '(m3-design §7.3, §10.4)', () {
    testWidgets('a booster press with none left opens its buy popup; Buy '
        'and Dismiss send the bloc events', (tester) async {
      final screen = await _pump(
        tester,
        save: FakeSaveService(
          initial: const SaveDocument(inventory: BoosterInventory(hint: 0)),
        ),
      );
      await tester.tap(find.text('Hint'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BoosterBuyPopup), findsOneWidget);
      expect(screen.state.acceptsInput, isFalse);

      await tester.tap(find.byType(NestyCloseButton));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BoosterBuyPopup), findsNothing);
      expect(screen.state.offer, isNull);
    });

    testWidgets('an unseen mechanic opens its intro card; Got it dismisses '
        'it', (tester) async {
      final screen = await _pump(tester, entries: [entryFor(outOfMovesLevel)]);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IntroMechanicCard), findsOneWidget);
      expect(find.text('Towers!'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IntroMechanicCard), findsNothing);
      expect(screen.state.intro, isNull);
    });

    testWidgets("the intro card draws the level's own art, in the level's "
        'colours (review FIDELITY-6)', (tester) async {
      final skins = ControlledSkinService();
      final screen = await _pump(
        tester,
        entries: [entryFor(outOfMovesLevel)],
        skins: skins,
      );
      await tester.pump(const Duration(milliseconds: 300));
      IntroMechanicCard card() =>
          tester.widget<IntroMechanicCard>(find.byType(IntroMechanicCard));
      expect(card().skin, isNull, reason: 'before the art has landed');
      expect(card().levelColors, [DollColor.red, DollColor.blue]);

      screen.board.layOut(screen.state.board);
      final skin = skins.complete(0);
      await tester.pump();
      expect(card().skin, same(skin));
    });

    testWidgets('the scripted tutorial move draws the scrim, the hand and '
        'the tooltip', (tester) async {
      final screen = await _pump(tester, entries: [entryFor(tutorialLevel)]);
      screen.board.layOut(screen.state.board);
      await tester.pump();
      expect(find.byType(TutorialOverlay), findsOneWidget);
    });
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
        final second = levelFrom(defaultLevelJson);
        await _pump(
          tester,
          entries: [
            entryFor(defaultLevel),
            entryFor(second, order: 2, chapterId: 'ch02'),
          ],
          level: 2,
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final ribbon = tester.getRect(find.byType(ChapterRibbon));
        // The canvas 1:1 on the design's 390 dp screen, scaled down on
        // narrower ones and never up (LOTTIE.md v3 "Ribbons").
        final ribbonScale = math.min(1.0, size.width / 390);
        expect(
          ribbon.size,
          within(distance: 1e-9, from: ChapterRibbon.canvas * ribbonScale),
        );
        expect(ribbon.center.dx, closeTo(size.width / 2, 1e-9));
        // The ribbon at rest is 380 dp of the canvas' width: on screen.
        // Only its 106 % pop may pass a 390 dp edge, by up to 6 dp.
        expect(
          ribbon.center.dx - _ribbonRestHalfWidth * ribbonScale,
          greaterThanOrEqualTo(-1e-9),
        );
        expect(
          ribbon.center.dx + _ribbonRestHalfWidth * ribbonScale,
          lessThanOrEqualTo(size.width + 1e-9),
        );
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
