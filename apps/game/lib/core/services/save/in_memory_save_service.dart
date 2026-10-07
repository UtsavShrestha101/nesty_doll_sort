import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart' show DifficultyCurve, StarRating;
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/records/badge_rules.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The [SaveService] rules over a [SaveDocument] held in memory
/// (docs/plans/m3-design.md §3). Every launch starts as a fresh install:
/// level 1, 0 coins, the starter boosters (spec §8, Q46).
///
/// It is the base of `FakeSaveService` (tests, the fake env) and of the
/// persistent `HiveSaveService` (the real env, m3-design §3.2), which loads
/// the document in [load] and overrides [persist] to queue a write after
/// each change. In the dev flavor boosters are unlimited (BACKLOG M2).
///
/// Not bound by DI itself: `HiveSaveService` and `FakeSaveService` each
/// carry their own `@LazySingleton`.
class InMemorySaveService implements SaveService {
  InMemorySaveService(
    this._remoteConfig, {
    @ignoreParam bool? unlimitedBoosters,
    @ignoreParam SaveDocument? initial,
  }) : _unlimitedOverride = unlimitedBoosters,
       _document = initial ?? const SaveDocument();

  final RemoteConfigService _remoteConfig;
  final bool? _unlimitedOverride;
  late final bool _flavorUnlimited = _unlimitedOverride ?? _isDevFlavor();
  bool? _debugUnlimited;
  bool get _unlimited => _debugUnlimited ?? _flavorUnlimited;

  /// Debug builds only: overrides the flavor's unlimited boosters (null
  /// goes back to it), so `integration_test/playthrough_test.dart` can
  /// reach the coin-priced booster rows and the booster popup on the dev
  /// flavor it drives (README "Testing"). Profile and release builds
  /// ignore it.
  @visibleForTesting
  set debugUnlimitedBoosters(bool? value) {
    if (kDebugMode) _debugUnlimited = value;
  }

  final StreamController<void> _changes = StreamController.broadcast();
  SaveDocument _document;
  Future<void>? _loading;

  @override
  SaveDocument get document => _document;

  /// Replaces the whole document without a [persist] (what [load] read).
  /// Fires [changes] when it differs.
  @protected
  void adopt(SaveDocument document) {
    if (document == _document) return;
    _document = document;
    _notify();
  }

  /// Called after every change with the new document. In memory: nothing.
  @protected
  void persist(SaveDocument document) {}

  /// Applies [change]; a change that leaves the document equal does
  /// nothing.
  @protected
  void update(SaveDocument Function(SaveDocument current) change) {
    final next = change(_document);
    if (next == _document) return;
    _document = next;
    persist(next);
    _notify();
  }

  @override
  Future<void> load() => _loading ??= loadDocument();

  /// [load]'s body, run once. In memory: gives a fresh install its player
  /// id and grants the badges the document already implies
  /// ([BadgeRules.withDerivable], silently, m7-design §12).
  @protected
  Future<void> loadDocument() async {
    update(
      (d) => BadgeRules.withDerivable(
        d.playerId == null ? d.copyWith(playerId: newPlayerId()) : d,
      ),
    );
  }

  /// A new random Player ID, `7F3A-21C9` (frame 8.1; m3-design §3.1). App
  /// code, so `Random.secure()` is fine here (rule 7 binds nesty_core).
  static String newPlayerId([math.Random? random]) {
    final r = random ?? math.Random.secure();
    String group() =>
        r.nextInt(0x10000).toRadixString(16).toUpperCase().padLeft(4, '0');
    return '${group()}-${group()}';
  }

  // --- Progress ---------------------------------------------------------

  @override
  int get currentLevel => _document.currentLevel;

  @override
  set currentLevel(int level) {
    RangeError.checkValueInInterval(level, 1, 1 << 30, 'level');
    update(
      (d) => d.copyWith(
        currentLevel: level,
        highestLevel: math.max(d.highestLevel, level),
      ),
    );
  }

  @override
  int get highestLevel => _document.highestLevel;

  @override
  int get nextBonus => _document.bonus.next;

  // --- Wallet -------------------------------------------------------------

  @override
  int get coins => _document.coins;

  @override
  void addCoins(int amount) {
    RangeError.checkNotNegative(amount, 'amount');
    if (amount == 0) return;
    update((d) => d.copyWith(coins: d.coins + amount));
  }

  @override
  bool spendCoins(int amount) {
    RangeError.checkNotNegative(amount, 'amount');
    if (amount > _document.coins) return false;
    if (amount == 0) return true;
    update((d) => d.copyWith(coins: d.coins - amount));
    return true;
  }

  @override
  int boosterCount(BoosterKind kind) => _document.inventory.of(kind);

  @override
  bool useBooster(BoosterKind kind) {
    if (_unlimited) return true;
    final held = _document.inventory.of(kind);
    if (held == 0) return false;
    update((d) => d.copyWith(inventory: d.inventory.withCount(kind, held - 1)));
    return true;
  }

  @override
  void addBoosters(BoosterKind kind, int count) {
    RangeError.checkNotNegative(count, 'count');
    if (count == 0) return;
    update(
      (d) => d.copyWith(
        inventory: d.inventory.withCount(kind, d.inventory.of(kind) + count),
      ),
    );
  }

  @override
  int get freeUndosPerLevel {
    final value = _remoteConfig.value(RemoteConfigKeys.freeUndosPerLevel);
    // A negative tuned value would read as "owes undos"; treat it as none.
    return value < 0 ? 0 : value;
  }

  @override
  bool get unlimitedBoosters => _unlimited;

  @override
  void recordBoosterUse(BoosterType type) => update((d) {
    final used = Map<String, int>.of(d.stats.boostersUsed);
    used[type.id] = (used[type.id] ?? 0) + 1;
    return d.copyWith(stats: d.stats.copyWith(boostersUsed: used));
  });

  // --- Wins -----------------------------------------------------------------

  @override
  void recordWin({required int levelOrder, required int rewardCoins}) =>
      recordLevelWin(
        LevelWinRecord(
          request: PlayRequest.campaign(levelOrder),
          rewardCoins: rewardCoins,
        ),
      );

  @override
  LevelWinOutcome recordLevelWin(LevelWinRecord win) {
    RangeError.checkNotNegative(win.rewardCoins, 'rewardCoins');
    RangeError.checkNotNegative(win.chapterReward, 'chapterReward');
    final request = win.request;
    // A race's win is recordRaceWin's (m7-design P2.7): nothing here.
    if (request is RacePlay) return const LevelWinOutcome();
    RangeError.checkValueInInterval(request.number, 1, 99991231, 'request');
    var outcome = const LevelWinOutcome();
    update((d) {
      // A replay pays nothing (spec-prop §7.1): the resolver already says
      // 0, and the save holds to it whatever the record carries.
      final replay = request is ReplayPlay;
      var next = d.copyWith(
        coins: d.coins + (replay ? 0 : win.rewardCoins),
        stats: d.stats.copyWith(
          wins: d.stats.wins + 1,
          moves: d.stats.moves + math.max(0, win.moves),
        ),
      );
      switch (request) {
        case CampaignPlay(:final order):
          final level = math.max(next.currentLevel, order + 1);
          next = next.copyWith(
            currentLevel: level,
            highestLevel: math.max(next.highestLevel, level),
            inProgress: next.inProgressOf(PlayKind.campaign)?.request == request
                ? null
                : next.inProgress,
          );
          final chapter = win.completedChapterId;
          if (chapter != null && !next.museum.contains(chapter)) {
            next = next.copyWith(
              coins: next.coins + win.chapterReward,
              museum: [...next.museum, chapter],
              museumCollected: {...next.museumCollected, chapter: ?win.date},
            );
          }
        case BonusPlay(:final number):
          next = next.copyWith(
            bonus: next.bonus.copyWith(
              next: math.max(next.bonus.next, number + 1),
            ),
            inProgress: next.inProgressOf(PlayKind.bonus)?.request == request
                ? null
                : next.inProgress,
          );
        case DailyPlay(:final yyyymmdd):
          var daily = win.daily ?? next.daily;
          // A solve adds at most one date; one `done` lacked before is a
          // daily solved for the first time (m7-design §12).
          final solvedNew = daily.done.any(
            (date) => !d.daily.done.contains(date),
          );
          // The Share text's facts and the reminder offer's hour
          // (m7-design P3.4): only a first solve of the date replaces it,
          // and only this path writes it (the record's `daily` never
          // does).
          daily = daily.copyWith(
            lastSolve: solvedNew
                ? DailySolve(
                    date: LocalDate.fromYyyymmdd(yyyymmdd),
                    moves: math.max(0, win.moves),
                    families: math.max(0, win.families),
                    minuteOfDay: _minuteOrNull(win.minuteOfDay),
                  )
                : d.daily.lastSolve,
          );
          next = next.copyWith(
            daily: daily.inProgress?.request == request
                ? daily.copyWith(inProgress: null)
                : daily,
            records: next.records.copyWith(
              dailies: next.records.dailies + (solvedNew ? 1 : 0),
              longestRun: math.max(next.records.longestRun, daily.run),
            ),
          );
        case ReplayPlay():
          // No progress, museum or chapter reward (spec-prop §7.1), and
          // nothing in progress to clear: a replay is never saved (§6).
          break;
        case RacePlay():
          // Unreachable: returned above.
          break;
      }

      // The milestone chest, once per level number and never on a replay
      // (m7-design §9): only the chest of this very request is paid.
      final chest = win.chest;
      ChestGrant? paid;
      if (chest != null &&
          !replay &&
          _chestBelongsTo(chest, request) &&
          !next.chests.hasOpened(chest)) {
        paid = chest;
        next = next.copyWith(
          coins: next.coins + math.max(0, chest.coins),
          inventory: next.inventory.withCount(
            BoosterKind.hint,
            next.inventory.hint + math.max(0, chest.hints),
          ),
          chests: next.chests.withOpened(chest),
        );
      }

      // Best moves, bundled boards only (m7-design §11).
      int? best;
      int? previous;
      final key = win.bestKey;
      if (key != null &&
          key.isNotEmpty &&
          request.isBundled &&
          win.moves >= 1) {
        previous = next.levelBests[key];
        best = previous == null ? win.moves : math.min(previous, win.moves);
        if (best != previous) {
          next = next.copyWith(levelBests: {...next.levelBests, key: best});
        }
      }

      // Best stars, bundled boards only (spec-prop §7.10; m7-design P3.4):
      // the highest ever, never lowered; the one-time tip on the first win
      // below 3 stars (Q119). Nothing else reads stars.
      int? bestStars;
      int? previousStars;
      var showStarTip = false;
      final starsKey = win.starsKey;
      final stars = win.stars;
      if (starsKey != null &&
          starsKey.isNotEmpty &&
          stars != null &&
          stars >= StarRating.minStars &&
          stars <= StarRating.maxStars &&
          request.isBundled) {
        previousStars = next.levelStars[starsKey];
        bestStars = math.max(previousStars ?? 0, stars);
        if (bestStars != previousStars) {
          next = next.copyWith(
            levelStars: {...next.levelStars, starsKey: bestStars},
          );
        }
        // The card marks it shown (`markStarTipShown`) once it had room
        // for it; a capped win shows the helper note instead (Q145).
        showStarTip =
            stars < StarRating.maxStars &&
            !win.starsCapped &&
            !next.starTipShown;
      }

      // Records and badges (m7-design §12).
      next = next.copyWith(
        records: next.records.copyWith(
          families: next.records.families + math.max(0, win.families),
          dolls: next.records.dolls + math.max(0, win.dolls),
        ),
      );
      final List<BadgeId> fresh;
      (next, fresh) = _withWinBadges(next, win.boardBadges);

      outcome = LevelWinOutcome(
        bestMoves: best,
        previousBest: previous,
        chestPaid: paid,
        newBadges: fresh,
        stars: bestStars,
        previousStars: previousStars,
        showStarTip: showStarTip,
      );
      return next;
    });
    return outcome;
  }

  /// [minute] when it is a minute of the day (0–1439), else null.
  static int? _minuteOrNull(int? minute) =>
      minute != null && minute >= 0 && minute < 24 * 60 ? minute : null;

  @override
  void markStarTipShown() {
    try {
      if (document.starTipShown) return;
      update((d) => d.starTipShown ? d : d.copyWith(starTipShown: true));
    } on Object catch (error, stack) {
      // Rule 3: the tip may show once more; nothing else is at stake.
      developer.log(
        'marking the star tip shown failed',
        name: 'nesty.save',
        error: error,
        stackTrace: stack,
      );
    }
  }

  @override
  int backfillLevelStars(LevelRepository levels) {
    try {
      final slack = StarRules.slackOf(_remoteConfig);
      var given = 0;
      update((d) {
        Map<String, int>? stars;
        for (var order = 1; order < d.highestLevel; order++) {
          final entry = levels.entryAt(order);
          // Past the bundle: nothing more was won from it.
          if (entry == null) break;
          // A skipped (invalid) level resolves to its successor: only the
          // level at exactly this order was won here.
          if (entry.order != order) continue;
          final par = entry.par;
          if (par == null) continue;
          final id = entry.level.id;
          if ((stars ?? d.levelStars).containsKey(id)) continue;
          final best = d.levelBests[LevelBests.key(id, entry.version)];
          (stars ??= {...d.levelStars})[id] = StarRules.backfill(
            par: par,
            best: best,
            slack: slack,
          );
          given++;
        }
        return stars == null ? d : d.copyWith(levelStars: stars);
      });
      return given;
    } on Object catch (error, stack) {
      // Rule 3: stars are cosmetic, so a failure here costs nothing but
      // the stars; the next launch tries again.
      developer.log(
        'the star backfill failed',
        name: 'nesty.save',
        error: error,
        stackTrace: stack,
      );
      return 0;
    }
  }

  /// [next] with the badges a win earns appended, and those badges
  /// (m7-design §12): the won board's own plus the ones derivable from
  /// [next], the document after the win's other steps, each only once.
  /// Both win paths share it ([recordLevelWin], [recordRaceWin]).
  static (SaveDocument, List<BadgeId>) _withWinBadges(
    SaveDocument next,
    List<BadgeId> boardBadges,
  ) {
    final fresh = BadgeRules.newlyEarned({
      ...boardBadges,
      ...BadgeRules.derivable(next),
    }, next.records);
    if (fresh.isEmpty) return (next, fresh);
    return (
      next.copyWith(
        records: next.records.copyWith(
          badges: [...next.records.badges, for (final b in fresh) b.id],
        ),
      ),
      fresh,
    );
  }

  // --- vs Computer (spec-prop §7.7; m7-design P2.7) ---------------------------

  @override
  int? beginRace(int rival) {
    if (rival < 1 || rival > RaceProgress.rivalCount) return null;
    final current = _document.race.rivals[rival - 1];
    if (!current.unlocked) return null;
    // At the cap the raceNo stays, so New race replays the last board
    // (the default of an owner question, m7-design P2.14).
    final raceNo = math.min(current.raceNo + 1, DifficultyCurve.maxRaceNo);
    update(
      (d) => d.copyWith(
        race: d.race.copyWith(
          rivals: [
            for (var i = 0; i < d.race.rivals.length; i++)
              i == rival - 1
                  ? d.race.rivals[i].copyWith(raceNo: raceNo)
                  : d.race.rivals[i],
          ],
        ),
      ),
    );
    return raceNo;
  }

  @override
  RaceWinOutcome recordRaceWin(RaceWinRecord win) {
    RangeError.checkValueInInterval(
      win.rival,
      1,
      RaceProgress.rivalCount,
      'rival',
    );
    RangeError.checkValueInInterval(
      win.raceNo,
      1,
      DifficultyCurve.maxRaceNo,
      'raceNo',
    );
    RangeError.checkNotNegative(win.rewardCoins, 'rewardCoins');
    var outcome = const RaceWinOutcome();
    update((d) {
      final index = win.rival - 1;
      final rivals = [...d.race.rivals];
      rivals[index] = rivals[index].copyWith(wins: rivals[index].wins + 1);
      // Spec-prop §7.7: "the first win against one unlocks the next".
      int? unlocked;
      if (index + 1 < rivals.length && !rivals[index + 1].unlocked) {
        rivals[index + 1] = rivals[index + 1].copyWith(unlocked: true);
        unlocked = index + 2;
      }
      var next = d.copyWith(
        coins: d.coins + win.rewardCoins,
        race: d.race.copyWith(rivals: rivals),
        stats: d.stats.copyWith(
          wins: d.stats.wins + 1,
          moves: d.stats.moves + math.max(0, win.moves),
        ),
        records: d.records.copyWith(
          families: d.records.families + math.max(0, win.families),
          dolls: d.records.dolls + math.max(0, win.dolls),
        ),
      );
      final List<BadgeId> fresh;
      (next, fresh) = _withWinBadges(next, win.boardBadges);
      outcome = RaceWinOutcome(
        coins: win.rewardCoins,
        unlockedRival: unlocked,
        wins: rivals[index].wins,
        newBadges: fresh,
      );
      return next;
    });
    return outcome;
  }

  /// [chest] is the one [request]'s own win reaches: a record can't pay
  /// another level's chest.
  static bool _chestBelongsTo(ChestGrant chest, PlayRequest request) =>
      switch ((chest.source, request)) {
        (ChestSource.campaign, CampaignPlay(:final order)) =>
          order == chest.number,
        (ChestSource.bonus, BonusPlay(:final number)) => number == chest.number,
        _ => false,
      };

  @override
  int? bestMovesFor(String levelKey) => _document.levelBests[levelKey];

  // --- In progress ------------------------------------------------------------

  @override
  InProgressLevel? inProgressFor(PlayKind kind) => _document.inProgressOf(kind);

  @override
  void saveInProgress(InProgressLevel level) {
    // A replay loses nothing on a kill, so it is never saved (m7-design
    // §6), and it must never replace the main line's board. A race is never
    // resumed (spec-prop §7.7 "Save"; m7-design P2.4).
    if (level.request.isReplay || level.request.isRace) return;
    update(
      (d) => level.request.kind == PlayKind.daily
          ? d.copyWith(daily: d.daily.copyWith(inProgress: level))
          : d.copyWith(inProgress: level),
    );
  }

  @override
  void clearInProgress(PlayKind kind) => update(
    (d) => switch (kind) {
      PlayKind.daily => d.copyWith(daily: d.daily.copyWith(inProgress: null)),
      PlayKind.campaign || PlayKind.bonus =>
        d.inProgressOf(kind) == null ? d : d.copyWith(inProgress: null),
      // Nothing is ever saved for a replay or a race.
      PlayKind.replay || PlayKind.race => d,
    },
  );

  // --- Cosmetics ----------------------------------------------------------------

  @override
  bool purchaseSkin(String skinId, int price) {
    RangeError.checkNotNegative(price, 'price');
    if (_document.ownedSkins.contains(skinId) || price > _document.coins) {
      return false;
    }
    update(
      (d) => d.copyWith(
        coins: d.coins - price,
        ownedSkins: [...d.ownedSkins, skinId],
      ),
    );
    return true;
  }

  @override
  bool selectSkin(String skinId) {
    if (!_document.ownedSkins.contains(skinId)) return false;
    update((d) => d.copyWith(selectedSkin: skinId));
    return true;
  }

  @override
  bool purchaseTheme(String themeId, int price) {
    RangeError.checkNotNegative(price, 'price');
    if (_document.ownedThemes.contains(themeId) || price > _document.coins) {
      return false;
    }
    update(
      (d) => d.copyWith(
        coins: d.coins - price,
        ownedThemes: [...d.ownedThemes, themeId],
      ),
    );
    return true;
  }

  @override
  void selectTheme(String? themeId) =>
      update((d) => d.copyWith(selectedTheme: themeId));

  // --- Onboarding -----------------------------------------------------------------

  @override
  void markIntroSeen(IntroMechanic mechanic) => update(
    (d) => d.seenIntros.contains(mechanic.id)
        ? d
        : d.copyWith(seenIntros: [...d.seenIntros, mechanic.id]),
  );

  @override
  void markTutorialDone() => update((d) => d.copyWith(tutorialDone: true));

  // --- Daily ------------------------------------------------------------------------

  @override
  void writeDaily(DailyProgress daily, {int addCoins = 0}) {
    RangeError.checkNotNegative(addCoins, 'addCoins');
    update((d) => d.copyWith(daily: daily, coins: d.coins + addCoins));
  }

  // --- Daily gift (plan-login-gift §7.5b; D268) ---------------------------

  @override
  LoginGiftGrant? claimLoginGift(LocalDate today) {
    try {
      final track = LoginGiftRules.trackOf(_remoteConfig);
      LoginGiftGrant? grant;
      // The grant is decided on the document the update applies to, so the
      // pay and the claim can't disagree (one update, m3-design §3.5).
      update((d) {
        grant = LoginGiftRules.grantFor(d, today, track);
        final reward = grant?.reward;
        if (reward == null) return d;
        // Boosters are a stored count, so they are added even with the
        // dev flavor's unlimited boosters.
        return d.copyWith(
          coins: d.coins + math.max(0, reward.coins),
          inventory: d.inventory.copyWith(
            hint: d.inventory.hint + math.max(0, reward.hints),
            slot: d.inventory.slot + math.max(0, reward.slots),
          ),
          loginGift: LoginGiftRules.claimed(d.loginGift, today),
        );
      });
      return grant;
    } on Object catch (error, stack) {
      // Rule 3: no gift today is the safe answer; nothing was written.
      developer.log(
        'claiming the daily gift failed',
        name: 'nesty.save',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }

  @override
  void noteLoginGiftDate(LocalDate today) {
    try {
      update((d) {
        final noted = LoginGiftRules.noted(d.loginGift, today);
        return noted == d.loginGift ? d : d.copyWith(loginGift: noted);
      });
    } on Object catch (error, stack) {
      // Rule 3: the clock guard keeps the date it had.
      developer.log(
        'noting the daily gift date failed',
        name: 'nesty.save',
        error: error,
        stackTrace: stack,
      );
    }
  }

  // --- Identity and persistence -------------------------------------------------------

  @override
  String get playerId => _document.playerId ?? '';

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> flush() async {}

  /// Flushes, then closes [changes] (get_it dispose hook).
  @override
  @disposeMethod
  Future<void> dispose() async {
    await flush();
    await _changes.close();
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  static bool _isDevFlavor() {
    try {
      return FlavorConfig.flavor == Flavor.dev;
    } on StateError {
      // `lib/main_<flavor>.dart` sets the flavor before DI, so only a test
      // that builds the real graph without one gets here: production rules.
      return false;
    }
  }
}
