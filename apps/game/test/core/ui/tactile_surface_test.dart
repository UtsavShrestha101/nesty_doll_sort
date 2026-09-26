import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// design/README.md "Tactile depth": pressed, a control moves down by
/// (edge − 2) px while its edge shrinks to 2 px, over 80 ms; activating it
/// plays the button sound and the selection haptic.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpButton(
    WidgetTester tester, {
    VoidCallback? onPressed,
    TactileButtonVariant variant = TactileButtonVariant.primary,
    TactileButtonSize size = TactileButtonSize.large,
    RecordingFeedback? feedback,
    bool reduceMotion = false,
  }) => pumpUi(
    tester,
    Center(
      child: SizedBox(
        width: 300,
        child: TactileButton(
          label: 'Continue',
          onPressed: onPressed,
          variant: variant,
          size: size,
        ),
      ),
    ),
    feedback: feedback ?? RecordingFeedback(),
    reduceMotion: reduceMotion,
  );

  double labelTop(WidgetTester tester) =>
      tester.getTopLeft(find.text('Continue')).dy;

  group('press travel', () {
    for (final (variant, size, travel) in [
      (TactileButtonVariant.primary, TactileButtonSize.large, 4.0),
      (TactileButtonVariant.ad, TactileButtonSize.large, 4.0),
      (TactileButtonVariant.secondary, TactileButtonSize.medium, 3.0),
      (TactileButtonVariant.success, TactileButtonSize.compact, 2.0),
    ]) {
      testWidgets(
        '${variant.name} ${size.name} moves down edge − 2 = $travel',
        (tester) async {
          await pumpButton(
            tester,
            onPressed: () {},
            variant: variant,
            size: size,
          );
          final rest = labelTop(tester);

          final gesture = await tester.startGesture(
            tester.getCenter(find.byType(TactileButton)),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 40));
          final halfway = labelTop(tester) - rest;
          expect(halfway, greaterThan(0));
          expect(halfway, lessThan(travel));

          await tester.pump(const Duration(milliseconds: 60));
          expect(labelTop(tester) - rest, closeTo(travel, 0.01));

          await gesture.up();
          await tester.pumpAndSettle();
          expect(labelTop(tester), closeTo(rest, 0.01));
        },
      );
    }

    testWidgets('a quick tap still bottoms out, then springs back', (
      tester,
    ) async {
      await pumpButton(tester, onPressed: () {});
      final rest = labelTop(tester);
      await tester.tap(find.byType(TactileButton));
      await tester.pump(); // the press ticker's first frame
      await tester.pump(const Duration(milliseconds: 80));
      expect(labelTop(tester) - rest, closeTo(4, 0.01));
      await tester.pumpAndSettle();
      expect(labelTop(tester), closeTo(rest, 0.01));
    });

    testWidgets('reduced motion halves the 80 ms press (D48)', (tester) async {
      await pumpButton(tester, onPressed: () {}, reduceMotion: true);
      final rest = labelTop(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TactileButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(labelTop(tester) - rest, closeTo(4, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the close button moves 2 px', (tester) async {
      await pumpUi(
        tester,
        Center(child: NestyCloseButton(onPressed: () {})),
        feedback: RecordingFeedback(),
      );
      final icon = find.byIcon(NestyIcons.close);
      final rest = tester.getTopLeft(icon).dy;
      final gesture = await tester.startGesture(tester.getCenter(icon));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(icon).dy - rest, closeTo(2, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('activation', () {
    testWidgets('a tap calls onPressed once and plays the feedback once', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      var pressed = 0;
      await pumpButton(tester, onPressed: () => pressed++, feedback: feedback);
      await tester.tap(find.byType(TactileButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      expect(feedback.activations, 1);
    });

    testWidgets('dragging off before release cancels', (tester) async {
      final feedback = RecordingFeedback();
      var pressed = 0;
      await pumpButton(tester, onPressed: () => pressed++, feedback: feedback);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TactileButton)),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await gesture.moveBy(const Offset(0, 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(pressed, 0);
      expect(feedback.activations, 0);
    });

    testWidgets('without a scope, it uses the registered services', (
      tester,
    ) async {
      final locator = GetIt.instance;
      final audio = _MockAudio();
      final haptics = _MockHaptics();
      when(() => haptics.play(HapticPattern.button)).thenAnswer((_) async {});
      locator
        ..registerSingleton<AudioService>(audio)
        ..registerSingleton<HapticsService>(haptics);
      addTearDown(locator.reset);

      await pumpUi(
        tester,
        Center(
          child: TactileButton(label: 'Continue', onPressed: () {}),
        ),
      );
      await tester.tap(find.byType(TactileButton));
      await tester.pumpAndSettle();
      verify(() => audio.play(SoundEffect.button)).called(1);
      verify(() => haptics.play(HapticPattern.button)).called(1);
    });

    testWidgets('with no scope and no services, a tap is silent', (
      tester,
    ) async {
      var pressed = 0;
      await pumpUi(
        tester,
        Center(
          child: TactileButton(label: 'Continue', onPressed: () => pressed++),
        ),
      );
      await tester.tap(find.byType(TactileButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });
  });

  group('disabled', () {
    testWidgets('no press, no feedback, flat and sunk, muted text', (
      tester,
    ) async {
      final feedback = RecordingFeedback();
      await pumpButton(tester, feedback: feedback);
      final rest = labelTop(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TactileButton)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(labelTop(tester), rest);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(feedback.activations, 0);

      final text = tester.widget<Text>(find.text('Continue'));
      expect(text.style?.color, AppColors.disabledText);
      final painter = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(TactileSurface),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .whereType<SurfacePainter>()
          .single;
      expect(painter.style, SurfaceStyles.disabled);
    });

    testWidgets('screen readers see a disabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpButton(tester);
      expect(
        tester.getSemantics(find.byType(TactileButton)),
        matchesSemantics(
          label: 'Continue',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('an enabled button exposes its tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpButton(tester, onPressed: () {});
      expect(
        tester.getSemantics(find.byType(TactileButton)),
        matchesSemantics(
          label: 'Continue',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('touch target', () {
    testWidgets('the 36 px close button answers taps across 48 dp', (
      tester,
    ) async {
      var pressed = 0;
      await pumpUi(
        tester,
        Center(child: NestyCloseButton(onPressed: () => pressed++)),
        feedback: RecordingFeedback(),
      );
      final box = find.byType(NestyCloseButton);
      expect(tester.getSize(box), const Size(48, 48));
      // Inside the 48 box but outside the 36 circle.
      await tester.tapAt(tester.getTopLeft(box) + const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      // Just outside the box: nothing.
      await tester.tapAt(tester.getTopLeft(box) - const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });
  });
}

class _MockAudio extends Mock implements AudioService {}

class _MockHaptics extends Mock implements HapticsService {}
