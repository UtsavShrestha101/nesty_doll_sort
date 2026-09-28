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
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

/// Home screen state (spec §10.2 #2, frame 2.1; docs/plans/m3-design.md
/// §10.3): the next level (or Bonus Endless) with its tier and board theme,
/// the coins, the Daily tile's lock/streak and the Museum tile's progress.
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
  ) {
    _saveChanges = _save.changes.listen((_) => _refresh());
    _dailyChanges = _daily.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final LevelRepository _levels;
  final LevelResolver _resolver;
  final DailyService _daily;
  final CatalogRepository _catalog;
  late final StreamSubscription<void> _saveChanges;
  late final StreamSubscription<DailyStatus> _dailyChanges;

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
      DailyPlay() => Tier.easy, // homeRequest never asks for the daily.
    };

    final daily = _daily.refresh();
    final museum = _museumProgress(document.museum, document.currentLevel);

    return HomeState(
      playRequest: request,
      tier: tier,
      themeId: document.selectedTheme ?? _currentThemeId(document),
      coins: _save.coins,
      adsRemoved: document.adsRemoved,
      dailyUnlocked: daily.unlocked,
      dailyStreak: daily.streak,
      museumFigurineId: museum.figurineId,
      museumLockedArtAsset: museum.lockedArtAsset,
      museumDone: museum.done,
      museumTotal: museum.total,
      museumAllCollected: museum.allCollected,
      museumCollectedCount: document.museum.length,
      museumCollectedTotal: _catalog.chapters.length,
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
  /// chapter is collected there is no next figurine (`TODO(design)`: Bonus
  /// Endless has no frame for this state, so the tile falls back to a plain
  /// collection count).
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
      final start = (chapter.number - 1) * chapter.levels + 1;
      final done = (currentLevel - start).clamp(0, chapter.levels);
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
