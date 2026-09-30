import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor, Tier;
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';
import 'package:nesty_game/features/gameplay/widgets/race_action_bar.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/gameplay/bloc/support/bloc_fixtures.dart';
import '../features/gameplay/bloc/support/scripted_level_resolver.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 phase-2 overflow suite (m7-design P2.10, P2.13): every vs Computer
/// stand-in screen and overlay at the five acceptance sizes and both text
/// scales. Behaviour is covered elsewhere (`test/features/race/**`,
/// `test/features/gameplay/{overlays,widgets}/**`,
/// `test/features/gameplay/pages/gameplay_view_race_test.dart`).
void main() {
  setUpAll(loadBundledFonts);

  RivalSelectCubit selectCubit() {
    final cubit = RivalSelectCubit(
      FakeSaveService(
        initial: const SaveDocument(currentLevel: 21, highestLevel: 21),
      ),
      FakeRemoteConfigService(),
    );
    unawaited(cubit.load());
    return cubit;
  }

  // Up to five families on the plank (88 dp dolls above four).
  const families = [
    DollColor.red,
    DollColor.blue,
    DollColor.green,
    DollColor.purple,
    DollColor.orange,
  ];

  RivalSelectCubit selectCubitNew() {
    final cubit = RivalSelectCubit(
      FakeSaveService(
        initial: const SaveDocument(
          currentLevel: 40,
          highestLevel: 40,
          race: RaceProgress(
            rivals: [
              RivalProgress(unlocked: true, wins: 1, raceNo: 1),
              RivalProgress(unlocked: true),
              RivalProgress(),
            ],
          ),
        ),
      ),
      FakeRemoteConfigService(),
    );
    unawaited(cubit.load());
    return cubit;
  }

  Widget raceWinCard({int families_ = 4}) => RaceWinCard(
    rival: 2,
    rewardCoins: 30,
    families: families.take(families_).toList(),
    newBadges: const [BadgeId.firstRace],
    library: FakeFxLibrary(),
    onRematch: () {},
    onNewRace: () {},
  );

  Widget raceLossCard() => RaceLossCard(
    rival: 3,
    families: families.take(3).toList(),
    library: FakeFxLibrary(),
    onRematch: _noop,
    onNewRace: _noop,
  );

  Widget rivalUnlockedCard() =>
      RivalUnlockedCard(rival: 3, onNewRace: () {}, onNotNow: () {});

  Widget racePauseDialog() => PauseDialog(
    race: const RacePauseInfo(rival: 1),
    settings: const PauseSettings(sound: true, music: true, haptics: true),
    onSoundChanged: (_) {},
    onMusicChanged: (_) {},
    onHapticsChanged: (_) {},
    onResume: () {},
    onRestart: () {},
    onLeaveRace: () {},
  );

  Widget raceActionBarReady() => RaceActionBar(
    ready: true,
    onStart: () {},
    canUndo: false,
    onUndo: () {},
    onRestart: () {},
  );

  Widget raceActionBarRunning() => RaceActionBar(
    ready: false,
    onStart: () {},
    canUndo: true,
    onUndo: () {},
    onRestart: () {},
  );

  Widget rivalStrip() => const RivalStripView(
    data: (
      rival: 2,
      activity: RivalActivity.thinking,
      rivalSets: 1,
      totalSets: 3,
      rivalMoves: 3,
      held: false,
      over: false,
    ),
  );

  // The integrator's additions (M7 phase 2): the race's HUD, its
  // out-of-moves sheet (Undo "Always free" and Restart only), the failure
  // card with Back to rivals, and 9.4 with the rival-unlocked toast up.
  Widget raceHud() => Align(
    alignment: Alignment.topCenter,
    child: GameplayHud(
      level: 20,
      tier: Tier.medium,
      coins: 99999,
      setsDone: 5,
      setsTotal: 6,
      raceStrip: rivalStrip(),
      onPause: () {},
      library: FakeFxLibrary(),
    ),
  );

  Widget raceOutOfMoves() => OutOfMovesSheet(
    freeUndosLeft: 0,
    showFreeUndos: true,
    relaxed: true,
    onUndo: () {},
    onExtraSlot: null,
    onRestart: () {},
    onDismiss: () {},
  );

  Widget raceFailed() => NextLevelFailedCard(
    title: 'The shelves need a moment',
    body: 'This race didn’t set up. Try again, or pick another race.',
    retryLabel: 'Try again',
    secondaryLabel: 'Back to races',
    versus: true,
    onRetry: () {},
    onSecondary: () {},
  );

  final screens = <String, Widget Function()>{
    'RivalSelectView': () => BlocProvider<RivalSelectCubit>.value(
      value: selectCubit(),
      child: const RivalSelectView(),
    ),
    'RivalSelectView (9.2b)': () => BlocProvider<RivalSelectCubit>.value(
      value: selectCubitNew(),
      child: const RivalSelectView(),
    ),
    'RaceWinCard': raceWinCard,
    'RaceWinCard (five families)': () => raceWinCard(families_: 5),
    'RaceLossCard': raceLossCard,
    'RivalUnlockedCard (9.6)': rivalUnlockedCard,
    'Pause (race)': racePauseDialog,
    'RaceActionBar (ready)': raceActionBarReady,
    'RaceActionBar (running)': raceActionBarRunning,
    'GameplayHud (race)': raceHud,
    'OutOfMovesSheet (race)': raceOutOfMoves,
    'NextLevelFailedCard (race)': raceFailed,
    'RivalStrip (12 families)': () => const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(left: 76, right: 16),
        child: RivalStripView(
          data: (
            rival: 3,
            activity: RivalActivity.startingOver,
            rivalSets: 7,
            totalSets: 12,
            rivalMoves: 30,
            held: false,
            over: false,
          ),
        ),
      ),
    ),
    'RivalStrip (player first)': () => const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(left: 76, right: 16),
        child: RivalStripView(
          data: (
            rival: 1,
            activity: RivalActivity.thinking,
            rivalSets: 3,
            totalSets: 4,
            rivalMoves: 9,
            held: false,
            over: true,
          ),
        ),
      ),
    ),
    'RivalStrip': () => Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: rivalStrip(),
      ),
    ),
  };

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final entry in screens.entries) {
        testWidgets(
          '${entry.key} fits ${size.width.toInt()}×${size.height.toInt()} '
          'at $scale× text',
          (tester) async {
            await pumpScreen(
              tester,
              entry.value(),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 300));
            await expectAccessibleLayout(tester);
            // 9.4's count-up, and the rival-unlocked toast ~900 ms in.
            for (var i = 0; i < 12; i++) {
              await tester.pump(const Duration(milliseconds: 100));
            }
            await expectAccessibleLayout(tester);
            // Past every toast, so no timer is left pending.
            await tester.pump(const Duration(seconds: 5));
          },
        );
      }
    }
  }

  // The whole race page over a real bloc and cubit (the strip under the
  // HUD, the Start bar, then Undo and Restart, then 9.4 over the board).
  Future<FakeGameplayBoard> pumpRacePage(
    WidgetTester tester, {
    required Size size,
    required double scale,
  }) async {
    const race = RacePlay(rival: 2, raceNo: 1);
    final config = FakeRemoteConfigService();
    final save = FakeSaveService(
      remoteConfig: config,
      initial: const SaveDocument(
        coins: 99999,
        currentLevel: 71,
        highestLevel: 71,
        race: RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, wins: 1, raceNo: 1),
            RivalProgress(unlocked: true),
            RivalProgress(),
          ],
        ),
      ),
    );
    final resolver = ScriptedLevelResolver(
      entries: {race: playEntryFor(race, defaultLevel, rewardCoins: 30)},
    );
    final bloc = buildBloc(resolver: resolver, save: save, config: config);
    addTearDown(bloc.close);
    final cubit = RaceCubit(race, save, config, FakeFrameTicker());
    addTearDown(cubit.close);
    final factory = FakeBoardFactory();
    final music = FakeMusicService();
    final jingles = FakeAudioService();
    final jingleCues = JingleCues(music, jingles);
    addTearDown(jingleCues.dispose);
    await pumpScreen(
      tester,
      BlocProvider.value(
        value: bloc..add(const GameplayStarted(race)),
        child: GameplayView(
          request: race,
          services: GameplayServices(
            skins: FakeSkinService(),
            levels: FakeLevelRepository(entries: [entryFor(defaultLevel)]),
            resolver: resolver,
            save: save,
            database: FakeDatabaseService(),
            fx: FakeFxLibrary(),
            feedback: RecordingCues(),
            music: music,
            jingles: jingles,
            jingleCues: jingleCues,
            share: FakeShareService(),
            uiArt: FakeUiArtLibrary(),
          ),
          onHome: () {},
          onSettings: () async {},
          boardFactory: factory.call,
          race: cubit,
        ),
      ),
      size: size,
      textScale: scale,
    );
    await tester.pump();
    return factory.board!;
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'the race page fits ${size.width.toInt()}×${size.height.toInt()} '
        'at $scale× text: ready, running and won',
        (tester) async {
          final board = await pumpRacePage(tester, size: size, scale: scale);
          await expectAccessibleLayout(tester);
          expect(find.text('Start'), findsOneWidget);

          await tester.tap(find.text('Start'));
          await tester.pump(const Duration(milliseconds: 20));
          await expectAccessibleLayout(tester);
          expect(find.text('Undo'), findsOneWidget);

          for (final slot in const [red2, red3, red1, red3]) {
            board.callbacks.onIntent(SlotTapped(slot));
            await tester.pump(const Duration(milliseconds: 20));
          }
          board.callbacks.onWon();
          for (var i = 0; i < 15; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.byType(RaceWinCard), findsOneWidget);
          await expectAccessibleLayout(tester);

          // Any exit of 9.4 shows 9.6 first (this win unlocked Comet).
          await tester.tap(find.text('New race'));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byType(RivalUnlockedCard), findsOneWidget);
          await expectAccessibleLayout(tester);
          await tester.pump(const Duration(seconds: 5));
        },
      );
    }
  }
}

void _noop() {}
