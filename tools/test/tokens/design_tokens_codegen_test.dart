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
