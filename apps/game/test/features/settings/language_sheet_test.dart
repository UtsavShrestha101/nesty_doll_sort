import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// Frame 8.2's language sheet (NestyMenus `LANGS`; FIDELITY-9): the
/// autonym is never ellipsized (the trailing English name and "Coming
/// soon" give way instead), pt_BR's English name is "Portuguese", and
/// "Done" is an orange text action on the right of a left-aligned title.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> openSheet(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: GestureDetector(
              onTap: () => LanguageSheet.show(
                context,
                selectedCode: 'en',
                onSelect: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsOneWidget);
  }

  testWidgets('the selected language says so to a screen reader, and '
      'every row is a 48 dp target (review R16, R21)', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    final english = tester.getSemantics(find.bySemanticsLabel('English'));
    expect(
      english.getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(english.rect.height, greaterThanOrEqualTo(48));
    final spanish = tester.getSemantics(
      find.bySemanticsLabel(RegExp('^Español, ')),
    );
    expect(
      spanish.getSemanticsData().flagsCollection.isSelected,
      Tristate.isFalse,
    );
    expect(spanish.rect.height, greaterThanOrEqualTo(48));
    handle.dispose();
  });

  testWidgets('pt_BR reads "Português (Brasil)" · "Portuguese" (the '
      'frame’s English name)', (tester) async {
    await openSheet(tester);
    expect(find.text('Português (Brasil)'), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Portuguese (Brazil)'), findsNothing);
  });

  testWidgets('the title row: "Language" left-aligned, "Done" an orange '
      'text action on its right; no bottom button', (tester) async {
    await openSheet(tester);
    final sheet = find.byType(LanguageSheet);
    final title = find.descendant(of: sheet, matching: find.text('Language'));
    final done = find.descendant(of: sheet, matching: find.text('Done'));
    expect(tester.getCenter(done).dy, closeTo(tester.getCenter(title).dy, 1));
    expect(tester.getCenter(done).dx, greaterThan(tester.getCenter(title).dx));
    expect(
      tester.getTopLeft(title).dx,
      lessThan(tester.getSize(sheet).width / 4),
    );
    expect(tester.widget<Text>(done).style?.color, AppColorTokens.primaryEdge);
    expect(tester.widget<Text>(title).style?.fontSize, 26);
    expect(
      find.descendant(of: sheet, matching: find.byType(TactileButton)),
      findsNothing,
    );
    // A real tap target (spec §16).
    final handle = tester.ensureSemantics();
    expect(tester.getSemantics(done).rect.height, greaterThanOrEqualTo(48));
    handle.dispose();

    await tester.tap(done);
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsNothing);
  });

  for (final size in screenSizes) {
    testWidgets('no autonym is ellipsized at 1.3× text on a '
        '${size.width.toInt()}-wide phone', (tester) async {
      await openSheet(tester, size: size, textScale: 1.3);
      for (final language in launchLanguages) {
        final text = tester.widget<Text>(find.text(language.autonym));
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(text.maxLines, isNull);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(language.autonym),
        );
        // Laid out whole: its one-line width fits, so it never wrapped
        // either.
        expect(
          paragraph.size.width,
          greaterThanOrEqualTo(
            paragraph.getMaxIntrinsicWidth(double.infinity) - 0.5,
          ),
          reason: language.autonym,
        );
      }
      expectNoLayoutErrors(tester);
    });
  }

  testWidgets('with room, the English name shares the autonym’s line', (
    tester,
  ) async {
    await openSheet(tester);
    expect(
      tester.getCenter(find.text('Portuguese')).dy,
      closeTo(tester.getCenter(find.text('Português (Brasil)')).dy, 2),
    );
  });

  testWidgets('without room (360 wide, 1.3×), the trailing text moves under '
      'the autonym instead of cutting it', (tester) async {
    await openSheet(tester, size: const Size(360, 640), textScale: 1.3);
    final autonym = find.text('Português (Brasil)');
    final name = find.text('Portuguese');
    expect(
      tester.getTopLeft(name).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(autonym).dy - 1),
    );
  });

  testWidgets('screen readers hear the autonym and its detail', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    expect(find.bySemanticsLabel('Español, Coming soon'), findsOneWidget);
    expect(find.bySemanticsLabel('English'), findsWidgets);
    handle.dispose();
  });
}
