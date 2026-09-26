part of 'session_cubit.dart';

@freezed
abstract class SessionState with _$SessionState {
  const factory SessionState({
    /// The signed-in user, or `null` when signed out.
    AdminUser? user,
  }) = _SessionState;
}
