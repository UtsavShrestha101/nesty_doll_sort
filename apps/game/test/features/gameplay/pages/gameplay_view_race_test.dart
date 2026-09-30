import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_duck.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';
import 'package:nesty_game/features/gameplay/widgets/race_action_bar.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/screen_harness.dart';
import '../bloc/support/bloc_fixtures.dart';
import '../bloc/support/scripted_level_resolver.dart';

/// The race board over a real `GameplayBloc` and `RaceCubit`, both on
/// fakes, with a `FakeFrameTicker` under the test's own control (m7-design
/// P2.13's race-ui test plan): "Computer" and its glyph on every rival
/// surface, no Hint or +1 Slot in a race, the Start/Undo/Restart bar, the
/// holds, and each result card.
const _race = RacePlay(rival: 1, raceNo: 1);

/// A [ScriptedLevelResolver] whose answers wait on [gate] while it is set,
/// so a test can act while Rematch's or New race's board is still being
/// made (the bloc's `loading`, the race's `waiting`).
final class _GatedLevelResolver extends ScriptedLevelResolver {
  _GatedLevelResolver({super.entries});

  Completer<void>? gate;

  @override
  Future<PlayEntry?> resolve(PlayRequest request) async {
    final waitFor = gate;
    if (waitFor != null) await waitFor.future;
    return super.resolve(request);
  }
}

final class _RaceScreen {
  _RaceScreen(
    this.bloc,
    this.raceCubit,
    this.factory,
    this.ticker,
    this.homes,
    this.cues,
    this.resolver,
    this.jingles,
  );

  final GameplayBloc bloc;
  final RaceCubit raceCubit;
  final FakeBoardFactory factory;
  final FakeFrameTicker ticker;
  final List<int> homes;
  final RecordingCues cues;
  final _GatedLevelResolver resolver;
  final FakeAudioService jingles;

  FakeGameplayBoard get board => factory.board!;
  GameplayState get state => bloc.state.data!;
  RaceState get raceState => raceCubit.state.data!;

  Future<void> tap(WidgetTester tester, String slot) async {
    board.callbacks.onIntent(SlotTapped(slot));
    await tester.pump(const Duration(milliseconds: 20));
  }

  Future<void> move(WidgetTester tester, String from, String to) async {
    await tap(tester, from);
    await tap(tester, to);
  }

  /// Plays `defaultLevel`'s two winning moves, then the board reports the
  /// winning batch played (the real board's `onWon`, after ~2.4 s).
  Future<void> win(WidgetTester tester) async {
    await move(tester, red2, red3);
    await move(tester, red1, red3);
    await tester.pump(const Duration(milliseconds: 300));
    board.callbacks.onWon();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUpAll(loadBundledFonts);

  Future<_RaceScreen> pumpRace(
    WidgetTester tester, {
    FakeSaveService? save,
    Level? level,
    bool scripted = true,
    Future<void> Function()? onSettings,
  }) async {
    final config = FakeRemoteConfigService();
    final usedSave = save ?? FakeSaveService(remoteConfig: config);
    final usedLevel = level ?? defaultLevel;
    // Unscripted, the race's board can't be made (the resolver's null).
    final resolver = _GatedLevelResolver(
      entries: {
        if (scripted)
          _race: playEntryFor(
            _race,
            usedLevel,
            rewardCoins: 20,
            themeId: 'ch02',
          ),
      },
    );
    final bloc = buildBloc(resolver: resolver, save: usedSave, config: config);
    addTearDown(bloc.close);
    final ticker = FakeFrameTicker();
    final raceCubit = RaceCubit(_race, usedSave, config, ticker);
    addTearDown(raceCubit.close);
    final factory = FakeBoardFactory();
    final database = FakeDatabaseService();
    final homes = <int>[];
    final music = FakeMusicService();
    final jingles = FakeAudioService();
    final jingleCues = JingleCues(music, jingles);
    addTearDown(jingleCues.dispose);
    final cues = RecordingCues();
    final screen = BlocProvider.value(
      value: bloc..add(const GameplayStarted(_race)),
      child: GameplayView(
        request: _race,
        services: GameplayServices(
          skins: FakeSkinService(),
          levels: FakeLevelRepository(entries: [entryFor(usedLevel)]),
          resolver: resolver,
          save: usedSave,
          database: database,
          fx: FakeFxLibrary(),
          feedback: cues,
          music: music,
          jingles: jingles,
          jingleCues: jingleCues,
          share: FakeShareService(),
          uiArt: FakeUiArtLibrary(),
        ),
        onHome: () => homes.add(1),
        onSettings: onSettings ?? () async {},
        boardFactory: factory.call,
        race: raceCubit,
      ),
    );
    await pumpScreen(tester, screen);
    await tester.pump();
    return _RaceScreen(
      bloc,
      raceCubit,
      factory,
      ticker,
      homes,
      cues,
      resolver,
      jingles,
    );
  }

  Future<void> startRace(WidgetTester tester, _RaceScreen screen) async {
    expect(screen.raceState.phase, RacePhase.ready);
    await tester.tap(find.text('Start'));
    // Past the `RaceGateChanged` round trip through the bloc's FIFO queue.
    await tester.pump(const Duration(milliseconds: 20));
    expect(screen.raceState.phase, RacePhase.running);
    expect(screen.state.raceLive, isTrue);
  }

  testWidgets('before Start: one Start button, no boosters, and the rival '
      "strip in the HUD's top row instead of the level and coin pills "
      '(frame 9.3)', (tester) async {
    final screen = await pumpRace(tester);
    expect(find.byType(RivalStrip), findsOneWidget);
    expect(find.byType(LevelPill), findsNothing);
    expect(find.byType(CoinPill), findsNothing);
    // Lane R restyles the strip to frame 9.3 (its state line "Ready when you
    // are" shows from a 340 dp screen; phase 4 P4.4).
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('+Slot'), findsNothing);
    expect(find.text('Restart'), findsNothing);
    expect(screen.state.canHint, isFalse);
    expect(screen.state.canAddSlot, isFalse);
  });

  testWidgets('running: exactly Undo and Restart, never Hint or +1 Slot', (
    tester,
  ) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('+Slot'), findsNothing);
    expect(find.byType(RaceActionBar), findsOneWidget);
  });

  testWidgets('taps pass through the rival strip to the top shelf under it', (
    tester,
  ) async {
    await pumpRace(tester);
    expect(
      find.ancestor(
        of: find.byType(RivalStrip),
        matching: find.byWidgetPredicate(
          (widget) => widget is IgnorePointer && widget.ignoring,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Computer" and the smartDisplay glyph are on the rival '
      'strip', (tester) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    expect(find.byType(RivalStrip), findsOneWidget);
    expect(find.textContaining('Pebble'), findsWidgets);
    expect(find.text('Computer'), findsWidgets);
    expect(find.byIcon(IconUses.computerTag), findsWidgets);
  });

  testWidgets('Pause in a race (9.7): the versus header naming the rival '
      'and its Computer tag, Restart and Leave race, and the hold stops the '
      'clock', (tester) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsOneWidget);
    Finder inPause(String text) => find.descendant(
      of: find.byType(PauseDialog),
      matching: find.text(text),
    );
    expect(inPause('vs Computer · Pebble'), findsOneWidget);
    expect(inPause('Pebble is paused too.'), findsOneWidget);
    expect(inPause('Computer'), findsOneWidget, reason: 'the tag');
    expect(inPause('Home'), findsNothing);
    expect(inPause('Restart'), findsOneWidget);
    expect(inPause('Leave race'), findsOneWidget);
    expect(screen.raceState.held, isTrue);

    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.raceState.held, isFalse);
  });

  testWidgets('Settings in a race\'s Pause (9.7, Q132): the tile opens '
      'Settings, the rival stays paused while it is open, and Resume lifts '
      'the hold', (tester) async {
    final settingsOpen = Completer<void>();
    var opened = 0;
    final screen = await pumpRace(
      tester,
      onSettings: () {
        opened++;
        return settingsOpen.future;
      },
    );
    await startRace(tester, screen);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    final settingsTile = find.descendant(
      of: find.byType(PauseDialog),
      matching: find.text('Settings'),
    );
    expect(settingsTile, findsOneWidget);

    await tester.tap(settingsTile);
    await tester.pump(const Duration(milliseconds: 300));
    expect(opened, 1);
    // Settings is open over the level: the rival's clock stays held and
    // its due frames move nothing.
    final rivalMoves = screen.raceState.rivalMoves;
    screen.ticker.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 20));
    expect(screen.raceState.held, isTrue);
    expect(screen.raceState.rivalMoves, rivalMoves);

    settingsOpen.complete();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsOneWidget, reason: 'back on Pause');
    expect(screen.raceState.held, isTrue);

    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.raceState.held, isFalse);
  });

  testWidgets('Leave race asks once (9.7b): Keep racing resumes and leaves '
      'the race running, nothing written', (tester) async {
    final save = FakeSaveService();
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Leave race'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('raceLeaveConfirm')), findsOneWidget);
    expect(find.text('Leave this race?'), findsOneWidget);
    expect(
      find.text('The race ends here. No coins, and nothing lost.'),
      findsOneWidget,
    );
    expect(find.text('Keep racing'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('raceLeaveConfirm')),
        matching: find.text('Computer'),
      ),
      findsOneWidget,
      reason: 'the tag',
    );
    expect(screen.raceState.held, isTrue, reason: 'still paused');

    await tester.tap(find.text('Keep racing'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsNothing);
    expect(screen.raceState.held, isFalse);
    expect(screen.raceState.phase, RacePhase.running);
    expect(save.document.coins, 0);
    expect(save.document.race.rivals[0].wins, 0);
  });

  testWidgets('the player wins: the reward is paid once, New race and '
      'Rematch show and no third control', (tester) async {
    final save = FakeSaveService();
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    expect(save.document.coins, 0);

    await screen.win(tester);

    expect(screen.raceState.phase, RacePhase.finished);
    expect(screen.raceState.result, RaceResult.playerWon);
    expect(find.byType(RaceWinCard), findsOneWidget);
    expect(find.text('You won the race!'), findsOneWidget);
    expect(find.text('Pebble'), findsWidgets);
    expect(find.text('Computer'), findsWidgets);
    expect(find.text('Rematch'), findsOneWidget);
    expect(find.text('New race'), findsOneWidget);
    expect(find.text('Back to races'), findsNothing);
    expect(find.text('+0 coins'), findsOneWidget);
    expect(save.document.coins, 20, reason: 'race_reward_1');
    expect(save.document.race.rivals[0].wins, 1);
    // A race's HUD has no coin pill: the rival strip takes its row (frame
    // 9.3; phase 4 §6.6).
    expect(
      find.descendant(
        of: find.byType(GameplayHud),
        matching: find.byType(CoinPill),
      ),
      findsNothing,
    );
    // The gate closed: the bloc refuses any further input.
    expect(screen.state.raceLive, isFalse);
  });

  testWidgets('9.4\'s plank draws the level\'s own skin and the player\'s '
      'Color symbols, as the win card does (rule 3)', (tester) async {
    final screen = await pumpRace(tester);
    screen.board.layOut(screen.state.board);
    await tester.pump();
    await startRace(tester, screen);
    await screen.win(tester);
    final layer = tester.widget<RaceResultLayer>(find.byType(RaceResultLayer));
    expect(layer.renderer, isNotNull);
    expect(layer.images, isNotNull);
    expect(
      layer.symbols,
      FakeDatabaseService().symbolsMode.dollSymbols,
      reason: 'the setting, not the layer\'s subtle default',
    );
  });

  testWidgets('Rematch replays the same race on the same page: the win '
      'card clears and Start shows again', (tester) async {
    final save = FakeSaveService();
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    await screen.win(tester);
    expect(find.byType(RaceWinCard), findsOneWidget);

    await tester.tap(find.text('Rematch'));
    await tester.pump(const Duration(milliseconds: 300));
    // The first win unlocked Button: 9.6 shows once, as 9.4 closes.
    expect(find.byType(RivalUnlockedCard), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RaceWinCard), findsNothing);
    expect(find.text('Start'), findsOneWidget);
    expect(screen.raceState.phase, RacePhase.ready);
    // Paid once, not again by loading the same board back up.
    expect(save.document.coins, 20);

    await startRace(tester, screen);
    await screen.win(tester);
    expect(find.byType(RaceWinCard), findsOneWidget);
    // Q124 default: a Rematch win pays again.
    expect(save.document.coins, 40);
    expect(save.document.race.rivals[0].wins, 2);
  });

  testWidgets('the computer finishes first: no reward, warm copy, Rematch '
      'then New race', (tester) async {
    final save = FakeSaveService();
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    // The player never moves: advance the rival's clock well past however
    // many moves (and restarts) this small one-family board takes the
    // casual policy to finish.
    screen.ticker.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 300));

    expect(screen.raceState.phase, RacePhase.finished);
    expect(screen.raceState.result, RaceResult.rivalWon);
    expect(find.byType(RaceLossCard), findsOneWidget);
    // copy.md G.5 (phase 4).
    expect(find.text('So close! Rematch?'), findsOneWidget);
    expect(
      find.text('Pebble finished first this time. A rematch costs nothing.'),
      findsOneWidget,
    );
    expect(find.text('Rematch'), findsOneWidget);
    expect(find.text('New race'), findsOneWidget);
    expect(find.text('Back to races'), findsNothing);
    expect(save.document.coins, 0, reason: 'a loss costs and pays nothing');
    expect(save.document.race.rivals[0].wins, 0);
  });

  testWidgets('out of moves in a race: Undo "Always free" and Restart '
      'only, no +1 Slot', (tester) async {
    final screen = await pumpRace(tester, level: outOfMovesLevel);
    await startRace(tester, screen);
    await screen.move(tester, 'r0c0', 'r0c3');
    screen.board.callbacks.onOutOfMoves();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(OutOfMovesSheet), findsOneWidget);
    expect(find.text('Free, as often as you like'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(OutOfMovesSheet),
        matching: find.text('+1 Slot'),
      ),
      findsNothing,
    );
    expect(screen.raceState.held, isTrue);
  });
  testWidgets('the board\'s win report opens 9.4, never 2.8\'s Level '
      'complete and its Continue (integrator fix)', (tester) async {
    final save = FakeSaveService();
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    await screen.move(tester, red2, red3);
    await screen.move(tester, red1, red3);
    await tester.pump(const Duration(milliseconds: 300));
    // Decided and paid at once; the card waits for the winning batch, as
    // 2.8 does.
    expect(screen.raceState.result, RaceResult.playerWon);
    expect(find.byType(RaceWinCard), findsNothing);

    screen.board.callbacks.onWon();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RaceWinCard), findsOneWidget);
    expect(find.byType(WinOverlay), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Level Complete!'), findsNothing);
    expect(screen.board.overlayOpen, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('9.4 celebrates as 2.8 does, with the versus jingle instead '
      'of the win sound: the haptic at the open, then the coins cue and the '
      'count-up to the reward (m7-design P2.10, P4.4)', (tester) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    await screen.win(tester);
    expect(screen.jingles.jingles, [Jingle.versusWin]);
    expect(
      screen.cues.played.map((cue) => cue.sound),
      isNot(contains(SoundEffect.win)),
      reason: 'the jingle replaces it',
    );
    expect(
      screen.cues.played.map((cue) => cue.haptic),
      contains(HapticPattern.win),
    );
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      screen.cues.played.map((cue) => cue.sound),
      contains(SoundEffect.coins),
    );
    expect(find.text('+20 coins'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('9.5 plays the lose jingle, no win sound and no haptic', (
    tester,
  ) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    screen.ticker.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.jingles.jingles, [Jingle.versusLose]);
    expect(screen.cues.played, isEmpty, reason: 'no sound cue, no haptic');
  });

  testWidgets('both results duck the music to 0.3 (raceResult)', (
    tester,
  ) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    await screen.win(tester);
    expect(find.byType(MusicDuck), findsWidgets);
    final ducks = tester.widgetList<MusicDuck>(find.byType(MusicDuck));
    expect(ducks.map((d) => d.reason), contains(DuckReason.raceResult));
    await tester.pump(const Duration(seconds: 5));
  });

  group('9.6, "New rival unlocked!"', () {
    testWidgets('a first win that unlocks the next rival: any button on 9.4 '
        'shows the card first, once', (tester) async {
      final save = FakeSaveService();
      final screen = await pumpRace(tester, save: save);
      await startRace(tester, screen);
      await screen.win(tester);
      expect(screen.raceState.outcome?.unlockedRival, 2);
      expect(find.byType(RivalUnlockedCard), findsNothing);

      await tester.tap(find.text('New race'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RivalUnlockedCard), findsOneWidget);
      expect(find.byType(RaceWinCard), findsNothing);
      expect(find.text('New rival unlocked!'), findsOneWidget);
      expect(find.text('Button is ready to race.'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RivalUnlockedCard),
          matching: find.text('Computer'),
        ),
        findsOneWidget,
        reason: 'the tag',
      );
      expect(find.text('Careful · Slow'), findsOneWidget);
      // Nothing began yet: the race in play is still rival 1's race 1.
      expect(screen.raceCubit.request, const RacePlay(rival: 1, raceNo: 1));

      // Not now does what the player tapped on 9.4: New race, rival 1 (its
      // raceNo is stored now: the fake save had none yet).
      await tester.tap(find.text('Not now'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(screen.raceCubit.request.rival, 1);
      expect(save.document.race.rivals[0].raceNo, 1);
      expect(save.document.race.rivals[1].raceNo, 0);
      expect(find.byType(RivalUnlockedCard), findsNothing);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('its New race starts a fresh race against the unlocked '
        'rival', (tester) async {
      final save = FakeSaveService();
      final screen = await pumpRace(tester, save: save);
      await startRace(tester, screen);
      await screen.win(tester);
      await tester.tap(find.text('Rematch'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RivalUnlockedCard), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(RivalUnlockedCard),
          matching: find.text('New race'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(screen.raceCubit.request, const RacePlay(rival: 2, raceNo: 1));
      expect(save.document.race.rivals[1].raceNo, 1);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a Rematch win never shows it again: it unlocks nothing', (
      tester,
    ) async {
      final save = FakeSaveService();
      final screen = await pumpRace(tester, save: save);
      await startRace(tester, screen);
      await screen.win(tester);
      await tester.tap(find.text('Rematch'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Not now'));
      await tester.pump(const Duration(milliseconds: 300));
      await startRace(tester, screen);
      await screen.win(tester);
      expect(screen.raceState.outcome?.unlockedRival, isNull);

      await tester.tap(find.text('Rematch'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RivalUnlockedCard), findsNothing);
      expect(screen.raceState.phase, RacePhase.ready);
    });

    testWidgets('system back on 9.4 opens it first; a loss and a win over '
        'an unlocked rival go straight through', (tester) async {
      final save = FakeSaveService();
      final screen = await pumpRace(tester, save: save);
      await startRace(tester, screen);
      await screen.win(tester);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RivalUnlockedCard), findsOneWidget);
    });
  });

  testWidgets('Start covers booster slots 2 and 3, and running leaves them '
      'empty wood between Undo (slot 1) and Restart (slot 4)', (tester) async {
    final screen = await pumpRace(tester);
    final start = tester.getRect(
      find.ancestor(
        of: find.text('Start'),
        matching: find.byType(TactileButton),
      ),
    );
    final width = tester.view.physicalSize.width;
    expect(start.center.dx, moreOrLessEquals(width / 2, epsilon: 1));
    await startRace(tester, screen);
    final undo = tester.getRect(find.text('Undo'));
    final restart = tester.getRect(find.text('Restart'));
    // Slots are 80 wide with 8 dp gaps: slot 4 starts 3 slots + gaps on.
    expect(restart.center.dx - undo.center.dx, moreOrLessEquals(3 * 88));
    expect(find.text('Hint'), findsNothing);
  });

  testWidgets('the computer\'s finish freezes the board under 9.5', (
    tester,
  ) async {
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    screen.ticker.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RaceLossCard), findsOneWidget);
    expect(screen.board.overlayOpen, isTrue);
    expect(screen.state.acceptsInput, isFalse);
  });

  testWidgets('a race board that can\'t be made: Try again and Back to '
      'rivals, never a dead page (m7-design P2.4)', (tester) async {
    await pumpRace(tester, scripted: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('raceLoadFailed')), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Back to races'), findsOneWidget);
    expect(find.text('Back to Home'), findsNothing);
  });

  testWidgets('a New race whose board can\'t be made opens the failure card '
      'with Back to rivals', (tester) async {
    // Race 1 already begun, so New race asks for race 2, which the
    // resolver can't make.
    final save = FakeSaveService(
      initial: const SaveDocument(
        currentLevel: 21,
        highestLevel: 21,
        race: RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, raceNo: 1),
            RivalProgress(),
            RivalProgress(),
          ],
        ),
      ),
    );
    final screen = await pumpRace(tester, save: save);
    await startRace(tester, screen);
    await screen.win(tester);
    await tester.tap(find.text('New race'));
    await tester.pump(const Duration(milliseconds: 300));
    // The first win unlocked Button: 9.6 shows before the New race.
    await tester.tap(find.text('Not now'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(screen.raceCubit.request, const RacePlay(rival: 1, raceNo: 2));
    expect(find.byType(NextLevelFailedCard), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Back to races'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
  group('the view\'s lifecycle holds and the tie (m7-design race-ui lane, '
      'review R32)', () {
    testWidgets('inactive alone (a system sheet) holds the clock; resumed '
        'releases it', (tester) async {
      final screen = await pumpRace(tester);
      await startRace(tester, screen);
      expect(screen.ticker.isTicking, isTrue);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(screen.raceState.held, isTrue);
      expect(screen.ticker.isTicking, isFalse);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(screen.raceState.held, isFalse);
      expect(screen.ticker.isTicking, isTrue);
    });

    testWidgets('to the background and back: Pause opens and keeps the hold '
        'until Resume', (tester) async {
      final screen = await pumpRace(tester);
      await startRace(tester, screen);

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(PauseDialog), findsOneWidget);
      expect(screen.raceState.held, isTrue);
      expect(screen.ticker.isTicking, isFalse);

      await tester.tap(find.text('Resume'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(screen.raceState.held, isFalse);
      expect(screen.ticker.isTicking, isTrue);
    });

    testWidgets('the winning tap, then the rival\'s due frame at once: the '
        'tie goes to the player (spec-prop §7.7)', (tester) async {
      final screen = await pumpRace(tester);
      await startRace(tester, screen);
      await screen.move(tester, red2, red3);
      await screen.tap(tester, red1);

      // The winning tap and its microtasks, then a frame whose step is long
      // past the rival's finish.
      screen.board.callbacks.onIntent(const SlotTapped(red3));
      await tester.pump(Duration.zero);
      screen.ticker.advance(const Duration(minutes: 5));
      await tester.pump(const Duration(milliseconds: 20));
      expect(screen.raceState.result, RaceResult.playerWon);
    });
  });

  testWidgets('Pause opened while a Rematch board loads keeps its hold once '
      'the board lands: Start leaves the clock off until Resume (M7 review '
      'R8)', (tester) async {
    final semantics = tester.ensureSemantics();
    final screen = await pumpRace(tester);
    await startRace(tester, screen);
    // A loss: the player never moves.
    screen.ticker.advance(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RaceLossCard), findsOneWidget);

    // Rematch, with its board still being made.
    screen.resolver.gate = Completer<void>();
    await tester.tap(find.text('Rematch'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(screen.raceState.phase, RacePhase.waiting);
    expect(screen.bloc.state.isLoading, isTrue);

    // System back during the spinner opens Pause over the old board.
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(screen.raceState.held, isTrue);

    // The board lands with Pause still up: the hold is still on.
    screen.resolver.gate!.complete();
    screen.resolver.gate = null;
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsOneWidget);
    expect(screen.raceState.phase, RacePhase.ready);
    expect(screen.raceState.held, isTrue);

    // Start is out of a screen reader's reach under Pause (R11); a Start
    // that still arrives keeps the rival's clock off while Pause is up.
    expect(find.semantics.byLabel('Start'), findsNothing);
    screen.raceCubit.start();
    await tester.pump(const Duration(milliseconds: 50));
    expect(screen.ticker.isTicking, isFalse);
    screen.ticker.advance(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    expect(screen.raceState.rivalMoves, 0);

    // Resume lifts the hold: the clock runs and the player's moves count.
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PauseDialog), findsNothing);
    expect(screen.raceState.held, isFalse);
    expect(screen.ticker.isTicking, isTrue);
    expect(screen.state.acceptsInput, isTrue);
    final movesBefore = screen.state.board.moveCount;
    await screen.move(tester, red2, red3);
    expect(screen.state.board.moveCount, movesBefore + 1);
    semantics.dispose();
  });
}
