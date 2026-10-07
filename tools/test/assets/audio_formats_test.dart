import 'dart:io';
import 'dart:typed_data';

import 'package:nesty_tools/src/assets/audio_formats.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// A WAV with one `fmt ` and one `data` chunk (plus [extra] chunks after
/// it), 44.1 kHz mono 16-bit PCM unless told otherwise.
List<int> _wav({
  int format = 1,
  int channels = 1,
  int rate = 44100,
  int bits = 16,
  int frames = 2,
  bool dataChunk = true,
  List<(String, int)> extra = const [],
  int riffSizeDelta = 0,
}) {
  final frameBytes = channels * bits ~/ 8;
  final body = BytesBuilder()..add('WAVE'.codeUnits);
  void chunk(String id, List<int> data) {
    body
      ..add(id.codeUnits)
      ..add(_u32(data.length))
      ..add(data);
    if (data.length.isOdd) body.addByte(0);
  }

  chunk('fmt ', [
    ..._u16(format),
    ..._u16(channels),
    ..._u32(rate),
    ..._u32(rate * frameBytes),
    ..._u16(frameBytes),
    ..._u16(bits),
  ]);
  if (dataChunk) chunk('data', List.filled(frames * frameBytes, 0));
  for (final (id, size) in extra) {
    chunk(id, List.filled(size, 7));
  }
  final bytes = body.toBytes();
  return [...'RIFF'.codeUnits, ..._u32(bytes.length + riffSizeDelta), ...bytes];
}

List<int> _u16(int v) => [v & 0xFF, v >> 8 & 0xFF];

List<int> _u32(int v) => [for (var i = 0; i < 4; i++) v >> (8 * i) & 0xFF];

List<int> _u64(int v) => [..._u32(v & 0xFFFFFFFF), ..._u32(v >> 32)];

/// Ogg's CRC-32, bit by bit (independent of the table the tool uses).
int _crc(List<int> page) {
  var crc = 0;
  for (final byte in page) {
    crc ^= byte << 24;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x80000000) != 0 ? (crc << 1) ^ 0x04C11DB7 : crc << 1;
      crc &= 0xFFFFFFFF;
    }
  }
  return crc;
}

/// One Ogg page carrying [body] as a single packet.
List<int> _page(
  List<int> body, {
  required int sequence,
  int flags = 0,
  int granule = 0,
  int serial = 0x4E455354,
}) {
  // Ogg lacing: 255s, then the remainder (0 when the packet is a multiple
  // of 255).
  final table = [
    for (var left = body.length; left >= 255; left -= 255) 255,
    body.length % 255,
  ];
  final page = [
    ...'OggS'.codeUnits,
    0,
    flags,
    ..._u64(granule),
    ..._u32(serial),
    ..._u32(sequence),
    0, 0, 0, 0, // checksum
    table.length,
    ...table,
    ...body,
  ];
  final crc = _u32(_crc(page));
  return [...page.sublist(0, 22), ...crc, ...page.sublist(26)];
}

/// The Vorbis I identification header (30 bytes).
List<int> _vorbisId({int channels = 2, int rate = 44100}) => [
  1,
  ...'vorbis'.codeUnits,
  ..._u32(0), // vorbis_version
  channels,
  ..._u32(rate),
  ..._u32(0), ..._u32(128000), ..._u32(0), // bitrates
  0xB8, // blocksizes 256 / 2048
  1, // framing
];

/// A minimal stream: the identification header, then one audio page that
/// ends the stream at [frames].
List<int> _ogg({
  int channels = 2,
  int rate = 44100,
  int frames = 1000,
  int lastFlags = 0x04,
  int secondSerial = 0x4E455354,
  List<int>? firstPacket,
}) => [
  ..._page(
    firstPacket ?? _vorbisId(channels: channels, rate: rate),
    sequence: 0,
    flags: 0x02,
  ),
  ..._page(
    List.filled(300, 3),
    sequence: 1,
    flags: lastFlags,
    granule: frames,
    serial: secondSerial,
  ),
];

void main() {
  final audio = Directory(p.join(findRepoRoot().path, 'design', 'audio'));
  List<File> designFiles(String ext) =>
      audio
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith(ext))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  group('validateSfxWav (44.1 kHz mono 16-bit PCM)', () {
    test('every design/audio WAV passes, C2PA chunk and all', () {
      final wavs = designFiles('.wav');
      // 17 of v2, plus m7's star_1..3, chest_wiggle, chest_open and
      // rival_complete, and m7-5's gift_claim.
      expect(wavs, hasLength(24));
      for (final file in wavs) {
        expect(
          validateSfxWav(file.readAsBytesSync()),
          isEmpty,
          reason: file.path,
        );
      }
    });

    test('a minimal WAV passes, with extra and odd-sized chunks', () {
      expect(validateSfxWav(_wav()), isEmpty);
      expect(validateSfxWav(_wav(extra: [('C2PA', 5), ('LIST', 4)])), isEmpty);
    });

    test('names what is off the format', () {
      expect(validateSfxWav(_wav(channels: 2)), [
        contains('2 channels, expected 1'),
      ]);
      expect(validateSfxWav(_wav(rate: 48000)), [
        contains('48000 Hz, expected 44100'),
      ]);
      expect(validateSfxWav(_wav(bits: 24)), [contains('24-bit, expected 16')]);
      expect(validateSfxWav(_wav(format: 3, bits: 32)), [
        contains('expected 1 (PCM)'),
        contains('32-bit'),
      ]);
    });

    test('rejects broken files', () {
      expect(validateSfxWav('RIFF'.codeUnits), ['not a RIFF/WAVE file']);
      expect(validateSfxWav(_wav(dataChunk: false)), ['no data chunk']);
      expect(validateSfxWav(_wav(riffSizeDelta: 2)), [
        contains('the RIFF size says'),
      ]);
      final truncated = _wav(frames: 100);
      expect(
        validateSfxWav(truncated.sublist(0, truncated.length - 10)),
        contains(contains('runs past the end')),
      );
    });
  });

  group('readOggVorbis (44.1 kHz stereo Ogg Vorbis)', () {
    test('every design/audio OGG passes; the loops are their token length', () {
      final oggs = designFiles('.ogg');
      expect(oggs.map((f) => p.basename(f.path)), [
        'jingle_chapter.ogg',
        'jingle_oom.ogg',
        'jingle_reward.ogg',
        'jingle_versus_lose.ogg',
        'jingle_versus_win.ogg',
        'music_game.ogg',
        'music_home.ogg',
      ]);
      final frames = <String, int>{};
      for (final file in oggs) {
        final check = readOggVorbis(file.readAsBytesSync());
        expect(check.issues, isEmpty, reason: file.path);
        expect(check.info!.channels, 2);
        expect(check.info!.sampleRate, 44100);
        frames[p.basenameWithoutExtension(file.path)] = check.info!.lastGranule;
      }
      // AUDIO.md "Files": 2,940,000 and 3,024,000 frames.
      expect(frames['music_home'], 2940000);
      expect(frames['music_game'], 3024000);
    });

    test('a minimal stream passes', () {
      final check = readOggVorbis(_ogg(frames: 4410));
      expect(check.issues, isEmpty);
      expect(check.info!.pages, 2);
      expect(check.info!.lastGranule, 4410);
    });

    test('names what is off the format', () {
      expect(readOggVorbis(_ogg(channels: 1)).issues, [
        contains('1 channels, expected 2'),
      ]);
      expect(readOggVorbis(_ogg(rate: 48000)).issues, [
        contains('48000 Hz, expected 44100'),
      ]);
      expect(
        readOggVorbis(
          _ogg(firstPacket: [...'OpusHead'.codeUnits, ...List.filled(22, 0)]),
        ).issues,
        ['the first packet is not a Vorbis identification header'],
      );
    });

    test('rejects broken streams', () {
      expect(readOggVorbis('RIFF....WAVE'.codeUnits).issues, [
        'not an Ogg file (no OggS capture pattern)',
      ]);
      // A flipped byte in the audio page's body.
      final corrupt = _ogg()..[100] ^= 0xFF;
      expect(readOggVorbis(corrupt).issues, ['page 1 (byte 58): CRC mismatch']);
      expect(readOggVorbis(_ogg(lastFlags: 0)).issues, [
        'the last page does not end the stream',
      ]);
      expect(readOggVorbis(_ogg(secondSerial: 7)).issues, [
        contains('a second logical stream'),
      ]);
      expect(readOggVorbis([..._ogg(), 1, 2, 3]).issues, [
        contains('no OggS capture pattern'),
      ]);
      final cut = _ogg();
      expect(readOggVorbis(cut.sublist(0, cut.length - 5)).issues, [
        contains('runs past the end'),
      ]);
    });
  });
}
