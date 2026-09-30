import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/gameplay/bloc/support/bloc_fixtures.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 overflow suite (m7-design §18 "overflow"): gameplay itself — the HUD,
/// the booster bar and a fake board together, over a real `GameplayBloc` —
/// at the five acceptance sizes and both text scales, resting and after a
/// win. Behaviour is covered by `test/features/gameplay/pages/
/// gameplay_view_test.dart`, which sweeps `screenSizes`; this file extends
/// the same real-bloc-over-a-recording-board pattern to the wider M7 grid.
void main() {
  setUpAll(loadBundledFonts);

  Future<FakeGameplayBoard> pumpGameplay(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    final entries = [entryFor(defaultLevel)];
    final bloc = buildBloc(entries: entries);
    addTearDown(bloc.close);
    final factory = FakeBoardFactory();
    final music = FakeMusicService();
    final jingles = FakeAudioService();
    final jingleCues = JingleCues(music, jingles);
    addTearDown(jingleCues.dispose);
    await pumpScreen(
      tester,
      BlocProvider.value(
        value: bloc..add(const GameplayStarted(PlayRequest.campaign(1))),
        child: GameplayView(
          request: const PlayRequest.campaign(1),
          services: GameplayServices(
            skins: FakeSkinService(),
            levels: FakeLevelRepository(entries: entries),
            resolver: resolverOf(bloc),
            save: saveOf(bloc),
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
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
    return factory.board!;
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text, '
        'resting and after a win',
        (tester) async {
          final board = await pumpGameplay(
            tester,
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
          for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }

          board.callbacks.onIntent(const SlotTapped(red2));
          await tester.pump(const Duration(milliseconds: 20));
          board.callbacks.onIntent(const SlotTapped(red3));
          await tester.pump(const Duration(milliseconds: 20));
          board.callbacks.onIntent(const SlotTapped(red1));
          await tester.pump(const Duration(milliseconds: 20));
          board.callbacks.onIntent(const SlotTapped(red3));
          await tester.pump(const Duration(milliseconds: 20));
          board.callbacks.onFamilyLanded(1, 1, 1.5);
          board.callbacks.onWon();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
