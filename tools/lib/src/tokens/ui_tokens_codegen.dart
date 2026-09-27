import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/sound_files.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Emits `apps/game/lib/core/ui/tokens/ui_tokens.gen.dart`: app colors,
/// gradients, type, radii, spacing, shadows, HUD/booster/nav layout, UI
/// motion and sound.
String uiTokensSource(TokenReader t, {required String header}) {
  final classes = [
    _info(t),
    _colors(t),
    _gradients(t),
    _fonts(t),
    _textStyles(t),
    _radii(t),
    _spacing(t),
    _shadows(t),
    _hud(t),
    _boosterBar(t),
    _bottomNav(t),
    _uiMotion(t),
    _sound(t),
  ];
  t.documentedTree(
    'haptics',
    reason: 'haptic patterns are hand-written in the HapticsService (M2)',
  );
  return [
    header,
    "import 'package:flutter/animation.dart' show Cubic;",
    "import 'package:flutter/painting.dart';",
    "import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';",
    '',
    ...classes.map((c) => '${c.build()}\n'),
  ].join('\n');
}

ConstClass _info(TokenReader t) {
  final c = ConstClass(
    'UiTokensInfo',
    'Which design/tokens.json these UI tokens were generated from.',
  );
  c.add(
    'version',
    '${t.integer('meta.version', symbol: 'UiTokensInfo.version')}',
    doc: 'tokens.json `meta.version`.',
  );
  return c;
}

ConstClass _colors(TokenReader t) {
  const name = 'AppColorTokens';
  final c = ConstClass(name, 'App colors (tokens.json `color`).');
  for (final key in t.keys('color')) {
    final member = memberName(key);
    final value = t.string('color.$key', symbol: '$name.$member');
    c.add(member, colorLiteral(parseCssColor(value)), doc: '`$value`.');
  }
  return c;
}

ConstClass _gradients(TokenReader t) {
  const name = 'AppGradientTokens';
  final c = ConstClass(
    name,
    'Gradients (tokens.json `gradient`). CSS angles map to Alignment so the '
    'gradient line reaches the corners of a square box, like CSS; a '
    'radial gradient uses the CSS default farthest-corner radius.',
  );
  for (final key in t.keys('gradient')) {
    final base = 'gradient.$key';
    final member = memberName(key);
    final symbol = '$name.$member';
    final type = t.string('$base.type', symbol: symbol);
    final stops = [
      for (final s in t.strings('$base.stops', symbol: symbol))
        parseGradientStop(s),
    ];
    final positions = resolveStopPositions([for (final s in stops) s.position]);
    final colors = '[${stops.map((s) => colorLiteral(s.color)).join(', ')}]';
    final allImplicit = stops.every((s) => s.position is ImplicitStop);
    final hasPx = positions.any((p) => p is PxStop);
    String fractionList() =>
        '[${positions.map((p) {
          if (p is! FractionStop) {
            throw TokenFormatException('$base.stops', 'px stops need a linear gradient');
          }
          return doubleLiteral(p.fraction);
        }).join(', ')}]';

    final extras = t.keys(base).toSet().difference({'type', 'angle', 'stops'});
    switch (type) {
      case 'linear':
        final angle = t.number('$base.angle', symbol: symbol);
        final a = cssAngleToAlignment(angle);
        final begin = alignmentLiteral(a.beginX, a.beginY);
        final end = alignmentLiteral(a.endX, a.endY);
        if (hasPx) {
          final tokenStops = positions.map(
            (p) => switch (p) {
              FractionStop(:final fraction) =>
                'TokenStop.fraction(${doubleLiteral(fraction)})',
              PxStop(:final px) => 'TokenStop.px(${doubleLiteral(px)})',
              ImplicitStop() => throw StateError('unresolved'),
            },
          );
          c.add(
            member,
            'PxLinearGradient(begin: $begin, end: $end, colors: $colors, '
            'stops: [${tokenStops.join(', ')}])',
            doc:
                '${angle}deg, stops ${t.strings('$base.stops', symbol: symbol)}. '
                'Has a px stop: call `resolve(extent)`.',
          );
        } else {
          c.add(
            member,
            'LinearGradient(begin: $begin, end: $end, colors: $colors'
            '${allImplicit ? '' : ', stops: ${fractionList()}'})',
            doc: '${angle}deg.',
          );
        }
      case 'radial':
        extras.remove('center');
        final center = t.numbers('$base.center', symbol: symbol, length: 2);
        final cx = center[0].toDouble();
        final cy = center[1].toDouble();
        if (cx < 0 || cx > 1 || cy < 0 || cy > 1) {
          throw TokenFormatException('$base.center', 'fractions 0–1 expected');
        }
        final radius = farthestCornerRadius(cx, cy);
        c.add(
          member,
          'RadialGradient(center: '
          '${alignmentLiteral(_round(cx * 2 - 1), _round(cy * 2 - 1))}, '
          'radius: ${doubleLiteral(radius)}, colors: $colors'
          '${allImplicit ? '' : ', stops: ${fractionList()}'})',
          doc: 'Radial from ($cx, $cy) of the box, farthest-corner.',
        );
      default:
        throw TokenFormatException('$base.type', 'unknown type "$type"');
    }
    for (final extra in extras) {
      final path = '$base.$extra';
      if (extra == 'overlay') {
        final value = t.string(path, symbol: '$name.${member}Grain');
        final m = RegExp(
          r'^repeating (vertical|horizontal) grain (\S+) (\d+(?:\.\d+)?)px '
          r'every (\d+(?:\.\d+)?)px$',
        ).firstMatch(value);
        if (m == null) throw TokenFormatException(path, 'unexpected wording');
        c.add(
          '${member}Grain',
          'WoodGrainToken(color: ${colorLiteral(parseCssColor(m[2]!))}, '
              'lineWidth: ${doubleLiteral(num.parse(m[3]!))}, '
              'spacing: ${doubleLiteral(num.parse(m[4]!))}, '
              'vertical: ${m[1] == 'vertical'})',
          doc: '"$value".',
        );
      } else if (extra == 'stripes') {
        final value = t.string(path, symbol: '$name.${member}Stripes');
        final m = RegExp(
          r'^(-?\d+)deg (\S+) (\d+(?:\.\d+)?)px on / (\d+(?:\.\d+)?)px off$',
        ).firstMatch(value);
        if (m == null) throw TokenFormatException(path, 'unexpected wording');
        c.add(
          '${member}Stripes',
          'TokenStripes(angleDeg: ${doubleLiteral(num.parse(m[1]!))}, '
              'color: ${colorLiteral(parseCssColor(m[2]!))}, '
              'onPx: ${doubleLiteral(num.parse(m[3]!))}, '
              'offPx: ${doubleLiteral(num.parse(m[4]!))})',
          doc: '"$value".',
        );
      } else {
        throw TokenFormatException(path, 'unknown gradient field');
      }
    }
  }
  return c;
}

ConstClass _fonts(TokenReader t) {
  const name = 'AppFontTokens';
  final c = ConstClass(
    name,
    'Font families and weights (tokens.json `font`). The TTFs are bundled '
    'in assets/fonts (tools/fonts/build_fonts.sh); icons use the bundled '
    '`NestySymbols` subset of Material Symbols Rounded.',
  );
  for (final role in const ['display', 'body']) {
    final family = t.string('font.$role.family', symbol: '$name.${role}Family');
    c.add('${role}Family', stringLiteral(family));
    final weights = t.numbers(
      'font.$role.weights',
      symbol: '$name.${role}Weights',
    );
    c.add(
      '${role}Weights',
      '[${weights.map((w) => _fontWeight(w, 'font.$role.weights')).join(', ')}]',
      type: 'List<FontWeight>',
      doc: 'The bundled weights.',
    );
    t.documented('font.$role.source', reason: 'licence note; see OFL.txt');
  }
  c.add(
    'iconDesignFamily',
    stringLiteral(
      t.string('font.icon.family', symbol: '$name.iconDesignFamily'),
    ),
    doc: 'The upstream icon font the bundled subset is cut from.',
  );
  final settings = t.string('font.icon.settings', symbol: '$name.iconFill');
  final axes = <String, double>{};
  for (final part in settings.split(',')) {
    final m = RegExp(
      r'^\s*(FILL|wght|GRAD|opsz) (-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(part);
    if (m == null) {
      throw TokenFormatException('font.icon.settings', 'unexpected "$part"');
    }
    axes[m[1]!] = double.parse(m[2]!);
  }
  if (axes.length != 4) {
    throw TokenFormatException(
      'font.icon.settings',
      'needs FILL/wght/GRAD/opsz',
    );
  }
  for (final (axis, member) in const [
    ('FILL', 'iconFill'),
    ('wght', 'iconWeight'),
    ('GRAD', 'iconGrade'),
    ('opsz', 'iconOpticalSize'),
  ]) {
    t.string('font.icon.settings', symbol: '$name.$member');
    c.add(member, doubleLiteral(axes[axis]!), doc: 'Icon axis $axis.');
  }
  t.documented('font.icon.source', reason: 'licence note; see LICENSE');
  t.documentedTree(
    'font.mono',
    reason: 'design annotations only, not in the app',
  );
  return c;
}

String _fontWeight(num weight, String path) {
  if (weight is! int || weight < 100 || weight > 900 || weight % 100 != 0) {
    throw TokenFormatException(path, 'weight $weight is not 100…900');
  }
  return 'FontWeight.w$weight';
}

ConstClass _textStyles(TokenReader t) {
  const name = 'AppTextStyleTokens';
  final c = ConstClass(
    name,
    'Text styles (tokens.json `fontSize`). `height` is lineHeight ÷ size '
    'with even leading, like CSS line-height.',
  );
  const allowed = {
    'family',
    'size',
    'lineHeight',
    'weight',
    'letterSpacing',
    'tabular',
  };
  for (final key in t.keys('fontSize')) {
    final base = 'fontSize.$key';
    final member = memberName(key);
    final symbol = '$name.$member';
    for (final field in t.keys(base)) {
      if (!allowed.contains(field)) {
        throw TokenFormatException('$base.$field', 'unknown text style field');
      }
    }
    final role = t.string('$base.family', symbol: symbol);
    if (role != 'display' && role != 'body') {
      throw TokenFormatException('$base.family', 'expected display or body');
    }
    // Peek (no ledger entry): font.<role>.* is accounted for by _fonts.
    final family = t.peek('font.$role.family');
    final weights = t.peek('font.$role.weights');
    if (family is! String || weights is! List<Object?>) {
      throw TokenFormatException('font.$role', 'needs family and weights');
    }
    final size = t.number('$base.size', symbol: symbol);
    final lineHeight = t.number('$base.lineHeight', symbol: symbol);
    final weight = t.integer('$base.weight', symbol: symbol);
    if (!weights.contains(weight)) {
      throw TokenFormatException(
        '$base.weight',
        '$weight is not a bundled $family weight ($weights)',
      );
    }
    final args = [
      'fontFamily: ${stringLiteral(family)}',
      'fontSize: ${doubleLiteral(size)}',
      'height: ${doubleLiteral(lineHeight / size)}',
      'leadingDistribution: TextLeadingDistribution.even',
      'fontWeight: ${_fontWeight(weight, '$base.weight')}',
    ];
    if (t.has('$base.letterSpacing')) {
      args.add(
        'letterSpacing: ${doubleLiteral(t.number('$base.letterSpacing', symbol: symbol))}',
      );
    }
    if (t.has('$base.tabular') && t.boolean('$base.tabular', symbol: symbol)) {
      args.add('fontFeatures: [FontFeature.tabularFigures()]');
    }
    c.add(
      member,
      'TextStyle(${args.join(', ')})',
      doc: '$family $size/$lineHeight/$weight.',
    );
  }
  return c;
}

ConstClass _radii(TokenReader t) {
  const name = 'AppRadii';
  final c = ConstClass(name, 'Corner radii (tokens.json `radius`).');
  for (final key in t.keys('radius')) {
    final member = memberName(key);
    c.add(
      member,
      doubleLiteral(t.number('radius.$key', symbol: '$name.$member')),
      doc: key == member ? null : 'tokens.json `radius.$key`.',
    );
  }
  return c;
}

ConstClass _spacing(TokenReader t) {
  const name = 'AppSpacing';
  final c = ConstClass(name, 'The 4-pt spacing scale (tokens.json `spacing`).');
  for (final key in t.keys('spacing')) {
    final member = memberName(key);
    c.add(
      member,
      doubleLiteral(t.number('spacing.$key', symbol: '$name.$member')),
    );
  }
  return c;
}

ConstClass _shadows(TokenReader t) {
  const name = 'AppShadowTokens';
  final c = ConstClass(
    name,
    'Shadow stacks (tokens.json `shadow`), CSS order: the first layer paints '
    'on top. Inset layers are the 2 px top highlight of tactile surfaces.',
  );
  for (final key in t.keys('shadow')) {
    final path = 'shadow.$key';
    if (key == 'pressedTravel') {
      final value = t.string(path, symbol: '$name.pressedEdge');
      final m = RegExp(
        r'^buttons move down by \(edge − (\d+)\) px and the solid edge '
        r'shrinks to (\d+) px, (\d+) ms$',
      ).firstMatch(value);
      if (m == null || m[1] != m[2]) {
        throw TokenFormatException(path, 'unexpected wording');
      }
      t.string(path, symbol: '$name.pressTravelMs');
      c.add(
        'pressedEdge',
        doubleLiteral(num.parse(m[2]!)),
        doc: 'Pressed: "$value".',
      );
      c.add('pressTravelMs', m[3]!, type: 'int');
      continue;
    }
    final member = memberName(key);
    final layers = parseBoxShadowList(t.string(path, symbol: '$name.$member'));
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
    c.add(
      member,
      '[${literals.join(', ')}]',
      type: 'List<NestyShadow>',
      doc: '`${t.peek(path)}`.',
    );
  }
  return c;
}

ConstClass _hud(TokenReader t) {
  const name = 'HudTokens';
  const p = 'layout.hud';
  final c = ConstClass(
    name,
    'Gameplay HUD placement on the 390×844 reference (tokens.json `$p`).',
  );
  void n(String path, String member) => c.add(
    member,
    doubleLiteral(t.number('$p.$path', symbol: '$name.$member')),
  );
  n('top', 'top');
  n('side', 'side');
  final pause = t.numbers(
    '$p.pauseButton',
    symbol: '$name.pauseButtonSize',
    length: 2,
  );
  c.add('pauseButtonSize', sizeLiteral(pause[0], pause[1]));
  n('levelPillHeight', 'levelPillHeight');
  n('coinPillHeight', 'coinPillHeight');
  n('familyCounter.top', 'familyCounterTop');
  n('familyCounter.height', 'familyCounterHeight');
  return c;
}

ConstClass _boosterBar(TokenReader t) {
  const name = 'BoosterBarTokens';
  const p = 'layout.boosterBar';
  final c = ConstClass(name, 'Booster bar (tokens.json `$p`).');
  void n(String path, String member) => c.add(
    member,
    doubleLiteral(t.number('$p.$path', symbol: '$name.$member')),
  );
  n('top', 'top');
  final button = t.numbers(
    '$p.buttonSize',
    symbol: '$name.buttonSize',
    length: 2,
  );
  c.add('buttonSize', sizeLiteral(button[0], button[1]));
  n('gap', 'gap');
  n('left', 'left');
  n('topInset', 'topInset');
  return c;
}

ConstClass _bottomNav(TokenReader t) {
  const name = 'BottomNavTokens';
  const p = 'layout.bottomNav';
  final c = ConstClass(name, 'Home bottom navigation (tokens.json `$p`).');
  c.add('top', doubleLiteral(t.number('$p.top', symbol: '$name.top')));
  final active = t.numbers(
    '$p.activeItem',
    symbol: '$name.activeItemSize',
    length: 2,
  );
  c.add('activeItemSize', sizeLiteral(active[0], active[1]));
  final item = t.numbers('$p.item', symbol: '$name.itemSize', length: 2);
  c.add('itemSize', sizeLiteral(item[0], item[1]));
  c.add(
    'lift',
    doubleLiteral(t.number('$p.lift', symbol: '$name.lift')),
    doc: 'Active item y offset (negative = up).',
  );
  return c;
}

ConstClass _uiMotion(TokenReader t) {
  const name = 'UiMotionTokens';
  final c = ConstClass(
    name,
    'UI (non-board) motion: durations in ms and the design easings '
    '(tokens.json `motion.ui`, `motion.easing`, `motion.reducedMotion`).',
  );
  for (final key in t.keys('motion.ui')) {
    final member = '${memberName(key)}Ms';
    c.add(member, '${t.integer('motion.ui.$key', symbol: '$name.$member')}');
  }
  for (final key in t.keys('motion.easing')) {
    final member = 'curve${key[0].toUpperCase()}${key.substring(1)}';
    final value = t.string('motion.easing.$key', symbol: '$name.$member');
    c.add(member, cubicLiteral(parseCubicBezier(value)), doc: '`$value`.');
  }
  c.add(
    'reducedMotionDurationScale',
    doubleLiteral(
      t.number(
        'motion.reducedMotion.durationScale',
        symbol: '$name.reducedMotionDurationScale',
      ),
    ),
  );
  return c;
}

ConstClass _sound(TokenReader t) {
  const name = 'SoundTokens';
  final c = ConstClass(
    name,
    'Sound events, music and mix (tokens.json `sound`, spec §11.3, '
    'design/audio/AUDIO.md). '
    '${t.documented('sound.format', reason: 'prose, in the class doc')}',
  );
  final maxSteps = t.integer(
    'motion.combo.maxSteps',
    symbol: '$name.comboMaxSteps',
  );
  final sfx = <String>{};
  final jingles = <String>{};
  for (final key in t.keys('sound.events')) {
    final path = 'sound.events.$key';
    final member = memberName(key);
    final value = t.string(path, symbol: '$name.$member');
    final event = parseSoundEvent(value, maxSteps: maxSteps);
    if (event == null) throw TokenFormatException(path, 'unexpected "$value"');
    final jingle = event.files.any(isJingleFile);
    if (jingle && event.pick != SoundEventPick.single) {
      throw TokenFormatException(
        path,
        'a jingle ($jingleFilePrefix*) plays alone, never in a random or '
        'combo cue',
      );
    }
    (jingle ? jingles : sfx).addAll(event.files);
    final files = '[${event.files.map(stringLiteral).join(', ')}]';
    c.add(
      member,
      switch (event.pick) {
        SoundEventPick.single => 'SoundCue($files)',
        SoundEventPick.random => 'SoundCue($files, pick: SoundPick.random)',
        SoundEventPick.comboStep =>
          'SoundCue($files, pick: SoundPick.comboStep)',
      },
      doc: jingle
          ? '`$value`: a jingle (OGG, in [jingleFiles]; the bus is '
                '[jingleBus]).'
          : '`$value`.',
    );
  }
  c.add(
    'allFiles',
    '[${(sfx.toList()..sort()).map(stringLiteral).join(', ')}]',
    type: 'List<String>',
    doc:
        'Every SFX file base name the events use, sorted (for preloading '
        'and the asset manifest test): `assets/audio/<name>.wav`. The '
        'jingles are [jingleFiles] and the music loops [musicFiles].',
  );
  c.add(
    'jingleFiles',
    '[${(jingles.toList()..sort()).map(stringLiteral).join(', ')}]',
    type: 'List<String>',
    doc:
        'Every jingle the events use (the `$jingleFilePrefix*` files), '
        'sorted: one-shots at `assets/audio/<name>.ogg`, loaded into memory '
        'like the SFX (AUDIO.md "Jingles").',
  );
  final rule = t.documented(
    'sound.clackPitch.rule',
    reason: 'formula prose; the semitone table is emitted',
  );
  final semitones = <String>[];
  var expected = 1;
  for (final key in t.keys('sound.clackPitch.semitonesBySize')) {
    if (int.tryParse(key) != expected++) {
      throw TokenFormatException(
        'sound.clackPitch.semitonesBySize.$key',
        'sizes must be 1, 2, 3, …',
      );
    }
    semitones.add(
      '$key: ${t.integer('sound.clackPitch.semitonesBySize.$key', symbol: '$name.clackSemitonesBySize')}',
    );
  }
  c.add(
    'clackSemitonesBySize',
    '{${semitones.join(', ')}}',
    type: 'Map<int, int>',
    doc: 'Clack pitch per doll size: $rule.',
  );
  c.add(
    'clackBakedSemitones',
    '${t.integer('sound.clackPitch.bakedSemitones', symbol: '$name.clackBakedSemitones')}',
    doc:
        'The pitch the clack files are recorded at, in semitones from the '
        'size-3.5 clack (tokens.json `sound.clackPitch.bakedSemitones`): the '
        'playback rate is 2^((clackSemitonesBySize[size] − this) / 12).',
  );
  final notes = t.strings('sound.comboNotes', symbol: '$name.comboNotes');
  if (notes.length != maxSteps) {
    throw TokenFormatException('sound.comboNotes', 'needs $maxSteps notes');
  }
  c.add(
    'comboNotes',
    '[${notes.map(stringLiteral).join(', ')}]',
    type: 'List<String>',
  );
  c.add(
    'comboWindowMs',
    '${t.integer('motion.combo.windowMs', symbol: '$name.comboWindowMs')}',
    doc: 'Sets completed within this window step up the chime.',
  );
  c.add('comboMaxSteps', '$maxSteps');
  _music(t, c);
  c.add(
    'sfxVolumeDefault',
    doubleLiteral(
      t.number('sound.mix.sfxDefault', symbol: '$name.sfxVolumeDefault'),
    ),
  );
  c.add(
    'musicVolumeDefault',
    doubleLiteral(
      t.number('sound.mix.musicDefault', symbol: '$name.musicVolumeDefault'),
    ),
  );
  c.add(
    'separateVolumes',
    '${t.boolean('sound.mix.separateVolumes', symbol: '$name.separateVolumes')}',
  );
  final bus = t.string('sound.mix.jingleBus', symbol: '$name.jingleBus');
  if (bus != 'sfx' && bus != 'music') {
    throw TokenFormatException('sound.mix.jingleBus', 'expected sfx or music');
  }
  c.add(
    'jingleBus',
    stringLiteral(bus),
    doc:
        'The bus the jingles play on (tokens.json `sound.mix.jingleBus`): '
        '`sfx` follows the Sound toggle and the SFX volume, `music` the '
        'Music ones. The codegen accepts only these two.',
  );
  return c;
}

/// `sound.music`, `sound.musicFadeMs` and `sound.musicDuck` (AUDIO.md
/// "Music loops", "Music rules").
void _music(TokenReader t, ConstClass c) {
  const name = 'SoundTokens';
  const fields = {
    'file',
    'seconds',
    'frames',
    'bpm',
    'meter',
    'key',
    'screens',
  };
  final files = <String>[];
  for (final key in t.keys('sound.music')) {
    final base = 'sound.music.$key';
    final prefix = 'music${_capitalized(memberName(key))}';
    for (final field in t.keys(base)) {
      if (!fields.contains(field)) {
        throw TokenFormatException('$base.$field', 'unknown music field');
      }
    }
    final file = t.string('$base.file', symbol: '$name.$prefix');
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(file)) {
      throw TokenFormatException('$base.file', 'expected a file base name');
    }
    files.add(file);
    final screens = t.documented(
      '$base.screens',
      reason: 'prose: the screens that play it (AUDIO.md "Music rules")',
    );
    c.add(
      prefix,
      stringLiteral(file),
      doc:
          'The $key loop, `assets/audio/$file.ogg` (streamed; the whole file '
          'loops). Plays on: $screens.',
    );
    final seconds = t.number('$base.seconds', symbol: '$name.${prefix}Seconds');
    final frames = t.integer('$base.frames', symbol: '$name.${prefix}Frames');
    if (frames <= 0 || (frames / soundSampleRate - seconds).abs() > 0.001) {
      throw TokenFormatException(
        '$base.frames',
        '$frames frames is not $seconds s at $soundSampleRate Hz',
      );
    }
    c.add(
      '${prefix}Seconds',
      doubleLiteral(seconds),
      doc: 'The loop length in seconds, rounded (the frames are exact).',
    );
    c.add(
      '${prefix}Frames',
      '$frames',
      doc: 'The loop length in frames at $soundSampleRate Hz.',
    );
    c.add(
      '${prefix}Bpm',
      doubleLiteral(t.number('$base.bpm', symbol: '$name.${prefix}Bpm')),
      doc: 'Tempo; with the meter and key, AUDIO.md "Music loops".',
    );
    final meter = t.string('$base.meter', symbol: '$name.${prefix}Meter');
    if (!RegExp(r'^\d+/\d+$').hasMatch(meter)) {
      throw TokenFormatException('$base.meter', 'expected "N/M"');
    }
    c.add('${prefix}Meter', stringLiteral(meter));
    final musicKey = t.string('$base.key', symbol: '$name.${prefix}Key');
    if (!RegExp(r'^[A-G][#b]? (major|minor)$').hasMatch(musicKey)) {
      throw TokenFormatException('$base.key', 'expected "<note> major|minor"');
    }
    c.add('${prefix}Key', stringLiteral(musicKey));
  }
  c.add(
    'musicFiles',
    '[${(files.toList()..sort()).map(stringLiteral).join(', ')}]',
    type: 'List<String>',
    doc: 'Every music loop, sorted: `assets/audio/<name>.ogg`.',
  );
  for (final key in t.keys('sound.musicFadeMs')) {
    final member = 'musicFade${_capitalized(memberName(key))}Ms';
    final ms = t.integer('sound.musicFadeMs.$key', symbol: '$name.$member');
    if (ms < 0) {
      throw TokenFormatException('sound.musicFadeMs.$key', 'negative');
    }
    c.add(member, '$ms', doc: 'tokens.json `sound.musicFadeMs.$key`.');
  }
  final ducks = <String>[];
  for (final key in t.keys('sound.musicDuck')) {
    final path = 'sound.musicDuck.$key';
    final member = 'musicDuck${_capitalized(memberName(key))}';
    final factor = t.number(path, symbol: '$name.$member');
    t.number(path, symbol: '$name.musicDuckFactors');
    if (factor <= 0 || factor > 1) {
      throw TokenFormatException(path, 'a duck factor is in (0, 1]');
    }
    c.add(
      member,
      doubleLiteral(factor),
      doc: 'Music volume × this while ducked for $key (tokens.json `$path`).',
    );
    ducks.add('${stringLiteral(key)}: ${doubleLiteral(factor)}');
  }
  c.add(
    'musicDuckFactors',
    '{${ducks.join(', ')}}',
    type: 'Map<String, double>',
    doc:
        'Every duck factor by reason (the `sound.musicDuck` keys). Ducks '
        "don't stack: the lowest active factor wins (AUDIO.md).",
  );
}

String _capitalized(String member) =>
    '${member[0].toUpperCase()}${member.substring(1)}';

double _round(double v) {
  final r = (v * 10000).round() / 10000;
  return r == 0 ? 0 : r;
}
