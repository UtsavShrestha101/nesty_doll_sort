import 'dart:convert';

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
}) => {
  'order': order,
  'chapterId': 'ch01',
  'tier': tier,
  'version': 1,
  'rewardCoins': 10,
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

  test(
    'the shipped bundle loads: 30 levels in play order (rootBundle)',
    () async {
      final repository = BundledLevelRepository();
      expect(repository.levelCount, 0);
      expect(repository.entryAt(1), isNull);

      await repository.load();

      expect(repository.levelCount, 30);
      for (var order = 1; order <= 30; order++) {
        final entry = repository.entryAt(order)!;
        expect(entry.order, order);
        expect(entry.level.id, 'L${order.toString().padLeft(4, '0')}');
      }
      expect(repository.entryAt(1)!.chapterId, 'ch01');
      expect(repository.entryAt(21)!.chapterId, 'ch02');
      expect(repository.entryAt(0), isNull);
      expect(repository.entryAt(31), isNull);
    },
  );

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
