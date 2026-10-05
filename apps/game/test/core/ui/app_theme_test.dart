import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// AppTheme from the generated tokens: Nunito by default, Fredoka for
/// display, the token type scale, a canvas-cream scaffold, no ink splash.
void main() {
  final theme = AppTheme.light;

  test('Nunito is the default family; display roles are Fredoka', () {
    expect(theme.textTheme.bodyLarge?.fontFamily, AppFontTokens.bodyFamily);
    expect(theme.textTheme.labelLarge?.fontFamily, AppFontTokens.bodyFamily);
    for (final style in [
      theme.textTheme.displayLarge,
      theme.textTheme.headlineMedium,
      theme.textTheme.titleLarge,
    ]) {
      expect(style?.fontFamily, AppFontTokens.displayFamily);
    }
    expect(theme.textTheme.displayLarge?.fontSize, 56);
    expect(theme.textTheme.bodyLarge?.fontSize, 16);
    expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w600);
  });

  test('scaffold and canvas are canvas cream; no splash or highlight', () {
    expect(theme.scaffoldBackgroundColor, AppColorTokens.canvasCream);
    expect(theme.canvasColor, AppColorTokens.canvasCream);
    expect(theme.splashFactory, NoSplash.splashFactory);
    expect(theme.highlightColor, Colors.transparent);
    expect(theme.colorScheme.primary, AppColorTokens.primary);
    expect(theme.colorScheme.onSurface, AppColorTokens.textPrimary);
  });

  testWidgets('localized, the roles keep the tokens (no Material geometry)', (
    tester,
  ) async {
    late BuildContext captured;
    await pumpUi(
      tester,
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    );
    final text = Theme.of(captured).textTheme;
    expect(text.bodyLarge?.letterSpacing, 0);
    expect(text.bodyLarge?.height, AppTextStyleTokens.body.height);
    expect(
      text.labelSmall?.letterSpacing,
      AppTextStyleTokens.tierChip.letterSpacing,
    );
    expect(text.bodyLarge?.color, AppColorTokens.textPrimary);
    // The context getters read the same scale.
    expect(captured.bodyText, AppTextStyles.body);
    expect(captured.sheetTitleText.fontSize, 30);
    expect(
      captured.numberText.fontFeatures,
      AppTextStyleTokens.number.fontFeatures,
    );
  });

  testWidgets('uiDuration halves under reduced motion (D48)', (tester) async {
    late BuildContext captured;
    Widget probe() => Builder(
      builder: (context) {
        captured = context;
        return const SizedBox();
      },
    );
    await pumpUi(tester, probe());
    expect(captured.reduceMotion, isFalse);
    expect(
      captured.uiDuration(UiMotionTokens.sheetInMs),
      const Duration(milliseconds: 280),
    );
    await pumpUi(tester, probe(), reduceMotion: true);
    expect(captured.reduceMotion, isTrue);
    expect(
      captured.uiDuration(UiMotionTokens.sheetInMs),
      const Duration(milliseconds: 140),
    );
  });

  test('legacy AppColors names alias the token values', () {
    expect(AppColorTokens.canvasCream, AppColorTokens.canvasCream);
    expect(AppColorTokens.textPrimary, AppColorTokens.textPrimary);
    expect(AppColorTokens.ad, AppColorTokens.ad);
  });
}
