import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../helpers/level_fixtures.dart';

final Level _level = levelFrom(tutorialLevelJson);

/// M2's bundle shape (D35): ch01 is levels 1–20, ch02 is 21–30.
FakeLevelRepository _bundle() => FakeLevelRepository(
  entries: [
    for (var order = 1; order <= 30; order++)
      entryFor(_level, order: order, chapterId: order <= 20 ? 'ch01' : 'ch02'),
  ],
);

/// A bundle whose level 3 was skipped (spec §5.3): `entryAt(3)` returns
/// the next playable level, as `BundledLevelRepository` does.
final class _SkippingRepository implements LevelRepository {
  _SkippingRepository(this._inner);

  final FakeLevelRepository _inner;

  @override
  int get levelCount => _inner.levelCount;

  @override
  Future<void> load() => _inner.load();

  @override
  LevelBundleEntry? entryAt(int order) =>
      order == 3 ? _inner.entryAt(4) : _inner.entryAt(order);
}

void main() {
  final levels = _bundle();
  ChapterProgress at(int order, [LevelRepository? repository]) =>
      ChapterProgress.of(levels.entryAt(order)!, repository ?? levels);

  test('counts a level in its chapter from the bundle (frame 2.8)', () {
    expect(
      at(16),
      const ChapterProgress(
        chapterId: 'ch01',
        number: 1,
        done: 16,
        total: 20,
        isFirstLevel: false,
      ),
    );
    expect(at(16).fraction, closeTo(0.8, 1e-9));
    expect(at(16).isComplete, isFalse);
    expect(at(20).isComplete, isTrue);
  });

  test('L21 opens ch02 with the ribbon (frame 4.7); L1 opens without', () {
    final l21 = at(21);
    expect(l21.chapterId, 'ch02');
    expect(l21.number, 2);
    expect(l21.done, 1);
    expect(l21.total, 10);
    expect(l21.isFirstLevel, isTrue);
    expect(l21.opensWithRibbon, isTrue);
    expect(l21.theme, ChapterTheme.ch02);

    final l1 = at(1);
    expect(l1.isFirstLevel, isTrue);
    expect(l1.opensWithRibbon, isFalse, reason: 'the tutorial opens ch01');
    expect(at(22).opensWithRibbon, isFalse);
  });

  test('the museum figurine follows the chapter number', () {
    expect(at(1).figurineId, 'classic');
    expect(at(21).figurineId, 'sailor');
  });

  test('a skipped level still counts in its chapter', () {
    final progress = at(5, _SkippingRepository(levels));
    expect(progress.done, 5);
    expect(progress.total, 20);
  });

  test('chapter numbers come from the id', () {
    expect(ChapterProgress.numberOf('ch02'), 2);
    expect(ChapterProgress.numberOf('ch10'), 10);
    expect(ChapterProgress.numberOf('bonus'), 1);
    expect(ChapterProgress.numberOf('ch00'), 1);
  });
}
