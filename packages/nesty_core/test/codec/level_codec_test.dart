// LevelCodec: the level JSON of spec §5.1, strict (design A21), canonical
// key order (A20), issues collected with JSON pointers and ARB args (§5.3).
//
// Platform-neutral on purpose (inline JSON, no dart:io): the admin decodes in
// the browser and the game on the VM, so this suite also runs with
// `-p node` and `-p chrome`.
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart';

/// The spec §5.1 example, byte for byte as the canonical encoder writes it.
const String specExampleCanonical =
    '{"schemaVersion":1,"id":"L0042","maxSize":4,"shelves":['
    '[{"type":"open","nest":["red4","red3"]},'
    '{"type":"open","nest":null},'
    '{"type":"tower","stack":[["blue2"],["green4"],["red2","red1"]]}],'
    '[{"type":"locked","unlockColor":"red","nest":["green3","green2","green1"]},'
    '{"type":"open","nest":["blue4","blue3"],"ice":2},'
    '{"type":"open","nest":["blue1"]}]]}';

/// A small valid level to break one piece at a time. Fresh and mutable on
/// every call, and parsed like real input, so its lists and maps take any
/// JSON value.
Map<String, Object?> baseJson() =>
    jsonDecode(
          '{"schemaVersion":1,"id":"T1","maxSize":3,"shelves":['
          '[{"type":"open","nest":["red3"]},{"type":"open","nest":null}],'
          '[{"type":"open","nest":["red2","red1"]},{"type":"open","nest":null}]'
          ']}',
        )
        as Map<String, Object?>;

/// [baseJson] with the slot at `r0c1` replaced by [slot].
Map<String, Object?> withSlot(Object? slot) {
  final json = baseJson();
  ((json['shelves']! as List)[0] as List)[1] = slot;
  return json;
}

/// Decodes [json], expects no level and exactly one issue, and returns it.
LevelIssue singleIssue(Object? json) {
  final result = LevelCodec.decode(json);
  expect(result.level, isNull, reason: 'an error means no level');
  expect(result.issues, hasLength(1), reason: '${result.issues}');
  return result.issues.single;
}

Matcher isIssue(
  String code, {
  String path = '',
  String? slotId,
  Map<String, Object>? args,
}) => isA<LevelIssue>()
    .having((i) => i.code, 'code', code)
    .having((i) => i.severity, 'severity', IssueSeverity.error)
    .having((i) => i.path, 'path', path)
    .having((i) => i.slotId, 'slotId', slotId)
    .having((i) => i.message, 'message', isNotEmpty)
    .having((i) => i.args, 'args', args ?? anything);

Nest nestOf(DollColor color, int outer, [int length = 1]) =>
    Nest.run(color, outer: outer, length: length);

void main() {
  group('decode', () {
    test('the spec §5.1 example decodes into the model', () {
      final result = LevelCodec.decodeString(specExampleCanonical);
      expect(result.issues, isEmpty);
      expect(result.isOk, isTrue);
      expect(result.level, specExampleLevel());
    });

    test('reads every slot kind with the spec §5.1 meaning', () {
      final level = LevelCodec.decodeString(specExampleCanonical).level!;
      // Nests are outer to inner; tower stacks bottom to top (spec §5.1).
      expect(level.slot('r0c0'), OpenSlot(nest: nestOf(DollColor.red, 4, 2)));
      expect(level.slot('r0c1'), OpenSlot());
      final tower = level.slot('r0c2') as TowerSlot;
      expect(tower.stack.first, nestOf(DollColor.blue, 2));
      expect(tower.top, nestOf(DollColor.red, 2, 2));
      expect(
        level.slot('r1c0'),
        LockedSlot(
          unlockColor: DollColor.red,
          nest: nestOf(DollColor.green, 3, 3),
        ),
      );
      expect(level.slot('r1c1').ice, 2);
      expect(level.slot('r1c2').ice, 0, reason: 'ice omitted means 0');
      expect(level.generatorVersion, isNull);
      expect(level.seed, isNull);
    });

    test('an explicit "ice": 0 is accepted', () {
      final level = LevelCodec.decode(
        withSlot({'type': 'open', 'nest': null, 'ice': 0}),
      ).level!;
      expect(level.slot('r0c1'), OpenSlot());
    });

    test('reads ice on towers and locked slots', () {
      final tower = LevelCodec.decode(
        withSlot({
          'type': 'tower',
          'stack': [
            ['blue1'],
          ],
          'ice': 3,
        }),
      ).level!;
      expect(
        tower.slot('r0c1'),
        TowerSlot([nestOf(DollColor.blue, 1)], ice: 3),
      );
      final locked = LevelCodec.decode(
        withSlot({
          'type': 'locked',
          'unlockColor': 'red',
          'nest': null,
          'ice': 1,
        }),
      ).level!;
      expect(
        locked.slot('r0c1'),
        LockedSlot(unlockColor: DollColor.red, ice: 1),
      );
    });

    test('reads the optional generator fields (design A20)', () {
      final json = baseJson()
        ..['generatorVersion'] = 1
        ..['seed'] = 1000001;
      final level = LevelCodec.decode(json).level!;
      expect(level.generatorVersion, 1);
      expect(level.seed, 1000001);
    });

    test('a seed up to 2^53 − 1 is read exactly', () {
      final level = LevelCodec.decode(
        baseJson()..['seed'] = Prng.maxSeed,
      ).level!;
      expect(level.seed, Prng.maxSeed);
    });

    test('parses gold tokens; the validator rejects them (D22)', () {
      final level = LevelCodec.decode(
        withSlot({
          'type': 'open',
          'nest': ['gold2', 'gold1'],
        }),
      ).level!;
      expect(level.slot('r0c1'), OpenSlot(nest: nestOf(DollColor.gold, 2, 2)));
    });

    test('reads every color id of spec §12.3', () {
      for (final color in DollColor.values) {
        final level = LevelCodec.decode(
          withSlot({
            'type': 'open',
            'nest': ['${color.id}3'],
          }),
        ).level!;
        expect(level.slot('r0c1').nests.single.color, color);
      }
    });

    test('decodes what only the validator rejects', () {
      // A Level can hold these (§5.3 rules 1, 2, 5; A20; A21), so the codec
      // decodes them and the validator reports them with the same paths.
      final json = baseJson()
        ..['id'] = ''
        ..['maxSize'] = 9
        ..['seed'] = -1
        ..['shelves'] = [
          [
            {
              'type': 'tower',
              'stack': [
                ['red6'],
                ['red5'],
                ['red4'],
                ['red3'],
                ['red2', 'red1'],
              ],
            },
          ],
        ];
      final result = LevelCodec.decode(json);
      expect(result.issues, isEmpty);
      expect(result.level!.maxSize, 9);
      expect((result.level!.slot('r0c0') as TowerSlot).stack, hasLength(5));
    });

    group('integers agree across the VM and the web', () {
      test('an integral double is an int (3.0 reads as 3)', () {
        final level = LevelCodec.decode(baseJson()..['maxSize'] = 3.0).level!;
        expect(level.maxSize, 3);
        expect(level, LevelCodec.decode(baseJson()).level);
      });

      test('a fraction is not an integer', () {
        expect(
          singleIssue(baseJson()..['maxSize'] = 3.5),
          isIssue(
            IssueCodes.wrongType,
            path: '/maxSize',
            args: {'field': 'maxSize', 'expected': 'integer'},
          ),
        );
      });

      test('beyond 2^53 − 1 is not an integer every platform reads', () {
        expect(
          singleIssue(baseJson()..['seed'] = 9007199254740992.0),
          isIssue(
            IssueCodes.wrongType,
            path: '/seed',
            args: {'field': 'seed', 'expected': 'integer'},
          ),
        );
        final fromText = LevelCodec.decodeString(
          '{"schemaVersion":1,"id":"T","maxSize":3,"shelves":[],'
          '"seed":1e300}',
        );
        expect(fromText.level, isNull);
        expect(fromText.issues.single.code, IssueCodes.wrongType);
      });

      test('infinity and NaN are not integers', () {
        for (final value in [double.infinity, double.nan]) {
          expect(
            singleIssue(baseJson()..['maxSize'] = value).code,
            IssueCodes.wrongType,
          );
        }
      });
    });
  });

  group('encode', () {
    test('writes the canonical key order (design A20)', () {
      expect(
        jsonEncode(LevelCodec.encode(specExampleLevel())),
        specExampleCanonical,
      );
    });

    test('encodeString without indent is jsonEncode(encode(level))', () {
      final level = specExampleLevel();
      expect(LevelCodec.encodeString(level), specExampleCanonical);
      expect(
        LevelCodec.encodeString(level),
        jsonEncode(LevelCodec.encode(level)),
      );
    });

    test('encodeString with an indent pretty-prints the same JSON', () {
      final pretty = LevelCodec.encodeString(specExampleLevel(), indent: '  ');
      expect(pretty, startsWith('{\n  "schemaVersion": 1,\n  "id": "L0042",'));
      expect(jsonEncode(jsonDecode(pretty)), specExampleCanonical);
    });

    test('empty slots are "nest": null and ice 0 is omitted', () {
      final json = LevelCodec.encode(specExampleLevel());
      final shelves = json['shelves']! as List;
      expect((shelves[0] as List)[1], {'type': 'open', 'nest': null});
      expect(((shelves[1] as List)[2] as Map).containsKey('ice'), isFalse);
      expect(((shelves[1] as List)[1] as Map)['ice'], 2);
    });

    test('generator fields come last, only when set', () {
      final plain = LevelCodec.encode(specExampleLevel());
      expect(plain.keys, ['schemaVersion', 'id', 'maxSize', 'shelves']);
      final generated = LevelCodec.encode(
        Level(
          id: 'B1',
          maxSize: 3,
          shelves: specExampleLevel().shelves,
          generatorVersion: 1,
          seed: 1000001,
        ),
      );
      expect(generated.keys, [
        'schemaVersion',
        'id',
        'maxSize',
        'shelves',
        'generatorVersion',
        'seed',
      ]);
      expect(generated['generatorVersion'], 1);
      expect(generated['seed'], 1000001);
    });

    test('slot keys are type, unlockColor, nest|stack, ice', () {
      final level = Level(
        id: 'K',
        maxSize: 3,
        shelves: [
          [
            LockedSlot(
              unlockColor: DollColor.blue,
              nest: nestOf(DollColor.red, 3),
              ice: 1,
            ),
            TowerSlot([nestOf(DollColor.red, 2)], ice: 2),
            OpenSlot(nest: nestOf(DollColor.red, 1), ice: 3),
          ],
        ],
      );
      final slots = (LevelCodec.encode(level)['shelves']! as List)[0] as List;
      expect((slots[0] as Map).keys, ['type', 'unlockColor', 'nest', 'ice']);
      expect((slots[1] as Map).keys, ['type', 'stack', 'ice']);
      expect((slots[2] as Map).keys, ['type', 'nest', 'ice']);
      expect(
        jsonEncode(slots),
        '[{"type":"locked","unlockColor":"blue","nest":["red3"],"ice":1},'
        '{"type":"tower","stack":[["red2"]],"ice":2},'
        '{"type":"open","nest":["red1"],"ice":3}]',
      );
    });
  });

  group('round trip', () {
    final levels = <String, Level>{
      'the spec §5.1 example': specExampleLevel(),
      'a generated level': Level(
        id: 'B0001',
        maxSize: 3,
        shelves: specExampleLevel().shelves,
        generatorVersion: 1,
        seed: Prng.maxSeed,
      ),
      'gold and ice everywhere': Level(
        id: 'G',
        maxSize: 6,
        shelves: [
          [
            OpenSlot(nest: nestOf(DollColor.gold, 6, 6), ice: 5),
            TowerSlot([
              nestOf(DollColor.brown, 6),
              nestOf(DollColor.navy, 5, 5),
            ], ice: 1),
          ],
          [LockedSlot(unlockColor: DollColor.pink, ice: 2), OpenSlot()],
        ],
      ),
      'a level the validator rejects': Level(
        id: '',
        maxSize: 2,
        schemaVersion: 1,
        shelves: [
          [],
          [
            TowerSlot([for (var i = 0; i < 6; i++) nestOf(DollColor.red, 1)]),
          ],
        ],
        seed: -5,
        generatorVersion: 0,
      ),
      'no shelves': Level(id: 'E', maxSize: 3, shelves: const []),
    };

    for (final MapEntry(key: name, value: level) in levels.entries) {
      test('decode(encode(level)) == level: $name', () {
        final encoded = LevelCodec.encodeString(level);
        final decoded = LevelCodec.decodeString(encoded);
        expect(decoded.issues, isEmpty);
        expect(decoded.level, level);
        // And the canonical bytes are stable.
        expect(LevelCodec.encodeString(decoded.level!), encoded);
      });
    }

    test('encode(decode(json)) == json for canonical JSON', () {
      final decoded = LevelCodec.decodeString(specExampleCanonical).level!;
      expect(LevelCodec.encodeString(decoded), specExampleCanonical);
    });
  });

  group('issues (one test per codec code)', () {
    test('schema.invalidJson', () {
      final result = LevelCodec.decodeString('{"schemaVersion": 1,');
      expect(result.level, isNull);
      expect(result.issues.single, isIssue(IssueCodes.invalidJson));
      // The parser's text differs between the VM and the web, so it is in
      // the message only, never an ARB arg.
      expect(result.issues.single.args, isEmpty);
      expect(result.issues.single.message, startsWith('Not valid JSON: '));
    });

    group('schema.unsupportedVersion', () {
      test('another version is not read further', () {
        final json = baseJson()
          ..['schemaVersion'] = 2
          ..['shelves'] = 'a v2 shape'
          ..['newField'] = true;
        expect(
          singleIssue(json),
          isIssue(
            IssueCodes.unsupportedVersion,
            path: '/schemaVersion',
            args: {'version': 2, 'supported': 1},
          ),
        );
      });

      test('a missing version is reported and the rest read as v1', () {
        final json = baseJson()
          ..remove('schemaVersion')
          ..['maxSize'] = 'three';
        final issues = LevelCodec.decode(json).issues;
        expect(issues.map((i) => i.code), [
          IssueCodes.missingField,
          IssueCodes.wrongType,
        ]);
        expect(issues.first.args, {'field': 'schemaVersion'});
      });
    });

    group('schema.missingField', () {
      for (final key in ['schemaVersion', 'id', 'maxSize', 'shelves']) {
        test('the level needs "$key"', () {
          expect(
            singleIssue(baseJson()..remove(key)),
            isIssue(IssueCodes.missingField, args: {'field': key}),
          );
        });
      }

      test('a slot needs its type', () {
        expect(
          singleIssue(withSlot({'nest': null})),
          isIssue(
            IssueCodes.missingField,
            path: '/shelves/0/1',
            slotId: 'r0c1',
            args: {'field': 'type'},
          ),
        );
      });

      test('open and locked slots need "nest" (null when empty)', () {
        expect(
          singleIssue(withSlot({'type': 'open'})),
          isIssue(
            IssueCodes.missingField,
            path: '/shelves/0/1',
            slotId: 'r0c1',
            args: {'field': 'nest'},
          ),
        );
        expect(
          singleIssue(withSlot({'type': 'locked', 'unlockColor': 'red'})),
          isIssue(
            IssueCodes.missingField,
            path: '/shelves/0/1',
            slotId: 'r0c1',
            args: {'field': 'nest'},
          ),
        );
      });

      test('a locked slot needs its unlockColor', () {
        expect(
          singleIssue(withSlot({'type': 'locked', 'nest': null})),
          isIssue(
            IssueCodes.missingField,
            path: '/shelves/0/1',
            slotId: 'r0c1',
            args: {'field': 'unlockColor'},
          ),
        );
      });

      test('a tower needs its stack', () {
        expect(
          singleIssue(withSlot({'type': 'tower'})),
          isIssue(
            IssueCodes.missingField,
            path: '/shelves/0/1',
            slotId: 'r0c1',
            args: {'field': 'stack'},
          ),
        );
      });
    });

    group('schema.unknownField (strict, design A21)', () {
      test('at the top level', () {
        expect(
          singleIssue(baseJson()..['tier'] = 'easy'),
          isIssue(
            IssueCodes.unknownField,
            path: '/tier',
            args: {'field': 'tier'},
          ),
        );
      });

      test('keys belong to one slot type', () {
        expect(
          singleIssue(
            withSlot({'type': 'open', 'nest': null, 'stack': <Object>[]}),
          ),
          isIssue(
            IssueCodes.unknownField,
            path: '/shelves/0/1/stack',
            slotId: 'r0c1',
            args: {'field': 'stack'},
          ),
        );
        expect(
          singleIssue(
            withSlot({
              'type': 'tower',
              'stack': [
                ['blue1'],
              ],
              'unlockColor': 'red',
            }),
          ).code,
          IssueCodes.unknownField,
        );
        expect(
          singleIssue(
            withSlot({
              'type': 'locked',
              'unlockColor': 'red',
              'nest': null,
              'unlocked': false,
            }),
          ),
          isIssue(
            IssueCodes.unknownField,
            path: '/shelves/0/1/unlocked',
            slotId: 'r0c1',
            args: {'field': 'unlocked'},
          ),
        );
      });

      test('a JSON-pointer special character in a key is escaped', () {
        expect(singleIssue(baseJson()..['a/b~c'] = 1).path, '/a~1b~0c');
      });
    });

    group('schema.wrongType', () {
      final cases = <String, (Object?, String, Map<String, Object>, String?)>{
        'the document is not an object': (
          <Object>[],
          '',
          {'field': 'level', 'expected': 'object'},
          null,
        ),
        'schemaVersion is a string': (
          baseJson()..['schemaVersion'] = '1',
          '/schemaVersion',
          {'field': 'schemaVersion', 'expected': 'integer'},
          null,
        ),
        'id is a number': (
          baseJson()..['id'] = 42,
          '/id',
          {'field': 'id', 'expected': 'string'},
          null,
        ),
        'maxSize is null': (
          baseJson()..['maxSize'] = null,
          '/maxSize',
          {'field': 'maxSize', 'expected': 'integer'},
          null,
        ),
        'shelves is an object': (
          baseJson()..['shelves'] = <String, Object>{},
          '/shelves',
          {'field': 'shelves', 'expected': 'array'},
          null,
        ),
        'a shelf is not an array': (
          baseJson()
            ..['shelves'] = [
              {'type': 'open', 'nest': null},
            ],
          '/shelves/0',
          {'field': 'shelf', 'expected': 'array'},
          null,
        ),
        'a slot is not an object': (
          withSlot('open'),
          '/shelves/0/1',
          {'field': 'slot', 'expected': 'object'},
          'r0c1',
        ),
        'type is not a string': (
          withSlot({'type': 1, 'nest': null}),
          '/shelves/0/1/type',
          {'field': 'type', 'expected': 'string'},
          'r0c1',
        ),
        'nest is a string': (
          withSlot({'type': 'open', 'nest': 'red1'}),
          '/shelves/0/1/nest',
          {'field': 'nest', 'expected': 'arrayOrNull'},
          'r0c1',
        ),
        'stack is null': (
          withSlot({'type': 'tower', 'stack': null}),
          '/shelves/0/1/stack',
          {'field': 'stack', 'expected': 'array'},
          'r0c1',
        ),
        'a tower nest is null': (
          withSlot({
            'type': 'tower',
            'stack': [
              ['blue1'],
              null,
            ],
          }),
          '/shelves/0/1/stack/1',
          {'field': 'nest', 'expected': 'array'},
          'r0c1',
        ),
        'a doll is not a string': (
          withSlot({
            'type': 'open',
            'nest': [3],
          }),
          '/shelves/0/1/nest/0',
          {'field': 'doll', 'expected': 'string'},
          'r0c1',
        ),
        'unlockColor is not a string': (
          withSlot({'type': 'locked', 'unlockColor': 0, 'nest': null}),
          '/shelves/0/1/unlockColor',
          {'field': 'unlockColor', 'expected': 'string'},
          'r0c1',
        ),
        'ice is a string': (
          withSlot({'type': 'open', 'nest': null, 'ice': '2'}),
          '/shelves/0/1/ice',
          {'field': 'ice', 'expected': 'integer'},
          'r0c1',
        ),
        'seed is null (omit it instead)': (
          baseJson()..['seed'] = null,
          '/seed',
          {'field': 'seed', 'expected': 'integer'},
          null,
        ),
        'generatorVersion is a fraction': (
          baseJson()..['generatorVersion'] = 1.5,
          '/generatorVersion',
          {'field': 'generatorVersion', 'expected': 'integer'},
          null,
        ),
      };
      for (final MapEntry(key: name, value: (json, path, args, slotId))
          in cases.entries) {
        test(name, () {
          expect(
            singleIssue(json),
            isIssue(
              IssueCodes.wrongType,
              path: path,
              slotId: slotId,
              args: args,
            ),
          );
        });
      }
    });

    test('slot.unknownType (the rest of the slot is not checked)', () {
      expect(
        singleIssue(withSlot({'type': 'shelf', 'nest': 5, 'extra': true})),
        isIssue(
          IssueCodes.unknownSlotType,
          path: '/shelves/0/1/type',
          slotId: 'r0c1',
          args: {'type': 'shelf'},
        ),
      );
    });

    group('doll.badToken (^([a-z]+)([1-6])\$)', () {
      for (final token in [
        'Red4',
        'red',
        '4',
        'red0',
        'red7',
        'red10',
        ' red4',
        'red4 ',
        'red-4',
        '',
      ]) {
        test('"$token"', () {
          expect(
            singleIssue(
              withSlot({
                'type': 'open',
                'nest': [token],
              }),
            ),
            isIssue(
              IssueCodes.badDollToken,
              path: '/shelves/0/1/nest/0',
              slotId: 'r0c1',
              args: {'token': token},
            ),
          );
        });
      }
    });

    group('doll.unknownColor', () {
      test('in doll tokens, each with its own path', () {
        final issues = LevelCodec.decode(
          withSlot({
            'type': 'tower',
            'stack': [
              ['blue1'],
              ['silver3', 'silver2'],
            ],
          }),
        ).issues;
        expect(issues, [
          isIssue(
            IssueCodes.unknownDollColor,
            path: '/shelves/0/1/stack/1/0',
            slotId: 'r0c1',
            args: {'token': 'silver3', 'color': 'silver'},
          ),
          isIssue(
            IssueCodes.unknownDollColor,
            path: '/shelves/0/1/stack/1/1',
            slotId: 'r0c1',
            args: {'token': 'silver2', 'color': 'silver'},
          ),
        ]);
      });

      test('as an unlockColor', () {
        expect(
          singleIssue(
            withSlot({'type': 'locked', 'unlockColor': 'Red', 'nest': null}),
          ),
          isIssue(
            IssueCodes.unknownDollColor,
            path: '/shelves/0/1/unlockColor',
            slotId: 'r0c1',
            args: {'token': 'Red', 'color': 'Red'},
          ),
        );
      });
    });

    test('ice.negative (spec §3.4)', () {
      expect(
        singleIssue(withSlot({'type': 'open', 'nest': null, 'ice': -1})),
        isIssue(
          IssueCodes.negativeIce,
          path: '/shelves/0/1/ice',
          slotId: 'r0c1',
          args: {'ice': -1},
        ),
      );
    });

    test('nest.empty (spec §2.1: one or more dolls)', () {
      expect(
        singleIssue(withSlot({'type': 'open', 'nest': <Object>[]})),
        isIssue(
          IssueCodes.emptyNest,
          path: '/shelves/0/1/nest',
          slotId: 'r0c1',
        ),
      );
      expect(
        singleIssue(
          withSlot({
            'type': 'tower',
            'stack': [<Object>[]],
          }),
        ),
        isIssue(
          IssueCodes.emptyNest,
          path: '/shelves/0/1/stack/0',
          slotId: 'r0c1',
        ),
      );
    });

    test('nest.mixedColors (spec §2.1: same color)', () {
      expect(
        singleIssue(
          withSlot({
            'type': 'open',
            'nest': ['red2', 'blue1'],
          }),
        ),
        isIssue(
          IssueCodes.mixedColors,
          path: '/shelves/0/1/nest',
          slotId: 'r0c1',
          args: {'tokens': 'red2, blue1'},
        ),
      );
    });

    group('nest.notConsecutive (spec §2.1)', () {
      for (final tokens in [
        ['red4', 'red2'],
        ['red1', 'red2'],
        ['red3', 'red3'],
      ]) {
        test(tokens.join(', '), () {
          expect(
            singleIssue(
              withSlot({
                'type': 'locked',
                'unlockColor': 'blue',
                'nest': tokens,
              }),
            ),
            isIssue(
              IssueCodes.notConsecutive,
              path: '/shelves/0/1/nest',
              slotId: 'r0c1',
              args: {'tokens': tokens.join(', ')},
            ),
          );
        });
      }
    });

    test('tower.emptyAtStart (spec §5.3 rule 5)', () {
      expect(
        singleIssue(withSlot({'type': 'tower', 'stack': <Object>[]})),
        isIssue(
          IssueCodes.towerEmptyAtStart,
          path: '/shelves/0/1/stack',
          slotId: 'r0c1',
        ),
      );
    });

    test('gold.notSupported for a nest mixing gold (spec §3.5, D22)', () {
      expect(
        singleIssue(
          withSlot({
            'type': 'open',
            'nest': ['red3', 'gold2', 'red1'],
          }),
        ),
        isIssue(
          IssueCodes.goldNotSupported,
          path: '/shelves/0/1/nest',
          slotId: 'r0c1',
          args: {'token': 'gold2'},
        ),
      );
    });
  });

  group('collects issues instead of failing fast', () {
    test('reports every problem in document order', () {
      final json = baseJson()
        ..['id'] = 7
        ..['extra'] = null
        ..['shelves'] = [
          [
            {
              'type': 'open',
              'nest': ['Red3'],
            },
            {'type': 'tower', 'stack': <Object>[]},
          ],
          [
            {'type': 'open', 'nest': null, 'ice': -2},
            {
              'type': 'locked',
              'unlockColor': 'red',
              'nest': ['red1', 'blue2'],
            },
          ],
        ];
      final result = LevelCodec.decode(json);
      expect(result.level, isNull);
      expect(result.issues.map((i) => '${i.code} ${i.path}'), [
        'schema.wrongType /id',
        'doll.badToken /shelves/0/0/nest/0',
        'tower.emptyAtStart /shelves/0/1/stack',
        'ice.negative /shelves/1/0/ice',
        'nest.mixedColors /shelves/1/1/nest',
        'schema.unknownField /extra',
      ]);
    });

    test('inside a slot: fields in canonical order, then unknown keys', () {
      final issues = LevelCodec.decode(
        withSlot({
          'colour': 'red',
          'type': 'locked',
          'ice': 'two',
          'nest': ['red2', 'red3'],
          'unlockColor': 'rose',
        }),
      ).issues;
      expect(issues.map((i) => '${i.code} ${i.path}'), [
        'doll.unknownColor /shelves/0/1/unlockColor',
        'nest.notConsecutive /shelves/0/1/nest',
        'schema.wrongType /shelves/0/1/ice',
        'schema.unknownField /shelves/0/1/colour',
      ]);
      expect(issues.map((i) => i.slotId).toSet(), {'r0c1'});
    });

    test('LevelDecodeResult compares by value', () {
      expect(
        LevelCodec.decodeString(specExampleCanonical),
        LevelCodec.decodeString(specExampleCanonical),
      );
      expect(
        LevelCodec.decode(baseJson()..remove('id')),
        LevelCodec.decode(baseJson()..remove('id')),
      );
    });
  });
}
