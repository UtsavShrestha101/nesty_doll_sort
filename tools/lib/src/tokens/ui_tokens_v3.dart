// What tokens v3 (m7-3) adds to ui_tokens.gen.dart besides the colours,
// the `versus` gradient and the family counter: the per-screen sections
// (the generic emitter), the M7 UI motion, the icon uses, and the rule
// values the design repeats, which are documentation only (phase 4
// architecture §1.1 policy 2: rules never come from tokens; the app's
// `rule_tokens_test` pins each to its source of truth).
import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/screen_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';

/// Every v3 UI class, in file order.
List<ConstClass> uiV3Classes(TokenReader t) {
  _documentRules(t);
  return [
    for (final MapEntry(key: path, value: name) in screenTokenSections.entries)
      path == 'shop' ? _shop(t) : screenTokens(t, path, className: name),
    _stars(t),
    _chest(t),
    _rival(t),
    _toast(t),
    _chaptersFadeIn(t),
    _purchase(t),
    _icons(t),
  ];
}

/// `versus.*` and `chest.*`: the owner's rules, repeated by the design.
void _documentRules(TokenReader t) {
  t
    ..documentedTree(
      'versus',
      reason:
          'rules, never read from tokens: RemoteConfigKeys (race unlock and '
          'rewards), RaceRules and the bloc\'s race mode (spec-prop §7.7, '
          'D93); rule_tokens_test pins the numbers',
    )
    ..documentedTree(
      'chest',
      reason:
          'rules, never read from tokens: MilestoneChest and '
          'RemoteConfigKeys (chest_coins, chest_hints, streak7_reward; '
          'spec-prop §7.3, §7.4); rule_tokens_test pins the numbers',
    );
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
  for (final id in t.keys('$p.skins')) {
    final base = '$p.skins.$id';
    const symbol = 'ShopTokens.skins';
    if (t.keys(base).join(',') != 'card,panel,edge,caption') {
      throw TokenFormatException(base, 'expected card, panel, edge, caption');
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
