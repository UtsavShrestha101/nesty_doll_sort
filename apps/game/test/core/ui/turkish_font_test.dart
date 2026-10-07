import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

import 'support/ui_harness.dart';

/// m7-5 item 28 (tokens.json `font.scripts.latnTr`): Fredoka has no ğ Ğ İ ş Ş,
/// so in `tr` every Fredoka role draws in Baloo 2, the whole string, never
/// per glyph; Nunito (body) stays.
void main() {
  setUpAll(loadBundledFonts);
  tearDown(() => LocaleScript.current = LocaleScript.latin);

  Future<TextStyle> styleUnderScope(
    WidgetTester tester,
    Locale locale,
    TextStyle Function() read,
  ) async {
    late TextStyle out;
    await tester.pumpWidget(
      Localizations(
        locale: locale,
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: LocaleScriptScope(
            child: Builder(
              builder: (context) {
                out = read();
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    return out;
  }

  testWidgets('in tr a Fredoka title resolves to Baloo 2, body stays Nunito', (
    tester,
  ) async {
    const tr = Locale('tr');
    final title = await styleUnderScope(
      tester,
      tr,
      () => AppTextStyles.cardTitle,
    );
    expect(title.fontFamily, AppFontTokens.latnTrFamily);
    expect(title.fontWeight, FontWeight.w700);
    expect(title.fontSize, AppTextStyleTokens.cardTitle.fontSize);
    for (final read in <TextStyle Function()>[
      () => AppTextStyles.display,
      () => AppTextStyles.h1,
      () => AppTextStyles.sheetTitle,
      () => AppTextStyles.h2,
      () => AppTextStyles.screenTitle,
      () => AppTextStyles.button,
      () => AppTextStyles.buttonSmall,
      () => AppTextStyles.hudLevel,
      () => AppTextStyles.number,
      () => AppTextStyles.tierChip,
      () => AppTextStyles.tabLabel,
    ]) {
      expect(
        (await styleUnderScope(tester, tr, read)).fontFamily,
        AppFontTokens.latnTrFamily,
      );
    }
    // 600 maps through latnTr's weight map.
    final label = await styleUnderScope(
      tester,
      tr,
      () => AppTextStyles.boosterLabel,
    );
    expect(label.fontFamily, AppFontTokens.latnTrFamily);
    expect(label.fontWeight, FontWeight.w600);
    for (final read in <TextStyle Function()>[
      () => AppTextStyles.body,
      () => AppTextStyles.bodySmall,
      () => AppTextStyles.row,
      () => AppTextStyles.caption,
    ]) {
      expect(
        (await styleUnderScope(tester, tr, read)).fontFamily,
        AppFontTokens.bodyFamily,
      );
    }
  });

  testWidgets('the generated tokens follow it: a type token, a text style '
      'and a Lottie label in Baloo 2 in tr, Fredoka again after', (
    tester,
  ) async {
    TextStyle chapterKicker() => HomeTypeTokens.chapterKicker;
    final kicker = await styleUnderScope(
      tester,
      const Locale('tr'),
      chapterKicker,
    );
    expect(kicker.fontFamily, AppFontTokens.latnTrFamily);
    final h1 = await styleUnderScope(
      tester,
      const Locale('tr'),
      () => AppTextStyleTokens.h1,
    );
    expect(h1.fontFamily, AppFontTokens.latnTrFamily);
    // Read twice, the same object (cached: no allocation per frame).
    expect(identical(AppTextStyleTokens.h1, AppTextStyleTokens.h1), isTrue);
    expect(
      DisplayFace.apply(
        const TextStyle(fontFamily: AppFontTokens.displayFamily),
      ).fontFamily,
      AppFontTokens.latnTrFamily,
    );
    // Body (Nunito) tokens never change face.
    final body = await styleUnderScope(
      tester,
      const Locale('tr'),
      () => AppTextStyleTokens.body,
    );
    expect(body.fontFamily, isNot(AppFontTokens.latnTrFamily));
    final back = await styleUnderScope(
      tester,
      const Locale('en'),
      chapterKicker,
    );
    expect(back.fontFamily, AppFontTokens.displayFamily);
  });

  testWidgets('every other language keeps Fredoka', (tester) async {
    for (final code in ['en', 'de', 'hi', 'ja']) {
      final title = await styleUnderScope(
        tester,
        Locale(code),
        () => AppTextStyles.cardTitle,
      );
      expect(title.fontFamily, AppFontTokens.displayFamily, reason: code);
    }
  });

  test('the Turkish theme: Material display roles in Baloo 2, body Nunito', () {
    final theme = AppTheme.forLocale(const Locale('tr'));
    expect(identical(theme, AppTheme.forLocale(const Locale('tr'))), isTrue);
    expect(
      theme.textTheme.displayLarge?.fontFamily,
      AppFontTokens.latnTrFamily,
    );
    expect(theme.textTheme.titleLarge?.fontFamily, AppFontTokens.latnTrFamily);
    expect(theme.textTheme.bodyLarge?.fontFamily, AppFontTokens.bodyFamily);
    expect(theme.textTheme.labelLarge?.fontFamily, AppFontTokens.bodyFamily);
    expect(AppTheme.forLocale(const Locale('en')), same(AppTheme.light));
    expect(
      AppTheme.light.textTheme.displayLarge?.fontFamily,
      AppFontTokens.displayFamily,
    );
  });

  testWidgets('"Şğİ" is laid out in Baloo 2 alone, not Fredoka plus Nunito', (
    tester,
  ) async {
    const word = 'Şeker ağacı İğne';
    double width(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }

    final fredoka = AppTextStyleTokens.cardTitle;
    final baloo = LocaleScript.forLocale(const Locale('tr')).display(fredoka);
    final balooAlone = baloo.copyWith(fontFamilyFallback: const []);
    expect(baloo.fontFamily, AppFontTokens.latnTrFamily);
    // Every letter is in the face, so the fallback chain adds nothing...
    expect(width(baloo), closeTo(width(balooAlone), 1e-6));
    // ...and it is not the Fredoka (+ Nunito for ğ ş) layout.
    expect((width(baloo) - width(fredoka)).abs(), greaterThan(0.5));
  });
}
