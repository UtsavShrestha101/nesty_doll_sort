import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/lottie/ribbon_tint.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../../../core/ui/support/ui_harness.dart';

Widget _ribbon(VoidCallback onDone) => Center(
  child: SizedBox.fromSize(
    size: ChapterRibbon.canvas,
    child: ChapterRibbon(
      number: 2,
      chapterId: 'ch02',
      library: FakeFxLibrary(),
      onDone: onDone,
    ),
  ),
);

void main() {
  testWidgets('names the chapter (frame 4.7, L21 opens ch02)', (tester) async {
    await pumpUi(tester, _ribbon(() {}));
    expect(
      find.bySemanticsLabel('CHAPTER 2 · Rainy Café Corner'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('ch07 has its copy.md G.4 name (m7-3)', (tester) async {
    await pumpUi(
      tester,
      Center(
        child: SizedBox.fromSize(
          size: ChapterRibbon.canvas,
          child: ChapterRibbon(
            number: 7,
            chapterId: 'ch07',
            library: FakeFxLibrary(),
            onDone: () {},
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('CHAPTER 7 · Puppet Theater'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('ends after the file (2.6 s) even without it', (tester) async {
    var done = 0;
    await pumpUi(tester, _ribbon(() => done++));
    await tester.pump(const Duration(milliseconds: 2300));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(done, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(done, 1);
  });

  testWidgets('half as long under reduced motion (D48)', (tester) async {
    var done = 0;
    await pumpUi(tester, _ribbon(() => done++), reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 1350));
    expect(done, 1);
  });

  group('ChapterRibbon.rectIn (LOTTIE.md v3, for gameplay_view)', () {
    const padding = EdgeInsets.only(top: 59, bottom: 34);

    test('on 390: the 410 × 100 canvas 1:1, centred, the anchor (205, 50) '
        'on the centre line, centerTop below the safe area', () {
      final rect = ChapterRibbon.rectIn(const Size(390, 844), padding);
      expect(rect, const Rect.fromLTWH(-10, 59 + 120 - 50, 410, 100));
      expect(rect.left + 205, 195);
    });

    test('never scaled up; scaled down on a narrower screen', () {
      final wide = ChapterRibbon.rectIn(const Size(430, 932), padding);
      expect(wide.size, ChapterRibbon.canvas);
      expect(wide.center.dx, closeTo(215, 1e-9));
      final narrow = ChapterRibbon.rectIn(const Size(360, 640), padding);
      expect(narrow.width, closeTo(410 * 360 / 390, 1e-9));
      expect(narrow.height, closeTo(100 * 360 / 390, 1e-9));
      expect(narrow.center.dx, closeTo(180, 1e-9));
      expect(narrow.center.dy, closeTo(59 + 120, 1e-9));
    });
  });

  group('tinted by the chapter palette (lead note 7; frame 4.7)', () {
    testWidgets('the file goes through the palette\'s colour matrix, and the '
        'label stays white', (tester) async {
      await pumpUi(
        tester,
        Center(
          child: SizedBox.fromSize(
            size: ChapterRibbon.canvas,
            child: ChapterRibbon(
              number: 4,
              chapterId: 'ch04',
              library: FakeFxLibrary(),
              palette: ChapterTheme.byId('ch04')!.palette,
              onDone: () {},
            ),
          ),
        ),
      );
      final filtered = tester.widget<ColorFiltered>(
        find.byKey(ChapterRibbon.tintKey),
      );
      expect(filtered.colorFilter, isNotNull);
      expect(find.bySemanticsLabel('CHAPTER 4 · Snowy Cabin'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('no palette keeps the file\'s own blue', (tester) async {
      await pumpUi(tester, _ribbon(() {}));
      expect(find.byKey(ChapterRibbon.tintKey), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    test('the matrix keeps white and sends the file\'s band and edge to the '
        'palette\'s accent and its edge, for every chapter', () {
      Color apply(List<double> m, Color c) {
        final v = [c.r, c.g, c.b];
        double row(int i) =>
            m[i * 5] * v[0] + m[i * 5 + 1] * v[1] + m[i * 5 + 2] * v[2];
        return Color.from(alpha: c.a, red: row(0), green: row(1), blue: row(2));
      }

      void expectClose(Color a, Color b, String reason) {
        expect(a.r, closeTo(b.r, 0.004), reason: reason);
        expect(a.g, closeTo(b.g, 0.004), reason: reason);
        expect(a.b, closeTo(b.b, 0.004), reason: reason);
      }

      for (var n = 1; n <= 10; n++) {
        final palette = ChapterTheme.forChapter(n).palette;
        final m = RibbonTint.matrixOf(palette);
        expectClose(
          apply(m, const Color(0xFFFFFFFF)),
          const Color(0xFFFFFFFF),
          'white $n',
        );
        expectClose(
          apply(m, const Color(0xFF3D8FDE)),
          palette.accent,
          'band $n',
        );
        expectClose(
          apply(m, const Color(0xFF2B6BB0)),
          palette.accentEdge,
          'edge $n',
        );
        expect(m[15], 0);
        expect(m[18], 1, reason: 'alpha is kept');
      }
    });
  });
}
