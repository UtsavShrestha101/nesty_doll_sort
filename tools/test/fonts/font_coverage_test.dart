// The bundled fonts draw every character the game's copy uses, in every
// locale, at every bundled weight (l10n.md §4.5): a character no family in
// a style's chain maps would fall through to the phone's system font. The
// chain is the style's family, then its fontFamilyFallback
// (AppFontTokens.displayFallback / bodyFallback): the other Latin family,
// then the Devanagari and Japanese role families.
import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/fonts/bundled_fonts.dart';
import 'package:nesty_tools/src/fonts/font_subsets.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/script_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _fix =
    'Fix: add the character to the copy only if a bundled face draws it, or '
    'run `dart run nesty_tools:gen_font_subsets` (a new kanji), then '
    '`tools/fonts/build_fonts.sh`.';

String _hex(int c) => 'U+${c.toRadixString(16).toUpperCase().padLeft(4, '0')}';

void main() {
  final root = findRepoRoot();
  final fonts = loadBundledFonts(root);
  final tokens =
      jsonDecode(File(p.join(root.path, tokensJsonPath)).readAsStringSync())
          as Map<String, Object?>;
  final font = tokens['font']! as Map<String, Object?>;
  // The per-glyph script faces (deva, jpan). m7-5's whole-string Turkish
  // face (`latnTr`) is in no fallback chain; the lane that bundles it adds
  // its own coverage of the `tr` strings.
  final scripts = {
    for (final MapEntry(:key, :value)
        in (font['scripts']! as Map<String, Object?>).entries)
      if (!key.startsWith(r'$') && !isWholeStringScript(key))
        key: value! as Map<String, Object?>,
  };
  String latin(String role) =>
      (font[role]! as Map<String, Object?>)['family']! as String;
  List<int> latinWeights(String role) =>
      ((font[role]! as Map<String, Object?>)['weights']! as List<Object?>)
          .cast<int>();
  List<String> chain(String role) => [
    latin(role),
    latin(role == 'display' ? 'body' : 'display'),
    for (final script in scripts.values)
      scriptFamilyName(script['family']! as String, role),
  ];

  /// The characters of [text] that some role's chain can't draw at some
  /// bundled weight, with where they fail.
  Map<int, Set<String>> uncovered(String text) {
    final out = <int, Set<String>>{};
    for (final c in text.runes) {
      if (isExemptCharacter(c)) continue;
      for (final role in fontRoles.keys) {
        for (final weight in latinWeights(role)) {
          final drawn = chain(role).any((family) {
            final files = fonts[family];
            if (files == null) {
              throw StateError('$family is in the chain but not bundled');
            }
            return matchWeight(files, weight).info.covers(c);
          });
          if (!drawn) {
            out.putIfAbsent(c, () => {}).add('${latin(role)} $weight');
          }
        }
      }
    }
    return out;
  }

  test('every family a chain names is bundled', () {
    for (final role in fontRoles.keys) {
      for (final family in chain(role)) {
        expect(fonts, contains(family), reason: '$role chain');
      }
    }
  });

  test('every ARB character draws from its chain at every weight', () {
    final arbs =
        Directory(p.join(root.path, arbDir))
            .listSync()
            .whereType<File>()
            .where((f) => RegExp(r'app_\w+\.arb$').hasMatch(f.path))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    expect(arbs, isNotEmpty);
    final failures = <String>[];
    for (final arb in arbs) {
      final locale = RegExp(r'app_(\w+)\.arb$').firstMatch(arb.path)![1]!;
      for (final MapEntry(:key, :value) in arbValues(
        arb.readAsStringSync(),
      ).entries) {
        if (isOsDrawnArbKey(key)) continue;
        for (final MapEntry(key: c, value: where) in uncovered(value).entries) {
          failures.add(
            '${_hex(c)} ${String.fromCharCode(c)} in $locale "$key" '
            '(the ${where.join(', ')} chains)',
          );
        }
      }
    }
    expect(failures, isEmpty, reason: '${failures.join('\n')}\n$_fix');
  });

  test("the language sheet's autonyms draw in every chain", () {
    final autonyms = parseAutonyms(
      File(p.join(root.path, languageSheetPath)).readAsStringSync(),
    );
    expect(autonyms.keys, containsAll(['en', 'hi', 'ja']));
    final failures = [
      for (final MapEntry(key: code, value: autonym) in autonyms.entries)
        for (final MapEntry(key: c, value: where) in uncovered(autonym).entries)
          '${_hex(c)} ${String.fromCharCode(c)} in the $code autonym '
              '"$autonym" (${where.join(', ')})',
    ];
    expect(failures, isEmpty, reason: '${failures.join('\n')}\n$_fix');
  });

  test('the script faces draw only their own script', () {
    // m7-4 9.1: Latin letters and digits stay Fredoka / Nunito.
    bool isLatin(int c) =>
        (c >= 0x30 && c <= 0x39) ||
        (c >= 0x41 && c <= 0x5A) ||
        (c >= 0x61 && c <= 0x7A) ||
        (c >= 0xC0 && c <= 0x24F);
    for (final script in scripts.values) {
      for (final role in fontRoles.keys) {
        final family = scriptFamilyName(script['family']! as String, role);
        for (final file in fonts[family]!) {
          expect(
            file.info.codepoints.where(isLatin).map(_hex),
            isEmpty,
            reason: '$file',
          );
        }
      }
    }
  });

  test('each role family answers a Latin weight with the mapped script '
      'weight', () {
    for (final MapEntry(key: name, value: script) in scripts.entries) {
      final weights = script['weights']! as Map<String, Object?>;
      for (final MapEntry(:key, :value) in weights.entries) {
        final m = RegExp(r'^(display|body)(\d+)$').firstMatch(key)!;
        final family = scriptFamilyName(script['family']! as String, m[1]!);
        final file = matchWeight(fonts[family]!, int.parse(m[2]!));
        expect(
          file.outlineWeight,
          value,
          reason:
              'font.scripts.$name.weights.$key: $family at ${m[2]} draws '
              '$file',
        );
      }
    }
  });

  test('the subset lists are what gen_font_subsets writes', () async {
    final lists = await generateFontSubsets(
      root: root,
      flutterSdk: findFlutterSdk(),
      fontScripts: font['scripts']! as Map<String, Object?>,
    );
    expect(lists.keys, hasLength(scriptSubsets.length));
    for (final MapEntry(key: path, value: source) in lists.entries) {
      expect(
        File(p.join(root.path, path)).readAsStringSync(),
        source,
        reason:
            '$path is stale. Run: dart run nesty_tools:gen_font_subsets, '
            'then tools/fonts/build_fonts.sh',
      );
    }
  });

  group(
    'the whole-string Turkish face (m7-5 item 28, font.scripts.latnTr)',
    () {
      final latnTr = {
        for (final MapEntry(:key, :value)
            in (font['scripts']! as Map<String, Object?>).entries)
          if (isWholeStringScript(key)) key: value! as Map<String, Object?>,
      }['latnTr']!;
      final family = wholeStringFamilyName(
        latnTr['family']! as String,
        'latnTr',
      );
      final weights = (latnTr['weights']! as Map<String, Object?>).map(
        (k, v) => MapEntry(int.parse(k.substring('display'.length)), v! as int),
      );

      test('is its own family, one file per Fredoka weight', () {
        expect(family, 'Baloo2LatnTr');
        expect(fonts, contains(family));
        expect(weights.keys.toSet(), latinWeights('display').toSet());
        for (final MapEntry(key: fredoka, value: baloo) in weights.entries) {
          final file = matchWeight(fonts[family]!, fredoka);
          expect(
            file.info.weightClass,
            fredoka,
            reason: '$file answers $fredoka',
          );
          expect(
            file.outlineWeight,
            baloo,
            reason: '$file draws Baloo 2 $baloo',
          );
        }
      });

      test('draws every tr string whole, in its display chain', () {
        final arb = File(p.join(root.path, arbDir, 'app_tr.arb'));
        final failures = <String>[];
        for (final MapEntry(:key, :value) in arbValues(
          arb.readAsStringSync(),
        ).entries) {
          if (isOsDrawnArbKey(key)) continue;
          for (final c in value.runes) {
            if (isExemptCharacter(c)) continue;
            for (final weight in weights.keys) {
              if (!matchWeight(fonts[family]!, weight).info.covers(c)) {
                failures.add(
                  '${_hex(c)} ${String.fromCharCode(c)} in "$key" '
                  'at $weight',
                );
              }
            }
          }
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      });

      test('draws the Turkish letters Fredoka lacks, and the rupee', () {
        final fredoka = matchWeight(fonts['Fredoka']!, 700).info;
        for (final c in 'ğĞİşŞ'.runes) {
          expect(
            fredoka.covers(c),
            isFalse,
            reason: 'Fredoka lacks ${_hex(c)}',
          );
          for (final weight in weights.keys) {
            expect(
              matchWeight(fonts[family]!, weight).info.covers(c),
              isTrue,
              reason: '${_hex(c)} at $weight',
            );
          }
        }
        // The rupee draws in Baloo 2 in every locale (the deva fallback).
        expect(
          matchWeight(
            fonts[scriptFamilyName('Baloo 2', 'display')]!,
            700,
          ).info.covers(0x20B9),
          isTrue,
        );
      });

      test('is in no fallback chain (whole strings, never per glyph)', () {
        for (final role in fontRoles.keys) {
          expect(chain(role), isNot(contains(family)));
        }
      });
    },
  );

  test('SHA256SUMS lists exactly the bundled font files', () {
    final sums = File(
      p.join(root.path, 'tools/fonts/SHA256SUMS'),
    ).readAsLinesSync().where((l) => l.trim().isNotEmpty);
    final listed = {for (final line in sums) line.split(RegExp(r'\s+')).last};
    final bundled = {
      for (final f in Directory(
        p.join(root.path, bundledFontsDir),
      ).listSync().whereType<File>())
        p.basename(f.path),
    };
    expect(bundled, listed);
    for (final family in [for (final r in fontRoles.keys) ...chain(r)]) {
      for (final file in fonts[family]!) {
        expect(listed, contains(p.basename(file.path)));
      }
    }
  });
}
