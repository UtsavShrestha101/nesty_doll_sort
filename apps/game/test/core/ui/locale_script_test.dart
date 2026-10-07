import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// tokens.json `font.scripts`: Hindi keeps its size and loosens wrapped
/// lines; Japanese is drawn at 0.94 with no tracking; Latin is untouched.
void main() {
  const tracked = TextStyle(fontSize: 11, height: 1, letterSpacing: 0.88);
  const tight = TextStyle(fontSize: 16, height: 1.1);

  group('forLocale', () {
    test('Hindi, Japanese, and the rest', () {
      expect(LocaleScript.forLocale(const Locale('hi')).sizeFactor, 1);
      expect(
        LocaleScript.forLocale(const Locale('ja')).sizeFactor,
        AppFontTokens.jpanSizeFactor,
      );
      for (final code in ['en', 'es', 'de', 'fr', 'id']) {
        expect(LocaleScript.forLocale(Locale(code)), LocaleScript.latin);
      }
      expect(
        LocaleScript.forLocale(const Locale('pt', 'BR')),
        LocaleScript.latin,
      );
    });
  });

  group('Turkish (Baloo 2 for every Fredoka role, m7-5 item 28)', () {
    final tr = LocaleScript.forLocale(const Locale('tr'));
    const title = TextStyle(
      fontFamily: AppFontTokens.displayFamily,
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      height: 1,
    );
    const body = TextStyle(
      fontFamily: AppFontTokens.bodyFamily,
      fontFamilyFallback: AppFontTokens.bodyFallback,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.2,
    );

    test('its own script, size 1, no tracking change', () {
      expect(tr, isNot(LocaleScript.latin));
      expect(tr.sizeFactor, AppFontTokens.latnTrSizeFactor);
      expect(tr.sizeFactor, 1);
      expect(tr.isTall, isFalse);
      expect(tr.dropsTracking, isFalse);
      expect(tr.tracking(0.5), 0.5);
      expect(LocaleScript.forLocale(const Locale('tr', 'TR')), tr);
    });

    test('a Fredoka style takes the whole-string family, weights mapped', () {
      for (final MapEntry(key: from, value: to)
          in AppFontTokens.latnTrDisplayWeights.entries) {
        final out = tr.display(
          title.copyWith(fontWeight: FontWeight.values[from ~/ 100 - 1]),
        );
        expect(out.fontFamily, AppFontTokens.latnTrFamily);
        expect(out.fontWeight, FontWeight.values[to ~/ 100 - 1]);
      }
      expect(AppFontTokens.latnTrFamily, 'Baloo2LatnTr');
    });

    test('a Nunito style stays Nunito; other scripts leave Fredoka alone', () {
      expect(tr.display(body), same(body));
      expect(tr.style(body).fontFamily, AppFontTokens.bodyFamily);
      expect(LocaleScript.latin.display(title), same(title));
      expect(
        LocaleScript.forLocale(const Locale('hi')).display(title),
        same(title),
      );
    });

    test(
      'titles floor at 1.15 when they wrap; a single line keeps its own',
      () {
        expect(tr.style(title).height, 1, reason: 'single-line keeps it');
        expect(
          tr.style(title, role: ScriptTextRole.title).height,
          AppFontTokens.latnTrTitleLineHeight,
        );
        expect(
          tr.style(title, role: ScriptTextRole.title).fontFamily,
          AppFontTokens.latnTrFamily,
        );
        expect(
          tr.style(body, role: ScriptTextRole.body).height,
          1.2,
          reason: 'no body floor in Turkish',
        );
      },
    );
  });

  group('style', () {
    test('Latin is returned as it came', () {
      expect(
        LocaleScript.latin.style(tracked, role: ScriptTextRole.body),
        same(tracked),
      );
    });

    test('Hindi: tracking dropped, wrapped lines floored, one line kept', () {
      final hi = LocaleScript.forLocale(const Locale('hi'));
      expect(hi.style(tracked).letterSpacing, 0);
      expect(hi.style(tracked).height, 1, reason: 'single-line keeps it');
      expect(
        hi.style(tight, role: ScriptTextRole.body).height,
        AppFontTokens.devaBodyLineHeight,
      );
      expect(
        hi.style(tight, role: ScriptTextRole.title).height,
        AppFontTokens.devaTitleLineHeight,
      );
    });

    test('Japanese: tracking 0, floors 1.6 and 1.3', () {
      final ja = LocaleScript.forLocale(const Locale('ja'));
      expect(ja.style(tracked).letterSpacing, 0);
      expect(
        ja.style(tight, role: ScriptTextRole.body).height,
        AppFontTokens.jpanBodyLineHeight,
      );
      expect(ja.style(tight, role: ScriptTextRole.title).height, 1.3);
      expect(ja.tracking(0.5), 0);
    });

    test('a style already above the floor keeps its height', () {
      final hi = LocaleScript.forLocale(const Locale('hi'));
      const loose = TextStyle(fontSize: 16, height: 1.9);
      expect(hi.style(loose, role: ScriptTextRole.body).height, 1.9);
    });

    test('Latin keeps its tracking', () {
      expect(LocaleScript.latin.tracking(0.5), 0.5);
    });
  });

  group('LocaleScriptScope', () {
    Future<double> scaledSixteen(WidgetTester tester, Locale locale) async {
      late double scaled;
      await tester.pumpWidget(
        Localizations(
          locale: locale,
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
            child: LocaleScriptScope(
              child: Builder(
                builder: (context) {
                  scaled = MediaQuery.textScalerOf(context).scale(16);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      return scaled;
    }

    testWidgets('Japanese: the system scale times 0.94', (tester) async {
      expect(
        await scaledSixteen(tester, const Locale('ja')),
        closeTo(16 * 1.2 * AppFontTokens.jpanSizeFactor, 1e-9),
      );
    });

    testWidgets('Latin and Hindi: the system scale alone', (tester) async {
      expect(
        await scaledSixteen(tester, const Locale('en')),
        closeTo(19.2, 1e-9),
      );
      expect(
        await scaledSixteen(tester, const Locale('hi')),
        closeTo(19.2, 1e-9),
      );
    });

    testWidgets('a clamp below keeps the factor', (tester) async {
      late TextScaler scaler;
      await tester.pumpWidget(
        Localizations(
          locale: const Locale('ja'),
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: LocaleScriptScope(
              child: Builder(
                builder: (context) {
                  scaler = MediaQuery.textScalerOf(
                    context,
                  ).clamp(maxScaleFactor: 1.3);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(scaler.scale(10), lessThanOrEqualTo(13 + 1e-9));
    });
  });
}
