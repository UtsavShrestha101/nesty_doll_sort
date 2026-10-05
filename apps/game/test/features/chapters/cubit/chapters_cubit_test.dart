import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/chest/milestone_chest.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';

import '../../../helpers/level_fixtures.dart';

/// `ChaptersCubit` over the bundled 10-chapter catalog (docs/plans/
/// m7-design.md §11, §15.1): the header's overall "Level {level} of
/// {total}" fields (owner's simulator review, 2026-09-28, design request
/// I.4), each level's tier reaching its cell, and the D111 "never soon"
/// figurine-earned fix `ChapterSection` shares with `MuseumEntry`.
void main() {
  final catalog = FakeCatalogRepository();

  FakeLevelRepository levelsThrough(
    int lastOrder, {
    Tier Function(int order)? tierOf,
  }) {
    final level = levelFrom(tutorialLevelJson);
    return FakeLevelRepository(
      entries: [
        for (var order = 1; order <= lastOrder; order++)
          entryFor(level, order: order, tier: tierOf?.call(order) ?? Tier.easy),
      ],
    );
  }

  test('load reads currentLevel/totalLevels over the whole catalog (200 '
      'levels, 10 bundled chapters × 20), not just what the bundle has so '
      'far', () async {
    final save = FakeSaveService(
      initial: const SaveDocument(currentLevel: 41, highestLevel: 41),
    );
    final cubit = ChaptersCubit(save, levelsThrough(41), catalog);
    await cubit.load();
    final data = cubit.state.data!;

    expect(data.currentLevel, 41);
    expect(data.totalLevels, 200);
  });

  test('a cell is the chest exactly where MilestoneChest says: the 10th of '
      'every chapter, from the one rule', () async {
    final save = FakeSaveService(
      initial: const SaveDocument(currentLevel: 1, highestLevel: 1),
    );
    final cubit = ChaptersCubit(save, levelsThrough(200), catalog);
    await cubit.load();
    final cells = [
      for (final chapter in cubit.state.data!.chapters) ...chapter.levels,
    ];

    expect(cells, hasLength(200));
    for (final cell in cells) {
      expect(
        cell.isChest,
        MilestoneChest.opensAtCampaign(cell.order),
        reason: 'level ${cell.order}',
      );
    }
    expect(cells.where((c) => c.isChest).length, 10);
    await cubit.close();
  });

  test('a level\'s own tier reaches its cell, won and current alike', () async {
    final save = FakeSaveService(
      initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
    );
    final cubit = ChaptersCubit(
      save,
      levelsThrough(
        3,
        tierOf: (order) => switch (order) {
          1 => Tier.hard,
          2 => Tier.superhard,
          _ => Tier.easy,
        },
      ),
      catalog,
    );
    await cubit.load();
    final levels = cubit.state.data!.chapters.first.levels;

    expect(levels[0].status, ChapterLevelStatus.won);
    expect(levels[0].tier, Tier.hard);
    expect(levels[1].status, ChapterLevelStatus.current);
    expect(levels[1].tier, Tier.superhard);
  });

  test('D111: a chapter whose levels are all won never reads as not yet '
      'earned, even before `document.museum` catches up (the dev "Jump to '
      'a level" bug, the same fix `MuseumCubit` carries)', () async {
    // Chapters 1 and 2 (orders 1-40) are both fully played here, but only
    // chapter 1 was ever actually recorded in `museum` — the dev picker (or
    // anything else moving currentLevel/highestLevel without a normal win)
    // can leave it behind.
    final save = FakeSaveService(
      initial: const SaveDocument(
        currentLevel: 41,
        highestLevel: 41,
        museum: ['ch01'],
      ),
    );
    final cubit = ChaptersCubit(save, levelsThrough(41), catalog);
    await cubit.load();
    final chapters = cubit.state.data!.chapters;

    expect(chapters[0].figurineEarned, isTrue); // from `museum`, unchanged
    expect(chapters[1].allWon, isTrue);
    expect(
      chapters[1].figurineEarned,
      isTrue,
      reason: 'all 20 levels won: never reads as not yet earned',
    );
    expect(chapters[2].figurineEarned, isFalse); // not reached yet
  });

  group('phase 4: what the level card and the grid need', () {
    test(
      'a won level with a par carries its 3-star target (par + 20 %, '
      'rounded up); one without a par has none; a locked one has none',
      () async {
        final level = levelFrom(tutorialLevelJson);
        final levels = FakeLevelRepository(
          entries: [
            entryFor(level, order: 1, par: 10),
            entryFor(level, order: 2),
            entryFor(level, order: 3, par: 10),
          ],
        );
        final cubit = ChaptersCubit(
          FakeSaveService(
            initial: SaveDocument(
              currentLevel: 3,
              highestLevel: 3,
              levelStars: {level.id: 2},
            ),
          ),
          levels,
          catalog,
        );
        await cubit.load();
        final cells = cubit.state.data!.chapters.first.levels;
        // par 10 at the default star3_slack_pct 20: 10 + ceil(2.0) = 12.
        expect(cells[0].target, 12);
        expect(cells[1].target, isNull, reason: 'no par, no target');
        expect(cells[2].status, ChapterLevelStatus.current);
        expect(cells[2].target, isNull, reason: 'only a won level has one');
      },
    );

    test(
      'the tuned slack reaches the target (Remote Config, rule 6)',
      () async {
        final level = levelFrom(tutorialLevelJson);
        final config = FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.star3SlackPct, 50);
        final cubit = ChaptersCubit(
          FakeSaveService(
            initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
          ),
          FakeLevelRepository(entries: [entryFor(level, order: 1, par: 10)]),
          catalog,
          config,
        );
        await cubit.load();
        expect(cubit.state.data!.chapters.first.levels.first.target, 15);
      },
    );

    test('the 10th level of a chapter is the chest and the 20th the finale '
        '(also for a locked cell)', () async {
      final cubit = ChaptersCubit(
        FakeSaveService(
          initial: const SaveDocument(currentLevel: 12, highestLevel: 12),
        ),
        levelsThrough(12),
        catalog,
      );
      await cubit.load();
      final cells = cubit.state.data!.chapters[0].levels;
      expect(
        [
          for (final c in cells)
            if (c.isChest) c.order,
        ],
        [10],
      );
      expect(
        [
          for (final c in cells)
            if (c.isFinale) c.order,
        ],
        [20],
      );
      // A chapter that isn't in the bundle yet still marks its cells.
      expect(
        cubit.state.data!.chapters[1].levels
            .where((c) => c.isChest)
            .single
            .order,
        30,
      );
    });

    test('wonCount adds every won level; isCurrent and reached read the '
        'cells; perfect is every star of the chapter', () async {
      final level = levelFrom(tutorialLevelJson);
      final levels = FakeLevelRepository(
        entries: [
          for (var order = 1; order <= 22; order++)
            entryFor(level, order: order, par: 5),
        ],
      );
      final cubit = ChaptersCubit(
        FakeSaveService(
          initial: SaveDocument(
            currentLevel: 22,
            highestLevel: 22,
            levelStars: {level.id: 3},
          ),
        ),
        levels,
        catalog,
      );
      await cubit.load();
      final data = cubit.state.data!;
      expect(data.wonCount, 21);
      expect(data.chapters[0].isCurrent, isFalse);
      expect(data.chapters[1].isCurrent, isTrue);
      expect(data.chapters[2].reached, isFalse, reason: 'locked row');
      // The fixture shares one level id, so the 20 won cells of chapter 1
      // all read 3 stars: 60 of 60.
      expect(data.chapters[0].stars, 60);
      expect(data.chapters[0].starsPossible, 60);
      expect(data.chapters[0].perfect, isTrue);
      expect(data.chapters[1].perfect, isFalse);
      expect(data.chapters[0].firstLevel, 1);
      expect(data.chapters[0].lastLevel, 20);
    });
  });
}
