// What tokens v3 (m7-3) adds to ui_tokens.gen.dart besides the colours,
// the `versus` gradient and the family counter: the per-screen sections
// (the generic emitter), the M7 UI motion, the icon uses, and the rule
// values the design repeats, which are documentation only (phase 4
// architecture §1.1 policy 2: rules never come from tokens; the app's
// `rule_tokens_test` pins each to its source of truth).
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/screen_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Every v3 UI class, in file order.
List<ConstClass> uiV3Classes(TokenReader t) {
  _documentRules(t);
  return [
    for (final MapEntry(key: path, value: name) in screenTokenSections.entries)
      switch (path) {
        'shop' => _shop(t),
        // The v3 counts and timings are ChestMotionTokens'.
        'motion.chest.collect' => screenTokens(
          t,
          path,
          className: name,
          skip: {
            for (final key in const [
              'coinFlightMs',
              'coinStaggerMs',
              'coins',
              'hintFlightMs',
              'targetBump',
              'targetBumpMs',
            ])
              '$path.$key',
          },
        ),
        _ => screenTokens(t, path, className: name),
      },
    _stars(t),
    _chest(t),
    _rival(t),
    _toast(t),
    _chaptersFadeIn(t),
    _purchase(t),
    _icons(t),
    _winRibbon(t),
  ];
}

/// `versus.*` and `chest.*`: the owner's rules, repeated by the design.
void _documentRules(TokenReader t) {
  // Every `versus` leaf but the ribbon's colours (tokens v4, m7-4 4.3),
  // which `WinRibbonTokens` emits.
  for (final key in t.keys('versus')) {
    if (key == 'ribbon') continue;
    t.documentedTree(
      'versus.$key',
      reason:
          'rules, never read from tokens: RemoteConfigKeys (race unlock and '
          'rewards), RaceRules and the bloc\'s race mode (spec-prop §7.7, '
          'D93); rule_tokens_test pins the numbers',
    );
  }
  // Every `chest` leaf but the +1 slot chip's look (tokens v5, m7-5), which
  // `ChestSlotChipTokens` emits.
  for (final key in t.keys('chest')) {
    if (key == 'slotChip') continue;
    t.documentedTree(
      'chest.$key',
      reason:
          'rules, never read from tokens: MilestoneChest and '
          'RemoteConfigKeys (chest_coins, chest_hints, streak7_reward; '
          'spec-prop §7.3, §7.4); rule_tokens_test pins the numbers',
    );
  }
}

ConstClass _shop(TokenReader t) {
  const p = 'shop';
  final c = screenTokens(
    t,
    p,
    className: 'ShopTokens',
    skip: const {'shop.skins'},
  );
  final entries = <String>[];
  final tags = <String>[];
  for (final id in t.keys('$p.skins')) {
    final base = '$p.skins.$id';
    const symbol = 'ShopTokens.skins';
    final keys = t.keys(base).join(',');
    if (keys != 'card,panel,edge,caption' &&
        keys != 'card,panel,edge,caption,tag') {
      throw TokenFormatException(
        base,
        'expected card, panel, edge, caption (and a tag)',
      );
    }
    if (keys.endsWith(',tag')) {
      // Tokens v4 (m7-4 4.11): a skin whose caption needs its own chip.
      if (t.keys('$base.tag').join(',') != 'face,text,note') {
        throw TokenFormatException('$base.tag', 'expected face, text, note');
      }
      t.documented('$base.tag.note', reason: 'the contrast, a design note');
      tags.add(
        '${stringLiteral(id)}: (face: '
        '${colorLiteral(parseCssColor(t.string('$base.tag.face', symbol: 'ShopTokens.skinTags')))}, '
        'text: ${colorLiteral(parseCssColor(t.string('$base.tag.text', symbol: 'ShopTokens.skinTags')))})',
      );
    }
    String colors(String key) {
      final list = t.strings('$base.$key', symbol: symbol);
      if (list.length != 2) {
        throw TokenFormatException('$base.$key', 'a card is two colours');
      }
      return '[${list.map((v) => colorLiteral(parseCssColor(v))).join(', ')}]';
    }

    String color(String key) =>
        colorLiteral(parseCssColor(t.string('$base.$key', symbol: symbol)));
    entries.add(
      '${stringLiteral(id)}: ShopSkinColors(card: ${colors('card')}, '
      'panel: ${colors('panel')}, edge: ${color('edge')}, '
      'caption: ${color('caption')})',
    );
  }
  c.add(
    'skins',
    '{${entries.join(', ')}}',
    type: 'Map<String, ShopSkinColors>',
    doc:
        'Each skin\'s Shop card and detail panel colours, by catalog skin id '
        '(tokens.json `$p.skins`).',
  );
  c.add(
    'skinTags',
    '{${tags.join(', ')}}',
    type: 'Map<String, ({Color face, Color text})>',
    doc:
        'The caption chip of a skin whose caption would not read on its '
        'card (m7-4 4.11: Space\'s white chip), by catalog skin id; other '
        'skins keep the caption colour.',
  );
  return c;
}

void Function(String, String) _ints(TokenReader t, ConstClass c, String p) =>
    (key, member) => c.add(
      member,
      '${t.integer('$p.$key', symbol: '${c.name}.$member')}',
      doc: 'tokens.json `$p.$key`.',
    );

void Function(String, String) _doubles(TokenReader t, ConstClass c, String p) =>
    (key, member) => c.add(
      member,
      doubleLiteral(t.number('$p.$key', symbol: '${c.name}.$member')),
      doc: 'tokens.json `$p.$key`.',
    );

ConstClass _stars(TokenReader t) {
  const p = 'motion.stars';
  final c = ConstClass(
    'StarMotionTokens',
    'The win card\'s star reveal, `ui_stars` (tokens.json `$p`). It starts '
        'when ${t.documentedExact('$p.startAfter', 'the coin count-up ends', reason: 'the win card schedule (lane O)')}; '
        'haptics: ${t.documentedExact('$p.haptics', 'light per star, success after the flourish', reason: 'the win card schedule (lane O)')}. '
        'Reduce motion: ${t.documentedExact('$p.reducedMotion', 'show the last frame of star_n at once, no flourish; one star sound (the highest earned) and one light haptic', reason: 'Q146 as the design answers it (lane O)')}.',
  );
  t.documented('$p.\$note', reason: 'a design note');
  final ms = _ints(t, c, p);
  final n = _doubles(t, c, p);
  ms('startMs', 'startMs');
  ms('segmentFrames', 'segmentFrames');
  ms('perStarMs', 'perStarMs');
  n('popScale', 'popScale');
  final flourish = t.numbers(
    '$p.flourish',
    symbol: 'StarMotionTokens.flourishStartFrame',
    length: 2,
  );
  t.numbers('$p.flourish', symbol: 'StarMotionTokens.flourishEndFrame');
  if (flourish.any((v) => v is! int)) {
    throw TokenFormatException('$p.flourish', 'frames are integers');
  }
  c.add(
    'flourishStartFrame',
    '${flourish[0]}',
    doc: '`ui_stars`\'s `flourish` segment (a test pins it to the marker).',
  );
  c.add('flourishEndFrame', '${flourish[1]}');
  return c;
}

ConstClass _chest(TokenReader t) {
  const p = 'motion.chest';
  final c = ConstClass(
    'ChestMotionTokens',
    'The chest moment, `ui_chest` and its flights (tokens.json `$p`). Its '
        'segments are the file\'s markers (`fxSpecOf(FxId.uiChest)`). Reduce '
        'motion: ${t.documentedExact('$p.reducedMotion', '200 ms crossfade closed → open, no wiggle, no flights; the chips appear together', reason: 'ChestRewardSequence (lane O)')}.',
  );
  t.documentedTree(
    '$p.segments',
    reason: 'ui_chest\'s markers, read from FxSpec (a test pins them)',
  );
  t.documented(
    '$p.rays',
    reason:
        'm7-4 4.7: ui_chest sways its own rays; the card draws none over the '
        'Lottie (lane O)',
  );
  final ms = _ints(t, c, p);
  final n = _doubles(t, c, p);
  ms('arriveMs', 'arriveMs');
  final idle = t.numbers(
    '$p.idle.scale',
    symbol: 'ChestMotionTokens.idleScaleFrom',
    length: 2,
  );
  t.numbers('$p.idle.scale', symbol: 'ChestMotionTokens.idleScaleTo');
  c.add('idleScaleFrom', doubleLiteral(idle[0]), doc: 'The idle breath …');
  c.add('idleScaleTo', doubleLiteral(idle[1]), doc: '… between these scales.');
  ms('idle.periodMs', 'idlePeriodMs');
  ms('idle.lockGlintEveryMs', 'idleLockGlintEveryMs');
  ms('wiggleMs', 'wiggleMs');
  ms('burstMs', 'burstMs');
  ms('chipStaggerMs', 'chipStaggerMs');
  ms('rewardJingleAfterOpenMs', 'rewardJingleAfterOpenMs');
  ms('collect.coinFlightMs', 'collectCoinFlightMs');
  ms('collect.coinStaggerMs', 'collectCoinStaggerMs');
  ms('collect.coins', 'collectCoins');
  ms('collect.hintFlightMs', 'collectHintFlightMs');
  n('collect.targetBump', 'collectTargetBump');
  ms('collect.targetBumpMs', 'collectTargetBumpMs');
  return c;
}

ConstClass _rival(TokenReader t) {
  const dot = 'motion.rivalDot';
  const move = 'motion.rivalMove';
  final c = ConstClass(
    'RivalMotionTokens',
    'The rival strip (tokens.json `$dot`, `$move`): a dot fills when the '
        'computer completes a family, and its portrait beats once per move '
        '(${t.documentedExact('$move.\$note', 'one beat per rival move; no sound, no haptic', reason: 'the rival strip (lane R)')}). '
        'Reduce motion: ${t.documentedExact('$move.reducedMotion', 'none', reason: 'the rival strip (lane R)')} beat.',
  );
  _ints(t, c, dot)('fillMs', 'dotFillMs');
  _doubles(t, c, dot)('bump', 'dotBump');
  final easing = t.string('$dot.easing', symbol: 'RivalMotionTokens.dotCurve');
  c.add('dotCurve', cubicLiteral(parseCubicBezier(easing)), doc: '`$easing`.');
  _doubles(t, c, move)('portraitScale', 'movePortraitScale');
  _ints(t, c, move)('ms', 'moveMs');
  return c;
}

ConstClass _toast(TokenReader t) {
  const p = 'motion.toast';
  final c = ConstClass(
    'ToastTokens',
    'The toast queue (tokens.json `$p`, '
        '${t.documented('$p.\$note', reason: 'the design item id')}; Q122, '
        'Q136): one at a time.',
  );
  _ints(t, c, p)('autoDismissMs', 'autoDismissMs');
  final queue = t.string('$p.queue', symbol: 'ToastTokens.gapMs');
  final m = RegExp(
    r'^one at a time, the next waits (\d+) ms after the first leaves$',
  ).firstMatch(queue);
  if (m == null) throw TokenFormatException('$p.queue', 'unexpected wording');
  c.add('gapMs', m[1]!, doc: '"$queue".');
  c.add(
    'leavesWithCard',
    '${t.boolean('$p.leavesWithCard', symbol: 'ToastTokens.leavesWithCard')}',
    doc: 'A result card\'s toasts leave with it.',
  );
  _doubles(t, c, p)('badgeToastTop', 'badgeToastTop');
  // Tokens v4 (m7-4 1.5).
  final appTop = t.string('$p.appTop', symbol: 'ToastTokens.appTopOffset');
  final m2 = RegExp(r'^safeTop ([+−]) (\d+)$').firstMatch(appTop);
  if (m2 == null) throw TokenFormatException('$p.appTop', 'unexpected wording');
  c.add(
    'appTopOffset',
    doubleLiteral((m2[1] == '−' ? -1 : 1) * num.parse(m2[2]!)),
    doc:
        'The app toast\'s motion top: the safe top + this (`$appTop`). '
        '`ToastLayoutTokens.appTopBelowSafeTop` is its resting place.',
  );
  for (final key in const ['relaxedOncePerLaunch', 'slotLimitOncePerLevel']) {
    c.add(
      key,
      '${t.boolean('$p.$key', symbol: 'ToastTokens.$key')}',
      doc: 'tokens.json `$p.$key`.',
    );
  }
  return c;
}

ConstClass _chaptersFadeIn(TokenReader t) {
  const p = 'motion.chaptersFadeIn';
  final c = ConstClass(
    'ChaptersMotionTokens',
    'Chapters\' rows fade in one after another (tokens.json `$p`). Reduce '
        'motion: ${t.documentedExact('$p.reducedMotion', 'none', reason: 'the Chapters list (lane M)')}.',
  );
  _ints(t, c, p)('staggerMs', 'staggerMs');
  _ints(t, c, p)('durationMs', 'durationMs');
  return c;
}

ConstClass _purchase(TokenReader t) {
  const p = 'motion.purchase';
  final c = ConstClass(
    'PurchaseMotionTokens',
    'A Shop purchase (tokens.json `$p`, '
        '${t.documented('$p.\$note', reason: 'the design item ids')}): the card '
        'comes in, `jingle_reward` plays at 0 and the balance counts up; the '
        'header balance ${t.documentedExact('$p.headerBalance', 'updates with the count-up', reason: 'the Shop header (lane M)')}.',
  );
  final jingle = t.documentedExact(
    '$p.jingle',
    'jingle_reward @0',
    reason: 'Jingle.reward at 0 ms (lane M)',
  );
  if (t.peek('sound.events.reward') != jingle.split(' ').first) {
    throw TokenFormatException('$p.jingle', 'is not sound.events.reward');
  }
  final ms = _ints(t, c, p);
  ms('cardInMs', 'cardInMs');
  ms('coinBurstAtMs', 'coinBurstAtMs');
  ms('countUpDelayMs', 'countUpDelayMs');
  ms('countUpMs', 'countUpMs');
  return c;
}

ConstClass _icons(TokenReader t) {
  const p = 'icons';
  final c = ConstClass(
    'IconTokens',
    'The glyph each M7 icon use draws (tokens.json `$p`: '
        '${t.documented('$p.\$note', reason: 'prose, in the class doc')}). '
        'Every glyph is in the bundled font (`NestyIcons.byName`; a test pins '
        'them); `IconUses` maps each use to its `IconData`.',
  );
  final glyph = RegExp(r'^[a-z0-9_]+$');
  final entries = <String>[];
  for (final key in t.keys(p)) {
    if (key.startsWith(r'$')) continue;
    final path = '$p.$key';
    final value = t.peek(path);
    if (value is! String) throw TokenFormatException(path, 'expected text');
    if (!glyph.hasMatch(value)) {
      t.documented(path, reason: 'art, not a glyph: $value');
      continue;
    }
    final member = memberName(key);
    c.add(
      member,
      stringLiteral(t.string(path, symbol: 'IconTokens.$member')),
      doc: 'The `$value` glyph.',
    );
    t.string(path, symbol: 'IconTokens.glyphs');
    entries.add('${stringLiteral(key)}: $member');
  }
  c.add(
    'glyphs',
    '{${entries.join(', ')}}',
    type: 'Map<String, String>',
    doc: 'Every glyph use, by its tokens.json key.',
  );
  return c;
}

/// `winRibbon` and `versus.ribbon` (tokens v4, m7-4 4.3, 4.15; LOTTIE.md
/// "Tint and width"): the ribbons' fill colours and the key paths that reach
/// them. The chapter ribbon's colours are each chapter's palette
/// (`ChapterPalette.accent`, `accentEdge`, `ribbonTail`, `ribbonFold`).
ConstClass _winRibbon(TokenReader t) {
  const name = 'WinRibbonTokens';
  final c = ConstClass(
    name,
    'The ribbons\' tints (tokens.json `winRibbon`, `versus.ribbon`): '
    '${t.documented('winRibbon.keyPaths.\$note', reason: 'prose, in the class doc')}. '
    '`ui_win_ribbon` is tinted [defaultColors] (as authored) or, on the '
    'race\'s result cards (9.4, 9.5), [versusColors].',
  );
  const fills = ['band', 'edge', 'tail', 'fold'];
  String colors(String base, String member) {
    for (final key in t.keys(base)) {
      if (!key.startsWith(r'$') &&
          !fills.contains(key) &&
          !(base == 'versus.ribbon' && (key == 'hi' || key == 'label'))) {
        throw TokenFormatException('$base.$key', 'unknown ribbon fill');
      }
    }
    final args = [
      for (final key in fills)
        '$key: ${colorLiteral(parseCssColor(t.string('$base.$key', symbol: '$name.$member')))}',
    ];
    return 'RibbonColors(${args.join(', ')})';
  }

  c.add(
    'defaultColors',
    colors('winRibbon.default', 'defaultColors'),
    doc: 'The win ribbon as authored (tokens.json `winRibbon.default`).',
  );
  t.documented('versus.ribbon.\$note', reason: 'the design frames');
  c.add(
    'versusColors',
    colors('versus.ribbon', 'versusColors'),
    doc: 'The race\'s result ribbon (tokens.json `versus.ribbon`).',
  );
  t.documentedExact(
    'versus.ribbon.hi',
    'unchanged',
    reason: '`hi_fill` keeps its authored white (no delegate)',
  );
  final label = t.string('versus.ribbon.label', symbol: '$name.versusLabel');
  final m = RegExp(
    r'^(#[0-9A-Fa-f]{6}) \(([\d.]+):1 on the band\)$',
  ).firstMatch(label);
  if (m == null) {
    throw TokenFormatException('versus.ribbon.label', 'unexpected wording');
  }
  c.add(
    'versusLabel',
    colorLiteral(parseCssColor(m[1]!)),
    doc: 'The label on the race ribbon (`$label`).',
  );
  for (final key in t.keys('winRibbon.keyPaths')) {
    if (key.startsWith(r'$')) continue;
    final path = 'winRibbon.keyPaths.$key';
    final member = '${memberName(key)}KeyPath';
    final parts = t.strings(path, symbol: '$name.$member');
    if (parts.length != 2 || parts[0] != '**' || parts[1] != '${key}_fill') {
      throw TokenFormatException(path, "expected ['**', '${key}_fill']");
    }
    c.add(
      member,
      '[${parts.map(stringLiteral).join(', ')}]',
      type: 'List<String>',
      doc: 'The colour delegate\'s key path to the `${key}_fill` fills.',
    );
  }
  _winRibbonSize(t, c);
  return c;
}

/// Tokens v5 (m7-5 item 5; LOTTIE.md m7-5) `winRibbon.size`: the win band's
/// size, its reach with the tails, the text box, the rects that set a width
/// (`FxSpec.sizedRects`, checked against both ribbons' contracts) and the
/// widest it may draw.
void _winRibbonSize(TokenReader t, ConstClass c) {
  const name = 'WinRibbonTokens';
  const p = 'winRibbon.size';
  for (final key in t.keys(p)) {
    const known = {r'$note', 'band', 'reach', 'textBox', 'rects', 'wider'};
    if (!known.contains(key)) {
      throw TokenFormatException('$p.$key', 'unknown ribbon size field');
    }
  }
  t.documented('$p.\$note', reason: 'a design note (LOTTIE.md m7-5)');
  final band = t.numbers('$p.band', symbol: '$name.bandSize', length: 2);
  c.add(
    'bandSize',
    sizeLiteral(band[0], band[1]),
    doc:
        '`ui_win_ribbon`\'s band as authored (m7-5): `band_rect` and '
        '`edge_rect`; `hi_rect` is 16 dp narrower.',
  );
  final reach = t.number('$p.reach', symbol: '$name.reach');
  if (reach <= band[0]) {
    throw TokenFormatException('$p.reach', 'the tails reach past the band');
  }
  c.add(
    'reach',
    doubleLiteral(reach),
    doc:
        'The ribbon\'s width at rest with its tails: for another band width '
        'w, move `tail_l` / `tail_r` by ∓(w − bandSize.width) / 2.',
  );
  final box = t.numbers('$p.textBox', symbol: '$name.textBox', length: 2);
  c.add(
    'textBox',
    sizeLiteral(box[0], box[1]),
    doc: 'The game\'s own label fits this box, centred on the anchor.',
  );
  final rects = <String>{};
  for (final key in t.keys('$p.rects')) {
    final path = '$p.rects.$key';
    final member = '${memberName(key)}RectKeyPath';
    final parts = t.strings(path, symbol: '$name.$member');
    if (parts.length != 3 || parts[0] != 'band' || parts[2] != '${key}_rect') {
      throw TokenFormatException(
        path,
        "expected ['band', <group>, '${key}_rect']",
      );
    }
    rects.add(parts[2]);
    c.add(
      member,
      '[${parts.map(stringLiteral).join(', ')}]',
      type: 'List<String>',
      doc:
          'The size delegate\'s key path to `${key}_rect` '
          '(`ValueDelegate.rectangleSize`).',
    );
  }
  final wider = t.string('$p.wider', symbol: '$name.maxWidthInset');
  final m = RegExp(
    r'^never wider than screen − (\d+); (ui_chapter_ribbon) has the same rect '
    r'names$',
  ).firstMatch(wider);
  if (m == null) throw TokenFormatException('$p.wider', 'unexpected wording');
  for (final file in ['ui_win_ribbon', m[2]!]) {
    final contract = lottieContractOf(file);
    if (contract == null ||
        contract.sizedRects.length != rects.length ||
        !contract.sizedRects.containsAll(rects)) {
      throw TokenFormatException(
        '$p.rects',
        '$rects are not $file\'s named rects (${contract?.sizedRects})',
      );
    }
  }
  c.add(
    'maxWidthInset',
    doubleLiteral(num.parse(m[1]!)),
    doc:
        'A ribbon is never wider than the screen − this; '
        '`ui_chapter_ribbon` takes a width through the same rects.',
  );
}
