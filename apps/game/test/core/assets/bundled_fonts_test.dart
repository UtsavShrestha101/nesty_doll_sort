// The bundled fonts must load and draw (offline-first, CLAUDE.md rule 3;
// design/README.md "Typography & icons"). flutter_test doesn't load pubspec
// fonts by itself: every family falls back to the square-glyph FlutterTest
// font. This test loads each declared font file from the real asset bundle
// with FontLoader, so a broken TTF, a wrong path or a missing glyph fails
// here, not on a device.
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The families this app bundles, and how many files (weights) each has.
const _bundled = {
  AppFontTokens.displayFamily: 3, // Fredoka 500/600/700
  AppFontTokens.bodyFamily: 4, // Nunito 500–800
  NestyIcons.fontFamily: 1,
  // The script faces, one family per Latin role (l10n.md §4.6).
  AppFontTokens.devaDisplayFamily: 2, // Baloo 2 600/700
  AppFontTokens.devaBodyFamily: 3, // Baloo 2 500/600/700
  AppFontTokens.jpanDisplayFamily: 2, // M PLUS Rounded 1c 700/800
  AppFontTokens.jpanBodyFamily: 2, // M PLUS Rounded 1c 500/700
};

/// Each script face file on its own, as `probe:<file name>`, so a test can
/// lay text out in exactly that file and compare.
const _probe = 'probe:';

/// The script families' files, by family: `<Family>-<Style>.ttf`.
final _scriptFiles = <String, List<String>>{};

Future<void> _loadBundledFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<Object?>;
  final loaded = <String, int>{};
  final scripts = {
    AppFontTokens.devaDisplayFamily,
    AppFontTokens.devaBodyFamily,
    AppFontTokens.jpanDisplayFamily,
    AppFontTokens.jpanBodyFamily,
  };
  for (final entry in manifest.cast<Map<String, Object?>>()) {
    final family = entry['family']! as String;
    if (!_bundled.containsKey(family)) continue;
    final loader = FontLoader(family);
    final fonts = (entry['fonts']! as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final font in fonts) {
      final asset = font['asset']! as String;
      loader.addFont(rootBundle.load(asset));
      if (scripts.contains(family)) {
        _scriptFiles.putIfAbsent(family, () => []).add(asset);
        final probe = FontLoader('$_probe${asset.split('/').last}')
          ..addFont(rootBundle.load(asset));
        await probe.load();
      }
    }
    await loader.load();
    loaded[family] = fonts.length;
  }
  expect(loaded, _bundled, reason: 'FontManifest.json families');
}

/// The outline weight a script file's style suffix names.
int _outlineWeight(String asset) {
  final style = asset.split('-').last.replaceAll('.ttf', '');
  return switch (style) {
    'Medium' => 500,
    'SemiBold' => 600,
    'Bold' => 700,
    'ExtraBold' => 800,
    _ => throw StateError('unknown style in $asset'),
  };
}

double _width(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// How many pixels [text] inks at 40 px: heavier outlines ink more, and the
/// same outlines ink exactly the same. (Japanese glyphs are all one em
/// wide, so widths can't tell its weights, or the fallback font, apart.)
Future<int> _ink(String text, TextStyle style) async {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: style.copyWith(fontSize: 40, color: const Color(0xFF000000)),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), Offset.zero);
  final width = painter.width.ceil();
  final height = painter.height.ceil();
  painter.dispose();
  final picture = recorder.endRecording();
  final image = picture.toImageSync(width, height);
  picture.dispose();
  final bytes = (await image.toByteData())!;
  image.dispose();
  var inked = 0;
  for (var i = 3; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i) > 127) inked++;
  }
  return inked;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadBundledFonts);

  test('Fredoka and Nunito draw their own glyphs at every bundled weight', () {
    const sample = 'Nesty Doll Sort 1234';
    // The FlutterTest fallback draws every glyph one em wide.
    final fallback = _width(
      sample,
      const TextStyle(fontFamily: 'NotBundled', fontSize: 20),
    );
    for (final (family, weights) in [
      (AppFontTokens.displayFamily, AppFontTokens.displayWeights),
      (AppFontTokens.bodyFamily, AppFontTokens.bodyWeights),
    ]) {
      final widths = [
        for (final weight in weights)
          _width(
            sample,
            TextStyle(fontFamily: family, fontSize: 20, fontWeight: weight),
          ),
      ];
      for (final width in widths) {
        expect(width, isNot(closeTo(fallback, 0.5)), reason: family);
      }
      // Heavier weights are wider in both families, so each weight resolved
      // to its own file (the engine picks by the file's usWeightClass).
      for (var i = 1; i < widths.length; i++) {
        expect(
          widths[i],
          greaterThan(widths[i - 1]),
          reason: '$family ${weights[i]}',
        );
      }
    }
  });

  // Each role family answers a Fredoka or Nunito weight with the script
  // weight tokens.json font.scripts maps it to (m7-4 9.1): the engine
  // matches the style's weight against the files' OS/2 weight classes, and
  // the text must come out exactly as wide as in the file whose outlines
  // are the mapped weight.
  for (final (script, sample, role, family, weights) in [
    (
      'Devanagari',
      'हिन्दी स्तर पूरा',
      'display',
      AppFontTokens.devaDisplayFamily,
      AppFontTokens.devaDisplayWeights,
    ),
    (
      'Devanagari',
      'हिन्दी स्तर पूरा',
      'body',
      AppFontTokens.devaBodyFamily,
      AppFontTokens.devaBodyWeights,
    ),
    (
      'Japanese',
      '日本語のレベルクリア！',
      'display',
      AppFontTokens.jpanDisplayFamily,
      AppFontTokens.jpanDisplayWeights,
    ),
    (
      'Japanese',
      '日本語のレベルクリア！',
      'body',
      AppFontTokens.jpanBodyFamily,
      AppFontTokens.jpanBodyWeights,
    ),
  ]) {
    test('$script $role text draws the weights font.scripts maps', () async {
      final fallback = await _ink(
        sample,
        const TextStyle(fontFamily: 'NotBundled'),
      );
      final files = _scriptFiles[family]!;
      final byOutline = {
        for (final file in files)
          _outlineWeight(file): await _ink(
            sample,
            TextStyle(fontFamily: '$_probe${file.split('/').last}'),
          ),
      };
      // Heavier outlines ink more, so the comparison tells weights apart.
      expect(byOutline.values.toSet(), hasLength(byOutline.length));
      for (final ink in byOutline.values) {
        expect(ink, isNot(fallback), reason: family);
      }
      for (final MapEntry(key: latin, value: scriptWeight) in weights.entries) {
        expect(
          byOutline.keys,
          contains(scriptWeight),
          reason: '$family bundles no $scriptWeight outlines',
        );
        final ink = await _ink(
          sample,
          TextStyle(
            fontFamily: family,
            fontWeight: FontWeight.values.firstWhere((w) => w.value == latin),
          ),
        );
        expect(
          ink,
          byOutline[scriptWeight],
          reason: '$family at $latin should draw $scriptWeight',
        );
      }
    });
  }

  test('the token styles draw Devanagari and Japanese from their role '
      'face', () async {
    for (final (sample, style, family, weights) in [
      (
        'हिन्दी',
        AppTextStyleTokens.body,
        AppFontTokens.devaBodyFamily,
        AppFontTokens.devaBodyWeights,
      ),
      (
        'हिन्दी',
        AppTextStyleTokens.h1,
        AppFontTokens.devaDisplayFamily,
        AppFontTokens.devaDisplayWeights,
      ),
      (
        '日本語',
        AppTextStyleTokens.body,
        AppFontTokens.jpanBodyFamily,
        AppFontTokens.jpanBodyWeights,
      ),
      (
        '日本語',
        AppTextStyleTokens.h1,
        AppFontTokens.jpanDisplayFamily,
        AppFontTokens.jpanDisplayWeights,
      ),
    ]) {
      final scriptWeight = weights[style.fontWeight!.value]!;
      final file = _scriptFiles[family]!.firstWhere(
        (f) => _outlineWeight(f) == scriptWeight,
      );
      final expected = await _ink(
        sample,
        style.copyWith(
          fontFamily: '$_probe${file.split('/').last}',
          fontFamilyFallback: const [],
        ),
      );
      expect(
        await _ink(sample, style),
        expected,
        reason: '${style.fontFamily} ${style.fontWeight} "$sample" → $file',
      );
    }
  });

  testWidgets('the design text styles lay out in the bundled fonts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('Level 12', style: AppTextStyleTokens.h1),
            Text('Sort the dolls', style: AppTextStyleTokens.body),
            Text('1,250', style: AppTextStyleTokens.number),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('every NestyIcons glyph draws from the bundled subset', (
    tester,
  ) async {
    const size = 48.0;
    final icons = NestyIcons.byName.entries.toList();
    final keys = [for (final e in icons) GlobalKey(debugLabel: e.key)];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          children: [
            for (var i = 0; i < icons.length; i++)
              RepaintBoundary(
                key: keys[i],
                child: Container(
                  width: size,
                  height: size,
                  color: const Color(0xFFFFFFFF),
                  child: Icon(
                    icons[i].value,
                    size: size,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // How much of each box is inked. The subset's glyphs cover about 7–58% of
    // the em square (chevron_right to extension). Without the font every
    // codepoint draws the same FlutterTest fallback box (32%), and a missing
    // glyph draws nothing.
    final coverage = <String, double>{};
    await tester.runAsync(() async {
      for (var i = 0; i < icons.length; i++) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(keys[i]),
        );
        final image = await boundary.toImage();
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var inked = 0;
        for (var p = 0; p < bytes.lengthInBytes; p += 4) {
          if (bytes.getUint8(p) < 128) inked++;
        }
        coverage[icons[i].key] = inked / (image.width * image.height);
        image.dispose();
      }
    });
    for (final MapEntry(key: name, value: inked) in coverage.entries) {
      expect(inked, inInclusiveRange(0.04, 0.7), reason: name);
    }
    expect(
      coverage.values.toSet().length,
      greaterThan(icons.length * 3 ~/ 4),
      reason: 'icons draw their own shapes, not one fallback glyph',
    );
    expect(coverage['chevron_right'], lessThan(0.15));
    expect(coverage['extension'], greaterThan(0.45));
  });
}
