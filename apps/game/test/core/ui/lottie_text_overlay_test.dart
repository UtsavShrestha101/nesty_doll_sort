import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// Lottie design §12 (PROGRESS D44): the text layers are hidden and a
/// localized Flutter label follows the null; a label wider (or taller) than
/// its box is laid out once more at `fontSize × maxWidth / width`. Since
/// m7-5 the win ribbon's box is `tokens.winRibbon.size.textBox` (266 × 40,
/// Fredoka Bold 24, in the 290 band) and the chapter's `textFit.chapterRibbon`
/// (312 × 32, 20, in the 336 band), centred on the ribbon anchor.
void main() {
  setUpAll(loadBundledFonts);

  group('LottieLabelPainter', () {
    test('a short label keeps its size', () {
      final painter = LottieLabelPainter(LottieLabelStyles.winRibbon)
        ..text = 'Level Complete!';
      expect(painter.fontSize, 24);
      expect(painter.size.width, lessThanOrEqualTo(266));
      painter.dispose();
    });

    test('a long label shrinks to the band', () {
      final painter = LottieLabelPainter(LottieLabelStyles.winRibbon)
        ..text = 'Niveau terminé avec brio, bravo à toi !';
      expect(painter.fontSize, lessThan(24));
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

    test('the table of §12 (LOTTIE.md v3 ribbons, m7-5 boxes)', () {
      expect(LottieLabelStyles.familyCounter.restNull, const Offset(60, 30));
      final win = LottieLabelStyles.winRibbon;
      expect(win.fontSize, 24);
      expect((win.maxWidth, win.maxHeight), (266, 40));
      expect(Size(win.maxWidth, win.maxHeight), WinRibbonTokens.textBox);
      expect(win.restNull, const Offset(205, 55));
      expect(win.canvas, const Size(410, 110));
      // 0.36 em below the null, as the file's preview text (28 at 10.08).
      expect(win.baseline.dy, closeTo(0.36 * 24, 1e-9));
      expect(win.shadowOffset, const Offset(0, 2));
      final chapter = LottieLabelStyles.chapterRibbon;
      expect(chapter.fontSize, 20);
      expect((chapter.maxWidth, chapter.maxHeight), (312, 32));
      expect(
        Size(chapter.maxWidth, chapter.maxHeight),
        TextFitTokens.chapterRibbonBox,
      );
      expect(chapter.restNull, const Offset(205, 50));
      expect(chapter.canvas, const Size(410, 100));
      expect(chapter.baseline, const Offset(0, 7.2));
      expect(chapter.textStyle().fontFamily, AppFontTokens.displayFamily);
      expect(chapter.textStyle().fontWeight, FontWeight.w700);
    });

    // The box is centred on the ribbon anchor, i.e. on the null.
    Rect box(LottieLabelStyle style) => Rect.fromCenter(
      center: Offset.zero,
      width: style.maxWidth,
      height: style.maxHeight,
    );

    for (final (style, name, label) in const [
      (LottieLabelStyles.winRibbon, 'win', 'Level Complete!'),
      (LottieLabelStyles.chapterRibbon, 'chapter', 'CHAPTER 4 · Snowy Cabin'),
    ]) {
      test('$name: the English label keeps its size, inside its box', () {
        final painter = LottieLabelPainter(style)..text = label;
        expect(painter.fontSize, style.fontSize);
        expect(
          box(style).inflate(0.5).contains(painter.bounds.topLeft),
          isTrue,
        );
        expect(
          box(style).inflate(0.5).contains(painter.bounds.bottomRight),
          isTrue,
          reason: '${painter.bounds}',
        );
        painter.dispose();
      });
    }

    for (final (style, name, label) in const [
      (
        LottieLabelStyles.winRibbon,
        'win',
        'STUFE ABGESCHLOSSEN – HERVORRAGEND GEMACHT!',
      ),
      (
        LottieLabelStyles.chapterRibbon,
        'chapter',
        'KAPITEL 10 · VERSCHNEITE BERGHÜTTE AM WALDRAND',
      ),
    ]) {
      test('$name: an all-caps German label scales down to fit the '
          '${style.maxWidth.toInt()} × ${style.maxHeight.toInt()} box, '
          'centred on the anchor', () {
        final painter = LottieLabelPainter(style)..text = label;
        expect(painter.fontSize, lessThan(style.fontSize));
        final bounds = painter.bounds;
        expect(bounds.width, lessThanOrEqualTo(style.maxWidth + 0.5));
        expect(bounds.center.dx, closeTo(0, 0.5));
        expect(box(style).inflate(0.5).contains(bounds.topLeft), isTrue);
        expect(
          box(style).inflate(0.5).contains(bounds.bottomRight),
          isTrue,
          reason: '$bounds',
        );
        // Shrunk about its visual centre: the baseline moves in with it.
        final fitted = painter.fontSize / style.fontSize;
        final full = LottieLabelPainter(style)..text = 'LEVEL';
        expect(bounds.center.dy, closeTo(full.bounds.center.dy * fitted, 1));
        full.dispose();
        painter.dispose();
      });
    }
  });

  group('LottieRibbonFit (LOTTIE.md m7-5 ribbons)', () {
    test('a band is never wider than the screen − 70', () {
      expect(WinRibbonTokens.maxWidthInset, 70);
      expect(LottieRibbonFit.bandWidthFor(290, 390), 290);
      expect(LottieRibbonFit.bandWidthFor(290, 360), 290);
      expect(LottieRibbonFit.bandWidthFor(290, 320), 250);
      expect(LottieRibbonFit.bandWidthFor(336, 430), 336);
      expect(LottieRibbonFit.bandWidthFor(336, 406), 336);
      expect(LottieRibbonFit.bandWidthFor(336, 390), 320);
      expect(LottieRibbonFit.bandWidthFor(336, 0), 0);
    });

    test('the canvas at full size, centred on the screen, its anchor on the '
        'centre line: on 390 it overhangs each edge by 10', () {
      final rect = LottieRibbonFit.rectFor(
        const Size(410, 110),
        screenWidth: 390,
        centerY: 91,
      );
      expect(rect, const Rect.fromLTWH(-10, 36, 410, 110));
      // The anchor (205, 55) lands on the screen's centre.
      expect(rect.left + 205, 195);
      final narrow = LottieRibbonFit.rectFor(
        const Size(410, 100),
        screenWidth: 320,
        centerY: 179,
      );
      expect(narrow.size, const Size(410, 100));
      expect(narrow.center.dx, closeTo(160, 1e-9));
      expect(narrow.center.dy, closeTo(179, 1e-9));
    });
  });

  group('LottieLabelStyle.copyWith', () {
    test('changes the box width or the shadow, and compares by value', () {
      final win = LottieLabelStyles.winRibbon;
      final narrow = win.copyWith(maxWidth: 226);
      expect(narrow.maxWidth, 226);
      expect(narrow.maxHeight, win.maxHeight);
      expect(narrow.shadowColor, win.shadowColor);
      expect(win.copyWith(), win);
      expect(win.copyWith().hashCode, win.hashCode);
      expect(narrow, isNot(win));
      const fold = Color(0x59123456);
      expect(win.copyWith(shadowColor: fold).shadowColor, fold);
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
      // The composition's 410 × 110 aspect.
      final size = tester.getSize(find.byKey(key));
      expect(size.width, 360);
      expect(size.height, closeTo(360 * 110 / 410, 1e-6));
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
            width: 205,
            child: LottieTextOverlay(
              label: 'CHAPTER 2 · Rainy Café Corner',
              style: LottieLabelStyles.chapterRibbon,
              fallback: ColoredBox(key: key, color: Color(0xFF3E7FC0)),
            ),
          ),
        ),
      );
      // Half the canvas width: the composition scales to the box.
      final size = tester.getSize(find.byKey(key));
      expect(size.width, 205);
      expect(size.height, closeTo(50, 1e-6));
      expect(tester.takeException(), isNull);
    });
  });
}
