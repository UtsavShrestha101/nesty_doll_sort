import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

/// Home screen state (spec §10.2 #2, frame 2.1): the next level with its
/// tier and chapter, and the coins. It follows the save ([SaveService.changes]),
/// so coming back from a won level shows the new level and balance.
///
/// TODO(M3): Daily/Museum/Remove Ads tiles and the bottom nav.
@injectable
class HomeCubit extends BaseAsyncCubit<HomeState> {
  HomeCubit(this._save, this._levels) {
    _changes = _save.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final LevelRepository _levels;
  late final StreamSubscription<void> _changes;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  /// The save changed (a win, a purchase): refresh without a spinner.
  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  HomeState _read() {
    final count = _levels.levelCount;
    final entry = _levels.entryAt(_save.currentLevel);
    if (entry == null) {
      // Past the last bundled level (spec §7.1): the last chapter's theme.
      final last = count > 0 ? _levels.entryAt(count) : null;
      return HomeState(
        currentLevel: _save.currentLevel,
        tier: last?.tier ?? Tier.easy,
        chapterId: last?.chapterId ?? 'ch01',
        coins: _save.coins,
        levelCount: count,
        allLevelsDone: count > 0,
      );
    }
    return HomeState(
      currentLevel: entry.order,
      tier: entry.tier,
      chapterId: entry.chapterId,
      coins: _save.coins,
      levelCount: count,
    );
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
