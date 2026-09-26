/// Repo-relative inputs and output of the icon codegen.
const glyphListPath = 'tools/fonts/nesty_symbols.txt';
const iconCodepointsPath =
    'apps/game/assets/fonts/NestySymbolsRounded.codepoints';
const nestyIconsPath = 'apps/game/lib/core/ui/icons/nesty_icons.gen.dart';

/// The font family `apps/game/pubspec.yaml` declares for the subset.
const nestySymbolsFamily = 'NestySymbols';

// Material's own convention: these point "forward/back" and flip in RTL.
const _mirrored = {'arrow_back', 'arrow_forward', 'chevron_right'};

final _glyphName = RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$');

/// Parses the glyph list (one name per line, `#` comments).
List<String> parseGlyphList(String text) => [
  for (final raw in text.split('\n'))
    if (raw.split('#').first.trim() case final line when line.isNotEmpty) line,
];

/// Parses a Material Symbols `.codepoints` file (`name hex` per line).
Map<String, int> parseCodepoints(String text) {
  final result = <String, int>{};
  for (final (index, raw) in text.split('\n').indexed) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final parts = line.split(RegExp(r'\s+'));
    final code = parts.length == 2 ? int.tryParse(parts[1], radix: 16) : null;
    if (code == null || !_glyphName.hasMatch(parts[0])) {
      throw FormatException('Bad codepoints line ${index + 1}', raw);
    }
    if (result.containsKey(parts[0])) {
      throw FormatException('Duplicate glyph ${parts[0]}', raw);
    }
    result[parts[0]] = code;
  }
  return result;
}

/// `local_fire_department` → `localFireDepartment`.
String iconMemberName(String glyph) {
  final parts = glyph.split('_');
  final name = [
    parts.first,
    for (final part in parts.skip(1))
      '${part[0].toUpperCase()}${part.substring(1)}',
  ].join();
  if (RegExp(r'^[0-9]').hasMatch(name)) return 'icon$name';
  return name;
}

/// Emits `nesty_icons.gen.dart` (unformatted) for [glyphs], in list order.
/// Every glyph must have a codepoint, and the codepoints file must list
/// nothing else, so the Dart constants and the shipped font can't drift.
String nestyIconsSource({
  required List<String> glyphs,
  required Map<String, int> codepoints,
}) {
  final missing = [
    for (final g in glyphs)
      if (!codepoints.containsKey(g)) g,
  ];
  final extra = codepoints.keys.where((k) => !glyphs.contains(k)).toList();
  if (missing.isNotEmpty || extra.isNotEmpty) {
    throw StateError(
      'Glyph list and font codepoints differ '
      '(missing: $missing, extra: $extra). Run tools/fonts/build_fonts.sh.',
    );
  }
  final members = <String>{};
  final buffer = StringBuffer()
    ..writeln(
      '// GENERATED — do not edit; run dart run nesty_tools:gen_nesty_icons',
    )
    ..writeln('//')
    ..writeln('// Source: $iconCodepointsPath (built by')
    ..writeln('// tools/fonts/build_fonts.sh from $glyphListPath).')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln(
      '/// The Material Symbols Rounded glyphs the design uses (FILL 1, wght 600,',
    )
    ..writeln(
      '/// GRAD 0, opsz 24), bundled as the `$nestySymbolsFamily` font subset.',
    )
    ..writeln('///')
    ..writeln(
      '/// Use these instead of `Icons.*`: the subset is all the app ships, so it',
    )
    ..writeln('/// works offline and stays small (design/README.md "Icons").')
    ..writeln('abstract final class NestyIcons {')
    ..writeln('  /// The font family declared in `apps/game/pubspec.yaml`.')
    ..writeln("  static const fontFamily = '$nestySymbolsFamily';")
    ..writeln();
  for (final glyph in glyphs) {
    final member = iconMemberName(glyph);
    if (!members.add(member)) {
      throw StateError('Two glyphs map to NestyIcons.$member');
    }
    final hex = codepoints[glyph]!.toRadixString(16).padLeft(4, '0');
    buffer
      ..writeln('  /// `$glyph`')
      ..writeln(
        '  static const IconData $member = '
        'IconData(0x$hex, fontFamily: fontFamily'
        '${_mirrored.contains(glyph) ? ', matchTextDirection: true' : ''});',
      )
      ..writeln();
  }
  buffer
    ..writeln('  /// Every glyph by its upstream name, for tests and tooling.')
    ..writeln('  static const Map<String, IconData> byName = {');
  for (final glyph in glyphs) {
    buffer.writeln("    '$glyph': ${iconMemberName(glyph)},");
  }
  buffer
    ..writeln('  };')
    ..writeln('}');
  return buffer.toString();
}
