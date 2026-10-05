import 'dart:typed_data';

/// The parts of a TrueType/OpenType font the font checks need, read in pure
/// Dart (no fontTools on CI's test runners): the characters its `cmap`
/// maps, its `OS/2` weight class and its `name` table's family.
///
/// Only the Unicode cmap subtables are read: platform 3 encoding 10 or
/// platform 0 encoding 4/6 (format 12, the full range), else platform 3
/// encoding 1 or platform 0 encodings 0–3 (format 4, the BMP). That is what
/// fontTools writes and what Skia picks, so a character listed here is one
/// the engine can draw from this file (l10n.md §4.5).
final class TtfInfo {
  TtfInfo._(this.codepoints, this.weightClass, this.familyName);

  /// Parses [bytes]; throws [FormatException] when they are not a TrueType
  /// or CFF OpenType font with a Unicode cmap.
  factory TtfInfo.parse(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    final tables = _tableDirectory(data);
    final cmap = tables['cmap'];
    if (cmap == null) throw const FormatException('the font has no cmap');
    final codepoints = _readCmap(data, cmap.offset);
    final os2 = tables['OS/2'];
    final weight = os2 == null || os2.length < 6
        ? 400
        : data.getUint16(os2.offset + 4);
    final name = tables['name'];
    return TtfInfo._(
      codepoints,
      weight,
      name == null ? null : _familyName(data, name.offset),
    );
  }

  /// Every Unicode scalar value the font maps to a glyph (glyph 0, .notdef,
  /// excluded).
  final Set<int> codepoints;

  /// `OS/2.usWeightClass`: what the engine matches a `FontWeight` against
  /// (it ignores pubspec's `weight:`), 400 when the table is missing.
  final int weightClass;

  /// The `name` table's family (name ID 1), when it has a readable one.
  final String? familyName;

  /// Whether the font maps [codepoint].
  bool covers(int codepoint) => codepoints.contains(codepoint);
}

final class _Table {
  const _Table(this.offset, this.length);
  final int offset;
  final int length;
}

Map<String, _Table> _tableDirectory(ByteData data) {
  if (data.lengthInBytes < 12) throw const FormatException('too short');
  final version = data.getUint32(0);
  // 0x00010000 TrueType, 'OTTO' CFF, 'true' (old Apple TrueType).
  if (version != 0x00010000 && version != 0x4F54544F && version != 0x74727565) {
    throw FormatException(
      'not a TrueType/OpenType font (0x${version.toRadixString(16)})',
    );
  }
  final count = data.getUint16(4);
  final tables = <String, _Table>{};
  for (var i = 0; i < count; i++) {
    final record = 12 + i * 16;
    if (record + 16 > data.lengthInBytes) {
      throw const FormatException('truncated table directory');
    }
    final tag = String.fromCharCodes([
      for (var b = 0; b < 4; b++) data.getUint8(record + b),
    ]);
    final offset = data.getUint32(record + 8);
    final length = data.getUint32(record + 12);
    if (offset + length > data.lengthInBytes) {
      throw FormatException('table $tag runs past the end of the file');
    }
    tables[tag] = _Table(offset, length);
  }
  return tables;
}

Set<int> _readCmap(ByteData data, int cmap) {
  final count = data.getUint16(cmap + 2);
  int? full; // format 12
  int? bmp; // format 4
  for (var i = 0; i < count; i++) {
    final record = cmap + 4 + i * 8;
    final platform = data.getUint16(record);
    final encoding = data.getUint16(record + 2);
    final offset = cmap + data.getUint32(record + 4);
    final format = data.getUint16(offset);
    final unicode =
        (platform == 3 && (encoding == 1 || encoding == 10)) || platform == 0;
    if (!unicode) continue;
    if (format == 12) {
      full ??= offset;
    } else if (format == 4) {
      bmp ??= offset;
    }
  }
  if (full != null) return _format12(data, full);
  if (bmp != null) return _format4(data, bmp);
  throw const FormatException('no Unicode cmap subtable of format 4 or 12');
}

Set<int> _format4(ByteData data, int table) {
  final segCountX2 = data.getUint16(table + 6);
  final segCount = segCountX2 ~/ 2;
  final endCodes = table + 14;
  final startCodes = endCodes + segCountX2 + 2; // + reservedPad
  final idDeltas = startCodes + segCountX2;
  final idRangeOffsets = idDeltas + segCountX2;
  final out = <int>{};
  for (var s = 0; s < segCount; s++) {
    final end = data.getUint16(endCodes + s * 2);
    final start = data.getUint16(startCodes + s * 2);
    final delta = data.getUint16(idDeltas + s * 2);
    final rangeOffsetAt = idRangeOffsets + s * 2;
    final rangeOffset = data.getUint16(rangeOffsetAt);
    if (start > end) continue;
    for (var c = start; c <= end; c++) {
      if (c == 0xFFFF) break;
      int glyph;
      if (rangeOffset == 0) {
        glyph = (c + delta) & 0xFFFF;
      } else {
        final at = rangeOffsetAt + rangeOffset + (c - start) * 2;
        if (at + 2 > data.lengthInBytes) continue;
        final raw = data.getUint16(at);
        glyph = raw == 0 ? 0 : (raw + delta) & 0xFFFF;
      }
      if (glyph != 0) out.add(c);
    }
  }
  return out;
}

Set<int> _format12(ByteData data, int table) {
  final groups = data.getUint32(table + 12);
  final out = <int>{};
  for (var g = 0; g < groups; g++) {
    final group = table + 16 + g * 12;
    final start = data.getUint32(group);
    final end = data.getUint32(group + 4);
    final startGlyph = data.getUint32(group + 8);
    if (end < start || end > 0x10FFFF) {
      throw FormatException('bad cmap group $start..$end');
    }
    for (var c = start; c <= end; c++) {
      if (startGlyph + (c - start) != 0) out.add(c);
    }
  }
  return out;
}

String? _familyName(ByteData data, int name) {
  final count = data.getUint16(name + 2);
  final strings = name + data.getUint16(name + 4);
  String? fallback;
  for (var i = 0; i < count; i++) {
    final record = name + 6 + i * 12;
    final platform = data.getUint16(record);
    final nameId = data.getUint16(record + 6);
    if (nameId != 1) continue;
    final length = data.getUint16(record + 8);
    final offset = strings + data.getUint16(record + 10);
    if (offset + length > data.lengthInBytes) continue;
    if (platform == 3 || platform == 0) {
      // UTF-16BE.
      return String.fromCharCodes([
        for (var b = 0; b + 1 < length; b += 2) data.getUint16(offset + b),
      ]);
    }
    if (platform == 1) {
      fallback ??= String.fromCharCodes([
        for (var b = 0; b < length; b++) data.getUint8(offset + b),
      ]);
    }
  }
  return fallback;
}
