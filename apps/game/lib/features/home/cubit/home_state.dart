part of 'home_cubit.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// Level the big play button starts (spec §10.2 #2).
    @Default(1) int currentLevel,
  }) = _HomeState;
}
