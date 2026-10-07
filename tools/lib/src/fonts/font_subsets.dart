import 'dart:convert';
import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nesty_tools/src/fonts/bundled_fonts.dart';
import 'package:path/path.dart' as p;

/// Repo-relative folder of the committed subset lists that
/// `tools/fonts/build_fonts.sh` passes to `pyftsubset --unicodes-file`.
const fontSubsetDir = 'tools/fonts/subset';

/// Repo-relative folder of the game's ARB files.
const arbDir = 'apps/game/lib/l10n';

/// Repo-relative file whose `LaunchLanguage('<code>', '<autonym>')` list
/// names each language in itself (frame 8.2).
const languageSheetPath =
    'apps/game/lib/features/settings/widgets/language_sheet.dart';

/// A Unicode range kept whole in a script subset.
typedef CodeRange = ({int first, int last, String name});

/// One script face's subset (l10n.md §4.3–§4.4): its tokens.json
/// `font.scripts` key, the locales it draws, the blocks it keeps whole and
/// the list file build_fonts.sh reads.
final class ScriptSubset {
  const ScriptSubset({
    required this.script,
    required this.locales,
    required this.blocks,
    required this.file,
    required this.why,
  });

  /// The `font.scripts` key (`deva`, `jpan`).
  final String script;

  /// The locales tokens.json says the face draws.
  final List<String> locales;

  /// Ranges kept whole, so a copy change inside them never needs a rebuild.
  final List<CodeRange> blocks;

  /// The list's file name in [fontSubsetDir].
  final String file;

  /// One line on why the blocks are what they are.
  final String why;
}

/// The two script subsets. The Devanagari face keeps its whole block, so a
/// Hindi copy change never needs a font rebuild; the Japanese face keeps
/// the kana, punctuation and full-width blocks plus the kanji its sources
/// use (a new kanji needs `gen_font_subsets` and `build_fonts.sh`).
const scriptSubsets = [
  ScriptSubset(
    script: 'deva',
    locales: ['hi'],
    file: 'hi.txt',
    why:
        'The whole Devanagari block (pyftsubset keeps the conjuncts and '
        'matras through GSUB/GPOS closure), ZWNJ/ZWJ and the dotted circle '
        'the shaper inserts, and the rupee sign (m7-5: ₹ draws in Baloo 2 in '
        'every locale, through the fallback).',
    blocks: [
      (first: 0x0900, last: 0x097F, name: 'Devanagari'),
      (first: 0x200C, last: 0x200D, name: 'ZWNJ, ZWJ'),
      (first: 0x20B9, last: 0x20B9, name: 'rupee sign'),
      (first: 0x25CC, last: 0x25CC, name: 'dotted circle'),
    ],
  ),
  ScriptSubset(
    script: 'jpan',
    locales: ['ja'],
    file: 'ja.txt',
    why:
        'Kana, CJK punctuation and full-width forms whole; kanji only as '
        'the sources below use them.',
    blocks: [
      (first: 0x3000, last: 0x303F, name: 'CJK Symbols and Punctuation'),
      (first: 0x3041, last: 0x309F, name: 'Hiragana'),
      (first: 0x30A0, last: 0x30FF, name: 'Katakana'),
      (first: 0x31F0, last: 0x31FF, name: 'Katakana Phonetic Extensions'),
      (first: 0xFF01, last: 0xFF5E, name: 'Full-width ASCII variants'),
    ],
  ),
];

/// ARB keys whose text the OS draws in its own fonts, never the app: the
/// share sheet's text and the notification and its channel (l10n.md §4.5).
bool isOsDrawnArbKey(String key) =>
    key == 'dailyShareText' ||
    key == 'dailyShareTextNoStreak' ||
    key == 'dailyShareGlyph' ||
    key.startsWith('reminderNotification') ||
    key.startsWith('reminderChannel');

/// Characters no font has to draw: controls (Cc), format characters (Cf),
/// space separators (Zs, invisible or drawn as space), variation selectors
/// and emoji, which the system's colour emoji font draws.
bool isExemptCharacter(int c) {
  if (c < 0x20 || (c >= 0x7F && c <= 0x9F)) return true; // Cc
  const zs = {0x0020, 0x00A0, 0x1680, 0x202F, 0x205F, 0x3000};
  if (zs.contains(c) || (c >= 0x2000 && c <= 0x200A)) return true; // Zs
  const cf = {0x00AD, 0x061C, 0x06DD, 0x070F, 0x180E, 0xFEFF};
  if (cf.contains(c) ||
      (c >= 0x0600 && c <= 0x0605) ||
      (c >= 0x200B && c <= 0x200F) ||
      (c >= 0x202A && c <= 0x202E) ||
      (c >= 0x2060 && c <= 0x2064) ||
      (c >= 0x2066 && c <= 0x206F) ||
      (c >= 0xFFF9 && c <= 0xFFFB)) {
    return true; // Cf
  }
  if (c >= 0xFE00 && c <= 0xFE0F) return true; // variation selectors
  return isEmoji(c);
}

/// The emoji the copy uses and their neighbours: the pictographic planes
/// and the BMP symbols with an emoji presentation (☀ ❤ ⭐).
bool isEmoji(int c) =>
    (c >= 0x1F000 && c <= 0x1FAFF) ||
    (c >= 0x2600 && c <= 0x27BF) ||
    (c >= 0x2B00 && c <= 0x2BFF) ||
    c == 0x20E3;

/// Where a list's characters came from, for its header.
final class SubsetSources {
  SubsetSources({
    required this.characters,
    required this.arbFiles,
    required this.missingArbFiles,
    required this.sdkFiles,
    required this.autonyms,
  });

  /// Every non-exempt character the face may be asked to draw.
  final Set<int> characters;
  final List<String> arbFiles;
  final List<String> missingArbFiles;
  final List<String> sdkFiles;
  final List<String> autonyms;
}

/// The Flutter SDK the lists read `material_<locale>.arb` from:
/// `$FLUTTER_ROOT`, else the `flutter` on PATH, else the SDK whose Dart runs
/// this script (`bin/cache/dart-sdk/bin/dart`).
Directory findFlutterSdk() {
  bool isSdk(String dir) => Directory(
    p.join(dir, 'packages', 'flutter_localizations', 'lib', 'src', 'l10n'),
  ).existsSync();
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && isSdk(env)) return Directory(env);
  final separator = Platform.isWindows ? ';' : ':';
  for (final dir in (Platform.environment['PATH'] ?? '').split(separator)) {
    final flutter = File(p.join(dir, 'flutter'));
    if (!flutter.existsSync()) continue;
    final sdk = p.dirname(p.dirname(flutter.resolveSymbolicLinksSync()));
    if (isSdk(sdk)) return Directory(sdk);
  }
  final fromDart = p.normalize(
    p.join(p.dirname(Platform.resolvedExecutable), '..', '..', '..', '..'),
  );
  if (isSdk(fromDart)) return Directory(fromDart);
  throw StateError(
    'Could not find the Flutter SDK (set FLUTTER_ROOT or put flutter on '
    'PATH): the Japanese subset reads its material_ja.arb.',
  );
}

/// `LaunchLanguage('<code>', '<autonym>')` pairs in [source].
Map<String, String> parseAutonyms(String source) {
  final pairs = {
    for (final m in RegExp(
      r"LaunchLanguage\(\s*'([A-Za-z_]+)',\s*'([^']+)'\s*,?\s*\)",
    ).allMatches(source))
      m[1]!: m[2]!,
  };
  if (pairs.isEmpty) {
    throw const FormatException(
      'no LaunchLanguage(code, autonym) entries in $languageSheetPath',
    );
  }
  return pairs;
}

/// The string values of an ARB file, by key (`@` metadata skipped).
Map<String, String> arbValues(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('an ARB file must be a JSON object');
  }
  return {
    for (final MapEntry(:key, :value) in decoded.entries)
      if (!key.startsWith('@') && value is String) key: value,
  };
}

/// What intl prints for [locale]'s dates where the app shows them:
/// `DateFormat.EEEE` (the daily's weekday) and `DateFormat.MMMd` (the
/// Museum, the daily pill and the share text), for every weekday and month.
Future<String> intlDateText(String locale) async {
  await initializeDateFormatting(locale);
  final buffer = StringBuffer();
  for (var d = 0; d < 7; d++) {
    // 2026-01-05 is a Monday.
    buffer.write(DateFormat.EEEE(locale).format(DateTime(2026, 1, 5 + d)));
  }
  for (var m = 1; m <= 12; m++) {
    buffer.write(DateFormat.MMMd(locale).format(DateTime(2026, m, 28)));
  }
  return buffer.toString();
}

/// Reads every source of [subset]'s characters (l10n.md §4.4): the game's
/// `app_<locale>.arb` (when it exists), intl's dates, the Flutter SDK's
/// `material_<locale>.arb` values (the time picker and any Material text)
/// and the language's autonym.
Future<SubsetSources> readSubsetSources(
  ScriptSubset subset, {
  required Directory root,
  required Directory flutterSdk,
}) async {
  final text = StringBuffer();
  final arbFiles = <String>[];
  final missing = <String>[];
  final sdkFiles = <String>[];
  final autonyms = <String>[];
  final sheet = parseAutonyms(
    File(p.join(root.path, languageSheetPath)).readAsStringSync(),
  );
  for (final locale in subset.locales) {
    final arb = '$arbDir/app_$locale.arb';
    final arbFile = File(p.join(root.path, arb));
    if (arbFile.existsSync()) {
      arbFiles.add(arb);
      for (final MapEntry(:key, :value) in arbValues(
        arbFile.readAsStringSync(),
      ).entries) {
        if (!isOsDrawnArbKey(key)) text.write(value);
      }
    } else {
      missing.add(arb);
    }
    text.write(await intlDateText(locale));
    const material = 'packages/flutter_localizations/lib/src/l10n';
    final materialArb = File(
      p.join(flutterSdk.path, material, 'material_$locale.arb'),
    );
    if (!materialArb.existsSync()) {
      throw StateError('${materialArb.path} is missing');
    }
    sdkFiles.add('$material/material_$locale.arb');
    text.write(arbValues(materialArb.readAsStringSync()).values.join());
    final autonym = sheet[locale];
    if (autonym == null) {
      throw FormatException('$languageSheetPath has no autonym for $locale');
    }
    autonyms.add(autonym);
    text.write(autonym);
  }
  return SubsetSources(
    characters: {
      for (final rune in text.toString().runes)
        if (!isExemptCharacter(rune)) rune,
    },
    arbFiles: arbFiles,
    missingArbFiles: missing,
    sdkFiles: sdkFiles,
    autonyms: autonyms,
  );
}

/// The characters both Latin families draw at every bundled weight: those
/// stay in Fredoka or Nunito (m7-4 9.1: Latin letters and digits never come
/// from the script face).
Set<int> latinCoverage(Map<String, List<BundledFont>> fonts) {
  Set<int> family(String name) {
    final files = fonts[name];
    if (files == null || files.isEmpty) {
      throw StateError('no bundled $name files in $bundledFontsDir');
    }
    return files
        .map((f) => f.info.codepoints)
        .reduce((a, b) => a.intersection(b));
  }

  return family('Fredoka').union(family('Nunito'));
}

/// The list file for [subset]: its blocks, then every source character
/// outside them that the Latin faces don't draw.
String subsetListSource(
  ScriptSubset subset,
  SubsetSources sources, {
  required Set<int> latin,
  required String designFamily,
}) {
  bool inBlocks(int c) => subset.blocks.any((b) => c >= b.first && c <= b.last);
  final extras =
      sources.characters
          .where((c) => !inBlocks(c) && !latin.contains(c))
          .toList()
        ..sort();
  String hex(int c) => 'U+${c.toRadixString(16).toUpperCase().padLeft(4, '0')}';
  final lines = <String>[
    '# GENERATED — do not edit; run: dart run nesty_tools:gen_font_subsets',
    '#',
    '# The $designFamily subset (tokens.json font.scripts.${subset.script}, '
        'locales ${subset.locales.join(', ')})',
    '# that tools/fonts/build_fonts.sh cuts with pyftsubset --unicodes-file.',
    '# ${subset.why}',
    '#',
    '# Whole blocks:',
    for (final b in subset.blocks)
      '${b.first == b.last ? hex(b.first) : '${hex(b.first)}-${hex(b.last).substring(2)}'}'
          ' # ${b.name}',
    '#',
    '# Characters outside the blocks that Fredoka and Nunito do not draw, from:',
    for (final arb in sources.arbFiles) '#   $arb',
    for (final arb in sources.missingArbFiles)
      '#   $arb (not written yet: rerun when it is)',
    for (final locale in subset.locales)
      "#   intl's $locale dates (DateFormat.EEEE and MMMd)",
    for (final sdk in sources.sdkFiles) '#   flutter/$sdk',
    '#   the autonym${sources.autonyms.length == 1 ? '' : 's'} '
        '${sources.autonyms.join(', ')} ($languageSheetPath)',
    if (extras.isEmpty) '# (none)',
    for (final c in extras) '${hex(c)} # ${String.fromCharCode(c)}',
  ];
  return '${lines.join('\n')}\n';
}

/// Every subset list, by repo-relative path.
Future<Map<String, String>> generateFontSubsets({
  required Directory root,
  required Directory flutterSdk,
  required Map<String, Object?> fontScripts,
}) async {
  final latin = latinCoverage(loadBundledFonts(root));
  final out = <String, String>{};
  for (final subset in scriptSubsets) {
    final token = fontScripts[subset.script];
    if (token is! Map<String, Object?>) {
      throw StateError('tokens.json has no font.scripts.${subset.script}');
    }
    final locales = token['locales'];
    if (locales is! List ||
        locales.length != subset.locales.length ||
        !subset.locales.every(locales.contains)) {
      throw StateError(
        'tokens.json font.scripts.${subset.script}.locales is $locales; '
        'the subset table in tools/lib/src/fonts/font_subsets.dart says '
        '${subset.locales}',
      );
    }
    final family = token['family'];
    if (family is! String) {
      throw StateError('tokens.json font.scripts.${subset.script}.family');
    }
    final sources = await readSubsetSources(
      subset,
      root: root,
      flutterSdk: flutterSdk,
    );
    out['$fontSubsetDir/${subset.file}'] = subsetListSource(
      subset,
      sources,
      latin: latin,
      designFamily: family,
    );
  }
  return out;
}
