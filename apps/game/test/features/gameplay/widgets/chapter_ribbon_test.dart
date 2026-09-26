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
}
