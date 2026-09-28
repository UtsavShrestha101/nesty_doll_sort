// Golden fingerprints of the levels a device generates (docs/plans/
// m3-design.md §5; spec §7.1 Bonus Endless, §7.5 daily puzzle; M3
// acceptance "The daily puzzle is identical across two devices on the same
// date").
//
// Each is `generatedFingerprint` (../generated_levels.dart) of
// `Generator.generateWithRetries` with `DifficultyCurve.dailyParams` for 28
// consecutive dates, 2026-09-21 (a Monday) to 2026-10-18, and
// `DifficultyCurve.bonusParams` for the global play orders 1–20 and 31–50,
// keyed by level id.
//
// Unlike the other vectors here these are regression pins, not values from
// an independent implementation: Generator.version 1's own output, captured
// on the VM on 2026-09-27 and then required on every platform. What makes
// them trustworthy is elsewhere: the 11 that overlap the M1 goldens
// (test/generator/golden_test.dart: dailies 2026-09-26 and 09-28, bonus 1,
// 2, 6, 10, 16, 20, 31, 36, 40) agree with them, every level passes the
// admin validation and replays its solution to a win
// (test/generator/daily_golden_test.dart), and the parity suite runs the
// same table on node, chrome and wasm.
//
// When one fails:
// - after an unintended change, fix the change;
// - after an intended change to what the pipeline produces, bump
//   `Generator.version`, keep a frozen v1 path for dailies (spec §7.5 pins
//   the generator version per date), and only then paste new values, once
//   every platform agrees.
library;

/// The 28 dates, in order: 2026-09-21 … 2026-10-18.
const dailyGoldenDates = <int>[
  20260921, 20260922, 20260923, 20260924, 20260925, 20260926, 20260927, //
  20260928, 20260929, 20260930, 20261001, 20261002, 20261003, 20261004, //
  20261005, 20261006, 20261007, 20261008, 20261009, 20261010, 20261011, //
  20261012, 20261013, 20261014, 20261015, 20261016, 20261017, 20261018, //
];

/// The bonus play orders: 1–20 and 31–50.
const bonusGoldenOrders = <int>[
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, //
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, //
  49, 50, //
];

/// `daily-<yyyymmdd>` → fingerprint, in [dailyGoldenDates] order.
const dailyGoldens = <String, Map<String, Object>>{
  'daily-20260921': {
    'digest': '7e9ca30edb1fa94f',
    'seed': 20260921,
    'attempt': 4,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260922': {
    'digest': '134295f504e7d20e',
    'seed': 20260922,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260923': {
    'digest': 'aab2585f9c2ba1fc',
    'seed': 20260923,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260924': {
    'digest': '48a69d05c632085c',
    'seed': 20260924,
    'attempt': 2,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260925': {
    'digest': 'ab9e71b6d34667dc',
    'seed': 20260925,
    'attempt': 5,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260926': {
    'digest': '7716bec2334e7d9a',
    'seed': 20260926,
    'attempt': 0,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20260927': {
    'digest': 'a8b698ef92cc1c6d',
    'seed': 20260927,
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20260928': {
    'digest': 'ba7076deff1ebeb8',
    'seed': 20260928,
    'attempt': 3,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260929': {
    'digest': 'f939945240c29d4e',
    'seed': 20260929,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20260930': {
    'digest': '2b50d5bd0aa48e77',
    'seed': 20260930,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261001': {
    'digest': '70347bcf8ebb7cc7',
    'seed': 20261001,
    'attempt': 16,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261002': {
    'digest': 'ad690e97612b3439',
    'seed': 20261002,
    'attempt': 2,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261003': {
    'digest': '688c347a5fcc21fd',
    'seed': 20261003,
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20261004': {
    'digest': '143e48e5f51ebef0',
    'seed': 20261004,
    'attempt': 1,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20261005': {
    'digest': 'dfb49c03ad53a533',
    'seed': 20261005,
    'attempt': 5,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261006': {
    'digest': '02ab8def645b480f',
    'seed': 20261006,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261007': {
    'digest': '1319ea7f78026a88',
    'seed': 20261007,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261008': {
    'digest': 'e451c9b8809bab01',
    'seed': 20261008,
    'attempt': 11,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261009': {
    'digest': 'fecf6c0006df3ed1',
    'seed': 20261009,
    'attempt': 6,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261010': {
    'digest': 'd1bb2265467abba1',
    'seed': 20261010,
    'attempt': 3,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20261011': {
    'digest': 'a40e1b3e1e3ec4c5',
    'seed': 20261011,
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20261012': {
    'digest': 'b8faf935fe70517b',
    'seed': 20261012,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261013': {
    'digest': 'fcb3094162aadeaa',
    'seed': 20261013,
    'attempt': 1,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261014': {
    'digest': '63838f85df5455ce',
    'seed': 20261014,
    'attempt': 6,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261015': {
    'digest': 'c3243a5c322044bd',
    'seed': 20261015,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261016': {
    'digest': 'd466c0bbbe48c871',
    'seed': 20261016,
    'attempt': 3,
    'tier': 'medium',
    'tierMatched': true,
  },
  'daily-20261017': {
    'digest': '8fe6d10fc5888550',
    'seed': 20261017,
    'attempt': 1,
    'tier': 'hard',
    'tierMatched': true,
  },
  'daily-20261018': {
    'digest': 'bd5c322eeeae6534',
    'seed': 20261018,
    'attempt': 6,
    'tier': 'hard',
    'tierMatched': true,
  },
};

/// `bonus-<order>` → fingerprint, in [bonusGoldenOrders] order.
const bonusGoldens = <String, Map<String, Object>>{
  'bonus-1': {
    'digest': '9dc65834299d0a5c',
    'seed': 1000001,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-2': {
    'digest': 'bda46e270c71f497',
    'seed': 1000002,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-3': {
    'digest': '5bfb3e726ef5e525',
    'seed': 1000003,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-4': {
    'digest': 'f22734fc5705eaa9',
    'seed': 1000004,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-5': {
    'digest': '8fa8c0836129d0d3',
    'seed': 1000005,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-6': {
    'digest': 'dffb7a0dfbfe1b26',
    'seed': 1000006,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-7': {
    'digest': '1c82868deeaa1cf4',
    'seed': 1000007,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-8': {
    'digest': '06a20ac0d3bceb96',
    'seed': 1000008,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-9': {
    'digest': 'dff84ffe7c0d3baf',
    'seed': 1000009,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-10': {
    'digest': 'af533bee7555ca05',
    'seed': 1000010,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-11': {
    'digest': '3dc257f6c5f2b3fa',
    'seed': 1000011,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-12': {
    'digest': 'cc6b6c2c87ac1125',
    'seed': 1000012,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-13': {
    'digest': '6ee9c7c4b3e8be6b',
    'seed': 1000013,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-14': {
    'digest': 'f8f85321ad05dcd3',
    'seed': 1000014,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-15': {
    'digest': 'cb465c75f693c920',
    'seed': 1000015,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
  },
  'bonus-16': {
    'digest': '71b6ff9c23271f9e',
    'seed': 1000016,
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
  },
  'bonus-17': {
    'digest': '59de93881597d087',
    'seed': 1000017,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-18': {
    'digest': '311ef6ae003619a8',
    'seed': 1000018,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-19': {
    'digest': 'f31bcb1359e992b2',
    'seed': 1000019,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-20': {
    'digest': '18709c29ccb00fe1',
    'seed': 1000020,
    'attempt': 5,
    'tier': 'superhard',
    'tierMatched': true,
  },
  'bonus-31': {
    'digest': '11c300906d48b87c',
    'seed': 1000031,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-32': {
    'digest': 'cc31858aa16c1623',
    'seed': 1000032,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-33': {
    'digest': '9f2cc6d10ac54812',
    'seed': 1000033,
    'attempt': 6,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-34': {
    'digest': '2092c8ace044a65b',
    'seed': 1000034,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-35': {
    'digest': 'b223f86d4889aa83',
    'seed': 1000035,
    'attempt': 10,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-36': {
    'digest': 'e0fe97357c357a40',
    'seed': 1000036,
    'attempt': 6,
    'tier': 'hard',
    'tierMatched': true,
  },
  'bonus-37': {
    'digest': '232201b5c43911a0',
    'seed': 1000037,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-38': {
    'digest': '827dc5f15a8b084b',
    'seed': 1000038,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-39': {
    'digest': '0ce2e7b89ef61366',
    'seed': 1000039,
    'attempt': 4,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-40': {
    'digest': 'd952bd515fba05ff',
    'seed': 1000040,
    'attempt': 0,
    'tier': 'superhard',
    'tierMatched': true,
  },
  'bonus-41': {
    'digest': '9f3ef659739b4118',
    'seed': 1000041,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-42': {
    'digest': '3343f12a5cf3ce5b',
    'seed': 1000042,
    'attempt': 1,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-43': {
    'digest': 'cff81226f4664558',
    'seed': 1000043,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-44': {
    'digest': '51fb6c7477919b4f',
    'seed': 1000044,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-45': {
    'digest': '6e8c35b10fea7fa4',
    'seed': 1000045,
    'attempt': 0,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-46': {
    'digest': '6a3f86d556843169',
    'seed': 1000046,
    'attempt': 2,
    'tier': 'hard',
    'tierMatched': true,
  },
  'bonus-47': {
    'digest': 'b7bd982f356e3276',
    'seed': 1000047,
    'attempt': 8,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-48': {
    'digest': '1ff92352a8193f84',
    'seed': 1000048,
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
  },
  'bonus-49': {
    'digest': '710fd101c092b28a',
    'seed': 1000049,
    'attempt': 7,
    'tier': 'medium',
    'tierMatched': true,
  },
  'bonus-50': {
    'digest': '8f2cbdbbbe425bef',
    'seed': 1000050,
    'attempt': 1,
    'tier': 'superhard',
    'tierMatched': true,
  },
};

/// `Generator.retrySeed(seed, r)` for r = 0..`Generator.maxRetries`
/// (m3-design §5: `Prng.derive(seed, 'RETR', r)`), keyed by seed: a date,
/// a bonus seed, 0 and `Prng.maxSeed`. Captured on the VM by the contracts
/// stage (generator_retry_test.dart) and required on every platform.
const retrySeedVectors = <int, List<int>>{
  20260926: [20260926, 1857866035, 862400723, 2188958778],
  1000031: [1000031, 2859693856, 2868834049, 819220729],
  0: [0, 1975986187, 643456767, 501517508],
  9007199254740991: [9007199254740991, 3843186773, 1414416639, 3915279618],
};
