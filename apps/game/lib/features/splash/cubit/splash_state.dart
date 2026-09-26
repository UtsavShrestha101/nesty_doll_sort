part of 'splash_cubit.dart';

/// What the splash loaded. Having data means "ready — go to Home".
@freezed
abstract class SplashState with _$SplashState {
  const factory SplashState({
    /// Levels available offline after loading (0 until the M2 bundle).
    @Default(0) int levelCount,
  }) = _SplashState;
}
