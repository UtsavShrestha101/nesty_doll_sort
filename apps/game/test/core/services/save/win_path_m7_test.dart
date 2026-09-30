import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The M7 parts of the win's one save update (docs/plans/m7-design.md §7):
/// the replay's no-pay branch, the milestone chest, the best moves, the
/// records and the badges, and what the update reports back.
void main() {
  const chest10 = ChestGrant(
    source: ChestSource.campaign,
    number: 10,
    coins: 100,
    hints: 1,
  );

  FakeSaveService saveAt(int level, {int coins = 0}) => FakeSaveService(
    remoteConfig: FakeRemoteConfigService(),
    initial: SaveDocument(
      currentLevel: level,
      highestLevel: level,
      coins: coins,
      stats: const SaveStats(wins: 1),
      records: const SaveRecords(badges: ['first_family']),
    ),
  );

  test('a replay pays nothing, moves nothing and opens no chest, but keeps '
      'its best and its records', () {
    final save = saveAt(12, coins: 50);
    final before = save.document;
    final outcome = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.replay(10),
        // Whatever the record says, a replay pays 0 (spec-prop §7.1).
        rewardCoins: 25,
        moves: 14,
        completedChapterId: 'ch01',
        chapterReward: 150,
        chest: chest10,
        bestKey: 'L0010@1',
        families: 3,
        dolls: 6,
      ),
    );
    final after = save.document;
    expect(after.coins, 50);
    expect(after.currentLevel, before.currentLevel);
    expect(after.highestLevel, before.highestLevel);
    expect(after.museum, isEmpty);
    expect(after.chests, const ChestProgress());
    expect(after.inventory, before.inventory);
    expect(after.levelBests, {'L0010@1': 14});
    expect(after.records.families, 3);
    expect(after.records.dolls, 6);
    expect(after.stats.wins, 2);
    expect(outcome.chestPaid, isNull);
    expect(outcome.bestMoves, 14);
    expect(outcome.previousBest, isNull);
  });

  test('a replay board is never saved in progress, and never replaces the '
      "main line's board", () {
    final save = saveAt(12);
    const main = InProgressLevel(
      request: PlayRequest.campaign(12),
      levelId: 'L0012',
      levelVersion: 1,
      session: {'format': 1},
    );
    save
      ..saveInProgress(main)
      ..saveInProgress(
        const InProgressLevel(
          request: PlayRequest.replay(3),
          levelId: 'L0003',
          levelVersion: 1,
          session: {'format': 1},
        ),
      );
    expect(save.document.inProgress, main);
    expect(save.inProgressFor(PlayKind.replay), isNull);
    save.clearInProgress(PlayKind.replay);
    expect(save.document.inProgress, main);
  });

  test('the milestone chest is paid in the win and opens once per level '
      'number', () {
    final save = saveAt(10);
    final hints = save.boosterCount(BoosterKind.hint);
    final first = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.campaign(10),
        rewardCoins: 10,
        moves: 20,
        chest: chest10,
      ),
    );
    expect(first.chestPaid, chest10);
    expect(save.coins, 110);
    expect(save.boosterCount(BoosterKind.hint), hints + 1);
    expect(save.document.chests.opened, [10]);

    // The dev picker can bring L10 back: its chest never pays twice.
    save.currentLevel = 10;
    final again = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.campaign(10),
        rewardCoins: 10,
        moves: 20,
        chest: chest10,
      ),
    );
    expect(again.chestPaid, isNull);
    expect(save.coins, 120);
    expect(save.boosterCount(BoosterKind.hint), hints + 1);
  });

  test("a chest only pays on its own level's win", () {
    final save = saveAt(11);
    final outcome = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.campaign(11),
        rewardCoins: 10,
        chest: chest10,
      ),
    );
    expect(outcome.chestPaid, isNull);
    expect(save.document.chests, const ChestProgress());
  });

  test('bonus chests are kept apart from campaign ones', () {
    final save = saveAt(31);
    final outcome = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.bonus(10),
        rewardCoins: 10,
        chest: ChestGrant(
          source: ChestSource.bonus,
          number: 10,
          coins: 100,
          hints: 1,
        ),
      ),
    );
    expect(outcome.chestPaid?.number, 10);
    expect(save.document.chests, const ChestProgress(bonusOpened: [10]));
  });

  test('the best moves keep the fewest, and report the one before', () {
    final save = saveAt(5);
    LevelWinOutcome win(int moves) => save.recordLevelWin(
      LevelWinRecord(
        request: const PlayRequest.replay(3),
        rewardCoins: 0,
        moves: moves,
        bestKey: 'L0003@1',
      ),
    );
    expect(win(18), const LevelWinOutcome(bestMoves: 18));
    expect(win(16), const LevelWinOutcome(bestMoves: 16, previousBest: 18));
    expect(win(20), const LevelWinOutcome(bestMoves: 16, previousBest: 16));
    expect(save.bestMovesFor('L0003@1'), 16);
    expect(save.bestMovesFor('L0003@2'), isNull);
  });

  test('a daily win counts a newly solved date and the longest run', () {
    final save = saveAt(5);
    final today = LocalDate(2026, 9, 28);
    final outcome = save.recordLevelWin(
      LevelWinRecord(
        request: const PlayRequest.daily(20260928),
        rewardCoins: 50,
        moves: 12,
        daily: DailyProgress(
          streak: 7,
          lit: true,
          run: 7,
          lastDate: today,
          done: [today],
        ),
      ),
    );
    expect(save.document.records.dailies, 1);
    expect(save.document.records.longestRun, 7);
    // Generated boards keep no best.
    expect(outcome.bestMoves, isNull);
  });

  test('the badges a win earns come back once, in BadgeId order', () {
    final save = FakeSaveService(
      initial: const SaveDocument(
        currentLevel: 100,
        highestLevel: 100,
        records: SaveRecords(dailies: 6),
      ),
    );
    final outcome = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.campaign(100),
        rewardCoins: 50,
        families: 5,
        dolls: 20,
        boardBadges: [BadgeId.tallOrder, BadgeId.glassBreaker],
      ),
    );
    expect(outcome.newBadges, [
      BadgeId.firstFamily,
      BadgeId.glassBreaker,
      BadgeId.tallOrder,
      BadgeId.level100,
    ]);
    expect(save.document.records.earned, outcome.newBadges);

    save.currentLevel = 50;
    final again = save.recordLevelWin(
      const LevelWinRecord(
        request: PlayRequest.campaign(50),
        rewardCoins: 10,
        boardBadges: [BadgeId.tallOrder],
      ),
    );
    expect(again.newBadges, isEmpty);
  });

  test('load grants the badges the document implies, silently', () async {
    final save = FakeSaveService(
      initial: const SaveDocument(
        highestLevel: 7,
        currentLevel: 7,
        stats: SaveStats(wins: 6),
      ),
    );
    await save.load();
    expect(save.document.records.earned, [BadgeId.firstFamily]);
  });
}
