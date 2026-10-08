import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/default_level_resolver.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';
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
        FakeClock(),
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
          FakeClock(),
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

    test('a replay of a won level is its campaign board paying nothing and '
        'completing nothing (m7-design §6)', () async {
      save.currentLevel = 5; // L1–L4 won.
      final replay = await resolver.resolve(const PlayRequest.replay(3));
      final campaign = await resolver.resolve(const PlayRequest.campaign(3));
      expect(replay, isNotNull);
      expect(replay!.request, const PlayRequest.replay(3));
      expect(replay.level, campaign!.level);
      expect(replay.levelVersion, campaign.levelVersion);
      expect(replay.tier, campaign.tier);
      expect(replay.themeId, campaign.themeId);
      expect(replay.chapterId, 'ch01');
      expect(replay.rewardCoins, 0);
      // L3 completes ch01 as the campaign, never as a replay.
      expect(campaign.completesChapter, isTrue);
      expect(replay.completesChapter, isFalse);
      expect(resolver.next(const PlayRequest.replay(3)), isNull);
    });

    test('a level not won yet, or not in the bundle, never replays', () async {
      save.currentLevel = 3;
      expect(await resolver.resolve(const PlayRequest.replay(3)), isNull);
      expect(await resolver.resolve(const PlayRequest.replay(4)), isNull);
      expect(await resolver.resolve(const PlayRequest.replay(0)), isNull);
      save.currentLevel = 7;
      expect(await resolver.resolve(const PlayRequest.replay(99)), isNull);
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
        FakeClock(),
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
        FakeClock(),
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
        FakeClock(),
      );
      // A negative `levelCount` makes `bonusParams` build an out-of-range
      // level number, which throws; the resolver's catch-all turns that
      // into null rather than letting it escape (rule 3).
      expect(await failing.resolve(const PlayRequest.bonus(1)), isNull);
    });
  });

  group('race requests (m7-design P2.4, P2.13)', () {
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
        FakeClock(),
      );
    });

    test('generates rival 1’s board once the mode and the rival are open: '
        'the simulated tier, Generator.version, race_reward_1, the current '
        'chapter’s theme, no chapter', () async {
      // Past race_unlock_level (20) so the mode is open, then back in ch01
      // (`currentLevel`'s setter never lowers `highestLevel`), so the theme
      // reads the player's current chapter, not the highest reached.
      save.currentLevel = 25;
      save.currentLevel = 1;
      final entry = await resolver.resolve(
        const PlayRequest.race(rival: 1, raceNo: 1),
      );
      expect(entry, isNotNull);
      expect(entry!.request, const PlayRequest.race(rival: 1, raceNo: 1));
      expect(entry.levelVersion, Generator.version);
      expect(entry.rewardCoins, RemoteConfigKeys.raceReward1.defaultValue);
      expect(entry.themeId, 'ch01');
      expect(entry.chapterId, isNull);
      expect(entry.completesChapter, isFalse);
      expect(generator.calls, 1);
    });

    test('gives nothing, and generates nothing, while the mode is still '
        'locked (at or below race_unlock_level)', () async {
      save.currentLevel = 20; // highestLevel 20 is not > 20: still locked.
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 1, raceNo: 1)),
        isNull,
      );
      expect(generator.calls, 0);
    });

    test('gives nothing for a rival still locked in the save', () async {
      save.currentLevel = 25; // Open the mode…
      // …but only rival 1 is unlocked by default (RaceProgress.
      // defaultRivals).
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 2, raceNo: 1)),
        isNull,
      );
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 3, raceNo: 1)),
        isNull,
      );
      expect(generator.calls, 0);
    });

    test('gives nothing for a rival outside 1..3', () async {
      save.currentLevel = 25;
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 0, raceNo: 1)),
        isNull,
      );
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 4, raceNo: 1)),
        isNull,
      );
      expect(generator.calls, 0);
    });

    test('gives nothing for a raceNo of 0 or past maxRaceNo', () async {
      save.currentLevel = 25;
      expect(
        await resolver.resolve(const PlayRequest.race(rival: 1, raceNo: 0)),
        isNull,
      );
      expect(
        await resolver.resolve(
          const PlayRequest.race(
            rival: 1,
            raceNo: DifficultyCurve.maxRaceNo + 1,
          ),
        ),
        isNull,
      );
      expect(generator.calls, 0);
    });

    test('a Rematch (the same rival and raceNo) resolves the very same '
        'cached Level at once, without generating again', () async {
      save.currentLevel = 25;
      const request = PlayRequest.race(rival: 1, raceNo: 3);
      final first = await resolver.resolve(request);
      final second = await resolver.resolve(request);
      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(generator.calls, 1);
    });

    test('the board is at RaceRules.stageLevel of the highest level won '
        '(highestLevel - 1): a higher highestLevel makes a different '
        'board at the same rival and raceNo', () async {
      final atStage21 = FakeSaveService(
        initial: const SaveDocument(currentLevel: 22, highestLevel: 22),
      );
      final atStage41 = FakeSaveService(
        initial: const SaveDocument(currentLevel: 42, highestLevel: 42),
      );
      const request = PlayRequest.race(rival: 1, raceNo: 7);
      final low = await DefaultLevelResolver(
        levels,
        FakeLevelGeneratorService(),
        remoteConfig,
        atStage21,
        catalog,
        FakeClock(),
      ).resolve(request);
      final high = await DefaultLevelResolver(
        levels,
        FakeLevelGeneratorService(),
        remoteConfig,
        atStage41,
        catalog,
        FakeClock(),
      ).resolve(request);
      expect(low, isNotNull);
      expect(high, isNotNull);
      expect(low!.level, isNot(high!.level));

      // And it matches core's own params for that stage exactly.
      final direct = Generator.generateWithRetries(
        DifficultyCurve.raceParams(rival: 1, raceNo: 7, highestWonLevel: 21),
      );
      expect(low.level, (direct as GeneratorSuccess).level);
    });

    test('a generation failure resolves to null, never throws (the page '
        'then offers a retry)', () async {
      save.currentLevel = 25;
      final failingGenerator = _AlwaysFailingLevelGeneratorService();
      final failing = DefaultLevelResolver(
        levels,
        failingGenerator,
        remoteConfig,
        save,
        catalog,
        FakeClock(),
      );
      expect(
        await failing.resolve(const PlayRequest.race(rival: 1, raceNo: 1)),
        isNull,
      );
      expect(failingGenerator.calls, 1);
    });

    test('next is always null: the result offers Rematch and New race, '
        'never a next level', () {
      expect(
        resolver.next(const PlayRequest.race(rival: 1, raceNo: 1)),
        isNull,
      );
    });

    test('a race board is never restored from an in-progress save, even '
        'one hand-built with a race request: it is always freshly '
        'generated or cached (m7-design §6, P2.4)', () async {
      final withStrayInProgress = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 25,
          highestLevel: 25,
          // SaveDocument.inProgressOf(race) is always null regardless of
          // what inProgress holds, so this can never be read back as a
          // race in the first place — the resolver never sees it.
          inProgress: InProgressLevel(
            request: const PlayRequest.race(rival: 1, raceNo: 1),
            levelId: 'race-1-1',
            levelVersion: Generator.version,
            session: const {},
            level: LevelCodec.encode(FixtureLevels.entries().first.level),
            tier: Tier.easy,
          ),
        ),
      );
      expect(withStrayInProgress.inProgressFor(PlayKind.race), isNull);
      final withStray = DefaultLevelResolver(
        levels,
        FakeLevelGeneratorService(),
        remoteConfig,
        withStrayInProgress,
        catalog,
        FakeClock(),
      );
      final entry = await withStray.resolve(
        const PlayRequest.race(rival: 1, raceNo: 1),
      );
      expect(entry, isNotNull);
      // Freshly generated, not the embedded fixture level.
      expect(entry!.level, isNot(FixtureLevels.entries().first.level));
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

/// A [LevelGeneratorService] that fails every request, to exercise the
/// resolver's null-on-failure path without depending on a real seed
/// happening to fail (race-core's sweep found none in 1,500 boards).
final class _AlwaysFailingLevelGeneratorService
    implements LevelGeneratorService {
  int calls = 0;

  @override
  Future<GeneratedLevel?> generate(GeneratorParams params) async {
    calls++;
    return null;
  }

  @override
  void dispose() {}
}
