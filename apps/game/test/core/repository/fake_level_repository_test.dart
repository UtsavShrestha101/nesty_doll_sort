import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';

import '../../helpers/level_fixtures.dart';

void main() {
  test('serves its entries by play order', () async {
    final level = levelFrom(tutorialLevelJson);
    final repository = FakeLevelRepository(
      entries: [entryFor(level), entryFor(level, order: 2)],
    );
    await repository.load();

    expect(repository.levelCount, 2);
    expect(repository.entryAt(1)!.order, 1);
    expect(repository.entryAt(2)!.level, level);
    expect(repository.entryAt(3), isNull);
    expect(repository.entryAt(0), isNull);
  });

  test('is empty by default', () {
    final repository = FakeLevelRepository();
    expect(repository.levelCount, 0);
    expect(repository.entryAt(1), isNull);
  });

  test('the fake env plays levels 1–3 of the authored bundle', () async {
    final repository = FakeLevelRepository.fixtures();
    await repository.load();

    expect(repository.levelCount, 3);
    expect(
      [for (var order = 1; order <= 3; order++) repository.entryAt(order)!],
      everyElement(
        isA<LevelBundleEntry>().having((e) => e.chapterId, 'chapter', 'ch01'),
      ),
    );
    expect(repository.entryAt(1)!.level, levelFrom(tutorialLevelJson));
    expect(repository.entryAt(3)!.tier, Tier.medium);
    expect(repository.entryAt(4), isNull);
  });

  test('every fixture level passes the game loader\'s rules 1–7 and is '
      'solvable', () {
    for (final entry in FixtureLevels.entries()) {
      final report = Validator.validate(entry.level);
      expect(
        report.isValid,
        isTrue,
        reason: '${entry.level.id}: ${report.issues}',
      );
      expect(entry.rewardCoins, entry.tier.defaultRewardCoins);
    }
  });
}
