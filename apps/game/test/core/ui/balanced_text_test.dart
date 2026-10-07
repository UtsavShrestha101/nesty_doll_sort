import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/win_result_chips.dart';

import 'support/ui_harness.dart';

/// CSS `text-wrap: balance` and `pretty` (frames 12.6, 10.2, 11.2).
void main() {
  setUpAll(loadBundledFonts);

  /// The widths of each laid-out line of [text].
  List<double> lineWidths(WidgetTester tester, Finder text, int length) {
    final paragraph = tester.renderObject<RenderParagraph>(text);
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: length),
    );
    final byTop = <int, List<TextBox>>{};
    for (final b in boxes) {
      byTop.putIfAbsent(b.top.round(), () => []).add(b);
    }
    return [
      for (final line in byTop.values)
        line.map((b) => b.right).reduce((a, b) => a > b ? a : b) -
            line.map((b) => b.left).reduce((a, b) => a < b ? a : b),
    ];
  }

  testWidgets('a two-line text breaks evenly, not "long line + orphan"', (
    tester,
  ) async {
    const text = 'The shelves need a moment';
    await pumpUi(
      tester,
      SizedBox(
        width: 250,
        child: BalancedText(text, style: ErrorCard.headStyle),
      ),
    );
    final widths = lineWidths(tester, find.text(text), text.length);
    expect(widths, hasLength(2));
    expect((widths[0] - widths[1]).abs(), lessThan(60));
  });

  testWidgets('a text that fits one line is left alone', (tester) async {
    await pumpUi(
      tester,
      SizedBox(
        width: 300,
        child: BalancedText('Paused', style: ErrorCard.headStyle),
      ),
    );
    expect(lineWidths(tester, find.text('Paused'), 6), hasLength(1));
  });

  testWidgets('the win note balances its two sentences (11.2)', (tester) async {
    const text = 'Fewer moves earn more stars. Replay any level from Chapters.';
    await pumpUi(
      tester,
      const SizedBox(width: 342, child: WinNotePill(text: text)),
    );
    final widths = lineWidths(tester, find.text(text), text.length);
    expect(widths, hasLength(2));
    expect((widths[0] - widths[1]).abs(), lessThan(70));
  });

  test('bindLastWord joins the last two words and leaves unspaced text', () {
    expect(bindLastWord('try again.'), 'try again.');
    expect(bindLastWord('はじめる'), 'はじめる');
    expect(bindLastWord('one'), 'one');
  });
}
