import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/default_level_resolver.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// [count] entries of [chapterId] starting at [startOrder], cycling through
/// `FixtureLevels`' three valid levels so every entry is a real, loader-valid
/// board.
List<LevelBundleEntry> _chapterEntries(
  String chapterId,
  int startOrder,
  int count,
) {
  final base = FixtureLevels.entries();
  return [
    for (var i = 0; i < count; i++)
      LevelBundleEntry(
        order: startOrder + i,
        chapterId: chapterId,
        tier: base[i % base.length].tier,
        version: base[i % base.length].version,
        rewardCoins: base[i % base.length].rewardCoins,
        level: base[i % base.length].level,
      ),
  ];
}

ChapterInfo _chapter(String id, int number, {int levels = 3}) => ChapterInfo(
  id: id,
  number: number,
  themeId: id,
  levels: levels,
  figurine: FigurineInfo(
    id: id,
    number: number,
    artAsset: 'assets/museum/$id.png',
    lockedArtAsset: 'assets/museum/$id-locked.png',
  ),
);

void main() {
  late FakeSaveService save;
  late FakeRemoteConfigService remoteConfig;
  late FakeLevelGeneratorService generator;

  setUp(() {
    save = FakeSaveService();
    remoteConfig = FakeRemoteConfigService();
    generator = FakeLevelGeneratorService();
  });

  group('campaign requests', () {
    late FakeLevelRepository levels;
    late FakeCatalogRepository catalog;
    late DefaultLevelResolver resolver;

    setUp(() {
      levels = FakeLevelRepository(
        entries: [
          ..._chapterEntries('ch01', 1, 3),
          ..._chapterEntries('ch02', 4, 3),
        ],
      );
      catalog = FakeCatalogRepository(
        chapters: [_chapter('ch01', 1), _chapter('ch02', 2)],
      );
      resolver = DefaultLevelResolver(
        levels,
        generator,
        remoteConfig,
        save,
        catalog,
      );
    });

    test('resolves the bundle entry, paid winRewardFor its tier, in its '
        'chapter theme', () async {
      final entry = await resolver.resolve(const PlayRequest.campaign(2));
      final bundle = FixtureLevels.entries()[1];
      expect(entry, isNotNull);
      expect(entry!.level, bundle.level);
      expect(entry.tier, bundle.tier);
      expect(entry.levelVersion, bundle.version);
      expect(entry.rewardCoins, RemoteConfigKeys.rewardEasy.defaultValue);
      expect(entry.chapterId, 'ch01');
      expect(entry.themeId, 'ch01');
      expect(entry.completesChapter, isFalse);
    });

    test('past the last published level resolves to null', () async {
      expect(await resolver.resolve(const PlayRequest.campaign(99)), isNull);
      expect(await resolver.resolve(const PlayRequest.campaign(0)), isNull);
    });

    test('completesChapter when the next entry is another chapter', () async {
      final l3 = await resolver.resolve(const PlayRequest.campaign(3));
      expect(l3!.completesChapter, isTrue);
      final l1 = await resolver.resolve(const PlayRequest.campaign(1));
      expect(l1!.completesChapter, isFalse);
    });

    test('completesChapter when there is no next entry and the chapter '
        'reaches its ChapterInfo.levels (D72)', () async {
      final l6 = await resolver.resolve(const PlayRequest.campaign(6));
      expect(l6!.completesChapter, isTrue);
    });

    test(
      'never completes a chapter that is not fully loaded yet, even at '
      'the very end of the bundle (D72: ch02 with 10 of 20 levels)',
      () async {
        final partial = DefaultLevelResolver(
          FakeLevelRepository(
            entries: [
              ..._chapterEntries('ch01', 1, 3),
              ..._chapterEntries('ch02', 4, 2),
            ],
          ),
          generator,
          remoteConfig,
          FakeSaveService(),
          catalog,
        );
        final last = await partial.resolve(const PlayRequest.campaign(5));
        expect(last!.completesChapter, isFalse);
      },
    );

    test('next follows the bundle, then Bonus Endless past the last level', () {
      expect(
        resolver.next(const PlayRequest.campaign(3)),
        const PlayRequest.campaign(4),
      );
      expect(
        resolver.next(const PlayRequest.campaign(6)),
        const PlayRequest.bonus(1),
      );
      expect(
        resolver.next(const PlayRequest.bonus(4)),
        const PlayRequest.bonus(5),
      );
      expect(resolver.next(const PlayRequest.daily(20260926)), isNull);
    });

    test('homeRequest is the saved currentLevel, else Bonus Endless', () {
      expect(resolver.homeRequest, const PlayRequest.campaign(1));
      save.currentLevel = 6;
      expect(resolver.homeRequest, const PlayRequest.campaign(6));
      save.currentLevel = 7;
      expect(resolver.homeRequest, const PlayRequest.bonus(1));
    });
  });

  group('generated requests (bonus, daily)', () {
    late FakeLevelRepository levels;
    late FakeCatalogRepository catalog;
    late DefaultLevelResolver resolver;

    setUp(() {
      levels = FakeLevelRepository(
        entries: [
          ..._chapterEntries('ch01', 1, 3),
          ..._chapterEntries('ch02', 4, 3),
        ],
      );
      catalog = FakeCatalogRepository(
        chapters: [_chapter('ch01', 1), _chapter('ch02', 2)],
      );
      resolver = DefaultLevelResolver(
        levels,
        generator,
        remoteConfig,
        save,
        catalog,
      );
    });

    test('a bonus level is generated, priced by its simulated tier, themed '
        'on the last published chapter', () async {
      final entry = await resolver.resolve(const PlayRequest.bonus(1));
      expect(entry, isNotNull);
      expect(entry!.request, const PlayRequest.bonus(1));
      expect(entry.chapterId, isNull);
      expect(entry.themeId, 'ch02');
      expect(entry.levelVersion, Generator.version);
      expect(generator.calls, 1);
    });

    test('a daily level is generated, themed on the player’s current '
        'chapter', () async {
      save.currentLevel = 1; // in ch01
      final entry = await resolver.resolve(const PlayRequest.daily(20260926));
      expect(entry, isNotNull);
      expect(entry!.rewardCoins, RemoteConfigKeys.dailyReward.defaultValue);
      expect(entry.themeId, 'ch01');
    });

    test(
      'a daily date that does not exist resolves to null, never throws',
      () async {
        expect(
          await resolver.resolve(const PlayRequest.daily(20260230)),
          isNull,
        );
      },
    );

    test('generated entries are cached: a second resolve reuses the same '
        'entry without generating again', () async {
      final first = await resolver.resolve(const PlayRequest.bonus(2));
      final second = await resolver.resolve(const PlayRequest.bonus(2));
      expect(identical(first, second), isTrue);
      expect(generator.calls, 1);
    });

    test(
      'prefetch starts one generation and a later resolve joins it',
      () async {
        resolver.prefetch(const PlayRequest.bonus(3));
        final resolved = await resolver.resolve(const PlayRequest.bonus(3));
        expect(resolved, isNotNull);
        expect(generator.calls, 1);
      },
    );

    test('restores a generated board from its embedded level JSON without '
        'generating again', () async {
      final embedded = FixtureLevels.entries().first.level;
      save.saveInProgress(
        InProgressLevel(
          request: const PlayRequest.bonus(4),
          levelId: embedded.id,
          levelVersion: Generator.version,
          session: const {},
          level: LevelCodec.encode(embedded),
          tier: Tier.easy,
        ),
      );

      final entry = await resolver.resolve(const PlayRequest.bonus(4));

      expect(entry, isNotNull);
      expect(entry!.level, embedded);
      expect(entry.tier, Tier.easy);
      expect(generator.calls, 0);
    });

    test('a board embedded by an older generator is regenerated, not '
        'replayed and re-stamped with the new version (spec §7.5 same daily '
        'for everyone; CORRECTNESS-5)', () async {
      final embedded = FixtureLevels.entries().first.level;
      const request = PlayRequest.daily(20260926);
      save.saveInProgress(
        InProgressLevel(
          request: request,
          levelId: embedded.id,
          levelVersion: Generator.version - 1,
          session: const {},
          level: LevelCodec.encode(embedded),
          tier: Tier.easy,
        ),
      );

      final entry = await resolver.resolve(request);

      expect(entry, isNotNull);
      expect(generator.calls, 1);
      expect(entry!.level, isNot(embedded));
      expect(entry.levelVersion, Generator.version);
      final fresh = DefaultLevelResolver(
        levels,
        FakeLevelGeneratorService(),
        remoteConfig,
        FakeSaveService(),
        catalog,
      );
      expect(entry.level, (await fresh.resolve(request))!.level);
    });

    test('a restore of the wrong request, or missing its level, regenerates '
        'instead of restoring', () async {
      save.saveInProgress(
        const InProgressLevel(
          request: PlayRequest.bonus(6),
          levelId: 'x',
          levelVersion: Generator.version,
          session: {},
          tier: Tier.easy, // No embedded level: not a generated board.
        ),
      );

      final entry = await resolver.resolve(const PlayRequest.bonus(5));

      expect(entry, isNotNull);
      expect(generator.calls, 1);
    });

    test('a generation failure resolves to null, never throws', () async {
      final failing = DefaultLevelResolver(
        _AlwaysFailingLevelRepository(),
        generator,
        remoteConfig,
        save,
        catalog,
      );
      // A negative `levelCount` makes `bonusParams` build an out-of-range
      // level number, which throws; the resolver's catch-all turns that
      // into null rather than letting it escape (rule 3).
      expect(await failing.resolve(const PlayRequest.bonus(1)), isNull);
    });
  });
}

/// A [LevelRepository] whose `levelCount` makes `DifficultyCurve.bonusParams`
/// throw, to exercise the generator-failure path.
final class _AlwaysFailingLevelRepository implements LevelRepository {
  @override
  Future<void> load() async {}

  @override
  int get levelCount => -5;

  @override
  LevelBundleEntry? entryAt(int order) => null;
}
