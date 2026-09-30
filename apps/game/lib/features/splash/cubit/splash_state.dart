part of 'splash_cubit.dart';

/// What the splash has loaded. `loading` carries the progress; `data` means
/// "ready": go to Home, or to Level 1 on a first launch (E9).
@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState({
    /// 0–1, the loader bar (`ui_splash_loader`'s frame = progress %).
    @Default(0) double progress,

    /// Levels available offline after loading.
    @Default(0) int levelCount,

    /// No level has been won yet (E9, spec-prop §10.1; docs/plans/
    /// m7-design.md §13): the splash opens Level 1 (its tutorial, or the
    /// board a kill left) instead of Home. The gameplay-bloc lane sets it
    /// from the save and the splash page follows it.
    @Default(false) bool opensFirstLevel,
  }) = _SplashState;
}
