import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
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
  /// id.
  @protected
  Future<void> loadDocument() async {
    if (_document.playerId == null) {
      update((d) => d.copyWith(playerId: newPlayerId()));
    }
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
  void recordLevelWin(LevelWinRecord win) {
    RangeError.checkNotNegative(win.rewardCoins, 'rewardCoins');
    RangeError.checkNotNegative(win.chapterReward, 'chapterReward');
    final request = win.request;
    RangeError.checkValueInInterval(request.number, 1, 99991231, 'request');
    update((d) {
      var next = d.copyWith(
        coins: d.coins + win.rewardCoins,
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
        case DailyPlay():
          final daily = win.daily ?? next.daily;
          next = next.copyWith(
            daily: daily.inProgress?.request == request
                ? daily.copyWith(inProgress: null)
                : daily,
          );
      }
      return next;
    });
  }

  // --- In progress ------------------------------------------------------------

  @override
  InProgressLevel? inProgressFor(PlayKind kind) => _document.inProgressOf(kind);

  @override
  void saveInProgress(InProgressLevel level) => update(
    (d) => level.request.kind == PlayKind.daily
        ? d.copyWith(daily: d.daily.copyWith(inProgress: level))
        : d.copyWith(inProgress: level),
  );

  @override
  void clearInProgress(PlayKind kind) => update(
    (d) => switch (kind) {
      PlayKind.daily => d.copyWith(daily: d.daily.copyWith(inProgress: null)),
      PlayKind.campaign || PlayKind.bonus =>
        d.inProgressOf(kind) == null ? d : d.copyWith(inProgress: null),
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
