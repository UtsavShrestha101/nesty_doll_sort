import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/records/widgets/record_stat_cell.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// A read-only Records stat (frame 10.6; docs/plans/m7-design.md §12): the
/// value over its label beside a tinted icon tile, one screen-reader node,
/// never dimmed and never tappable.
void main() {
  setUpAll(loadBundledFonts);

  Widget cell({String label = 'Levels won', UiArt? art}) => Material(
    child: SizedBox(
      width: 170,
      child: RecordStatCell(
        icon: NestyIcons.checkCircle,
        tint: AppColorTokens.successTint,
        glyphColor: AppColorTokens.success,
        art: art,
        value: '128',
        label: label,
      ),
    ),
  );

  testWidgets('shows the icon, the value and the label at full opacity', (
    tester,
  ) async {
    await pumpScreen(tester, cell());
    expect(find.text('Levels won'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.byIcon(NestyIcons.checkCircle), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('is one node reading "label, value", and its tile is 36 dp', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, cell());
    expect(find.bySemanticsLabel('Levels won, 128'), findsOneWidget);
    expect(
      tester.getSize(
        find
            .ancestor(
              of: find.byIcon(NestyIcons.checkCircle),
              matching: find.byType(NestySurface),
            )
            .first,
      ),
      const Size.square(36),
    );
    handle.dispose();
  });

  testWidgets('UI art replaces the glyph (the Stars stat)', (tester) async {
    await pumpScreen(tester, cell(art: UiArt.starFilled));
    expect(find.byIcon(NestyIcons.checkCircle), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is UiArtImage && w.art == UiArt.starFilled,
      ),
      findsOneWidget,
    );
  });

  testWidgets('a two-line label ("Daily puzzles solved") wraps, never cut', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      cell(label: 'Daily puzzles solved'),
      textScale: 1.3,
    );
    expectNoCutText(tester);
    expectNoLayoutErrors(tester);
  });
}
