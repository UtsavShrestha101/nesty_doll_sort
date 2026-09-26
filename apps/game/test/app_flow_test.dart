import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_page.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import 'helpers/test_dependencies.dart';

/// Main flow on fake services (spec §10.1): Splash → Home → Gameplay.
void main() {
  setUp(configureTestDependencies);
  tearDown(resetDependencies);

  testWidgets('boots through Splash to Home, then opens Gameplay', (
    tester,
  ) async {
    await tester.pumpWidget(App(router: get<AppRouter>()));
    // The router parses the initial route asynchronously, so the splash
    // appears on the frame after the first one.
    await tester.pump();

    // Splash is shown while the (fake) save and levels load.
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    final playButton = find.widgetWithText(FilledButton, 'Level 1');
    expect(playButton, findsOneWidget);

    await tester.tap(playButton);
    // Not pumpAndSettle: Flame's game loop schedules a frame every tick, so
    // the tree never "settles" once the GameWidget is on screen. Pump past
    // the route transition instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameplayPage), findsOneWidget);
    expect(find.byType(GameWidget<NestyGame>), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      // Boosters stay disabled until the board is playable (M2).
      expect(button.enabled, isFalse, reason: label);
    }

    // Placeholder pause returns to Home (TODO(M2): pause menu, frame 3.9).
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GameplayPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
