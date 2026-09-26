import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import 'core/ui/support/ui_harness.dart';
import 'helpers/test_dependencies.dart';

/// The main flow on the whole app over the fake DI graph (spec §10.1;
/// m2-lottie-design §17 "Screens and UI"): Splash → Home → PLAY → the board
/// laid out with its HUD and boosters, taking a tap → Pause → Home.
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

    await tester.pumpWidget(App(router: get<AppRouter>()));
    // The router parses the initial route asynchronously.
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('Dusting the shelves…'), findsOneWidget);

    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    final play = find.bySemanticsLabel('Play level 1');
    expect(play, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(play);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
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
    expect(tester.takeException(), isNull);
  });
}
