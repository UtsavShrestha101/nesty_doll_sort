// What tokens v6 (Claude Design m7-6) adds to the generic per-screen
// emitter: the local habits' sections (App Flow section 14: the welcome
// card, the month, a past day, the home-screen widget), the Computer tag
// (Part 2 item 2), and Part 2's prose additions to existing sections (the
// race strip's pause, the Museum's name plate, the splash's error pointers,
// the gift tally on short phones, the text-fit rules). Its parsers and
// documented leaves sit beside the m7-4 and m7-5 ones of the library.
part of 'screen_tokens_codegen.dart';

/// The m7-6 sections, tokens.json path → generated class. `habits.month`
/// and `habits.widget` skip their sub-sections, which are their own.
const m76ScreenTokenSections = {
  'versus.computerTag': 'ComputerTagTokens',
  'habits.welcomeBack': 'HabitsWelcomeTokens',
  'habits.month': 'HabitsMonthTokens',
  'habits.month.short': 'HabitsMonthShortTokens',
  'habits.month.cell': 'HabitsDayCellTokens',
  'habits.pastDay': 'HabitsPastDayTokens',
  'habits.widget': 'HabitsWidgetTokens',
  'habits.widget.colors': 'HabitsWidgetColorTokens',
};

/// Sub-sections an m7-6 section leaves to their own class.
const m76SectionSkips = {
  'habits.month': {'habits.month.short', 'habits.month.cell'},
  'habits.widget': {'habits.widget.colors'},
};

/// m7-6 prose kept as documentation, with why.
const _m76DocumentedLeaves = {
  // The welcome card (14.1).
  'habits.welcomeBack.gone':
      'behaviour: the card goes once today\'s puzzle is solved, when '
      'dismissed, or at the first Home after midnight, never while the '
      'player is looking at it (WelcomeBackRules and Home, B-habits)',
  'habits.welcomeBack.card.button':
      'behaviour: the whole card but the close is one button that opens '
      'today\'s daily board (5.3)',
  'habits.welcomeBack.withGift':
      'behaviour: the gift button\'s ready dot (13.1) shows with the card; '
      'neither moves on its own',
  // The month (14.2).
  'habits.month.header.chip.show':
      'behaviour: the ‹ chip shows only on the 1st–7th, when part of the '
      'window is in the previous month; that month shows {this month} › '
      '(MonthCard, B-habits)',
  'habits.month.weekdays.names':
      'the locale\'s abbreviated stand-alone weekday names (intl), narrow '
      'when one does not fit (TextFitTokens.habitsMonthWeekdaysMinScale)',
  'habits.month.weekdays.first':
      'the locale\'s first weekday: MaterialLocalizations.'
      'firstDayOfWeekIndex (0 = Sunday)',
  'habits.month.grid.rows':
      'the grid has 4 to 6 rows, as the month needs; the card\'s height '
      'follows',
  'habits.month.legend.shows':
      'behaviour: the legend shows only the marks the month holds (lit, '
      'later, freeze)',
  'habits.month.window':
      'a rule, never read from tokens: the 7 dates before today by the '
      'device\'s local date are buttons, every other past day is not '
      '(plan-local-habits §2–§3, B-habits)',
  'habits.month.frozen':
      'a rule: a frozen day shows HabitsDayCellTokens.freeze*, never lit; '
      'played later afterwards it shows later*',
  'habits.month.firstOfMonth':
      'behaviour on the 1st: at most today is lit; the chip reaches the '
      'window\'s days in the previous month',
  'habits.month.justUnlocked':
      'behaviour when the Daily has just unlocked: every past day blank, '
      'the 7 days before today open, no legend',
  'habits.month.cell.today.tap':
      'behaviour: tapping today scrolls up to today\'s card',
  // A past day (14.3).
  'habits.pastDay.rules':
      'rules, never read from tokens: a past day pays nothing, never moves '
      'the streak, never grants or spends a freeze, never counts toward the '
      'Day 7 chest and can\'t repair a paused streak; replays pay nothing '
      '(plan-local-habits §3, after Q189)',
  // The widget (14.4): native, built in local-habits stage 4.
  'habits.widget.tap':
      'behaviour: the widget opens DailyRoute (the locked Daily, 12.14, '
      'before Level 2), plan-local-habits §4',
  'habits.widget.refresh':
      'behaviour: the widget refreshes at local midnight and when the daily '
      'is solved; nothing counts down',
  'habits.widget.art.previews':
      'the picker previews\' pixel sizes, checked by sync_design_assets '
      '(tools/lib/src/assets/widget_art.dart)',
  'habits.widget.ios.families':
      'the WidgetKit families (systemSmall, systemMedium), native '
      '(plan-local-habits §4)',
  'habits.widget.ios.sizeNote':
      'the iOS sizes are a 390×844 iPhone\'s; the system sets them per '
      'device',
  'habits.widget.ios.radius':
      'native: the system\'s radius (containerBackground)',
  'habits.widget.ios.background':
      'native: containerBackground(for: .widget) with '
      'HabitsWidgetColorTokens.light/darkBackground',
  'habits.widget.ios.tinted':
      'native (iOS 18 tinted mode): the flame and the number are '
      'widgetAccentable(), flame_lit.svg draws as a template, the dolls '
      'render accentedDesaturated, the background is the system\'s',
  'habits.widget.ios.standby':
      'native (iOS 17 StandBy): no container background; the content keeps '
      'the dark colours on black',
  'habits.widget.ios.fonts':
      'native: the widget extension bundles Fredoka 600/700 and Nunito 800 '
      '(UIAppFonts), SF Pro Rounded only as fallback',
  'habits.widget.android.sizes':
      'the Android sizes, 2 × 2 and 4 × 2 cells, native (plan-local-habits '
      '§4)',
  'habits.widget.android.preview':
      'native: previewLayout on Android 12+, previewImage '
      '(ui/widget/preview_*.png) before',
  'habits.widget.android.fonts':
      'native: RemoteViews can\'t load the app\'s fonts, so the system sans '
      '(sans-serif-medium for numbers and titles, sans-serif for labels); '
      'text stays text for TalkBack and font scaling',
  'habits.widget.colors.tinted.background':
      'native: in tinted mode the background is the system\'s',
  'textFit.habitsMonth.legend':
      'the month\'s legend wraps to a second row (MonthCard)',
};

/// m7-6 prose pinned word for word (the hand-written code follows it).
const _m76ExactLeaves = {
  'habits.welcomeBack.place.h693.dolls': (
    'faded out: there is no room',
    'on 16:9 the dolls fade out (HomeLayout, B-habits)',
  ),
  'habits.welcomeBack.place.between': (
    'the card top blends as layout.sizeBlend; the doll rule picks scale or '
        'fade',
    'HomeLayout blends the card\'s top like every Home number '
        '(SizeBlendTokens); the doll rule picks scale or fade',
  ),
  'habits.welcomeBack.place.moves': (
    'only the dolls. The top row, the chapter card, Records, the plank, '
        'Play, the tiles and the nav stay',
    'HomeLayout moves only the dolls for the card',
  ),
  'habits.month.motion': (
    'nothing in the month moves on its own; Reduce motion changes nothing '
        'here',
    'MonthCard has no motion of its own',
  ),
  'habits.pastDay.haptic': (
    'as 5.3 and 5.4',
    'a past day\'s board and win play the daily\'s haptics',
  ),
  'habits.widget.art.folder': (
    'ui/widget/',
    'design/ui/widget/, validated by sync_design_assets (widget_art.dart)',
  ),
  'habits.widget.art.png': (
    'each as name.png (1×), name-2x.png and name-3x.png at the dp size above',
    'widget_art.dart checks each scale (widgetPngScales)',
  ),
  'habits.widget.art.vector': (
    'flat fills, no filters, no gradients, so Android takes them as vector '
        'drawables',
    'widget_art.dart checks the SVGs are flat (validateWidgetSvg)',
  ),
  'habits.widget.art.doll': (
    'one colour (#000000): a template image, tinted per family with '
        'DollColor.base',
    'widget_art.dart checks the doll is one colour; native code tints it '
        'per family with DollColor.base',
  ),
};

/// Tokens v6's generic string shapes: a day number's colour and weight
/// (`#FFFFFF 700`), a cell with no face (`none`), a state's meaning, a
/// copy id under `copy`. False when [value] is none of them.
bool _m76String(_Leaf l, String value) {
  final t = l.t;
  if (l.key == 'number') {
    final m = RegExp('^$_color (\\d{3})\$').firstMatch(value);
    if (m != null) {
      final weight = int.parse(m[2]!);
      final weights = t.peek('font.display.weights');
      if (weights is! List<Object?> || !weights.contains(weight)) {
        throw TokenFormatException(l.path, '$weight is not a bundled weight');
      }
      l
        ..add(
          colorLiteral(parseCssColor(m[1]!)),
          name: '${l.member}Color',
          doc: 'The day number\'s colour …',
        )
        ..add(
          'FontWeight.w$weight',
          name: '${l.member}Weight',
          doc: '… and weight (`$value`).',
        );
      return true;
    }
  }
  if (l.key == 'face' && value == 'none') {
    t.documented(l.path, reason: 'no face: the number alone on the card');
    return true;
  }
  if (l.key == 'means') {
    t.documented(l.path, reason: 'what the mark means, in the design');
    return true;
  }
  if (l.key == 'copy' && _copyId.hasMatch(value)) {
    t.documented(l.path, reason: 'a copy.md id: the ARB key `$value`');
    return true;
  }
  return false;
}

/// A number leaf under another member name.
void Function(_Leaf) _renamed(String name, String doc) => (l) {
  l.c.add(
    name,
    doubleLiteral(l.t.number(l.path, symbol: l.symbol(name))),
    doc: '$doc (`${l.t.peek(l.path)}`).',
  );
};

/// Documentation only, after [check] passes on the value.
void Function(_Leaf) _checked(
  String reason,
  bool Function(_Leaf l, String text) check,
) => (l) {
  final text = '${l.t.peek(l.path)}';
  if (!check(l, text)) {
    throw TokenFormatException(l.path, 'unexpected wording "$text"');
  }
  l.t.documented(l.path, reason: reason);
};

/// `<variant description>: <copy id>`, documented as the copy.md id.
void Function(_Leaf) _copyAfterColon(String prefix) => (l) {
  final m = l.match('(.+): ($prefix[a-z_]+)');
  l.t.documented(
    l.path,
    reason: '${m[1]}: the copy.md id `${m[2]}` (the ARB key)',
  );
};

/// A glyph look: `<glyph>[ FILL 1,] <size>[,] <colour>[ wght <w>][ (<aside>)]`.
/// Adds `<member>` (the glyph), `<member>Size`, `<member>Color` and, when
/// the design names one, `<member>Weight`.
void _glyphLook(_Leaf l, String text, {String? name}) {
  final member = name ?? l.member;
  final m = RegExp(
    '^([a-z_]+)( FILL 1,)? $_nr,? $_color(?: wght (\\d{3}))?'
    '(?: \\(([^()]+)\\))?\$',
  ).firstMatch(text);
  if (m == null) {
    throw TokenFormatException(l.path, 'expected a glyph look, got "$text"');
  }
  if (m[2] != null && !'${l.t.peek('font.icon.settings')}'.contains('FILL 1')) {
    throw TokenFormatException(l.path, 'the bundled icon font is not filled');
  }
  l
    ..add(
      stringLiteral(m[1]!),
      name: member,
      doc:
          'The `${m[1]}` glyph (`NestyIcons`)${m[6] == null ? '' : ', ${m[6]}'}'
          '; tools/test/tokens checks the bundled icon font has it …',
    )
    ..add(doubleLiteral(num.parse(m[3]!)), name: '${member}Size', doc: '… dp …')
    ..add(
      colorLiteral(parseCssColor(m[4]!)),
      name: '${member}Color',
      doc: '… in this colour.',
    );
  if (m[5] != null) {
    l.add(
      doubleLiteral(num.parse(m[5]!)),
      name: '${member}Weight',
      doc:
          'The design draws it at this weight; the bundled icon font is a '
          'static cut at AppFontTokens.iconWeight.',
    );
  }
}

/// A font followed by a `text-shadow`: the style with its one shadow.
String _fontWithTextShadow(_Leaf l, String font, String shadow) {
  final style = textStyleLiteral(l.t, _fontOf(l, font), l.path);
  return '${style.substring(0, style.length - 1)}, '
      'shadows: [${_textShadowLiteral(l, shadow)}])';
}

/// `Shadow(…)` for a CSS `text-shadow` layer (`0 2px 0 rgba(…)`).
String _textShadowLiteral(_Leaf l, String css) {
  final layers = parseBoxShadowList(css);
  if (layers.length != 1 || layers.single.inset || layers.single.spread != 0) {
    throw TokenFormatException(l.path, 'a text-shadow is one plain layer');
  }
  final s = layers.single;
  return 'Shadow(color: ${colorLiteral(s.color)}, '
      'offset: ${offsetLiteral(s.dx, s.dy)}'
      '${s.blur == 0 ? '' : ', blurRadius: ${doubleLiteral(s.blur)}'})';
}

/// `easeOut` (or `motion.easing.easeOut`) as its UiMotionTokens curve.
String _curve(_Leaf l, String name) =>
    _easing(l, name.startsWith('motion.easing.') ? name.substring(14) : name);

/// `one line, scales to <n>[, then wraps]`: a min scale.
void Function(_Leaf) _minScale(String tail) => (l) {
  final m = l.match('one line, scales to ([\\d.]+)$tail');
  l.add(
    doubleLiteral(num.parse(m[1]!)),
    name: '${l.member}MinScale',
    doc:
        'One line, scaling down to this${tail.isEmpty ? '' : ', then it '
                  'wraps'} (`${l.text}`).',
  );
};

/// The widget's art sizes from `habits.widget.art.files`, by file.
Map<String, void Function(_Leaf)> _widgetArtFiles() => {
  for (final (file, member) in const [
    ('flame_lit.svg', 'artFlameLitSize'),
    ('flame_unlit.svg', 'artFlameUnlitSize'),
    ('flame_unlit_dark.svg', 'artFlameUnlitDarkSize'),
    ('doll.svg', 'artDollSize'),
    ('daily_mark.svg', 'artDailyMarkSize'),
  ])
    'habits.widget.art.files.$file': (l) {
      final value = l.t.peek(l.path);
      final String size;
      if (value is num) {
        l.t.number(l.path, symbol: l.symbol(member));
        size = sizeLiteral(value, value);
      } else {
        final wh = l.t.numbers(l.path, symbol: l.symbol(member), length: 2);
        size = sizeLiteral(wh[0], wh[1]);
      }
      l.c.add(
        member,
        size,
        doc:
            '`ui/widget/$file` is drawn at this dp size (native, '
            'plan-local-habits §4; the 1×/2×/3× PNGs are this × 1, 2, 3).',
      );
    },
};

/// The m7-6 parsers for the prose values whose numbers the app needs.
final Map<String, void Function(_Leaf)> _m76Specials = {
  // ---- Part 2 additions to existing sections ----
  // Item 3 (keep): Pause in every strip form.
  'layout.rivalStrip.forms.pause': (l) {
    final m = l.match(
      r'm7-6 \(item 3\): Pause stays (\d+) × (\d+) \(HudTokens\.'
      r'pauseButtonSize\) in every form; on the (\d+) dp strip it centres '
      r'vertically \(top \+ (\d+)\)\. 9\.3i redrawn',
    );
    final pause = l.t.peek('layout.hud.pauseButton');
    final n = [for (var i = 1; i <= 4; i++) num.parse(m[i]!)];
    if (pause is! List<Object?> ||
        pause[0] != n[0] ||
        pause[1] != n[1] ||
        n[2] != _num(l, 'layout.rivalStrip.forms.heightAt13') ||
        (n[2] - n[1]) / 2 != n[3]) {
      throw TokenFormatException(
        l.path,
        'is not HudTokens.pauseButtonSize centred on forms.heightAt13',
      );
    }
    l.add(
      doubleLiteral(n[3]),
      name: 'formsPauseTop',
      doc:
          'Pause stays HudTokens.pauseButtonSize in every strip form; on '
          'the [formsHeightAt13] strip it sits this far down, centred '
          '(m7-6 item 3, 9.3i).',
    );
  },
  // Item 8: the flat brass name plate (6.1c).
  'layout.museum.cabinet.namePlate': (l) {
    final m = l.match(
      '$_font on flat brass: linear-gradient\\(180deg, (\\w+) $_color, '
      '(\\w+) $_color\\), (inset 0 1px 0 $_color), (0 2px 0) (\\w+) '
      '$_color, radius $_nr, padding $_nr/$_nr\\. No shine, no extra '
      'saturation: 6\\.1c is the spec \\(m7-6, item 8\\)',
    );
    for (final (name, color) in [
      (m[2]!, m[3]!),
      (m[4]!, m[5]!),
      (m[9]!, m[10]!),
    ]) {
      final named = l.t.has('color.$name') ? l.t.peek('color.$name') : null;
      if (named is! String || parseCssColor(named) != parseCssColor(color)) {
        throw TokenFormatException(l.path, 'its $name is not color.$name');
      }
    }
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
        doc: 'The name plate\'s text (m7-6 item 8: flat brass, 6.1c).',
      )
      ..add(
        linearGradientLiteral(
          parseCssLinearGradient('linear-gradient(180deg, ${m[3]}, ${m[5]})'),
          l.path,
        ),
        name: '${l.member}Face',
        doc:
            'The plate\'s flat brass: AppColorTokens.${m[2]} → ${m[4]}, no '
            'shine and no extra saturation.',
      )
      ..add(
        shadowListLiteral(parseBoxShadowList('${m[6]}, ${m[8]} ${m[10]}')),
        name: '${l.member}Shadow',
        type: 'List<NestyShadow>',
        doc: 'A 1 dp white top and a 2 dp AppColorTokens.${m[9]} edge.',
      )
      ..add(doubleLiteral(num.parse(m[11]!)), name: '${l.member}Radius')
      ..add(
        edgeInsetsLiteral([num.parse(m[12]!), num.parse(m[13]!)], l.path),
        name: '${l.member}Padding',
      );
  },
  // Item 17: pointers only.
  'layout.splash.errors.dim': _checked(
    'a pointer (m7-6 item 17): the error views\' dim is '
    'AppColorTokens.scrimLight (checked)',
    (l, text) {
      final m = RegExp(
        '^color\\.scrimLight: $_color, the #3C1E0A at 35 % of 12\\.10 and '
        '12\\.11\$',
      ).firstMatch(text);
      final scrim = l.t.peek('color.scrimLight');
      return m != null &&
          scrim is String &&
          parseCssColor(scrim) == parseCssColor(m[1]!);
    },
  ),
  'layout.splash.errors.icons': _checked(
    'a pointer (m7-6 item 17): the error views\' glyphs are '
    'icons.storageError and icons.contentError (checked)',
    (l, text) {
      final m = RegExp(
        r'^icons\.storageError \((\w+)\) and icons\.contentError \((\w+)\), '
        r'named since m7-4$',
      ).firstMatch(text);
      return m != null &&
          l.t.peek('icons.storageError') == m[1] &&
          l.t.peek('icons.contentError') == m[2];
    },
  ),
  // Item 9 (keep).
  'gift.tally.shortPhone': _checked(
    'behaviour on short phones (m7-6 item 9, keep): the tally may cover '
    'the dimmed chapter card for its visit (GiftTallyTokens.holdMs, '
    'checked); it never steps aside',
    (l, text) {
      final m = RegExp(
        r'^m7-6 \(item 9, keep\): on short phones the tally may cover the '
        r'dimmed chapter card for its ([\d.]+) s visit \(13\.5b, 13\.6d\); '
        r'it never steps aside$',
      ).firstMatch(text);
      return m != null &&
          double.parse(m[1]!) * 1000 == _num(l, 'gift.tally.holdMs');
    },
  ),
  // The text-fit rules of the habits and the widget.
  'textFit.habitsWelcome.title': _minScale(', then wraps'),
  'textFit.habitsWelcome.body': (l) {
    final m = l.match(r'(\w+) lines, then (habits_welcome_\*_short)');
    final lines = _numberWords[m[1]];
    if (lines == null) throw TokenFormatException(l.path, 'a line count');
    l.add(
      '$lines',
      name: '${l.member}MaxLines',
      doc:
          'The body takes this many lines, then the short forms '
          '`${m[2]}` (copy.md `## Short forms`).',
    );
  },
  'textFit.habitsWelcome.play': (l) {
    final m = l.match(
      r'at ([\d.]+)× text or with a short body the Play pill moves under '
      r'the text',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: '${l.member}UnderAtTextScale',
      doc:
          'From this text scale, or with a short body, the Play pill moves '
          'under the text (HabitsWelcomeTokens.playUnderGap).',
    );
  },
  'textFit.habitsMonth.title': _minScale(''),
  'textFit.habitsMonth.hint': (l) {
    final m = l.match(
      r'one line, then (habits_month_hint_short), then (\w+) '
      r'lines',
    );
    final lines = _numberWords[m[2]];
    if (lines == null) throw TokenFormatException(l.path, 'a line count');
    l
      ..add(
        '[${stringLiteral(m[1]!)}]',
        name: '${l.member}Short',
        type: 'List<String>',
        doc: 'One line, then this short form (the ARB key) …',
      )
      ..add(
        '$lines',
        name: '${l.member}MaxLines',
        doc: '… then this many lines.',
      );
  },
  'textFit.habitsMonth.weekdays': (l) {
    final m = l.match(
      r'abbreviated stand-alone names; the narrow form when one doesn’t fit '
      r'its column at ([\d.]+)',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: '${l.member}MinScale',
      doc:
          'The weekday names are the abbreviated stand-alone ones; when one '
          'does not fit its column at this scale, the narrow form.',
    );
  },
  'textFit.widget.line': (l) {
    final m = l.match(r'(\w+) lines, then ellipsis');
    l.add(
      '${_numberWords[m[1]] ?? (throw TokenFormatException(l.path, 'lines'))}',
      name: '${l.member}MaxLines',
      doc: 'The widget\'s line: this many lines, then an ellipsis (native).',
    );
  },
  'textFit.widget.title': (l) {
    final m = l.match(r'(\w+) line, ellipsis');
    l.add(
      '${_numberWords[m[1]] ?? (throw TokenFormatException(l.path, 'lines'))}',
      name: '${l.member}MaxLines',
      doc: 'The widget\'s title: one line, then an ellipsis (native).',
    );
  },
  'textFit.widget.number': (l) {
    final m = l.match(
      r'never scales below ([\d.]+); 1000\+ uses the locale’s grouping',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: '${l.member}MinScale',
      doc:
          'The widget\'s streak number never scales below this; 1000+ uses '
          'the locale\'s grouping (native).',
    );
  },

  // ---- The Computer tag (Part 2 item 2) ----
  'versus.computerTag.glyph': _renamed(
    'glyphSize',
    'The `computer` glyph\'s size at 1× text, dp',
  ),
  'versus.computerTag.face': (l) {
    final m = l.match('$_color, ring ${_nr}px $_color');
    l
      ..add(colorLiteral(parseCssColor(m[1]!)), doc: 'The tag\'s face …')
      ..add(
        strokeLiteral(_strokeOf(l, m[2]!, m[3]!)),
        name: 'ring',
        doc: '… and its ring.',
      );
  },
  'versus.computerTag.scale': (l) {
    final m = l.match(
      r'm7-6 \(item 2\): one tag for every rival surface, scaled with the '
      r'text setting: height (\d+)k, glyph (\d+)k, text (\d+)k, radius '
      r'(\d+)k, k = text scale up to ([\d.]+)\. Where a surface can’t grow, '
      r'it drops to its glyph first \(textFit\.rivalNames\)',
    );
    const p = 'versus.computerTag';
    final text = tryParseFontSpec('${l.t.peek('$p.text')}');
    if (num.parse(m[1]!) != _num(l, '$p.height') ||
        num.parse(m[2]!) != _num(l, '$p.glyph') ||
        text == null ||
        num.parse(m[3]!) != text.size ||
        num.parse(m[4]!) != _num(l, '$p.radius')) {
      throw TokenFormatException(l.path, 'is not the tag\'s own sizes');
    }
    l.add(
      doubleLiteral(num.parse(m[5]!)),
      name: 'maxTextScale',
      doc:
          'Every rival surface\'s tag scales its height, glyph, text and '
          'radius with the text scale k, up to this (m7-6 item 2); where a '
          'surface can\'t grow it drops to its glyph first '
          '(TextFitTokens.rivalNames*).',
    );
  },

  // ---- The welcome card (14.1) ----
  'habits.welcomeBack.when': _checked(
    'a rule, never read from tokens: RemoteConfigKeys.welcomeBackDays '
    '(default 2) and WelcomeBackRules; the Daily must be unlocked and '
    'today\'s puzzle unsolved (B-habits)',
    (l, text) =>
        text ==
        'the app opens after two or more days away, the Daily is unlocked '
            'and today’s puzzle isn’t solved',
  ),
  'habits.welcomeBack.variants.freeze': _copyAfterColon('habits_welcome_'),
  'habits.welcomeBack.variants.paused': _copyAfterColon('habits_welcome_'),
  'habits.welcomeBack.variants.new': _copyAfterColon('habits_welcome_'),
  'habits.welcomeBack.place.rule': (l) {
    final m = l.match(
      r'an inline card under the chapter card, left/right (\d+), top = '
      r'chapterCard\.top \+ (\d+)\. The five dolls scale about the plank '
      r'centre so the tallest clears the card’s bottom edge by (\d+) dp at '
      r'the top of its bob; below ([\d.]+) they fade out and the empty '
      r'plank stays',
    );
    final below = num.parse(m[2]!);
    const p = 'habits.welcomeBack.place';
    if (_num(l, 'layout.home.chapterCard.top') + below !=
            _num(l, '$p.h844.top') ||
        _num(l, 'layout.homeShort.chapterCard') + below !=
            _num(l, '$p.h693.top') ||
        _num(l, '$p.h844.dollScale') < num.parse(m[4]!)) {
      throw TokenFormatException(
        l.path,
        'is not layout.home(Short).chapterCard.top + the offset, or the 844 '
        'doll scale fades',
      );
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'placeSide',
        doc:
            'The card sits under the chapter card, this far from each '
            'side …',
      )
      ..add(
        doubleLiteral(below),
        name: 'placeBelowChapterCardTop',
        doc:
            '… its top this far below the chapter card\'s top '
            '(HomeTokens.chapterCardTop, HomeShortTokens.chapterCard; checked against '
            '[placeH844Top] and [placeH693Top]).',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'placeDollClearance',
        doc:
            'The five dolls scale about the plank centre so the tallest '
            'clears the card\'s bottom edge by this at the top of its bob …',
      )
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: 'placeDollFadeBelow',
        doc: '… and below this scale they fade out; the empty plank stays.',
      );
  },
  'habits.welcomeBack.disc.freeze.glyph': (l) => _glyphLook(l, l.text),
  'habits.welcomeBack.disc.paused.glyph': (l) => _glyphLook(l, l.text),
  'habits.welcomeBack.disc.new.glyph': (l) => _glyphLook(l, l.text),
  'habits.welcomeBack.disc.freeze.badge': (l) {
    final m = l.match(
      '(\\d+) dp $_color disc, ring (0 0 0 ${_nr}px $_color), edge '
      '(0 ${_nr}px 0 ${_nr}px $_color), ([a-z_]+) (\\d+) $_color, at right '
      '(−?\\d+) / bottom (−?\\d+)',
    );
    num signed(String v) => num.parse(v.replaceAll('−', '-'));
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'discFreezeBadgeSize',
        doc: 'The freeze badge on the disc: a disc this big …',
      )
      ..add(
        colorLiteral(parseCssColor(m[2]!)),
        name: 'discFreezeBadgeFace',
        doc: '… in this colour …',
      )
      ..add(
        shadowListLiteral(parseBoxShadowList('${m[3]}, ${m[6]}')),
        name: 'discFreezeBadgeShadow',
        type: 'List<NestyShadow>',
        doc: '… ringed and edged so …',
      )
      ..add(
        stringLiteral(m[10]!),
        name: 'discFreezeBadgeGlyph',
        doc: '… with the `${m[10]}` glyph (`NestyIcons`) …',
      )
      ..add(doubleLiteral(num.parse(m[11]!)), name: 'discFreezeBadgeGlyphSize')
      ..add(
        colorLiteral(parseCssColor(m[12]!)),
        name: 'discFreezeBadgeGlyphColor',
      )
      ..add(
        doubleLiteral(signed(m[13]!)),
        name: 'discFreezeBadgeRight',
        doc: 'The badge\'s right edge from the disc\'s (negative: outside) …',
      )
      ..add(
        doubleLiteral(signed(m[14]!)),
        name: 'discFreezeBadgeBottom',
        doc: '… and its bottom edge from the disc\'s.',
      );
  },
  'habits.welcomeBack.body': (l) {
    final m = l.match('$_font; (\\w+) lines, then the short form');
    final fit = '${l.t.peek('textFit.habitsWelcome.body')}';
    if (!fit.startsWith('${m[2]} lines,')) {
      throw TokenFormatException(l.path, 'is not textFit.habitsWelcome.body');
    }
    l.add(
      textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
      doc:
          'The body: ${m[2]} lines, then the short form '
          '(TextFitTokens.habitsWelcomeBodyMaxLines).',
    );
  },
  'habits.welcomeBack.play.label': (l) {
    final m = l.match('$_font, text-shadow (0 \\d+px 0 $_color)');
    l.add(_fontWithTextShadow(l, m[1]!, m[2]!), doc: '`${l.text}`.');
  },
  'habits.welcomeBack.play.triangle': (l) {
    final m = l.match('$_nr × $_nr $_color');
    l
      ..add(
        sizeLiteral(num.parse(m[1]!), num.parse(m[2]!)),
        doc: 'The Play pill\'s triangle …',
      )
      ..add(
        colorLiteral(parseCssColor(m[3]!)),
        name: '${l.member}Color',
        doc: '… in this colour.',
      );
  },
  'habits.welcomeBack.play.place': (l) {
    final m = l.match(
      r'bottom (\d+), right (\d+); the text keeps clear of it\. At ([\d.]+)× '
      r'text or with a short body it moves under the text, right-aligned, '
      r'(\d+) below',
    );
    final fit = '${l.t.peek('textFit.habitsWelcome.play')}';
    if (!fit.startsWith('at ${m[3]}× text')) {
      throw TokenFormatException(l.path, 'is not textFit.habitsWelcome.play');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'playBottom',
        doc: 'The Play pill sits this far from the card\'s bottom …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'playRight',
        doc: '… and right; the text keeps clear of it.',
      )
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: 'playUnderGap',
        doc:
            'From TextFitTokens.habitsWelcomePlayUnderAtTextScale, or with '
            'a short body, the pill moves under the text, right-aligned, '
            'this far below.',
      );
  },
  'habits.welcomeBack.dismiss.face': _renamed(
    'dismissFaceSize',
    'The close button\'s disc, dp',
  ),
  'habits.welcomeBack.dismiss.place': (l) {
    final m = l.match(
      r'top (\d+), right (\d+); the target is centred on the disc',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'dismissTop',
        doc: 'The close disc sits this far from the card\'s top …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'dismissRight',
        doc: '… and right; its [dismissTarget] is centred on the disc.',
      );
  },
  'habits.welcomeBack.dismiss.glyph': (l) => _glyphLook(l, l.text),
  'habits.welcomeBack.motion.in': (l) {
    final m = l.match(
      r'with Home’s first frame \(never later, on its own\): opacity 0 → 1 '
      r'and translateY (\d+) → 0, (\d+) ms (motion\.easing\.\w+); the dolls '
      r'are drawn at their scale from the start',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'motionInRise',
        doc:
            'With Home\'s first frame (never later, never on its own) the '
            'card fades in and rises from this far down …',
      )
      ..add(m[2]!, name: 'motionInMs', doc: '… over this …')
      ..add(
        _curve(l, m[3]!),
        name: 'motionInCurve',
        type: 'Cubic',
        doc: '… so; the dolls are drawn at their scale from the start.',
      );
  },
  'habits.welcomeBack.motion.out': (l) {
    final m = l.match(
      r'on the close: opacity 1 → 0 and scale 1 → ([\d.]+), (\d+) ms (\w+); '
      r'then the dolls grow back to 1 in (\d+) ms \((\w+)\), or fade in over '
      r'(\d+) ms where they had faded out',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'motionOutScale',
        doc: 'On the close the card fades out and shrinks to this …',
      )
      ..add(m[2]!, name: 'motionOutMs', doc: '… over this …')
      ..add(_curve(l, m[3]!), name: 'motionOutCurve', type: 'Cubic')
      ..add(
        m[4]!,
        name: 'motionDollsGrowMs',
        doc: 'Then the dolls grow back to 1 over this …',
      )
      ..add(_curve(l, m[5]!), name: 'motionDollsGrowCurve', type: 'Cubic')
      ..add(
        m[6]!,
        name: 'motionDollsFadeInMs',
        doc: '… or fade in over this where they had faded out.',
      );
  },
  'habits.welcomeBack.reducedMotion.in': (l) {
    final m = l.match(r'opacity only, (\d+) ms');
    l.add(m[1]!, name: 'reducedMotionInMs', doc: 'Reduce motion: a fade in.');
  },
  'habits.welcomeBack.reducedMotion.out': (l) {
    final m = l.match(
      r'opacity only, (\d+) ms; the dolls cross-fade to full size in (\d+) ms',
    );
    l
      ..add(
        m[1]!,
        name: 'reducedMotionOutMs',
        doc: 'Reduce motion: a fade out …',
      )
      ..add(
        m[2]!,
        name: 'reducedMotionDollsMs',
        doc: '… then the dolls cross-fade to full size over this.',
      );
  },
  'habits.welcomeBack.sound': _checked(
    'the card and its close play SoundTokens.habitsTap (checked)',
    (l, text) =>
        text == 'sound.events.habitsTap on the card and the close' &&
        l.t.has('sound.events.habitsTap'),
  ),
  'habits.welcomeBack.haptic': _checked(
    'the card and its close play haptics.habitsTap (HapticsService, '
    'checked)',
    (l, text) => text == 'haptics.habitsTap' && l.t.has('haptics.habitsTap'),
  ),

  // ---- The month (14.2) ----
  'habits.month.place': (l) {
    final m = l.match(
      r'the last card of the Daily’s scroll, under today’s puzzle card: top '
      r'(\d+) on 844 \((\d+) under its edge\), (\d+) on 693\. On open its '
      r'title peeks under Play\. Once scrolled, the header keeps the canvas '
      r'behind it with a (\d+) dp fade \(to (\d+) on 844, (\d+) on 693\)',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'top',
        doc:
            'The month is the last card of the Daily\'s scroll; on open its '
            'top is here (its title peeks under Play) …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'gapBelowPuzzleCard',
        doc: '… this far under today\'s puzzle card …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'topShort',
        doc: '… and here on 16:9.',
      )
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: 'headerFade',
        doc:
            'Once scrolled, the screen header keeps the canvas behind it '
            'with a fade this tall …',
      )
      ..add(
        doubleLiteral(num.parse(m[5]!)),
        name: 'headerFadeTo',
        doc: '… ending this far down …',
      )
      ..add(
        doubleLiteral(num.parse(m[6]!)),
        name: 'headerFadeToShort',
        doc: '… (this on 16:9).',
      );
  },
  'habits.month.header.title': (l) {
    final m = l.match(
      '$_font: the stand-alone month name \\((L+)\\), first letter '
      'capitalised',
    );
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
        doc: 'The month\'s name, first letter capitalised …',
      )
      ..add(
        stringLiteral(m[2]!),
        name: '${l.member}DateSkeleton',
        doc: '… the stand-alone month name (intl skeleton).',
      );
  },
  'habits.month.header.chip.glyph': (l) {
    final m = l.match(r'([a-z_]+) / ([a-z_]+) (\d+)');
    l
      ..add(
        stringLiteral(m[1]!),
        name: '${l.member}Previous',
        doc: 'The ‹ chip\'s `${m[1]}` glyph (`NestyIcons`) …',
      )
      ..add(
        stringLiteral(m[2]!),
        name: '${l.member}Next',
        doc: '… the › chip\'s `${m[2]}` …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: '${l.member}Size',
        doc: '… at this size, dp.',
      );
  },
  'habits.month.grid.pitch': (l) {
    final m = l.match(
      r'min\((\d+), floor\(\(screen width − (\d+)\) / 7\)\): (\d+) at 390, '
      r'(\d+) at 360',
    );
    final max = num.parse(m[1]!);
    final inset = num.parse(m[2]!);
    num pitch(num width) => math.min(max, ((width - inset) / 7).floor());
    if (pitch(390) != num.parse(m[3]!) || pitch(360) != num.parse(m[4]!)) {
      throw TokenFormatException(l.path, 'its examples disagree');
    }
    l
      ..add(
        doubleLiteral(max),
        name: 'gridPitchMax',
        doc:
            'A day column is min([gridPitchMax], floor((screen width − '
            '[gridPitchInset]) / 7)) wide: ${m[3]} at 390, ${m[4]} at 360.',
      )
      ..add(doubleLiteral(inset), name: 'gridPitchInset');
  },
  'habits.month.grid.face': (l) {
    final m = l.match(
      r'min\((\d+), pitch − (\d+)\): (\d+) at 390, (\d+) at 360',
    );
    final max = num.parse(m[1]!);
    final inset = num.parse(m[2]!);
    final pitch = l.t.peek('habits.month.grid.pitch');
    final p = pitch is String
        ? RegExp(r': (\d+) at 390, (\d+) at 360$').firstMatch(pitch)
        : null;
    if (p == null ||
        math.min(max, num.parse(p[1]!) - inset) != num.parse(m[3]!) ||
        math.min(max, num.parse(p[2]!) - inset) != num.parse(m[4]!)) {
      throw TokenFormatException(l.path, 'its examples disagree with pitch');
    }
    l
      ..add(
        doubleLiteral(max),
        name: 'gridFaceMax',
        doc:
            'A day\'s face is min([gridFaceMax], pitch − [gridFaceInset]): '
            '${m[3]} at 390, ${m[4]} at 360.',
      )
      ..add(doubleLiteral(inset), name: 'gridFaceInset');
  },
  'habits.month.grid.rowHeight': (l) {
    final m = l.match(r'face \+ (\d+)');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'gridRowOverFace',
      doc: 'A grid row is the face + this tall.',
    );
  },
  'habits.month.grid.radius': (l) {
    final m = l.match(r'(\d+) \((\d+) at a (\d+) face\)');
    if (num.parse(m[3]!) != _num(l, 'habits.month.short.face')) {
      throw TokenFormatException(l.path, 'its small face is not short.face');
    }
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'gridRadius',
        doc: 'A day\'s corner radius …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'gridRadiusSmall',
        doc: '… and at a [gridSmallFace] face.',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'gridSmallFace',
        doc: 'The face size that takes the small radius and number.',
      );
  },
  'habits.month.grid.number': (l) {
    final m = l.match(
      r'Fredoka (\d+)/1 tabular \((\d+) at a (\d+) face\): (\d{3}) on a '
      r'coloured face, (\d{3}) on a plain one',
    );
    if (num.parse(m[2]!) != _num(l, 'habits.month.short.number') ||
        num.parse(m[3]!) != _num(l, 'habits.month.short.face')) {
      throw TokenFormatException(l.path, 'is not short.number at short.face');
    }
    final font = tryParseFontSpec('Fredoka ${m[4]} ${m[1]}/1 tabular')!;
    l
      ..add(
        textStyleLiteral(l.t, font, l.path),
        doc:
            'A day\'s number, tabular; the colour and weight are its '
            'state\'s (`HabitsDayCellTokens.<state>Number*`): ${m[4]} on a '
            'coloured face, ${m[5]} on a plain one …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: '${l.member}SizeSmall',
        doc: '… at this size on a [gridSmallFace] face.',
      );
    textStyleLiteral(
      l.t,
      tryParseFontSpec('Fredoka ${m[5]} ${m[1]}/1')!,
      l.path,
    );
  },
  'habits.month.grid.target': _checked(
    'a day\'s target is its whole pitch × row height (checked against the '
    'grid formulas at 390 and 360)',
    (l, text) {
      final m = RegExp(
        r'^the whole pitch × row height \((\d+) × (\d+) at 390, (\d+) × '
        r'(\d+) at 360\)$',
      ).firstMatch(text);
      if (m == null) return false;
      final rowOver = RegExp(
        r'^face \+ (\d+)$',
      ).firstMatch('${l.t.peek('habits.month.grid.rowHeight')}');
      final face = RegExp(
        r': (\d+) at 390, (\d+) at 360$',
      ).firstMatch('${l.t.peek('habits.month.grid.face')}');
      final pitch = RegExp(
        r': (\d+) at 390, (\d+) at 360$',
      ).firstMatch('${l.t.peek('habits.month.grid.pitch')}');
      if (rowOver == null || face == null || pitch == null) return false;
      final over = int.parse(rowOver[1]!);
      return m[1] == pitch[1] &&
          int.parse(m[2]!) == int.parse(face[1]!) + over &&
          m[3] == pitch[2] &&
          int.parse(m[4]!) == int.parse(face[2]!) + over;
    },
  ),
  'habits.month.grid.fits360': _checked(
    'the grid fits 360 dp (checked: 7 columns at the 360 pitch inside the '
    'card less its padding)',
    (l, text) {
      final m = RegExp(
        r'^7 × (\d+) = (\d+) inside a (\d+) card with (\d+) dp padding$',
      ).firstMatch(text);
      if (m == null) return false;
      final card =
          360 -
          _num(l, 'habits.month.card.left') -
          _num(l, 'habits.month.card.right');
      final padding = l.t.peek('habits.month.card.padding');
      return 7 * int.parse(m[1]!) == int.parse(m[2]!) &&
          card == int.parse(m[3]!) &&
          padding is List<Object?> &&
          padding[1] == int.parse(m[4]!) &&
          card - 2 * int.parse(m[4]!) >= int.parse(m[2]!);
    },
  ),
  'habits.month.a11y': (l) {
    final m = l.match(
      r'each day is one element read as (habits_day_a11y_\*) with \{date\} = '
      r'(\w+); window days add (habits_day_a11y_open)',
    );
    l.add(
      stringLiteral(m[2]!),
      name: 'a11yDateSkeleton',
      doc:
          'Each day is one element read as `${m[1]}` with {date} in this '
          'intl skeleton; window days add `${m[3]}`.',
    );
  },
  // 16:9 (14.2b).
  'habits.month.short.title': _renamed(
    'titleSize',
    'The month\'s name on 16:9, dp',
  ),
  'habits.month.short.hint': (l) {
    final m = l.match('$_font, gap (\\d+)');
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
        doc:
            'The hint on 16:9 (the colour is HabitsMonthTokens.hintFont\'s) '
            '…',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'hintGap',
        doc: '… this far under the header.',
      );
  },
  'habits.month.short.weekdays': (l) {
    final m = l.match(r'gap (\d+), height (\d+)');
    l
      ..add(doubleLiteral(num.parse(m[1]!)), name: 'weekdaysGap')
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'weekdaysHeight');
  },
  'habits.month.short.face': _renamed('faceSize', 'A day\'s face on 16:9, dp'),
  'habits.month.short.number': _renamed(
    'numberSize',
    'A day\'s number on 16:9, dp',
  ),
  // The day cells.
  'habits.month.cell.freeze.glyph': (l) {
    final m = l.match(
      '([a-z_]+) (\\d+) $_color, (\\d+) from the bottom; the number lifts '
      '$_nr',
    );
    _glyphLook(l, '${m[1]} ${m[2]} ${m[3]}');
    l
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: '${l.member}Bottom',
        doc: 'The snowflake sits this far from the face\'s bottom …',
      )
      ..add(
        doubleLiteral(num.parse(m[5]!)),
        name: 'freezeNumberLift',
        doc: '… and the number lifts this far.',
      );
  },
  'habits.month.cell.raised': (l) {
    final m = l.match(
      r'inside the window every past cell adds its edge, 0 (\d+)px 0 <edge>, '
      r'and is a button; outside it is flat and not a button',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'raisedEdgeDepth',
      doc:
          'Inside the window every past day is a button raised on its '
          'state\'s `<state>Edge` this deep; outside it is flat and not a '
          'button.',
    );
  },
  'habits.month.cell.pressed': (l) {
    final m = l.match(
      r'translateY (\d+) with a (\d+) dp edge, (\d+) ms \(the house press\)',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'pressedShift',
        doc: 'Pressed, a day sinks this far …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'pressedEdgeDepth',
        doc: '… onto an edge this deep …',
      )
      ..add(m[3]!, name: 'pressedMs', doc: '… over this (the house press).');
  },
  'habits.month.cell.selected': (l) {
    final m = l.match(
      '(?:the chosen day): translateY (\\d+), no edge, rings '
      '(0 0 0 ${_nr}px $_color, 0 0 0 ${_nr}px $_color), while its card is '
      'open',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'selectedShift',
        doc:
            'The chosen day, while its card is open, sinks this far with no '
            'edge …',
      )
      ..add(
        shadowListLiteral(parseBoxShadowList(m[2]!)),
        name: 'selectedRings',
        type: 'List<NestyShadow>',
        doc: '… and wears these rings.',
      );
  },

  // ---- A past day (14.3) ----
  'habits.pastDay.card.place': (l) {
    final m = l.match(r'(\d+) under the month card');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'cardGapBelowMonth',
      doc: 'A past day\'s card opens this far under the month card.',
    );
  },
  'habits.pastDay.card.layout': (l) {
    final m = l.match(
      'the puzzle card of 5\\.1: title \\{date\\} \\((\\w+), $_font\\), the '
      'colours · tier chip, the (\\d+) dp preview, Play (\\d+) tall with no '
      'coin chip, then (habits_past_note) \\($_font, centred\\)',
    );
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'cardTitle',
        doc:
            'The puzzle card of 5.1 for a past day: its title, the date '
            '([cardTitleDateSkeleton]) …',
      )
      ..add(
        stringLiteral(m[1]!),
        name: 'cardTitleDateSkeleton',
        doc: '… in this intl skeleton …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'cardPreviewSize',
        doc: '… the colours · tier chip, the preview this big …',
      )
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: 'cardPlayHeight',
        doc: '… Play this tall with no coin chip …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[6]!), l.path),
        name: 'cardNote',
        doc: '… then `${m[5]}` (the ARB key), centred, in this style.',
      );
  },
  'habits.pastDay.open': (l) {
    final m = l.match(
      r'slides down (\d+) dp and fades in, (\d+) ms (\w+), and the page '
      r'scrolls just enough to show the note \((\d+) ms\)\. Reduced: a (\d+) '
      r'ms fade, and the scroll jumps',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'openSlide',
        doc: 'The card slides down this far and fades in …',
      )
      ..add(m[2]!, name: 'openMs', doc: '… over this …')
      ..add(_curve(l, m[3]!), name: 'openCurve', type: 'Cubic', doc: '… so;')
      ..add(
        m[4]!,
        name: 'openScrollMs',
        doc: 'the page scrolls just enough to show the note over this.',
      )
      ..add(
        m[5]!,
        name: 'openReducedMs',
        doc: 'Reduce motion: a fade this long, and the scroll jumps.',
      );
  },
  'habits.pastDay.solved.preview': (l) {
    final m = l.match(
      '(?:dimmed with) $_color under the green pill \\(5\\.5’s\\): '
      '(habits_past_solved_day) or (habits_past_solved_later)',
    );
    l.add(
      colorLiteral(parseCssColor(m[1]!)),
      name: 'solvedPreviewDim',
      doc:
          'A solved past day\'s preview is dimmed with this under 5.5\'s '
          'green pill, `${m[2]}` or `${m[3]}` (the ARB keys).',
    );
  },
  'habits.pastDay.solved.playAgain': (l) {
    final m = l.match(
      'the secondary button: (\\d+) tall, radius (\\d+), $_color, '
      '(inset 0 2px 0 $_color, 0 5px 0 $_color), ([a-z_]+) (\\d+) \\+ '
      '$_font',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'playAgainHeight',
        doc: 'Play again is the secondary button: this tall …',
      )
      ..add(doubleLiteral(num.parse(m[2]!)), name: 'playAgainRadius')
      ..add(colorLiteral(parseCssColor(m[3]!)), name: 'playAgainFace')
      ..add(
        shadowListLiteral(parseBoxShadowList(m[4]!)),
        name: 'playAgainShadow',
        type: 'List<NestyShadow>',
      )
      ..add(
        stringLiteral(m[7]!),
        name: 'playAgainGlyph',
        doc: 'The `${m[7]}` glyph (`NestyIcons`) …',
      )
      ..add(doubleLiteral(num.parse(m[8]!)), name: 'playAgainGlyphSize')
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[9]!), l.path),
        name: 'playAgainLabel',
        doc: '… and the label.',
      );
  },
  'habits.pastDay.board': (l) {
    final m = l.match(
      'NestyBoard scene daily with the past date in the Daily pill chip '
      '\\(\\{date\\} (\\w+)\\); no coin pill; a booster at 0 takes the '
      'disabled face \\($_color, (inset 0 2px 4px $_color), $_color\\) '
      'instead of ▶ or a price; Out of moves lists only what the player '
      'owns, plus Restart; no interstitial',
    );
    l
      ..add(
        stringLiteral(m[1]!),
        name: 'boardDateSkeleton',
        doc:
            'A past day\'s board shows its date in the Daily pill chip in '
            'this intl skeleton; no coin pill, no ▶ or price, Out of moves '
            'lists only what the player owns plus Restart, no interstitial.',
      )
      ..add(
        colorLiteral(parseCssColor(m[2]!)),
        name: 'boardBoosterDisabledFace',
        doc: 'A booster at 0 takes the disabled face …',
      )
      ..add(
        shadowListLiteral(parseBoxShadowList(m[3]!)),
        name: 'boardBoosterDisabledShadow',
        type: 'List<NestyShadow>',
      )
      ..add(
        colorLiteral(parseCssColor(m[5]!)),
        name: 'boardBoosterDisabledGlyphColor',
        doc: '… its glyph and count in this.',
      );
  },
  'habits.pastDay.win': (l) {
    final m = l.match(
      'the 5\\.4 layout: ribbon (habits_past_win_title), the Moves pill '
      '\\(([a-z_]+) (\\d+) $_color in a (\\d+) dp $_color disc, $_font\\) '
      'where the coins were, the date card where the streak card was \\(a '
      '(\\d+) dp cell\\.later with the day, \\{date\\} (\\w+) in $_font, '
      '(habits_past_win_line)\\), then Back to Daily, which lands on the '
      'month with the new mark\\. No coins, no ×3',
    );
    l
      ..add(
        stringLiteral(m[2]!),
        name: 'winMovesGlyph',
        doc:
            'A past day\'s win is 5.4\'s layout with `${m[1]}`: where the '
            'coins were, the Moves pill: the `${m[2]}` glyph (`NestyIcons`) '
            '…',
      )
      ..add(doubleLiteral(num.parse(m[3]!)), name: 'winMovesGlyphSize')
      ..add(colorLiteral(parseCssColor(m[4]!)), name: 'winMovesGlyphColor')
      ..add(
        doubleLiteral(num.parse(m[5]!)),
        name: 'winMovesDisc',
        doc: '… in a disc this big …',
      )
      ..add(colorLiteral(parseCssColor(m[6]!)), name: 'winMovesDiscColor')
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[7]!), l.path),
        name: 'winMovesText',
        doc: '… and the moves.',
      )
      ..add(
        doubleLiteral(num.parse(m[8]!)),
        name: 'winDateCell',
        doc:
            'Where the streak card was, the date card: a '
            'HabitsDayCellTokens.later* day this big …',
      )
      ..add(
        stringLiteral(m[9]!),
        name: 'winDateSkeleton',
        doc: '… the date in this intl skeleton …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[10]!), l.path),
        name: 'winDateText',
        doc:
            '… in this style, then `${m[11]}`; Back to Daily lands on the '
            'month with the new mark. No coins, no ×3.',
      );
  },
  'habits.pastDay.sound': _checked(
    'a past day\'s board plays the daily\'s sounds; its win plays '
    'SoundTokens.habitsPastWin (checked)',
    (l, text) =>
        text == 'the board as 5.3; the win plays sound.events.habitsPastWin' &&
        l.t.has('sound.events.habitsPastWin'),
  ),

  // ---- The home-screen widget (14.4), native ----
  ..._widgetArtFiles(),
  'habits.widget.ios.small': (l) {
    final wh = l.t.numbers(l.path, symbol: l.symbol('iosSmall'), length: 2);
    l.c.add(
      'iosSmall',
      sizeLiteral(wh[0], wh[1]),
      doc: 'systemSmall on a 390×844 iPhone (the system sets it per device).',
    );
  },
  'habits.widget.ios.medium': (l) {
    final wh = l.t.numbers(l.path, symbol: l.symbol('iosMedium'), length: 2);
    l.c.add(
      'iosMedium',
      sizeLiteral(wh[0], wh[1]),
      doc: 'systemMedium on a 390×844 iPhone.',
    );
  },
  'habits.widget.android.maxResizeHeight': (l) {
    final m = l.match(r'(\d+) cells');
    l.add(
      m[1]!,
      name: 'androidMaxResizeCells',
      doc: 'The Android widget resizes up to this many cells tall.',
    );
  },
  'habits.widget.android.resizeMode': (l) {
    l.match(r'(horizontal\|vertical)');
    l.add(
      stringLiteral(l.text),
      doc: 'The Android widget\'s `android:resizeMode`.',
    );
  },
  'habits.widget.android.layouts': (l) {
    final m = l.match(
      r'responsive RemoteViews: under (\d+) dp wide the 2 × 2 layout, from '
      r'(\d+) dp the 4 × 2',
    );
    if (m[1] != m[2]) throw TokenFormatException(l.path, 'two breakpoints');
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'androidMediumFrom',
      doc:
          'Responsive RemoteViews: from this width the 4 × 2 (medium) '
          'layout, under it the 2 × 2 (small).',
    );
  },
  'habits.widget.android.radius': (l) {
    final m = l.match(
      r'@android:dimen/system_app_widget_background_radius on 12\+ '
      r'\(clipToOutline true\), (\d+) dp before',
    );
    l.add(
      doubleLiteral(num.parse(m[1]!)),
      name: 'androidRadiusBefore12',
      doc:
          'Android 12+ uses system_app_widget_background_radius '
          '(clipToOutline); before it, this radius.',
    );
  },
  'habits.widget.layout.small.number': (l) {
    final m = l.match('$_font, (\\d+) after the flame, row (\\d+)');
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
        doc: 'The small widget\'s streak number …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: '${l.member}Gap',
        doc: '… this far after the flame …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: '${l.member}Row',
        doc: '… in a row this tall.',
      );
  },
  'habits.widget.layout.small.label': (l) {
    final m = l.match('$_font, (\\d+) below');
    l
      ..add(textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path))
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: '${l.member}Gap',
        doc: 'The label sits this far under the number row.',
      );
  },
  'habits.widget.layout.small.dolls': (l) {
    final m = l.match(
      r'(\d+) × (\d+), gap (\d+), (\d+) below the label, up to (\d+)',
    );
    l
      ..add(
        sizeLiteral(num.parse(m[1]!), num.parse(m[2]!)),
        name: '${l.member}Size',
        doc: 'The small widget\'s dolls: each this big …',
      )
      ..add(doubleLiteral(num.parse(m[3]!)), name: '${l.member}Gap')
      ..add(
        doubleLiteral(num.parse(m[4]!)),
        name: '${l.member}Top',
        doc: '… this far under the label …',
      )
      ..add(m[5]!, name: '${l.member}Max', doc: '… at most this many.');
  },
  'habits.widget.layout.small.line': (l) {
    final m = l.match('$_font at the bottom, (\\w+) lines');
    if (_numberWords[m[2]] == null ||
        !'${l.t.peek('textFit.widget.line')}'.startsWith('${m[2]} lines')) {
      throw TokenFormatException(l.path, 'is not textFit.widget.line');
    }
    l.add(
      textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
      doc:
          'The small widget\'s line, at the bottom '
          '(TextFitTokens.widgetLineMaxLines).',
    );
  },
  'habits.widget.layout.small.locked': (l) {
    final m = l.match(
      'daily_mark (\\d+) at the top; “Daily puzzle” $_font; the line $_font',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: '${l.member}Mark',
        doc: 'Locked (before Level 2): `daily_mark` this big at the top …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: '${l.member}Title',
        doc: '… the title …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[3]!), l.path),
        name: '${l.member}Line',
        doc: '… and the line.',
      );
  },
  'habits.widget.layout.medium.columns': (l) {
    final m = l.match(
      '(?:left) (\\d+) · (\\d+) · $_nr divider · (\\d+) · right',
    );
    if (m[2] != m[4]) throw TokenFormatException(l.path, 'two gaps');
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'layoutMediumLeft',
        doc: 'The medium widget: a left column this wide …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: 'layoutMediumGap',
        doc: '… this gap either side of …',
      )
      ..add(
        doubleLiteral(num.parse(m[3]!)),
        name: 'layoutMediumDivider',
        doc: '… a divider this thick, then the right column.',
      );
  },
  'habits.widget.layout.medium.left': (l) {
    final m = l.match(
      'flame (\\d+) at the top, the number $_font at the bottom, label '
      '$_font',
    );
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: 'layoutMediumFlame',
        doc: 'The left column: the flame this big at the top …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'layoutMediumNumber',
        doc: '… the number at the bottom …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[3]!), l.path),
        name: 'layoutMediumLabel',
        doc: '… and the label.',
      );
  },
  'habits.widget.layout.medium.right': (l) {
    final m = l.match(
      'title $_font \\(one line\\), sub $_font, dolls (\\d+) × (\\d+) gap '
      '(\\d+) \\((\\d+) below, up to (\\d+)\\), the line $_font at the '
      'bottom',
    );
    l
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[1]!), l.path),
        name: 'layoutMediumTitle',
        doc: 'The right column: the title (one line) …',
      )
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[2]!), l.path),
        name: 'layoutMediumSub',
        doc: '… the sub …',
      )
      ..add(
        sizeLiteral(num.parse(m[3]!), num.parse(m[4]!)),
        name: 'layoutMediumDollsSize',
        doc: '… the dolls, each this big …',
      )
      ..add(doubleLiteral(num.parse(m[5]!)), name: 'layoutMediumDollsGap')
      ..add(
        doubleLiteral(num.parse(m[6]!)),
        name: 'layoutMediumDollsTop',
        doc: '… this far under the sub …',
      )
      ..add(m[7]!, name: 'layoutMediumDollsMax', doc: '… at most this many …')
      ..add(
        textStyleLiteral(l.t, _fontOf(l, m[8]!), l.path),
        name: 'layoutMediumLine',
        doc: '… and the line at the bottom.',
      );
  },
  'habits.widget.layout.medium.locked': (l) {
    final m = l.match(r'daily_mark (\d+) in a (\d+) column');
    l
      ..add(
        doubleLiteral(num.parse(m[1]!)),
        name: '${l.member}Mark',
        doc: 'Locked: `daily_mark` this big …',
      )
      ..add(
        doubleLiteral(num.parse(m[2]!)),
        name: '${l.member}Column',
        doc: '… in a left column this wide.',
      );
  },
  for (final state in const ['ready', 'solved', 'paused', 'zero', 'locked'])
    'habits.widget.states.$state': _checked(
      'the widget\'s $state state: its art and copy.md ids (native, '
      'plan-local-habits §4)',
      (l, text) => RegExp(r'widget_[a-z_]+').hasMatch(text),
    ),
  // The widget's colours.
  for (final scheme in const ['light', 'dark'])
    'habits.widget.colors.$scheme.flameUnlit': _checked(
      'the $scheme widget\'s unlit flame art (ui/widget/; checked)',
      (l, text) => l.t.has('habits.widget.art.files.$text'),
    ),
  'habits.widget.colors.light.shadow': (l) {
    final m = l.match(r'(.+) \(Android; iOS draws its own\)');
    l.add(
      shadowListLiteral(parseBoxShadowList(m[1]!)),
      type: 'List<NestyShadow>',
      doc: 'The light widget\'s shadow on Android; iOS draws its own.',
    );
  },
  'habits.widget.colors.tinted.accent': (l) {
    final m = l.match('the system tint \\(frames show $_color\\)');
    l.add(
      colorLiteral(parseCssColor(m[1]!)),
      name: 'tintedAccentPreview',
      doc:
          'Tinted mode draws the accent in the system tint; the frames show '
          'this one.',
    );
  },
  'habits.widget.colors.tinted.unlitAccent': (l) {
    final m = l.match(r'the tint at (\d+) %');
    l.add(
      doubleLiteral(num.parse(m[1]!) / 100),
      name: 'tintedUnlitAccentOpacity',
      doc: 'Tinted mode: the unlit flame is the tint at this opacity.',
    );
  },
  'habits.widget.colors.tinted.text': (l) {
    final m = l.match(r'white at (\d+) %, labels at (\d+) %');
    String white(String percent) => colorLiteral(
      parseCssColor('rgba(255,255,255,${num.parse(percent) / 100})'),
    );
    l
      ..add(
        white(m[1]!),
        name: 'tintedText',
        doc: 'Tinted mode: the text in white at ${m[1]} % …',
      )
      ..add(
        white(m[2]!),
        name: 'tintedLabel',
        doc: '… and the labels at ${m[2]} %.',
      );
  },
};
