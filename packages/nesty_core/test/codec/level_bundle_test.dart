// LevelBundleCodec: the bundled levels file of spec §13.4 in the format of
// design §4. Deterministic text (2-space indent, fixed key order, entries by
// order), a strict decoder that skips invalid entries with issues, unique
// ids and continuous orders.
//
// Platform-neutral on purpose (inline JSON, no dart:io): the game decodes
// the bundle on the VM and the admin (M5) encodes it in the browser, so this
// suite also runs with `-p node` and `-p chrome`.
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart';

/// A small valid level with id [id].
Level tinyLevel(String id) => Level(
  id: id,
  maxSize: 3,
  shelves: [
    [OpenSlot(nest: nest(DollColor.red, 3)), OpenSlot()],
    [OpenSlot(nest: nest(DollColor.red, 2, 2)), OpenSlot()],
  ],
);

LevelBundleEntry entry(
  int order, {
  String? id,
  Tier tier = Tier.easy,
  String chapterId = 'ch01',
  int version = 1,
  Level? level,
}) => LevelBundleEntry(
  order: order,
  chapterId: chapterId,
  tier: tier,
  version: version,
  rewardCoins: tier.defaultRewardCoins,
  level: level ?? tinyLevel(id ?? 'L${order.toString().padLeft(4, '0')}'),
);

/// The JSON of one valid entry, fresh and mutable, parsed like real input.
Map<String, Object?> entryJson(int order, {String? id}) =>
    jsonDecode(
          jsonEncode(
            (LevelBundleCodec.encode(
                      LevelBundle(
                        levelsVersion: 0,
                        levels: [entry(order, id: id)],
                      ),
                    )['levels']!
                    as List)
                .single,
          ),
        )
        as Map<String, Object?>;

/// A bundle document with [entries], fresh and mutable.
Map<String, Object?> bundleJson(List<Object?> entries) => {
  'format': 'nesty.levels',
  'bundleVersion': 1,
  'levelsVersion': 0,
  'levels': entries,
};

List<String> codes(LevelBundleDecodeResult result) => [
  for (final issue in result.issues) issue.code,
];

List<String> ids(LevelBundleDecodeResult result) => [
  for (final e in result.bundle!.levels) e.level.id,
];

/// The canonical text of a one-entry bundle, byte for byte (design §4).
const String oneEntryText = '''
{
  "format": "nesty.levels",
  "bundleVersion": 1,
  "levelsVersion": 3,
  "levels": [
    {
      "order": 1,
      "chapterId": "ch01",
      "tier": "hard",
      "version": 2,
      "rewardCoins": 25,
      "data": {
        "schemaVersion": 1,
        "id": "L0001",
        "maxSize": 3,
        "shelves": [
          [
            {
              "type": "open",
              "nest": [
                "red3"
              ]
            },
            {
              "type": "open",
              "nest": null
            }
          ],
          [
            {
              "type": "open",
              "nest": [
                "red2",
                "red1"
              ]
            },
            {
              "type": "open",
              "nest": null
            }
          ]
        ]
      }
    }
  ]
}
''';

void main() {
  group('LevelBundle', () {
    test('sorts its entries by order, stably', () {
      final a = entry(2, id: 'A');
      final b = entry(1, id: 'B');
      final c = entry(2, id: 'C');
      final bundle = LevelBundle(levelsVersion: 0, levels: [a, b, c]);
      expect(bundle.levels, [b, a, c]);
      expect(
        LevelBundle(levelsVersion: 0, levels: [c, b, a]).levels,
        [b, c, a],
        reason: 'equal orders keep the given order',
      );
    });

    test('copies the list it is given', () {
      final list = [entry(1)];
      final bundle = LevelBundle(levelsVersion: 0, levels: list);
      list.add(entry(2));
      expect(bundle.levels, hasLength(1));
    });
  });

  group('encode', () {
    test('writes the fixed key order of design §4', () {
      final json = LevelBundleCodec.encode(
        LevelBundle(levelsVersion: 7, levels: [entry(1)]),
      );
      expect(json.keys, ['format', 'bundleVersion', 'levelsVersion', 'levels']);
      expect(json['format'], LevelBundle.format);
      expect(json['bundleVersion'], LevelBundle.currentBundleVersion);
      expect(json['levelsVersion'], 7);
      final first = (json['levels']! as List).single as Map<String, Object?>;
      expect(first.keys, [
        'order',
        'chapterId',
        'tier',
        'version',
        'rewardCoins',
        'data',
      ]);
    });

    test('data is the level codec\'s canonical form', () {
      final level = specExampleLevel();
      final json = LevelBundleCodec.encode(
        LevelBundle(levelsVersion: 0, levels: [entry(1, level: level)]),
      );
      final first = (json['levels']! as List).single as Map<String, Object?>;
      expect(jsonEncode(first['data']), LevelCodec.encodeString(level));
    });

    test('writes tier ids, not Dart names', () {
      final json = LevelBundleCodec.encode(
        LevelBundle(levelsVersion: 0, levels: [entry(1, tier: Tier.superhard)]),
      );
      final first = (json['levels']! as List).single as Map<String, Object?>;
      expect(first['tier'], 'superhard');
      expect(first['rewardCoins'], 50);
    });

    test('encodeString is the exact file text: 2-space indent and a '
        'trailing newline', () {
      final bundle = LevelBundle(
        levelsVersion: 3,
        levels: [
          LevelBundleEntry(
            order: 1,
            chapterId: 'ch01',
            tier: Tier.hard,
            version: 2,
            rewardCoins: 25,
            level: tinyLevel('L0001'),
          ),
        ],
      );
      expect(LevelBundleCodec.encodeString(bundle), oneEntryText);
    });

    test('an empty bundle is valid text', () {
      expect(
        LevelBundleCodec.encodeString(
          LevelBundle(levelsVersion: 0, levels: []),
        ),
        '{\n'
        '  "format": "nesty.levels",\n'
        '  "bundleVersion": 1,\n'
        '  "levelsVersion": 0,\n'
        '  "levels": []\n'
        '}\n',
      );
    });

    test('the same entries in any order give the same text', () {
      final entries = [entry(1), entry(2), entry(3)];
      final text = LevelBundleCodec.encodeString(
        LevelBundle(levelsVersion: 0, levels: entries),
      );
      expect(
        LevelBundleCodec.encodeString(
          LevelBundle(levelsVersion: 0, levels: entries.reversed.toList()),
        ),
        text,
      );
      final orders = [
        for (final e
            in LevelBundleCodec.encode(
                  LevelBundle(
                    levelsVersion: 0,
                    levels: entries.reversed.toList(),
                  ),
                )['levels']!
                as List)
          (e as Map)['order'],
      ];
      expect(orders, [1, 2, 3]);
    });
  });

  group('round trip', () {
    test('decode(encode(b)) == b with no issues', () {
      final bundle = LevelBundle(
        levelsVersion: 12,
        levels: [
          entry(1),
          entry(2, tier: Tier.medium, chapterId: 'ch01', version: 4),
          entry(3, tier: Tier.superhard, level: specExampleLevel()),
        ],
      );
      final decoded = LevelBundleCodec.decode(LevelBundleCodec.encode(bundle));
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle, bundle);
    });

    test('decodeString(encodeString(b)) == b and re-encodes byte for byte', () {
      final bundle = LevelBundle(
        levelsVersion: 0,
        levels: [
          entry(1),
          entry(2, level: specExampleLevel()),
        ],
      );
      final text = LevelBundleCodec.encodeString(bundle);
      final decoded = LevelBundleCodec.decodeString(text);
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle, bundle);
      expect(LevelBundleCodec.encodeString(decoded.bundle!), text);
    });

    test('the golden text decodes', () {
      final decoded = LevelBundleCodec.decodeString(oneEntryText);
      expect(decoded.issues, isEmpty);
      final only = decoded.bundle!.levels.single;
      expect(decoded.bundle!.levelsVersion, 3);
      expect(only.order, 1);
      expect(only.chapterId, 'ch01');
      expect(only.tier, Tier.hard);
      expect(only.version, 2);
      expect(only.rewardCoins, 25);
      expect(only.level, tinyLevel('L0001'));
    });

    test('an unsorted file decodes sorted by order', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(3), entryJson(1), entryJson(2)]),
      );
      expect(decoded.issues, isEmpty);
      expect(ids(decoded), ['L0001', 'L0002', 'L0003']);
    });

    test('integers are read by value: 1.0 is 1 (web and VM agree)', () {
      final first = entryJson(1)
        ..['order'] = 1.0
        ..['version'] = 2.0;
      final json = bundleJson([first])
        ..['bundleVersion'] = 1.0
        ..['levelsVersion'] = 5.0;
      final decoded = LevelBundleCodec.decode(json);
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle!.levelsVersion, 5);
      expect(decoded.bundle!.levels.single.version, 2);
    });

    test('an empty levels list is a valid, empty bundle', () {
      final decoded = LevelBundleCodec.decode(bundleJson([]));
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle!.levels, isEmpty);
    });
  });

  group('an unusable file gives no bundle', () {
    test('invalid JSON', () {
      final decoded = LevelBundleCodec.decodeString('{"format": ');
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.invalidJson]);
      expect(decoded.issues.single.args, isEmpty);
    });

    test('not an object', () {
      final decoded = LevelBundleCodec.decode([1, 2]);
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.wrongType]);
      expect(decoded.issues.single.args, {
        'field': 'bundle',
        'expected': 'object',
      });
      expect(decoded.issues.single.path, '');
    });

    test('missing format', () {
      final decoded = LevelBundleCodec.decode(bundleJson([])..remove('format'));
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.missingField]);
      expect(decoded.issues.single.args, {'field': 'format'});
    });

    test('a format that is not a string', () {
      final decoded = LevelBundleCodec.decode(bundleJson([])..['format'] = 1);
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.wrongType]);
      expect(decoded.issues.single.path, '/format');
    });

    test('another format stops the decode', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([42])
          ..['format'] = 'nesty.levels.manifest'
          ..['extra'] = true,
      );
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.bundleBadFormat]);
      expect(decoded.issues.single.args, {'format': 'nesty.levels.manifest'});
      expect(decoded.issues.single.path, '/format');
    });

    test('an unsupported bundleVersion stops the decode', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([42])..['bundleVersion'] = 2,
      );
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [IssueCodes.bundleUnsupportedVersion]);
      expect(decoded.issues.single.args, {'version': 2, 'supported': 1});
    });

    test('a missing or fractional bundleVersion', () {
      expect(
        codes(LevelBundleCodec.decode(bundleJson([])..remove('bundleVersion'))),
        [IssueCodes.missingField],
      );
      final fractional = LevelBundleCodec.decode(
        bundleJson([])..['bundleVersion'] = 1.5,
      );
      expect(fractional.bundle, isNull);
      expect(codes(fractional), [IssueCodes.wrongType]);
      expect(fractional.issues.single.args, {
        'field': 'bundleVersion',
        'expected': 'integer',
      });
    });

    test('a bad levelsVersion, but the entries are still checked', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1)..['tier'] = 'nope'])..['levelsVersion'] = -1,
      );
      expect(decoded.bundle, isNull);
      expect(codes(decoded), [
        IssueCodes.valueOutOfRange,
        IssueCodes.bundleUnknownTier,
      ]);
      expect(decoded.issues.first.args, {
        'field': 'levelsVersion',
        'value': -1,
        'min': 0,
        'max': 0x1FFFFFFFFFFFFF,
      });
      expect(
        codes(LevelBundleCodec.decode(bundleJson([])..remove('levelsVersion'))),
        [IssueCodes.missingField],
      );
      expect(
        codes(LevelBundleCodec.decode(bundleJson([])..['levelsVersion'] = '0')),
        [IssueCodes.wrongType],
      );
    });

    test('levels missing or not an array', () {
      final missing = LevelBundleCodec.decode(bundleJson([])..remove('levels'));
      expect(missing.bundle, isNull);
      expect(codes(missing), [IssueCodes.missingField]);
      expect(missing.issues.single.args, {'field': 'levels'});
      final object = LevelBundleCodec.decode(bundleJson([])..['levels'] = {});
      expect(object.bundle, isNull);
      expect(codes(object), [IssueCodes.wrongType]);
      expect(object.issues.single.path, '/levels');
    });
  });

  group('the file is strict but still loads', () {
    test('an unknown top-level key is an error; the bundle loads', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1)])..['exportedAt'] = 'today',
      );
      expect(codes(decoded), [IssueCodes.unknownField]);
      expect(decoded.issues.single.path, '/exportedAt');
      expect(decoded.issues.single.isError, isTrue);
      expect(ids(decoded), ['L0001']);
    });
  });

  group('invalid entries are skipped with issues', () {
    LevelBundleDecodeResult withSecond(Map<String, Object?> second) =>
        LevelBundleCodec.decode(
          bundleJson([entryJson(1), second, entryJson(3)]),
        );

    test('an entry that is not an object', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1), 'L0002']),
      );
      expect(codes(decoded), [IssueCodes.wrongType]);
      expect(decoded.issues.single.path, '/levels/1');
      expect(decoded.issues.single.args, {
        'field': 'entry',
        'expected': 'object',
      });
      expect(ids(decoded), ['L0001']);
    });

    for (final field in [
      'order',
      'chapterId',
      'tier',
      'version',
      'rewardCoins',
      'data',
    ]) {
      test('missing $field', () {
        final decoded = withSecond(entryJson(2)..remove(field));
        expect(
          codes(decoded),
          field == 'order'
              // The skipped entry's order is unknown, so 3 follows 1.
              ? [IssueCodes.missingField, IssueCodes.bundleOrderGap]
              : [IssueCodes.missingField],
        );
        expect(decoded.issues.first.path, '/levels/1');
        expect(decoded.issues.first.args, {'field': field});
        expect(ids(decoded), ['L0001', 'L0003']);
      });
    }

    test('an unknown entry key', () {
      final decoded = withSecond(entryJson(2)..['status'] = 'published');
      expect(codes(decoded), [IssueCodes.unknownField]);
      expect(decoded.issues.single.path, '/levels/1/status');
      expect(decoded.issues.single.args, {'field': 'status'});
      expect(ids(decoded), ['L0001', 'L0003']);
    });

    test('wrong types', () {
      final decoded = withSecond(
        entryJson(2)
          ..['chapterId'] = 1
          ..['tier'] = null
          ..['version'] = '1'
          ..['rewardCoins'] = 2.5,
      );
      expect(decoded.issues.map((i) => i.path), [
        '/levels/1/chapterId',
        '/levels/1/tier',
        '/levels/1/version',
        '/levels/1/rewardCoins',
      ]);
      expect(codes(decoded), everyElement(IssueCodes.wrongType));
      expect(decoded.issues.map((i) => i.args['expected']), [
        'string',
        'string',
        'integer',
        'integer',
      ]);
      expect(ids(decoded), ['L0001', 'L0003']);
    });

    test('values out of range', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([
          entryJson(1)..['order'] = 0,
          entryJson(1)..['version'] = 0,
          entryJson(2)..['rewardCoins'] = -5,
        ]),
      );
      expect(codes(decoded), [
        IssueCodes.valueOutOfRange,
        IssueCodes.valueOutOfRange,
        IssueCodes.valueOutOfRange,
      ]);
      expect(decoded.issues.map((i) => i.args['field']), [
        'order',
        'version',
        'rewardCoins',
      ]);
      expect(decoded.issues.map((i) => i.args['min']), [1, 1, 0]);
      expect(decoded.bundle!.levels, isEmpty);
    });

    test('an unknown tier, compared exactly', () {
      final decoded = withSecond(entryJson(2)..['tier'] = 'Easy');
      expect(codes(decoded), [IssueCodes.bundleUnknownTier]);
      expect(decoded.issues.single.args, {'tier': 'Easy'});
      expect(decoded.issues.single.path, '/levels/1/tier');
    });

    test('level issues are re-rooted under the entry\'s data', () {
      final second = entryJson(2);
      final data = second['data']! as Map<String, Object?>;
      ((data['shelves']! as List)[0] as List)[0] = {
        'type': 'open',
        'nest': ['Red3'],
      };
      final decoded = withSecond(second);
      expect(codes(decoded), [IssueCodes.badDollToken]);
      final issue = decoded.issues.single;
      expect(issue.path, '/levels/1/data/shelves/0/0/nest/0');
      expect(issue.slotId, 'r0c0');
      expect(issue.args, {'token': 'Red3'});
      expect(ids(decoded), ['L0001', 'L0003']);
    });

    test('a data value that is not a level', () {
      final decoded = withSecond(entryJson(2)..['data'] = []);
      expect(codes(decoded), [IssueCodes.wrongType]);
      expect(decoded.issues.single.path, '/levels/1/data');
      expect(decoded.issues.single.args, {
        'field': 'level',
        'expected': 'object',
      });
    });

    test('a level of another schema version is skipped', () {
      final second = entryJson(2);
      (second['data']! as Map<String, Object?>)['schemaVersion'] = 2;
      final decoded = withSecond(second);
      expect(codes(decoded), [IssueCodes.unsupportedVersion]);
      expect(decoded.issues.single.path, '/levels/1/data/schemaVersion');
    });

    test('several broken entries report everything, in file order', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([
          entryJson(1)..['tier'] = 'x',
          entryJson(2)..remove('version'),
          entryJson(3),
        ]),
      );
      expect(codes(decoded), [
        IssueCodes.bundleUnknownTier,
        IssueCodes.missingField,
      ]);
      expect(ids(decoded), ['L0003']);
    });

    test('the decoder does not validate the level (the loader does)', () {
      // Rule 4 is broken (red has no size 1), which the codec can represent.
      final second = entryJson(2);
      ((((second['data']! as Map)['shelves']! as List)[1] as List)[0]
          as Map)['nest'] = [
        'red2',
      ];
      final decoded = withSecond(second);
      expect(decoded.issues, isEmpty);
      expect(ids(decoded), ['L0001', 'L0002', 'L0003']);
    });
  });

  group('unique ids and orders', () {
    test('a reused order skips the later entry', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1), entryJson(2), entryJson(2, id: 'Other')]),
      );
      expect(codes(decoded), [IssueCodes.bundleDuplicateOrder]);
      expect(decoded.issues.single.path, '/levels/2/order');
      expect(decoded.issues.single.args, {'order': 2});
      expect(ids(decoded), ['L0001', 'L0002']);
    });

    test('a reused id skips the later entry, naming the kept order', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1), entryJson(2), entryJson(3, id: 'L0001')]),
      );
      expect(codes(decoded), [
        IssueCodes.bundleDuplicateId,
        // Order 3 still counts for the gap check, so none is reported.
      ]);
      expect(decoded.issues.single.path, '/levels/2/data/id');
      expect(decoded.issues.single.args, {'id': 'L0001', 'order': 1});
      expect(ids(decoded), ['L0001', 'L0002']);
    });

    test('only error-free entries claim an order or an id', () {
      // The first order-2 entry is broken, so the second one keeps order 2.
      final decoded = LevelBundleCodec.decode(
        bundleJson([
          entryJson(1),
          entryJson(2, id: 'Broken')..['tier'] = 'x',
          entryJson(2),
        ]),
      );
      expect(codes(decoded), [IssueCodes.bundleUnknownTier]);
      expect(ids(decoded), ['L0001', 'L0002']);
    });
  });

  group('continuous orders from 1', () {
    test('one issue per gap, at the entry with the found order', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1), entryJson(2), entryJson(5), entryJson(9)]),
      );
      expect(codes(decoded), [
        IssueCodes.bundleOrderGap,
        IssueCodes.bundleOrderGap,
      ]);
      expect(decoded.issues.map((i) => i.args), [
        {'expected': 3, 'found': 5},
        {'expected': 6, 'found': 9},
      ]);
      expect(decoded.issues.map((i) => i.path), [
        '/levels/2/order',
        '/levels/3/order',
      ]);
      expect(
        ids(decoded),
        ['L0001', 'L0002', 'L0005', 'L0009'],
        reason: 'gaps are errors, but the levels themselves are fine',
      );
    });

    test('orders must start at 1', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(3), entryJson(2)]),
      );
      expect(codes(decoded), [IssueCodes.bundleOrderGap]);
      expect(decoded.issues.single.args, {'expected': 1, 'found': 2});
      expect(decoded.issues.single.path, '/levels/1/order');
    });

    test('a skipped level whose order was readable causes no gap', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(1), entryJson(2)..['tier'] = 'x', entryJson(3)]),
      );
      expect(codes(decoded), [IssueCodes.bundleUnknownTier]);
    });

    test('gaps are checked after the entries, before unknown top-level '
        'keys', () {
      final decoded = LevelBundleCodec.decode(
        bundleJson([entryJson(2)..['x'] = 1])..['y'] = 2,
      );
      expect(decoded.issues.map((i) => '${i.code} ${i.path}'), [
        '${IssueCodes.unknownField} /levels/0/x',
        '${IssueCodes.bundleOrderGap} /levels/0/order',
        '${IssueCodes.unknownField} /y',
      ]);
    });
  });

  test('every code the bundle codec reports is a registered IssueCode', () {
    final reported = {
      IssueCodes.invalidJson,
      IssueCodes.wrongType,
      IssueCodes.missingField,
      IssueCodes.unknownField,
      IssueCodes.valueOutOfRange,
      IssueCodes.bundleBadFormat,
      IssueCodes.bundleUnsupportedVersion,
      IssueCodes.bundleDuplicateId,
      IssueCodes.bundleDuplicateOrder,
      IssueCodes.bundleOrderGap,
      IssueCodes.bundleUnknownTier,
    };
    expect(IssueCodes.all, containsAll(reported));
  });
}
