// The generic per-screen emitter of tokens v3 (m7-3; phase 4 architecture
// §1.1): one const class per `layout.<screen>` section (and `shop`,
// `chestModal`, `settings`, `textLink`), a member per leaf named by its
// camelCased path. Each value becomes the Dart type its shape says:
//
//   number                        double (int for counts and `…Ms`)
//   `padding` list                EdgeInsets (CSS 1-, 2-, 3- or 4-value order)
//   2 numbers under a size key    Size;  `origin`, `offset` Offset;
//                                 `points` List<Offset>;  `rect` (4) Rect
//   other number lists            List<double> (`hiddenSlots` List<int>)
//   `#RRGGBB`, `rgba(…)`, `white` Color
//   `gradient.<name>`             a checked reference to AppGradientTokens
//   `Fredoka|Nunito <w> <size> …` TextStyle (an unbundled weight fails)
//   `<n>px <color>`               TokenStroke
//   `linear-gradient(…)`          LinearGradient
//   a CSS box-shadow              List<NestyShadow>
//   a glyph key (`glyph`, …)      the glyph name, checked against `icons`
//
// Anything else is prose: a strict parser in [_specials] reads the numbers
// out of it, or [_documentedLeaves] names it with its reason. An unknown
// string fails the build, so a new design value is never silently dropped.
import 'dart:math' as math;

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

part 'screen_tokens_m75.dart';
part 'screen_tokens_m76.dart';

/// The per-screen sections, tokens.json path → generated class.
const screenTokenSections = {
  'layout.tutorial': 'TutorialTokens',
  'layout.sizeBlend': 'SizeBlendTokens',
  'layout.settingsRows': 'SettingsRowsTokens',
  'layout.noCoins': 'NoCoinsTokens',
  'layout.museumDetail': 'MuseumDetailTokens',
  'layout.languageSheet': 'LanguageSheetTokens',
  'toast': 'ToastLayoutTokens',
  'textFit': 'TextFitTokens',
  'screenHeader': 'ScreenHeaderTokens',
  'motion.chest.collect': 'ChestCollectTokens',
  'motion.rivalReact': 'RivalReactTokens',
  'motion.museumIdle': 'MuseumIdleTokens',
  'motion.firstLaunch': 'FirstLaunchTokens',
  'motion.spinner': 'SpinnerMotionTokens',
  'motion.purchaseItem': 'PurchaseItemTokens',
  'motion.relitHome': 'RelitHomeTokens',
  'motion.relitTwinkle': 'RelitTwinkleTokens',
  'layout.rivalStrip': 'RivalStripTokens',
  'layout.raceBar': 'RaceBarTokens',
  'layout.short169': 'Short169Tokens',
  'layout.winStars': 'WinStarsTokens',
  'layout.winStarsShort': 'WinStarsShortTokens',
  'layout.chestCard': 'ChestCardTokens',
  'layout.home': 'HomeTokens',
  'layout.homeShort': 'HomeShortTokens',
  'layout.chapters': 'ChaptersTokens',
  'layout.museum': 'MuseumTokens',
  'layout.records': 'RecordsTokens',
  'layout.rivalSelect': 'RivalSelectTokens',
  'layout.replayCard': 'ReplayCardTokens',
  'layout.hintMiddle': 'HintMiddleTokens',
  'layout.winTwinkles': 'WinTwinklesTokens',
  'layout.generating': 'GeneratingTokens',
  'shop': 'ShopTokens',
  'chestModal': 'ChestModalTokens',
  'settings': 'SettingsTokens',
  'textLink': 'TextLinkTokens',
  // Tokens v5 (m7-5): the splash's top fade (item 11), the chest's +1 slot
  // chip and the daily gift (App Flow section 13).
  'layout.splash': 'SplashTokens',
  'chest.slotChip': 'ChestSlotChipTokens',
  'gift.button': 'GiftButtonTokens',
  'gift.sheet': 'GiftSheetTokens',
  'gift.tile': 'GiftTileTokens',
  'gift.tally': 'GiftTallyTokens',
  'gift.claim': 'GiftClaimTokens',
  'gift.reducedMotion': 'GiftReducedMotionTokens',
  'gift.short': 'GiftShortTokens',
  // Tokens v6 (m7-6): the Computer tag and the local habits (App Flow
  // section 14).
  ...m76ScreenTokenSections,
};

/// One generated class for the section at [path] (a [screenTokenSections]
/// key). [skip] holds sub-paths another emitter accounts for.
ConstClass screenTokens(
  TokenReader t,
  String path, {
  required String className,
  Set<String> skip = const {},
}) {
  final note = t.has('$path.\$note') ? t.peek('$path.\$note') : null;
  // The 16:9 sections are measured on the short screen.
  final short =
      path.endsWith('Short') ||
      path == 'layout.short169' ||
      path == 'gift.short' ||
      path == 'habits.month.short';
  final c = ConstClass(
    className,
    'tokens.json `$path`${note == null ? '' : ' ($note)'}, in dp on the '
    '${short ? '390×693 (16:9)' : '390×844'} reference unless a member says '
    'otherwise.',
  );
  final env = _Env(t);
  for (final leaf in leafPaths(t.peek(path), path)) {
    if (skip.any((s) => leaf == s || leaf.startsWith('$s.'))) continue;
    final segments = leaf.substring(path.length + 1).split('.');
    if (segments.last.startsWith(r'$')) {
      t.documented(leaf, reason: 'a design note, in the class doc');
      continue;
    }
    final String member;
    try {
      member = [
        memberName(segments.first),
        for (final s in segments.skip(1))
          '${s[0].toUpperCase()}${s.substring(1)}',
      ].join();
    } on FormatException {
      // A reserved word (m7-5 `gift.tally.in`) is fine when a special parser
      // names the members itself.
      if (_specials[leaf] == null &&
          _m75Specials[leaf] == null &&
          _m76Specials[leaf] == null) {
        rethrow;
      }
      _emitLeaf(_Leaf(t, c, env, leaf, segments.join('_')));
      continue;
    }
    _emitLeaf(_Leaf(t, c, env, leaf, member));
  }
  return c;
}

/// What the emitter checks values against, read once per section.
final class _Env {
  _Env(this.t)
    : glyphs = {
        for (final MapEntry(:key, :value)
            in (t.peek('icons')! as Map<String, Object?>).entries)
          if (!key.startsWith(r'$') &&
              value is String &&
              RegExp(r'^[a-z0-9_]+$').hasMatch(value))
            value,
      };

  final TokenReader t;

  /// Every glyph `icons` names (the bundled font has each; §1.4).
  final Set<String> glyphs;
}

/// One leaf being emitted.
final class _Leaf {
  _Leaf(this.t, this.c, this.env, this.path, this.member);

  final TokenReader t;
  final ConstClass c;
  final _Env env;
  final String path;
  final String member;

  String get key => path.split('.').last;

  String symbol([String? name]) => '${c.name}.${name ?? member}';

  /// The value, read without a ledger entry ([add] makes one).
  String get text => t.peek(path)! as String;

  /// Adds [name] (default [member]) and records it on this leaf.
  void add(String expression, {String? name, String? doc, String? type}) {
    t.string(path, symbol: symbol(name));
    c.add(
      name ?? member,
      expression,
      doc: doc ?? '`${t.peek(path)}`.',
      type: type,
    );
  }

  RegExpMatch match(String regex) {
    final m = RegExp('^$regex\$').firstMatch(text);
    if (m == null) {
      throw TokenFormatException(path, 'unexpected wording "${t.peek(path)}"');
    }
    return m;
  }
}

const _nr = r'(\d+(?:\.\d+)?)';
const _color = r'(#[0-9A-Fa-f]{3,8}|rgba?\([^)]*\)|white)';
const _font = r'((?:Fredoka|Nunito) \d{3} \d+(?:\.\d+)? ?[^,:;]*?)';

/// Counts and `…Ms` durations are ints; every other number is a double.
const _intKeys = {
  'columns',
  'rows',
  'columnsAdsRemoved',
  'undoSlot',
  'restartSlot',
  'coins',
  // Tokens v5 (m7-5): a count of rows, and a flight's `ms`.
  'foldedAbove',
  'ms',
};

/// List keys whose two numbers are a width and a height.
const _sizeKeys = {
  'size',
  'art',
  'thumb',
  'figurine',
  'stand',
  'towerStand',
  'screen',
  'viewBox',
  'icon',
  // Tokens v4 (m7-4): the chest's art box, textFit's text boxes.
  'artBox',
  'box',
  // Tokens v5 (m7-5): the gift sheet's day-7 chest.
  'chest',
};

/// Keys whose string is a glyph of the bundled font.
const _glyphKeys = {'glyph', 'undoBadge', 'icon'};

/// The prose tail each font value may carry after its style.
const _fontTails = {
  'layout.rivalStrip.tag.text': 'sentence case',
  'layout.replayCard.reason': 'with the replay glyph',
  'layout.noCoins.heading': 'balanced',
  'shop.cardName.skin': 'one line',
  'shop.cardName.theme': 'one line, ellipsis',
  'layout.languageSheet.english':
      'right, before the radio; not shown on the English row',
};

/// Prose kept as documentation, with why.
const _documentedLeaves = {
  'layout.home.tiles.order':
      'copy and order of the Home tiles: the ARB\'s, lane M (frame 2.1)',
  'layout.home.chapterCard.accent':
      'the chapter\'s ChapterThemeTokens palette (lane M)',
  'settings.reduceMotion.default':
      'a setting default, never read from tokens: SettingsDefaults.'
      'reduceMotion (rule_tokens_test pins it)',
  'layout.tutorial.chip':
      'copy: the tutorial card\'s step chip, from the ARB ("STEP {step} OF '
      '3", copy.md)',
  'layout.sizeBlend.rule':
      'the size blend (m7-4 4.7, 4.12), hand-written in HomeLayout and the '
      'win card\'s CelebrationLayout',
  'layout.settingsRows.reminderOff':
      'behaviour of the reminder switch (10.2h), SettingsPage (lane D)',
  'layout.languageSheet.native':
      'the language sheet\'s script fonts (font.scripts), 5B',
  'layout.languageSheet.change':
      'behaviour: a language change applies at once (m7-4 Choices 9.3), 5B',
  'toast.app.streakSaved':
      'the streak-saved banner is the info toast (m7-4 10.7), lane D',
  'textFit.cardsAndSheets':
      'the overflow rule of cards and sheets (wrap; 2-line buttons at 1.3×)',
  'textFit.sheetRows.rule':
      'the sheet rows\' chip placement (10.9c), hand-written in the rows',
  'screenHeader.title':
      'fontSize.screenTitle (AppTextStyleTokens.screenTitle), start-aligned '
      'beside the button (ScreenHeader, C-HDR); the colour is '
      'AppColorTokens.textPrimary',
  'layout.chestCard.artFit.svg':
      'the chest SVGs\' visible box, the derivation of artFit (design note)',
  'layout.chestCard.artFit.frames':
      'the chest\'s top 56 dp below the card top follows from padding top + '
      'the art box (design note; the chest test measures it)',
  'layout.chestCard.artFit.superseded':
      'a design note: the 200×170 box is gone',
  'layout.rivalSelect.selection':
      'which rival a visit preselects, as built (m7-4 4.5), RivalSelectPage',
  'layout.rivalSelect.shortScreen':
      'the short screen\'s scroll and fade as built (m7-4 Choices 10.4; '
      'lead note 10: a 16 dp mask, a 12 dp gap), RivalSelectPage',
  'layout.chapters.progressCount':
      'the won count right-aligned with the bar (10.4), ChapterSectionCard',
  'layout.chapters.accordion':
      'the accordion as built (m7-4 Choices 4.8), ChaptersPage',
};

/// Prose pinned word for word (the hand-written code follows it).
const _exactLeaves = {
  'layout.winStars.starsCanvas.lottie': ('ui_stars', 'FxId.uiStars (lane O)'),
  'layout.chestCard.lottie.name': ('ui_chest', 'FxId.uiChest (lane O)'),
  'motion.rivalReact.lottie': ('ui_rival_react', 'FxId.uiRivalReact'),
  'motion.rivalReact.reducedMotion': (
    'frame 0, still',
    'FxMotionPolicy: an ambient file rests on frame 0',
  ),
  'motion.museumIdle.lottie': ('ui_museum_idle', 'FxId.uiMuseumIdle'),
  'motion.museumIdle.reducedMotion': (
    'frame 0, still',
    'FxMotionPolicy: an ambient file rests on frame 0',
  ),
  'motion.firstLaunch.reducedMotion': (
    'cut',
    'GameplayEntrance: no fade under reduce motion',
  ),
  'motion.chest.collect.hintRing.on': (
    'the Hint badge, as the hint lands',
    'the booster bar\'s hint ring (lane O, F-CH2)',
  ),
  'motion.chest.collect.gainTag.text': (
    '+{count}',
    'copy: chest_gain_tag, from the ARB',
  ),
  'motion.purchaseItem.swap': (
    'the price chip becomes Equip / Use with motion.tagPop',
    'the Shop card\'s purchase (m7-4 4.11), with MotionTokens.tagPop*',
  ),
  'motion.purchaseItem.haptic': ('success', 'HapticsService.success'),
  'motion.relitTwinkle.motion': (
    'fx_twinkle once at that point when the card lands, then the glyph '
        'stays; reduce motion: the glyph only',
    'the relit card\'s twinkle (m7-4 4.17), lane O',
  ),
  'layout.hintMiddle.arrow': ('unchanged', 'the hint arrow (lane B)'),
  'layout.winStarsShort.notePill': (
    'not shown; the tip waits for a taller screen',
    'the win card on 16:9 (lane O)',
  ),
  'chestModal.glow.showsOn': (
    'open and open_idle',
    'the rays show with ui_chest\'s open segments (lane O)',
  ),
  'settings.reduceMotion.control': (
    'segmented Off · On · System',
    'SettingsSegmentedRow (lane D)',
  ),
};

void _emitLeaf(_Leaf l) {
  final t = l.t;
  final special =
      _specials[l.path] ?? _m75Specials[l.path] ?? _m76Specials[l.path];
  if (special != null) return special(l);
  final reason =
      _documentedLeaves[l.path] ??
      _m75DocumentedLeaves[l.path] ??
      _m76DocumentedLeaves[l.path];
  if (reason != null) {
    t.documented(l.path, reason: reason);
    return;
  }
  // Tokens v4 (m7-4): a `note` or `use` leaf is the design's prose about
  // its section, like a `$note`.
  if ((l.key == 'note' || l.key == 'use') && t.peek(l.path) is String) {
    t.documented(l.path, reason: 'a design note, in the design only');
    return;
  }
  // Tokens v4 `textFit.*.short`: one copy.md id (a list is [_emitList]'s),
  // or prose naming a family of ids (`booster_*_short`).
  if (t.peek(l.path) case final String value when l.key == 'short') {
    if (RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      l.add(
        '[${stringLiteral(value)}]',
        type: 'List<String>',
        doc: 'The copy.md id of the short form (the ARB key).',
      );
    } else {
      t.documented(
        l.path,
        reason: 'the short forms copy.md names (`## Short forms`), 5B',
      );
    }
    return;
  }
  final exact =
      _exactLeaves[l.path] ??
      _m75ExactLeaves[l.path] ??
      _m76ExactLeaves[l.path];
  if (exact != null) {
    final (text, why) = exact;
    t.documentedExact(l.path, text, reason: why);
    if (lottieContractOf(text) == null && text.startsWith('ui_')) {
      throw TokenFormatException(l.path, 'no Lottie contract "$text"');
    }
    return;
  }
  switch (t.peek(l.path)) {
    case bool():
      l.c.add(l.member, '${t.boolean(l.path, symbol: l.symbol())}');
    case num():
      if (_intKeys.contains(l.key) || l.key.endsWith('Ms')) {
        l.c.add(l.member, '${t.integer(l.path, symbol: l.symbol())}');
      } else {
        l.c.add(l.member, doubleLiteral(t.number(l.path, symbol: l.symbol())));
      }
    case List<Object?>():
      _emitList(l);
    case String():
      _emitString(l);
    default:
      throw TokenFormatException(l.path, 'unexpected value');
  }
}

void _emitList(_Leaf l) {
  final t = l.t;
  final list = t.peek(l.path)! as List<Object?>;
  if (l.key == 'points') {
    final points = t.list(l.path, symbol: l.symbol());
    final offsets = [
      for (final point in points)
        if (point is List<Object?> &&
            point.length == 2 &&
            point.every((v) => v is num))
          offsetLiteral(point[0]! as num, point[1]! as num)
        else
          throw TokenFormatException(l.path, 'points are [x, y] pairs'),
    ];
    l.c.add(l.member, '[${offsets.join(', ')}]', type: 'List<Offset>');
    return;
  }
  // Tokens v4 (m7-4): a tile's [face, glyph] colours.
  if (list.isNotEmpty && list.every((v) => v is String && isCssColor(v))) {
    final colors = t.strings(l.path, symbol: l.symbol());
    l.c.add(
      l.member,
      '[${colors.map((v) => colorLiteral(parseCssColor(v))).join(', ')}]',
      type: 'List<Color>',
      doc: '`${colors.join(', ')}`.',
    );
    return;
  }
  // Tokens v4 `textFit.*.short`: the copy.md ids of a surface's short forms.
  if (l.key == 'short' &&
      list.isNotEmpty &&
      list.every((v) => v is String && RegExp(r'^[a-z0-9_]+$').hasMatch(v))) {
    final ids = t.strings(l.path, symbol: l.symbol());
    l.c.add(
      l.member,
      '[${ids.map(stringLiteral).join(', ')}]',
      type: 'List<String>',
      doc: 'The copy.md ids of the short forms (the ARB keys).',
    );
    return;
  }
  if (!list.every((v) => v is num)) {
    throw TokenFormatException(
      l.path,
      'a list of strings is prose: parse it or document it',
    );
  }
  final numbers = t.numbers(l.path, symbol: l.symbol());
  if (l.key == 'padding') {
    l.c.add(l.member, edgeInsetsLiteral(numbers, l.path));
  } else if (_sizeKeys.contains(l.key) && numbers.length == 2) {
    l.c.add(l.member, sizeLiteral(numbers[0], numbers[1]));
  } else if (l.key == 'rect' && numbers.length == 4) {
    // Tokens v4 `layout.tutorial.pauseHole.rect`: x, y, width, height.
    l.c.add(
      l.member,
      'Rect.fromLTWH(${numbers.map(doubleLiteral).join(', ')})',
      doc: 'x, y, width, height (`$numbers`).',
    );
  } else if ((l.key == 'origin' || l.key == 'offset') && numbers.length == 2) {
    l.c.add(l.member, offsetLiteral(numbers[0], numbers[1]));
  } else if (l.key == 'hiddenSlots') {
    if (!numbers.every((n) => n is int)) {
      throw TokenFormatException(l.path, 'slots are integers');
    }
    l.c.add(l.member, '[${numbers.join(', ')}]', type: 'List<int>');
  } else {
    l.c.add(
      l.member,
      '[${numbers.map(doubleLiteral).join(', ')}]',
      type: 'List<double>',
    );
  }
}

void _emitString(_Leaf l) {
  final t = l.t;
  final value = t.peek(l.path)! as String;
  if (l.key == 'gradient' && RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(value)) {
    l.add(gradientReference(t, value, l.path));
    return;
  }
  if (RegExp(r'^gradient\.[a-z][A-Za-z0-9]*$').hasMatch(value)) {
    l.add(gradientReference(t, value.substring(9), l.path));
    return;
  }
  if (_glyphKeys.contains(l.key) && RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
    if (!l.env.glyphs.contains(value)) {
      throw TokenFormatException(
        l.path,
        'glyph "$value" is not in tokens.json `icons` (the font has only '
        'those)',
      );
    }
    l.add(stringLiteral(l.text), doc: 'The `$value` glyph (`NestyIcons`).');
    return;
  }
  if (isCssColor(value)) {
    l.add(colorLiteral(parseCssColor(l.text)));
    return;
  }
  final stroke = tryParseStroke(value);
  if (stroke != null) {
    l.add(strokeLiteral(stroke));
    return;
  }
  final font = tryParseFontSpec(value);
  if (font != null) {
    final tail = _fontTails[l.path];
    if (font.tail != tail) {
      throw TokenFormatException(
        l.path,
        font.tail == null
            ? 'expected the tail "$tail"'
            : 'unexpected prose after the font: "${font.tail}"',
      );
    }
    l.add(textStyleLiteral(t, font, l.path));
    return;
  }
  if (isCssLinearGradient(value)) {
    l.add(linearGradientLiteral(parseCssLinearGradient(value), l.path));
    return;
  }
  // Tokens v5 (m7-5): a colour by name, an art reference, a radial
  // gradient, a copy.md id.
  if (_m75String(l, value)) return;
  // Tokens v6 (m7-6): a day number's colour and weight, no face, a mark's
  // meaning, a copy id.
  if (_m76String(l, value)) return;
  try {
    final shadows = parseBoxShadowList(value);
    l.add(shadowListLiteral(shadows), type: 'List<NestyShadow>');
    return;
  } on FormatException {
    // Not a shadow either: prose.
  }
  throw TokenFormatException(
    l.path,
    'prose the codegen can\'t read ("$value"): add a parser to _specials or '
    'a reason to _documentedLeaves (tools/lib/src/tokens/'
    'screen_tokens_codegen.dart)',
  );
}

/// `AppGradientTokens.<name>`, after checking tokens.json has it.
String gradientReference(TokenReader t, String name, String path) {
  if (!t.has('gradient.$name')) {
    throw TokenFormatException(path, 'there is no gradient.$name');
  }
  return 'AppGradientTokens.$name';
}

/// `EdgeInsets` from a CSS padding list (top, right, bottom, left order).
String edgeInsetsLiteral(List<num> v, String path) {
  final d = v.map(doubleLiteral).toList();
  return switch (d.length) {
    1 => 'EdgeInsets.all(${d[0]})',
    2 => 'EdgeInsets.symmetric(vertical: ${d[0]}, horizontal: ${d[1]})',
    3 => 'EdgeInsets.fromLTRB(${d[1]}, ${d[0]}, ${d[1]}, ${d[2]})',
    4 => 'EdgeInsets.fromLTRB(${d[3]}, ${d[0]}, ${d[1]}, ${d[2]})',
    _ => throw TokenFormatException(path, 'padding has 1–4 values'),
  };
}

/// `TokenStroke(width: …, color: …)`.
String strokeLiteral(CssStroke stroke) =>
    'TokenStroke(width: ${doubleLiteral(stroke.width)}, '
    'color: ${colorLiteral(stroke.color)})';

/// A `TextStyle` for [font], its family and weight checked against the
/// bundled fonts (tokens.json `font`), with an optional [letterSpacing] in
/// logical px (tokens v5's `letter-spacing <n>em`, already × the size).
String textStyleLiteral(
  TokenReader t,
  FontSpec font,
  String path, {
  double? letterSpacing,
}) {
  final role = switch (font.family) {
    'Fredoka' => 'display',
    'Nunito' => 'body',
    _ => throw TokenFormatException(path, 'unknown family ${font.family}'),
  };
  final family = t.peek('font.$role.family');
  final weights = t.peek('font.$role.weights');
  if (family != font.family ||
      weights is! List<Object?> ||
      !weights.contains(font.weight)) {
    throw TokenFormatException(
      path,
      '${font.family} ${font.weight} is not a bundled weight ($weights)',
    );
  }
  return 'TextStyle(${['fontFamily: ${stringLiteral(font.family)}', 'fontSize: ${doubleLiteral(font.size)}', 'fontWeight: FontWeight.w${font.weight}', 'fontFamilyFallback: AppFontTokens.${role}Fallback', if (font.height != null) 'height: ${doubleLiteral(font.height!)}', if (font.height != null) 'leadingDistribution: TextLeadingDistribution.even', if (font.color != null) 'color: ${colorLiteral(font.color!)}', if (letterSpacing != null) 'letterSpacing: ${doubleLiteral(letterSpacing)}', if (font.tabular) 'fontFeatures: [FontFeature.tabularFigures()]'].join(', ')})';
}

/// A `LinearGradient` for a CSS `linear-gradient(…)`: the angle as the
/// `gradient` section maps it (the line reaches a square box's corners).
String linearGradientLiteral(CssLinearGradient g, String path) {
  final positions = resolveStopPositions([for (final s in g.stops) s.position]);
  final a = cssAngleToAlignment(g.angle);
  final colors = '[${g.stops.map((s) => colorLiteral(s.color)).join(', ')}]';
  final implicit = g.stops.every((s) => s.position is ImplicitStop);
  final stops = [
    for (final p in positions)
      if (p is FractionStop)
        doubleLiteral(p.fraction)
      else
        throw TokenFormatException(path, 'px stops need the gradient section'),
  ];
  return 'LinearGradient(begin: ${alignmentLiteral(a.beginX, a.beginY)}, '
      'end: ${alignmentLiteral(a.endX, a.endY)}, colors: $colors'
      '${implicit ? '' : ', stops: [${stops.join(', ')}]'})';
}

/// `[NestyShadow(…), …]` for a parsed box-shadow list.
String shadowListLiteral(List<CssShadow> layers) {
  final literals = layers.map((l) {
    final args = [
      'color: ${colorLiteral(l.color)}',
      if (l.inset) 'inset: true',
      if (l.dx != 0) 'dx: ${doubleLiteral(l.dx)}',
      if (l.dy != 0) 'dy: ${doubleLiteral(l.dy)}',
      if (l.blur != 0) 'blur: ${doubleLiteral(l.blur)}',
      if (l.spread != 0) 'spread: ${doubleLiteral(l.spread)}',
    ];
    return 'NestyShadow(${args.join(', ')})';
  });
  return '[${literals.join(', ')}]';
}

FontSpec _fontOf(_Leaf l, String text) {
  final font = tryParseFontSpec(text);
  if (font == null || font.tail != null) {
    throw TokenFormatException(l.path, 'expected a font, got "$text"');
  }
  return font;
}

CssStroke _strokeOf(_Leaf l, String width, String color) =>
    (width: double.parse(width), color: parseCssColor(color));

const _numberWords = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5};

/// Checks that `fontSize.<name>` is the style a prose value repeats.
void _checkFontSize(_Leaf l, String name, int weight, num size, num height) {
  final base = 'fontSize.$name';
  if (!l.t.has(base) ||
      l.t.peek('$base.weight') != weight ||
      l.t.peek('$base.size') != size ||
      ((l.t.peek('$base.lineHeight')! as num) / size - height).abs() > 0.01) {
    throw TokenFormatException(l.path, 'is not $base');
  }
}

/// `0 4px 0 {ring}`: a toast's solid edge in its kind's ring colour
/// (`AppColorTokens.toast<Kind>Ring`), so only its depth is a token.
void _ringEdge(_Leaf l) {
  final m = l.match(r'0 (\d+)px 0 \{ring\}');
  l.add(
    doubleLiteral(num.parse(m[1]!)),
    name: '${l.member}Depth',
    doc:
        'The solid edge\'s depth under the toast, in its kind\'s ring colour '
        '(`AppColorTokens.toast<Kind>Ring`).',
  );
}

/// A number as the design writes it, with a thousands comma (`1,600`).
num _designNumber(String text) => num.parse(text.replaceAll(',', ''));

/// `motion.rivalReact.segments.<name>`: `ui_rival_react`'s marker, read from
/// `FxSpec` (checked against the contract here).
void _rivalSegment(_Leaf l) {
  final value = l.t.peek(l.path);
  final contract = lottieContractOf('ui_rival_react');
  final marker = contract?.markers.where((m) => m.name == l.key).firstOrNull;
  if (value is! List<Object?> ||
      marker == null ||
      value.length != 2 ||
      value[0] != marker.start ||
      value[1] != marker.end) {
    throw TokenFormatException(l.path, 'is not ui_rival_react\'s marker');
  }
  l.t.documented(
    l.path,
    reason: 'ui_rival_react\'s marker, read from FxSpec (checked)',
  );
}

/// Strict parsers for the prose values whose numbers the app needs.
final Map<String, void Function(_Leaf)> _specials = {
  for (final segment in const ['idle', 'family', 'win', 'lose'])
    'motion.rivalReact.segments.$segment': _rivalSegment,
  'motion.rivalReact.sound': (l) {
    final m = l.match(r'(\w+) with (\w+)');
    final events = l.t.peek('sound.events')! as Map<String, Object?>;
    if (!events.values.contains(m[1]) ||
        lottieContractOf(
          'ui_rival_react',
        )!.markers.every((x) => x.name != m[2])) {
      throw TokenFormatException(l.path, 'unknown sound or segment');
    }
    l.t.documented(
      l.path,
      reason: 'the race\'s rival_complete cue plays with `family` (lane R)',
    );
  },
  'motion.museumIdle.canvas': (l) {
    final canvas = l.t.number(l.path, symbol: l.symbol());
    final contract = lottieContractOf('ui_museum_idle')!;
    if (canvas != contract.width || canvas != contract.height) {
      throw TokenFormatException(l.path, 'is not ui_museum_idle\'s canvas');
    }
    l.c.add(l.member, doubleLiteral(canvas), doc: 'The square canvas, dp.');
  },
  'motion.firstLaunch.easing': (l) {
    final name = l.text;
    if (!l.t.has('motion.easing.$name')) {
      throw TokenFormatException(l.path, 'there is no motion.easing.$name');
    }
    l.add(
      'UiMotionTokens.curve${name[0].toUpperCase()}${name.substring(1)}',
      name: 'curve',
      type: 'Cubic',
      doc: 'The first launch\'s fade (`motion.easing.$name`).',
    );
  },
  'motion.spinner.reducedMotion': (l) {
    final m = l.match(
      r'frame 0, opacity 1 → ([\d.]+) → 1 over ([\d,]+) ms (\w+), looping '
      r'\(12\.5, 7\.5\)',
    );
    if (!l.t.has('motion.easing.${m[3]}')) {
      throw TokenFormatException(l.path, 'there is no motion.easing.${m[3]}');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'reducedMotionMinOpacity',
        doc:
            'Under reduce motion `ui_spinner` rests on frame 0 and pulses '
            'its opacity 1 → this → 1 …',
      )
      ..add(
        '${_designNumber(m[2]!)}',
        name: 'reducedMotionPulseMs',
        doc: '… over this, looping, `${m[3]}` (12.5, 7.5).',
      );
  },
  'motion.purchaseItem.sparkles': (l) {
    final m = l.match(r'(\w+) (fx_sparkle) around the card or the Buy button');
    final count = _numberWords[m[1]!];
    if (count == null || lottieContractOf(m[2]!) == null) {
      throw TokenFormatException(l.path, 'unexpected wording');
    }
    l.add(
      '$count',
      name: 'sparkleCount',
      doc: 'This many `fx_sparkle` around the card or the Buy button.',
    );
  },
  'motion.purchaseItem.balance': (l) {
    final m = l.match(r'the header coins count down over (\d+) ms');
    l.add(
      m[1]!,
      name: 'balanceCountDownMs',
      doc: 'The header balance counts down over this.',
    );
  },
  'motion.purchaseItem.jingle': (l) {
    final text = l.t.documentedExact(
      l.path,
      'jingle_reward @0',
      reason: 'Jingle.reward at 0 ms (the Shop)',
    );
    if (l.t.peek('sound.events.reward') != text.split(' ').first) {
      throw TokenFormatException(l.path, 'is not sound.events.reward');
    }
  },
  'motion.relitHome.rule': (l) {
    final m = l.match(
      r'the Daily tile badge glows \(color\.(\w+) ring\) on the first Home '
      r'visit after a relight, in that session or a later one, ([\d,]+) ms '
      r'then a (\d+) ms fade; never twice',
    );
    if (!l.t.has('color.${m[1]}')) {
      throw TokenFormatException(l.path, 'there is no color.${m[1]}');
    }
    l
      ..add(
        '${_designNumber(m[2]!)}',
        name: 'glowMs',
        doc:
            'The Daily tile badge glows (`AppColorTokens.${m[1]}` ring) on '
            'the first Home visit after a relight, in that session or a later '
            'one, never twice (m7-4 4.10) …',
      )
      ..add(m[3]!, name: 'fadeMs', doc: '… then fades over this.');
  },
  'motion.relitTwinkle.glyph': (l) {
    final m = l.match('([a-z0-9_]+), (\\d+) dp, $_color, glow (.+)');
    l
      ..add(stringLiteral(m[1]!), name: 'glyph', doc: 'The `${m[1]}` glyph.')
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'glyphSize')
      ..add(colorLiteral(parseCssColor(m[3]!)), name: 'glyphColor')
      ..add(
        shadowListLiteral(parseBoxShadowList(m[4]!)),
        name: 'glyphGlow',
        type: 'List<NestyShadow>',
      );
  },
  'motion.relitTwinkle.place': (l) {
    final m = l.match(
      r'the flame disc’s top-right corner, its box (\d+) dp outside the disc '
      r'\(right −(\d+), top −(\d+)\)',
    );
    if (m[1] != m[2] || m[1] != m[3]) {
      throw TokenFormatException(l.path, 'the offsets disagree');
    }
    l.add(
      doubleLiteral(-num.parse(m[1]!)),
      name: 'placeInset',
      doc:
          'The twinkle\'s box sits at the flame disc\'s top-right corner, '
          'right and top this far (negative: outside the disc).',
    );
  },
  'motion.chest.collect.pillRing.from': (l) {
    final m = l.match(r'first coin lands \((\d+) ms\)');
    if (l.t.peek('motion.chest.collect.coinFlightMs') != int.parse(m[1]!)) {
      throw TokenFormatException(l.path, 'is not collect.coinFlightMs');
    }
    l.add(
      m[1]!,
      name: 'pillRingFromMs',
      doc: 'The ring shows as the first coin lands.',
    );
  },
  'motion.chest.collect.pillRing.until': (l) {
    final m = l.match(r'(\d+) ms after the last coin \(([\d,]+) ms\)');
    final c = 'motion.chest.collect';
    final last =
        (l.t.peek('$c.coinFlightMs')! as int) +
        ((l.t.peek('$c.coins')! as int) - 1) *
            (l.t.peek('$c.coinStaggerMs')! as int);
    if (l.t.peek('$c.pillRing.outMs') != int.parse(m[1]!) ||
        _designNumber(m[2]!) != last) {
      throw TokenFormatException(l.path, 'is not outMs after the last coin');
    }
    l.add(
      '$last',
      name: 'pillRingLastCoinMs',
      doc: 'The last coin lands here; the ring fades [pillRingOutMs] after.',
    );
  },
  'motion.chest.collect.gainTag.pop': (l) {
    if (l.text != 'motion.tagPop' || !l.t.has('motion.tagPop.duration')) {
      throw TokenFormatException(l.path, 'expected motion.tagPop');
    }
    l.t.documented(l.path, reason: 'the pop is MotionTokens.tagPop*');
  },
  'motion.chest.collect.trail.spacing': (l) {
    final m = l.match(r'behind the sprite at path t ((?:−\s?[\d.]+(?:, )?)+)');
    final values = [
      for (final v in RegExp(r'−\s?([\d.]+)').allMatches(m[1]!))
        num.parse(v[1]!),
    ];
    if (values.length != l.t.peek('motion.chest.collect.trail.coinDots')) {
      throw TokenFormatException(l.path, 'one offset per coin dot');
    }
    l.add(
      '[${values.map(doubleLiteral).join(', ')}]',
      name: 'trailSpacing',
      type: 'List<double>',
      doc: 'Each trail dot sits behind the sprite at path t − this.',
    );
  },
  'motion.chest.collect.trail.opacity': (l) {
    final m = l.match(r'([\d.]+) near the sprite to ([\d.]+) at the tail');
    l
      ..add(doubleLiteral(num.parse(m[1]!)), name: 'trailOpacityHead')
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'trailOpacityTail');
  },
  'textLink.pressedToken': (l) {
    final m = l.match(r'color\.(\w+) \((#[0-9A-Fa-f]{6})\)');
    if (l.t.peek('color.${m[1]}') != m[2] ||
        l.t.peek('textLink.pressed') != m[2]) {
      throw TokenFormatException(l.path, 'is not textLink.pressed');
    }
    l.t.documented(
      l.path,
      reason: 'TextLinkTokens.pressed is AppColorTokens.${m[1]} (checked)',
    );
  },
  // Tokens v4 (m7-4).
  'layout.tutorial.scrim': (l) {
    final m = l.match(
      '$_color over the whole screen, HUD and booster bar included, except '
      'the holes',
    );
    l.add(
      colorLiteral(parseCssColor(m[1]!)),
      doc:
          'The tutorial scrim, over the HUD and the booster bar too, with a '
          'hole that keeps Pause lit (m7-4 8.1).',
    );
  },
  'layout.tutorial.tooltip.top': (l) {
    final m = l.match(r'hud\.top \((\d+); (\d+) on 16:9\)');
    if (l.t.peek('layout.hud.top') != num.parse(m[1]!)) {
      throw TokenFormatException(l.path, 'is not layout.hud.top');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        doc: 'The tip sits in the HUD row (`HudTokens.top`).',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: '${l.member}Short',
        doc: 'On the 16:9 screen.',
      );
  },
  'layout.settingsRows.blockedActions': (l) {
    final m = l.match(
      r'Open phone settings \(secondary chip\) and Turn off \(textLink\), '
      r'(\d+) dp apart, wrapping under each other when narrow; Turn off sets '
      r'the reminder to Off \(10\.2h\)',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'blockedActionsGap',
      doc:
          'The blocked reminder row\'s two actions, "Open phone settings" '
          '(a secondary chip) and "Turn off" (a text link), this far apart; '
          'they wrap under each other when narrow (10.2f, Q158).',
    );
  },
  'layout.settingsRows.divider': (l) {
    final m = l.match(r'(\d+(?:\.\d+)?)px color\.([a-zA-Z]+)');
    final color = l.t.peek('color.${m[2]}');
    if (color is! String) {
      throw TokenFormatException(l.path, 'there is no color.${m[2]}');
    }
    l.add(
      strokeLiteral((width: double.parse(m[1]!), color: parseCssColor(color))),
      doc: 'The rows\' divider (`AppColorTokens.${m[2]}`).',
    );
  },
  'layout.noCoins.itemChip.price': (l) {
    final m = l.match(
      'gradient\\.(\\w+) pill, (\\d+) tall, $_font with the (\\d+) dp coin: '
      'the number alone .+',
    );
    l
      ..add(gradientReference(l.t, m[1]!, l.path), name: 'itemChipPriceFill')
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'itemChipPriceHeight',
        doc:
            'The price pill shows the number alone; the coin says the rest '
            'and screen readers hear "coins" (m7-4 10.1).',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[3]!), l.path),
        name: 'itemChipPriceText',
      )
      ..add(doubleLiteral(num.parse(m[4]!)), name: 'itemChipPriceCoin');
  },
  'layout.museumDetail.spotlight.panel': (l) {
    final m = l.match(
      r'the (\d+)-tall art panel, radius (\d+), overflow hidden',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'spotlightPanelHeight',
        doc: 'The art panel the cone is clipped to.',
      )
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'spotlightPanelRadius');
  },
  'layout.museumDetail.spotlight.cone.clipPath': (l) {
    final m = l.match(r'polygon\((\d+)% 0,(\d+)% 0,100% 100%,0 100%\)');
    l
      ..add(
        doubleLiteral(int.parse(m[1]!) / 100),
        name: 'spotlightConeTopLeft',
        doc: 'The cone\'s top edge runs from this fraction of its width …',
      )
      ..add(
        doubleLiteral(int.parse(m[2]!) / 100),
        name: 'spotlightConeTopRight',
        doc: '… to this one; its bottom edge is the full width.',
      );
  },
  'layout.museumDetail.spotlight.cone.fill': (l) {
    final m = l.match('linear 180°: $_color → $_color');
    l.add(
      'LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, '
      'colors: [${colorLiteral(parseCssColor(m[1]!))}, '
      '${colorLiteral(parseCssColor(m[2]!))}])',
    );
  },
  'layout.languageSheet.radio': (l) {
    final m = l.match(
      '(\\d+), ring ${_nr}px $_color; current: $_color fill with a white check',
    );
    l
      ..add(doubleLiteral(num.parse(m[1]!)), name: 'radioSize')
      ..add(strokeLiteral(_strokeOf(l, m[2]!, m[3]!)), name: 'radioRing')
      ..add(
        colorLiteral(parseCssColor(m[4]!)),
        name: 'radioCurrentFill',
        doc: 'The current language\'s radio, with a white check.',
      );
  },
  'layout.languageSheet.maxHeight': (l) {
    final m = l.match(r'screen − safeTop − (\d+)');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'maxHeightInset',
      doc: 'The sheet is at most the screen − the safe top − this.',
    );
  },
  'layout.languageSheet.scroll': (l) {
    final m = l.match(
      'the rows scroll under the pinned title row; a (\\d+) dp fade '
      '\\($_color\\) at the bottom edge while more rows are below',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'scrollFadeHeight',
        doc: 'The fade over the last rows while more are below.',
      )
      ..add(colorLiteral(parseCssColor(m[2]!)), name: 'scrollFadeColor');
  },
  'toast.app.top': (l) {
    final m = l.match(r'safeTop \+ (\d+): .+');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'appTopBelowSafeTop',
      doc:
          'The app toast\'s top is the safe top + this, just under the '
          'status bar (m7-4 1.5).',
    );
  },
  'toast.app.edge': _ringEdge,
  'toast.inPlace.edge': _ringEdge,
  'toast.app.iconDisc.badge': (l) {
    final m = l.match(r'the badge art at (\d+), no disc');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'appBadgeArtSize',
      doc: 'A badge toast shows the badge art at this size, with no disc.',
    );
  },
  'screenHeader.trailing': (l) {
    final m = l.match(r'the coin pill \((\d+) tall\) or nothing, at the right');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'trailingCoinPillHeight',
      doc: 'The header\'s trailing coin pill (or nothing).',
    );
  },
  'screenHeader.tabScreen': (l) {
    final m = l.match(
      r'the Museum tab has no button: the title sits at left (\d+)',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'tabScreenTitleLeft',
      doc: 'A tab screen (the Museum) has no button; its title starts here.',
    );
  },
  'layout.rivalStrip.dots.many': (l) {
    final m = l.match(
      r'(\d+) or more families: (\d+) dp, (\d+) dp gap \(as built\)',
    );
    l
      ..add(
        m[1]!,
        name: 'dotsManyFromFamilies',
        doc: 'From this many families the dots shrink (as built) …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'dotsManySize',
        doc: '… to this, dp …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'dotsManyGap',
        doc: '… this far apart.',
      );
  },
  'layout.rivalStrip.narrow.measuredOn': (l) {
    l.t.documentedExact(
      l.path,
      'screen width (as built)',
      reason: 'the strip\'s narrow test reads the screen width (lane R)',
    );
  },
  'layout.museum.cabinet.collectedIdle': (l) {
    final text = l.t.documentedExact(
      l.path,
      'ui_museum_idle (J.2), random start frame per niche',
      reason: 'FxId.uiMuseumIdle in each collected niche (m7-4 J.2)',
    );
    if (lottieContractOf(text.split(' ').first) == null) {
      throw TokenFormatException(l.path, 'no Lottie contract ui_museum_idle');
    }
  },
  'layout.museum.nextCard.name': (l) {
    final m = l.match(
      r'fontSize\.(\w+) \((Fredoka|Nunito) (\d{3}) (\d+)/([\d.]+)\), up to '
      r'(two) balanced lines, as 6\.1 draws it',
    );
    _checkFontSize(
      l,
      m[1]!,
      int.parse(m[3]!),
      num.parse(m[4]!),
      num.parse(m[5]!),
    );
    l.add(
      '2',
      name: 'nextCardNameMaxLines',
      doc:
          'The next card\'s name (`AppTextStyleTokens.${m[1]}`) takes up to '
          'two balanced lines.',
    );
  },
  'layout.museum.title': (l) {
    final m = l.match(
      r'fontSize\.(\w+), left (\d+), top (\d+) \(the tab screen header\)',
    );
    if (!l.t.has('fontSize.${m[1]}')) {
      throw TokenFormatException(l.path, 'there is no fontSize.${m[1]}');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'titleLeft',
        doc: 'The tab screen title (`AppTextStyleTokens.${m[1]}`) …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'titleTop',
        doc: '… at this top.',
      );
  },
  'layout.chapters.foldedRow.name': (l) {
    final m = l.match(
      '$_font, one line; scales down to $_nr \\(([\\d.]+)\\) before it ellipsizes',
    );
    final font = _fontOf(l, m[1]!);
    if ((font.size * double.parse(m[2]!) - double.parse(m[3]!)).abs() > 0.01) {
      throw TokenFormatException(l.path, 'the scaled size does not match');
    }
    l
      ..add(textStyleLiteral(l.t, font, l.path))
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'foldedRowNameMinScale',
        doc: 'One line: it scales down to this before it ellipsizes.',
      );
  },
  'layout.chapters.openScroll': (l) {
    final m = l.match(
      r'the current chapter card with at most (\w+) finished rows above it: '
      r'offset = max\(0, currentCardTop − listTop − min\((\d+), finished\) '
      r'× (\d+)\)',
    );
    if (_numberWords[m[1]!] != int.parse(m[2]!)) {
      throw TokenFormatException(l.path, 'the row count disagrees');
    }
    l
      ..add(
        m[2]!,
        name: 'openScrollFinishedRows',
        doc:
            'On open, the list scrolls so at most this many finished rows '
            'show above the current chapter card: offset = max(0, '
            'currentCardTop − listTop − min(this, finished) × '
            '[openScrollRowPitch]).',
      )
      ..add(doubleLiteral(num.parse(m[3]!)), name: 'openScrollRowPitch');
  },
  'layout.chestCard.lottie.layout': (l) {
    l.t.documentedExact(
      l.path,
      'overlay: the 240×240 canvas takes no layout space and may draw past '
      'the card top, like the frame rays',
      reason: 'ChestRewardSequence\'s overflowing slot (lane O, F-CH1)',
    );
  },
  'layout.chestCard.artFit.lottie': (l) {
    final m = l.match(
      r'ui_chest draws the same box at (\d+)×(\d+) \(the chest (\d+) dp '
      r'wide\): play it at ([\d.]+) so it matches the frames',
    );
    final scale = l.t.peek('layout.chestCard.lottie.scale');
    final art = l.t.peek('layout.chestCard.artBox');
    if (scale != num.parse(m[4]!) ||
        art is! List<Object?> ||
        art[0] != (num.parse(m[1]!) * num.parse(m[4]!)).round()) {
      throw TokenFormatException(
        l.path,
        'is not artBox / lottie.scale (layout.chestCard)',
      );
    }
    l.t.documented(
      l.path,
      reason:
          'why ChestCardTokens.lottieScale is the art box over ui_chest\'s '
          '(checked)',
    );
  },
  'layout.records.statsGrid.cell.value': (l) {
    final m = l.match('$_font, tabular, one line');
    final font = _fontOf(l, m[1]!);
    l.add(
      textStyleLiteral(l.t, (
        family: font.family,
        weight: font.weight,
        size: font.size,
        height: font.height,
        color: font.color,
        tabular: true,
        tail: null,
      ), l.path),
      doc: 'A stat\'s value, tabular figures, one line.',
    );
  },
  'layout.records.statsGrid.cell.tints.familiesCompleted': (l) {
    final list = l.t.list(l.path, symbol: l.symbol());
    final mark = RegExp(r'^doll mark (\d+)×(\d+)$').firstMatch('${list.last}');
    if (list.length != 3 || mark == null) {
      throw TokenFormatException(
        l.path,
        'expected [face, glyph, doll mark WxH]',
      );
    }
    l.c
      ..add(
        l.member,
        '[${list.take(2).map((v) => colorLiteral(parseCssColor('$v'))).join(', ')}]',
        type: 'List<Color>',
        doc: 'The tile\'s face and the doll mark\'s colour (`$list`).',
      )
      ..add(
        '${l.member}MarkSize',
        sizeLiteral(num.parse(mark[1]!), num.parse(mark[2]!)),
        doc: 'The family counter\'s doll mark, not a glyph.',
      );
    l.t.list(l.path, symbol: '${l.c.name}.${l.member}MarkSize');
  },
  'layout.records.statsGrid.cell.tints.stars': (l) {
    final list = l.t.list(l.path, symbol: l.symbol());
    final art = RegExp(r'^star art (\d+)$').firstMatch('${list.last}');
    if (list.length != 2 || art == null) {
      throw TokenFormatException(l.path, 'expected [face, star art N]');
    }
    l.c
      ..add(
        l.member,
        '[${colorLiteral(parseCssColor('${list.first}'))}]',
        type: 'List<Color>',
        doc: 'The tile\'s face (`$list`); it shows the star art.',
      )
      ..add(
        '${l.member}ArtSize',
        doubleLiteral(num.parse(art[1]!)),
        doc: 'The star art in the tile.',
      );
    l.t.list(l.path, symbol: '${l.c.name}.${l.member}ArtSize');
  },
  'layout.hintMiddle.clampTop': (l) {
    final m = l.match(
      r'the arrow’s highest bob point stays ≥ (\d+) \((\d+) dp under the '
      r'level pill\); move it down over the doll’s head if needed',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      doc:
          'The hint arrow\'s highest bob point stays at or below this y, '
          '${m[2]} dp under the level pill; it moves down over the doll\'s '
          'head if needed (m7-4 5.4).',
    );
  },
  'layout.chestCard.card.height': (l) {
    final m = l.match(
      r'from content: (\d+) closed, (\d+) open \(milestone\); (\d+) open '
      r'with Double it \(day 7\)',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'cardHeightClosed',
        doc:
            'The card\'s height from its content, for the layout tests: '
            'closed …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'cardHeightOpen',
        doc: '… open …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'cardHeightOpenDoubleIt',
        doc: '… and the day-7 chest open with Double it.',
      );
  },
  'layout.rivalStrip.dots.filled': (l) {
    final m = l.match('$_color \\+ ${_nr}px $_color ring');
    l
      ..add(colorLiteral(parseCssColor(m[1]!)), doc: 'A filled dot.')
      ..add(
        strokeLiteral(_strokeOf(l, m[2]!, m[3]!)),
        name: '${l.member}Ring',
        doc: 'Its ring.',
      );
  },
  'layout.rivalStrip.dots.empty': (l) {
    final m = l.match('$_color sunk');
    if (!l.t.has('shadow.sunk')) {
      throw TokenFormatException(l.path, 'there is no shadow.sunk');
    }
    l.add(
      colorLiteral(parseCssColor(m[1]!)),
      doc: 'An empty dot, drawn sunk (`AppShadowTokens.sunk`).',
    );
  },
  'layout.rivalStrip.state': (l) {
    final m = l.match(
      '$_font; thinking = (\\w+) (\\d+) px dots, $_nr s, (\\d+) ms stagger',
    );
    final dots = _numberWords[m[2]!];
    if (dots == null) throw TokenFormatException(l.path, 'dot count "${m[2]}"');
    l
      ..add(textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path))
      ..add('$dots', name: '${l.member}ThinkingDots', doc: 'Thinking… dots.')
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: '${l.member}ThinkingDotSize',
        doc: 'Each dot, dp.',
      )
      ..add(
        '${(double.parse(m[4]!) * 1000).round()}',
        name: '${l.member}ThinkingPeriodMs',
        doc: 'One cycle of the dots.',
      )
      ..add(m[5]!, name: '${l.member}ThinkingStaggerMs', doc: 'Between dots.');
  },
  'layout.winStars.newBestChip.position': (l) {
    final m = l.match('centered on the moves chip, top [−-](\\d+)');
    l.add(
      doubleLiteral(-num.parse(m[1]!)),
      name: 'newBestChipTopOffset',
      doc: 'Centred on the moves chip, its top this far from the chip\'s.',
    );
  },
  'layout.chestCard.lottie.anchor': (l) {
    final text = l.t.documented(
      l.path,
      reason:
          'ui_chest\'s anchor, FxSpec.anchor (checked), on the art box\'s '
          'bottom centre (m7-4 6.4)',
    );
    final m = RegExp(
      r'^chest base \((\d+), (\d+)\) → the art box bottom centre$',
    ).firstMatch(text);
    final contract = lottieContractOf('ui_chest');
    if (m == null ||
        contract == null ||
        contract.anchor !=
            LottiePoint(double.parse(m[1]!), double.parse(m[2]!))) {
      throw TokenFormatException(l.path, 'is not ui_chest\'s anchor');
    }
  },
  'layout.chapters.current.ring': (l) {
    final m = l.match('(\\d+)px chapter accentTop');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'currentRingWidth',
      doc: 'The open chapter\'s ring, in its palette\'s `accentTop`.',
    );
  },
  'layout.chapters.current.header.crop': (l) {
    final m = l.match('theme thumb scaled to (\\d+) wide');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'currentHeaderCropWidth',
      doc: 'The header shows the theme\'s thumb crop scaled to this width.',
    );
  },
  'layout.chapters.current.currentTile': (l) {
    final m = l.match(
      'gradient\\.(\\w+), (\\d+)px edge $_color, (\\d+)px ring $_color',
    );
    l
      ..add(
        gradientReference(l.t, m[1]!, l.path),
        name: 'currentTileFill',
        doc: 'The current level\'s tile.',
      )
      ..add(strokeLiteral(_strokeOf(l, m[2]!, m[3]!)), name: 'currentTileEdge')
      ..add(strokeLiteral(_strokeOf(l, m[4]!, m[5]!)), name: 'currentTileRing');
  },
  'layout.chapters.current.tierEdge': (l) {
    final m = l.match('(\\d+)px inset, won or current only');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'currentTierEdgeWidth',
      doc: 'A hard or super hard tile\'s inset edge, on won or current tiles.',
    );
  },
  'layout.chapters.perfectChip': (l) {
    final m = l.match('inset ${_nr}px $_color \\+ ${_nr}px $_color ring');
    l
      ..add(
        strokeLiteral(_strokeOf(l, m[1]!, m[2]!)),
        name: 'perfectChipInset',
        doc: 'A 3-star chapter chip\'s inset line.',
      )
      ..add(strokeLiteral(_strokeOf(l, m[3]!, m[4]!)), name: 'perfectChipRing');
  },
  'layout.replayCard.targetRow': (l) {
    final m = l.match('dashed divider, empty star (\\d+), (.+)');
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'targetRowStarSize',
        doc: 'Under a dashed divider: an empty star, then the target.',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'targetRowText',
      );
  },
  'layout.replayCard.bottomLimit': (l) {
    final m = l.match('booster bar top (\\d+)');
    final top = l.t.peek('layout.boosterBar.top');
    if (top != num.parse(m[1]!)) {
      throw TokenFormatException(l.path, 'is not layout.boosterBar.top');
    }
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      doc: 'The card ends above the booster bar (`BoosterBarTokens.top`).',
    );
  },
  'layout.museum.cabinet.lockedLabel': (l) {
    final m = l.match('two lines, $_font: "([^"]+)" / "([^"]+)"');
    l.add(
      textStyleLiteral(l.t, _fontOf(l, m[1]!.trim()), l.path),
      doc: 'A locked figurine\'s two lines ("${m[2]}" / "${m[3]}").',
    );
  },
  'layout.rivalSelect.newChip': (l) {
    final m = l.match('gradient\\.(\\w+), (.+)');
    l
      ..add(
        gradientReference(l.t, m[1]!, l.path),
        name: 'newChipFill',
        doc: 'The "New" chip.',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'newChipText',
      );
  },
  'layout.hintMiddle.appliesWhen': (l) {
    final m = l.match(
      'ui_hint_arrow over slot cx (\\d+) on the top shelf with its top above '
      'y (\\d+)',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'slotCenterX',
        doc: 'The hint arrow over the top shelf\'s slot at this cx …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'arrowTopAboveY',
        doc: '… with its top above this y fades the family counter (3.1b).',
      );
  },
  'layout.generating.spinner': (l) {
    // m7-5 (item 10): the colours are ui_spinner.json's own (recoloured by
    // the design), so only the size is the game's.
    final m = l.match(
      '(ui_spinner) at (\\d+) dp: orange arc $_color \\((\\d+)°\\) on a '
      '$_color track \\(m7-5\\)',
    );
    if (lottieContractOf(m[1]!) == null) {
      throw TokenFormatException(l.path, 'no Lottie contract ${m[1]}');
    }
    l.add(
      doubleLiteral(num.parse(m[2]!)),
      name: 'spinnerSize',
      doc:
          '`ui_spinner`, dp: its own ${m[3]} arc (${m[4]}°) on a ${m[5]} '
          'track, baked into the file (m7-5).',
    );
  },
  'shop.detailPanel.tag': (l) {
    final m = l.match('$_color chip, (.+)');
    l
      ..add(
        colorLiteral(parseCssColor(m[1]!)),
        name: 'detailPanelTagFill',
        doc: 'The detail panel\'s tag chip.',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'detailPanelTagText',
      );
  },
  'chestModal.glow.rays': (l) {
    final rays = parseConicRays(l.text);
    l
      ..add(colorLiteral(rays.color), name: 'glowRayColor', doc: 'A lit ray.')
      ..add(
        doubleLiteral(rays.litDeg),
        name: 'glowRayLitDeg',
        doc: 'Each ray\'s width, degrees …',
      )
      ..add(
        doubleLiteral(rays.periodDeg),
        name: 'glowRayPeriodDeg',
        doc: '… of every this many (`${l.t.peek(l.path)}`).',
      );
  },
  'chestModal.glow.mask': (l) {
    final m = l.match('radial, solid to (\\d+) %, clear at (\\d+) %');
    l
      ..add(
        doubleLiteral(int.parse(m[1]!) / 100),
        name: 'glowMaskSolid',
        doc: 'The rays\' radial mask: solid to this fraction of the radius …',
      )
      ..add(
        doubleLiteral(int.parse(m[2]!) / 100),
        name: 'glowMaskClear',
        doc: '… and clear from this one.',
      );
  },
};
