/// Format checks for the museum figurine PNGs `sync_design_assets` ships
/// (docs/plans/m3-design.md §9.5): they must be real PNGs at the art's
/// 600×600 size. Pure Dart, byte-level: the files ship byte for byte, so a
/// file `package:flutter`'s image codec can't decode must stop the sync.
library;

import 'dart:typed_data';

/// The museum figurine art's fixed size (design/museum/png/*.png).
const museumPngSize = 600;

const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// Problems with a museum figurine PNG. Empty when it ships.
List<String> validateMuseumPng(List<int> bytes) {
  final data = Uint8List.fromList(bytes);
  if (data.length < 8 || !_matches(data, 0, _pngSignature)) {
    return const ['not a PNG file (bad signature)'];
  }
  // The IHDR chunk is always first: 4-byte length, "IHDR", then width and
  // height as big-endian uint32s (the PNG spec).
  if (data.length < 8 + 4 + 4 + 8 ||
      String.fromCharCodes(data, 12, 16) != 'IHDR') {
    return const ['no IHDR chunk'];
  }
  final view = ByteData.sublistView(data);
  final width = view.getUint32(16, Endian.big);
  final height = view.getUint32(20, Endian.big);
  if (width != museumPngSize || height != museumPngSize) {
    return ['$width×$height, expected $museumPngSize×$museumPngSize'];
  }
  return const [];
}

bool _matches(Uint8List data, int offset, List<int> pattern) {
  for (var i = 0; i < pattern.length; i++) {
    if (data[offset + i] != pattern[i]) return false;
  }
  return true;
}
