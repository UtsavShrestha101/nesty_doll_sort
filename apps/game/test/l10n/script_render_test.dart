import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';
import 'support/test_locale.dart';

/// The bundled faces draw each script (build/m7-p5/p5/l10n.md §4.6, §7.1;
/// tokens.json `font.scripts`, m7-4 9.1): with the bundled fonts loaded,
/// a Devanagari or Japanese string is laid out exactly as wide as in Baloo
/// 2 or M PLUS Rounded 1c alone, so the script face draws it, not the
/// test's em-square font or a system font; a German string is as wide as
/// in its own Latin face, so Fredoka and Nunito cover its letters.
///
/// The language sheet's autonyms (हिन्दी, 日本語) read the same in every
/// locale, so the fallback must work in English too: that case runs as soon
/// as the fonts lane bundles the two faces. The per-locale cases (the
/// booster bar and the sheet in de, hi and ja) run once their catalog is
/// in. Each is skipped with its reason until then. Run from `apps/game`.
void main() {
  late Set<String> families;

  setUpAll(() async {
    await loadBundledFonts();
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json'))
            as List<Object?>;
    families = {
      for (final entry in manifest.cast<Map<String, Object?>>())
        entry['family']! as String,
    };
  });

  /// The script faces by name: the fonts lane bundles each as a display
  /// and a body family (`Baloo2Display`, `MPLUSRounded1cBody` …), so a
  /// style's chain names the one of its own role.
  const devanagari = {
    AppFontTokens.devaDisplayFamily,
    AppFontTokens.devaBodyFamily,
  };
  const japanese = {
    AppFontTokens.jpanDisplayFamily,
    AppFontTokens.jpanBodyFamily,
  };

  bool bundled(Set<String> faces) => faces.every(families.contains);

  /// [text]'s paragraph is drawn by a [face] family: one is on the style's
  /// chain, and each word's ink equals the same word drawn in that family
  /// alone. Ink, not width: the test font and CJK are both 1 em wide, and a
  /// space comes from the style's Latin face, so a width can't tell the
  /// script face from the fallback (5B-1's handoff).
  Future<void> expectDrawnBy(
    WidgetTester tester,
    String text,
    Set<String> faces,
  ) async {
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text(text).first,
    );
    final style = paragraph.text.style!;
    final chain = [?style.fontFamily, ...?style.fontFamilyFallback];
    final family = chain.where(faces.contains).firstOrNull;
    expect(
      family,
      isNotNull,
      reason: '"$text": one of $faces is on the style\'s chain $chain',
    );
    Future<List<int>> ink(String word, TextStyle style) async {
      final painter = TextPainter(
        text: TextSpan(
          text: word,
          style: style.copyWith(color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
        textScaler: paragraph.textScaler,
      )..layout();
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), Offset.zero);
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        painter.width.ceil() + 2,
        painter.height.ceil() + 2,
      );
      final bytes = await image.toByteData();
      final result = bytes!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      painter.dispose();
      return result;
    }

    await tester.runAsync(() async {
      for (final word
          in text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty)) {
        final alone = style.copyWith(
          fontFamily: family,
          fontFamilyFallback: const [],
        );
        expect(
          await ink(word, style),
          await ink(word, alone),
          reason: '"$word" is drawn in $family',
        );
      }
    });
  }

  Widget sheet() => SingleChildScrollView(
    child: LanguageSheet(selectedCode: 'en', onSelect: (_) {}),
  );

  testWidgets('the sheet\'s autonyms are drawn by the script faces in '
      'English', (tester) async {
    if (!bundled(devanagari) || !bundled(japanese)) {
      markTestSkipped('Baloo 2 and M PLUS Rounded 1c are not bundled yet');
      return;
    }
    await pumpUi(tester, sheet(), locale: const Locale('en'));
    expectNoLayoutErrors(tester);
    await expectDrawnBy(tester, 'हिन्दी', devanagari);
    await expectDrawnBy(tester, '日本語', japanese);
  });

  /// Each script family's locale: its face, and a string that is only in
  /// its script (the check compares widths, so Latin must not be mixed in).
  final cases = <String, (Set<String>?, RegExp)>{
    'de': (null, RegExp(r'^[\p{Script=Latin}\s]+$', unicode: true)),
    'hi': (devanagari, RegExp(r'^[ऀ-ॿ\s]+$')),
    'ja': (japanese, RegExp(r'^[　-ヿ一-鿿＀-￯]+$')),
  };

  for (final MapEntry(key: code, value: (face, pure)) in cases.entries) {
    final locale = Locale(code);
    final catalog = hasCatalog(locale);

    testWidgets('$code: the booster bar and the language sheet are drawn by '
        'their faces', (tester) async {
      if (!catalog) {
        markTestSkipped('app_$code.arb is not in yet (5B-3)');
        return;
      }
      final family = face;
      if (family != null && !bundled(family)) {
        markTestSkipped('the $code script face is not bundled yet');
        return;
      }
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(
        tester,
        Scaffold(
          body: Column(
            children: [
              Expanded(child: sheet()),
              BoosterBar(
                model: const BoosterBarModel(
                  undoEnabled: true,
                  undoBadge: BoosterBadge.count(2),
                  hintEnabled: true,
                  hintBadge: BoosterBadge.count(3),
                  slotEnabled: true,
                  restartEnabled: true,
                ),
                library: FakeFxLibrary(),
                onUndo: () {},
                onHint: () {},
                onExtraSlot: () {},
                onRestart: () {},
              ),
            ],
          ),
        ),
        locale: locale,
      );
      await expectAccessibleLayout(tester);
      final labels = [
        l10n.boosterUndo,
        l10n.boosterHint,
        l10n.restart,
        l10n.languageSheetTitle,
      ].where((label) => find.text(label).evaluate().isNotEmpty);
      expect(labels, isNotEmpty, reason: 'the labels are on screen');
      var checked = 0;
      for (final label in labels) {
        if (!pure.hasMatch(label)) continue;
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label).first,
        );
        await expectDrawnBy(
          tester,
          label,
          family ?? {paragraph.text.style!.fontFamily!},
        );
        checked++;
      }
      expect(checked, greaterThan(0), reason: 'a label only in its script');
    });
  }
}
