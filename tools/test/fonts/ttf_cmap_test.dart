import 'dart:io';
import 'dart:typed_data';

import 'package:nesty_tools/src/fonts/bundled_fonts.dart';
import 'package:nesty_tools/src/fonts/ttf_cmap.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// A minimal sfnt: a `cmap` with the given subtables (platform, encoding,
/// bytes) and an `OS/2` holding only its version, avgCharWidth and
/// usWeightClass.
Uint8List _font(List<(int, int, Uint8List)> subtables, {int weight = 400}) {
  final cmap = BytesBuilder();
  final header = ByteData(4 + subtables.length * 8)
    ..setUint16(0, 0)
    ..setUint16(2, subtables.length);
  var offset = header.lengthInBytes;
  for (var i = 0; i < subtables.length; i++) {
    final (platform, encoding, bytes) = subtables[i];
    header
      ..setUint16(4 + i * 8, platform)
      ..setUint16(6 + i * 8, encoding)
      ..setUint32(8 + i * 8, offset);
    offset += bytes.length;
  }
  cmap.add(header.buffer.asUint8List());
  for (final (_, _, bytes) in subtables) {
    cmap.add(bytes);
  }
  final cmapBytes = cmap.toBytes();
  final os2 = ByteData(6)
    ..setUint16(0, 4)
    ..setUint16(4, weight);
  final tables = [('OS/2', os2.buffer.asUint8List()), ('cmap', cmapBytes)];
  final out = BytesBuilder();
  final dir = ByteData(12 + tables.length * 16)
    ..setUint32(0, 0x00010000)
    ..setUint16(4, tables.length);
  var at = dir.lengthInBytes;
  for (var i = 0; i < tables.length; i++) {
    final (tag, bytes) = tables[i];
    for (var b = 0; b < 4; b++) {
      dir.setUint8(12 + i * 16 + b, tag.codeUnitAt(b));
    }
    dir
      ..setUint32(12 + i * 16 + 8, at)
      ..setUint32(12 + i * 16 + 12, bytes.length);
    at += bytes.length;
  }
  out.add(dir.buffer.asUint8List());
  for (final (_, bytes) in tables) {
    out.add(bytes);
  }
  return out.toBytes();
}

/// A format-4 subtable with one delta segment (start..end → glyphs from
/// [firstGlyph]), one idRangeOffset segment ([mapped] codepoints, glyph 0
/// for the zeros) and the 0xFFFF terminator.
Uint8List _format4({
  required int start,
  required int end,
  required int firstGlyph,
  required int rangeStart,
  required List<int> rangeGlyphs,
}) {
  const segCount = 3;
  final rangeEnd = rangeStart + rangeGlyphs.length - 1;
  final length = 16 + segCount * 8 + rangeGlyphs.length * 2;
  final d = ByteData(length)
    ..setUint16(0, 4)
    ..setUint16(2, length)
    ..setUint16(6, segCount * 2);
  const ends = 14;
  const starts = ends + segCount * 2 + 2;
  const deltas = starts + segCount * 2;
  const ranges = deltas + segCount * 2;
  const glyphArray = ranges + segCount * 2;
  d
    ..setUint16(ends, end)
    ..setUint16(ends + 2, rangeEnd)
    ..setUint16(ends + 4, 0xFFFF)
    ..setUint16(starts, start)
    ..setUint16(starts + 2, rangeStart)
    ..setUint16(starts + 4, 0xFFFF)
    ..setUint16(deltas, (firstGlyph - start) & 0xFFFF)
    ..setUint16(deltas + 2, 0)
    ..setUint16(deltas + 4, 1)
    ..setUint16(ranges, 0)
    // From segment 1's idRangeOffset entry to glyphArray[0].
    ..setUint16(ranges + 2, glyphArray - (ranges + 2))
    ..setUint16(ranges + 4, 0);
  for (var i = 0; i < rangeGlyphs.length; i++) {
    d.setUint16(glyphArray + i * 2, rangeGlyphs[i]);
  }
  return d.buffer.asUint8List();
}

Uint8List _format12(List<(int, int, int)> groups) {
  final d = ByteData(16 + groups.length * 12)
    ..setUint16(0, 12)
    ..setUint32(4, 16 + groups.length * 12)
    ..setUint32(12, groups.length);
  for (var i = 0; i < groups.length; i++) {
    final (start, end, glyph) = groups[i];
    d
      ..setUint32(16 + i * 12, start)
      ..setUint32(20 + i * 12, end)
      ..setUint32(24 + i * 12, glyph);
  }
  return d.buffer.asUint8List();
}

void main() {
  group('TtfInfo', () {
    test('reads a format-4 cmap: delta and idRangeOffset segments', () {
      final info = TtfInfo.parse(
        _font([
          (
            3,
            1,
            _format4(
              start: 0x41,
              end: 0x43,
              firstGlyph: 5,
              rangeStart: 0x3041,
              rangeGlyphs: [9, 0, 11],
            ),
          ),
        ], weight: 700),
      );
      expect(info.codepoints, {0x41, 0x42, 0x43, 0x3041, 0x3043});
      expect(info.covers(0x3042), isFalse, reason: 'glyph 0 is .notdef');
      expect(info.weightClass, 700);
    });

    test('prefers the full format-12 table over format 4', () {
      final info = TtfInfo.parse(
        _font([
          (
            3,
            1,
            _format4(
              start: 0x41,
              end: 0x41,
              firstGlyph: 1,
              rangeStart: 0x42,
              rangeGlyphs: [2],
            ),
          ),
          (3, 10, _format12([(0x41, 0x42, 1), (0x1F600, 0x1F601, 3)])),
        ]),
      );
      expect(info.codepoints, {0x41, 0x42, 0x1F600, 0x1F601});
    });

    test('ignores non-Unicode subtables and rejects other files', () {
      expect(
        () => TtfInfo.parse(
          _font([
            (1, 0, _format12([(0x41, 0x41, 1)])),
          ]),
        ),
        throwsFormatException,
      );
      expect(
        () => TtfInfo.parse(Uint8List.fromList('not a font'.codeUnits)),
        throwsFormatException,
      );
    });

    final root = findRepoRoot();
    test('reads the bundled icon font: exactly its codepoints file', () {
      final dir = p.join(root.path, bundledFontsDir);
      final info = TtfInfo.parse(
        File(p.join(dir, 'NestySymbolsRounded.ttf')).readAsBytesSync(),
      );
      final listed = {
        for (final line in File(
          p.join(dir, 'NestySymbolsRounded.codepoints'),
        ).readAsLinesSync())
          if (line.trim().isNotEmpty)
            int.parse(line.trim().split(RegExp(r'\s+'))[1], radix: 16),
      };
      expect(info.codepoints, listed);
    });

    test('reads the bundled Latin faces: weight classes and families', () {
      final fonts = loadBundledFonts(root);
      for (final family in ['Fredoka', 'Nunito']) {
        for (final font in fonts[family]!) {
          expect(font.info.weightClass, font.outlineWeight, reason: '$font');
          expect(font.info.familyName, startsWith(family), reason: '$font');
          for (final c in 'AZaz09'.codeUnits) {
            expect(font.info.covers(c), isTrue, reason: '$font');
          }
        }
      }
    });
  });

  group('matchWeight (CSS Fonts 3, as Skia matches)', () {
    final root = findRepoRoot();
    final fonts = loadBundledFonts(root);
    int match(String family, int weight) =>
        matchWeight(fonts[family]!, weight).info.weightClass;

    test('exact weights first', () {
      expect(match('Nunito', 700), 700);
      expect(match('Fredoka', 500), 500);
    });

    test('above 500: heavier first, then lighter', () {
      expect(match('Fredoka', 800), 700);
      expect(match('Fredoka', 900), 700);
    });

    test('400–500: up to 500, then lighter, then heavier', () {
      expect(match('Fredoka', 400), 500);
      expect(match('Nunito', 450), 500);
    });

    test('below 400: lighter first, then heavier', () {
      expect(match('Nunito', 300), 500);
    });
  });
}
