import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/widgets/buttons/icon_tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/header/screen_header.dart';

import 'support/ui_harness.dart';

void main() {
  setUpAll(loadBundledFonts);

  Future<void> pump(
    WidgetTester tester,
    ScreenHeaderTitleAlignment? alignment, {
    bool leading = true,
  }) => pumpUi(
    tester,
    Align(
      alignment: Alignment.topLeft,
      // Null: the constructor's default, the one every screen uses.
      child: alignment == null
          ? ScreenHeader(title: 'Records', onBack: leading ? () {} : null)
          : ScreenHeader(
              title: 'Records',
              onBack: leading ? () {} : null,
              titleAlignment: alignment,
            ),
    ),
    feedback: RecordingFeedback(),
  );

  testWidgets('the default is start (m7-4 10.2): the title begins 12 dp after '
      'the 48 dp leading box', (tester) async {
    await pump(tester, null);
    final title = tester.getRect(find.text('Records'));
    expect(title.left, 48 + 12);
    final header = tester.getRect(find.byType(ScreenHeader));
    // No trailing spacer: the title's box runs to the header's right edge.
    expect(tester.getRect(find.byType(FittedBox)).right, header.right);
  });

  testWidgets('center, when asked for, is centred as before', (tester) async {
    await pump(tester, ScreenHeaderTitleAlignment.center);
    final back = tester.getRect(find.byType(IconTactileButton));
    expect(back.right, 48);
    final title = tester.getRect(find.text('Records'));
    expect(
      title.center.dx,
      closeTo(tester.getRect(find.byType(ScreenHeader)).center.dx, 0.5),
    );
  });

  testWidgets('a tab screen with no button starts its title at 20 (tokens '
      '`screenHeader.tabScreen`): 4 dp inside the 16 dp page margin', (
    tester,
  ) async {
    await pump(tester, null, leading: false);
    expect(tester.getRect(find.text('Records')).left, 4);
  });
}
