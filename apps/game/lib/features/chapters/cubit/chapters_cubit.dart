import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
// `show`: injectable's top-level `order` would shadow `ChapterLevel.order`
// in the state's getters.
import 'package:injectable/injectable.dart' show injectable;
import 'package:nesty_core/nesty_core.dart' show StarRating, Tier;
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'chapters_cubit.freezed.dart';
part 'chapters_state.dart';

/// The Chapters screen (E7; spec-prop §7.1, §10.2 #18; docs/plans/
/// m7-design.md §11, §15.1): every catalog chapter's 20 levels, which are
/// won (with their best moves), which one is next and which are locked.
/// A won level replays, the current one plays as the campaign.
///
/// It follows [SaveService.changes] (a replay's new best lands while the
/// screen is under the board), so the grid updates without a spinner.
@injectable
class ChaptersCubit extends BaseAsyncCubit<ChaptersState> {
  ChaptersCubit(
    this._save,
    this._levels,
    this._catalog, [
    RemoteConfigService? remoteConfig,
  ]) : _remoteConfig = remoteConfig ?? DefaultsRemoteConfigService() {
    _saveChanges = _save.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final LevelRepository _levels;
  final CatalogRepository _catalog;
  final RemoteConfigService _remoteConfig;
  late final StreamSubscription<void> _saveChanges;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  ChaptersState _read() {
    final document = _save.document;
    final slack = StarRules.slackOf(_remoteConfig);
    final chapters = [
      for (final chapter in _catalog.chapters)
        _section(chapter, document, slack),
    ];
    return ChaptersState(
      coins: _save.coins,
      chapters: chapters,
      currentLevel: document.currentLevel,
      // The header's overall "Level {level} of {total}" line (owner's
      // simulator review, 2026-09-28, design request I.4): every catalog
      // chapter's own level count, not a hard-coded 200, so it stays right
      // if a later chapter ships with a different length.
      totalLevels: chapters.fold(0, (sum, section) => sum + section.total),
    );
  }

  /// Chapters are uniform blocks of `chapter.levels` in order-space (spec
  /// §7.1), as Home and the Museum count them.
  ChapterSection _section(
    ChapterInfo chapter,
    SaveDocument document,
    StarSlack slack,
  ) {
    final first = (chapter.number - 1) * chapter.levels + 1;
    final levels = [
      for (var order = first; order < first + chapter.levels; order++)
        _level(
          order,
          document,
          slack,
          position: order - first,
          count: chapter.levels,
        ),
    ];
    final won = levels
        .where((level) => level.status == ChapterLevelStatus.won)
        .length;
    // Stars (m7-design P3.7): the won cells' best stars, out of 3 × the
    // chapter's levels the bundle has with a par.
    var withPar = 0;
    for (var order = first; order < first + chapter.levels; order++) {
      final entry = _levels.entryAt(order);
      if (entry != null && entry.order == order && entry.par != null) {
        withPar++;
      }
    }
    return ChapterSection(
      chapterId: chapter.id,
      number: chapter.number,
      levels: levels,
      themeId: chapter.themeId,
      figurineId: chapter.figurine.id,
      // The same "show it as ready" fix as `MuseumCubit._entryFor` (D111,
      // the owner's simulator review, 2026-09-28): a chapter whose levels
      // are all won here (`ChapterLevelStatus.won` already reads
      // `highestLevel`, so this never regresses on the dev picker moving
      // `currentLevel` back, m7-design §6) is never a stale "not earned",
      // even before `document.museum` catches up.
      figurineEarned:
          document.museum.contains(chapter.id) || won >= chapter.levels,
      stars: levels.fold(0, (sum, level) => sum + (level.stars ?? 0)),
      starsPossible: StarRating.maxStars * withPar,
    );
  }

  /// m7-design §11: a level the bundle doesn't have (yet) is locked; the
  /// one Home's PLAY starts (`currentLevel`) is current; one behind
  /// `highestLevel` is won; the rest are locked.
  ChapterLevel _level(
    int order,
    SaveDocument document,
    StarSlack slack, {
    required int position,
    required int count,
  }) {
    // The milestone chest is the chapter's 10th level, the flag its last.
    final isChest = position == 9;
    final isFinale = position == count - 1;
    final entry = _levels.entryAt(order);
    if (entry == null || entry.order != order) {
      return ChapterLevel(order: order, isChest: isChest, isFinale: isFinale);
    }
    if (order == document.currentLevel) {
      return ChapterLevel(
        order: order,
        status: ChapterLevelStatus.current,
        tier: entry.tier,
        isChest: isChest,
        isFinale: isFinale,
      );
    }
    if (order < document.highestLevel) {
      return ChapterLevel(
        order: order,
        status: ChapterLevelStatus.won,
        bestMoves: _save.bestMovesFor(
          LevelBests.key(entry.level.id, entry.version),
        ),
        tier: entry.tier,
        stars: document.levelStars[entry.level.id],
        target: entry.par == null
            ? null
            : StarRating.threshold(entry.par!, slack.star3),
        isChest: isChest,
        isFinale: isFinale,
      );
    }
    return ChapterLevel(
      order: order,
      tier: entry.tier,
      isChest: isChest,
      isFinale: isFinale,
    );
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    return super.close();
  }
}
