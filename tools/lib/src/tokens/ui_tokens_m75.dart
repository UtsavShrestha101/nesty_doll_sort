// What tokens v5 (Claude Design m7-5) adds to ui_tokens.gen.dart beyond the
// generic sections (the gift's, the slot chip's, the splash fade's, in
// screen_tokens_m75.dart): the `type` index of each surface's text styles
// (Part 2 item 2), checked against the gift sheet's sizes, and the gift's
// note (its track, rewards, unlock and clock rule stay the game's).
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/screen_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Every m7-5 UI class that is not a generic section, in file order.
List<ConstClass> uiM75Classes(TokenReader t) {
  t.documented(
    r'gift.$note',
    reason:
        'the gift\'s design note: its track, rewards, unlock and clock rule '
        'are the game\'s (Remote Config login_gift_track, LoginGiftRules), '
        'never read from tokens',
  );
  final note = t.documented(r'type.$note', reason: 'prose, in each class doc');
  final classes = [
    for (final surface in t.keys('type'))
      if (!surface.startsWith(r'$')) _typeStyles(t, surface, note),
  ];
  _checkGiftSizes(t);
  _giftChest(t);
  return classes;
}

/// `gift.chest` (13.6): the day-7 chest card is the milestone chest card
/// (`ChestCardTokens`, `ChestMotionTokens`) with its own copy, so every
/// leaf is a copy.md id or behaviour, documented with checks.
void _giftChest(TokenReader t) {
  const p = 'gift.chest';
  const known = {'title', 'tint', 'body', 'chips', 'buttons'};
  for (final key in t.keys(p)) {
    if (!known.contains(key)) {
      throw TokenFormatException('$p.$key', 'unknown gift chest field');
    }
  }
  final copyId = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$');
  final title = t.documented(
    '$p.title',
    reason:
        'copy.md ids: the ARB keys of the card title and its short form '
        '(TextFitTokens.giftChestTitle*; checked)',
  );
  final m = RegExp(
    r'^(\w+) \(([^)]+)\); short form (\w+) \(([^)]+)\)$',
  ).firstMatch(title);
  if (m == null || t.peek('textFit.giftChestTitle.short') != m[3]) {
    throw TokenFormatException(
      '$p.title',
      'expected "<id> (<text>); short form <textFit.giftChestTitle.short> '
          '(<text>)"',
    );
  }
  final body = t.documented('$p.body', reason: 'a copy.md id (the ARB key)');
  if (!copyId.hasMatch(body)) {
    throw TokenFormatException('$p.body', 'expected a copy.md id');
  }
  final chips = t.peek('$p.chips');
  if (chips is! List<Object?> ||
      chips.isEmpty ||
      !chips.every((c) => c is String && copyId.hasMatch(c))) {
    throw TokenFormatException('$p.chips', 'expected copy.md ids');
  }
  t.documented(
    '$p.chips',
    reason: 'the day-7 chips by copy.md id (the ARB keys $chips)',
  );
  t.documented(
    '$p.tint',
    reason:
        'no gift tint: the house orange ribbon of 10.3b and 5.6 '
        '(WinRibbonTokens.defaultColors)',
  );
  t.documentedExact(
    '$p.buttons',
    'Open, then Collect; no Double it',
    reason: 'the chest card\'s day-7 gift mode: Open, then Collect',
  );
}

/// A `type` value: `<font>[, <word>…][ (<aside>)]`, the font as
/// [tryParseFontSpec] reads it, then these words.
final _aside = RegExp(r'^(.*?) \(([^()]+)\)$');
final _shortSize = RegExp(r'^(\d+(?:\.\d+)?) on 16:9$');
final _colorName = RegExp(r'^[a-z][A-Za-z0-9]*$');
final _capsExample = RegExp(r'^[A-Z][A-Z ]*$');
final _letterSpacing = RegExp(r'^letter-spacing (\d+(?:\.\d+)?)em$');

/// `type.<surface>`: one `TextStyle` per entry, `<entry>Caps` when it draws
/// in capitals and `<entry>ShortSize` when 16:9 gives its own size.
ConstClass _typeStyles(TokenReader t, String surface, String note) {
  final name = '${surface[0].toUpperCase()}${surface.substring(1)}TypeTokens';
  final c = ConstClass(
    name,
    'The text styles of the $surface surfaces (tokens.json `type.$surface`): '
    '$note A `…Caps` member '
    'says the text is drawn in capitals (CSS `text-transform`), a '
    '`…ShortSize` member the size on 16:9.',
  );
  for (final key in t.keys('type.$surface')) {
    final path = 'type.$surface.$key';
    final member = memberName(key);
    final raw = t.string(path, symbol: '$name.$member');
    final aside = _aside.firstMatch(raw);
    final words = (aside == null ? raw : aside[1]!).split(', ');
    final font = tryParseFontSpec(words.first);
    if (font == null || font.tail != null) {
      throw TokenFormatException(path, 'expected a font first, got "$raw"');
    }
    var caps = false;
    var tabular = font.tabular;
    var chapterInk = false;
    double? spacingEm;
    for (final word in words.skip(1)) {
      if (word == 'caps') {
        caps = true;
      } else if (word == 'tabular') {
        tabular = true;
      } else if (word == 'chapter ink') {
        chapterInk = true;
      } else if (_letterSpacing.firstMatch(word) case final m?) {
        spacingEm = double.parse(m[1]!);
      } else {
        throw TokenFormatException(path, 'unknown style word "$word"');
      }
    }
    if (chapterInk && font.color != null) {
      throw TokenFormatException(path, 'two colours');
    }
    double? shortSize;
    String? colorName;
    String? example;
    if (aside != null) {
      final text = aside[2]!;
      if (_shortSize.firstMatch(text) case final m?) {
        shortSize = double.parse(m[1]!);
      } else if (_colorName.hasMatch(text)) {
        final named = t.has('color.$text') ? t.peek('color.$text') : null;
        if (font.color == null ||
            named is! String ||
            parseCssColor(named) != font.color) {
          throw TokenFormatException(path, 'its colour is not color.$text');
        }
        colorName = text;
      } else if (caps && _capsExample.hasMatch(text)) {
        example = text;
      } else {
        throw TokenFormatException(path, 'unknown aside "($text)"');
      }
    }
    final style = (
      family: font.family,
      weight: font.weight,
      size: font.size,
      height: font.height,
      color: font.color,
      tabular: tabular,
      tail: null,
    );
    final notes = [
      if (colorName != null) 'the colour is `AppColorTokens.$colorName`',
      if (chapterInk) 'the colour is the chapter palette\'s `ink`',
      if (font.color == null && !chapterInk) 'the surface gives the colour',
      if (tabular) 'tabular figures',
      if (example != null) 'e.g. "$example"',
    ];
    c.add(
      member,
      textStyleLiteral(
        t,
        style,
        path,
        letterSpacing: spacingEm == null
            ? null
            : double.parse((spacingEm * font.size).toStringAsFixed(4)),
      ),
      doc: '`$raw`${notes.isEmpty ? '' : ': ${notes.join('; ')}'}.',
    );
    if (caps) {
      t.string(path, symbol: '$name.${member}Caps');
      c.add('${member}Caps', 'true', doc: '[$member] is drawn in capitals.');
    }
    if (shortSize != null) {
      t.string(path, symbol: '$name.${member}ShortSize');
      c.add(
        '${member}ShortSize',
        doubleLiteral(shortSize),
        doc: '[$member]\'s size on 16:9 (390×693).',
      );
    }
  }
  return c;
}

/// The gift sheet's sizes repeat its `type` styles: the 16:9 sizes, and the
/// title and sub rows' heights (size × line height, rounded as the frames
/// draw them). A change to one without the other fails here.
void _checkGiftSizes(TokenReader t) {
  FontSpec style(String key) {
    final raw = t.peek('type.gift.$key')! as String;
    return tryParseFontSpec(_aside.firstMatch(raw)?[1] ?? raw)!;
  }

  num shortOf(String key) {
    final raw = t.peek('type.gift.$key')! as String;
    final aside = _aside.firstMatch(raw)?[2];
    final m = aside == null ? null : _shortSize.firstMatch(aside);
    if (m == null) {
      throw TokenFormatException('type.gift.$key', 'needs its 16:9 size');
    }
    return num.parse(m[1]!);
  }

  void same(String path, num expected) {
    if (t.peek(path) != expected) {
      throw TokenFormatException(path, 'is not $expected (tokens `type.gift`)');
    }
  }

  for (final (key, short) in [
    ('title', 'gift.short.title.size'),
    ('sub', 'gift.short.sub.size'),
    ('amount', 'gift.short.amount'),
  ]) {
    same(short, shortOf(key));
  }
  for (final key in ['title', 'sub']) {
    final font = style(key);
    same('gift.sheet.$key.height', (font.size * font.height!).round());
    same('gift.short.$key.height', (shortOf(key) * font.height!).round());
  }
}
