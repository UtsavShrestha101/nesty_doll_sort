import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';

/// The first launch's fade into Level 1 (frame 10.8; phase 4 architecture
/// §3.13; ui-spec-game §2.4): 400 ms with `easeOut`, and a cut under reduce
/// motion. The route wiring (the splash passing `fromSplash`) is
/// `test/features/splash/splash_page_test.dart` and the playthrough.
void main() {
  Future<void> pump(
    WidgetTester tester,
    AnimationController controller, {
    required bool reduceMotion,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Builder(
            builder: (context) => GameplayTransitions.firstLaunch(
              context,
              controller,
              const Text('Level 1'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the fade is 400 ms and eases out: most of it is done by the '
      'middle', (tester) async {
    final controller = AnimationController(
      vsync: tester,
      duration: GameplayTransitions.duration,
    );
    expect(GameplayTransitions.duration, const Duration(milliseconds: 400));
    await pump(tester, controller, reduceMotion: false);
    final fade = find.byType(FadeTransition);
    expect(tester.widget<FadeTransition>(fade).opacity.value, 0);

    unawaited(controller.forward());
    await tester.pump(); // the ticker's first frame
    await tester.pump(const Duration(milliseconds: 200));
    final half = tester.widget<FadeTransition>(fade).opacity.value;
    expect(half, greaterThan(0.5), reason: 'easeOut front-loads it');
    expect(half, lessThan(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
    controller.dispose();
  });

  testWidgets('reduce motion: a cut, the level is just there', (tester) async {
    final controller = AnimationController(
      vsync: tester,
      duration: GameplayTransitions.duration,
    );
    await pump(tester, controller, reduceMotion: true);
    expect(find.text('Level 1'), findsOneWidget);
    // The controller is still at 0, and nothing fades the text.
    expect(controller.value, 0);
    expect(find.byType(FadeTransition), findsNothing);
    controller.dispose();
  });
}
