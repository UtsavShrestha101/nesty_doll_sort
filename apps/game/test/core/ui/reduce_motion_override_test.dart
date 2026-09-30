import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/ui/theme/reduce_motion_override.dart';

/// E14's override over the OS setting (docs/plans/m7-design.md §14,
/// spec-prop §16 "follow the system setting"), on both platforms' flags:
/// Android's "Remove animations" reaches `MediaQuery.disableAnimations`,
/// iOS's Reduce Motion only `AccessibilityFeatures.reduceMotion` (review
/// R7).
void main() {
  bool? reduced;

  Future<void> pump(WidgetTester tester, ReduceMotionMode mode) =>
      tester.pumpWidget(
        MediaQuery.fromView(
          view: tester.view,
          child: ReduceMotionOverride(
            mode: mode,
            child: Builder(
              builder: (context) {
                reduced = MediaQuery.disableAnimationsOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

  void setFeatures(
    WidgetTester tester, {
    bool reduceMotion = false,
    bool disableAnimations = false,
  }) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(
          reduceMotion: reduceMotion,
          disableAnimations: disableAnimations,
        );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  setUp(() => reduced = null);

  group('System follows the OS', () {
    testWidgets("iOS's Reduce Motion (reduceMotion only) reduces motion", (
      tester,
    ) async {
      setFeatures(tester, reduceMotion: true);
      await pump(tester, ReduceMotionMode.system);
      expect(reduced, isTrue);
    });

    testWidgets("Android's Remove animations (disableAnimations) reduces it", (
      tester,
    ) async {
      setFeatures(tester, disableAnimations: true);
      await pump(tester, ReduceMotionMode.system);
      expect(reduced, isTrue);
    });

    testWidgets('neither flag: full motion', (tester) async {
      setFeatures(tester);
      await pump(tester, ReduceMotionMode.system);
      expect(reduced, isFalse);
    });

    testWidgets('an iOS change while the app runs is followed live', (
      tester,
    ) async {
      setFeatures(tester);
      await pump(tester, ReduceMotionMode.system);
      expect(reduced, isFalse);

      setFeatures(tester, reduceMotion: true);
      await tester.pump();
      expect(reduced, isTrue);

      setFeatures(tester);
      await tester.pump();
      expect(reduced, isFalse);
    });
  });

  group('the in-app choice wins over the OS', () {
    testWidgets('On reduces motion with neither flag set', (tester) async {
      setFeatures(tester);
      await pump(tester, ReduceMotionMode.on);
      expect(reduced, isTrue);
    });

    for (final (name, ios, android) in [
      ("iOS's Reduce Motion", true, false),
      ("Android's Remove animations", false, true),
    ]) {
      testWidgets('Off keeps full motion under $name', (tester) async {
        setFeatures(tester, reduceMotion: ios, disableAnimations: android);
        await pump(tester, ReduceMotionMode.off);
        expect(reduced, isFalse);
      });
    }
  });
}
