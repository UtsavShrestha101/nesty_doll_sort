import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';

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

  testWidgets('ch07+ falls back to "Chapter N" (m3-design §9.1: named '
      'ch01–ch06 only)', (tester) async {
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
    expect(find.bySemanticsLabel('CHAPTER 7 · Chapter 7'), findsOneWidget);
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
}
