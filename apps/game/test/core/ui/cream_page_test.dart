import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/layout/cream_page.dart';

void main() {
  testWidgets('CreamPage paints canvasCream to canvasCreamLow top to bottom '
      'and fills its parent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: AppColorTokens.canvasCream,
          body: CreamPage(child: SafeArea(child: Text('hi'))),
        ),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(CreamPage),
        matching: find.byType(DecoratedBox),
      ),
    );
    final gradient =
        (box.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(gradient.colors, [
      AppColorTokens.canvasCream,
      AppColorTokens.canvasCreamLow,
    ]);
    expect(gradient.begin, Alignment.topCenter);
    expect(gradient.end, Alignment.bottomCenter);
    expect(tester.getSize(find.byType(CreamPage)), const Size(800, 600));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColorTokens.canvasCream,
    );
  });
}
