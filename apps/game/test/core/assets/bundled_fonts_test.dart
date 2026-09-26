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
};

Future<void> _loadBundledFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<Object?>;
  final loaded = <String, int>{};
  for (final entry in manifest.cast<Map<String, Object?>>()) {
    final family = entry['family']! as String;
    if (!_bundled.containsKey(family)) continue;
    final loader = FontLoader(family);
    final fonts = (entry['fonts']! as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final font in fonts) {
      loader.addFont(rootBundle.load(font['asset']! as String));
    }
    await loader.load();
    loaded[family] = fonts.length;
  }
  expect(loaded, _bundled, reason: 'FontManifest.json families');
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
