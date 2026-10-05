import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// The race atoms (vs Computer; phase 4 ui-spec-game §1): [ComputerTag]
/// (spec-prop §1.1 rule 5: "A computer opponent is always labelled a
/// computer") and [RivalPortrait] (the design's art, drawn round).
void main() {
  setUpAll(loadBundledFonts);

  testWidgets('ComputerTag: "Computer" and the computer glyph, 20 tall with '
      'the tokens\' ring, radius and fill', (tester) async {
    await pumpUi(tester, const Center(child: ComputerTag()));
    expect(find.text('Computer'), findsOneWidget);
    expect(find.byIcon(IconUses.computerTag), findsOneWidget);
    expect(find.byIcon(NestyIcons.smartDisplay), findsNothing);
    expect(
      tester.getSize(find.byType(ComputerTag)).height,
      RivalStripTokens.tagHeight,
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(ComputerTag),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, RivalStripTokens.tagFill);
    expect(
      decoration.borderRadius,
      const BorderRadius.all(Radius.circular(RivalStripTokens.tagRadius)),
    );
    final border = decoration.border! as Border;
    expect(border.top.color, RivalStripTokens.tagRing.color);
    expect(border.top.width, RivalStripTokens.tagRing.width);
    final label = tester.widget<Text>(find.text('Computer'));
    expect(label.style?.fontSize, 11);
    expect(label.style?.fontWeight, FontWeight.w800);
  });

  testWidgets('ComputerTag glyphOnly drops the word and stays 20 tall', (
    tester,
  ) async {
    await pumpUi(tester, const Center(child: ComputerTag(glyphOnly: true)));
    expect(find.text('Computer'), findsNothing);
    expect(find.byIcon(IconUses.computerTag), findsOneWidget);
    expect(
      tester.getSize(find.byType(ComputerTag)).height,
      RivalStripTokens.tagHeight,
    );
  });

  testWidgets('ComputerTag.responsive: glyph only under 360 dp, the word at '
      '360 and up', (tester) async {
    await pumpUi(tester, Center(child: ComputerTag.responsive()), width: 359);
    expect(find.text('Computer'), findsNothing);
    await pumpUi(tester, Center(child: ComputerTag.responsive()), width: 360);
    expect(find.text('Computer'), findsOneWidget);
  });

  testWidgets(
    'the tag is decorative: the row that carries it says "Computer"',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(tester, const Center(child: ComputerTag()));
      expect(find.bySemanticsLabel('Computer'), findsNothing);
      handle.dispose();
    },
  );

  testWidgets('RivalPortrait draws the rival\'s art round, in a ring, with no '
      'bare number for a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUi(tester, const Center(child: RivalPortrait(number: 2)));
    final art = tester.widget<UiArtImage>(find.byType(UiArtImage));
    expect(art.art, UiArt.rival2);
    expect(art.size, const Size.square(96));
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.bySemanticsLabel('2'), findsNothing);
    handle.dispose();
  });

  testWidgets('locked shows rival_locked; sizes follow the frames', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const Center(child: RivalPortrait(number: 3, locked: true, size: 38)),
    );
    final art = tester.widget<UiArtImage>(find.byType(UiArtImage));
    expect(art.art, UiArt.rivalLocked);
    expect(tester.getSize(find.byType(UiArtImage)), const Size.square(38));
  });

  testWidgets('emphasis adds the wide versus ring (9.6, 9.7b)', (tester) async {
    await pumpUi(
      tester,
      const Center(child: RivalPortrait(number: 1, emphasis: true)),
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(RivalPortrait),
        matching: find.byType(DecoratedBox),
      ),
    );
    final shadows = (box.decoration as BoxDecoration).boxShadow!;
    expect(shadows.map((s) => s.color), contains(AppColorTokens.versus));
    // Flutter paints the last shadow on top: the white 4 dp ring over the
    // indigo 7 dp one over the drop (CSS order reversed, frame 9.6).
    expect(shadows.last.spreadRadius, 4);
    expect(shadows.last.color, const Color(0xFFFFFDF7));
    expect(shadows[1].spreadRadius, 7);
    expect(shadows.first.blurRadius, greaterThan(0));
  });

  testWidgets('the plain ring paints over its drop shadow (9.3)', (
    tester,
  ) async {
    await pumpUi(tester, const Center(child: RivalPortrait(number: 1)));
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(RivalPortrait),
        matching: find.byType(DecoratedBox),
      ),
    );
    final shadows = (box.decoration as BoxDecoration).boxShadow!;
    expect(shadows.first.blurRadius, greaterThan(0));
    expect(shadows.last.spreadRadius, 2);
  });
}
