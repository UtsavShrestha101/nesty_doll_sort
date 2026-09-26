import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// Lottie design §12 (PROGRESS D44): the text layers are hidden and a
/// localized Flutter label follows the null; a label wider than its band is
/// laid out once more at `fontSize × maxWidth / width`.
void main() {
  setUpAll(loadBundledFonts);

  group('LottieLabelPainter', () {
    test('a short label keeps its size', () {
      final painter = LottieLabelPainter(LottieLabelStyles.winRibbon)
        ..text = 'Level Complete!';
      expect(painter.fontSize, 28);
      expect(painter.size.width, lessThanOrEqualTo(232));
      painter.dispose();
    });

    test('a long label shrinks to the band', () {
      final painter = LottieLabelPainter(LottieLabelStyles.winRibbon)
        ..text = 'Niveau terminé avec brio, bravo à toi !';
      expect(painter.fontSize, lessThan(28));
      expect(
        painter.size.width,
        lessThanOrEqualTo(LottieLabelStyles.winRibbon.maxWidth + 1),
      );
      painter.dispose();
    });

    test('lays out again only when the text changes', () {
      final painter = LottieLabelPainter(LottieLabelStyles.chapterRibbon)
        ..text = 'CHAPTER 2 · Rainy Café Corner';
      final size = painter.fontSize;
      painter.text = 'CHAPTER 2 · Rainy Café Corner';
      expect(painter.fontSize, size);
      painter.text = 'CHAPTER 3 · Seaside Market';
      expect(painter.fontSize, 20);
      painter.dispose();
    });

    test('paints its baseline centre on the null, following its scale', () {
      final painter = LottieLabelPainter(LottieLabelStyles.familyCounter)
        ..text = '1 / 4';
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // Drawing is a no-op check: no throw, and nothing for an empty label.
      painter.paint(canvas, const Offset(60, 30), nullScale: 1.22);
      painter.text = '';
      painter.paint(canvas, const Offset(60, 30));
      recorder.endRecording().dispose();
      painter.dispose();
    });

    test('the table of §12', () {
      expect(LottieLabelStyles.familyCounter.restNull, const Offset(60, 30));
      expect(LottieLabelStyles.winRibbon.baseline, const Offset(0, 10.08));
      expect(LottieLabelStyles.winRibbon.shadowOffset, const Offset(0, 2));
      expect(LottieLabelStyles.chapterRibbon.maxWidth, 262);
      expect(
        LottieLabelStyles.chapterRibbon.textStyle().fontFamily,
        AppFontTokens.displayFamily,
      );
    });
  });

  group('LottieTextOverlay', () {
    testWidgets('shows the lottie when given, and reads the label once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      const key = Key('ribbon');
      await pumpUi(
        tester,
        const Center(
          child: SizedBox(
            width: 360,
            child: LottieTextOverlay(
              label: 'Level Complete!',
              style: LottieLabelStyles.winRibbon,
              lottie: SizedBox.expand(key: key),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(key)), const Size(360, 110));
      expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('without a lottie, draws the fallback and the label', (
      tester,
    ) async {
      const key = Key('fallback');
      await pumpUi(
        tester,
        const Center(
          child: SizedBox(
            width: 180,
            child: LottieTextOverlay(
              label: 'CHAPTER 2 · Rainy Café Corner',
              style: LottieLabelStyles.chapterRibbon,
              fallback: ColoredBox(key: key, color: Color(0xFF3E7FC0)),
            ),
          ),
        ),
      );
      // Half the canvas width: the composition scales to the box.
      expect(tester.getSize(find.byKey(key)), const Size(180, 50));
      expect(tester.takeException(), isNull);
    });
  });
}
