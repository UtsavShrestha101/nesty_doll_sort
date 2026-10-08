part of 'welcome_back_cubit.dart';

/// Whether Home carries the welcome-back card (plan-local-habits §1).
@freezed
sealed class WelcomeBackState with _$WelcomeBackState {
  /// No card: not away, dismissed, locked, solved today or a new date.
  const factory WelcomeBackState.hidden() = WelcomeBackHidden;

  /// The card shows, with the variant's line and the streak's number
  /// (the paused line names it).
  const factory WelcomeBackState.shown({
    required WelcomeBackVariant variant,
    required int streak,
  }) = WelcomeBackShown;
}
