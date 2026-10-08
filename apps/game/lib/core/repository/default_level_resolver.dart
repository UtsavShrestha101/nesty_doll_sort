import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/daily_archive/daily_archive_rules.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/win_reward.dart';

/// The [LevelResolver] for both environments (m3-design §6.2): the fake env
/// fakes its parts (`FakeLevelRepository`, `FakeLevelGeneratorService`,
/// `FakeCatalogRepository`, `FakeSaveService`), so one implementation serves
/// both.
@LazySingleton(as: LevelResolver, env: [AppEnv.real, AppEnv.fake])
class DefaultLevelResolver implements LevelResolver {
  DefaultLevelResolver(
    this._levels,
    this._generator,
    this._remoteConfig,
    this._save,
    this._catalog,
    this._clock,
  );

  final LevelRepository _levels;
  final LevelGeneratorService _generator;
  final RemoteConfigService _remoteConfig;
  final SaveService _save;
  final CatalogRepository _catalog;
  final AppClock _clock;

  /// Generated entries kept for the last few requests (m3-design §6.2).
  static const int _cacheSize = 4;

  final Map<PlayRequest, PlayEntry> _cache = {};
  final Map<PlayRequest, Future<PlayEntry?>> _inFlight = {};

  @override
  Future<PlayEntry?> resolve(PlayRequest request) => switch (request) {
    CampaignPlay(:final order) => Future.value(_campaign(order)),
    ReplayPlay(:final order) => Future.value(_replay(order)),
    PastDailyPlay() =>
      _mayPlayPastDay(request)
          ? _ensureGenerated(request)
          : Future<PlayEntry?>.value(),
    BonusPlay() || DailyPlay() || RacePlay() => _ensureGenerated(request),
  };

  @override
  void prefetch(PlayRequest request) {
    // Bundled boards (campaign, replay) resolve synchronously; generated
    // ones (bonus, daily, race) start in the isolate.
    if (!request.isGenerated) return;
    if (request is PastDailyPlay && !_mayPlayPastDay(request)) return;
    unawaited(_ensureGenerated(request));
  }

  @override
  PlayRequest? next(PlayRequest request) => switch (request) {
    CampaignPlay(:final order) =>
      _levels.entryAt(order + 1) != null
          ? PlayRequest.campaign(order + 1)
          : PlayRequest.bonus(_save.nextBonus),
    BonusPlay(:final number) => PlayRequest.bonus(number + 1),
    DailyPlay() => null,
    // A past day ends on its own card, back to the Daily (§7.5c).
    PastDailyPlay() => null,
    // Continue after a replay goes back to Chapters (m7-design §6).
    ReplayPlay() => null,
    // A race's result offers Rematch and New race, never a next level
    // (m7-design P2.4, P2.5).
    RacePlay() => null,
  };

  @override
  PlayRequest get homeRequest {
    final level = _save.currentLevel;
    return _levels.entryAt(level) != null
        ? PlayRequest.campaign(level)
        : PlayRequest.bonus(_save.nextBonus);
  }

  // --- Campaign: synchronous, from the bundle. ---------------------------

  PlayEntry? _campaign(int order) {
    if (order < 1) return null;
    final entry = _levels.entryAt(order);
    if (entry == null) return null;
    final chapter = _catalog.chapter(entry.chapterId);
    return PlayEntry(
      request: PlayRequest.campaign(entry.order),
      level: entry.level,
      tier: entry.tier,
      levelVersion: entry.version,
      rewardCoins: winRewardFor(entry.tier, _remoteConfig),
      themeId: chapter?.themeId ?? entry.chapterId,
      chapterId: entry.chapterId,
      completesChapter: _completesChapter(entry),
      bundleEntry: entry,
    );
  }

  /// A replay of won level [order] (m7-design §6): the campaign's board,
  /// tier, version and theme, paying nothing and completing nothing. Null
  /// when the bundle doesn't have that exact order (a skipped level
  /// resolves to its successor for the campaign, never for a replay) or
  /// the player hasn't won it (`order >= highestLevel`).
  PlayEntry? _replay(int order) {
    if (order < 1 || order >= _save.highestLevel) return null;
    final entry = _levels.entryAt(order);
    if (entry == null || entry.order != order) return null;
    final chapter = _catalog.chapter(entry.chapterId);
    return PlayEntry(
      request: PlayRequest.replay(order),
      level: entry.level,
      tier: entry.tier,
      levelVersion: entry.version,
      rewardCoins: 0,
      themeId: chapter?.themeId ?? entry.chapterId,
      chapterId: entry.chapterId,
      bundleEntry: entry,
    );
  }

  /// A campaign level's win completes its chapter when the next entry is in
  /// another chapter, or there is no next entry and this chapter's loaded
  /// entries already reach its `ChapterInfo.levels` (D72).
  ///
  /// TODO(M4): this only sees the bundle it was resolved from, so a chapter
  /// the player already passed with fewer levels than `ChapterInfo.levels`
  /// never retroactively completes when sync adds the rest. Award that
  /// figurine and `reward_chapter` when sync lands them instead (m3 §6.2).
  bool _completesChapter(LevelBundleEntry entry) {
    final next = _levels.entryAt(entry.order + 1);
    if (next != null) return next.chapterId != entry.chapterId;
    final chapter = _catalog.chapter(entry.chapterId);
    if (chapter == null) return false;
    return _chapterEntryCount(chapter) >= chapter.levels;
  }

  int _chapterEntryCount(ChapterInfo chapter) {
    // Chapters are uniform blocks of `chapter.levels` in order-space (spec
    // §7.1); every bundled chapter uses the same size, so this is exact.
    final end = chapter.number * chapter.levels;
    var order = (chapter.number - 1) * chapter.levels + 1;
    var count = 0;
    while (order <= end) {
      final entry = _levels.entryAt(order);
      if (entry == null || entry.chapterId != chapter.id) break;
      count++;
      order = entry.order + 1;
    }
    return count;
  }

  // --- Bonus and daily: generated, cached, restore-first. -----------------

  /// Cached → restored from the saved in-progress board → generated fresh,
  /// with in-flight de-duplication so `prefetch` and `resolve` (or two
  /// `resolve`s) share one attempt. A race is never saved, so it is only
  /// ever cached or generated: the cache gives a Rematch the very same
  /// `Level` at once (m7-design P2.4).
  Future<PlayEntry?> _ensureGenerated(PlayRequest request) {
    final cached = _cache[request];
    if (cached != null) return Future.value(cached);
    final inFlight = _inFlight[request];
    if (inFlight != null) return inFlight;

    final saved = _save.inProgressFor(request.kind);
    if (saved != null && saved.request == request) {
      final restored = _restoreEmbedded(request, saved);
      if (restored != null) {
        _remember(request, restored);
        return Future.value(restored);
      }
    }

    final future = _generate(request);
    _inFlight[request] = future;
    return future.then((entry) {
      _inFlight.remove(request);
      if (entry != null) _remember(request, entry);
      return entry;
    });
  }

  /// Never throws (rule 3): a generation failure, or a request whose date
  /// or number can't make a board, is null.
  Future<PlayEntry?> _generate(PlayRequest request) async {
    try {
      return switch (request) {
        BonusPlay(:final number) => await _bonus(request, number),
        DailyPlay(:final yyyymmdd) => await _daily(request, yyyymmdd),
        PastDailyPlay(:final yyyymmdd) => await _pastDaily(request, yyyymmdd),
        RacePlay() => await _race(request),
        CampaignPlay() || ReplayPlay() => null,
      };
    } on Object catch (error, stack) {
      _log('generation of $request failed', error, stack);
      return null;
    }
  }

  Future<PlayEntry?> _bonus(PlayRequest request, int number) async {
    if (number < 1) return null;
    final params = DifficultyCurve.bonusParams(_levels.levelCount + number);
    final generated = await _generator.generate(params);
    if (generated == null) return null;
    return PlayEntry(
      request: request,
      level: generated.level,
      tier: generated.tier,
      levelVersion: Generator.version,
      rewardCoins: winRewardFor(generated.tier, _remoteConfig),
      themeId: _lastChapterThemeId(),
      expertOnly: generated.expertOnly,
    );
  }

  Future<PlayEntry?> _daily(PlayRequest request, int yyyymmdd) async {
    if (!_isRealDate(yyyymmdd)) return null;
    final params = DifficultyCurve.dailyParams(yyyymmdd);
    final generated = await _generator.generate(params);
    if (generated == null) return null;
    return PlayEntry(
      request: request,
      level: generated.level,
      tier: generated.tier,
      levelVersion: Generator.version,
      rewardCoins: _remoteConfig.value(RemoteConfigKeys.dailyReward),
      themeId: _currentChapterThemeId(),
      expertOnly: generated.expertOnly,
    );
  }

  /// A past day's board (§7.5c): the very board `_daily` makes for that
  /// date, paying nothing. The gate ([_mayPlayPastDay]) already ran.
  Future<PlayEntry?> _pastDaily(PlayRequest request, int yyyymmdd) async {
    final params = DifficultyCurve.dailyParams(yyyymmdd);
    final generated = await _generator.generate(params);
    if (generated == null) return null;
    return PlayEntry(
      request: request,
      level: generated.level,
      tier: generated.tier,
      levelVersion: Generator.version,
      rewardCoins: 0,
      themeId: _currentChapterThemeId(),
      expertOnly: generated.expertOnly,
    );
  }

  /// A past day may be resolved when the Daily is unlocked and the date is
  /// in the window (today − `daily_archive_days` … today − 1), or is the
  /// date of the saved past-day board: one open on screen past midnight
  /// can still be finished (§7.5c). Never today, the future or a date that
  /// isn't one.
  bool _mayPlayPastDay(PlayRequest request) {
    if (request is! PastDailyPlay) return false;
    final LocalDate date;
    try {
      date = LocalDate.fromYyyymmdd(request.yyyymmdd);
    } on ArgumentError {
      return false;
    }
    final today = _clock.today();
    if (date >= today) return false;
    if (_save.highestLevel < StreakDailyService.unlockAtHighestLevel) {
      return false;
    }
    final saved = _save.inProgressFor(PlayKind.pastDaily);
    if (saved != null && saved.request == request) return true;
    return DailyArchiveRules.isPlayable(
      date,
      today,
      unlocked: true,
      days: DailyArchiveRules.daysOf(_remoteConfig),
    );
  }

  /// A vs Computer race (spec-prop §7.7; m7-design P2.4):
  /// `DifficultyCurve.raceParams` for the rival and raceNo at the stage of
  /// the highest level won (`RaceRules.stageLevel`), generated in the
  /// isolate with the deterministic retries, paying `race_reward_<rival>`
  /// (`RaceRules.rewardCoins`), on the player's current chapter's theme
  /// (the daily's; the default of an owner question until frame 9.3
  /// lands), outside the chapters.
  ///
  /// Null, with nothing generated, when the mode is still locked
  /// (`RaceRules.modeUnlocked`), the rival is outside 1–3 or still locked
  /// in the save, or the raceNo is outside 1–`DifficultyCurve.maxRaceNo`;
  /// and when every retry failed. The page's failure card then leads back
  /// to rival select, and the next race (the save already stored this
  /// raceNo) makes another board.
  Future<PlayEntry?> _race(RacePlay request) async {
    final rival = request.rival;
    final raceNo = request.raceNo;
    if (rival < 1 || rival > DifficultyCurve.raceRivals) return null;
    if (raceNo < 1 || raceNo > DifficultyCurve.maxRaceNo) return null;
    final document = _save.document;
    if (!RaceRules.modeUnlocked(document.highestLevel, _remoteConfig)) {
      return null;
    }
    if (!document.race.rivals[rival - 1].unlocked) return null;
    final params = DifficultyCurve.raceParams(
      rival: rival,
      raceNo: raceNo,
      highestWonLevel: RaceRules.stageLevel(document.highestLevel),
    );
    final generated = await _generator.generate(params);
    if (generated == null) return null;
    return PlayEntry(
      request: request,
      level: generated.level,
      tier: generated.tier,
      levelVersion: Generator.version,
      rewardCoins: RaceRules.rewardCoins(rival, _remoteConfig),
      themeId: _currentChapterThemeId(),
      expertOnly: generated.expertOnly,
    );
  }

  /// Rebuilds a generated entry from its saved level JSON (rules 1–7,
  /// `ValidationOptions.loader`, no solver) rather than regenerating it
  /// (m3-design §6.2). Null when anything it needs is missing or invalid,
  /// so the caller regenerates instead.
  ///
  /// A board an older generator made is regenerated too: replaying it
  /// under the new `Generator.version` would keep a daily that no longer
  /// matches everyone else's for that date (spec §7.5), and the bloc drops
  /// the stale session anyway (spec §13.3 levelVersion check).
  PlayEntry? _restoreEmbedded(PlayRequest request, InProgressLevel saved) {
    if (saved.levelVersion != Generator.version) return null;
    final levelJson = saved.level;
    final tier = saved.tier;
    if (levelJson == null || tier == null) return null;
    final level = LevelCodec.decode(levelJson).level;
    if (level == null) return null;
    if (!Validator.validate(level, options: ValidationOptions.loader).isValid) {
      return null;
    }
    return PlayEntry(
      request: request,
      level: level,
      tier: tier,
      levelVersion: Generator.version,
      rewardCoins: switch (request) {
        BonusPlay() => winRewardFor(tier, _remoteConfig),
        DailyPlay() => _remoteConfig.value(RemoteConfigKeys.dailyReward),
        PastDailyPlay() => 0,
        // Never restored: bundled boards load from the bundle, and a race
        // is never saved (m7-design P2.4).
        CampaignPlay() || ReplayPlay() || RacePlay() => 0,
      },
      themeId: switch (request) {
        BonusPlay() => _lastChapterThemeId(),
        DailyPlay() || PastDailyPlay() => _currentChapterThemeId(),
        CampaignPlay() || ReplayPlay() || RacePlay() => '',
      },
    );
  }

  /// A bonus board's theme: the last published campaign chapter's
  /// (m3-design §6.2 table).
  String _lastChapterThemeId() => _themeIdOf(_lastEntry());

  /// A daily board's theme: the player's current chapter's, else the last
  /// published one (m3-design §6.2 table, §9.1).
  String _currentChapterThemeId() =>
      _themeIdOf(_levels.entryAt(_save.currentLevel) ?? _lastEntry());

  LevelBundleEntry? _lastEntry() {
    final count = _levels.levelCount;
    return count < 1 ? null : _levels.entryAt(count);
  }

  String _themeIdOf(LevelBundleEntry? entry) {
    if (entry == null) return '';
    return _catalog.chapter(entry.chapterId)?.themeId ?? entry.chapterId;
  }

  static bool _isRealDate(int yyyymmdd) {
    try {
      LocalDate.fromYyyymmdd(yyyymmdd);
      return true;
    } on ArgumentError {
      return false;
    }
  }

  void _remember(PlayRequest request, PlayEntry entry) {
    _cache
      ..remove(request)
      ..[request] = entry;
    while (_cache.length > _cacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.resolver',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.resolver] $message: $error');
  }
}
