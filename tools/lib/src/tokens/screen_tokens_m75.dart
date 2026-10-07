// What tokens v5 (Claude Design m7-5) adds to the generic per-screen
// emitter: the daily gift's sections (App Flow section 13), the chest's +1
// slot chip, the splash's top fade, and Part 2's layout additions (the race
// strip's two forms, the tutorial hand, the generating card). Its prose
// parsers and documented leaves sit beside the m7-4 ones of the library.
part of 'screen_tokens_codegen.dart';

/// m7-5 prose kept as documentation, with why.
const _m75DocumentedLeaves = {
  'layout.chapters.scroll.rule':
      'the open scroll as built (m7-5 item 21): up to '
      'ChaptersTokens.scrollFoldedAbove folded rows above the open card, '
      'fewer when it would not fit whole (ChaptersPage)',
  'layout.generating.card.boxSizing':
      'the card\'s width includes its side padding (border-box), which is '
      'how Flutter sizes a padded box',
  'layout.rivalStrip.forms.tagSecondLine':
      'the 9.3i form (name alone on line 1, the tag then the state glyph on '
      'line 2), the race strip as built (B-game)',
  'layout.rivalStrip.forms.belowWidth360':
      'the README rule (the tag drops to its glyph under 360 dp), unchanged',
  'layout.splash.topFade.over':
      'the fade\'s layer: over the theme art, under the logo and the status '
      'bar (SplashPage)',
  'gift.button.readyDot.motion':
      'behaviour: the ready dot is static, there when Home shows, never '
      'pulsing',
  'gift.button.narrow':
      'behaviour on 360 dp at 1.3× text: both top-row buttons keep their '
      '46 dp faces and 48 dp targets (as built)',
  'gift.button.hiddenUntil':
      'a rule, never read from tokens: the gift button shows once the Daily '
      'unlocks (the daily unlock, after level 2), LoginGiftCubit',
  'gift.sheet.day7.chips.wrap':
      'the day-7 chips sit side by side and wrap to two rows when they do '
      'not fit (textFit.chestChips)',
  'gift.tile.day7':
      'the wide day-7 tile takes the same four looks; done dims its chest '
      'and chips to GiftTileTokens.doneContentOpacity',
  'gift.tally.layer': 'the tally paints above the scrim',
  'gift.tally.count': 'the tally shows the player\'s new total',
  'gift.claim.coins.from': 'the coins fly from today\'s tile centre',
  'gift.claim.coins.to': 'the coins land on the coin disc in the pill',
  'gift.claim.hint.to': 'the hint lands on the tally\'s disc',
  'gift.claim.slot.to': 'the slot lands on the tally\'s disc',
  'gift.reducedMotion.day7':
      'reduce motion on day 7 is the chest\'s own '
      '(ChestMotionTokens / ChestRewardSequence): a 200 ms cross-fade, no '
      'wiggle, the chips together, Collect with no flights',
  'textFit.giftSheet':
      'the gift sheet\'s overflow rules: the title one line scaling to 0.85, '
      'the tile amounts never scale, the day-7 chips wrap, the footer lines '
      'wrap (GiftSheet)',
};

/// m7-5 prose pinned word for word (the hand-written code follows it).
const _m75ExactLeaves = {
  'layout.tutorial.hand.lottie': (
    'ui_tap_hand',
    'FxId.uiTapHand, played at TutorialTokens.handScale (B-game)',
  ),
  'layout.generating.card.top': (
    'centred in the safe area (as built); the frame’s 360 is that centre on '
        '844',
    'GeneratingOverlay centres the card in the safe area (DELIVERY Choices '
        '10); no top is generated',
  ),
  'layout.noCoins.top': (
    'centred in the safe area (as built); 220 is that centre for this card '
        'on 844',
    'the no-coins dialog stays centred (DELIVERY Choices 17); no top is '
        'generated',
  ),
  'gift.claim.slot.land': (
    'as the hint',
    'the slot lands as the hint does (GiftClaimTokens.hintLand*)',
  ),
};

/// Keys whose snake_case string is a copy.md id (the ARB key).
const _copyIdKeys = {'label', 'a11y', 'body'};

final _copyId = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$');
final _artPath = RegExp(r'^(ui/[a-z0-9_]+/[a-z0-9_]+\.svg)$');
final _artAt = RegExp(r'^(ui/[a-z0-9_]+/[a-z0-9_]+\.svg) at (\d+(?:\.\d+)?)$');

/// Tokens v5's generic string shapes: a colour by name (`color.scrim`), an
/// art reference (`ui/gift/gift_glyph.svg`, documented: `UiArt` draws it),
/// art at a size (`ui/sprites/hint_flight.svg at 40`), a CSS radial
/// gradient, a copy.md id. False when [value] is none of them.
bool _m75String(_Leaf l, String value) {
  final t = l.t;
  final named = RegExp(r'^color\.([a-z][A-Za-z0-9]*)$').firstMatch(value);
  if (named != null) {
    final name = named[1]!;
    final color = t.has('color.$name') ? t.peek('color.$name') : null;
    if (color is! String || !isCssColor(color)) {
      throw TokenFormatException(l.path, 'there is no colour color.$name');
    }
    l.add(
      'AppColorTokens.$name',
      type: 'Color',
      doc: 'The `$name` colour (`$color`).',
    );
    return true;
  }
  if (_artPath.firstMatch(value) case final art?) {
    t.documented(
      l.path,
      reason: 'an art reference (${art[1]}), drawn through UiArt',
    );
    return true;
  }
  if (_artAt.firstMatch(value) case final art?) {
    l.add(
      doubleLiteral(num.parse(art[2]!)),
      name: '${l.member}Size',
      doc: '`${art[1]}` (`UiArt`) at this size, dp.',
    );
    return true;
  }
  if (isCssRadialGradient(value)) {
    l.add(radialGradientLiteral(parseCssRadialGradient(value), l.path));
    return true;
  }
  if (_copyIdKeys.contains(l.key) && _copyId.hasMatch(value)) {
    t.documented(l.path, reason: 'a copy.md id: the ARB key `$value`');
    return true;
  }
  return false;
}

/// A `RadialGradient` for a CSS `radial-gradient(circle at …)`: the centre
/// as an Alignment, CSS's farthest-corner radius on a square box.
String radialGradientLiteral(CssRadialGradient g, String path) {
  final positions = resolveStopPositions([for (final s in g.stops) s.position]);
  final implicit = g.stops.every((s) => s.position is ImplicitStop);
  final stops = [
    for (final p in positions)
      if (p is FractionStop)
        doubleLiteral(p.fraction)
      else
        throw TokenFormatException(path, 'px stops in a radial gradient'),
  ];
  double r4(double v) {
    final r = (v * 10000).round() / 10000;
    return r == 0 ? 0 : r;
  }

  return 'RadialGradient(center: '
      '${alignmentLiteral(r4(g.cx * 2 - 1), r4(g.cy * 2 - 1))}, '
      'radius: ${doubleLiteral(farthestCornerRadius(g.cx, g.cy))}, '
      'colors: [${g.stops.map((s) => colorLiteral(s.color)).join(', ')}]'
      '${implicit ? '' : ', stops: [${stops.join(', ')}]'})';
}

/// The value at [path] as a number, or a format error naming [at].
num _num(_Leaf l, String path) {
  final value = l.t.peek(path);
  if (value is! num) throw TokenFormatException(l.path, 'needs $path');
  return value;
}

/// `motion.easing.<name>` as the `UiMotionTokens` curve it emits.
String _easing(_Leaf l, String name) {
  if (!l.t.has('motion.easing.$name')) {
    throw TokenFormatException(l.path, 'there is no motion.easing.$name');
  }
  return 'UiMotionTokens.curve${name[0].toUpperCase()}${name.substring(1)}';
}

/// One of the race strip's state glyphs (9.3i): `<glyph>, <colour>[, …]`.
void Function(_Leaf) _stateGlyph(String tail) => (l) {
  final m = l.match('([a-z_]+), $_color$tail');
  l
    ..add(
      stringLiteral(m[1]!),
      doc:
          'The `${m[1]}` glyph (`NestyIcons`), 16 dp after the tag (9.3i); '
          'tools/test/tokens checks the bundled icon font has it.',
    )
    ..add(colorLiteral(parseCssColor(m[2]!)), name: '${l.member}Color');
};

/// The m7-5 parsers for the prose values whose numbers the app needs.
final Map<String, void Function(_Leaf)> _m75Specials = {
  // Part 2, item 16: the race strip's two narrow forms.
  'layout.rivalStrip.forms.full': (l) {
    final m = l.match(
      r'9\.3: name \+ tag on line 1, the state on line 2, the count over ≤ '
      r'(\d+) dots',
    );
    l.add(
      m[1]!,
      name: 'formsFullMaxDots',
      doc:
          'The full form (9.3) draws the count over at most this many dots; '
          'a race with more families takes the count-only form.',
    );
  },
  'layout.rivalStrip.forms.countOnly': (l) {
    final m = l.match(
      '9\\.3h: the dots go and the count \\($_font\\) stands alone, centred; '
      'also every race with more than (\\d+) families',
    );
    if (l.t.peek('layout.rivalStrip.forms.full') case final String full
        when !full.endsWith('≤ ${m[2]} dots')) {
      throw TokenFormatException(l.path, 'disagrees with forms.full');
    }
    l.add(
      textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
      name: 'formsCountOnlyText',
      doc:
          'The count-only form (9.3h): the dots go and the count stands '
          'alone, centred; also every race with more than '
          '[formsFullMaxDots] families.',
    );
  },
  'layout.rivalStrip.forms.stateGlyph.thinking': _stateGlyph(
    ', pulsing like the 3 dots',
  ),
  'layout.rivalStrip.forms.stateGlyph.startingOver': _stateGlyph(''),
  'layout.rivalStrip.forms.stateGlyph.finished': _stateGlyph(''),
  'layout.rivalStrip.forms.dots': (l) {
    final m = l.match(r'never smaller than (\d+) dp');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'formsDotsMinSize',
      doc: 'In the m7-5 forms the dots never shrink below this, dp.',
    );
  },
  // Part 2, item 8.
  'layout.tutorial.hand.note': (l) {
    final m = l.match(
      r'm7-5 \(item 8\): play at ([\d.]+) on the fingertip anchor '
      r'\((\d+), (\d+)\), so the hand is (\d+) dp as in the frames',
    );
    final contract = lottieContractOf('ui_tap_hand');
    if (num.parse(m[1]!) != _num(l, 'layout.tutorial.hand.scale') ||
        contract == null ||
        contract.anchor !=
            LottiePoint(double.parse(m[2]!), double.parse(m[3]!))) {
      throw TokenFormatException(
        l.path,
        'is not hand.scale on ui_tap_hand\'s anchor',
      );
    }
    l.t.documented(
      l.path,
      reason:
          'ui_tap_hand at TutorialTokens.handScale on FxSpec.anchor (both '
          'checked)',
    );
  },
  // Part 2, item 11.
  'layout.splash.topFade.fill': (l) {
    final m = l.match(
      'linear-gradient\\(180deg, $_color 0, $_color (\\d+)dp, $_color '
      '(\\d+)dp\\)',
    );
    final a = cssAngleToAlignment(180);
    final colors = [
      m[1]!,
      m[2]!,
      m[4]!,
    ].map((c) => colorLiteral(parseCssColor(c)));
    l
      ..add(
        'PxLinearGradient(begin: ${alignmentLiteral(a.beginX, a.beginY)}, '
        'end: ${alignmentLiteral(a.endX, a.endY)}, '
        'colors: [${colors.join(', ')}], stops: [TokenStop.px(0.0), '
        'TokenStop.px(${doubleLiteral(num.parse(m[3]!))}), '
        'TokenStop.px(${doubleLiteral(num.parse(m[5]!))})])',
        doc:
            'The splash\'s top fade (m7-5 item 11): solid to ${m[3]} dp, '
            'clear at ${m[5]} dp, over the theme art. Call '
            '`resolve(topFadeHeight)`.',
      )
      ..add(
        doubleLiteral(num.parse(m[5]!)),
        name: 'topFadeHeight',
        doc: 'The fade\'s box, from the screen top, dp.',
      );
  },
  // The chest's +1 slot chip (5.6, 13.6).
  'chest.slotChip.disc': (l) {
    final m = l.match(
      r'(ui/chest/chip_slot\.svg) \((\d+) dp, like the coin and hint discs\)',
    );
    l.add(
      doubleLiteral(num.parse(m[2]!)),
      name: 'discSize',
      doc: 'The chip\'s disc, `${m[1]}` (`UiArt`), dp.',
    );
  },
  'chest.slotChip.glyph': (l) {
    final m = l.match(
      'a (white) rounded square \\(([\\d.]+) dp, radius ([\\d.]+)\\) with a '
      '$_color plus',
    );
    l
      ..add(
        colorLiteral(parseCssColor(m[1]!)),
        name: 'glyphColor',
        doc:
            'The add box in the disc (drawn in chip_slot.svg): a rounded '
            'square …',
      )
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'glyphSize', doc: '… dp …')
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'glyphRadius',
        doc: '… with this corner radius …',
      )
      ..add(
        colorLiteral(parseCssColor(m[4]!)),
        name: 'glyphPlusColor',
        doc: '… and a plus in this colour.',
      );
  },
  // The gift button (13.1).
  'gift.button.place': (l) {
    final m = l.match(
      r'Home top row, left of the gear: right (\d+) \((\d+) \+ (\d+) \+ '
      r'(\d+)\), top = the gear’s top \((\d+); (\d+) on 16:9\)',
    );
    final n = [for (var i = 1; i <= 6; i++) num.parse(m[i]!)];
    if (n[0] != n[1] + n[2] + n[3] ||
        n[2] != _num(l, 'gift.button.size') ||
        n[3] != _num(l, 'gift.button.gapToGear') ||
        n[0] != _num(l, 'layout.home.giftButton.right') ||
        n[0] != _num(l, 'layout.homeShort.giftButton.right') ||
        n[4] != _num(l, 'layout.home.giftButton.top') ||
        n[5] != _num(l, 'layout.homeShort.giftButton.top')) {
      throw TokenFormatException(
        l.path,
        'is not layout.home(Short).giftButton and the button\'s size and gap',
      );
    }
    l.t.documented(
      l.path,
      reason:
          'the placement: HomeTokens.giftButton* and '
          'HomeShortTokens.giftButton* (checked)',
    );
  },
  'gift.button.glyph.color': (l) {
    final m = l.match('$_color, baked into the SVG \\((\\w+)\\)');
    final named = l.t.has('color.${m[2]}') ? l.t.peek('color.${m[2]}') : null;
    if (named is! String || parseCssColor(named) != parseCssColor(m[1]!)) {
      throw TokenFormatException(l.path, 'is not color.${m[2]}');
    }
    l.t.documented(
      l.path,
      reason:
          'baked into ui/gift/gift_glyph.svg: AppColorTokens.${m[2]} '
          '(checked)',
    );
  },
  // The sheet (13.3).
  'gift.sheet.footer.claim': (l) {
    final m = l.match(
      'the primary button \\(gradient\\.(\\w+), edge 0 (\\d+)px 0 $_color, '
      'radius (\\d+), $_font\\)',
    );
    gradientReference(l.t, m[1]!, l.path);
    _fontOf(l, m[5]!);
    l.t.documented(
      l.path,
      reason: 'Claim is the primary button as built (NestyButton.primary)',
    );
  },
  'gift.sheet.footer.swap': (l) {
    final m = l.match(
      r'Claim ↔ the line: (\d+) ms cross-fade, the height stays (\d+) so '
      r'nothing moves',
    );
    if (num.parse(m[2]!) != _num(l, 'gift.sheet.footer.height')) {
      throw TokenFormatException(l.path, 'is not footer.height');
    }
    l.add(
      m[1]!,
      name: 'footerSwapMs',
      doc:
          'Claim and the claimed line cross-fade over this; the footer keeps '
          '[footerHeight], so nothing moves.',
    );
  },
  'gift.sheet.open': (l) {
    final m = l.match(
      r'motion\.ui\.(\w+) \((\d+) ms\); only when the player taps the gift '
      r'button',
    );
    if (l.t.has('motion.ui.${m[1]}') &&
        l.t.peek('motion.ui.${m[1]}') == int.parse(m[2]!)) {
      l.t.documented(
        l.path,
        reason:
            'UiMotionTokens.${m[1]}Ms (checked); the sheet opens only from '
            'the gift button',
      );
      return;
    }
    throw TokenFormatException(l.path, 'is not motion.ui.${m[1]}');
  },
  'gift.sheet.height': (l) {
    final m = l.match(r'(\d+) on 844 \(top (\d+)\)');
    if (844 - num.parse(m[1]!) != num.parse(m[2]!)) {
      throw TokenFormatException(l.path, 'the top is not 844 − the height');
    }
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      doc:
          'The sheet\'s height on the 390×844 reference (from its content), '
          'for the layout tests; its top is ${m[2]}.',
    );
  },
  'gift.short.height': (l) {
    final m = l.match(r'(\d+) \(top (\d+)\)');
    if (693 - num.parse(m[1]!) != num.parse(m[2]!)) {
      throw TokenFormatException(l.path, 'the top is not 693 − the height');
    }
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      doc:
          'The sheet\'s height on 16:9 (from its content), for the layout '
          'tests; its top is ${m[2]}.',
    );
  },
  // The tiles (13.3).
  'gift.tile.done.check.glyph': (l) {
    final m = l.match('([a-z_]+) (\\d+) $_color wght (\\d+)');
    l
      ..add(
        stringLiteral(m[1]!),
        name: 'doneCheckGlyph',
        doc: 'The done tile\'s check: the `${m[1]}` glyph (`NestyIcons`) …',
      )
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'doneCheckGlyphSize')
      ..add(colorLiteral(parseCssColor(m[3]!)), name: 'doneCheckGlyphColor')
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: 'doneCheckGlyphWeight',
        doc:
            'The design draws it at this weight; the bundled icon font is '
            'cut at AppFontTokens.iconWeight.',
      );
  },
  // The tally under the coin pill (13.5b, 13.6d).
  'gift.tally.top': (l) {
    final m = l.match(r'the coin pill’s top \+ (\d+) \((\d+); (\d+) on 16:9\)');
    final below = num.parse(m[1]!);
    if (_num(l, 'layout.home.topRow') + below != num.parse(m[2]!) ||
        _num(l, 'layout.homeShort.topRow') + below != num.parse(m[3]!)) {
      throw TokenFormatException(
        l.path,
        'is not layout.home(Short).topRow + the offset',
      );
    }
    l
      ..add(
        doubleLiteral(below),
        name: 'topBelowCoinPill',
        doc: 'The tally\'s top is the coin pill\'s top + this …',
      )
      ..add(doubleLiteral(num.parse(m[2]!)), doc: '… on 844 …')
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'topShort',
        doc: '… and on 16:9.',
      );
  },
  'gift.tally.discs.hint': (l) {
    final m = l.match(
      'the chest’s hint chip disc: (linear-gradient\\([^)]*\\)), '
      '(inset 0 -?\\d+px 0 $_color), ([a-z_]+) (\\d+) $_color',
    );
    l
      ..add(
        linearGradientLiteral(parseCssLinearGradient(m[1]!), l.path),
        name: 'discsHintFace',
        doc: 'The hint disc, as the chest\'s hint chip draws it: its face …',
      )
      ..add(
        shadowListLiteral(parseBoxShadowList(m[2]!)),
        name: 'discsHintEdge',
        type: 'List<NestyShadow>',
        doc: '… its edge …',
      )
      ..add(
        stringLiteral(m[4]!),
        name: 'discsHintGlyph',
        doc: '… and the `${m[4]}` glyph (`NestyIcons`) …',
      )
      ..add(doubleLiteral(num.parse(m[5]!)), name: 'discsHintGlyphSize')
      ..add(colorLiteral(parseCssColor(m[6]!)), name: 'discsHintGlyphColor');
  },
  'gift.tally.in': (l) {
    final m = l.match(
      r'slides down from behind the coin pill, (\d+) ms (\w+), as the sprite '
      r'takes off',
    );
    l
      ..add(
        m[1]!,
        name: 'inMs',
        doc:
            'The tally slides down from behind the coin pill as the sprite '
            'takes off …',
      )
      ..add(_easing(l, m[2]!), name: 'inCurve', type: 'Cubic', doc: '… so.');
  },
  'gift.tally.out': (l) {
    final m = l.match(r'slides back up, (\d+) ms (\w+)');
    l
      ..add(
        m[1]!,
        name: 'outMs',
        doc: 'After [holdMs] the tally slides back up …',
      )
      ..add(_easing(l, m[2]!), name: 'outCurve', type: 'Cubic', doc: '… so.');
  },
  // The claim (13.5, 13.5b, 13.6).
  'gift.claim.tile': (l) {
    final m = l.match(
      r'today’s tile sinks to done \((\d+) ms\) and its check pops with '
      r'motion\.tagPop',
    );
    if (!l.t.has('motion.tagPop.duration')) {
      throw TokenFormatException(l.path, 'there is no motion.tagPop');
    }
    l.add(
      m[1]!,
      name: 'tileSinkMs',
      doc:
          'Today\'s tile sinks to done over this, and its check pops with '
          'MotionTokens.tagPop*.',
    );
  },
  'gift.claim.coins.sprites': (l) {
    final m = l.match(
      r'one per (\d+) coins, (\d+) to (\d+) \(((?:\d+ → \d+(?:, )?)+)\)',
    );
    final every = int.parse(m[1]!);
    final min = int.parse(m[2]!);
    final max = int.parse(m[3]!);
    for (final e in RegExp(r'(\d+) → (\d+)').allMatches(m[4]!)) {
      if ((int.parse(e[1]!) ~/ every).clamp(min, max) != int.parse(e[2]!)) {
        throw TokenFormatException(l.path, 'the example ${e[0]} disagrees');
      }
    }
    l
      ..add(
        '$every',
        name: 'coinsSpriteEvery',
        doc:
            'A coin day flies one coin sprite per this many coins, clamped '
            'to [coinsSpritesMin]…[coinsSpritesMax] (a look, not the '
            'reward: the amounts are the track\'s).',
      )
      ..add('$min', name: 'coinsSpritesMin')
      ..add('$max', name: 'coinsSpritesMax');
  },
  'gift.claim.coins.path': (l) {
    final m = l.match(
      r'quadratic; control \((\d+), (\d+)\) from a row-2 tile on 844',
    );
    l.add(
      offsetLiteral(num.parse(m[1]!), num.parse(m[2]!)),
      name: 'coinsPathControl',
      doc:
          'The coins fly a quadratic path; from a row-2 tile on 844 its '
          'control point is here.',
    );
  },
  'gift.claim.coins.trail': (l) {
    final text = l.t.documentedExact(
      l.path,
      'motion.chest.collect.trail',
      reason: 'the chest flights\' trail, ChestCollectTokens.trail*',
    );
    if (!l.t.has('$text.dot')) {
      throw TokenFormatException(l.path, 'there is no $text');
    }
  },
  'gift.claim.coins.pill': (l) {
    final m = l.match(
      r'the scrim opens around the pill \(a (\d+) × (\d+) hole, radius '
      r'(\d+)\) for the flight and closes (\d+) ms after the last coin; '
      r'motion\.chest\.collect\.pillRing; the count steps up per landing',
    );
    if (!l.t.has('motion.chest.collect.pillRing.shadow')) {
      throw TokenFormatException(l.path, 'there is no pillRing');
    }
    l
      ..add(
        sizeLiteral(num.parse(m[1]!), num.parse(m[2]!)),
        name: 'coinsPillHole',
        doc:
            'For the flight the scrim opens a hole this big around the coin '
            'pill (which glows with ChestCollectTokens.pillRing* and steps '
            'its count up per landing) …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'coinsPillHoleRadius',
        doc: '… with this radius …',
      )
      ..add(
        m[4]!,
        name: 'coinsPillHoleCloseMs',
        doc: '… and closes this long after the last coin lands.',
      );
  },
  'gift.claim.hint.land': (l) {
    final m = l.match(
      r'the disc bumps ([\d.]+)× \((\d+) ms\) with '
      r'motion\.chest\.collect\.hintRing, and gainTag \+\{count\} sits beside '
      r'the tally',
    );
    if (num.parse(m[1]!) != _num(l, 'motion.chest.collect.targetBump') ||
        num.parse(m[2]!) != _num(l, 'motion.chest.collect.targetBumpMs')) {
      throw TokenFormatException(l.path, 'is not the chest\'s targetBump');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'hintLandBump',
        doc:
            'As a hint (or a slot) lands the tally\'s disc bumps to this '
            'scale (the chest\'s targetBump) with ChestCollectTokens.hintRing*, '
            'and the gain tag sits beside the tally …',
      )
      ..add(m[2]!, name: 'hintLandBumpMs', doc: '… over this.');
  },
  'gift.claim.day7': (l) {
    final m = l.match(
      'Claim closes the sheet \\((\\d+) ms\\) and opens the chest card '
      '\\(layout\\.chestCard, topDay7 (\\d+), ui_chest arrive\\)\\. Collect '
      'works as 10\\.3d: the scrim drops to $_color, (\\d+) coins fly to the '
      'pill and the slot to the tally',
    );
    if (num.parse(m[2]!) != _num(l, 'layout.chestCard.card.topDay7') ||
        num.parse(m[4]!) != _num(l, 'motion.chest.collect.coins') ||
        lottieContractOf('ui_chest') == null) {
      throw TokenFormatException(
        l.path,
        'is not chestCard.card.topDay7 and the chest\'s collect',
      );
    }
    l
      ..add(
        m[1]!,
        name: 'day7SheetCloseMs',
        doc:
            'Day 7: Claim closes the sheet over this and opens the chest card '
            '(ChestCardTokens.cardTopDay7, ui_chest\'s arrive); Collect works '
            'as 10.3d (ChestCollectTokens) …',
      )
      ..add(
        colorLiteral(parseCssColor(m[3]!)),
        name: 'day7CollectScrim',
        doc:
            '… with the scrim dropped to this while ${m[4]} coins fly to the '
            'pill and the slot to the tally.',
      );
  },
  'gift.claim.sound': (l) {
    final m = l.match(
      r'(\w+) @0 on Claim, (\w+) as the first coin lands; nothing extra for a '
      r'hint or a slot\. Day 7: (\w+), (\w+) and (\w+) as 5\.6',
    );
    final events = (l.t.peek('sound.events')! as Map<String, Object?>).values;
    if (l.t.peek('sound.events.giftClaim') != m[1] ||
        [for (var i = 2; i <= 5; i++) m[i]].any((e) => !events.contains(e))) {
      throw TokenFormatException(l.path, 'names an unknown sound event');
    }
    l.t.documented(
      l.path,
      reason:
          'the cues: SoundTokens.giftClaim at Claim, SoundTokens.coins as the '
          'first coin lands; day 7 plays the chest\'s (checked)',
    );
  },
  'gift.claim.haptic': (l) {
    l.t.documentedExact(
      l.path,
      'light on Claim; light as a hint or slot lands',
      reason: 'HapticsService.light at Claim and at a hint or slot landing',
    );
    if (l.t.peek('haptics.giftClaim') != 'HapticFeedback.lightImpact') {
      throw TokenFormatException(l.path, 'is not haptics.giftClaim');
    }
  },
  // Reduce motion (13.5r).
  'gift.reducedMotion.claim': (l) {
    final m = l.match(
      r'no flights, no trail: the tile and Claim cross-fade \((\d+) ms\); the '
      r'pill shows the new count at once with its ring for (\d+) ms; the '
      r'tally fades in over (\d+) ms, holds ([\d,]+) and fades out',
    );
    if (_designNumber(m[4]!) != _num(l, 'gift.tally.holdMs')) {
      throw TokenFormatException(l.path, 'is not gift.tally.holdMs');
    }
    l
      ..add(
        m[1]!,
        name: 'claimCrossFadeMs',
        doc:
            'Reduce motion: no flights and no trail; the tile and Claim '
            'cross-fade over this …',
      )
      ..add(
        m[2]!,
        name: 'claimPillRingMs',
        doc: '… the pill shows the new count at once, ringed for this …',
      )
      ..add(
        m[3]!,
        name: 'claimTallyFadeInMs',
        doc:
            '… and the tally fades in over this, holds GiftTallyTokens.holdMs '
            'and fades out.',
      );
  },
};
