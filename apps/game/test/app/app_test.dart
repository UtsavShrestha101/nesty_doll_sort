import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';

import '../core/ui/support/ui_harness.dart';
import '../helpers/test_dependencies.dart';

/// The app root's reduce-motion override (E14; docs/plans/m7-design.md
/// §14): `MediaQuery.disableAnimations`, which `context.reduceMotion`,
/// `LottieFxView`, the UI kit's duration tokens and the board all read,
/// follows `DatabaseService.reduceMotion`/`reduceMotionChanges` over the
/// platform's own value, inside the existing 1.3× text-scale clamp.
void main() {
  setUpAll(loadBundledFonts);
  setUp(configureTestDependencies);
  tearDown(resetDependencies);

  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  /// What every screen's `context.reduceMotion` reads right now: the
  /// override reaches the whole tree via one root `MediaQuery`, so any
  /// live element (whatever page the app landed on) shows it.
  bool currentlyReducesMotion(WidgetTester tester) =>
      MediaQuery.maybeDisableAnimationsOf(
        tester.element(find.byType(Navigator).first),
      ) ??
      false;

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
  }

  testWidgets('System (the default) follows the platform\'s own reduce-'
      'motion flag', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    expect(get<DatabaseService>().reduceMotion, ReduceMotionMode.system);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isTrue);
  });

  testWidgets("System follows iOS's Reduce Motion, which reaches only "
      'AccessibilityFeatures.reduceMotion, never MediaQuery (review R7)', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    expect(get<DatabaseService>().reduceMotion, ReduceMotionMode.system);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isTrue);
  });

  testWidgets("Off keeps full motion under iOS's Reduce Motion too", (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await get<DatabaseService>().setReduceMotion(ReduceMotionMode.off);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isFalse);
  });

  testWidgets('System with the platform off keeps motion on', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isFalse);
  });

  testWidgets('On always reduces motion, even when the platform doesn\'t', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await get<DatabaseService>().setReduceMotion(ReduceMotionMode.on);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isTrue);
  });

  testWidgets('Off never reduces motion, even when the platform does', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await get<DatabaseService>().setReduceMotion(ReduceMotionMode.off);

    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isFalse);
  });

  testWidgets('a change made mid-session (Pause → Settings) reaches the '
      'screen already on top, live', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    expect(currentlyReducesMotion(tester), isFalse);

    await get<DatabaseService>().setReduceMotion(ReduceMotionMode.on);
    await tester.pump();
    expect(currentlyReducesMotion(tester), isTrue);

    await get<DatabaseService>().setReduceMotion(ReduceMotionMode.off);
    await tester.pump();
    expect(currentlyReducesMotion(tester), isFalse);
  });
}
