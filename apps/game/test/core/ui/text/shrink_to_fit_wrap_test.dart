import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/text/shrink_to_fit_text.dart';

import '../../../features/support/screen_harness.dart' show expectNoCutText;
import '../support/ui_harness.dart';

/// `overflowLines` and `fixedWidth` (M7 5B overflow: a translated chapter or
/// family name that no longer fits one line, or a box inside an
/// IntrinsicHeight that can't hold a LayoutBuilder).
void main() {
  setUpAll(loadBundledFonts);
  final style = AppTextStyleTokens.cardTitle.copyWith(fontSize: 15);
  const name = 'Boutique de jouets ensoleillée';

  Future<Text> shown(WidgetTester tester, Widget child) async {
    await pumpUi(tester, Center(child: SizedBox(width: 140, child: child)));
    return tester.widget<Text>(
      find.descendant(
        of: find.byType(ShrinkToFitText),
        matching: find.byType(Text),
      ),
    );
  }

  testWidgets('one line that cannot fit even scaled wraps to overflowLines', (
    tester,
  ) async {
    final text = await shown(
      tester,
      ShrinkToFitText(
        name,
        style: style,
        maxLines: 1,
        minFontScale: 0.85,
        overflowLines: 2,
      ),
    );
    expect(text.maxLines, 2);
    expectNoCutText(tester);
  });

  testWidgets('without overflowLines it stays on one line', (tester) async {
    final text = await shown(
      tester,
      ShrinkToFitText(name, style: style, maxLines: 1, minFontScale: 0.85),
    );
    expect(text.maxLines, 1);
  });

  testWidgets('a string that fits is not wrapped early', (tester) async {
    final text = await shown(
      tester,
      ShrinkToFitText('Short', style: style, maxLines: 1, overflowLines: 2),
    );
    expect(text.maxLines, 1);
    expect(text.style?.fontSize, 15);
  });

  testWidgets('fixedWidth fits inside an IntrinsicHeight', (tester) async {
    await pumpUi(
      tester,
      Center(
        child: SizedBox(
          width: 200,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: ShrinkToFitText(
                    'Boulangers boulangers boulangers',
                    style: style,
                    maxLines: 3,
                    fixedWidth: 90,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(LayoutBuilder), findsNothing);
  });

  testWidgets('Japanese wraps between characters instead of shrinking', (
    tester,
  ) async {
    final text = await shown(
      tester,
      ShrinkToFitText(
        'すべての家族が帰ってきました。',
        style: style.copyWith(fontSize: 24),
        maxLines: 3,
      ),
    );
    // Before the fix the unbroken "word" was wider than the box, so the font
    // stepped down to 0.6 before the text wrapped.
    expect(text.style?.fontSize, greaterThan(24 * 0.75));
  });
}
