// The board sections tokens v3 (m7-3) adds to render_tokens.gen.dart: the
// tall glass case, the board fit and its presets, the tower stack, the iced
// tower, the hint arc, the fallback doll and the chapter themes (phase 4
// architecture §1.1, §2). Prose that layout math follows is parsed with
// strict regexes, or pinned word for word, so a changed wording fails the
// build instead of silently leaving the hand-written math behind.
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Every v3 board class, in file order.
List<ConstClass> boardV3Classes(TokenReader t) => [
  _glassCaseTall(t),
  _boardFit(t),
  _boardPresets(t),
  _towerStack(t),
  _icedTower(t),
  _hintArc(t),
  _fallbackDoll(t),
  _chapterThemes(t),
];

const _num = r'(\d+(?:\.\d+)?)';

/// `num` → `double`, for `peek`ed values.
double _peekNumber(TokenReader t, String path) {
  final value = t.peek(path);
  if (value is! num) throw TokenFormatException(path, 'expected a number');
  return value.toDouble();
}

List<double> _peekNumbers(TokenReader t, String path) {
  final value = t.peek(path);
  if (value is! List<Object?> || !value.every((v) => v is num)) {
    throw TokenFormatException(path, 'expected numbers');
  }
  return [for (final v in value) (v! as num).toDouble()];
}

RegExpMatch _match(TokenReader t, String path, String symbol, String regex) {
  final text = t.string(path, symbol: symbol);
  final m = RegExp('^$regex\$').firstMatch(text);
  if (m == null) throw TokenFormatException(path, 'unexpected wording "$text"');
  return m;
}

bool _near(double a, double b, [double tolerance = 0.01]) =>
    (a - b).abs() <= tolerance;

ConstClass _glassCaseTall(TokenReader t) {
  const name = 'GlassCaseTallTokens';
  const p = 'layout.board.glassCaseTall';
  final c = ConstClass(
    name,
    'The tall glass case of a sealed size-5 or size-6 doll (tokens v3 `$p`, '
    'm7-1): its geometry as fractions of the doll height h, so it grows '
    'with the doll. `fx_glass_unlock_tall` unlocks it.',
  );
  final box = t.numbers('$p.viewBox', symbol: '$name.viewBox', length: 2);
  c.add(
    'viewBox',
    sizeLiteral(box[0], box[1]),
    doc: 'The art\'s viewBox (`board/glass-case-tall-{0,1,2}.svg`).',
  );
  final size = _match(
    t,
    '$p.size',
    '$name.widthPerHeight',
    '$_num'
        r'h × '
        '$_num'
        r'h \((\d+)×(\d+) for h (\d+)\)',
  );
  t.string('$p.size', symbol: '$name.heightPerHeight');
  final perW = double.parse(size[1]!);
  final perH = double.parse(size[2]!);
  final h = double.parse(size[5]!);
  if ((perW * h).round() != int.parse(size[3]!) ||
      (perH * h).round() != int.parse(size[4]!)) {
    throw TokenFormatException('$p.size', 'the example size does not match');
  }
  c.add(
    'widthPerHeight',
    doubleLiteral(perW),
    doc: 'Case width ÷ h (`${t.peek('$p.size')}`).',
  );
  c.add('heightPerHeight', doubleLiteral(perH), doc: 'Case height ÷ h.');
  final bottom = _match(
    t,
    '$p.bottom',
    '$name.bottomPerHeight',
    r'stand surface \+ (\d*\.\d+)h',
  );
  c.add(
    'bottomPerHeight',
    doubleLiteral(double.parse(bottom[1]!)),
    doc: 'The case bottom sits this × h below the stand surface.',
  );
  t.string('$p.dollBase', symbol: '$name.dollBaseOnSurface');
  if (t.peek('$p.dollBase') != 'the stand surface (not raised)') {
    throw TokenFormatException('$p.dollBase', 'unexpected wording');
  }
  c.add(
    'dollBaseOnSurface',
    'true',
    doc:
        'The sealed doll stands on the stand surface (no plinth lift), so '
        'the unlock needs no settle.',
  );
  final lock = _match(
    t,
    '$p.lockSymbol',
    '$name.lockSymbolSize',
    r'(\d+) dp, ink, centred at caseTop \+ (\d*\.\d+) × caseHeight',
  );
  t.string('$p.lockSymbol', symbol: '$name.lockCenter');
  c.add(
    'lockSymbolSize',
    doubleLiteral(num.parse(lock[1]!)),
    doc: 'The padlock\'s symbol, in the unlock colour\'s ink, dp at q = 1.',
  );
  c.add(
    'lockCenter',
    doubleLiteral(double.parse(lock[2]!)),
    doc: 'The symbol\'s centre: caseTop + this × caseHeight.',
  );
  final use = _match(
    t,
    '$p.use',
    '$name.minDollHeight',
    r'a case whose doll is size (\d) or (\d) \(h > '
        '$_num'
        r'\); smaller dolls keep glassCase',
  );
  c.add(
    'minDollHeight',
    doubleLiteral(double.parse(use[3]!)),
    doc:
        'A case whose doll is taller than this (dp at 390×844, sizes '
        '${use[1]} and ${use[2]}) is the tall one; smaller dolls keep '
        '`BoardTokens.glassCaseSize`.',
  );
  final art = t.documentedExact(
    '$p.art',
    'board/glass-case-tall-{0,1,2}.svg',
    reason: 'the BoardSprite.glassCaseTall0..2 art (a test checks it ships)',
  );
  final lottie = t.documentedExact(
    '$p.lottie',
    'fx_glass_unlock_tall with doll_size and case_size set to h / 150',
    reason: 'FxSpec.scaleNulls and FxLayout (lane B)',
  );
  if (!art.startsWith('board/') ||
      lottieContractOf('fx_glass_unlock_tall') == null ||
      !lottie.startsWith('fx_glass_unlock_tall ')) {
    throw TokenFormatException(p, 'the art or the Lottie is unknown');
  }
  return c;
}

ConstClass _boardFit(TokenReader t) {
  const name = 'BoardFitTokens';
  const p = 'layout.boardFit';
  final c = ConstClass(
    name,
    'The board fit (tokens v3 `$p`), which replaces the h·2/3 clamp: one '
    'factor k per level, `min(1, min(vertical, hud, horizontal) / '
    'heightOf(maxSize))`, applied to every doll (the formulas are hand-'
    'written in BoardLayout and pinned to `BoardPresetTokens` by '
    'board_fit_test).\n\n'
    '${t.documented('$p.\$description', reason: 'prose, in the class doc')}',
  );
  void n(String key, String doc) => c.add(
    key,
    doubleLiteral(t.number('$p.$key', symbol: '$name.$key')),
    doc: doc,
  );
  n(
    'drawnHeight',
    'The drawn doll above its base ÷ its height (742/768 of the art box).',
  );
  n('bodyWidth', 'The widest painted part ÷ the doll height (411 of 512).');
  n('hudClearY', 'The top shelf\'s dolls stay below this y (dp at 390×844).');
  n('headroom', 'Gap under the plank above, dp.');
  n('neighbourGap', 'Gap between neighbouring dolls, dp.');
  final stand = _match(
    t,
    '$p.standWidth',
    '$name.standMaxWidth',
    r'min\((\d+), pitch − '
        '$_num'
        r'\)',
  );
  t.string('$p.standWidth', symbol: '$name.standPitchInset');
  final standWidth = _peekNumbers(t, 'layout.board.stand')[0];
  if (double.parse(stand[1]!) != standWidth) {
    throw TokenFormatException('$p.standWidth', 'max is not the stand width');
  }
  c.add(
    'standMaxWidth',
    doubleLiteral(num.parse(stand[1]!)),
    doc: 'Stand width = `min(this, pitch − standPitchInset)`.',
  );
  c.add('standPitchInset', doubleLiteral(double.parse(stand[2]!)));
  t
    ..documentedExact(
      '$p.limits.vertical',
      '(pitchY − plankHeight − standSurfaceOffset − headroom) / drawnHeight, '
          'pitchY = the smallest step between plank tops',
      reason: 'BoardLayout\'s fit (lane B, board_fit_test)',
    )
    ..documentedExact(
      '$p.limits.horizontal',
      '(min(standWidth, pitch) − neighbourGap) / bodyWidth, for the row with '
          'the smallest pitch',
      reason: 'BoardLayout\'s fit (lane B, board_fit_test)',
    )
    ..documentedExact(
      '$p.rule',
      'k = min(1, min(vertical, hud, horizontal) / heightOf(maxSize)), '
          'heightOf from dollHeightBySize; every doll is heightOf(size) × k',
      reason: 'BoardLayout\'s fit (lane B, board_fit_test)',
    )
    ..documentedExact(
      '$p.pickLift',
      'the picked doll keeps its 14 dp lift and may pass in front of the '
          'plank above; draw it above the planks until it lands',
      reason: 'the picked doll\'s z-order (lane B)',
    );
  final hud = t.documentedExact(
    '$p.limits.hud',
    '(planksY[0] − standSurfaceOffset − hudClearY) / drawnHeight; hudClearY '
        '= the family counter\'s bottom (142) + 8',
    reason: 'BoardLayout\'s fit (lane B, board_fit_test)',
  );
  final counterBottom =
      _peekNumber(t, 'layout.hud.familyCounter.top') +
      _peekNumber(t, 'layout.hud.familyCounter.height');
  if (!hud.contains('(${counterBottom.round()}) + 8') ||
      counterBottom + 8 != _peekNumber(t, '$p.hudClearY')) {
    throw TokenFormatException(
      '$p.hudClearY',
      'is not the family counter\'s bottom ($counterBottom) + 8',
    );
  }
  return c;
}

ConstClass _boardPresets(TokenReader t) {
  const name = 'BoardPresetTokens';
  const p = 'layout.boardPresets';
  final c = ConstClass(
    name,
    'The NestyBoard presets (tokens v3 `$p`), with the design\'s own board '
    'fit results for 4 slots per row. The preset follows the shelf count '
    'and maxSize (phase 4 architecture §2.1).\n\n'
    '${t.documented('$p.\$description', reason: 'prose, in the class doc')}',
  );
  String limits(String base, String symbol) {
    final v = [
      for (final key in const ['vertical', 'hud', 'horizontal'])
        t.number('$base.limits.$key', symbol: symbol),
    ];
    return 'BoardFitLimits(vertical: ${doubleLiteral(v[0])}, '
        'hud: ${doubleLiteral(v[1])}, horizontal: ${doubleLiteral(v[2])})';
  }

  String heights(String base, String symbol) {
    final entries = <String>[];
    for (final key in t.keys('$base.dollHeights')) {
      final maxSize = int.tryParse(key);
      final values = t.numbers('$base.dollHeights.$key', symbol: symbol);
      if (maxSize == null || values.length != maxSize) {
        throw TokenFormatException(
          '$base.dollHeights.$key',
          'needs one height per size up to $key',
        );
      }
      entries.add('$maxSize: [${values.map(doubleLiteral).join(', ')}]');
    }
    return '{${entries.join(', ')}}';
  }

  void docs(String base) {
    t
      ..documented('$base.use', reason: 'prose: when the preset applies (§2.1)')
      ..documented('$base.scenes', reason: 'NestyBoard prototype scene names');
  }

  const shelfKeys = {
    'twoShelves': '2shelves',
    'threeShelves': '3shelves',
    'threeShelvesTall': '3shelvesTall',
    'fourShelves': '4shelves',
  };
  for (final key in t.keys(p)) {
    if (key.startsWith(r'$')) continue;
    final base = '$p.$key';
    final symbol = '$name.$key';
    if (key == 'oneShelf') {
      _oneShelf(t, base);
      continue;
    }
    if (key == 'rowOfFive') {
      c.add(key, _rowOfFive(t, base, symbol, limits, heights), doc: '`$base`.');
      docs(base);
      continue;
    }
    final plankKey = shelfKeys[key];
    if (plankKey == null) {
      throw TokenFormatException(base, 'unknown board preset');
    }
    final planks = t.numbers('$base.planksY', symbol: symbol);
    if ([for (final v in planks) v.toDouble()].join(',') !=
        _peekNumbers(t, 'layout.board.planksY.$plankKey').join(',')) {
      throw TokenFormatException(
        '$base.planksY',
        'differs from layout.board.planksY.$plankKey',
      );
    }
    final args = [
      'plankTops: [${planks.map(doubleLiteral).join(', ')}]',
      'slotMaxDollHeight: '
          '${doubleLiteral(t.number('$base.slotMaxDollHeight', symbol: symbol))}',
      'maxSlotsPerRow: ${t.integer('$base.maxSlotsPerRow', symbol: symbol)}',
      'limits: ${limits(base, symbol)}',
      'dollHeights: ${heights(base, symbol)}',
      if (t.has('$base.optional') &&
          t.boolean('$base.optional', symbol: symbol))
        'optional: true',
      if (t.has('$base.iceOverlay')) _iceOverlay(t, base, symbol),
    ];
    c.add(key, 'BoardPresetToken(${args.join(', ')},)', doc: '`$base`.');
    docs(base);
    if (t.has('$base.pieces')) {
      // m7-4 (5.2): "glassCase and ice scale with k (dolls) about the stand
      // surface" on four shelves, as `layout.board.overlays` says for every
      // preset: BoardLayout's piece scale (lane B), not a number.
      t.documentedExact(
        '$base.pieces',
        'glassCase and ice scale with k (dolls) about the stand surface',
        reason: 'the four-shelf pieces\' scale, hand-written in BoardLayout',
      );
    }
  }
  return c;
}

/// m7-4 (5.2): `oneShelf`, "tokens only". No bundled level has one shelf
/// (the bundle's boards have two or three), and the preset carries no fit
/// limits or doll heights, so it is documentation: a level with one shelf
/// keeps BoardLayout's own fallback. Its shape is still checked, so a
/// changed preset is noticed.
void _oneShelf(TokenReader t, String base) {
  final planks = t.peek('$base.planksY');
  if (planks is! List<Object?> || planks.length != 1 || planks[0] is! num) {
    throw TokenFormatException('$base.planksY', 'one shelf has one plank');
  }
  for (final key in t.keys(base)) {
    const known = {'planksY', 'slotMaxDollHeight', 'maxSlotsPerRow', 'use'};
    if (!known.contains(key)) {
      throw TokenFormatException(
        '$base.$key',
        'a new oneShelf field: emit the preset (BoardPresetToken) instead',
      );
    }
  }
  t.documentedTree(
    base,
    reason:
        'tokens only (m7-4 5.2): no bundled level has one shelf, so no '
        'BoardPresetToken; BoardLayout keeps its fallback',
  );
}

/// A preset's own ice overlay: the tall one (`layout.board.iceOverlayTall`).
String _iceOverlay(TokenReader t, String base, String symbol) {
  final ice = t.numbers('$base.iceOverlay', symbol: symbol, length: 2);
  final tall = _peekNumbers(t, 'layout.board.iceOverlayTall');
  if (ice[0] != tall[0] || ice[1] != tall[1]) {
    throw TokenFormatException(
      '$base.iceOverlay',
      'differs from layout.board.iceOverlayTall',
    );
  }
  return 'iceOverlay: ${sizeLiteral(ice[0], ice[1])}';
}

String _rowOfFive(
  TokenReader t,
  String base,
  String symbol,
  String Function(String, String) limits,
  String Function(String, String) heights,
) {
  final pitch = t.number('$base.pitch', symbol: symbol).toDouble();
  final stand = [
    for (final v in t.numbers('$base.stand', symbol: symbol, length: 2))
      v.toDouble(),
  ];
  final tower = [
    for (final v in t.numbers('$base.towerStand', symbol: symbol, length: 2))
      v.toDouble(),
  ];
  final scale = t.number('$base.standScale', symbol: symbol).toDouble();
  final surface = t.number('$base.standSurfaceOffset', symbol: symbol);
  final boardStand = _peekNumbers(t, 'layout.board.stand');
  final boardTower = _peekNumbers(t, 'layout.board.towerStand');
  final boardSurface = _peekNumber(t, 'layout.board.standSurfaceOffset');
  final inset = double.parse(
    RegExp(
          r'− (\d+(?:\.\d+)?)\)$',
        ).firstMatch('${t.peek('layout.boardFit.standWidth')}')?[1] ??
        'NaN',
  );
  // The scale is the fit's stand width at this pitch over the full one.
  if (!_near(scale, (pitch - inset).clamp(0, boardStand[0]) / boardStand[0]) ||
      !_near(stand[0], boardStand[0] * scale) ||
      !_near(stand[1], boardStand[1] * scale) ||
      !_near(tower[0], boardTower[0] * scale) ||
      !_near(tower[1], boardTower[1] * scale) ||
      !_near(surface.toDouble(), boardSurface * scale)) {
    throw TokenFormatException(
      base,
      'the stand, tower stand and surface are not the board\'s × standScale '
      '(min(90, pitch − $inset) / 90)',
    );
  }
  // "plankTop + 9 − 34 × 0.8": the stand's top, scaled about its base.
  final top = RegExp(
    '^plankTop \\+ $_num − $_num × $_num\$',
  ).firstMatch(t.string('$base.standTop', symbol: symbol));
  if (top == null ||
      double.parse(top[2]!) != boardStand[1] ||
      double.parse(top[3]!) != scale) {
    throw TokenFormatException('$base.standTop', 'unexpected wording');
  }
  final pips = RegExp(
    '^$_num dp at pitch $_num, not scaled\$',
  ).firstMatch(t.string('$base.pips', symbol: symbol));
  if (pips == null ||
      double.parse(pips[1]!) != _peekNumber(t, 'layout.pip.size') ||
      double.parse(pips[2]!) != _peekNumber(t, 'layout.pip.pitch')) {
    throw TokenFormatException('$base.pips', 'expected the unscaled pips');
  }
  final args = [
    'pitch: ${doubleLiteral(pitch)}',
    'stand: ${sizeLiteral(stand[0], stand[1])}',
    'towerStand: ${sizeLiteral(tower[0], tower[1])}',
    'standScale: ${doubleLiteral(scale)}',
    'standSurfaceOffset: ${doubleLiteral(surface)}',
    'pipsScaled: false',
    'limits: ${limits(base, symbol)}',
    'dollHeights: ${heights(base, symbol)}',
    if (t.has('$base.optional') && t.boolean('$base.optional', symbol: symbol))
      'optional: true',
  ];
  return 'RowOfFiveToken(${args.join(', ')},)';
}

ConstClass _towerStack(TokenReader t) {
  const name = 'TowerStackTokens';
  const p = 'layout.towerStack';
  final c = ConstClass(
    name,
    'Buried-nest silhouettes that stay clear of the HUD and the plank above '
    '(tokens v3 `$p`). `SlotGeometry.towerStack` hand-codes the rule below; '
    'its test re-derives the design\'s three examples.\n\n'
    'Rule: ${t.documentedExact('$p.rule', 'step = min(18, (hRoom − topHeight) / N), hRoom = (towerSurface − limit) / drawnHeight, towerSurface = plankTop − 17.7, limit = hudClearY on the top shelf, else the plank above\'s top + 40 + headroom; if step < 9, draw max(1, floor((hRoom − topHeight) / 9)) silhouettes at step 9', reason: 'SlotGeometry.towerStack (lane B)')}',
  );
  t
    ..documented('$p.\$description', reason: 'prose, in the class doc')
    ..documentedExact(
      '$p.tag',
      'the +N tag always shows the real depth',
      reason: 'the tower tag (lane B)',
    )
    ..documentedTree(
      '$p.examples',
      reason: 'the design\'s worked examples, re-derived by lane B\'s test',
    );
  // m7-4 5.3: true sizes with raised bases; the step rule above stays.
  t.documented(
    '$p.d21',
    reason:
        'm7-4 5.3 (D21: true sizes, raised bases, ≥ 9 dp step), '
        'SlotGeometry.towerStack (lane B)',
  );
  final step = t.number('$p.step', symbol: '$name.step');
  final minStep = t.number('$p.minStep', symbol: '$name.minStep');
  // The pinned rule names both numbers.
  if (step != 18 || minStep != 9) {
    throw TokenFormatException(p, 'the rule says min(18, …) and step 9');
  }
  c.add('step', doubleLiteral(step), doc: 'The full step, dp (as before).');
  c.add(
    'minStep',
    doubleLiteral(minStep),
    doc: 'Below this step fewer silhouettes are drawn, at this step.',
  );
  return c;
}

ConstClass _icedTower(TokenReader t) {
  const name = 'IcedTowerTokens';
  const p = 'layout.icedTower';
  final c = ConstClass(
    name,
    'A tower under ice (tokens v3 `$p`). Its +N tag is '
    '${t.documentedExact('$p.tag', 'hidden while the ice is on; pops in (motion.tagPop) when fx_ice plays shatter', reason: 'the tower tag (lane B)')}.',
  );
  final m = _match(
    t,
    '$p.silhouettes',
    '$name.iceTopGap',
    r'kept inside the ice: limit = max\(limit, iceTop \+ (\d+)\)',
  );
  c.add(
    'iceTopGap',
    doubleLiteral(num.parse(m[1]!)),
    doc:
        'The silhouettes stay inside the ice: limit = max(limit, iceTop + '
        'this).',
  );
  return c;
}

ConstClass _hintArc(TokenReader t) {
  const name = 'HintArcTokens';
  const p = 'layout.hintArc';
  final c = ConstClass(
    name,
    'The dashed hint arc from the hinted doll to its target (tokens v3 '
    '`$p`, ${t.documented('$p.\$note', reason: 'the design item id')}).',
  );
  void n(String key, String doc) => c.add(
    key,
    doubleLiteral(t.number('$p.$key', symbol: '$name.$key')),
    doc: doc,
  );
  n('endOffsetAboveDoll', 'The arc ends this far above the target doll.');
  n('handleLift', 'The control points\' lift on the same shelf.');
  n('handleLiftCrossRow', 'The control points\' lift across shelves.');
  final dash = t.numbers('$p.dash', symbol: '$name.dashOn', length: 2);
  t.numbers('$p.dash', symbol: '$name.dashOff', length: 2);
  c.add('dashOn', doubleLiteral(dash[0]));
  c.add('dashOff', doubleLiteral(dash[1]));
  n('width', 'Stroke width.');
  c.add(
    'color',
    colorLiteral(parseCssColor(t.string('$p.color', symbol: '$name.color'))),
  );
  c.add(
    'arrowhead',
    '${t.boolean('$p.arrowhead', symbol: '$name.arrowhead')}',
    doc:
        'The arc ends with no arrowhead (m7-4 5.4: '
        '${t.documented('$p.\$m74', reason: 'a design note, in the doc')}).',
  );
  return c;
}

ConstClass _fallbackDoll(TokenReader t) {
  const name = 'FallbackDollTokens';
  const p = 'layout.fallbackDoll';
  final c = ConstClass(
    name,
    'The procedural doll drawn when a skin can\'t load (tokens v3 `$p`, '
    '${t.documented('$p.\$note', reason: 'the design item id')}; spec '
    '§12.5). Sizes are fractions of the doll height h (w: its width); the '
    'head, face and belly are diameters (m7-4 8). On the splash: '
    '${t.documentedExact('$p.splash', 'three cherry (red) fallback dolls, as 1.1; 12.12’s three colours only show the recipe', reason: 'the splash dolls (lane O, frame 1.1)')}.',
  );
  final head = _match(
    t,
    '$p.head',
    '$name.headSize',
    r'circle, diameter (\d*\.\d+) h, base color, (\d+) dp darker bottom',
  );
  t.string('$p.head', symbol: '$name.headShade');
  c.add(
    'headSize',
    doubleLiteral(double.parse(head[1]!)),
    doc: 'The head circle\'s diameter (`${t.peek('$p.head')}`).',
  );
  c.add(
    'headShade',
    doubleLiteral(num.parse(head[2]!)),
    doc: 'Its darker bottom band, dp.',
  );
  final face = _match(
    t,
    '$p.face',
    '$name.faceSize',
    r'cream (#[0-9A-Fa-f]{6}) disc, diameter (\d*\.\d+) h',
  );
  t.string('$p.face', symbol: '$name.faceColor');
  c.add(
    'faceSize',
    doubleLiteral(double.parse(face[2]!)),
    doc: 'The face disc\'s diameter.',
  );
  c.add('faceColor', colorLiteral(parseCssColor(face[1]!)));
  final body = _match(
    t,
    '$p.body',
    '$name.bodyHeight',
    r'rounded (\d*\.\d+) h × (\d*\.\d+) w, base color, darker bottom',
  );
  t.string('$p.body', symbol: '$name.bodyWidth');
  c.add(
    'bodyHeight',
    doubleLiteral(double.parse(body[1]!)),
    doc: 'The rounded body (`${t.peek('$p.body')}`).',
  );
  c.add(
    'bodyWidth',
    doubleLiteral(double.parse(body[2]!)),
    doc: 'Its width ÷ the doll width.',
  );
  final belly = _match(
    t,
    '$p.belly',
    '$name.bellySize',
    r'cream disc, diameter (\d*\.\d+) h, with the symbol in ink',
  );
  c.add(
    'bellySize',
    doubleLiteral(double.parse(belly[1]!)),
    doc:
        'The belly disc\'s diameter, the face colour, with the symbol in '
        'ink.',
  );
  c.add(
    'noDetails',
    '${t.boolean('$p.noDetails', symbol: '$name.noDetails')}',
    doc: 'No painted details or shine.',
  );
  return c;
}

ConstClass _chapterThemes(TokenReader t) {
  const name = 'ChapterThemeTokens';
  const p = 'theme';
  final c = ConstClass(
    name,
    'Chapter themes (tokens v3 `$p`, spec §12.4): the art\'s size and safe '
    'area, the Shop card crop box, and per chapter its palette and crop. '
    'Names and ribbons are copy (the ARB\'s `chapterName`).\n\n'
    '${t.documented('$p.\$description', reason: 'prose, in the class doc')}',
  );
  final art = t.numbers('$p.artSize', symbol: '$name.artSize', length: 2);
  c.add('artSize', sizeLiteral(art[0], art[1]), doc: 'The art\'s px size.');
  final safe = t.numbers('$p.safeArea', symbol: '$name.safeArea', length: 4);
  c.add(
    'safeArea',
    'Rect.fromLTWH(${safe.map(doubleLiteral).join(', ')})',
    doc: 'Important content stays inside this, in art px.',
  );
  final box = t.numbers('$p.thumbBox', symbol: '$name.thumbBox', length: 2);
  c.add(
    'thumbBox',
    sizeLiteral(box[0], box[1]),
    doc: 'The Shop theme card, dp; every `thumb` crop has its ratio.',
  );
  const palette = [
    'band',
    'accentTop',
    'accent',
    'accentEdge',
    'onAccent',
    'soft',
    'ink',
    'ribbonTail',
    'ribbonFold',
  ];
  // m7-4 4.15: the chapter ribbon's tint, from each palette.
  t.documentedExact(
    '$p.ribbonTint',
    'ui_chapter_ribbon: band = palette.accent, edge = palette.accentEdge, '
        'tail = ribbonTail, fold = ribbonFold, label shadow = ribbonFold; same '
        'key paths as winRibbon. The one-line Lottie stays; 4.7’s two-line '
        'plate is superseded',
    reason:
        'ChapterPalette.accent / accentEdge / ribbonTail / ribbonFold on '
        'WinRibbonTokens\' key paths (lane O)',
  );
  final members = <String>[];
  final keys = t.keys('$p.chapters');
  for (final (i, key) in keys.indexed) {
    final n = i + 1;
    final base = '$p.chapters.$key';
    if (int.tryParse(key) != n) {
      throw TokenFormatException(base, 'chapters are numbered 1, 2, 3, …');
    }
    final id = 'ch${n.toString().padLeft(2, '0')}';
    final symbol = '$name.$id';
    if (t.peek('$base.id') != id) {
      throw TokenFormatException('$base.id', 'expected $id');
    }
    t.documented('$base.id', reason: 'the catalog\'s theme id (checked)');
    final chapterName = t.documented(
      '$base.name',
      reason: 'copy: the ARB\'s chapterName (a test compares them)',
    );
    t.documentedExact(
      '$base.ribbon',
      'CHAPTER $n · $chapterName',
      reason: 'copy: the chapter ribbon, from the ARB',
    );
    final levels = _peekNumbers(t, '$base.levels');
    if (levels.length != 2 ||
        levels[0] != 20.0 * (n - 1) + 1 ||
        levels[1] != 20.0 * n) {
      throw TokenFormatException('$base.levels', 'chapters are 20 levels');
    }
    t.documented('$base.levels', reason: 'spec §7.1: 20 levels (checked)');
    final file = t.documented(
      '$base.file',
      reason:
          'the synced art, assets/themes/$id/background.svg (a test '
          'checks it)',
    );
    if (!RegExp('^themes/${id}_[a-z0-9_]+\\.svg\$').hasMatch(file)) {
      throw TokenFormatException('$base.file', 'expected themes/${id}_*.svg');
    }
    t.documented(
      '$base.figurine',
      reason: 'the catalog\'s figurine order (a test checks it)',
    );
    for (final key in t.keys(base)) {
      const known = {
        'id',
        'name',
        'ribbon',
        'levels',
        'file',
        'figurine',
        'palette',
        'thumb',
        'boardArt',
      };
      if (!known.contains(key)) {
        throw TokenFormatException('$base.$key', 'unknown theme field');
      }
    }
    if (t.keys('$base.palette').join(',') != palette.join(',')) {
      throw TokenFormatException(
        '$base.palette',
        'expected ${palette.join(', ')}',
      );
    }
    final colors = [
      for (final key in palette)
        '$key: ${colorLiteral(parseCssColor(t.string('$base.palette.$key', symbol: symbol)))}',
    ];
    final thumb = [
      for (final key in const ['x', 'y', 'w', 'h'])
        t.number('$base.thumb.$key', symbol: symbol).toDouble(),
    ];
    if (!_near(thumb[2] / thumb[3], box[0] / box[1], 0.005) ||
        thumb[0] < 0 ||
        thumb[1] < 0 ||
        thumb[0] + thumb[2] > art[0] ||
        thumb[1] + thumb[3] > art[1]) {
      throw TokenFormatException(
        '$base.thumb',
        'the crop must be inside the art at the thumbBox ratio',
      );
    }
    final boardArt = _boardArt(t, base, id, symbol);
    c.add(
      id,
      'ChapterThemeToken(chapter: $n, id: ${stringLiteral(id)}, '
      'palette: ChapterPalette(${colors.join(', ')}), '
      'thumb: Rect.fromLTWH(${thumb.map(doubleLiteral).join(', ')}),'
      '${boardArt == null ? '' : ' boardArtDir: ${stringLiteral(boardArt)},'})',
      doc: 'Chapter $n, "$chapterName" (`$base`).',
    );
    members.add(id);
  }
  c.add(
    'chapters',
    '[${members.join(', ')}]',
    type: 'List<ChapterThemeToken>',
    doc: 'Every chapter theme, in chapter order.',
  );
  return c;
}

/// The shared board art folder (tokens v4 `theme.chapters.N.boardArt.dir`).
const sharedBoardArtDir = 'board/';

/// The themed wood pieces a chapter may override (m7-4 A.5), in
/// tokens.json order. The sync ships the `-blank` stand and tower; the
/// pip-baked `slot-stand.svg` and `tower-base.svg` never ship (spec §10.3).
const themedBoardArtFiles = [
  'shelf-plank.svg',
  'slot-stand.svg',
  'slot-stand-blank.svg',
  'tower-base.svg',
  'tower-base-blank.svg',
];

/// `theme.chapters.N.boardArt` (tokens v4, m7-4 A.5): the folder of the
/// chapter's own wood, or null for the shared `board/` art.
String? _boardArt(TokenReader t, String base, String id, String symbol) {
  final art = '$base.boardArt';
  if (!t.has(art)) return null;
  final dir = t.string('$art.dir', symbol: symbol);
  if (dir == sharedBoardArtDir) {
    if (t.keys(art).join(',') != 'dir') {
      throw TokenFormatException(art, 'the shared art has only a dir');
    }
    return null;
  }
  if (dir != 'board/$id/') {
    throw TokenFormatException('$art.dir', 'expected board/ or board/$id/');
  }
  if (t.keys(art).join(',') != 'dir,wood,files,note') {
    throw TokenFormatException(art, 'expected dir, wood, files, note');
  }
  final files = t.strings('$art.files', symbol: symbol);
  if (files.join(',') != themedBoardArtFiles.join(',')) {
    throw TokenFormatException(
      '$art.files',
      'expected ${themedBoardArtFiles.join(', ')} (the sync ships them from '
          'design/board/$id/)',
    );
  }
  t
    ..documented('$art.wood', reason: 'the art\'s description')
    ..documentedExact(
      '$art.note',
      'A.5: the shared shapes and sizes; extra-slot, glass and ice stay shared',
      reason: 'only the wood pieces are themed (BoardSprite, lane B)',
    );
  return 'board/$id/';
}
