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
          if (!RegExp(
            'static const (?:[\\w<>, ]+ )?$member = ',
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
        'layout.winStarsShort.notePill',
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
        'color.starEmpty',
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
        'textLink.minTapHeight',
        for (final leaf in leafPaths(tokens()['versus'], 'versus')) leaf,
        for (final leaf in leafPaths(tokens()['chest'], 'chest')) leaf,
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
        contains('fontWeight: FontWeight.w800, color: Color(0xFF9A6A44)'),
      );
      expect(ui, isNot(contains('starEmpty')), reason: 'an art reference');
      expect(ui, isNot(contains('minTapHeight')), reason: 'lead note 3: 48');
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
    Object? at(String path) {
      Object? node = json;
      for (final key in path.split('.')) {
        node = (node! as Map<String, Object?>)[key];
      }
      return node;
    }

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
      final star = RegExp(
        r'^(ui/\S+\.svg) ',
      ).firstMatch(at('color.starEmpty')! as String)![1]!;
      expect(File(p.join(root.path, 'design', star)).existsSync(), isTrue);
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
}
