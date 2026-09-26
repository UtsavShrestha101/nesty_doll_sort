import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/manifest.dart';
import 'package:test/test.dart';

import 'support/scratch_repo.dart';

Map<String, Object?> manifestJson(List<Object?> levels) => {
  'format': 'nesty.levels.manifest',
  'manifestVersion': 1,
  'levelsVersion': 0,
  'levels': levels,
};

ManifestParse parse(Object? json) => parseManifest(json, subject: 'm.json');

List<String> codes(ManifestParse result) => [
  for (final f in result.findings) f.code,
];

void main() {
  test('reads every field, with the optional ones', () {
    final result = parse(
      manifestJson([
        manifestEntry(1, 'L0001', tierOverride: 'Tutorial pacing')
          ..['notes'] = 'TUT1',
        manifestEntry(2, 'L-2_b', tier: 'superhard', version: 3),
      ])..['levelsVersion'] = 4,
    );
    expect(result.findings, isEmpty);
    final manifest = result.manifest!;
    expect(manifest.levelsVersion, 4);
    final [first, second] = manifest.levels;
    expect(first.order, 1);
    expect(first.id, 'L0001');
    expect(first.chapterId, 'ch01');
    expect(first.tier, Tier.easy);
    expect(first.version, 1);
    expect(first.tierOverride, 'Tutorial pacing');
    expect(first.notes, 'TUT1');
    expect(second.tier, Tier.superhard);
    expect(second.version, 3);
    expect(second.tierOverride, isNull);
    expect(second.notes, isNull);
  });

  test('not an object', () {
    final result = parse([]);
    expect(result.manifest, isNull);
    expect(codes(result), [FindingCodes.manifestWrongType]);
  });

  test('another format stops reading (a bundle is not a manifest)', () {
    final result = parse(manifestJson([42])..['format'] = 'nesty.levels');
    expect(result.manifest, isNull);
    expect(codes(result), [FindingCodes.manifestBadFormat]);
    expect(result.findings.single.path, '/format');
  });

  test('an unsupported manifestVersion stops reading', () {
    final result = parse(manifestJson([42])..['manifestVersion'] = 2);
    expect(result.manifest, isNull);
    expect(codes(result), [FindingCodes.manifestUnsupportedVersion]);
  });

  test('missing, mistyped and unknown top-level fields', () {
    final result = parse({
      'format': 'nesty.levels.manifest',
      'manifestVersion': 1,
      'levelsVersion': -1,
      'levels': <String, Object?>{},
      'extra': true,
    });
    expect(result.manifest, isNull);
    expect(codes(result), [
      FindingCodes.manifestValueOutOfRange,
      FindingCodes.manifestWrongType,
      FindingCodes.manifestUnknownField,
    ]);
    expect(codes(parse(manifestJson([])..remove('levels'))), [
      FindingCodes.manifestMissingField,
    ]);
  });

  test('an empty manifest is valid', () {
    final result = parse(manifestJson([]));
    expect(result.findings, isEmpty);
    expect(result.manifest!.levels, isEmpty);
  });

  group('entries', () {
    test('every required field', () {
      for (final key in ['order', 'id', 'chapterId', 'tier', 'version']) {
        final result = parse(
          manifestJson([manifestEntry(1, 'L1')..remove(key)]),
        );
        expect(result.manifest, isNull, reason: key);
        expect(codes(result), [FindingCodes.manifestMissingField], reason: key);
        expect(result.findings.single.path, '/levels/0', reason: key);
      }
    });

    test('types, ranges and unknown keys', () {
      final result = parse(
        manifestJson([
          'L0001',
          manifestEntry(2, 'L2')
            ..['order'] = '2'
            ..['version'] = 0
            ..['tier'] = 'Hard'
            ..['rewardCoins'] = 10,
        ]),
      );
      expect(result.manifest, isNull);
      expect(codes(result), [
        FindingCodes.manifestWrongType,
        FindingCodes.manifestWrongType,
        FindingCodes.manifestValueOutOfRange,
        FindingCodes.manifestUnknownField,
        FindingCodes.manifestUnknownTier,
      ]);
      expect(result.findings.map((f) => f.path), [
        '/levels/0',
        '/levels/1/order',
        '/levels/1/version',
        '/levels/1/rewardCoins',
        '/levels/1/tier',
      ]);
    });

    test('orders are the positions: 1, 2, 3, …', () {
      final result = parse(
        manifestJson([
          manifestEntry(1, 'A'),
          manifestEntry(3, 'B'),
          manifestEntry(2, 'C'),
        ]),
      );
      expect(codes(result), [
        FindingCodes.manifestOrderSequence,
        FindingCodes.manifestOrderSequence,
      ]);
      expect(result.findings.map((f) => f.path), [
        '/levels/1/order',
        '/levels/2/order',
      ]);
    });

    test('ids are unique and safe as file names', () {
      final result = parse(
        manifestJson([
          manifestEntry(1, 'L0001'),
          manifestEntry(2, 'L0001'),
          manifestEntry(3, '../escape'),
          manifestEntry(4, ''),
          manifestEntry(5, 'x' * 65),
        ]),
      );
      expect(codes(result), [
        FindingCodes.manifestDuplicateId,
        FindingCodes.manifestBadId,
        FindingCodes.manifestBadId,
        FindingCodes.manifestBadId,
      ]);
      expect(result.findings.first.message, contains('entry 1'));
    });

    test('text fields must not be empty', () {
      final result = parse(
        manifestJson([
          manifestEntry(1, 'A', chapterId: ' ', tierOverride: '')
            ..['notes'] = '',
        ]),
      );
      expect(codes(result), [
        FindingCodes.manifestEmptyText,
        FindingCodes.manifestEmptyText,
        FindingCodes.manifestEmptyText,
      ]);
    });

    test('integers are read by value, as in the core codecs', () {
      final result = parse(
        manifestJson([manifestEntry(1, 'A')..['version'] = 2.0]),
      );
      expect(result.findings, isEmpty);
      expect(result.manifest!.levels.single.version, 2);
      expect(
        codes(parse(manifestJson([manifestEntry(1, 'A')..['version'] = 1.5]))),
        [FindingCodes.manifestWrongType],
      );
    });
  });
}
