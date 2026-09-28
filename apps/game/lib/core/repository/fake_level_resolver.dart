import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/gameplay/bloc/win_reward.dart';

/// A scriptable [LevelResolver] for tests: campaign requests come from
/// [LevelRepository] (paid `winRewardFor(tier)`, in their chapter; no
/// chapter is ever complete), generated requests from [generated], which a
/// test fills (unknown ones resolve to null).
///
/// Not bound by DI: `DefaultLevelResolver` (m3-design §6.2) serves both
/// environments; this class is a hand-scripted double for tests only.
class FakeLevelResolver implements LevelResolver {
  FakeLevelResolver(
    this._levels,
    this._save,
    this._remoteConfig, {
    @ignoreParam Map<PlayRequest, PlayEntry>? generated,
  }) : generated = generated ?? {};

  final LevelRepository _levels;
  final SaveService _save;
  final RemoteConfigService _remoteConfig;

  /// Bonus and daily entries a test provides.
  final Map<PlayRequest, PlayEntry> generated;

  /// Requests [prefetch] was asked for, oldest first.
  final List<PlayRequest> prefetched = [];

  @override
  Future<PlayEntry?> resolve(PlayRequest request) async => switch (request) {
    CampaignPlay(:final order) => _campaign(order),
    BonusPlay() || DailyPlay() => generated[request],
  };

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
    DailyPlay() => null,
  };

  @override
  PlayRequest get homeRequest {
    final level = _save.currentLevel;
    return _levels.entryAt(level) != null
        ? PlayRequest.campaign(level)
        : PlayRequest.bonus(_save.nextBonus);
  }
}
