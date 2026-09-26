part of 'splash_cubit.dart';

/// What the splash has loaded. `loading` carries the progress; `data` means
/// "ready — go to Home".
@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState({
    /// 0–1, the loader bar (`ui_splash_loader`'s frame = progress %).
    @Default(0) double progress,

    /// Levels available offline after loading.
    @Default(0) int levelCount,
  }) = _SplashState;
}
