part of 'skin_detail_cubit.dart';

/// What the skin detail screen shows (frame 7.4; docs/plans/m3-design.md
/// §10.7): one skin, whether it's owned, whether it's the equipped one, and
/// the balance for its "You have N coins" line.
@freezed
abstract class SkinDetailState with _$SkinDetailState {
  const factory SkinDetailState({
    required SkinInfo skin,
    required bool owned,
    required bool equipped,
    required int coins,
  }) = _SkinDetailState;
}
