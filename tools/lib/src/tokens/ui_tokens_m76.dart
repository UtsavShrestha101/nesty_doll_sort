// What tokens v6 (Claude Design m7-6) adds to ui_tokens.gen.dart beyond the
// generic sections (the habits', the Computer tag's, in
// screen_tokens_m76.dart): the local habits' notes and respect rules
// (documentation: they are the habits' rules, never values), the shared
// ribbon title the Day 7 chest now wears (Part 2 item 5), and the checks
// that tie Part 2's repeated numbers to their sources (item 7's text box).
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/screen_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Every m7-6 UI class that is not a generic section, in file order.
List<ConstClass> uiM76Classes(TokenReader t) {
  t
    ..documented(
      r'habits.$note',
      reason:
          'the local habits\' design note: they change no game rule '
          '(rewards, limits, unlocks and the streak stay the game\'s)',
    )
    ..documented(
      'habits.respect',
      reason:
          'the respect rules every habit keeps (plan-local-habits "The '
          'respect rules"); the ethics tests hold the app to them, never '
          'values',
    );
  _checkWinRibbonBox(t);
  return [_ribbonTitle(t)];
}

/// `textFit.winRibbon.box` is the 290 ribbon's text box (m7-6 item 7).
void _checkWinRibbonBox(TokenReader t) {
  final box = t.peek('textFit.winRibbon.box');
  final textBox = t.peek('winRibbon.size.textBox');
  if (box is! List<Object?> ||
      textBox is! List<Object?> ||
      box.length != 2 ||
      textBox.length != 2 ||
      box[0] != textBox[0] ||
      box[1] != textBox[1]) {
    throw TokenFormatException(
      'textFit.winRibbon.box',
      'is not winRibbon.size.textBox (m7-6 item 7)',
    );
  }
}

final _ribbon = RegExp(
  r'^m7-6 \(item 5\): the shared ribbon title of 10\.3b: (.+), padding '
  r'(\d+)/(\d+), radius (\d+), top −(\d+), gradient\.(\w+) with edge '
  r'(0 \d+px 0 #[0-9A-Fa-f]{6}), text-shadow (0 \d+px 0 rgba\([^)]*\))\. '
  r'13\.6b redrawn$',
);

/// `gift.chest.ribbon` (item 5): the Day 7 chest card wears the shared
/// orange ribbon title of 10.3b, which the tokens now spell out.
ConstClass _ribbonTitle(TokenReader t) {
  const path = 'gift.chest.ribbon';
  const name = 'RibbonTitleTokens';
  final c = ConstClass(
    name,
    'The shared orange ribbon title of 10.3b (`RibbonTitle`), on a modal '
    'card\'s top edge; the Day 7 chest card wears it too (m7-6 item 5, '
    'tokens.json `$path`; 13.6b redrawn).',
  );
  final text = t.peek(path);
  final m = text is String ? _ribbon.firstMatch(text) : null;
  if (m == null) {
    throw TokenFormatException(path, 'unexpected wording "$text"');
  }
  final font = tryParseFontSpec(m[1]!);
  if (font == null || font.tail != null) {
    throw TokenFormatException(path, 'expected a font, got "${m[1]}"');
  }
  final edge = parseBoxShadowList(m[7]!);
  final primaryEdge = t.peek('color.primaryEdge');
  if (primaryEdge is! String ||
      edge.single.color != parseCssColor(primaryEdge)) {
    throw TokenFormatException(path, 'its edge is not color.primaryEdge');
  }
  final shadow = parseBoxShadowList(m[8]!).single;
  final style = textStyleLiteral(t, font, path);
  void add(String member, String expression, {String? doc, String? type}) {
    t.string(path, symbol: '$name.$member');
    c.add(member, expression, doc: doc, type: type);
  }

  add(
    'text',
    '${style.substring(0, style.length - 1)}, shadows: [Shadow(color: '
        '${colorLiteral(shadow.color)}, offset: '
        '${offsetLiteral(shadow.dx, shadow.dy)})])',
    doc: 'The title, one line, with its text shadow.',
  );
  add('padding', edgeInsetsLiteral([num.parse(m[2]!), num.parse(m[3]!)], path));
  add('radius', doubleLiteral(num.parse(m[4]!)));
  add(
    'overhang',
    doubleLiteral(num.parse(m[5]!)),
    doc: 'How far the ribbon rises above the card\'s top edge.',
  );
  add('face', gradientReference(t, m[6]!, path), doc: 'Its face.');
  add(
    'edge',
    shadowListLiteral(edge),
    type: 'List<NestyShadow>',
    doc: 'Its solid edge (AppColorTokens.primaryEdge).',
  );
  return c;
}
