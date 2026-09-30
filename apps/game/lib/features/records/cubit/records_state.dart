part of 'records_cubit.dart';

/// What the Records screen shows (E8; docs/plans/m7-design.md §12, §15.2).
@freezed
abstract class RecordsState with _$RecordsState {
  const factory RecordsState({
    /// The header's coin pill (`SaveService.coins`).
    @Default(0) int coins,

    /// The records and badges (`RecordsSummary.of`).
    @Default(RecordsSummary()) RecordsSummary summary,

    /// Whether each rival, 1–3, is unlocked (`race.rivals[i].unlocked`): a
    /// locked one shows the locked portrait and a dash (frame 10.6).
    @Default(<bool>[true, false, false]) List<bool> rivalsUnlocked,
  }) = _RecordsState;
}
