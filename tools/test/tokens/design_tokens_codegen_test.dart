import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/assets/design_asset_sync.dart';
import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/dart_source.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();
  final tokensJson = File(p.join(root.path, tokensJsonPath)).readAsStringSync();

  Map<String, Object?> tokens() =>
      jsonDecode(tokensJson) as Map<String, Object?>;

  group('parity with design/tokens.json', () {
    final output = generateDesignTokens(tokensJson);
    final allSource = output.files.values.join('\n');

    test('every leaf is emitted or explicitly documented', () {
      expect(output.reader.unaccounted, isEmpty);
      expect(output.reader.uses.keys.toSet(), leafPaths(tokens(), '').toSet());
    });

    test('every emitted symbol exists in the generated source', () {
      final missing = <String>[];
      for (final MapEntry(key: path, value: use)
          in output.reader.uses.entries) {
        if (use is! EmittedAs) continue;
        expect(use.symbols, isNotEmpty, reason: path);
        for (final symbol in use.symbols) {
          final [className, member] = symbol.split('.');
          final classStart = allSource.indexOf(
            'abstract final class $className {',
          );
          final classEnd = allSource.indexOf('\n}', classStart);
          final body = classStart == -1
              ? ''
              : allSource.substring(classStart, classEnd);
          // A display-family TextStyle is a DisplayFace getter (m7-5 28).
          if (!RegExp(
            'static const (?:[\\w<>, (){}?]+ )?$member = '
            '|static TextStyle get $member => ',
          ).hasMatch(body)) {
            missing.add('$path → $symbol');
          }
        }
      }
      expect(missing, isEmpty);
    });

    test('only the known prose leaves are documentation-only', () {
      final documented = {
        for (final MapEntry(key: path, value: use)
            in output.reader.uses.entries)
          if (use is DocumentedOnly) path,
      };
      // A new documentation-only leaf must be a deliberate decision: add it
      // here with the codegen change that documents it.
      expect(documented, {
        r'$description',
        'meta.units',
        'dollColorDerivation.note',
        'font.display.source',
        'font.body.source',
        'font.icon.source',
        'font.mono.family',
        'font.mono.use',
        'skin.tint',
        'motion.swallow',
        'sound.format',
        'sound.clackPitch.rule',
        'sound.music.home.screens',
        'sound.music.game.screens',
        'haptics.pick',
        'haptics.nest',
        'haptics.complete',
        'haptics.win',
        'haptics.invalid',
        'haptics.unlock',
        'haptics.iceCrack',
        'haptics.button',
        'haptics.respectsSetting',
        // Tokens v3 (m7-3). Design notes and item ids.
        'meta.updated',
        for (final section in [
          'layout.hud.familyCounter',
          'layout.hintArc',
          'layout.fallbackDoll',
          'layout.rivalStrip',
          'layout.raceBar',
          'layout.short169',
          'layout.winStars',
          'layout.winStarsShort',
          'layout.chestCard',
          'layout.home',
          'layout.homeShort',
          'layout.chapters',
          'layout.museum',
          'layout.records',
          'layout.rivalSelect',
          'layout.replayCard',
          'layout.hintMiddle',
          'layout.winTwinkles',
          'layout.generating',
          'motion.tapFeedback',
          'motion.dragHover',
          'motion.extraSlot',
          'motion.stars',
          'motion.rivalMove',
          'motion.toast',
          'motion.purchase',
          'icons',
          'shop',
          'chestModal',
          'settings',
          'textLink',
        ])
          '$section.\$note',
        for (final section in [
          'layout.boardFit',
          'layout.boardPresets',
          'layout.towerStack',
          'theme',
        ])
          '$section.\$description',
        // Formulas and rules of placement the hand-written code follows,
        // pinned word for word (documentedExact).
        'layout.board.glassCaseTall.art',
        'layout.board.glassCaseTall.lottie',
        'layout.boardFit.limits.vertical',
        'layout.boardFit.limits.hud',
        'layout.boardFit.limits.horizontal',
        'layout.boardFit.rule',
        'layout.boardFit.pickLift',
        'layout.towerStack.rule',
        'layout.towerStack.tag',
        'layout.icedTower.tag',
        'motion.tagPop.delay',
        'motion.rowOfFive.then',
        'motion.tapFeedback.emptyStand.haptic',
        'motion.dragHover.invalidTarget',
        'motion.stars.startAfter',
        'motion.stars.haptics',
        'motion.stars.reducedMotion',
        'motion.chest.reducedMotion',
        'motion.rivalMove.reducedMotion',
        'motion.chaptersFadeIn.reducedMotion',
        'motion.purchase.jingle',
        'motion.purchase.headerBalance',
        'layout.winStars.starsCanvas.lottie',
        'layout.chestCard.lottie.name',
        'layout.chestCard.lottie.anchor',
        'layout.hintMiddle.arrow',
        'chestModal.glow.showsOn',
        'settings.reduceMotion.control',
        // Worked examples, scene names, copy and art references.
        for (final preset in [
          'twoShelves',
          'threeShelves',
          'threeShelvesTall',
          'fourShelves',
          'rowOfFive',
        ]) ...[
          'layout.boardPresets.$preset.use',
          'layout.boardPresets.$preset.scenes',
        ],
        'layout.towerStack.examples.top shelf, size-4 top (117), 3 buried',
        'layout.towerStack.examples.top shelf, size-3 top (99), 3 buried',
        'layout.towerStack.examples.middle shelf, size-1 top (63), 3 buried',
        for (var ch = 1; ch <= 10; ch++)
          for (final key in [
            'id',
            'name',
            'ribbon',
            'levels',
            'file',
            'figurine',
          ])
            'theme.chapters.$ch.$key',
        'layout.home.chapterCard.accent',
        'layout.home.tiles.order',
        'icons.recordsRival',
        'icons.chestLevel',
        'icons.stars',
        // ui_chest's markers: FxSpec is their one source (pinned below).
        for (final segment in ['arrive', 'idle', 'wiggle', 'open', 'openIdle'])
          'motion.chest.segments.$segment',
        // Rules the design repeats: never read from tokens (policy 2; the
        // game's rule_tokens_test pins them), and the placement D172
        // overrides.
        'layout.extraSlot.placement',
        'layout.extraSlot.limitPerLevel',
        'settings.reduceMotion.default',
        // The ribbon's colours (m7-4) and the Computer tag's look (m7-6
        // item 2) are emitted.
        for (final leaf in leafPaths(tokens()['versus'], 'versus'))
          if (!leaf.startsWith('versus.ribbon.') &&
              !leaf.startsWith('versus.computerTag.'))
            leaf,
        // The +1 slot chip is look, not rule (m7-5): only its copy ids.
        for (final leaf in leafPaths(tokens()['chest'], 'chest'))
          if (!leaf.startsWith('chest.slotChip.')) leaf,
        ..._documentedV4(tokens()),
        ..._documentedV5,
        ..._documentedV6,
      });
    });

    test('spot-checks values against tokens.json', () {
      final render = output.files[renderTokensPath]!;
      final ui = output.files[uiTokensPath]!;
      expect(ui, contains('static const scrim = Color(0x8C3C1E0A);'));
      expect(ui, contains('static const xxl = 30.0;'));
      expect(render, contains('static const pickMs = 120;'));
      expect(
        render,
        contains(
          'static const curveEaseOutBack = '
          'Cubic(0.34, 1.56, 0.64, 1.0);',
        ),
      );
      expect(render, contains('rampInputExponent: 2.0'));
      expect(ui, contains('TokenStop.px(14.0)'));
      expect(ui, contains('fontFeatures: [FontFeature.tabularFigures()]'));
      expect(ui, contains('letterSpacing: 0.66'));
    });

    test('routes every display-family style through DisplayFace (m7-5 28)', () {
      final ui = output.files[uiTokensPath]!;
      // Fredoka styles are getters, so Turkish can draw them in Baloo 2.
      expect(ui, contains('static TextStyle get display => DisplayFace.of('));
      expect(
        RegExp(
          r"static const \w+ = TextStyle\(\s*fontFamily: 'Fredoka'",
        ).hasMatch(ui),
        isFalse,
      );
      // Nunito (body) styles stay const.
      expect(
        RegExp(
          r"static const \w+ = TextStyle\(\s*fontFamily: 'Nunito'",
        ).hasMatch(ui),
        isTrue,
      );
    });

    test('emits the script faces and their fallback on every style', () {
      final ui = output.files[uiTokensPath]!;
      expect(ui, contains("static const devaDisplayFamily = 'Baloo2Display';"));
      expect(
        ui,
        contains("static const jpanBodyFamily = 'MPLUSRounded1cBody';"),
      );
      expect(
        ui,
        contains(
          'static const Map<int, int> devaBodyWeights = '
          '{800: 700, 700: 600, 600: 500};',
        ),
      );
      expect(
        ui,
        contains(
          'static const Map<int, int> jpanDisplayWeights = {700: 800, 600: 700};',
        ),
      );
      expect(ui, contains('static const jpanSizeFactor = 0.94;'));
      expect(ui, contains('static const devaBodyLineHeight = 1.5;'));
      expect(ui, contains('static const jpanTitleLineHeight = 1.3;'));
      expect(ui, contains('static const jpanLetterSpacing = 0.0;'));
      expect(ui, isNot(contains('devaLetterSpacing')));
      expect(
        ui,
        contains(
          "static const List<String> displayFallback = ['Nunito', "
          "'Baloo2Display', 'MPLUSRounded1cDisplay'];",
        ),
      );
      expect(
        ui,
        contains(
          "static const List<String> bodyFallback = ['Fredoka', "
          "'Baloo2Body', 'MPLUSRounded1cBody'];",
        ),
      );
      // Every TextStyle, from the type scale and the screen sections alike,
      // lists its role's fallback (l10n.md §4.6).
      final styles = RegExp(r'TextStyle\(([^;]*?)\)').allMatches(ui).toList();
      expect(styles, isNotEmpty);
      for (final style in styles) {
        final body = style[1]!;
        final role = body.contains("fontFamily: 'Fredoka'")
            ? 'display'
            : 'body';
        expect(
          body,
          contains('fontFamilyFallback: AppFontTokens.${role}Fallback'),
          reason: body,
        );
      }
    });

    test('spot-checks the audio tokens (design/audio/AUDIO.md)', () {
      final ui = output.files[uiTokensPath]!;
      expect(
        ui,
        contains(
          "static const chapterComplete = SoundCue(['jingle_chapter']);",
        ),
      );
      expect(ui, contains('static const clackBakedSemitones = 0;'));
      expect(ui, contains('static const musicHome = \'music_home\';'));
      expect(ui, contains('static const musicHomeFrames = 2940000;'));
      expect(ui, contains('static const musicGameSeconds = 68.571;'));
      expect(ui, contains('static const musicFadeCrossfadeMs = 800;'));
      expect(ui, contains('static const musicDuckWin = 0.3;'));
      expect(ui, contains("'outOfMoves': 0.4,"));
      expect(ui, contains("static const jingleBus = 'sfx';"));

      // allFiles stays WAV-only: the jingles and loops are OGG lists.
      String listOf(String member) {
        final start = ui.indexOf('static const List<String> $member = [');
        return ui.substring(start, ui.indexOf('];', start));
      }

      expect(listOf('allFiles'), isNot(contains('jingle_')));
      expect(listOf('allFiles'), isNot(contains('music_')));
      expect(
        listOf('jingleFiles'),
        allOf(
          contains("'jingle_chapter'"),
          contains("'jingle_oom'"),
          contains("'jingle_reward'"),
        ),
      );
      expect(
        ui,
        contains(
          "static const List<String> musicFiles = ['music_game', 'music_home'];",
        ),
      );
    });

    test('spot-checks the owner decisions 3d and 3e', () {
      final render = output.files[renderTokensPath]!;
      expect(
        render,
        contains('static const revealWipeCenter = Offset(256.0, 476.0);'),
      );
      expect(render, contains('static const revealSplashDrops = 5;'));
      expect(
        render,
        contains("static const towerSilhouetteSprite = 'doll-silhouette';"),
      );
      expect(render, contains('static const towerDepthRaise = 18.0;'));
    });

    test('spot-checks tokens v3: the board (m7-3)', () {
      final render = output.files[renderTokensPath]!;
      expect(
        render,
        contains(
          'static const Map<int, List<double>> plankTopsByShelfCount = {3: '
          '[312.0, 498.0, 684.0], 2: [430.0, 650.0], 4: [253.0, 398.0, '
          '543.0, 688.0]};',
        ),
      );
      expect(
        render,
        contains(
          'static const List<double> plankTopsThreeShelvesTall = [300.0, '
          '494.0, 688.0];',
        ),
      );
      expect(render, contains('static const widthPerHeight = 0.62;'));
      expect(render, contains('static const minDollHeight = 117.5;'));
      expect(render, contains('static const iceTopFromPlank = 16.5;'));
      expect(render, contains('static const iceTallFxScaleY = 1.05;'));
      expect(render, contains('static const standPitchInset = 2.4;'));
      expect(
        render,
        contains(
          'limits: BoardFitLimits(vertical: 144.2, hud: 142.1, '
          'horizontal: 153.2)',
        ),
      );
      expect(render, contains('iceOverlay: Size(96.0, 168.0),'));
      expect(render, contains('standSurfaceOffset: 9.84,'));
      expect(render, contains('pipsScaled: false,'));
      expect(render, contains('static const extraSlotRestFrame = 0;'));
      expect(render, contains('static const rowOfFiveMs = 280;'));
      expect(
        render,
        contains('static const Cubic rowOfFiveCurve = curveEaseInOut;'),
      );
      expect(render, contains('static const dragHoverGlowOpacity = 0.6;'));
      expect(render, contains('static const iceTopGap = 8.0;'));
      expect(
        render,
        contains('static const safeArea = Rect.fromLTWH(105.0, 438.0'),
      );
      expect(
        render,
        contains('thumb: Rect.fromLTWH(105.0, 720.0, 1080.0, 506.0),'),
        reason: 'ch10',
      );
    });

    test('spot-checks tokens v3: the UI (m7-3)', () {
      final ui = output.files[uiTokensPath]!;
      expect(ui, contains('static const versus = LinearGradient('));
      expect(ui, contains('static const familyCounterGap = 5.0;'));
      expect(
        ui,
        contains(
          'static const familyCounterPadding = EdgeInsets.symmetric('
          'vertical: 7.0, horizontal: 10.0);',
        ),
      );
      expect(ui, contains("'12 / 12': 78.0"));
      expect(ui, contains('static const tagGlyph = \'computer\';'));
      expect(
        ui,
        contains('static const startGradient = AppGradientTokens.versus;'),
      );
      expect(ui, contains('static const List<int> hiddenSlots = [2, 3];'));
      expect(ui, contains('static const tilesColumns = 3;'));
      expect(ui, contains('static const stateThinkingPeriodMs = 1200;'));
      expect(ui, contains('static const newBestChipTopOffset = -16.0;'));
      expect(ui, contains('static const gapMs = 300;'));
      expect(ui, contains('static const badgeToastTop = 60.0;'));
      expect(ui, contains('static const glowRayPeriodDeg = 24.0;'));
      expect(ui, contains('static const glowMaskClear = 0.68;'));
      expect(ui, contains("'forest-bear': ShopSkinColors("));
      expect(ui, contains('static const star1 = SoundCue([\'star_1\']);'));
      expect(
        ui,
        contains("static const raceWon = SoundCue(['jingle_versus_win']);"),
      );
      expect(ui, contains('static const musicDuckRaceResult = 0.3;'));
      expect(ui, contains("static const shareIOS = 'ios_share';"));
      expect(
        ui,
        contains(
          'fontWeight: FontWeight.w800, '
          'fontFamilyFallback: AppFontTokens.bodyFallback, '
          'color: Color(0xFF9A6A44)',
        ),
      );
      expect(
        ui,
        isNot(contains('static const starEmpty =')),
        reason: 'tokens v3\'s art reference; v4 names colours',
      );
    });

    test('spot-checks tokens v4: the board and the themes (m7-4)', () {
      final render = output.files[renderTokensPath]!;
      expect(render, isNot(contains('oneShelf')), reason: 'tokens only');
      expect(render, contains('static const tallGlassPitchInset = 2.0;'));
      expect(render, contains('static const iceMaxOverlap = 3.0;'));
      expect(render, contains('static const arrowhead = false;'));
      expect(render, contains('static const headSize = 0.36;'));
      expect(render, contains('static const bellySize = 0.2;'));
      // Chapter 7's own wood and ribbon colours; chapter 1 shares board/.
      final ch07 = render.substring(
        render.indexOf('static const ch07 ='),
        render.indexOf('static const ch08 ='),
      );
      expect(ch07, contains('ribbonTail: Color(0xFFAA3A4D)'));
      expect(ch07, contains('ribbonFold: Color(0xFF681828)'));
      expect(ch07, contains("boardArtDir: 'board/ch07/'"));
      final ch01 = render.substring(
        render.indexOf('static const ch01 ='),
        render.indexOf('static const ch02 ='),
      );
      expect(ch01, contains('ribbonTail: Color(0xFFA46B0B)'));
      expect(ch01, isNot(contains('boardArtDir')));
    });

    test('spot-checks tokens v4: the UI (m7-4)', () {
      final ui = output.files[uiTokensPath]!;
      expect(ui, contains('static const version = 4;'));
      expect(ui, contains('static const sunkFace = Color(0xFFF3E6D2);'));
      expect(
        ui,
        contains('static const starEmptyOutline = Color(0xFFDDBE8E);'),
      );
      expect(ui, contains('static const scrimLight = Color(0x593C1E0A);'));
      expect(ui, contains('static const canvas = LinearGradient('));
      expect(ui, contains('static const List<NestyShadow> coinChipEdge = ['));
      expect(ui, contains('static const reminderSet = SoundCue([]);'));
      expect(ui, contains("static const storageError = 'sd_card_alert';"));
      expect(ui, contains('static const minTapHeight = 48.0;'));
      expect(ui, contains('static const accentPressed = Color(0xFFA94F12);'));
      expect(ui, contains('static const cardTop = 168.0;'));
      expect(ui, contains('static const artBox = Size(156.0, 130.0);'));
      expect(ui, contains('static const lottieScale = 1.2;'));
      expect(ui, contains('static const appTopBelowSafeTop = 4.0;'));
      expect(ui, contains('static const appTopOffset = -1.0;'));
      expect(ui, contains('static const appEdgeDepth = 4.0;'));
      expect(ui, contains('static const blockedActionsGap = 18.0;'));
      expect(
        ui,
        contains(
          'static const pauseHoleRect = Rect.fromLTWH(10.0, 56.0, 60.0, 60.0);',
        ),
      );
      // m7-6 (item 7): the 290 ribbon's 266 × 40 text box (was 312 × 40).
      expect(ui, contains('static const winRibbonBox = Size(266.0, 40.0);'));
      expect(ui, contains('static const gainTagOffset = Offset(12.0, -42.0);'));
      expect(ui, contains('static const tooltipTopShort = 30.0;'));
      expect(ui, contains('static const openScrollFinishedRows = 2;'));
      expect(ui, contains('static const foldedRowNameMinScale = 0.85;'));
      expect(ui, contains('static const statsGridCellIconTileSize = 36.0;'));
      expect(ui, contains('static const clampTop = 112.0;'));
      expect(ui, contains('static const trailingCoinPillHeight = 40.0;'));
      expect(
        ui,
        contains(
          'static const List<String> winRibbonShort = ['
          "'win_title_short', 'race_win_title_short',",
        ),
      );
      expect(ui, contains('static const versusColors = RibbonColors('));
      expect(
        ui,
        contains(
          "static const List<String> bandKeyPath = ['**', 'band_fill'];",
        ),
      );
      expect(ui, contains("'space': (face: Color(0xEBFFFFFF)"));
      // Line heights: a multiple (24/1.15) and px (16/23).
      final noCoins = ui.substring(
        ui.indexOf('abstract final class NoCoinsTokens'),
      );
      expect(noCoins, contains('fontSize: 24.0,'));
      expect(noCoins, contains('height: 1.15,'));
      expect(noCoins, contains('height: 1.4375,'));
      // Motion.
      expect(
        ui,
        contains(
          'static const List<double> trailSpacing = [0.1, 0.2, 0.3, 0.45, 0.6];',
        ),
      );
      expect(ui, contains('static const pillRingLastCoinMs = 1000;'));
      expect(ui, contains('static const glowMs = 2400;'));
      expect(ui, contains('static const reducedMotionPulseMs = 1600;'));
      expect(
        ui,
        contains('static const Cubic curve = UiMotionTokens.curveEaseOut;'),
      );
      expect(ui, contains('static const stripCanvasDp = 47.5;'));
      expect(ui, contains('static const sparkleCount = 3;'));
      expect(ui, contains("static const glyph = 'auto_awesome';"));
      expect(ui, contains('static const placeInset = -8.0;'));
      expect(ui, contains('static const familyCounterLottieWidth = 70.0;'));
    });

    test('every glyph the v4 tokens name is in the bundled font', () {
      final font = File(
        p.join(root.path, 'tools/fonts/nesty_symbols.txt'),
      ).readAsLinesSync().map((l) => l.trim()).toSet();
      final ui = output.files[uiTokensPath]!;
      final glyphs = [
        for (final m in RegExp(
          r"static const (?:glyph|storageError|contentError) = '([a-z0-9_]+)';",
        ).allMatches(ui))
          m[1]!,
      ];
      expect(glyphs, containsAll(['auto_awesome', 'sd_card_alert']));
      expect(font, containsAll(glyphs));
    });

    test('spot-checks tokens v5: the Turkish face (m7-5 item 28)', () {
      final ui = output.files[uiTokensPath]!;
      expect(ui, contains("static const latnTrFamily = 'Baloo2LatnTr';"));
      expect(ui, contains("static const List<String> latnTrLocales = ['tr'];"));
      expect(
        ui,
        contains(
          'static const Map<int, int> latnTrDisplayWeights = '
          '{700: 700, 600: 600, 500: 500};',
        ),
      );
      expect(ui, contains('static const latnTrSizeFactor = 1.0;'));
      expect(ui, contains('static const latnTrTitleLineHeight = 1.15;'));
      // Whole strings, never per glyph: in no fallback list, and no
      // per-role families (the fallback lists are checked above).
      expect(ui, isNot(contains('latnTrDisplayFamily')));
      expect(ui, isNot(contains('latnTrBodyFamily')));
      expect(ui, isNot(contains("'Baloo2LatnTr', ")));
    });

    test('spot-checks tokens v5: the type index (m7-5 item 2)', () {
      final ui = output.files[uiTokensPath]!;
      for (final surface in [
        'Home',
        'Chapters',
        'Museum',
        'Records',
        'Shop',
        'Gift',
      ]) {
        expect(ui, contains('abstract final class ${surface}TypeTokens {'));
      }
      String member(String className, String name) {
        final start = ui.indexOf('abstract final class $className {');
        // A display-family TextStyle is a DisplayFace getter (m7-5 28).
        final at = ui.indexOf(
          RegExp('static (const|TextStyle get) $name (=|=>) '),
          start,
        );
        expect(at, greaterThan(start), reason: '$className.$name');
        return ui.substring(at, ui.indexOf(';', at));
      }

      // "Fredoka 700 11/1, caps, letter-spacing 0.08em, chapter ink".
      final kicker = member('HomeTypeTokens', 'chapterKicker');
      expect(kicker, contains('fontSize: 11.0'));
      expect(kicker, contains('letterSpacing: 0.88'));
      expect(kicker, isNot(contains('color:')));
      expect(member('HomeTypeTokens', 'chapterKickerCaps'), endsWith('true'));
      // "Fredoka 700 30/1.1 #5B3A21 (26 on 16:9)".
      expect(member('GiftTypeTokens', 'title'), contains('height: 1.1'));
      expect(member('GiftTypeTokens', 'titleShortSize'), endsWith('26.0'));
      expect(
        member('GiftTypeTokens', 'amount'),
        contains('fontFeatures: [FontFeature.tabularFigures()]'),
      );
      expect(member('GiftTypeTokens', 'amountShortSize'), endsWith('22.0'));
      // "(museumNextName)" names the colour it repeats.
      expect(
        member('MuseumTypeTokens', 'nextName'),
        contains('color: Color(0xFFFFEFD6)'),
      );
      expect(member('MuseumTypeTokens', 'kickerCaps'), endsWith('true'));
      expect(
        member('RecordsTypeTokens', 'rowName'),
        contains('fontWeight: FontWeight.w600'),
      );
      expect(member('ShopTypeTokens', 'description'), contains('height: 1.45'));
    });

    test('spot-checks tokens v5: the daily gift (App Flow section 13)', () {
      final ui = output.files[uiTokensPath]!;
      for (final name in [
        'GiftButtonTokens',
        'GiftSheetTokens',
        'GiftTileTokens',
        'GiftTallyTokens',
        'GiftClaimTokens',
        'GiftReducedMotionTokens',
        'GiftShortTokens',
        'ChestSlotChipTokens',
      ]) {
        expect(ui, contains('abstract final class $name {'), reason: name);
      }
      for (final value in [
        'static const touch = 48.0;',
        'center: Alignment(-0.3, -0.4)',
        'static const readyDotRing = TokenStroke(width: 2.5, '
            'color: Color(0xFFFFFDF7));',
        'static const readyDotOffsetRight = -3.0;',
        'static const Color scrim = AppColorTokens.scrim;',
        'static const gridColumns = 3;',
        'static const day7Chest = Size(108.0, 90.0);',
        'static const footerSwapMs = 200;',
        'static const height = 556.0;',
        'static const doneCheckGlyph = \'check\';',
        // m7-6 (item 6, keep): drawn at the bundled cut's 600 (was 700).
        'static const doneCheckGlyphWeight = 600.0;',
        'static const todayLift = -2.0;',
        'static const topBelowCoinPill = 54.0;',
        'static const topShort = 82.0;',
        'static const discsHintGlyph = \'lightbulb\';',
        'static const Cubic inCurve = UiMotionTokens.curveEaseOut;',
        'static const holdMs = 1200;',
        'static const coinsSpriteEvery = 10;',
        'static const coinsSpritesMax = 6;',
        'static const coinsMs = 700;',
        'static const coinsPathControl = Offset(175.0, 300.0);',
        'static const coinsPillHole = Size(122.0, 54.0);',
        'static const hintSpriteSize = 40.0;',
        'static const slotSpriteSize = 40.0;',
        'static const day7CollectScrim = Color(0x2E3C1E0A);',
        'static const claimTallyFadeInMs = 150;',
        // m7-6 (item 4): the 58 dp Claim on 16:9 makes the sheet 465.
        'static const height = 465.0;',
        'static const discSize = 30.0;',
        'static const glyphRadius = 4.2;',
        'static const giftButtonTop = 26.0;',
        "static const giftClaim = SoundCue(['gift_claim']);",
        'static const giftChestTitleMinScale = 0.85;',
        'static const List<String> giftChestTitleShort = '
            "['gift_chest_title_short'];",
        'static const giftDot = Color(0xFFF5C518);',
        'static const slotDiscEdge = Color(0xFF2F7A3E);',
      ]) {
        expect(ui, contains(value));
      }
      // The track is a rule (Remote Config login_gift_track), never tokens.
      expect(
        output.reader.uses['gift.button.hiddenUntil'],
        isA<DocumentedOnly>(),
      );
      expect(ui, isNot(contains('GiftChestTokens')));
    });

    test('spot-checks tokens v5: Part 2 (m7-5)', () {
      final ui = output.files[uiTokensPath]!;
      final render = output.files[renderTokensPath]!;
      for (final value in [
        // Item 5: the win ribbon's width.
        'static const bandSize = Size(290.0, 56.0);',
        'static const reach = 334.0;',
        'static const textBox = Size(266.0, 40.0);',
        "static const List<String> hiRectKeyPath = ['band', 'hi', 'hi_rect'];",
        'static const maxWidthInset = 70.0;',
        // Items 8, 11, 16, 18, 21.
        'static const handScale = 0.6;',
        'static const topFadeFill = PxLinearGradient(',
        'TokenStop.px(120.0), TokenStop.px(240.0)',
        'static const formsFullMaxDots = 8;',
        "static const formsStateGlyphThinking = 'more_horiz';",
        'static const formsDotsMinSize = 8.0;',
        'static const formsHeightAt13 = 58.0;',
        'static const spotlightHeightShort = 200.0;',
        'static const spotlightShortBelow = 760.0;',
        'static const scrollFoldedAbove = 3;',
        // Item 1: the frame-only colours and shadows.
        'static const museumNextName = Color(0xFFFFEFD6);',
        'static const List<NestyShadow> segmentSelected = [',
        // Item 10: the generating card is centred, its padding a token.
        'static const cardPadding = EdgeInsets.symmetric(vertical: 22.0, '
            'horizontal: 18.0);',
        'static const spinnerSize = 44.0;',
      ]) {
        expect(ui, contains(value));
      }
      // Prose tops (Choices 10, 17): nothing reads a number any more.
      String body(String className) {
        final start = ui.indexOf('abstract final class $className {');
        return ui.substring(start, ui.indexOf('\n}', start));
      }

      expect(body('GeneratingTokens'), isNot(contains('static const cardTop')));
      expect(body('NoCoinsTokens'), isNot(contains('static const top ')));
      // Item 14.
      expect(render, contains('static const pickWobbleToMoveMs = 80;'));
      expect(
        render,
        contains('static const Cubic pickWobbleToMoveCurve = curveEaseOut;'),
      );
    });

    test('every glyph the v5 tokens name is in the bundled font, but one', () {
      final font = File(
        p.join(root.path, 'tools/fonts/nesty_symbols.txt'),
      ).readAsLinesSync().map((l) => l.trim()).toSet();
      final ui = output.files[uiTokensPath]!;
      final glyphs = {
        for (final m in RegExp(
          r'static const (?:formsStateGlyph\w+|doneCheckGlyph|discsHintGlyph) '
          r"= '([a-z0-9_]+)';",
        ).allMatches(ui))
          m[1]!,
      };
      expect(glyphs, {
        'more_horiz',
        'replay',
        'check_circle',
        'check',
        'lightbulb',
      });
      // Every glyph the m7-5 tokens name is bundled; `more_horiz` (the race
      // strip's thinking glyph, 9.3i) is in nesty_symbols.txt since m7-5.
      expect(glyphs.difference(font), isEmpty);
    });

    test('spot-checks tokens v6: the local habits (App Flow section 14)', () {
      final ui = output.files[uiTokensPath]!;
      for (final className in [
        'HabitsWelcomeTokens',
        'HabitsMonthTokens',
        'HabitsMonthShortTokens',
        'HabitsDayCellTokens',
        'HabitsPastDayTokens',
        'HabitsWidgetTokens',
        'HabitsWidgetColorTokens',
      ]) {
        expect(ui, contains('abstract final class $className {'));
      }
      for (final value in [
        // 14.1: the card's place (chapterCard.top + 74; checked).
        'static const placeBelowChapterCardTop = 74.0;',
        'static const placeH844Top = 198.0;',
        'static const placeH844DollScale = 0.78;',
        'static const placeDollFadeBelow = 0.6;',
        'static const cardPadding = EdgeInsets.fromLTRB(12.0, 12.0, 12.0, '
            '12.0);',
        "static const discFreezeGlyph = 'local_fire_department';",
        'static const discFreezeBadgeRight = -6.0;',
        'static const playFace = AppGradientTokens.primary;',
        'static const playUnderGap = 8.0;',
        'static const dismissGlyphWeight = 700.0;',
        'static const motionInMs = 280;',
        'static const Cubic motionInCurve = UiMotionTokens.curveEaseOut;',
        'static const Cubic motionDollsGrowCurve = '
            'UiMotionTokens.curveEaseOutBack;',
        'static const reducedMotionDollsMs = 200;',
        // 14.2: the month, its grid formulas and 16:9.
        'static const top = 728.0;',
        'static const topShort = 690.0;',
        "static const headerTitleDateSkeleton = 'LLLL';",
        "static const headerChipGlyphPrevious = 'chevron_left';",
        'static const gridColumns = 7;',
        'static const gridPitchMax = 48.0;',
        'static const gridPitchInset = 52.0;',
        'static const gridFaceMax = 42.0;',
        'static const gridNumberSizeSmall = 15.0;',
        "static const a11yDateSkeleton = 'MMMMd';",
        'static const titleSize = 18.0;',
        'static const faceSize = 40.0;',
        // The day cells: a number's colour and weight, the window's press.
        'static const litNumberWeight = FontWeight.w700;',
        'static const openNumberWeight = FontWeight.w600;',
        'static const laterFace = Color(0xFFFFE7D0);',
        "static const freezeGlyph = 'ac_unit';",
        'static const freezeNumberLift = 4.5;',
        'static const raisedEdgeDepth = 3.0;',
        'static const pressedMs = 80;',
        'static const List<NestyShadow> selectedRings = [NestyShadow(color: '
            'Color(0xFFFFF9EE), spread: 2.0), NestyShadow(color: '
            'Color(0xFF6E4526), spread: 5.0)];',
        // 14.3: a past day.
        "static const cardTitleDateSkeleton = 'MMMEd';",
        'static const openScrollMs = 300;',
        'static const solvedPreviewDim = Color(0xB8FFF9EC);',
        "static const boardDateSkeleton = 'MMMd';",
        "static const winMovesGlyph = 'route';",
        "static const winDateSkeleton = 'EEEEdMMMM';",
        // 14.4: the widget (native), its art sizes and colours.
        'static const artDollSize = Size(18.0, 24.0);',
        'static const artDailyMarkSize = Size(52.0, 52.0);',
        'static const iosMedium = Size(338.0, 158.0);',
        'static const androidMediumFrom = 250.0;',
        "static const androidResizeMode = 'horizontal|vertical';",
        'static const layoutMediumDollsMax = 8;',
        'static const darkTitle = Color(0xFFFFF4E0);',
        'static const tintedText = Color(0xEBFFFFFF);',
        'static const tintedUnlitAccentOpacity = 0.45;',
        // The habits' text fit and sound.
        'static const habitsWelcomeTitleMinScale = 0.85;',
        'static const habitsWelcomeBodyMaxLines = 2;',
        'static const List<String> habitsMonthHintShort = '
            "['habits_month_hint_short'];",
        'static const widgetNumberMinScale = 0.8;',
        "static const habitsTap = SoundCue(['button']);",
        "static const habitsPastWin = SoundCue(['win']);",
      ]) {
        expect(ui, contains(value));
      }
      // The habits' rules are never values.
      for (final rule in [
        'habits.respect',
        'habits.welcomeBack.when',
        'habits.month.window',
        'habits.pastDay.rules',
      ]) {
        expect(output.reader.uses[rule], isA<DocumentedOnly>(), reason: rule);
      }
    });

    test('spot-checks tokens v6: Part 2 (m7-6)', () {
      final ui = output.files[uiTokensPath]!;
      final render = output.files[renderTokensPath]!;
      for (final value in [
        // Item 2: the Computer tag.
        'static const ring = TokenStroke(width: 1.5, color: '
            'Color(0xFFD8B07A));',
        'static const maxTextScale = 1.3;',
        // Items 1, 3, 5, 7, 8, 15, 16.
        'static const freezeChipMaxWidth = 64.0;',
        'static const List<String> freezeChipShort = '
            "['streak_freeze_chip_short'];",
        'static const formsPauseTop = 5.0;',
        'static const overhang = 18.0;',
        'static const List<NestyShadow> edge = [NestyShadow(color: '
            'Color(0xFFC4631E), dy: 4.0)];',
        'static const winRibbonBox = Size(266.0, 40.0);',
        'transform: EllipseGradientTransform(center: Alignment(0.0, -0.4), '
            'radiusX: 0.6, radiusY: 0.7)',
        'static const cabinetNamePlateFace = LinearGradient(begin: '
            'Alignment.topCenter, end: Alignment.bottomCenter, colors: '
            '[Color(0xFFF5D98C), Color(0xFFD9AE52)]);',
        'static const cabinetNamePlatePadding = EdgeInsets.symmetric('
            'vertical: 3.0, horizontal: 7.0);',
        'static const familyCounterLabelMaxWidth = 58.0;',
        'static const familyCounterPillMaxWidth = 92.0;',
        'static const familyCounterPillChrome = 34.0;',
        // Item 4.
        'static const footerHeight = 58.0;',
      ]) {
        expect(ui, contains(value));
      }
      // Item 15 (fontSize.textLink) and the museum count (item 7).
      String body(String className) {
        final start = ui.indexOf('abstract final class $className {');
        return ui.substring(start, ui.indexOf('\n}', start));
      }

      expect(
        body('AppTextStyleTokens'),
        contains(
          "textLink => DisplayFace.of(const TextStyle(fontFamily: 'Fredoka', "
          'fontSize: 16.0, height: 1.25,',
        ),
      );
      expect(body('MuseumTypeTokens'), contains('fontSize: 16.0'));
      // Items 20 and 21 (nesty_render).
      for (final value in [
        'static const splashFadeInMs = 200;',
        'static const bodyRadius = 0.16;',
        'static const invalidEmptyTargetStop = 0.5;',
      ]) {
        expect(render, contains(value));
      }
      expect(output.reader.uses['versus.computerTag.height'], isA<EmittedAs>());
    });

    test('every glyph the v6 tokens name is in the bundled font, but one', () {
      final font = File(
        p.join(root.path, 'tools/fonts/nesty_symbols.txt'),
      ).readAsLinesSync().map((l) => l.trim()).toSet();
      final ui = output.files[uiTokensPath]!;
      final glyphs = <String>{};
      for (final className in [
        'HabitsWelcomeTokens',
        'HabitsMonthTokens',
        'HabitsDayCellTokens',
        'HabitsPastDayTokens',
      ]) {
        final start = ui.indexOf('abstract final class $className {');
        final body = ui.substring(start, ui.indexOf('\n}', start));
        for (final m in RegExp(
          r"static const \w*Glyph\w* = '([a-z0-9_]+)';",
        ).allMatches(body)) {
          glyphs.add(m[1]!);
        }
      }
      expect(glyphs, {
        'local_fire_department',
        'ac_unit',
        'extension',
        'close',
        'chevron_left',
        'chevron_right',
        'replay',
        'route',
      });
      // Every glyph the v6 tokens name is in the font (the font lane added
      // `chevron_left`, the month's previous chip).
      expect(glyphs.difference(font), isEmpty);
    });

    test('is deterministic', () {
      expect(generateDesignTokens(tokensJson).files, output.files);
    });

    test('the committed .gen.dart files are up to date', () async {
      for (final MapEntry(key: relative, value: code) in output.files.entries) {
        final target = p.join(root.path, relative);
        final formatted = await formatDart(code, targetPath: target);
        expect(
          File(target).readAsStringSync(),
          formatted,
          reason:
              '$relative is stale: run dart run nesty_tools:gen_design_tokens',
        );
      }
    });
  });

  group('cross-checks tokens v3 with the rest of design/', () {
    final json = tokens();
    // Through TokenReader, which also reaches tokens v6's file-name keys
    // (`habits.widget.art.files.flame_lit.svg`).
    final reader = TokenReader(json);
    Object? at(String path) => reader.peek(path);

    Map<String, (num, num)> markersOf(String file) {
      final lottie =
          jsonDecode(
                File(
                  p.join(root.path, designLottieDir, '$file.json'),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      return {
        for (final m
            in (lottie['markers']! as List<Object?>)
                .cast<Map<String, Object?>>())
          m['cm']! as String: (m['tm']! as num, m['dr']! as num),
      };
    }

    test('the art the tokens name ships in design/', () {
      for (final n in [0, 1, 2]) {
        expect(
          File(
            p.join(root.path, 'design/board/glass-case-tall-$n.svg'),
          ).existsSync(),
          isTrue,
          reason: 'layout.board.glassCaseTall.art',
        );
      }
      // Tokens v4 (m7-4 A.5): each chapter's own wood.
      for (var ch = 7; ch <= 10; ch++) {
        final dir = at('theme.chapters.$ch.boardArt.dir')! as String;
        for (final file
            in (at('theme.chapters.$ch.boardArt.files')! as List<Object?>)) {
          expect(
            File(p.join(root.path, 'design', '$dir$file')).existsSync(),
            isTrue,
            reason: '$dir$file',
          );
        }
      }
      for (var ch = 1; ch <= 10; ch++) {
        final base = 'theme.chapters.$ch';
        expect(
          File(
            p.join(root.path, 'design', at('$base.file')! as String),
          ).existsSync(),
          isTrue,
          reason: base,
        );
        // "museum/06_snow.svg": the catalog's figurine order.
        expect(
          at('$base.figurine'),
          'museum/${ch.toString().padLeft(2, '0')}_'
          '${defaultMuseumFigurineIds[ch - 1]}.svg',
        );
      }
    });

    test('every UI art file the tokens name ships, and is synced', () {
      // Tokens v5 (m7-5): the gift glyph, the slot chip and its sprite join
      // the stars, chests and flight sprites the prose names by path.
      final paths = <String>{
        for (final leaf in leafPaths(json, ''))
          if (at(leaf) case final String text)
            for (final m in RegExp(
              r'\bui/[a-z0-9_]+/[a-z0-9_]+\.svg\b',
            ).allMatches(text))
              m[0]!,
      };
      expect(
        paths,
        containsAll([
          'ui/gift/gift_glyph.svg',
          'ui/chest/chip_slot.svg',
          'ui/sprites/slot_flight.svg',
          'ui/sprites/hint_flight.svg',
        ]),
      );
      for (final path in paths) {
        expect(
          File(p.join(root.path, 'design', path)).existsSync(),
          isTrue,
          reason: 'design/$path',
        );
        expect(
          File(p.join(root.path, 'apps/game/assets', path)).existsSync(),
          isTrue,
          reason: 'apps/game/assets/$path: run sync_design_assets',
        );
      }
    });

    test('the chapter names are the ARB\'s chapterName', () {
      final arb =
          jsonDecode(
                File(
                  p.join(root.path, 'apps/game/lib/l10n/app_en.arb'),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final names = {
        for (final m in RegExp(
          r'(ch\d\d)\{([^}]*)\}',
        ).allMatches(arb['chapterName']! as String))
          m[1]!: m[2]!,
      };
      // Chapters 1–6 today; C4b adds 7–10 with copy.md G.4.
      expect(names.keys, containsAll(['ch01', 'ch06']));
      for (var ch = 1; ch <= 10; ch++) {
        final id = 'ch${ch.toString().padLeft(2, '0')}';
        if (!names.containsKey(id)) continue;
        expect(names[id], at('theme.chapters.$ch.name'), reason: id);
      }
    });

    test('the motion frames are the Lottie files\' markers', () {
      final stars = markersOf('ui_stars');
      final segment = at('motion.stars.segmentFrames')! as num;
      for (final n in [1, 2, 3]) {
        expect(stars['star_$n'], ((n - 1) * segment, segment));
      }
      final [from, to] = (at('motion.stars.flourish')! as List<Object?>)
          .cast<num>();
      expect(stars['flourish'], (from, to - from));
      expect(
        at('motion.stars.perStarMs'),
        (segment * 1000 / 60).round(),
        reason: '20 frames at 60 fps',
      );

      final chest = markersOf('ui_chest');
      for (final (key, marker) in [
        ('arrive', 'arrive'),
        ('idle', 'idle'),
        ('wiggle', 'wiggle'),
        ('open', 'open'),
        ('openIdle', 'open_idle'),
      ]) {
        final [start, end] =
            (at('motion.chest.segments.$key')! as List<Object?>).cast<num>();
        expect(chest[marker], (start, end - start), reason: marker);
      }

      expect(markersOf('fx_ice')['shatter']!.$1, 48, reason: 'tagPop.delay');
      expect(markersOf('ui_extra_slot')['rest'], (
        at('motion.extraSlot.restFrame'),
        0,
      ));
      expect(lottieContractOf('ui_extra_slot')!.markers.single.start, 0);
    });
  });

  group('fails loudly', () {
    String mutate(void Function(Map<String, Object?> json) change) {
      final json = tokens();
      change(json);
      return jsonEncode(json);
    }

    Map<String, Object?> at(Map<String, Object?> json, String path) {
      Object? node = json;
      for (final key in path.split('.')) {
        node = (node! as Map<String, Object?>)[key];
      }
      return node! as Map<String, Object?>;
    }

    test('on a leaf with no codegen mapping', () {
      final json = mutate((j) => at(j, 'motion.pick')['bounce'] = 3);
      expect(
        () => generateDesignTokens(json),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('motion.pick.bounce'),
          ),
        ),
      );
    });

    test('on a value of the wrong shape', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'color')['background'] = 12),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'color')['background'] = 'tomato'),
        ),
        throwsFormatException,
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'shadow')['raised'] = '0 2px 0'),
        ),
        throwsFormatException,
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'motion.easing')['easeOut'] = 'ease-out'),
        ),
        throwsFormatException,
      );
    });

    test('on doll colors that do not match nesty_core DollColor', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'dollColor').remove('navy')),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'dollColor.red')['wild'] = true),
        ),
        throwsA(isA<TokenFormatException>()),
      );
    });

    test('on reworded prose the codegen parses', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.board')['hitArea'] = 'min 48'),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      // The v1 wordings, before the owner decisions 3d and 3e.
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'motion.reveal')['type'] =
                'circular paint wipe from the belly + 5 splash drops',
          ),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout')['towerSilhouettes'] =
                'each buried nest drawn behind the top as a silhouette of '
                'height (topHeight + 18 × depth), with a +N walnut tag at the '
                "stand's right",
          ),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      // A wipe centre that isn't where the percentage says.
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'motion.reveal')['type'] =
                "circular paint wipe from the doll's centre (art 256, 590, 62 "
                '% down the artboard) + 5 splash drops',
          ),
        ),
        throwsA(isA<TokenFormatException>()),
      );
    });

    test('on audio tokens of the wrong shape', () {
      String sound(void Function(Map<String, Object?> sound) change) =>
          mutate((j) => change(at(j, 'sound')));
      Matcher throwsAt(String path) => throwsA(
        isA<TokenFormatException>().having((e) => e.path, 'path', path),
      );

      expect(
        () => generateDesignTokens(
          sound(
            (s) => (s['events']! as Map<String, Object?>)['reward'] =
                'jingle_reward|jingle_chapter (random)',
          ),
        ),
        throwsAt('sound.events.reward'),
        reason: 'a jingle plays alone',
      );
      expect(
        () => generateDesignTokens(
          sound(
            (s) => (s['mix']! as Map<String, Object?>)['jingleBus'] = 'voice',
          ),
        ),
        throwsAt('sound.mix.jingleBus'),
      );
      expect(
        () => generateDesignTokens(
          sound(
            (s) =>
                ((s['music']! as Map<String, Object?>)['home']!
                        as Map<String, Object?>)['frames'] =
                    2940000 + 441,
          ),
        ),
        throwsAt('sound.music.home.frames'),
        reason: '10 ms longer than its seconds',
      );
      expect(
        () => generateDesignTokens(
          sound(
            (s) =>
                ((s['music']! as Map<String, Object?>)['game']!
                        as Map<String, Object?>)['loopStart'] =
                    0,
          ),
        ),
        throwsAt('sound.music.game.loopStart'),
      );
      expect(
        () => generateDesignTokens(
          sound((s) => (s['musicDuck']! as Map<String, Object?>)['win'] = 1.5),
        ),
        throwsAt('sound.musicDuck.win'),
      );
      expect(
        () => generateDesignTokens(
          sound(
            (s) =>
                (s['clackPitch']! as Map<String, Object?>)['bakedSemitones'] =
                    0.5,
          ),
        ),
        throwsAt('sound.clackPitch.bakedSemitones'),
      );
    });

    test('on script fonts the bundle cannot honour', () {
      Matcher throwsAt(String path) => throwsA(
        isA<TokenFormatException>().having((e) => e.path, 'path', path),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => (at(j, 'font')).remove('scripts')),
        ),
        throwsAt('font.scripts'),
        reason: 'tokens v4 always names the hi/ja faces',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'font.scripts.deva.weights')['body900'] = 700),
        ),
        throwsAt('font.scripts.deva.weights.body900'),
        reason: 'Nunito 900 is not bundled',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'font.scripts.jpan.weights')['heavy'] = 700),
        ),
        throwsAt('font.scripts.jpan.weights.heavy'),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'font.scripts.jpan')['lineHeight'] = 'roomy'),
        ),
        throwsAt('font.scripts.jpan.lineHeight'),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'font.scripts.deva')['kerning'] = 'none'),
        ),
        throwsAt('font.scripts.deva.kerning'),
      );
    });

    test('on a text style weight that is not bundled', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'fontSize.caption')['weight'] = 900),
        ),
        throwsA(isA<TokenFormatException>()),
      );
    });

    test('on a shelf key that is not Nshelves or 3shelvesTall', () {
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.board.planksY')['3shelvesWide'] = [1, 2, 3],
          ),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.board.planksY')['2shelvesTall'] = [1, 2]),
        ),
        throwsA(isA<TokenFormatException>()),
        reason: 'only three shelves have a tall variant',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.board.planksY').remove('3shelvesTall')),
        ),
        throwsA(isA<TokenFormatException>()),
      );
    });

    test('on a v3 formula or rule of placement that changed its wording', () {
      for (final (section, key, text) in [
        ('layout.boardFit', 'rule', 'k = min(vertical, hud, horizontal)'),
        ('layout.boardFit.limits', 'hud', '(planksY[0] − 150) / drawnHeight'),
        ('layout.towerStack', 'rule', 'step = 18'),
        ('layout.board.glassCaseTall', 'size', '0.6h × 1h'),
        ('layout.board', 'iceOverlayTop', 'plankTop + 16.5 − overlay height'),
        ('layout.boardPresets.rowOfFive', 'pips', '6 dp, scaled'),
        ('motion.toast', 'queue', 'all at once'),
        ('chestModal.glow', 'mask', 'radial'),
        ('layout.rivalStrip', 'state', 'Nunito 700 12 #8A5B3A; three dots'),
      ]) {
        expect(
          () => generateDesignTokens(mutate((j) => at(j, section)[key] = text)),
          throwsA(isA<TokenFormatException>()),
          reason: '$section.$key',
        );
      }
    });

    test('on a v3 value that disagrees with the board it repeats', () {
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.boardPresets.threeShelves')['planksY'] = [
              310,
              498,
              684,
            ],
          ),
        ),
        throwsA(isA<TokenFormatException>()),
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.boardPresets.rowOfFive')['stand'] = [70, 27.2],
          ),
        ),
        throwsA(isA<TokenFormatException>()),
        reason: 'the stand is the board\'s × standScale',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.boardFit')['hudClearY'] = 148),
        ),
        throwsA(isA<TokenFormatException>()),
        reason: 'the family counter\'s bottom + 8',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'theme.chapters.7.thumb')['h'] = 400),
        ),
        throwsA(isA<TokenFormatException>()),
        reason: 'the crop keeps the thumbBox ratio',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'theme.chapters.7')['levels'] = [120, 140]),
        ),
        throwsA(isA<TokenFormatException>()),
        reason: 'chapters are 20 levels',
      );
    });

    test('on a screen value the emitter can\'t read', () {
      Matcher at_(String path) => throwsA(
        isA<TokenFormatException>().having((e) => e.path, 'path', path),
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.home')['hint'] = 'a friendly nudge'),
        ),
        at_('layout.home.hint'),
        reason: 'unknown prose fails; it is parsed or documented on purpose',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.rivalStrip')['name'] = 'Fredoka 800 16'),
        ),
        at_('layout.rivalStrip.name'),
        reason: 'Fredoka 800 is not bundled',
      );
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'layout.rivalStrip.tag')['glyph'] = 'robot'),
        ),
        at_('layout.rivalStrip.tag.glyph'),
        reason: 'not an `icons` glyph',
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.winStars.newBestChip')['fill'] =
                'gradient.rainbow',
          ),
        ),
        at_('layout.winStars.newBestChip.fill'),
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.rivalStrip.tag')['text'] =
                'Nunito 800 11 #6E4526, uppercase',
          ),
        ),
        at_('layout.rivalStrip.tag.text'),
        reason: 'a font\'s prose tail is pinned',
      );
    });

    test('on a colour that is neither a colour nor an art reference', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'color')['starEmpty'] = 'cream outline'),
        ),
        throwsFormatException,
      );
    });

    test('on an unknown gradient type', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'gradient.primary')['type'] = 'conic'),
        ),
        throwsA(isA<TokenFormatException>()),
      );
    });
  });

  group('memberName', () {
    test('keeps camelCase keys and rewrites t-shirt sizes', () {
      expect(memberName('surfaceEdge'), 'surfaceEdge');
      expect(memberName('2xl'), 'xxl');
      expect(memberName('3xl'), 'xxxl');
    });

    test('rejects keys that are not Dart names', () {
      for (final bad in ['3shelves', 'hello-world', 'Class', 'switch']) {
        expect(() => memberName(bad), throwsFormatException, reason: bad);
      }
    });
  });

  group('tokens v4 fails loudly (m7-4)', () {
    String mutate(void Function(Map<String, Object?> json) change) {
      final json = tokens();
      change(json);
      return jsonEncode(json);
    }

    Map<String, Object?> at(Map<String, Object?> json, String path) {
      Object? node = json;
      for (final key in path.split('.')) {
        node = (node! as Map<String, Object?>)[key];
      }
      return node! as Map<String, Object?>;
    }

    Matcher throwsAt(String path) => throwsA(
      isA<TokenFormatException>().having((e) => e.path, 'path', path),
    );

    test('on a oneShelf preset that grows fit limits', () {
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.boardPresets.oneShelf')['limits'] = {
              'vertical': 1,
            },
          ),
        ),
        throwsAt('layout.boardPresets.oneShelf.limits'),
      );
    });

    test('on a chapter\'s board art in another chapter\'s folder', () {
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'theme.chapters.7.boardArt')['dir'] = 'board/ch08/',
          ),
        ),
        throwsAt('theme.chapters.7.boardArt.dir'),
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'theme.chapters.7.boardArt')['files'] = [
              'shelf-plank.svg',
            ],
          ),
        ),
        throwsAt('theme.chapters.7.boardArt.files'),
      );
    });

    test('on a ribbon key path that is not its fill', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'winRibbon.keyPaths')['band'] = ['**', 'fill']),
        ),
        throwsAt('winRibbon.keyPaths.band'),
      );
    });

    test('on a ribbon palette without its tail and fold', () {
      expect(
        () => generateDesignTokens(
          mutate((j) => at(j, 'theme.chapters.3.palette').remove('ribbonFold')),
        ),
        throwsAt('theme.chapters.3.palette'),
      );
    });

    test('on reworded v4 prose the codegen parses', () {
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'layout.fallbackDoll')['head'] =
                'circle, radius 0.18 h, base color, 3 dp darker bottom',
          ),
        ),
        throwsAt('layout.fallbackDoll.head'),
        reason: 'the painter reads diameters (m7-4 1.8)',
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'motion.chest.collect.pillRing')['until'] =
                '240 ms after the last coin (1,200 ms)',
          ),
        ),
        throwsAt('motion.chest.collect.pillRing.until'),
        reason: 'the last coin lands at 700 + 5 × 60 ms',
      );
      expect(
        () => generateDesignTokens(
          mutate(
            (j) => at(j, 'motion.rivalReact.segments')['win'] = [220, 290],
          ),
        ),
        throwsAt('motion.rivalReact.segments.win'),
        reason: 'not ui_rival_react\'s marker',
      );
    });
  });

  group('tokens v5 fails loudly (m7-5)', () {
    String mutate(void Function(Map<String, Object?> json) change) {
      final json = tokens();
      change(json);
      return jsonEncode(json);
    }

    Map<String, Object?> at(Map<String, Object?> json, String path) {
      Object? node = json;
      for (final key in path.split('.')) {
        node = (node! as Map<String, Object?>)[key];
      }
      return node! as Map<String, Object?>;
    }

    Matcher throwsAt(String path) => throwsA(
      isA<TokenFormatException>().having((e) => e.path, 'path', path),
    );

    void expectThrowsAt(
      String section,
      String key,
      Object? value,
      String path, {
      String? reason,
    }) => expect(
      () => generateDesignTokens(mutate((j) => at(j, section)[key] = value)),
      throwsAt(path),
      reason: reason,
    );

    test('on a whole-string face the bundle cannot honour', () {
      const base = 'font.scripts.latnTr';
      expectThrowsAt(
        base,
        'weights',
        {'display700': 700, 'display600': 600},
        '$base.weights',
        reason: 'Fredoka 500 would fall back to the Latin face',
      );
      expectThrowsAt(
        base,
        'weights',
        {'display700': 700, 'display600': 600, 'display400': 400},
        '$base.weights.display400',
        reason: 'Fredoka 400 is not bundled',
      );
      expectThrowsAt(
        base,
        'weights',
        {'display700': 700, 'display600': 600, 'body500': 500},
        '$base.weights.body500',
        reason: 'the body role stays Nunito',
      );
      expectThrowsAt(
        base,
        'body',
        'Baloo 2 for every Nunito role too',
        '$base.body',
      );
      expectThrowsAt(base, 'italic', true, '$base.italic');
    });

    test('on a type entry the style can\'t say', () {
      expectThrowsAt(
        'type.home',
        'tileTitle',
        'Fredoka 700 15/1.1 #5B3A21, small caps',
        'type.home.tileTitle',
      );
      expectThrowsAt(
        'type.museum',
        'nextName',
        'Fredoka 700 12/1.15 #FFFFFF (museumNextName)',
        'type.museum.nextName',
        reason: 'the colour is not the one it names',
      );
      expectThrowsAt(
        'type.records',
        'rowName',
        'Fredoka 400 16/1 #5B3A21',
        'type.records.rowName',
        reason: 'Fredoka 400 is not bundled',
      );
    });

    test('on a gift size that disagrees with its type', () {
      expectThrowsAt(
        'gift.short.title',
        'size',
        24,
        'gift.short.title.size',
        reason: 'type.gift.title says 26 on 16:9',
      );
      expectThrowsAt(
        'gift.sheet.title',
        'height',
        36,
        'gift.sheet.title.height',
        reason: '30 × 1.1',
      );
    });

    test('on reworded or disagreeing gift prose', () {
      expectThrowsAt(
        'layout.home.giftButton',
        'right',
        70,
        'gift.button.place',
        reason: 'the place says right 68',
      );
      expectThrowsAt(
        'gift.tally',
        'top',
        'the coin pill’s top + 50 (120; 82 on 16:9)',
        'gift.tally.top',
      );
      expectThrowsAt(
        'gift.claim.coins',
        'sprites',
        'one per 10 coins, 2 to 6 (20 → 2, 40 → 4, 100 → 10)',
        'gift.claim.coins.sprites',
        reason: '100 coins clamp to 6 sprites',
      );
      expectThrowsAt(
        'gift.reducedMotion',
        'claim',
        'no flights, no trail: the tile and Claim cross-fade (200 ms); the '
            'pill shows the new count at once with its ring for 400 ms; the '
            'tally fades in over 150 ms, holds 1,500 and fades out',
        'gift.reducedMotion.claim',
        reason: 'not gift.tally.holdMs',
      );
      expectThrowsAt(
        'gift.claim',
        'sound',
        'gift_open @0 on Claim, coins as the first coin lands; nothing extra '
            'for a hint or a slot. Day 7: chest_wiggle, chest_open and '
            'jingle_reward as 5.6',
        'gift.claim.sound',
      );
      expectThrowsAt(
        'gift.chest',
        'title',
        'gift_chest_title (Day 7 gift); short form gift_title_short (Day 7)',
        'gift.chest.title',
        reason: 'not textFit.giftChestTitle.short',
      );
      expectThrowsAt(
        'gift.tile.done.check',
        'glyph',
        'a check, 16 dp',
        'gift.tile.done.check.glyph',
      );
      expectThrowsAt(
        'chest.slotChip',
        'glyph',
        'a white plus',
        'chest.slotChip.glyph',
      );
    });

    test('on ribbon rects that are not the Lottie contract\'s', () {
      expectThrowsAt('winRibbon.size.rects', 'band', [
        'band',
        'band',
        'rect',
      ], 'winRibbon.size.rects.band');
      expectThrowsAt(
        'winRibbon.size.rects',
        'glow',
        ['band', 'glow', 'glow_rect'],
        'winRibbon.size.rects',
        reason: 'ui_win_ribbon has no glow_rect',
      );
    });

    test('on a wobble note that is not wobbleToMoveMs', () {
      expectThrowsAt('motion.pick', 'wobbleToMoveMs', 100, r'motion.pick.$m75');
    });
  });

  group('tokens v6 fails loudly (m7-6)', () {
    String mutate(void Function(Map<String, Object?> json) change) {
      final json = tokens();
      change(json);
      return jsonEncode(json);
    }

    Map<String, Object?> at(Map<String, Object?> json, String path) {
      Object? node = json;
      for (final key in path.split('.')) {
        node = (node! as Map<String, Object?>)[key];
      }
      return node! as Map<String, Object?>;
    }

    Matcher throwsAt(String path) => throwsA(
      isA<TokenFormatException>().having((e) => e.path, 'path', path),
    );

    void expectThrowsAt(
      String section,
      String key,
      Object? Function(Object? old) change,
      String path, {
      String? reason,
    }) => expect(
      () => generateDesignTokens(
        mutate((j) {
          final node = at(j, section);
          node[key] = change(node[key]);
        }),
      ),
      throwsAt(path),
      reason: reason,
    );

    String Function(Object?) replace(String from, String to) => (old) {
      final text = old! as String;
      expect(text, contains(from), reason: 'the test edits "$from"');
      return text.replaceFirst(from, to);
    };

    test('on habits prose that disagrees with the values it repeats', () {
      const welcome = 'habits.welcomeBack';
      expectThrowsAt(
        '$welcome.place',
        'rule',
        replace('chapterCard.top + 74', 'chapterCard.top + 80'),
        '$welcome.place.rule',
        reason: '124 + 80 is not the 844 top',
      );
      expectThrowsAt(
        welcome,
        'body',
        replace('two lines', 'three lines'),
        '$welcome.body',
        reason: 'textFit.habitsWelcome.body says two',
      );
      expectThrowsAt(
        '$welcome.play',
        'place',
        replace('At 1.3×', 'At 1.2×'),
        '$welcome.play.place',
      );
      expectThrowsAt(
        welcome,
        'when',
        replace('two or more days', 'three or more days'),
        '$welcome.when',
        reason: 'the rule is RemoteConfigKeys.welcomeBackDays',
      );
      expectThrowsAt(
        welcome,
        'sound',
        replace('habitsTap', 'habitsTapLoud'),
        '$welcome.sound',
      );
      expectThrowsAt(
        'habits.month.grid',
        'pitch',
        replace('44 at 360', '45 at 360'),
        'habits.month.grid.pitch',
      );
      expectThrowsAt(
        'habits.month.grid',
        'target',
        replace('48 × 46', '48 × 48'),
        'habits.month.grid.target',
      );
      expectThrowsAt(
        'habits.month.short',
        'face',
        (_) => 38,
        'habits.month.grid.radius',
        reason: 'the small face is short.face',
      );
      expectThrowsAt(
        'habits.widget.colors.light',
        'flameUnlit',
        (_) => 'flame_gone.svg',
        'habits.widget.colors.light.flameUnlit',
      );
      expectThrowsAt(
        'habits.widget.layout.small',
        'line',
        replace('two lines', 'three lines'),
        'habits.widget.layout.small.line',
      );
    });

    test('on a new habits value the emitter can\'t read', () {
      expectThrowsAt(
        'habits.month.card',
        'glow',
        (_) => 'soft and warm',
        'habits.month.card.glow',
      );
      expectThrowsAt(
        'habits.welcomeBack.disc.paused',
        'glyph',
        (_) => 'local_fire_department thirty, #9A6A44',
        'habits.welcomeBack.disc.paused.glyph',
      );
    });

    test('on a gradient shape that is not an ellipse in the box', () {
      for (final shape in [
        'circle 50% at 50% 30%',
        'ellipse 60% 70% at 50% 130%',
      ]) {
        expectThrowsAt(
          'gradient.figurinePanelEarned',
          'shape',
          (_) => shape,
          'gradient.figurinePanelEarned.shape',
          reason: shape,
        );
      }
    });

    test('on Part 2 prose that disagrees with its sources', () {
      expectThrowsAt(
        'layout.museum.cabinet',
        'namePlate',
        replace('namePlateTop #F5D98C', 'namePlateTop #F5D98D'),
        'layout.museum.cabinet.namePlate',
        reason: 'not color.namePlateTop',
      );
      expectThrowsAt(
        'versus.computerTag',
        'scale',
        replace('height 20k', 'height 22k'),
        'versus.computerTag.scale',
      );
      expectThrowsAt(
        'layout.rivalStrip.forms',
        'pause',
        replace('top + 5', 'top + 6'),
        'layout.rivalStrip.forms.pause',
      );
      expectThrowsAt(
        'layout.hud.familyCounter',
        'pillMaxWidth',
        (_) => 90,
        r'layout.hud.familyCounter.$m76',
        reason: 'label + 34 is 92',
      );
      expectThrowsAt(
        'gift.chest',
        'ribbon',
        replace('#C4631E', '#000000'),
        'gift.chest.ribbon',
        reason: 'not color.primaryEdge',
      );
      expectThrowsAt(
        'textFit.winRibbon',
        'box',
        (_) => [312, 40],
        'textFit.winRibbon.box',
        reason: 'not winRibbon.size.textBox',
      );
      expectThrowsAt(
        'gift.short',
        'height',
        replace('the 58 dp', 'the 54 dp'),
        'gift.short.height',
      );
      expectThrowsAt(
        'layout.boardPresets.oneShelf',
        r'$m76',
        replace('plank top 540', 'plank top 560'),
        r'layout.boardPresets.oneShelf.$m76',
      );
      expectThrowsAt(
        'layout.extraSlot',
        r'$m76',
        replace('pitch 62', 'pitch 64'),
        r'layout.extraSlot.$m76',
      );
      expectThrowsAt(
        'layout.fallbackDoll',
        r'$m76',
        replace('0.48 h tall', '0.5 h tall'),
        r'layout.fallbackDoll.$m76',
        reason: 'not the body\'s h × w',
      );
    });

    test('TokenReader reaches a key with a dot', () {
      final reader = TokenReader({
        'files': {'flame_lit.svg': 44, 'a': 1},
      });
      expect(reader.peek('files.flame_lit.svg'), 44);
      expect(reader.peek('files.a'), 1);
      expect(
        () => reader.peek('files.flame_lit'),
        throwsA(isA<TokenFormatException>()),
      );
    });
  });
}

/// The documentation-only leaves of tokens v5 (m7-5), each a deliberate
/// decision of the codegen change that reads v5.
const _documentedV5 = {
  // Design notes.
  r'color.$m75',
  r'font.scripts.latnTr.$note',
  r'layout.rivalStrip.forms.$note',
  r'layout.splash.topFade.$note',
  r'gift.$note',
  r'gift.short.$note',
  r'type.$note',
  r'winRibbon.size.$note',
  'layout.homeShort.giftButton.note',
  'textFit.giftChestTitle.note',
  'gift.tile.later.note',
  'gift.tally.use',
  // Licence notes, and the Turkish face's checked prose.
  'font.scripts.latnTr.source',
  'font.scripts.latnTr.body',
  'font.scripts.latnTr.rupee',
  // Behaviour and placement the hand-written code follows (some pinned
  // word for word, some checked against the values they repeat).
  'layout.tutorial.hand.lottie',
  'layout.tutorial.hand.note',
  'layout.generating.card.top',
  'layout.generating.card.boxSizing',
  'layout.noCoins.top',
  'layout.chapters.scroll.rule',
  'layout.rivalStrip.forms.tagSecondLine',
  'layout.rivalStrip.forms.belowWidth360',
  'layout.splash.topFade.over',
  'textFit.giftSheet',
  'gift.button.place',
  'gift.button.glyph.color',
  'gift.button.readyDot.motion',
  'gift.button.narrow',
  'gift.sheet.day7.chips.wrap',
  'gift.sheet.footer.claim',
  'gift.sheet.open',
  'gift.tile.day7',
  'gift.tally.layer',
  'gift.tally.count',
  'gift.claim.coins.from',
  'gift.claim.coins.to',
  'gift.claim.coins.trail',
  'gift.claim.hint.to',
  'gift.claim.slot.to',
  'gift.claim.slot.land',
  'gift.claim.sound',
  'gift.claim.haptic',
  'gift.chest.tint',
  'gift.chest.buttons',
  'gift.reducedMotion.day7',
  'haptics.giftClaim',
  // A rule: the gift shows once the Daily unlocks (never read from tokens).
  'gift.button.hiddenUntil',
  // Art references (UiArt draws them) and copy.md ids (the ARB keys).
  'gift.button.glyph.src',
  'gift.sheet.day7.chestSrc',
  'gift.tile.artSrc.coins',
  'gift.tile.artSrc.hint',
  'gift.tally.discs.slot',
  'chest.slotChip.label',
  'chest.slotChip.a11y',
  'gift.chest.title',
  'gift.chest.body',
  'gift.chest.chips',
};

/// The documentation-only leaves of tokens v6 (m7-6), each a deliberate
/// decision of the codegen change that reads v6.
final _documentedV6 = {
  // Design notes.
  r'habits.$note',
  r'habits.month.short.$note',
  r'layout.extraSlot.$m76',
  r'layout.hud.familyCounter.$m76',
  r'layout.sizeBlend.$m76',
  r'layout.splash.errors.$note',
  r'textFit.winRibbon.$m76',
  'fontSize.textLink.use',
  'gradient.figurinePanelEarned.use',
  'gradient.figurinePanelLocked.use',
  'textFit.freezeChip.note',
  'habits.welcomeBack.dismiss.note',
  for (final state in ['lit', 'later', 'freeze', 'open', 'blank'])
    'habits.month.cell.$state.means',
  // The habits' respect rules, and rules never read from tokens (the
  // welcome card's when, the past-day window and pay rules).
  'habits.respect',
  'habits.welcomeBack.when',
  'habits.month.window',
  'habits.pastDay.rules',
  // Behaviour and placement the hand-written code follows (some pinned word
  // for word, some checked against the values they repeat).
  'gift.tally.shortPhone',
  'layout.splash.errors.dim',
  'layout.splash.errors.icons',
  'textFit.habitsMonth.legend',
  'habits.welcomeBack.gone',
  'habits.welcomeBack.card.button',
  'habits.welcomeBack.place.h693.dolls',
  'habits.welcomeBack.place.between',
  'habits.welcomeBack.place.moves',
  'habits.welcomeBack.withGift',
  'habits.welcomeBack.sound',
  'habits.welcomeBack.haptic',
  'habits.month.header.chip.show',
  'habits.month.weekdays.names',
  'habits.month.weekdays.first',
  'habits.month.grid.rows',
  'habits.month.grid.target',
  'habits.month.grid.fits360',
  'habits.month.legend.shows',
  'habits.month.frozen',
  'habits.month.firstOfMonth',
  'habits.month.justUnlocked',
  'habits.month.motion',
  'habits.month.cell.blank.face',
  'habits.month.cell.future.face',
  'habits.month.cell.today.tap',
  'habits.pastDay.sound',
  'habits.pastDay.haptic',
  'haptics.habitsTap',
  'haptics.habitsPastWin',
  // Copy.md ids (the ARB keys).
  for (final variant in ['freeze', 'paused', 'new'])
    'habits.welcomeBack.variants.$variant',
  'habits.welcomeBack.dismiss.label',
  'habits.month.hint.copy',
  // The home-screen widget's native-only prose (local-habits stage 4) and
  // its art, which sync_design_assets validates (widget_art.dart).
  'habits.widget.tap',
  'habits.widget.refresh',
  for (final key in ['folder', 'png', 'vector', 'doll', 'previews'])
    'habits.widget.art.$key',
  for (final key in [
    'families',
    'sizeNote',
    'radius',
    'background',
    'tinted',
    'standby',
    'fonts',
  ])
    'habits.widget.ios.$key',
  for (final key in ['sizes', 'preview', 'fonts']) 'habits.widget.android.$key',
  for (final scheme in ['light', 'dark'])
    'habits.widget.colors.$scheme.flameUnlit',
  'habits.widget.colors.tinted.background',
  for (final state in ['ready', 'solved', 'paused', 'zero', 'locked'])
    'habits.widget.states.$state',
};

/// The documentation-only leaves of tokens v4 (m7-4), each a deliberate
/// decision of the codegen change that reads v4.
Set<String> _documentedV4(Map<String, Object?> tokens) => {
  // Design notes.
  for (final section in ['color', 'layout.hintArc']) '$section.\$m74',
  for (final section in [
    'layout.tutorial',
    'layout.sizeBlend',
    'layout.noCoins',
    'layout.languageSheet',
    'toast',
    'textFit',
    'textFit.sheetRows',
    'screenHeader',
    'motion.rivalReact',
    'motion.museumIdle',
    'motion.purchaseItem',
    'motion.relitHome',
    'motion.relitTwinkle',
    'winRibbon.keyPaths',
    'versus.ribbon',
  ])
    '$section.\$note',
  for (final leaf in [
    'gradient.canvas.use',
    'layout.tutorial.pauseHole.note',
    'layout.tutorial.tooltip.note',
    'layout.settingsRows.segmented.note',
    'layout.museumDetail.spotlight.cone.note',
    'toast.app.use',
    'toast.inPlace.use',
    'toast.pill.use',
    'textFit.rivalNames.note',
    'textFit.chestChips.note',
    'textFit.chapterRows.note',
    'textLink.accent.use',
    'shop.skins.space.tag.note',
    'theme.chapters.7.boardArt.wood',
    'theme.chapters.8.boardArt.wood',
    'theme.chapters.9.boardArt.wood',
    'theme.chapters.10.boardArt.wood',
    'icons.familiesCompleted',
    'icons.shareNote',
  ])
    leaf,
  // Tokens only: no bundled level has one shelf.
  for (final leaf in leafPaths(
    (((tokens['layout']! as Map<String, Object?>)['boardPresets']!
        as Map<String, Object?>)['oneShelf']),
    'layout.boardPresets.oneShelf',
  ))
    leaf,
  // The script fonts' fallback rule (emitted as the fallback lists) and
  // their licence notes.
  r'font.scripts.$note',
  'font.scripts.deva.source',
  'font.scripts.jpan.source',
  // Rules of placement and behaviour the hand-written code follows (some
  // pinned word for word), and checked cross-references.
  'layout.board.glassCaseTopOverlap',
  'layout.boardPresets.fourShelves.pieces',
  'layout.towerStack.d21',
  // `layout.fallbackDoll.splash` is FallbackDollTokens.splashFadeInMs since
  // m7-6 (item 20).
  'layout.hud.familyCounter.lottieWidth',
  'theme.ribbonTint',
  for (var ch = 7; ch <= 10; ch++) 'theme.chapters.$ch.boardArt.note',
  'layout.tutorial.chip',
  'layout.sizeBlend.rule',
  'layout.settingsRows.reminderOff',
  'layout.languageSheet.native',
  'layout.languageSheet.change',
  'toast.app.streakSaved',
  'textFit.hudPills.short',
  'textFit.boosterLabels.short',
  'textFit.tabBar.short',
  'textFit.cardsAndSheets',
  'textFit.sheetRows.rule',
  'screenHeader.title',
  'layout.rivalStrip.narrow.measuredOn',
  'layout.chestCard.lottie.layout',
  'layout.chestCard.artFit.svg',
  'layout.chestCard.artFit.frames',
  'layout.chestCard.artFit.lottie',
  'layout.chestCard.artFit.superseded',
  'layout.chapters.progressCount',
  'layout.chapters.accordion',
  'layout.museum.cabinet.collectedIdle',
  'layout.rivalSelect.selection',
  'layout.rivalSelect.shortScreen',
  'textLink.pressedToken',
  'versus.ribbon.hi',
  'motion.chest.rays',
  'motion.chest.collect.hintRing.on',
  'motion.chest.collect.gainTag.text',
  'motion.chest.collect.gainTag.pop',
  'motion.rivalReact.lottie',
  for (final segment in ['idle', 'family', 'win', 'lose'])
    'motion.rivalReact.segments.$segment',
  'motion.rivalReact.sound',
  'motion.rivalReact.reducedMotion',
  'motion.museumIdle.lottie',
  'motion.museumIdle.reducedMotion',
  'motion.firstLaunch.reducedMotion',
  'motion.purchaseItem.swap',
  'motion.purchaseItem.jingle',
  'motion.purchaseItem.haptic',
  'motion.relitTwinkle.motion',
};
