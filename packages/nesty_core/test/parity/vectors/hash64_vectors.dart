// Reference vectors for Hash64 (lib/src/util/hash64.dart): spec §6.2,
// docs/plans/m1-core-design.md §1 and §5, PROGRESS Q9.
//
// Produced by an independent Python 3 implementation of MurmurHash3_x86_32
// over bytes, checked against a C transcription of smhasher's
// MurmurHash3.cpp and against the 20 published test vectors below. Hash64 is
// that hash run twice over the same little-endian byte stream: hi with seed
// 0x6A09E667 and lo with seed 0xBB67AE85 (the first two SHA-256 initial hash
// words). u16 input is two bytes per unit, u32 four bytes per word, and a
// String is its UTF-16 code units.
//
// JSON-shaped consts, so test/parity/ compares them unchanged on the VM, in
// dart2js (chrome, node) and in dart2wasm. Never edit a value to match the
// Dart output: if a definition changes on purpose, recompute every vector
// with an independent implementation (the one-off script is not kept).
library;

/// The 20 published MurmurHash3_x86_32 test vectors (bytes, seed, hash).
/// Hash64Builder with a custom lane seed must reproduce each one.
const murmur3Published = <Map<String, Object>>[
  {'bytes': <int>[], 'seed': 0x00000000, 'hash': 0x00000000},
  {'bytes': <int>[], 'seed': 0x00000001, 'hash': 0x514E28B7},
  {'bytes': <int>[], 'seed': 0xFFFFFFFF, 'hash': 0x81F16F39},
  {
    'bytes': [0x00, 0x00, 0x00, 0x00],
    'seed': 0x00000000,
    'hash': 0x2362F9DE,
  },
  {
    'bytes': [0x61, 0x61, 0x61, 0x61],
    'seed': 0x9747B28C,
    'hash': 0x5A97808A,
  },
  {
    'bytes': [0x61, 0x61, 0x61],
    'seed': 0x9747B28C,
    'hash': 0x283E0130,
  },
  {
    'bytes': [0x61, 0x61],
    'seed': 0x9747B28C,
    'hash': 0x5D211726,
  },
  {
    'bytes': [0x61],
    'seed': 0x9747B28C,
    'hash': 0x7FA09EA6,
  },
  {
    'bytes': [0x61, 0x62, 0x63, 0x64],
    'seed': 0x9747B28C,
    'hash': 0xF0478627,
  },
  {
    'bytes': [0x61, 0x62, 0x63],
    'seed': 0x9747B28C,
    'hash': 0xC84A62DD,
  },
  {
    'bytes': [0x61, 0x62],
    'seed': 0x9747B28C,
    'hash': 0x74875592,
  },
  {
    'bytes': [
      0x48,
      0x65,
      0x6C,
      0x6C,
      0x6F,
      0x2C,
      0x20,
      0x77,
      0x6F,
      0x72,
      0x6C,
      0x64,
      0x21,
    ],
    'seed': 0x9747B28C,
    'hash': 0x24884CBA,
  },
  {
    'bytes': [
      0x54,
      0x68,
      0x65,
      0x20,
      0x71,
      0x75,
      0x69,
      0x63,
      0x6B,
      0x20,
      0x62,
      0x72,
      0x6F,
      0x77,
      0x6E,
      0x20,
      0x66,
      0x6F,
      0x78,
      0x20,
      0x6A,
      0x75,
      0x6D,
      0x70,
      0x73,
      0x20,
      0x6F,
      0x76,
      0x65,
      0x72,
      0x20,
      0x74,
      0x68,
      0x65,
      0x20,
      0x6C,
      0x61,
      0x7A,
      0x79,
      0x20,
      0x64,
      0x6F,
      0x67,
    ],
    'seed': 0x9747B28C,
    'hash': 0x2FA826CD,
  },
  {
    'bytes': [0x68, 0x65, 0x6C, 0x6C, 0x6F],
    'seed': 0x00000000,
    'hash': 0x248BFA47,
  },
  {
    'bytes': [0xFF, 0xFF, 0xFF, 0xFF],
    'seed': 0x00000000,
    'hash': 0x76293B50,
  },
  {
    'bytes': [0x21, 0x43, 0x65, 0x87],
    'seed': 0x00000000,
    'hash': 0xF55B516B,
  },
  {
    'bytes': [0x21, 0x43, 0x65, 0x87],
    'seed': 0x5082EDEE,
    'hash': 0x2362F9DE,
  },
  {
    'bytes': [0x21, 0x43, 0x65],
    'seed': 0x00000000,
    'hash': 0x7E4A8634,
  },
  {
    'bytes': [0x21, 0x43],
    'seed': 0x00000000,
    'hash': 0xA0F7B07A,
  },
  {
    'bytes': [0x21],
    'seed': 0x00000000,
    'hash': 0x72661CF4,
  },
];

/// Hash64 goldens. `kind` names the Hash64 factory: u32 = ofU32s,
/// u16 = ofU16s, bytes = ofBytes. `hex` is `Hash64.toHex()`.
const hash64Goldens = <Map<String, Object>>[
  {'kind': 'u32', 'input': <int>[], 'hex': '09f45f69adcf6676'},
  {
    'kind': 'u32',
    'input': [0x00000000],
    'hex': '16ffa8f804ce6665',
  },
  {
    'kind': 'u32',
    'input': [0x00000001],
    'hex': '421d288274feb110',
  },
  {
    'kind': 'u32',
    'input': [0xFFFFFFFF],
    'hex': '77b132fb1ab94a5b',
  },
  {
    'kind': 'u32',
    'input': [0x00000001, 0x00000002, 0x00000003, 0x00000004],
    'hex': 'f23ab3c984416353',
  },
  {
    'kind': 'u32',
    'input': [0xDEADBEEF, 0xCAFEBABE, 0x8BADF00D],
    'hex': 'a1cfd68ce3c1c136',
  },
  {
    'kind': 'u32',
    'input': [
      0x00000001,
      0x00000002,
      0x00000003,
      0x00000004,
      0x00000005,
      0x00000006,
      0x00000007,
      0x00000008,
      0x00000009,
      0x0000000A,
      0x0000000B,
      0x0000000C,
      0x0000000D,
      0x0000000E,
      0x0000000F,
      0x00000010,
      0x00000011,
      0x00000012,
      0x00000013,
      0x00000014,
      0x00000015,
      0x00000016,
      0x00000017,
      0x00000018,
      0x00000019,
      0x0000001A,
      0x0000001B,
      0x0000001C,
      0x0000001D,
      0x0000001E,
      0x0000001F,
      0x00000020,
    ],
    'hex': '1d7a2ee7ec6a5c9c',
  },
  {'kind': 'u16', 'input': <int>[], 'hex': '09f45f69adcf6676'},
  {
    'kind': 'u16',
    'input': [0x0041],
    'hex': 'c36f5c44cf338735',
  },
  {
    'kind': 'u16',
    'input': [0x0041, 0x0042],
    'hex': 'd1d3cf7eb450c3b2',
  },
  {
    'kind': 'u16',
    'input': [0x0041, 0x0042, 0x0043],
    'hex': '0faf847198a27180',
  },
  {
    'kind': 'u16',
    'input': [0xFFFF],
    'hex': 'bc7287ad06926d22',
  },
  {
    'kind': 'u16',
    'input': [0x0000, 0xFFFF, 0x0001],
    'hex': '143037590c3ae4b6',
  },
  {
    'kind': 'u16',
    'input': [0x0009, 0x0011, 0x03FF, 0x0000, 0x020A],
    'hex': '9a778ce12eb520c2',
  },
  {'kind': 'bytes', 'input': <int>[], 'hex': '09f45f69adcf6676'},
  {
    'kind': 'bytes',
    'input': [0x61],
    'hex': 'b712665ad4c88fa4',
  },
  {
    'kind': 'bytes',
    'input': [0x61, 0x62],
    'hex': '6657b2c6ba0162a4',
  },
  {
    'kind': 'bytes',
    'input': [0x61, 0x62, 0x63],
    'hex': '74a23a721dd98daa',
  },
  {
    'kind': 'bytes',
    'input': [0x61, 0x62, 0x63, 0x64, 0x65],
    'hex': 'd23a9deb5ffe7af4',
  },
];

/// `Hash64.ofString` goldens: strings hash as their UTF-16 code units
/// (little-endian bytes), so a surrogate pair is two units and a lone
/// surrogate is hashed as is.
const hash64StringGoldens = <Map<String, Object>>[
  {'input': '', 'hex': '09f45f69adcf6676'},
  {'input': 'a', 'hex': '14854a617efdf395'},
  {'input': 'ab', 'hex': '225cffe2385eeece'},
  {'input': 'abc', 'hex': 'fe4dadd642488f76'},
  {'input': 'nesty', 'hex': 'bc17dfb16f200e26'},
  {
    'input': '{"schemaVersion":1,"id":"L0001","maxSize":3}',
    'hex': '8be538f1ff4ab9e3',
  },
  {
    'input': 'Matryoshka \u{1FA86} d\u00E9j\u00E0 vu \u2013 ok',
    'hex': '3b60f84a370ce06b',
  },
  {'input': '\uD800 lone surrogate', 'hex': '5ccacefc56ab2c4e'},
];

/// One Hash64Builder fed u8, u16 and u32 values in this order. It visits
/// every (width, pending-bytes) pair, so each carry path of the byte
/// stream is pinned. `bytes` is the concatenated little-endian stream.
const hash64MixedStream = <String, Object>{
  'ops': [
    ['u8', 0x01],
    ['u8', 0x02],
    ['u8', 0x03],
    ['u8', 0x04],
    ['u16', 0x0605],
    ['u16', 0x0807],
    ['u8', 0x09],
    ['u16', 0x0B0A],
    ['u16', 0x0D0C],
    ['u32', 0x11100F0E],
    ['u8', 0x12],
    ['u32', 0x16151413],
    ['u8', 0x17],
    ['u32', 0x1B1A1918],
    ['u16', 0x1D1C],
    ['u16', 0x1F1E],
    ['u8', 0x20],
    ['u32', 0xFFFEFDFC],
    ['u8', 0xAB],
  ],
  'bytes': [
    0x01,
    0x02,
    0x03,
    0x04,
    0x05,
    0x06,
    0x07,
    0x08,
    0x09,
    0x0A,
    0x0B,
    0x0C,
    0x0D,
    0x0E,
    0x0F,
    0x10,
    0x11,
    0x12,
    0x13,
    0x14,
    0x15,
    0x16,
    0x17,
    0x18,
    0x19,
    0x1A,
    0x1B,
    0x1C,
    0x1D,
    0x1E,
    0x1F,
    0x20,
    0xFC,
    0xFD,
    0xFE,
    0xFF,
    0xAB,
  ],
  'hex': '9ffcec0f2280d1b1',
};

/// Hash64 of the 1,000 u32 words `i * 0x9E3779B9 mod 2^32`, i = 0..999.
const hash64LargeU32 = 'ebdd172de068cb10';
