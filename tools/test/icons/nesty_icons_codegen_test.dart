import 'dart:io';

import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/icons/nesty_icons_codegen.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();
  String read(String relative) =>
      File(p.join(root.path, relative)).readAsStringSync();

  test('the glyph list is exactly the design README icon lists', () {
    final readme = read('design/README.md');
    final v1 = RegExp(r'Glyphs used: (.*?)\. m7 adds').firstMatch(readme);
    final m7 = RegExp(
      r'm7 adds \(I\.10\): (.*?)\. The full map',
    ).firstMatch(readme);
    expect(v1, isNotNull, reason: 'README wording changed');
    expect(m7, isNotNull, reason: 'README wording changed');
    final first = v1![1]!.split(',').map((s) => s.trim()).toList();
    // "share (iOS: ios_share), …, all_inclusive (unlimited Undo) redeem
    // (chests)": each glyph, with the iOS one from its parenthesis, and
    // without the ones the v1 list has (redeem, check_circle).
    final added = <String>[];
    for (final m in RegExp(
      r'([a-z][a-z0-9_]*)(?: \(([^)]*)\))?',
    ).allMatches(m7![1]!)) {
      for (final glyph in [
        m[1]!,
        if (m[2] case final note? when note.startsWith('iOS: '))
          note.substring(5),
      ]) {
        if (!first.contains(glyph) && !added.contains(glyph)) added.add(glyph);
      }
    }
    expect(added, hasLength(18), reason: 'the m7 list (D171 says 17)');
    // The splash errors' two glyphs (phase 4 lead note 2): in the pinned
    // font, not yet in the README or tokens.json `icons`.
    const splashErrors = ['sd_card_alert', 'inventory_2'];
    expect(parseGlyphList(read(glyphListPath)), [
      ...first,
      ...added,
      ...splashErrors,
    ]);
  });

  test('every glyph tokens.json names is in the font', () {
    final glyphs = parseGlyphList(read(glyphListPath)).toSet();
    final tokens = read('design/tokens.json');
    final icons = RegExp(
      r'"icons": \{(.*?)\n  \}',
      dotAll: true,
    ).firstMatch(tokens)![1]!;
    final named = [
      for (final m in RegExp(r'"(\w+)": "([a-z0-9_]+)"').allMatches(icons))
        m[2]!,
      // The layout sections name a few glyphs too.
      for (final m in RegExp(
        r'"(?:glyph|undoBadge|icon)": "([a-z0-9_]+)"',
      ).allMatches(tokens))
        m[1]!,
    ];
    expect(named, isNotEmpty);
    expect(named.where((g) => !glyphs.contains(g)), isEmpty);
  });

  test('the font codepoints cover the glyph list and nothing else', () {
    final glyphs = parseGlyphList(read(glyphListPath));
    final codepoints = parseCodepoints(read(iconCodepointsPath));
    expect(codepoints.keys, glyphs);
    expect(codepoints.values.toSet(), hasLength(glyphs.length));
  });

  test('assets/fonts holds exactly the files tools/fonts/SHA256SUMS lists', () {
    final listed = [
      for (final line in read('tools/fonts/SHA256SUMS').trim().split('\n'))
        line.split(RegExp(r'\s+')).last,
    ]..sort();
    final shipped = [
      for (final f in Directory(
        p.join(root.path, 'apps/game/assets/fonts'),
      ).listSync().whereType<File>())
        p.basename(f.path),
    ]..sort();
    expect(shipped, listed, reason: 'run tools/fonts/build_fonts.sh');
  });

  test('the committed nesty_icons.gen.dart is up to date', () async {
    final source = nestyIconsSource(
      glyphs: parseGlyphList(read(glyphListPath)),
      codepoints: parseCodepoints(read(iconCodepointsPath)),
    );
    final target = p.join(root.path, nestyIconsPath);
    expect(
      read(nestyIconsPath),
      await formatDart(source, targetPath: target),
      reason: 'run dart run nesty_tools:gen_nesty_icons',
    );
  });

  group('parsers', () {
    test('glyph list skips comments and blank lines', () {
      expect(parseGlyphList('# x\npause\n\n undo # the arrow\n'), [
        'pause',
        'undo',
      ]);
    });

    test('codepoints parse hex and reject junk and duplicates', () {
      expect(parseCodepoints('pause e034\nundo e166\n'), {
        'pause': 0xe034,
        'undo': 0xe166,
      });
      expect(() => parseCodepoints('pause'), throwsFormatException);
      expect(() => parseCodepoints('pause zz'), throwsFormatException);
      expect(
        () => parseCodepoints('pause e034\npause e035'),
        throwsFormatException,
      );
    });

    test('member names are lowerCamelCase', () {
      expect(iconMemberName('local_fire_department'), 'localFireDepartment');
      expect(iconMemberName('ac_unit'), 'acUnit');
      expect(iconMemberName('home'), 'home');
      expect(iconMemberName('10k'), 'icon10k');
    });
  });

  test('refuses a glyph list that differs from the font', () {
    expect(
      () =>
          nestyIconsSource(glyphs: ['pause', 'undo'], codepoints: {'pause': 1}),
      throwsStateError,
    );
    expect(
      () =>
          nestyIconsSource(glyphs: ['pause'], codepoints: {'pause': 1, 'x': 2}),
      throwsStateError,
    );
  });
}
