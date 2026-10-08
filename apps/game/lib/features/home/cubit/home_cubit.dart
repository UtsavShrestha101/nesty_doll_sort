import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
import 'package:nesty_game/features/chapters/cubit/chapter_star_tally.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

/// Home screen state (spec §10.2 #2, frame 2.1; docs/plans/m3-design.md
/// §10.3): the next level (or Bonus Endless) with its tier and board theme,
/// the coins, the Daily tile's lock/streak/flame, the Museum tile's
/// progress and the vs Computer tile's lock (docs/plans/m7-design.md
/// §15.8).
/// It follows [SaveService.changes] and [DailyService.changes], so coming
/// back from a won level, a purchase or the day rolling over shows the new
/// state.
@injectable
class HomeCubit extends BaseAsyncCubit<HomeState> {
  HomeCubit(
    this._save,
    this._levels,
    this._resolver,
    this._daily,
    this._catalog,
    this._remoteConfig,
    this._database,
  ) {
    _saveChanges = _save.changes.listen((_) => _refresh());
    _dailyChanges = _daily.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final LevelRepository _levels;
  final LevelResolver _resolver;
  final DailyService _daily;
  final CatalogRepository _catalog;
  final RemoteConfigService _remoteConfig;
  final DatabaseService _database;
  late final StreamSubscription<void> _saveChanges;
  late final StreamSubscription<DailyStatus> _dailyChanges;

  /// The solve date of the relight whose glow is playing now (m7-4 4.10),
  /// until [relitGlowFinished].
  LocalDate? _glowing;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  /// The save or the daily changed (a win, a purchase, a new day): refresh
  /// without a spinner.
  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  HomeState _read() {
    final document = _save.document;
    final request = _resolver.homeRequest;
    final tier = switch (request) {
      CampaignPlay(:final order) => _levels.entryAt(order)?.tier ?? Tier.easy,
      BonusPlay(:final number) => DifficultyCurve.tierForLevel(
        _levels.levelCount + number,
      ),
      // homeRequest never asks for the daily, a replay, a race or a past
      // day's board (Home never offers one as its "continue").
      DailyPlay() || ReplayPlay() || RacePlay() || PastDailyPlay() => Tier.easy,
    };

    final daily = _daily.refresh();
    final museum = _museumProgress(document.museum, document.currentLevel);
    final raceUnlockLevel = _remoteConfig.value(
      RemoteConfigKeys.raceUnlockLevel,
    );

    final chapter = _chapterCard(request, document);
    final relit = _relitGlow(document, daily);

    return HomeState(
      chapterNumber: chapter.number,
      chapterId: chapter.id,
      isBonus: request is BonusPlay,
      chapterStars: chapter.stars,
      chapterStarsPossible: chapter.possible,
      streakRelit: relit,
      playRequest: request,
      tier: tier,
      themeId: document.selectedTheme ?? _currentThemeId(document),
      coins: _save.coins,
      adsRemoved: document.adsRemoved,
      dailyUnlocked: daily.unlocked,
      dailyStreak: daily.streak,
      dailyLit: daily.lit,
      raceUnlockLevel: raceUnlockLevel,
      raceUnlocked: document.highestLevel > raceUnlockLevel,
      museumFigurineId: museum.figurineId,
      museumLockedArtAsset: museum.lockedArtAsset,
      museumDone: museum.done,
      museumTotal: museum.total,
      museumAllCollected: museum.allCollected,
      museumCollectedCount: document.museum.length,
      museumCollectedTotal: _catalog.chapters.length,
    );
  }

  /// Whether the Daily tile's badge glows now (m7-4 4.10, `motion.relitHome`):
  /// a solve relit the paused streak (`DailyProgress.relitOn`, which holds
  /// until the next solve), and Home hasn't glowed for it yet, in this
  /// session or an earlier one. The date is stored the moment the glow is
  /// first asked for, so a kill during it never shows it twice; it plays
  /// until [relitGlowFinished].
  bool _relitGlow(SaveDocument document, DailyStatus daily) {
    final date = document.daily.lastDate;
    final relitDate = date != null && daily.lit && document.daily.relitOn(date)
        ? date
        : null;
    if (relitDate == null) {
      _glowing = null;
      return false;
    }
    if (_glowing != relitDate && _database.relitGlowSeen != relitDate.toIso()) {
      _glowing = relitDate;
      unawaited(
        // A failed write only risks one more glow (rule 3).
        _database.setRelitGlowSeen(relitDate.toIso()).catchError((Object _) {}),
      );
    }
    return _glowing == relitDate;
  }

  /// The badge's glow ran its 2,400 ms and faded: the tile shows the plain
  /// lit flame from now on.
  void relitGlowFinished() {
    _glowing = null;
    final current = state.data;
    if (isClosed || current == null || !current.streakRelit) return;
    emit(AsyncValue.data(data: current.copyWith(streakRelit: false)));
  }

  /// The chapter card (menus spec 1.1): the PLAY level's chapter with its
  /// stars over its levels' par, or in Bonus Endless the last chapter (for
  /// the palette) with the whole campaign's stars.
  ({int number, String id, int stars, int possible}) _chapterCard(
    PlayRequest request,
    SaveDocument document,
  ) {
    final count = _levels.levelCount;
    final order = switch (request) {
      CampaignPlay(:final order) => order,
      _ => count,
    };
    final entry =
        _levels.entryAt(order) ?? (count > 0 ? _levels.entryAt(count) : null);
    final chapter = entry == null ? null : _catalog.chapter(entry.chapterId);
    final number = chapter?.number ?? 1;
    final id = chapter?.id ?? 'ch01';
    final total = request is BonusPlay || chapter == null
        ? ChapterStarTally.ofCampaign(document: document, levels: _levels)
        : ChapterStarTally.ofChapter(
            chapter,
            document: document,
            levels: _levels,
          );
    return (
      number: number,
      id: id,
      stars: total.stars,
      possible: total.possible,
    );
  }

  /// The chapter behind the hero's background: the player's current one, or
  /// the last published one past it (Bonus Endless, m3-design §7.4 table).
  String _currentThemeId(SaveDocument document) {
    final count = _levels.levelCount;
    final entry =
        _levels.entryAt(document.currentLevel) ??
        (count > 0 ? _levels.entryAt(count) : null);
    if (entry == null) return SaveDocument.defaultTheme;
    return _catalog.chapter(entry.chapterId)?.themeId ?? entry.chapterId;
  }

  /// The Museum tile (m3-design §10.3, §10.6): the next chapter not yet in
  /// [museum], its own "done/20" of levels already won; once every catalog
  /// chapter is collected there is no next figurine, and the count is all
  /// there is (frame 6.1c is the Museum's own "every family is home").
  ({
    String? figurineId,
    String? lockedArtAsset,
    int done,
    int total,
    bool allCollected,
  })
  _museumProgress(List<String> museum, int currentLevel) {
    for (final chapter in _catalog.chapters) {
      if (museum.contains(chapter.id)) continue;
      final done = chapter.doneAt(currentLevel);
      return (
        figurineId: chapter.figurine.id,
        lockedArtAsset: chapter.figurine.lockedArtAsset,
        done: done,
        total: chapter.levels,
        allCollected: false,
      );
    }
    return (
      figurineId: null,
      lockedArtAsset: null,
      done: 0,
      total: ChapterInfo.levelsPerChapter,
      allCollected: true,
    );
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    await _dailyChanges.cancel();
    return super.close();
  }
}
