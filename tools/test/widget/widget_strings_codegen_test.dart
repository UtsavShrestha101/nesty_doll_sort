import 'dart:io';

import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/widget/widget_strings_codegen.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();

  Map<String, Map<String, Object?>> realArbs() => {
    for (final code in {
      for (final l in widgetStringsLocales) ...[l.arb, ?l.fallbackArb],
    })
      code: decodeArb(
        File(
          p.join(root.path, widgetArbDir, 'app_$code.arb'),
        ).readAsStringSync(),
      ),
  };

  Map<String, Object?> arb(Map<String, String> values) => values;

  group('widgetStringsFor', () {
    const en = WidgetStringsLocale('en', ios: 'en', android: 'values');
    final full = {
      'widgetGalleryName': 'Daily puzzle',
      'widgetGalleryDescription': 'Your streak.',
      'widgetLockedTitle': 'Daily puzzle',
    };

    test('reads the three keys', () {
      expect(widgetStringsFor(en, {'en': arb(full)}), full);
    });

    test('a regional overlay falls back to its language', () {
      const ptBr = WidgetStringsLocale(
        'pt_BR',
        ios: 'pt-BR',
        android: 'values-pt-rBR',
        fallbackArb: 'pt',
      );
      final values = widgetStringsFor(ptBr, {
        'pt_BR': arb({'widgetGalleryName': 'Quebra-cabeça diário'}),
        'pt': arb({
          'widgetGalleryName': 'Puzzle diário',
          'widgetGalleryDescription': 'Sua sequência.',
          'widgetLockedTitle': 'Puzzle diário',
        }),
      });
      expect(values['widgetGalleryName'], 'Quebra-cabeça diário');
      expect(values['widgetGalleryDescription'], 'Sua sequência.');
    });

    test('a missing key, an empty one and a placeholder are errors', () {
      expect(
        () => widgetStringsFor(en, {
          'en': arb({...full}..remove('widgetLockedTitle')),
        }),
        throwsFormatException,
      );
      expect(
        () => widgetStringsFor(en, {
          'en': arb({...full, 'widgetGalleryName': ' '}),
        }),
        throwsFormatException,
      );
      expect(
        () => widgetStringsFor(en, {
          'en': arb({...full, 'widgetGalleryName': 'Level {level}'}),
        }),
        throwsFormatException,
      );
    });
  });

  group('the files', () {
    const en = WidgetStringsLocale('en', ios: 'en', android: 'values');
    final values = {
      'widgetGalleryName': 'Today\'s "puzzle" & more <3',
      'widgetGalleryDescription': '@home',
      'widgetLockedTitle': 'Daily puzzle',
    };

    test('iOS: ARB key names, quotes escaped, a generated header', () {
      final text = iosStringsFile(en, values);
      expect(text, startsWith('/*\n  GENERATED — do not edit'));
      expect(
        text,
        contains(
          r'"widgetGalleryName" = "Today'
          "'"
          r's \"puzzle\" & more <3";',
        ),
      );
      expect(text, contains('"widgetLockedTitle" = "Daily puzzle";'));
    });

    test('Android: snake_case names, aapt syntax escaped, a header', () {
      final text = androidStringsFile(en, values);
      expect(text, contains('<!--\n  GENERATED — do not edit'));
      expect(
        text,
        contains(
          '<string name="widget_gallery_name">Today\\\'s \\"puzzle\\" '
          '&amp; more &lt;3</string>',
        ),
      );
      expect(
        text,
        contains('<string name="widget_gallery_description">\\@home</string>'),
      );
    });

    test('the names map: widgetLockedTitle → widget_locked_title', () {
      expect(androidNameOf('widgetLockedTitle'), 'widget_locked_title');
    });
  });

  group('the real files', () {
    test('cover every language, in both platforms\' folders', () {
      final files = widgetStringFiles(realArbs());
      expect(files, hasLength(widgetStringsLocales.length * 2));
      expect(
        files.keys,
        containsAll([
          'apps/game/ios/NestyWidget/en.lproj/Localizable.strings',
          'apps/game/ios/NestyWidget/pt-BR.lproj/Localizable.strings',
          'apps/game/ios/NestyWidget/ja.lproj/Localizable.strings',
          'apps/game/android/app/src/main/res/values/widget_strings.xml',
          'apps/game/android/app/src/main/res/values-pt-rBR/widget_strings.xml',
          'apps/game/android/app/src/main/res/values-ja/widget_strings.xml',
        ]),
      );
      expect(
        widgetStringsLocales.map((l) => l.arb),
        containsAll([
          'en',
          'es',
          'pt',
          'pt_BR',
          'id',
          'hi',
          'de',
          'fr',
          'tr',
          'ja',
        ]),
      );
    });

    test(
      'are in sync with the ARBs (run dart run nesty_tools:gen_widget_strings)',
      () {
        for (final MapEntry(key: path, value: content) in widgetStringFiles(
          realArbs(),
        ).entries) {
          final file = File(p.join(root.path, path));
          expect(file.existsSync(), isTrue, reason: '$path is missing');
          expect(
            file.readAsStringSync(),
            content,
            reason:
                '$path is stale: run dart run nesty_tools:gen_widget_strings',
          );
        }
      },
    );
  });
}
