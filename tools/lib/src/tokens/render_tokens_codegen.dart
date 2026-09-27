import 'package:nesty_core/nesty_core.dart';
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
    _motion(t),
  ];
  return [
    header,
    "import 'dart:ui' show Color, Offset, Size;",
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
  for (final key in t.keys('$lb.planksY')) {
    final shelves = _shelfCount(key, '$lb.planksY');
    final ys = t.numbers(
      '$lb.planksY.$key',
      symbol: '$b.plankTopsByShelfCount',
    );
    if (ys.length != shelves) {
      throw TokenFormatException('$lb.planksY.$key', 'needs $shelves planks');
    }
    planks.add('$shelves: [${ys.map(doubleLiteral).join(', ')}]');
  }
  c.add(
    'plankTopsByShelfCount',
    '{${planks.join(', ')}}',
    type: 'Map<int, List<double>>',
    doc: 'Plank top y per shelf count (tokens.json `$lb.planksY`).',
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
  size('$lb.iceOverlay', 'iceOverlaySize');
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
    final shelves = _shelfCount(key, '$ld.slotMaxDollHeight');
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

int _shelfCount(String key, String path) {
  final m = RegExp(r'^(\d+)shelves$').firstMatch(key);
  if (m == null) throw TokenFormatException('$path.$key', 'expected Nshelves');
  return int.parse(m[1]!);
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
  return c;
}
