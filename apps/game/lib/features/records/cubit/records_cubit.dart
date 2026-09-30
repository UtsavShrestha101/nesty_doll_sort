import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/records/records_summary.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'records_cubit.freezed.dart';
part 'records_state.dart';

/// The Records screen (E8; spec-prop §7.8, §10.2 #19; docs/plans/
/// m7-design.md §12, §15.2): the lifetime records and the badges, read
/// from the save (`RecordsSummary.of`). It follows [SaveService.changes].
@injectable
class RecordsCubit extends BaseAsyncCubit<RecordsState> {
  RecordsCubit(this._save, this._levels) {
    _saveChanges = _save.changes.listen((_) => _refresh());
  }

  final SaveService _save;
  final LevelRepository _levels;
  late final StreamSubscription<void> _saveChanges;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => _read());
  }

  void _refresh() {
    if (isClosed || !state.hasData) return;
    unawaited(runGuarded(() async => _read()));
  }

  RecordsState _read() => RecordsState(
    coins: _save.coins,
    rivalsUnlocked: [
      for (final rival in _save.document.race.rivals) rival.unlocked,
    ],
    summary: RecordsSummary.of(
      _save.document,
      levelCount: _levels.levelCount,
      starLevels: StarRules.levelsWithPar(_levels),
    ),
  );

  @override
  Future<void> close() async {
    await _saveChanges.cancel();
    return super.close();
  }
}
