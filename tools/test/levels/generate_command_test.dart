import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/generator_params_json.dart';
import 'package:test/test.dart';

import 'support/scratch_repo.dart';

const String smallParams =
    '{"colors":2,"maxSize":3,"shelves":2,"slotsPerShelf":3,"emptySlots":2,'
    '"targetTier":"easy"}';

void main() {
  group('parseGeneratorParams', () {
    List<String> codes(Object? json) => [
      for (final f in parseGeneratorParams(json, subject: 'p').findings) f.code,
    ];

    test('required keys, tier ids and GeneratorParams defaults', () {
      final parse = parseGeneratorParams({
        'colors': 3,
        'maxSize': 4,
        'shelves': 3,
        'slotsPerShelf': 4,
        'emptySlots': 1,
        'towers': 2,
        'targetTier': 'hard',
      }, subject: 'p');
      expect(parse.findings, isEmpty);
      final params = parse.params!(42);
      expect(
        params,
        const GeneratorParams(
          colors: 3,
          maxSize: 4,
          shelves: 3,
          slotsPerShelf: 4,
          emptySlots: 1,
          towers: 2,
          targetTier: Tier.hard,
          seed: 42,
        ),
      );
    });

    test('every key is read', () {
      final params = parseGeneratorParams({
        'colors': 3,
        'setsPerColor': 2,
        'maxSize': 5,
        'shelves': 3,
        'slotsPerShelf': 4,
        'towers': 1,
        'towerDepth': 3,
        'emptySlots': 2,
        'locked': 1,
        'iceSlots': 1,
        'targetTier': 'superhard',
      }, subject: 'p').params!(7);
      expect(params.setsPerColor, 2);
      expect(params.towerDepth, 3);
      expect(params.locked, 1);
      expect(params.iceSlots, 1);
      expect(params.targetTier, Tier.superhard);
    });

    test('rejects missing, mistyped and unknown keys (seed and id too)', () {
      expect(codes([]), ['params.wrongType']);
      expect(codes({'colors': 2}), [
        'params.missingField',
        'params.missingField',
        'params.missingField',
        'params.missingField',
        'params.missingField',
      ]);
      expect(
        codes({
          'colors': '2',
          'maxSize': 3,
          'shelves': 2,
          'slotsPerShelf': 3,
          'emptySlots': 1,
          'targetTier': 'Easy',
          'seed': 1,
          'id': 'x',
        }),
        [
          'params.wrongType',
          FindingCodes.paramsUnknownTier,
          'params.unknownField',
          'params.unknownField',
        ],
      );
    });
  });

  group('generate', () {
    late ScratchRepo repo;
    setUp(() => repo = ScratchRepo.create());
    tearDown(() => repo.delete());

    test('--params --seed --count: the same batch twice is identical', () {
      final args = [
        'generate',
        '--params',
        smallParams,
        '--seed',
        '11',
        '--count',
        '2',
      ];
      final first = repo.run(args);
      expect(first.exitCode, 0, reason: '$first');
      expect(first.out, contains('gen-11'));
      expect(first.out, contains('gen-12'));
      expect(repo.run(args).out, first.out);

      // The printed level is exactly the generator's.
      final outcome =
          Generator.generate(
                const GeneratorParams(
                  colors: 2,
                  maxSize: 3,
                  shelves: 2,
                  slotsPerShelf: 3,
                  emptySlots: 2,
                  targetTier: Tier.easy,
                  seed: 11,
                ),
              )
              as GeneratorSuccess;
      expect(first.out, contains(LevelCodec.encodeString(outcome.level)));
    });

    test('--params may name a file; --out writes one file per level', () {
      repo.write('params/small.json', smallParams);
      final run = repo.run([
        'generate',
        '--params',
        'small.json',
        '--seed=3',
        '--out',
        '../drafts',
        '--verify',
      ], cwd: 'params');
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('Wrote 1 level(s) to drafts'));
      final text = repo.read('drafts/gen-3.json');
      final level = LevelCodec.decodeString(text).level!;
      expect(text, '${LevelCodec.encodeString(level, indent: '  ')}\n');
      expect(level.generatorVersion, Generator.version);
      expect(level.seed, 3);
    });

    test('--bonus uses the curve (spec §7.1) and --verify re-validates', () {
      final run = repo.run([
        'generate',
        '--bonus',
        '1',
        '--count',
        '2',
        '--verify',
      ]);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('1000001  bonus-1'));
      expect(run.out, contains('1000002  bonus-2'));
      expect(run.out, contains('generate 2 level(s): OK'));
    });

    test('--daily generates that date\'s puzzle (spec §7.5)', () {
      final run = repo.run(['generate', '--daily', '20260926']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('daily-20260926'));
      expect(repo.run(['generate', '--daily', '20260931']).exitCode, 64);
    });

    test('bad params are findings; impossible ones fail per seed', () {
      final unknown = repo.run([
        'generate',
        '--params',
        '{"colors":2}',
        '--seed',
        '1',
      ]);
      expect(unknown.exitCode, 1);
      expect(unknown.err, contains('params.missingField'));

      final impossible = repo.run([
        'generate',
        '--params',
        smallParams.replaceFirst('"emptySlots":2', '"emptySlots":5'),
        '--seed',
        '1',
      ]);
      expect(impossible.exitCode, 1);
      expect(impossible.out, contains('FAILED'));
      expect(impossible.err, contains('seed 1'));
    });

    test('usage: exactly one source, explicit seeds', () {
      expect(repo.run(['generate']).exitCode, 64);
      expect(repo.run(['generate', '--params', smallParams]).exitCode, 64);
      expect(
        repo.run([
          'generate',
          '--params',
          smallParams,
          '--bonus',
          '1',
        ]).exitCode,
        64,
      );
      expect(
        repo.run(['generate', '--bonus', '1', '--seed', '2']).exitCode,
        64,
      );
      expect(repo.run(['generate', '--bonus', '0']).exitCode, 64);
      expect(
        repo.run(['generate', '--daily', '20260926', '--count', '2']).exitCode,
        64,
      );
      expect(
        repo.run(['generate', '--params', '{', '--seed', '1']).exitCode,
        64,
      );
      expect(repo.run(['generate', 'extra', '--bonus', '1']).exitCode, 64);
    });
  });
}
