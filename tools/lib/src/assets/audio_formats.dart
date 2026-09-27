/// Format checks for the audio `sync_design_assets` ships (tokens.json
/// `sound.format`, `design/audio/AUDIO.md` "Files"): SFX are 44.1 kHz mono
/// 16-bit PCM WAV; music loops and jingles are 44.1 kHz stereo Ogg Vorbis.
/// Pure Dart, byte-level: the files ship byte for byte, so a file the
/// engine (flutter_soloud's dr_wav and libvorbisfile) can't read must stop
/// the sync.
library;

import 'dart:typed_data';

import 'package:nesty_tools/src/tokens/sound_files.dart';

/// The SFX WAV format: PCM, mono, [soundSampleRate], 16-bit.
const sfxWavChannels = 1;
const sfxWavBitsPerSample = 16;

/// The music and jingle format: Vorbis, stereo, [soundSampleRate].
const oggVorbisChannels = 2;

/// Problems with a WAV file against the SFX format. Empty when it ships.
List<String> validateSfxWav(List<int> bytes) {
  final data = Uint8List.fromList(bytes);
  final view = ByteData.sublistView(data);
  if (data.length < 12 ||
      _ascii(data, 0, 4) != 'RIFF' ||
      _ascii(data, 8, 12) != 'WAVE') {
    return const ['not a RIFF/WAVE file'];
  }
  final issues = <String>[];
  final riffSize = view.getUint32(4, Endian.little);
  if (riffSize + 8 != data.length) {
    issues.add(
      'the RIFF size says ${riffSize + 8} bytes, the file has '
      '${data.length}',
    );
  }
  int? format;
  int? channels;
  int? sampleRate;
  int? byteRate;
  int? blockAlign;
  int? bits;
  int? dataBytes;
  var offset = 12;
  while (offset + 8 <= data.length) {
    final id = _ascii(data, offset, offset + 4);
    final size = view.getUint32(offset + 4, Endian.little);
    final body = offset + 8;
    if (body + size > data.length) {
      issues.add('chunk "$id" runs past the end of the file');
      break;
    }
    if (id == 'fmt ') {
      if (size < 16) {
        issues.add('the fmt chunk is $size bytes, expected at least 16');
      } else {
        format = view.getUint16(body, Endian.little);
        channels = view.getUint16(body + 2, Endian.little);
        sampleRate = view.getUint32(body + 4, Endian.little);
        byteRate = view.getUint32(body + 8, Endian.little);
        blockAlign = view.getUint16(body + 12, Endian.little);
        bits = view.getUint16(body + 14, Endian.little);
      }
    } else if (id == 'data') {
      if (format == null) issues.add('the data chunk comes before fmt');
      dataBytes = size;
    }
    // Chunks are word-aligned: an odd size has a pad byte.
    offset = body + size + (size & 1);
  }
  if (format == null) return [...issues, 'no fmt chunk'];
  if (dataBytes == null) return [...issues, 'no data chunk'];
  if (format != 1) issues.add('format $format, expected 1 (PCM)');
  if (channels != sfxWavChannels) {
    issues.add('$channels channels, expected $sfxWavChannels (mono)');
  }
  if (sampleRate != soundSampleRate) {
    issues.add('$sampleRate Hz, expected $soundSampleRate');
  }
  if (bits != sfxWavBitsPerSample) {
    issues.add('$bits-bit, expected $sfxWavBitsPerSample-bit');
  }
  final frameBytes = channels! * bits! ~/ 8;
  if (blockAlign != frameBytes || byteRate != sampleRate! * frameBytes) {
    issues.add(
      'block align $blockAlign / byte rate $byteRate do not match '
      '$channels × $bits-bit at $sampleRate Hz',
    );
  }
  if (dataBytes == 0 || (frameBytes > 0 && dataBytes % frameBytes != 0)) {
    issues.add('the data chunk holds $dataBytes bytes, not whole frames');
  }
  return issues;
}

/// What [readOggVorbis] found in a readable stream.
final class OggVorbisInfo {
  const OggVorbisInfo({
    required this.channels,
    required this.sampleRate,
    required this.pages,
    required this.lastGranule,
  });

  final int channels;
  final int sampleRate;
  final int pages;

  /// The last page's granule position: the stream's length in frames.
  final int lastGranule;
}

/// The result of [readOggVorbis]: [info] is null when the stream can't be
/// walked at all.
final class OggVorbisCheck {
  const OggVorbisCheck(this.info, this.issues);

  final OggVorbisInfo? info;

  /// Empty when the file ships.
  final List<String> issues;
}

/// Walks every Ogg page of [bytes] and checks it against the music and
/// jingle format: each page has the `OggS` capture pattern, version 0 and a
/// valid CRC; one logical stream, begun on the first page and ended on the
/// last, with no bytes after it; its first packet is a Vorbis
/// identification header for a stereo [soundSampleRate] stream.
OggVorbisCheck readOggVorbis(List<int> bytes) {
  final data = Uint8List.fromList(bytes);
  final view = ByteData.sublistView(data);
  final issues = <String>[];
  var offset = 0;
  var pages = 0;
  int? serial;
  var lastGranule = 0;
  var lastFlags = 0;
  int? channels;
  int? sampleRate;
  while (offset < data.length) {
    final at = 'page $pages (byte $offset)';
    if (offset + 27 > data.length ||
        _ascii(data, offset, offset + 4) != 'OggS') {
      issues.add(
        pages == 0
            ? 'not an Ogg file (no OggS capture pattern)'
            : '$at: no OggS capture pattern',
      );
      return OggVorbisCheck(null, issues);
    }
    final version = data[offset + 4];
    final flags = data[offset + 5];
    final granule = view.getInt64(offset + 6, Endian.little);
    final pageSerial = view.getUint32(offset + 14, Endian.little);
    final sequence = view.getUint32(offset + 18, Endian.little);
    final checksum = view.getUint32(offset + 22, Endian.little);
    final segments = data[offset + 26];
    final headerEnd = offset + 27 + segments;
    if (headerEnd > data.length) {
      issues.add('$at: the segment table runs past the end of the file');
      return OggVorbisCheck(null, issues);
    }
    var bodyBytes = 0;
    for (var i = offset + 27; i < headerEnd; i++) {
      bodyBytes += data[i];
    }
    final end = headerEnd + bodyBytes;
    if (end > data.length) {
      issues.add('$at: the page runs past the end of the file');
      return OggVorbisCheck(null, issues);
    }
    if (version != 0) issues.add('$at: stream structure version $version');
    if (_oggCrc(data, offset, end) != checksum) {
      issues.add('$at: CRC mismatch');
    }
    serial ??= pageSerial;
    if (pageSerial != serial) {
      issues.add('$at: a second logical stream ($pageSerial)');
    }
    if (sequence != pages) issues.add('$at: sequence number $sequence');
    final begins = flags & 0x02 != 0;
    if (begins != (pages == 0)) {
      issues.add(
        pages == 0
            ? '$at: the first page does not begin the stream'
            : '$at: begins a stream mid-file',
      );
    }
    if (pages > 0 && lastFlags & 0x04 != 0) {
      issues.add('$at: comes after the end-of-stream page');
    }
    if (pages == 0) {
      // Vorbis I §4.2.2: the identification header is the first packet,
      // alone on the first page.
      final body = headerEnd;
      if (bodyBytes < 30 ||
          data[body] != 1 ||
          _ascii(data, body + 1, body + 7) != 'vorbis') {
        issues.add('the first packet is not a Vorbis identification header');
        return OggVorbisCheck(null, issues);
      }
      final vorbisVersion = view.getUint32(body + 7, Endian.little);
      channels = data[body + 11];
      sampleRate = view.getUint32(body + 12, Endian.little);
      if (vorbisVersion != 0) issues.add('Vorbis version $vorbisVersion');
      if (data[body + 29] & 1 != 1) {
        issues.add('the identification header has no framing bit');
      }
    }
    lastGranule = granule;
    lastFlags = flags;
    pages++;
    offset = end;
  }
  if (pages > 0 && lastFlags & 0x04 == 0) {
    issues.add('the last page does not end the stream');
  }
  if (channels != oggVorbisChannels) {
    issues.add('$channels channels, expected $oggVorbisChannels (stereo)');
  }
  if (sampleRate != soundSampleRate) {
    issues.add('$sampleRate Hz, expected $soundSampleRate');
  }
  return OggVorbisCheck(
    OggVorbisInfo(
      channels: channels ?? 0,
      sampleRate: sampleRate ?? 0,
      pages: pages,
      lastGranule: lastGranule,
    ),
    issues,
  );
}

String _ascii(Uint8List data, int start, int end) =>
    end > data.length ? '' : String.fromCharCodes(data, start, end);

/// Ogg's CRC-32 (polynomial 0x04C11DB7, no reflection, initial value 0, no
/// final XOR) of the page [start]…[end] with its checksum field as zeros.
int _oggCrc(Uint8List data, int start, int end) {
  var crc = 0;
  for (var i = start; i < end; i++) {
    final byte = (i >= start + 22 && i < start + 26) ? 0 : data[i];
    crc = ((crc << 8) & 0xFFFFFFFF) ^ _crcTable[((crc >> 24) ^ byte) & 0xFF];
  }
  return crc;
}

final List<int> _crcTable = List<int>.generate(256, (n) {
  var r = n << 24;
  for (var i = 0; i < 8; i++) {
    r = (r & 0x80000000) != 0 ? ((r << 1) ^ 0x04C11DB7) : (r << 1);
    r &= 0xFFFFFFFF;
  }
  return r;
}, growable: false);
