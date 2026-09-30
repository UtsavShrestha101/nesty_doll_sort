import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/bundled_level_repository.dart';

/// Serves [files] by key and counts reads.
final class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);

  final Map<String, String> files;
  int reads = 0;

  @override
  Future<ByteData> load(String key) async {
    reads++;
    final text = files[key];
    if (text == null) throw StateError('Unable to load asset: $key');
    return ByteData.sublistView(utf8.encode(text));
  }
}

/// A one-colour maxSize-3 level; [nests] replaces its three nests.
Map<String, Object?> _level(String id, {List<List<String>>? nests}) => {
  'schemaVersion': 1,
  'id': id,
  'maxSize': 3,
  'shelves': [
    [
      for (final nest
          in nests ??
              const [
                ['red3'],
                ['red2'],
                ['red1'],
              ])
        {'type': 'open', 'nest': nest},
      {'type': 'open', 'nest': null},
    ],
  ],
};

Map<String, Object?> _entry(
  int order,
  Map<String, Object?> level, {
  String tier = 'easy',
  Object? par,
}) => {
  'order': order,
  'chapterId': 'ch01',
  'tier': tier,
  'version': 1,
  'rewardCoins': 10,
  'par': ?par,
  'data': level,
};

String _bundleJson(List<Map<String, Object?>> entries) => jsonEncode({
  'format': LevelBundle.format,
  'bundleVersion': LevelBundle.currentBundleVersion,
  'levelsVersion': 1,
  'levels': entries,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  BundledLevelRepository repositoryOf(String json) => BundledLevelRepository(
    bundle: _Bundle({BundledLevelRepository.bundleAsset: json}),
  );

  // M7 ships levels 1–200 in ten chapters of 20 (spec §7.1's launch target,
  // D90; m7-design §18 gives this count to the levels lane).
  test(
    'the shipped bundle loads: 200 levels in play order (rootBundle)',
    () async {
      final repository = BundledLevelRepository();
      expect(repository.levelCount, 0);
      expect(repository.entryAt(1), isNull);

      await repository.load();

      expect(repository.levelCount, 200);
      for (var order = 1; order <= 200; order++) {
        final entry = repository.entryAt(order)!;
        expect(entry.order, order);
        expect(entry.level.id, 'L${order.toString().padLeft(4, '0')}');
        expect(
          entry.chapterId,
          'ch${((order - 1) ~/ 20 + 1).toString().padLeft(2, '0')}',
        );
      }
      expect(repository.entryAt(0), isNull);
      expect(repository.entryAt(201), isNull);
    },
  );

  // Spec-prop §7.10 (D146): every bundled level carries its par, the
  // solver's optimum that `nesty_levels bundle build` writes; the tutorial
  // L1 is 2 moves (design §4), so its par is 2.
  test('every shipped level has its star-rating par; L1 is 2', () async {
    final repository = BundledLevelRepository();
    await repository.load();

    expect(repository.entryAt(1)!.par, 2);
    expect(repository.entryAt(2)!.par, 3);
    for (var order = 1; order <= repository.levelCount; order++) {
      expect(
        repository.entryAt(order)!.par,
        greaterThanOrEqualTo(1),
        reason: 'order $order',
      );
    }
  });

  test('a par crosses the worker isolate; a bad one is only a warning, and '
      'its level still plays without stars', () async {
    final repository = repositoryOf(
      _bundleJson([
        _entry(1, _level('A'), par: 2),
        _entry(2, _level('B'), par: 0),
        _entry(3, _level('C'), par: 'x'),
        _entry(4, _level('D')),
      ]),
    );

    await repository.load();

    expect(repository.levelCount, 4);
    expect(
      [for (var o = 1; o <= 4; o++) repository.entryAt(o)!.level.id],
      ['A', 'B', 'C', 'D'],
    );
    expect(
      [for (var o = 1; o <= 4; o++) repository.entryAt(o)!.par],
      [2, null, null, null],
    );
    expect(repository.checkedOn, BundledLevelRepository.workerName);
  });

  test('a level that fails a validator rule is skipped; its order plays the '
      'next level and progress goes on from there', () async {
    final repository = repositoryOf(
      _bundleJson([
        _entry(1, _level('A')),
        // Rule 4: red1 is missing, so red isn't a whole set.
        _entry(
          2,
          _level(
            'B',
            nests: [
              ['red3'],
              ['red2'],
            ],
          ),
        ),
        _entry(3, _level('C')),
      ]),
    );

    await repository.load();

    expect(repository.entryAt(1)!.level.id, 'A');
    expect(repository.entryAt(2)!.level.id, 'C');
    expect(repository.entryAt(2)!.order, 3);
    expect(repository.entryAt(3)!.level.id, 'C');
    expect(repository.levelCount, 3);
    expect(repository.entryAt(4), isNull);
  });

  test('an entry the codec rejects is skipped too', () async {
    final repository = repositoryOf(
      _bundleJson([
        _entry(1, _level('A')),
        _entry(2, _level('B'), tier: 'impossible'),
      ]),
    );

    await repository.load();

    expect(repository.levelCount, 1);
    expect(repository.entryAt(2), isNull);
  });

  test('a trailing skipped level lowers levelCount', () async {
    final repository = repositoryOf(
      _bundleJson([
        _entry(1, _level('A')),
        _entry(
          2,
          _level(
            'B',
            nests: [
              ['red3', 'red2', 'red1'],
            ],
          ),
        ),
      ]),
    );

    await repository.load();

    expect(repository.levelCount, 1);
  });

  // CLAUDE.md rule 8: the 200-level bundle's decode and rules 1–7 are
  // several frames of work (57–75 ms AOT, 232–354 ms JIT on the dev Mac),
  // so the splash's UI isolate must not run them.
  group('off the UI isolate', () {
    test('the shipped bundle is decoded and checked on the worker isolate, '
        'not the caller\'s', () async {
      final repository = BundledLevelRepository();

      await repository.load();

      expect(repository.levelCount, 200);
      expect(repository.checkedOn, BundledLevelRepository.workerName);
      expect(repository.checkedOn, isNot(Isolate.current.debugName));
    });

    test('load hands the asset text to its checker once and plays what it '
        'returns', () async {
      final json = _bundleJson([
        _entry(1, _level('A')),
        _entry(2, _level('B')),
        _entry(3, _level('C')),
      ]);
      final texts = <String>[];
      final repository = BundledLevelRepository(
        bundle: _Bundle({BundledLevelRepository.bundleAsset: json}),
        checker: (text) async {
          texts.add(text);
          final checked = BundledLevelRepository.checkBundle(text);
          // Keeps only the first two: what plays comes from the checker.
          return CheckedLevelBundle(
            usable: true,
            playable: checked.playable.take(2).toList(),
            checkedOn: 'spy',
          );
        },
      );

      await repository.load();

      expect(texts, [json]);
      expect(repository.levelCount, 2);
      expect(repository.entryAt(3), isNull);
      expect(repository.checkedOn, 'spy');
    });

    test(
      'a checker that fails is a content error the splash can retry',
      () async {
        var calls = 0;
        final repository = BundledLevelRepository(
          bundle: _Bundle({
            BundledLevelRepository.bundleAsset: _bundleJson([
              _entry(1, _level('A')),
            ]),
          }),
          checker: (text) async {
            if (calls++ == 0) throw StateError('the worker died');
            return BundledLevelRepository.checkBundle(text);
          },
        );

        await expectLater(
          repository.load(),
          throwsA(
            isA<AppException>().having(
              (e) => e.kind,
              'kind',
              AppExceptionKind.content,
            ),
          ),
        );
        await repository.load();

        expect(repository.levelCount, 1);
        expect(calls, 2);
      },
    );
  });

  test('loads once; concurrent and later calls share it', () async {
    final bundle = _Bundle({
      BundledLevelRepository.bundleAsset: _bundleJson([_entry(1, _level('A'))]),
    });
    final repository = BundledLevelRepository(bundle: bundle);

    await Future.wait([repository.load(), repository.load()]);
    await repository.load();

    expect(bundle.reads, 1);
  });

  group('a bundle that fails entirely is a content error', () {
    Future<void> expectContentError(BundledLevelRepository repository) =>
        expectLater(
          repository.load(),
          throwsA(
            isA<AppException>().having(
              (e) => e.kind,
              'kind',
              AppExceptionKind.content,
            ),
          ),
        );

    test('missing', () async {
      await expectContentError(BundledLevelRepository(bundle: _Bundle({})));
    });

    test('not JSON', () async {
      await expectContentError(repositoryOf('{ nope'));
    });

    test('the wrong format', () async {
      await expectContentError(repositoryOf(jsonEncode({'format': 'other'})));
    });

    test('no playable level', () async {
      await expectContentError(
        repositoryOf(
          _bundleJson([
            _entry(
              1,
              _level(
                'B',
                nests: [
                  ['red3'],
                ],
              ),
            ),
          ]),
        ),
      );
    });

    test('and the splash can retry', () async {
      final bundle = _Bundle({});
      final repository = BundledLevelRepository(bundle: bundle);
      await expectContentError(repository);

      bundle.files[BundledLevelRepository.bundleAsset] = _bundleJson([
        _entry(1, _level('A')),
      ]);
      await repository.load();

      expect(repository.levelCount, 1);
      expect(bundle.reads, 2);
    });
  });
}
