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
    var earnedCount = 0;
    final entries = <MuseumEntry>[];
    for (final chapter in _catalog.chapters) {
      final entry = _entryFor(
        chapter,
        document: document,
        collected: collected,
        collectedDates: collectedDates,
        isNext: !foundNext,
      );
      if (entry.earned) {
        earnedCount++;
      } else {
        foundNext = true;
      }
      entries.add(entry);
    }

    return MuseumState(
      coins: _save.coins,
      // Derived from the entries below, not `collected.length`: a chapter
      // that reads `earned` because its levels are all won (the D111 fix)
      // must also count here, so the collection card's "N / 10" and
      // progress bar never disagree with the cabinet under it.
      collectedCount: earnedCount,
      totalChapters: _catalog.chapters.length,
      entries: entries,
      homeRequest: _resolver.homeRequest,
      homeLevelNumber: document.currentLevel,
    );
  }

  /// [isNext] is only a candidate here (the first entry `_read`'s loop
  /// hasn't already marked earned); the entry's own [MuseumEntry.earned]
  /// decides whether it actually is (below).
  MuseumEntry _entryFor(
    ChapterInfo chapter, {
    required SaveDocument document,
    required List<String> collected,
    required Map<String, LocalDate> collectedDates,
    required bool isNext,
  }) {
    final done = chapter.doneAt(document.currentLevel);
    // D111 (the owner's simulator review, 2026-09-28): the dev "Jump to a
    // level" sheet (and anything else that moves `currentLevel`/
    // `highestLevel` without going through a normal win) never appends to
    // `document.museum`, so a chapter whose 20 levels are all won could
    // read `earned: false` — "soon" with a full progress chip, seen as
    // "Classic · soon" with a 20/20 badge. A chapter this done is always
    // shown as ready, never "soon": `earned` is derived (`done >=
    // chapter.levels`) as well as read from the save. This is the
    // "show it as ready" option (the durable "award it" alternative — a
    // silent catch-up like the badges', backfilling `museum`/
    // `museumCollected` on load or win — belongs in `SaveService`,
    // `core/services/save/**`, outside this lane; see the lane report).
    final earned = collected.contains(chapter.id) || done >= chapter.levels;
    return MuseumEntry(
      chapterId: chapter.id,
      chapterNumber: chapter.number,
      themeId: chapter.themeId,
      figurineId: chapter.figurine.id,
      earned: earned,
      isNext: isNext && !earned,
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
