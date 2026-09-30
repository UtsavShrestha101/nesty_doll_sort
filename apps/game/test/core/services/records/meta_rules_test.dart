import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/services/chest/milestone_chest.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/records/badge_rules.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/records/records_summary.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

import '../../../helpers/level_fixtures.dart';

/// The M7 meta rules frozen by the phase-1 contracts (docs/plans/
/// m7-design.md §9, §11, §12): minimal cases; the meta-services lane owns
/// the full tables.
void main() {
  group('BadgeId', () {
    test('ids are unique and round-trip', () {
      final ids = BadgeId.values.map((badge) => badge.id).toList();
      expect(ids.toSet(), hasLength(12));
      for (final badge in BadgeId.values) {
        expect(BadgeId.tryFromId(badge.id), badge);
      }
      expect(BadgeId.tryFromId('from_the_future'), isNull);
    });
  });

  group('BadgeRules.forWonLevel', () {
    Level level(String json) => levelFrom(json);

    test('glass, ice that thaws, tall and grand boards', () {
      final plain = level('''
{"schemaVersion": 1, "id": "T1", "maxSize": 3, "shelves": [[
  {"type": "open", "nest": ["red3"]}, {"type": "open", "nest": ["red2"]},
  {"type": "open", "nest": ["red1"]}, {"type": "open", "nest": null}]]}
''');
      expect(BadgeRules.forWonLevel(plain), isEmpty);

      final glassAndIce = level('''
{"schemaVersion": 1, "id": "T2", "maxSize": 3, "shelves": [[
  {"type": "open", "nest": ["red3"]}, {"type": "open", "nest": ["red2"]},
  {"type": "locked", "unlockColor": "red", "nest": ["blue3"]},
  {"type": "open", "nest": ["red1"], "ice": 1},
  {"type": "open", "nest": ["blue2", "blue1"]}]]}
''');
      expect(BadgeRules.forWonLevel(glassAndIce), [
        BadgeId.glassBreaker,
        BadgeId.iceMelter,
      ]);
    });

    test('tallOrder from maxSize 5, grandNest only at maxSize 6', () {
      Level board(int maxSize) => level('''
{"schemaVersion": 1, "id": "T$maxSize", "maxSize": $maxSize, "shelves": [[
  {"type": "open", "nest": null}]]}
''');
      expect(BadgeRules.forWonLevel(board(4)), isEmpty);
      expect(BadgeRules.forWonLevel(board(5)), [BadgeId.tallOrder]);
      expect(BadgeRules.forWonLevel(board(6)), [
        BadgeId.tallOrder,
        BadgeId.grandNest,
      ]);
    });
  });

  group('BadgeRules.derivable', () {
    test('from the document alone', () {
      expect(BadgeRules.derivable(const SaveDocument()), isEmpty);
      expect(
        BadgeRules.derivable(
          SaveDocument(
            highestLevel: 201,
            stats: const SaveStats(wins: 1),
            records: const SaveRecords(dailies: 30),
            museum: [
              for (final chapter in BundledCatalogRepository.bundledChapters)
                chapter.id,
            ],
            race: const RaceProgress(
              rivals: [
                RivalProgress(unlocked: true, wins: 1),
                RivalProgress(unlocked: true, wins: 2),
                RivalProgress(unlocked: true, wins: 1),
              ],
            ),
          ),
        ),
        BadgeId.values.toSet().difference({
          BadgeId.glassBreaker,
          BadgeId.iceMelter,
          BadgeId.tallOrder,
          BadgeId.grandNest,
        }),
      );
    });

    test('level, dailies and rival thresholds are exact boundaries', () {
      expect(
        BadgeRules.derivable(const SaveDocument(highestLevel: 100)),
        isEmpty,
      );
      expect(
        BadgeRules.derivable(const SaveDocument(highestLevel: 101)),
        contains(BadgeId.level100),
      );
      expect(
        BadgeRules.derivable(const SaveDocument(highestLevel: 200)),
        isNot(contains(BadgeId.level200)),
      );
      expect(
        BadgeRules.derivable(const SaveDocument(highestLevel: 201)),
        contains(BadgeId.level200),
      );
      expect(
        BadgeRules.derivable(
          const SaveDocument(records: SaveRecords(dailies: 6)),
        ),
        isEmpty,
      );
      expect(
        BadgeRules.derivable(
          const SaveDocument(records: SaveRecords(dailies: 7)),
        ),
        contains(BadgeId.dailies7),
      );
      expect(
        BadgeRules.derivable(
          const SaveDocument(records: SaveRecords(dailies: 29)),
        ),
        isNot(contains(BadgeId.dailies30)),
      );
      expect(
        BadgeRules.derivable(
          const SaveDocument(records: SaveRecords(dailies: 30)),
        ),
        contains(BadgeId.dailies30),
      );
      // One rival win is enough for firstRace; allRivals needs every one.
      expect(
        BadgeRules.derivable(
          const SaveDocument(
            race: RaceProgress(
              rivals: [
                RivalProgress(unlocked: true, wins: 1),
                RivalProgress(),
                RivalProgress(),
              ],
            ),
          ),
        ),
        {BadgeId.firstRace},
      );
      expect(
        BadgeRules.derivable(
          const SaveDocument(
            race: RaceProgress(
              rivals: [
                RivalProgress(unlocked: true, wins: 1),
                RivalProgress(unlocked: true, wins: 2),
                RivalProgress(unlocked: true, wins: 3),
              ],
            ),
          ),
        ),
        {BadgeId.firstRace, BadgeId.allRivals},
      );
    });

    test('withDerivable adds only what is new, in BadgeId order', () {
      const doc = SaveDocument(
        stats: SaveStats(wins: 3),
        records: SaveRecords(dailies: 7, badges: ['dailies_7']),
      );
      expect(BadgeRules.withDerivable(doc).records.badges, [
        'dailies_7',
        'first_family',
      ]);
      final done = BadgeRules.withDerivable(doc);
      expect(BadgeRules.withDerivable(done), same(done));
    });
  });

  group('RecordRules', () {
    test('families and dolls nested of a won level', () {
      final level = levelFrom(tutorialLevelJson);
      expect(RecordRules.familiesIn(level), level.totalSets);
      expect(
        RecordRules.dollsNestedIn(level),
        level.totalSets * (level.maxSize - 1),
      );
    });

    test('levels won: campaign behind highestLevel, capped by the bundle, '
        'plus bonus levels', () {
      const doc = SaveDocument(
        currentLevel: 31,
        highestLevel: 31,
        bonus: BonusProgress(next: 4),
      );
      expect(RecordRules.levelsWon(doc, levelCount: 30), 33);
      expect(RecordRules.levelsWon(const SaveDocument(), levelCount: 30), 0);
    });

    test('LevelBests keys are <id>@<version>', () {
      expect(LevelBests.key('L0024', 2), 'L0024@2');
    });

    test('RecordsSummary reads the save', () {
      const doc = SaveDocument(
        highestLevel: 6,
        currentLevel: 6,
        records: SaveRecords(
          families: 9,
          dolls: 18,
          dailies: 2,
          longestRun: 2,
          badges: ['dailies_7', 'first_family'],
        ),
      );
      expect(
        RecordsSummary.of(doc, levelCount: 30, starLevels: 0),
        const RecordsSummary(
          levelsWon: 5,
          families: 9,
          dolls: 18,
          dailies: 2,
          longestRun: 2,
          badges: [BadgeId.firstFamily, BadgeId.dailies7],
        ),
      );
    });
  });

  group('MilestoneChest', () {
    final config = FakeRemoteConfigService();

    test('level 10 of each chapter and every 10th bonus level', () {
      final campaign = [
        for (var order = 1; order <= 200; order++)
          if (MilestoneChest.opensAtCampaign(order)) order,
      ];
      expect(campaign, [10, 30, 50, 70, 90, 110, 130, 150, 170, 190]);
      // "and on past the launch chapters" (m7-design §9): a chapter
      // published later keeps the same level-10 rule.
      expect(MilestoneChest.opensAtCampaign(210), isTrue);
      expect(MilestoneChest.opensAtCampaign(230), isTrue);
      expect(MilestoneChest.opensAtCampaign(209), isFalse);
      expect(MilestoneChest.opensAtCampaign(0), isFalse);
      expect(MilestoneChest.opensAtBonus(10), isTrue);
      expect(MilestoneChest.opensAtBonus(15), isFalse);
      expect(MilestoneChest.opensAtBonus(0), isFalse);
      expect(
        MilestoneChest.forWin(const PlayRequest.campaign(30), config),
        const ChestGrant(
          source: ChestSource.campaign,
          number: 30,
          coins: 100,
          hints: 1,
        ),
      );
      expect(
        MilestoneChest.forWin(const PlayRequest.replay(30), config),
        isNull,
      );
      expect(
        MilestoneChest.forWin(const PlayRequest.daily(20260930), config),
        isNull,
      );
    });

    test('contents come from Remote Config, never negative', () {
      final tuned = FakeRemoteConfigService()
        ..setOverride(RemoteConfigKeys.chestCoins, 250)
        ..setOverride(RemoteConfigKeys.chestHints, -2);
      expect(
        MilestoneChest.forWin(const PlayRequest.bonus(20), tuned),
        const ChestGrant(
          source: ChestSource.bonus,
          number: 20,
          coins: 250,
          hints: 0,
        ),
      );
    });

    test('the countdown shows while the chest is the nearer goal', () {
      expect(MilestoneChest.levelsToNext(const PlayRequest.campaign(7)), 3);
      expect(MilestoneChest.levelsToNext(const PlayRequest.campaign(29)), 1);
      // From position 10 on the figurine (position 20) is nearer.
      expect(MilestoneChest.levelsToNext(const PlayRequest.campaign(10)), null);
      expect(MilestoneChest.levelsToNext(const PlayRequest.campaign(20)), null);
      expect(MilestoneChest.levelsToNext(const PlayRequest.bonus(10)), 10);
      expect(MilestoneChest.levelsToNext(const PlayRequest.bonus(13)), 7);
      expect(MilestoneChest.levelsToNext(const PlayRequest.replay(7)), null);
    });
  });

  group('DailyProgress (m7-design §8)', () {
    final today = LocalDate(2026, 10, 4);

    test('paused: out with days counted', () {
      expect(const DailyProgress(streak: 5).paused, isTrue);
      expect(const DailyProgress().paused, isFalse);
      expect(const DailyProgress(streak: 5, lit: true, run: 2).paused, isFalse);
    });

    test('relit: the run restarted on a streak that had days, today', () {
      expect(
        DailyProgress(
          streak: 6,
          lit: true,
          run: 1,
          lastDate: today,
        ).relitOn(today),
        isTrue,
      );
      // A first solve starts a streak; it relights nothing.
      expect(
        DailyProgress(
          streak: 1,
          lit: true,
          run: 1,
          lastDate: today,
        ).relitOn(today),
        isFalse,
      );
      expect(
        DailyProgress(
          streak: 6,
          lit: true,
          run: 3,
          lastDate: today,
        ).relitOn(today),
        isFalse,
      );
      expect(
        DailyProgress(
          streak: 6,
          lit: true,
          run: 1,
          lastDate: today,
        ).relitOn(today.addDays(-1)),
        isFalse,
      );
    });
  });
}
