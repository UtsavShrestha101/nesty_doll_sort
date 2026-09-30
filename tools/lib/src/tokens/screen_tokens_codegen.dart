// The generic per-screen emitter of tokens v3 (m7-3; phase 4 architecture
// §1.1): one const class per `layout.<screen>` section (and `shop`,
// `chestModal`, `settings`, `textLink`), a member per leaf named by its
// camelCased path. Each value becomes the Dart type its shape says:
//
//   number                        double (int for counts and `…Ms`)
//   `padding` list                EdgeInsets (CSS 1-, 2-, 3- or 4-value order)
//   2 numbers under a size key    Size;  `origin` Offset;  `points` List<Offset>
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
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// The per-screen sections, tokens.json path → generated class.
const screenTokenSections = {
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
  final short = path.endsWith('Short') || path == 'layout.short169';
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
    final member = [
      memberName(segments.first),
      for (final s in segments.skip(1))
        '${s[0].toUpperCase()}${s.substring(1)}',
    ].join();
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
};

/// Keys whose string is a glyph of the bundled font.
const _glyphKeys = {'glyph', 'undoBadge', 'icon'};

/// The prose tail each font value may carry after its style.
const _fontTails = {
  'layout.rivalStrip.tag.text': 'sentence case',
  'layout.museum.cabinet.namePlate': 'on a brass gradient',
  'layout.replayCard.reason': 'with the replay glyph',
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
  'textLink.minTapHeight':
      'superseded: text links keep a 48 dp hit box (lead note 3, the '
      'overflow harness); the look is the rest of TextLinkTokens',
};

/// Prose pinned word for word (the hand-written code follows it).
const _exactLeaves = {
  'layout.winStars.starsCanvas.lottie': ('ui_stars', 'FxId.uiStars (lane O)'),
  'layout.chestCard.lottie.name': ('ui_chest', 'FxId.uiChest (lane O)'),
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
  final special = _specials[l.path];
  if (special != null) return special(l);
  final reason = _documentedLeaves[l.path];
  if (reason != null) {
    t.documented(l.path, reason: reason);
    return;
  }
  final exact = _exactLeaves[l.path];
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
  } else if (l.key == 'origin' && numbers.length == 2) {
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
  if (value.startsWith('gradient.')) {
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
    if (font.tail != _fontTails[l.path]) {
      throw TokenFormatException(
        l.path,
        font.tail == null
            ? 'expected the tail "${_fontTails[l.path]}"'
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
/// bundled fonts (tokens.json `font`).
String textStyleLiteral(TokenReader t, FontSpec font, String path) {
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
  return 'TextStyle(${['fontFamily: ${stringLiteral(font.family)}', 'fontSize: ${doubleLiteral(font.size)}', 'fontWeight: FontWeight.w${font.weight}', if (font.color != null) 'color: ${colorLiteral(font.color!)}', if (font.tabular) 'fontFeatures: [FontFeature.tabularFigures()]'].join(', ')})';
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

/// Strict parsers for the prose values whose numbers the app needs.
final Map<String, void Function(_Leaf)> _specials = {
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
      reason: 'ui_chest\'s anchor, FxSpec.anchor (checked)',
    );
    final m = RegExp(r'^chest base \((\d+), (\d+)\)$').firstMatch(text);
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
  'layout.museum.cabinet.collectedIdle': (l) {
    final m = l.match('bob (\\d+) dp, $_nr–$_nr s');
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'cabinetCollectedIdleBob',
        doc: 'A collected figurine bobs this far, dp.',
      )
      ..add(
        '${(double.parse(m[2]!) * 1000).round()}',
        name: 'cabinetCollectedIdleMinPeriodMs',
        doc: 'Its period, varied between this and the max per figurine.',
      )
      ..add(
        '${(double.parse(m[3]!) * 1000).round()}',
        name: 'cabinetCollectedIdleMaxPeriodMs',
      );
  },
  'layout.records.statsGrid.cell': (l) {
    final m = l.match('radius (\\d+), icon (\\d+)');
    l
      ..add(doubleLiteral(num.parse(m[1]!)), name: 'statsGridCellRadius')
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'statsGridCellIcon');
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
    final m = l.match('(ui_spinner) at (\\d+) dp');
    if (lottieContractOf(m[1]!) == null) {
      throw TokenFormatException(l.path, 'no Lottie contract ${m[1]}');
    }
    l.add(
      doubleLiteral(num.parse(m[2]!)),
      name: 'spinnerSize',
      doc: '`ui_spinner`, dp.',
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
