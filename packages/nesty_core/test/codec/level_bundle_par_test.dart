// LevelBundleEntry.par (spec-prop §7.10, D125, D146; m7-design P3.3): the
// star rating's par rides in the bundle entry, written only when present
// and read leniently.
//
// Spec-prop §7.10: "**Par** is the fewest moves that solve the level from
// its start, the solver's optimal solution (§6.3). It is computed when the
// level bundle is built, and checked with it." star-rating.md "Rules" 1:
// "The level JSON doesn't change, so no level version moves (L1–L30 stay
// byte-identical)." m7-design P3.3: "The encoder writes it after
// `rewardCoins` only when present, so a par-less bundle encodes byte for
// byte as before … The decoder reads it leniently: absent → null; an
// integral number ≥ 1 by value (`2.0` is 2) → the par; anything else → one
// `schema.wrongType` or `schema.valueOutOfRange` **warning** at
// `/levels/<i>/par`, par null, the entry kept (a bad par never makes a level
// unplayable). No new `IssueCodes` entry."
//
// Platform-neutral (inline JSON, no dart:io), like level_bundle_test.dart;
// test/parity/codec_parity_test.dart repeats the lenient reads on the web.
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'level_bundle_test.dart'
    show bundleJson, entry, entryJson, oneEntryText, tinyLevel;

LevelBundleEntry withPar(int order, int? par, {String? id}) {
  final plain = entry(order, id: id);
  return LevelBundleEntry(
    order: plain.order,
    chapterId: plain.chapterId,
    tier: plain.tier,
    version: plain.version,
    rewardCoins: plain.rewardCoins,
    level: plain.level,
    par: par,
  );
}

/// [oneEntryText]'s entry: hard, version 2, 25 coins, with [par].
LevelBundle oneEntry({int? par}) => LevelBundle(
  levelsVersion: 3,
  levels: [
    LevelBundleEntry(
      order: 1,
      chapterId: 'ch01',
      tier: Tier.hard,
      version: 2,
      rewardCoins: 25,
      level: tinyLevel('L0001'),
      par: par,
    ),
  ],
);

void main() {
  group('encode', () {
    test('par round-trips, after rewardCoins and before data', () {
      final bundle = LevelBundle(levelsVersion: 0, levels: [withPar(1, 13)]);
      final json = LevelBundleCodec.encode(bundle);
      final encoded = (json['levels']! as List).single as Map<String, Object?>;
      expect(encoded.keys.toList(), [
        'order',
        'chapterId',
        'tier',
        'version',
        'rewardCoins',
        'par',
        'data',
      ]);
      final decoded = LevelBundleCodec.decodeString(
        LevelBundleCodec.encodeString(bundle),
      );
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle, bundle);
      expect(decoded.bundle!.levels.single.par, 13);
    });

    test('an entry without a par encodes as before and reads null', () {
      final bundle = LevelBundle(levelsVersion: 0, levels: [entry(1)]);
      final encoded =
          (LevelBundleCodec.encode(bundle)['levels']! as List).single
              as Map<String, Object?>;
      expect(encoded.containsKey('par'), isFalse);
      final decoded = LevelBundleCodec.decode(
        jsonDecode(LevelBundleCodec.encodeString(bundle)),
      );
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle!.levels.single.par, isNull);
    });

    test('without a par the text is the pre-stars golden, byte for byte', () {
      expect(LevelBundleCodec.encodeString(oneEntry()), oneEntryText);
    });

    test('with a par the golden gains exactly one line, after rewardCoins', () {
      expect(
        LevelBundleCodec.encodeString(oneEntry(par: 2)),
        oneEntryText.replaceFirst(
          '      "rewardCoins": 25,\n',
          '      "rewardCoins": 25,\n      "par": 2,\n',
        ),
      );
    });

    test('decodeString(encodeString(b)) re-encodes byte for byte', () {
      final bundle = LevelBundle(
        levelsVersion: 4,
        levels: [withPar(1, 2), withPar(2, null), withPar(3, 41)],
      );
      final text = LevelBundleCodec.encodeString(bundle);
      final decoded = LevelBundleCodec.decodeString(text);
      expect(decoded.issues, isEmpty);
      expect(decoded.bundle, bundle);
      expect([for (final e in decoded.bundle!.levels) e.par], [2, null, 41]);
      expect(LevelBundleCodec.encodeString(decoded.bundle!), text);
    });
  });

  group('LevelBundleEntry', () {
    test(
      'par defaults to null and takes part in ==, hashCode and toString',
      () {
        expect(entry(1).par, isNull);
        expect(withPar(1, 5), withPar(1, 5));
        expect(withPar(1, 5).hashCode, withPar(1, 5).hashCode);
        expect(withPar(1, 5), isNot(withPar(1, 6)));
        expect(withPar(1, 5), isNot(withPar(1, null)));
        expect(withPar(1, null), entry(1));
        expect('${withPar(1, 5)}', contains('par 5'));
        expect('${entry(1)}', isNot(contains('par')));
      },
    );

    test('bundles differ when only a par differs', () {
      LevelBundle of(int? par) =>
          LevelBundle(levelsVersion: 0, levels: [withPar(1, par)]);
      expect(of(3), of(3));
      expect(of(3), isNot(of(4)));
      expect(of(3), isNot(of(null)));
    });
  });

  group('decode is lenient about par', () {
    test('2.0 reads 2; a bad par is one warning and the entry is kept', () {
      final good = entryJson(1)..['par'] = 2.0;
      expect(
        LevelBundleCodec.decode(bundleJson([good])).bundle!.levels.single.par,
        2,
      );
      for (final (value, code) in const [
        (0, IssueCodes.valueOutOfRange),
        (-1, IssueCodes.valueOutOfRange),
        ('x', IssueCodes.wrongType),
        (2.5, IssueCodes.wrongType),
      ]) {
        final json = entryJson(1)..['par'] = value;
        final result = LevelBundleCodec.decode(bundleJson([json]));
        expect(result.bundle!.levels, hasLength(1), reason: '$value');
        expect(result.bundle!.levels.single.par, isNull, reason: '$value');
        expect(result.issues, hasLength(1), reason: '$value');
        final issue = result.issues.single;
        expect(issue.code, code, reason: '$value');
        expect(issue.severity, IssueSeverity.warning, reason: '$value');
        expect(issue.path, '/levels/0/par', reason: '$value');
      }
    });

    test('other wrong types: null, a bool, a numeric string, a list, a map, '
        'a number past 2^53 − 1', () {
      for (final value in <Object?>[
        null,
        true,
        '2',
        [2],
        {'par': 2},
        9007199254740992,
      ]) {
        final json = entryJson(1)..['par'] = value;
        final result = LevelBundleCodec.decode(bundleJson([json]));
        expect(result.bundle!.levels.single.level.id, 'L0001');
        expect(result.bundle!.levels.single.par, isNull, reason: '$value');
        expect(result.issues.single.code, IssueCodes.wrongType);
        expect(result.issues.single.severity, IssueSeverity.warning);
        expect(result.issues.single.args, {
          'field': 'par',
          'expected': 'integer',
        });
      }
    });

    test('the out-of-range warning names the value and the bounds', () {
      final result = LevelBundleCodec.decode(
        bundleJson([entryJson(1)..['par'] = -3]),
      );
      expect(result.issues.single.args, {
        'field': 'par',
        'value': -3,
        'min': 1,
        'max': 9007199254740991,
      });
    });

    test('the largest exact integer is a par; 1 is the smallest', () {
      for (final value in const [1, 9007199254740991]) {
        final result = LevelBundleCodec.decode(
          bundleJson([entryJson(1)..['par'] = value]),
        );
        expect(result.issues, isEmpty, reason: '$value');
        expect(result.bundle!.levels.single.par, value);
      }
    });

    test('a par warning never skips its entry, but an error elsewhere '
        'still does', () {
      final result = LevelBundleCodec.decode(
        bundleJson([
          entryJson(1)..['par'] = 'x',
          entryJson(2)
            ..['par'] = 0
            ..['rewardCoins'] = -1,
          entryJson(3)..['par'] = 7,
        ]),
      );
      expect(
        [for (final e in result.bundle!.levels) e.level.id],
        ['L0001', 'L0003'],
      );
      expect([for (final e in result.bundle!.levels) e.par], [null, 7]);
      expect(
        [
          for (final issue in result.issues)
            (issue.path, issue.code, issue.severity),
        ],
        [
          ('/levels/0/par', IssueCodes.wrongType, IssueSeverity.warning),
          (
            '/levels/1/rewardCoins',
            IssueCodes.valueOutOfRange,
            IssueSeverity.error,
          ),
          ('/levels/1/par', IssueCodes.valueOutOfRange, IssueSeverity.warning),
        ],
      );
    });

    test('par is read after rewardCoins and before data, like the key '
        'order', () {
      final json = entryJson(1)
        ..['par'] = 'x'
        ..['version'] = 0
        ..['zz'] = 1;
      (json['data']! as Map)['maxSize'] = 'three';
      final result = LevelBundleCodec.decode(bundleJson([json]));
      expect(result.issues.map((i) => i.path), [
        '/levels/0/version',
        '/levels/0/par',
        '/levels/0/data/maxSize',
        '/levels/0/zz',
      ]);
    });

    test('a par warning alone keeps the file usable for the game', () {
      final result = LevelBundleCodec.decodeString(
        LevelBundleCodec.encodeString(
          LevelBundle(levelsVersion: 0, levels: [entry(1), entry(2)]),
        ).replaceFirst('"rewardCoins": 10,', '"rewardCoins": 10, "par": 0,'),
      );
      expect(result.bundle, isNotNull);
      expect(result.bundle!.levels, hasLength(2));
      expect(result.issues.where((i) => i.isError), isEmpty);
      expect(result.issues.single.path, '/levels/0/par');
    });
  });
}
