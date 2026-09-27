import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/dart_format.dart';
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
