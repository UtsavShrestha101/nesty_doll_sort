import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/daily_archive/daily_archive_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/win_reward.dart';

/// A scriptable [LevelResolver] for tests: campaign requests come from
/// [LevelRepository] (paid `winRewardFor(tier)`, in their chapter; no
/// chapter is ever complete), replays too for a won order (paid 0, as
/// `DefaultLevelResolver`, m7-design §6), generated requests (bonus, daily
/// and race, m7-design P2.4) from [generated], which a test fills (unknown
/// ones resolve to null).
///
/// Not bound by DI: `DefaultLevelResolver` (m3-design §6.2) serves both
/// environments; this class is a hand-scripted double for tests only.
class FakeLevelResolver implements LevelResolver {
  FakeLevelResolver(
    this._levels,
    this._save,
    this._remoteConfig, {
    @ignoreParam Map<PlayRequest, PlayEntry>? generated,
    @ignoreParam AppClock? clock,
  }) : generated = generated ?? {},
       _clock = clock ?? FakeClock();

  final AppClock _clock;

  final LevelRepository _levels;
  final SaveService _save;
  final RemoteConfigService _remoteConfig;

  /// Bonus, daily and race entries a test provides.
  final Map<PlayRequest, PlayEntry> generated;

  /// Requests [prefetch] was asked for, oldest first.
  final List<PlayRequest> prefetched = [];

  @override
  Future<PlayEntry?> resolve(PlayRequest request) async => switch (request) {
    CampaignPlay(:final order) => _campaign(order),
    ReplayPlay(:final order) => _replay(order),
    PastDailyPlay() => _pastDaily(request),
    BonusPlay() || DailyPlay() || RacePlay() => generated[request],
  };

  /// `DefaultLevelResolver`'s gate (§7.5c): refuses today, the future, a
  /// date outside the window and a locked Daily, unless the date is the
  /// saved past-day board's. The board is the one a test filed for that
  /// date's `PlayRequest.daily` (or for the past-day request itself), paying
  /// nothing.
  PlayEntry? _pastDaily(PastDailyPlay request) {
    final LocalDate date;
    try {
      date = LocalDate.fromYyyymmdd(request.yyyymmdd);
    } on ArgumentError {
      return null;
    }
    final today = _clock.today();
    if (date >= today) return null;
    final saved = _save.inProgressFor(PlayKind.pastDaily);
    final open = saved != null && saved.request == request;
    if (!open) {
      if (_save.highestLevel < StreakDailyService.unlockAtHighestLevel) {
        return null;
      }
      if (!DailyArchiveRules.isPlayable(
        date,
        today,
        unlocked: true,
        days: DailyArchiveRules.daysOf(_remoteConfig),
      )) {
        return null;
      }
    }
    final board =
        generated[request] ?? generated[PlayRequest.daily(request.yyyymmdd)];
    return board?.copyWith(request: request, rewardCoins: 0);
  }

  PlayEntry? _replay(int order) {
    if (order < 1 || order >= _save.highestLevel) return null;
    final entry = _levels.entryAt(order);
    if (entry == null || entry.order != order) return null;
    return campaignEntry(
      entry,
      0,
    ).copyWith(request: PlayRequest.replay(entry.order));
  }

  PlayEntry? _campaign(int order) {
    if (order < 1) return null;
    final entry = _levels.entryAt(order);
    if (entry == null) return null;
    return campaignEntry(entry, winRewardFor(entry.tier, _remoteConfig));
  }

  /// The [PlayEntry] of a bundle [entry] paying [rewardCoins]: its own
  /// chapter and theme, not completing it.
  static PlayEntry campaignEntry(
    LevelBundleEntry entry,
    int rewardCoins, {
    bool completesChapter = false,
  }) => PlayEntry(
    request: PlayRequest.campaign(entry.order),
    level: entry.level,
    tier: entry.tier,
    levelVersion: entry.version,
    rewardCoins: rewardCoins,
    themeId: entry.chapterId,
    chapterId: entry.chapterId,
    completesChapter: completesChapter,
    bundleEntry: entry,
  );

  @override
  void prefetch(PlayRequest request) => prefetched.add(request);

  @override
  PlayRequest? next(PlayRequest request) => switch (request) {
    CampaignPlay(:final order) =>
      _levels.entryAt(order + 1) != null
          ? PlayRequest.campaign(order + 1)
          : PlayRequest.bonus(_save.nextBonus),
    BonusPlay(:final number) => PlayRequest.bonus(number + 1),
    DailyPlay() || ReplayPlay() || RacePlay() || PastDailyPlay() => null,
  };

  @override
  PlayRequest get homeRequest {
    final level = _save.currentLevel;
    return _levels.entryAt(level) != null
        ? PlayRequest.campaign(level)
        : PlayRequest.bonus(_save.nextBonus);
  }
}
