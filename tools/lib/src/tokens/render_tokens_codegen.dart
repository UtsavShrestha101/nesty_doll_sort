import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/tokens/board_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Emits `packages/nesty_render/lib/src/tokens/render_tokens.gen.dart`:
/// doll colors, skin geometry, board layout and motion.
String renderTokensSource(TokenReader t, {required String header}) {
  final classes = [
    _info(t),
    _dollColors(t),
    _derivation(t),
    _skin(t),
    _board(t),
    ...boardV3Classes(t),
    _motion(t),
  ];
  t
    ..documented(
      'meta.updated',
      reason: 'the delivery date, in the design handoff only',
    )
    ..documented(
      'layout.extraSlot.placement',
      reason:
          'contradicts spec §3.6; D172 keeps the bottom shelf (lane B: '
          'BoardShape.withExtraSlot, rowOfFive for 5)',
    )
    ..documented(
      'layout.extraSlot.limitPerLevel',
      reason:
          'a rule, never read from tokens: LayoutLimits.maxExtraSlots '
          '(nesty_core); rule_tokens_test pins it',
    );
  return [
    header,
    "import 'dart:ui' show Color, Offset, Rect, Size;",
    '',
    "import 'package:flutter/animation.dart' show Cubic;",
    "import 'package:nesty_core/nesty_core.dart' show DollColor;",
    "import 'package:nesty_render/src/tokens/render_token_types.dart';",
    '',
    ...classes.map((c) => '${c.build()}\n'),
  ].join('\n');
}

ConstClass _info(TokenReader t) {
  final c = ConstClass(
    'RenderTokensInfo',
    'Which design/tokens.json these render tokens were generated from.',
  );
  c.add(
    'version',
    '${t.integer('meta.version', symbol: 'RenderTokensInfo.version')}',
    doc: 'tokens.json `meta.version`.',
  );
  return c;
}

ConstClass _dollColors(TokenReader t) {
  final c = ConstClass(
    'DollColorTokens',
    'Per-`DollColor` design colors (tokens.json `dollColor`). Keyed by the '
        '`nesty_core` `DollColor.id`, never by display name.',
  );
  final ids = t.keys('dollColor');
  final coreIds = [for (final color in DollColor.values) color.id];
  if (ids.join(',') != coreIds.join(',')) {
    throw TokenFormatException(
      'dollColor',
      'keys [${ids.join(', ')}] must equal the nesty_core DollColor ids '
          '[${coreIds.join(', ')}] in enum order',
    );
  }
  for (final color in DollColor.values) {
    final base = 'dollColor.${color.id}';
    final symbol = 'DollColorTokens.${color.name}';
    final allowed = {
      'name',
      'base',
      'ink',
      'light',
      'symbol',
      'wild',
      'tintMode',
      'ramp',
      'rampInput',
    };
    for (final key in t.keys(base)) {
      if (!allowed.contains(key)) {
        throw TokenFormatException('$base.$key', 'unknown doll color field');
      }
    }
    String col(String key) =>
        colorLiteral(parseCssColor(t.string('$base.$key', symbol: symbol)));
    final args = <String>[
      'id: ${stringLiteral(color.id)}',
      'name: ${stringLiteral(t.string('$base.name', symbol: symbol))}',
      'base: ${col('base')}',
      'ink: ${col('ink')}',
      'light: ${col('light')}',
      'symbol: ${stringLiteral(t.string('$base.symbol', symbol: symbol))}',
    ];
    final wild = t.has('$base.wild') && t.boolean('$base.wild', symbol: symbol);
    if (wild != color.isWild) {
      throw TokenFormatException(
        '$base.wild',
        'is $wild but DollColor.${color.name}.isWild is ${color.isWild}',
      );
    }
    if (wild) args.add('wild: true');
    if (t.has('$base.tintMode')) {
      final mode = t.string('$base.tintMode', symbol: symbol);
      if (mode != 'gradientMap' && mode != 'modulate') {
        throw TokenFormatException('$base.tintMode', 'unknown mode "$mode"');
      }
      if (mode == 'gradientMap') {
        args.add('tintMode: DollTintMode.gradientMap');
        final ramp = t.list('$base.ramp', symbol: symbol);
        final stops = <String>[];
        var last = -1.0;
        for (final stop in ramp) {
          if (stop is! List<Object?> ||
              stop.length != 2 ||
              stop[0] is! num ||
              stop[1] is! String) {
            throw TokenFormatException('$base.ramp', 'stops are [pos, hex]');
          }
          final pos = (stop[0]! as num).toDouble();
          if (pos < 0 || pos > 1 || pos <= last) {
            throw TokenFormatException('$base.ramp', 'positions must rise 0–1');
          }
          last = pos;
          stops.add(
            'RampStop(${doubleLiteral(pos)}, '
            '${colorLiteral(parseCssColor(stop[1]! as String))})',
          );
        }
        args.add('ramp: [${stops.join(', ')}]');
        final input = t.string('$base.rampInput', symbol: symbol);
        final match = RegExp(r'^gray\^(\d+(?:\.\d+)?)$').firstMatch(input);
        if (match == null) {
          throw TokenFormatException('$base.rampInput', 'expected gray^N');
        }
        args.add(
          'rampInputExponent: ${doubleLiteral(double.parse(match[1]!))}',
        );
      }
    }
    c.add(
      color.name,
      'DollColorToken(${args.join(', ')},)',
      doc: 'tokens.json `$base`.',
    );
  }
  c.add(
    'values',
    '[${DollColor.values.map((d) => d.name).join(', ')}]',
    type: 'List<DollColorToken>',
    doc: 'Every color, in `DollColor.values` order.',
  );
  c.addRaw(
    [
      docComment(
        'The tokens for [color]. Exhaustive: a new `DollColor` '
        'without tokens is a compile error.',
      ),
      '  static DollColorToken of(DollColor color) => switch (color) {',
      for (final d in DollColor.values) '    DollColor.${d.name} => ${d.name},',
      '  };',
    ].join('\n'),
  );
  return c;
}

ConstClass _derivation(TokenReader t) {
  const p = 'dollColorDerivation';
  final c = ConstClass(
    'DollColorDerivationTokens',
    'How to derive ink/light shades for a color outside the table '
        '(tokens.json `$p`). The table colors are hand-tuned: use their '
        'tokens, not this.',
  );
  final space = t.string('$p.space', symbol: 'DollColorDerivationTokens.space');
  if (space != 'OKLCH') {
    throw TokenFormatException('$p.space', 'only OKLCH is supported');
  }
  c.add('space', stringLiteral(space));
  void n(String path, String member) => c.add(
    member,
    doubleLiteral(
      t.number('$p.$path', symbol: 'DollColorDerivationTokens.$member'),
    ),
    doc: 'tokens.json `$p.$path`.',
  );
  n('ink.dL', 'inkDeltaL');
  n('ink.chroma', 'inkChromaScale');
  n('ink.minL', 'inkMinL');
  n('light.dL', 'lightDeltaL');
  n('light.chroma', 'lightChromaScale');
  n('light.maxL', 'lightMaxL');
  final gamut = t.string(
    '$p.gamut',
    symbol: 'DollColorDerivationTokens.gamutChromaStep',
  );
  final m = RegExp(
    r'^reduce chroma by (\d+)% steps until inside sRGB$',
  ).firstMatch(gamut);
  if (m == null) throw TokenFormatException('$p.gamut', 'unexpected wording');
  c.add(
    'gamutChromaStep',
    doubleLiteral(int.parse(m[1]!) / 100),
    doc: '"$gamut": multiply chroma by (1 − this) until the color is in sRGB.',
  );
  t.documented('$p.note', reason: 'prose; the class doc says it');
  return c;
}

ConstClass _skin(TokenReader t) {
  const s = 'SkinTokens';
  final c = ConstClass(
    s,
    'Doll skin geometry in 512×768 artboard units (tokens.json `skin`, '
    'spec §12.2). Per-skin values come from each `skin.json`; these are '
    'the defaults they must match.\n\n'
    'Tint: ${t.documented('skin.tint', reason: 'prose, in the class doc')}.',
  );
  final artboard = t.numbers('skin.artboard', symbol: '$s.artboard', length: 2);
  c.add('artboard', sizeLiteral(artboard[0], artboard[1]));
  void n(String key, [String? member]) => c.add(
    member ?? key,
    doubleLiteral(t.number('skin.$key', symbol: '$s.${member ?? key}')),
    doc: 'tokens.json `skin.$key`.',
  );
  n('splitY');
  n('lidLiftPx');
  final anchor = t.numbers(
    'skin.symbolAnchor',
    symbol: '$s.symbolAnchor',
    length: 2,
  );
  c.add(
    'symbolAnchor',
    offsetLiteral(anchor[0], anchor[1]),
    doc: 'Center of the belly symbol box.',
  );
  n('symbolSize');
  n('symbolSizeLarge');
  n('badgeRadius');
  c.add(
    'badgeFill',
    colorLiteral(
      parseCssColor(t.string('skin.badgeFill', symbol: '$s.badgeFill')),
    ),
    doc: 'Large-symbols mode backing disc.',
  );
  n('badgeStroke');
  c.add(
    'woodSilhouette',
    colorLiteral(
      parseCssColor(
        t.string('skin.woodSilhouette', symbol: '$s.woodSilhouette'),
      ),
    ),
    doc: 'Mask tint for buried tower nests (spec §3.2).',
  );
  const rim = 'skin.interiorRim';
  for (final (key, member) in const [
    ('ellipseOuter', 'interiorRimOuter'),
    ('ellipseInner', 'interiorRimInner'),
  ]) {
    final e = t.numbers('$rim.$key', symbol: '$s.$member', length: 4);
    c.add(
      member,
      'TokenEllipse(cx: ${doubleLiteral(e[0])}, cy: ${doubleLiteral(e[1])}, '
      'rx: ${doubleLiteral(e[2])}, ry: ${doubleLiteral(e[3])})',
      doc:
          'tokens.json `$rim.$key` (cx, cy, rx, ry), drawn while the lid '
          'is open.',
    );
  }
  c.add(
    'interiorRimInnerFill',
    colorLiteral(
      parseCssColor(
        t.string('$rim.innerFill', symbol: '$s.interiorRimInnerFill'),
      ),
    ),
  );
  c.add(
    'interiorRimInnerOpacity',
    doubleLiteral(
      t.number('$rim.innerOpacity', symbol: '$s.interiorRimInnerOpacity'),
    ),
  );
  return c;
}

ConstClass _board(TokenReader t) {
  const b = 'BoardTokens';
  final c = ConstClass(
    b,
    'Board layout on the 390×844 reference screen (tokens.json `meta.screen` '
    'and `layout`, spec §10.3). BoardLayout scales these to the device.\n\n'
    'Units: ${t.documented('meta.units', reason: 'prose, in the class doc')}.',
  );
  final w = t.number('meta.screen.width', symbol: '$b.referenceScreen');
  final h = t.number('meta.screen.height', symbol: '$b.referenceScreen');
  c.add('referenceScreen', sizeLiteral(w, h));
  c.add(
    'referenceSafeTop',
    doubleLiteral(
      t.number('meta.screen.safeTop', symbol: '$b.referenceSafeTop'),
    ),
  );
  c.add(
    'referenceSafeBottom',
    doubleLiteral(
      t.number('meta.screen.safeBottom', symbol: '$b.referenceSafeBottom'),
    ),
  );

  const lb = 'layout.board';
  void n(String path, String member, {String? doc}) => c.add(
    member,
    doubleLiteral(t.number(path, symbol: '$b.$member')),
    doc: doc ?? 'tokens.json `$path`.',
  );
  Size2 size(String path, String member, {String? doc}) {
    final v = t.numbers(path, symbol: '$b.$member', length: 2);
    c.add(member, sizeLiteral(v[0], v[1]), doc: doc ?? 'tokens.json `$path`.');
    return (v[0], v[1]);
  }

  n('$lb.sideMargin', 'sideMargin');
  final slotMax = t.number('$lb.slotWidthMax', symbol: '$b.slotWidthMax');
  c.add('slotWidthMax', doubleLiteral(slotMax), doc: 'Max slot pitch.');
  final spacing = t.string('$lb.slotSpacing', symbol: '$b.slotRowWidth');
  final sm = RegExp(r'^min\((\d+), (\d+) / slotsInRow\)$').firstMatch(spacing);
  if (sm == null || num.parse(sm[1]!) != slotMax) {
    throw TokenFormatException(
      '$lb.slotSpacing',
      'expected "min(<slotWidthMax>, <rowWidth> / slotsInRow)"',
    );
  }
  c.add(
    'slotRowWidth',
    doubleLiteral(num.parse(sm[2]!)),
    doc: 'Slot pitch = `$spacing`.',
  );
  final planks = <String>[];
  String? tallPlanks;
  for (final key in t.keys('$lb.planksY')) {
    final (shelves, tall) = _shelfCount(key, '$lb.planksY');
    final symbol = tall
        ? '$b.plankTopsThreeShelvesTall'
        : '$b.plankTopsByShelfCount';
    final ys = t.numbers('$lb.planksY.$key', symbol: symbol);
    if (ys.length != shelves) {
      throw TokenFormatException('$lb.planksY.$key', 'needs $shelves planks');
    }
    final list = '[${ys.map(doubleLiteral).join(', ')}]';
    if (!tall) {
      planks.add('$shelves: $list');
    } else if (shelves == 3 && tallPlanks == null) {
      tallPlanks = list;
    } else {
      throw TokenFormatException(
        '$lb.planksY.$key',
        'only 3shelvesTall has a tall variant',
      );
    }
  }
  c.add(
    'plankTopsByShelfCount',
    '{${planks.join(', ')}}',
    type: 'Map<int, List<double>>',
    doc: 'Plank top y per shelf count (tokens.json `$lb.planksY`).',
  );
  if (tallPlanks == null) {
    throw TokenFormatException('$lb.planksY', 'needs 3shelvesTall');
  }
  c.add(
    'plankTopsThreeShelvesTall',
    tallPlanks,
    type: 'List<double>',
    doc:
        'The size-6 boards\' three shelves (tokens.json '
        '`$lb.planksY.3shelvesTall`, `layout.boardPresets.threeShelvesTall`): '
        '12 dp higher, 6 dp longer pitch.',
  );
  n('$lb.plankHeight', 'plankHeight');
  size('$lb.stand', 'standSize');
  size('$lb.towerStand', 'towerStandSize');
  n(
    '$lb.standSurfaceOffset',
    'standSurfaceOffset',
    doc: 'The doll base sits this far below the stand top.',
  );
  size('$lb.glassCase', 'glassCaseSize');
  final (_, iceHeight) = size('$lb.iceOverlay', 'iceOverlaySize');
  final (_, tallIceHeight) = size(
    '$lb.iceOverlayTall',
    'iceOverlayTallSize',
    doc:
        'The tall ice of `threeShelvesTall` (tokens.json '
        '`$lb.iceOverlayTall`).',
  );
  // "plankTop + 16.5 − overlay height (160 → plankTop + 9 − 152.5 as
  // before; 168 on threeShelvesTall, where fx_ice plays at scale (1, 1.05)
  // from the ice bottom)".
  final iceTop = t.string('$lb.iceOverlayTop', symbol: '$b.iceTopFromPlank');
  t.string('$lb.iceOverlayTop', symbol: '$b.iceTallFxScaleY');
  const nr = r'(\d+(?:\.\d+)?)';
  final im = RegExp(
    '^plankTop \\+ $nr − overlay height \\($nr → plankTop \\+ $nr − $nr as '
    'before; $nr on threeShelvesTall, where fx_ice plays at scale '
    '\\(1, $nr\\) from the ice bottom\\)\$',
  ).firstMatch(iceTop);
  if (im == null) {
    throw TokenFormatException('$lb.iceOverlayTop', 'unexpected wording');
  }
  final fromPlank = double.parse(im[1]!);
  if (double.parse(im[2]!) != iceHeight ||
      double.parse(im[5]!) != tallIceHeight ||
      (fromPlank - iceHeight - (double.parse(im[3]!) - double.parse(im[4]!)))
              .abs() >
          1e-9) {
    throw TokenFormatException(
      '$lb.iceOverlayTop',
      'its worked example does not match the overlay sizes',
    );
  }
  c.add(
    'iceTopFromPlank',
    doubleLiteral(fromPlank),
    doc:
        'An ice overlay\'s top = plankTop + this − its height (tokens.json '
        '`$lb.iceOverlayTop`).',
  );
  c.add(
    'iceTallFxScaleY',
    doubleLiteral(double.parse(im[6]!)),
    doc:
        'On the tall ice, `fx_ice` plays at scale (1, this) from the ice\'s '
        'bottom (LOTTIE.md m7-1).',
  );
  // Tokens v4 (m7-4 5.1): the pieces scale with the stand; the caps.
  final overlays = t.string('$lb.overlays', symbol: '$b.tallGlassPitchInset');
  t.string('$lb.overlays', symbol: '$b.iceMaxOverlap');
  final om = RegExp(
    r'^glass, tall glass and ice scale with the stand \(standScale\) about '
    r'their bottom centre; tall glass capped at pitch − (\d+(?:\.\d+)?); '
    r'adjacent ice may overlap up to (\d+(?:\.\d+)?) dp \(as rows of 4 do '
    r'today\)$',
  ).firstMatch(overlays);
  if (om == null) {
    throw TokenFormatException('$lb.overlays', 'unexpected wording');
  }
  c.add(
    'tallGlassPitchInset',
    doubleLiteral(num.parse(om[1]!)),
    doc:
        'Glass, tall glass and ice scale with the stand about their bottom '
        'centre; the tall glass is at most the pitch − this wide (tokens.json '
        '`$lb.overlays`).',
  );
  c.add(
    'iceMaxOverlap',
    doubleLiteral(num.parse(om[2]!)),
    doc: 'Neighbouring ice may overlap by up to this, dp.',
  );
  t.documentedExact(
    '$lb.glassCaseTopOverlap',
    'keep: the 0.7 dp under the plank above is inside the plank shadow',
    reason: 'the glass case keeps its 0.7 dp overlap (m7-4 Choices 5.6)',
  );
  final hit = t.string('$lb.hitArea', symbol: '$b.minHitExtent');
  final hm = RegExp(r'^whole slot column, min (\d+)$').firstMatch(hit);
  if (hm == null) throw TokenFormatException('$lb.hitArea', 'unexpected');
  c.add(
    'minHitExtent',
    doubleLiteral(num.parse(hm[1]!)),
    doc: 'Hit area: "$hit".',
  );

  const lp = 'layout.pip';
  n('$lp.size', 'pipSize');
  n('$lp.pitch', 'pipPitch');
  final order = t.string('$lp.order', symbol: '$b.pipBiggestFirst');
  if (order != 'left = biggest size') {
    throw TokenFormatException('$lp.order', 'unexpected "$order"');
  }
  c.add('pipBiggestFirst', 'true', doc: 'Pip order: "$order".');
  final filled = t.string('$lp.filled', symbol: '$b.pipFilledRingColor');
  final fm = RegExp(
    r'^doll base color \+ (\d+(?:\.\d+)?)px (\S+) ring$',
  ).firstMatch(filled);
  if (fm == null) throw TokenFormatException('$lp.filled', 'unexpected');
  t.string('$lp.filled', symbol: '$b.pipFilledRingWidth');
  c.add(
    'pipFilledRingWidth',
    doubleLiteral(num.parse(fm[1]!)),
    doc: 'Filled pip: "$filled".',
  );
  c.add('pipFilledRingColor', colorLiteral(parseCssColor(fm[2]!)));
  final empty = t.string('$lp.empty', symbol: '$b.pipEmptyColor');
  final em = RegExp(r'^(#[0-9A-Fa-f]{6}) inset$').firstMatch(empty);
  if (em == null) throw TokenFormatException('$lp.empty', 'unexpected');
  t.string('$lp.empty', symbol: '$b.pipEmptyInset');
  c.add(
    'pipEmptyColor',
    colorLiteral(parseCssColor(em[1]!)),
    doc: 'Empty pip: "$empty".',
  );
  c.add('pipEmptyInset', 'true');

  const ld = 'layout.dollHeightBySize';
  final fractions = <double>[];
  String? divisorText;
  for (final key in t.keys(ld)) {
    if (key == 'maxSize3Scale') {
      divisorText = t.string('$ld.$key', symbol: '$b.maxSize3Divisor');
    } else if (key == 'slotMaxDollHeight') {
      continue;
    } else {
      final size = int.tryParse(key);
      if (size != fractions.length + 1) {
        throw TokenFormatException('$ld.$key', 'sizes must be 1, 2, 3, …');
      }
      fractions.add(
        t.number('$ld.$key', symbol: '$b.dollHeightFractions').toDouble(),
      );
    }
  }
  c.add(
    'dollHeightFractions',
    '[${fractions.map(doubleLiteral).join(', ')}]',
    type: 'List<double>',
    doc: 'Doll height ÷ slotMaxDollHeight, index 0 = size 1.',
  );
  final dm = RegExp(
    r'^divide by (\d*\.\d+) so size (\d) = 1\.00$',
  ).firstMatch(divisorText ?? '');
  if (dm == null ||
      int.parse(dm[2]!) != 3 ||
      double.parse(dm[1]!) != fractions[2]) {
    throw TokenFormatException('$ld.maxSize3Scale', 'unexpected wording');
  }
  c.add(
    'maxSize3Divisor',
    doubleLiteral(double.parse(dm[1]!)),
    doc: 'When maxSize = 3: "$divisorText".',
  );
  final maxHeights = <String>[];
  for (final key in t.keys('$ld.slotMaxDollHeight')) {
    final (shelves, tall) = _shelfCount(key, '$ld.slotMaxDollHeight');
    if (tall) {
      throw TokenFormatException('$ld.slotMaxDollHeight.$key', 'no tall key');
    }
    maxHeights.add(
      '$shelves: ${doubleLiteral(t.number('$ld.slotMaxDollHeight.$key', symbol: '$b.slotMaxDollHeightByShelfCount'))}',
    );
  }
  c.add(
    'slotMaxDollHeightByShelfCount',
    '{${maxHeights.join(', ')}}',
    type: 'Map<int, double>',
  );
  // Owner decision 3e (2026-09-26): every skin draws its buried nests as
  // the one wood-grain blank board sprite.
  final tower = t.string(
    'layout.towerSilhouettes',
    symbol: '$b.towerDepthRaise',
  );
  t.string('layout.towerSilhouettes', symbol: '$b.towerSilhouetteSprite');
  final tm = RegExp(
    r'^each buried nest drawn behind the top as the wood-grain blank '
    r'board/([a-z0-9-]+)\.svg \(same for every skin\), height '
    r'\(topHeight \+ (\d+) × depth\), with a \+N walnut tag at the '
    r"stand's right$",
  ).firstMatch(tower);
  if (tm == null) {
    throw TokenFormatException('layout.towerSilhouettes', 'unexpected wording');
  }
  c.add(
    'towerDepthRaise',
    doubleLiteral(num.parse(tm[2]!)),
    doc: 'Towers: "$tower".',
  );
  c.add(
    'towerSilhouetteSprite',
    stringLiteral(tm[1]!),
    doc:
        'The board sprite (`board/<name>.svg`) every buried tower nest draws, '
        'the same for every skin.',
  );

  const lh = 'layout.hud';
  n('$lh.top', 'hudTop');
  n('$lh.side', 'hudSide');
  size('$lh.pauseButton', 'hudPauseButtonSize');
  n('$lh.levelPillHeight', 'hudLevelPillHeight');
  n('$lh.coinPillHeight', 'hudCoinPillHeight');
  n('$lh.familyCounter.top', 'familyCounterTop');
  n('$lh.familyCounter.height', 'familyCounterHeight');

  const bb = 'layout.boosterBar';
  n('$bb.top', 'boosterBarTop');
  size('$bb.buttonSize', 'boosterButtonSize');
  n('$bb.gap', 'boosterGap');
  n('$bb.left', 'boosterBarLeft');
  n('$bb.topInset', 'boosterBarTopInset');
  return c;
}

typedef Size2 = (num, num);

/// `3shelves` → (3, false); tokens v3's `3shelvesTall` → (3, true).
(int, bool) _shelfCount(String key, String path) {
  final m = RegExp(r'^(\d+)shelves(Tall)?$').firstMatch(key);
  if (m == null) {
    throw TokenFormatException(
      '$path.$key',
      'expected Nshelves or NshelvesTall',
    );
  }
  return (int.parse(m[1]!), m[2] != null);
}

ConstClass _motion(TokenReader t) {
  const m = 'MotionTokens';
  final c = ConstClass(
    m,
    'Game-feel timings (tokens.json `motion`, spec §11.1). Durations are '
    'milliseconds (`…Ms`), distances logical px, angles degrees.',
  );
  final easings = <String, String>{};
  for (final key in t.keys('motion.easing')) {
    final member = 'curve${key[0].toUpperCase()}${key.substring(1)}';
    final value = t.string('motion.easing.$key', symbol: '$m.$member');
    easings[key] = member;
    c.add(member, cubicLiteral(parseCubicBezier(value)), doc: '`$value`.');
  }
  void ms(String path, String member) => c.add(
    member,
    '${t.integer('motion.$path', symbol: '$m.$member')}',
    doc: 'tokens.json `motion.$path`.',
  );
  void n(String path, String member) => c.add(
    member,
    doubleLiteral(t.number('motion.$path', symbol: '$m.$member')),
    doc: 'tokens.json `motion.$path`.',
  );
  void i(String path, String member) => c.add(
    member,
    '${t.integer('motion.$path', symbol: '$m.$member')}',
    doc: 'tokens.json `motion.$path`.',
  );
  void flag(String path, String member) => c.add(
    member,
    '${t.boolean('motion.$path', symbol: '$m.$member')}',
    doc: 'tokens.json `motion.$path`.',
  );
  void curve(String path, String member) {
    final name = t.string('motion.$path', symbol: '$m.$member');
    final target = easings[name];
    if (target == null) {
      throw TokenFormatException('motion.$path', 'unknown easing "$name"');
    }
    c.add(member, target, type: 'Cubic', doc: 'tokens.json `motion.$path`.');
  }

  ms('pick.duration', 'pickMs');
  n('pick.lift', 'pickLift');
  n('pick.scale', 'pickScale');
  n('pick.wobbleDeg', 'pickWobbleDeg');
  ms('pick.wobblePeriod', 'pickWobblePeriodMs');
  ms('pick.cancelSettle', 'pickCancelSettleMs');
  // Tokens v5 (m7-5 item 14): a wobbling doll's rotation eases to 0 over
  // the first ms of doll_move, overlapped, so the move never snaps.
  ms('pick.wobbleToMoveMs', 'pickWobbleToMoveMs');
  final wobbleNote = t.string(
    r'motion.pick.$m75',
    symbol: '$m.pickWobbleToMoveCurve',
  );
  final wobble = RegExp(
    r'^wobbleToMoveMs: when a wobbling doll is dropped, its rotation eases '
    r'to 0 over the first (\d+) ms of doll_move \((\w+)\), overlapped, so '
    r'the move starts at once and never snaps$',
  ).firstMatch(wobbleNote);
  if (wobble == null ||
      int.parse(wobble[1]!) != t.peek('motion.pick.wobbleToMoveMs') ||
      easings[wobble[2]] == null) {
    throw TokenFormatException(
      r'motion.pick.$m75',
      'unexpected wording, or not wobbleToMoveMs with a motion.easing',
    );
  }
  c.add(
    'pickWobbleToMoveCurve',
    easings[wobble[2]]!,
    type: 'Cubic',
    doc:
        'When a wobbling doll is dropped its rotation eases to 0 over '
        '[pickWobbleToMoveMs] of doll_move with this curve, overlapped, so '
        'the move starts at once and never snaps (m7-5).',
  );

  ms('move.duration', 'moveMs');
  curve('move.easing', 'moveCurve');
  n('move.arcHeight', 'moveArcHeight');

  ms('nest.lidLift.duration', 'nestLidLiftMs');
  n('nest.lidLift.fraction', 'nestLidLiftFraction');
  curve('nest.lidLift.easing', 'nestLidLiftCurve');
  ms('nest.dropIn.duration', 'nestDropInMs');
  n('nest.dropIn.scale', 'nestDropInScale');
  curve('nest.dropIn.easing', 'nestDropInCurve');
  ms('nest.lidSnap.duration', 'nestLidSnapMs');
  curve('nest.lidSnap.easing', 'nestLidSnapCurve');
  ms('nest.squash.duration', 'nestSquashMs');
  n('nest.squash.scaleX', 'nestSquashScaleX');
  n('nest.squash.scaleY', 'nestSquashScaleY');
  t.documented(
    'motion.swallow',
    reason: 'prose; the swallow reuses the nest timings',
  );

  ms('complete.shine', 'completeShineMs');
  final hops = t.list('motion.complete.hops', symbol: '$m.completeHops');
  final hopLiterals = <String>[];
  for (final hop in hops) {
    if (hop is! Map<String, Object?> ||
        hop.keys.toSet().difference({'height', 'duration'}).isNotEmpty ||
        hop['height'] is! num ||
        hop['duration'] is! int) {
      throw TokenFormatException(
        'motion.complete.hops',
        'each hop is {height: number, duration: int}',
      );
    }
    hopLiterals.add(
      'MotionHop(height: ${doubleLiteral(hop['height']! as num)}, '
      'durationMs: ${hop['duration']})',
    );
  }
  c.add(
    'completeHops',
    '[${hopLiterals.join(', ')}]',
    type: 'List<MotionHop>',
    doc: 'tokens.json `motion.complete.hops`.',
  );
  ms('complete.fly.duration', 'completeFlyMs');
  n('complete.fly.endScale', 'completeFlyEndScale');
  n('complete.fly.rotateDeg', 'completeFlyRotateDeg');
  curve('complete.fly.easing', 'completeFlyCurve');
  ms('complete.counterBump.duration', 'completeCounterBumpMs');
  n('complete.counterBump.scale', 'completeCounterBumpScale');
  ms('complete.dustPuff', 'completeDustPuffMs');

  i('invalid.shakes', 'invalidShakes');
  n('invalid.amplitude', 'invalidAmplitude');
  ms('invalid.each', 'invalidShakeMs');
  ms('invalid.returnDuration', 'invalidReturnMs');

  ms('reveal.duration', 'revealMs');
  // Owner decision 3d (2026-09-26): the wipe grows from the doll's centre,
  // not the belly.
  final reveal = t.string('motion.reveal.type', symbol: '$m.revealSplashDrops');
  t.string('motion.reveal.type', symbol: '$m.revealWipeCenter');
  final rm = RegExp(
    r"^circular paint wipe from the doll's centre \(art (\d+(?:\.\d+)?), "
    r'(\d+(?:\.\d+)?), (\d+(?:\.\d+)?) % down the artboard\) \+ (\d+) '
    r'splash drops$',
  ).firstMatch(reveal);
  if (rm == null) {
    throw TokenFormatException('motion.reveal.type', 'unexpected wording');
  }
  final cx = num.parse(rm[1]!);
  final cy = num.parse(rm[2]!);
  // Peek (no ledger entry): skin.artboard is accounted for by _skin.
  final artboard = t.peek('skin.artboard');
  if (artboard is! List<Object?> ||
      artboard.length != 2 ||
      artboard[0] is! num ||
      artboard[1] is! num) {
    throw TokenFormatException('skin.artboard', 'expected [width, height]');
  }
  final artWidth = artboard[0]! as num;
  final artHeight = artboard[1]! as num;
  if (cx < 0 ||
      cx > artWidth ||
      (cy / artHeight * 100 - num.parse(rm[3]!)).abs() > 0.5) {
    throw TokenFormatException(
      'motion.reveal.type',
      'the wipe centre ($cx, $cy) is not ${rm[3]} % down the '
          '$artWidth × $artHeight artboard',
    );
  }
  c.add('revealSplashDrops', rm[4]!, doc: 'Reveal: "$reveal".');
  c.add(
    'revealWipeCenter',
    offsetLiteral(cx, cy),
    doc:
        'The centre the reveal wipe grows from, in 512×768 skin artboard '
        'units (tokens.json `motion.reveal.type`).',
  );

  ms('unlock.padlockPop', 'unlockPadlockPopMs');
  ms('unlock.crackedAt', 'unlockCrackedAtMs');
  ms('unlock.shatteredAt', 'unlockShatteredAtMs');
  ms('unlock.shardsDuration', 'unlockShardsMs');

  i('ice.stages', 'iceStages');
  ms('ice.crackShake.duration', 'iceCrackShakeMs');
  n('ice.crackShake.amplitude', 'iceCrackShakeAmplitude');
  ms('ice.shatter', 'iceShatterMs');

  ms('win.ribbonIn', 'winRibbonInMs');
  ms('win.confetti', 'winConfettiMs');
  ms('win.danceLoop', 'winDanceLoopMs');
  ms('win.danceStagger', 'winDanceStaggerMs');

  ms('combo.windowMs', 'comboWindowMs');
  i('combo.maxSteps', 'comboMaxSteps');

  ms('ui.buttonPress', 'uiButtonPressMs');
  ms('ui.toggle', 'uiToggleMs');
  ms('ui.sheetIn', 'uiSheetInMs');
  ms('ui.modalIn', 'uiModalInMs');
  ms('ui.tabLift', 'uiTabLiftMs');

  n('reducedMotion.durationScale', 'reducedMotionDurationScale');
  flag('reducedMotion.shake', 'reducedMotionShake');
  flag('reducedMotion.confetti', 'reducedMotionConfetti');
  flag('reducedMotion.wobble', 'reducedMotionWobble');

  // Tokens v3 (m7-3): the iced tower's tag pop, the row-of-5 re-pitch, tap
  // feedback on a slot with nothing selected (E.13), the drag hover
  // (E.14) and the extra slot's pad (E.16, E.21).
  ms('tagPop.duration', 'tagPopMs');
  n('tagPop.from', 'tagPopFrom');
  curve('tagPop.easing', 'tagPopCurve');
  t.documentedExact(
    'motion.tagPop.delay',
    'with fx_ice shatter frame 48 (0 ms into the segment)',
    reason:
        'the pop starts with fx_ice\'s `shatter` marker (a test pins '
        'frame 48)',
  );
  ms('rowOfFive.duration', 'rowOfFiveMs');
  curve('rowOfFive.easing', 'rowOfFiveCurve');
  t.documentedExact(
    'motion.rowOfFive.then',
    'ui_extra_slot starts',
    reason: 'the pad pops in after the re-pitch (lane B)',
  );
  t.documented(r'motion.tapFeedback.$note', reason: 'the design item id');
  n('tapFeedback.emptyStand.dip', 'tapDip');
  ms('tapFeedback.emptyStand.ms', 'tapDipMs');
  t.documentedExact(
    'motion.tapFeedback.emptyStand.haptic',
    'light',
    reason: 'HapticsService.light (lane B)',
  );
  n('tapFeedback.lockedCase.padlockScale', 'padlockPingScale');
  ms('tapFeedback.lockedCase.ms', 'padlockPingMs');
  n('tapFeedback.iced.counterScale', 'iceBumpScale');
  ms('tapFeedback.iced.ms', 'iceBumpMs');
  t.documented(r'motion.dragHover.$note', reason: 'the design item id');
  final hover = t.string(
    'motion.dragHover.validTarget',
    symbol: '$m.dragHoverGlowOpacity',
  );
  final hm = RegExp(r'^fx_select_glow at (\d+) %$').firstMatch(hover);
  if (hm == null || lottieContractOf('fx_select_glow') == null) {
    throw TokenFormatException('motion.dragHover.validTarget', 'unexpected');
  }
  c.add(
    'dragHoverGlowOpacity',
    doubleLiteral(int.parse(hm[1]!) / 100),
    doc: 'A valid drop target under a drag: "$hover".',
  );
  t.documentedExact(
    'motion.dragHover.invalidTarget',
    'none',
    reason: 'an invalid target shows nothing (lane B)',
  );
  t.documented(r'motion.extraSlot.$note', reason: 'the design item ids');
  ms('extraSlot.stopUnderDollMs', 'extraSlotStopUnderDollMs');
  i('extraSlot.restFrame', 'extraSlotRestFrame');
  return c;
}
