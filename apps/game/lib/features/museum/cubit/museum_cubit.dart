import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'museum_cubit.freezed.dart';
part 'museum_state.dart';

/// The Doll Museum (spec §7.2, §10.2 #10, frames 6.1–6.3; docs/plans/
/// m3-design.md §9.1, §10.6): the ten chapter figurines, which are earned,
/// which is next, and how far its chapter is along; the collection card's
/// totals; and Home's "Play Level N" for a locked or the next figurine's
/// modal (`LevelResolver.homeRequest`, the same one Home's PLAY and Daily's
/// solved state use).
///
/// It follows [SaveService.changes] (a win completes a chapter while the
/// shell's Museum tab stays mounted underneath), so the cabinet updates
/// without a spinner.
@injectable
class MuseumCubit extends BaseAsyncCubit<MuseumState> {
  MuseumCubit(this._save, this._catalog, this._resolver) {
    _saveChanges = _save.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final CatalogRepository _catalog;
  final LevelResolver _resolver;
  late final StreamSubscription<void> _saveChanges;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  MuseumState _read() {
    final document = _save.document;
    final collected = document.museum;
    final collectedDates = document.museumCollected;
    var foundNext = false;
    final entries = <MuseumEntry>[];
    for (final chapter in _catalog.chapters) {
      final isNext = !collected.contains(chapter.id) && !foundNext;
      if (isNext) foundNext = true;
      entries.add(
        _entryFor(
          chapter,
          document: document,
          collected: collected,
          collectedDates: collectedDates,
          isNext: isNext,
        ),
      );
    }

    return MuseumState(
      coins: _save.coins,
      collectedCount: collected.length,
      totalChapters: _catalog.chapters.length,
      entries: entries,
      homeRequest: _resolver.homeRequest,
      homeLevelNumber: document.currentLevel,
    );
  }

  MuseumEntry _entryFor(
    ChapterInfo chapter, {
    required SaveDocument document,
    required List<String> collected,
    required Map<String, LocalDate> collectedDates,
    required bool isNext,
  }) {
    final earned = collected.contains(chapter.id);
    final start = (chapter.number - 1) * chapter.levels + 1;
    final done = (document.currentLevel - start).clamp(0, chapter.levels);
    return MuseumEntry(
      chapterId: chapter.id,
      chapterNumber: chapter.number,
      themeId: chapter.themeId,
      figurineId: chapter.figurine.id,
      earned: earned,
      isNext: isNext,
      done: done,
      total: chapter.levels,
      collectedOn: collectedDates[chapter.id],
    );
  }

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    return super.close();
  }
}
