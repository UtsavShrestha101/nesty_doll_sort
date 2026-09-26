import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';

part 'session_cubit.freezed.dart';
part 'session_state.dart';

/// Who is signed in, app-wide.
///
/// [AuthService] is the source of truth: this cubit seeds from
/// `currentUser` and follows `userChanges`, so a sign-in from the login form,
/// a sign-out button or (M5) a session revoked elsewhere all reach `App`,
/// which re-enters the router so `AuthGuard` can decide where the user
/// belongs.
@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(AuthService auth)
    : _auth = auth,
      super(SessionState(user: auth.currentUser)) {
    _subscription = _auth.userChanges.listen(_update);
  }

  final AuthService _auth;
  late final StreamSubscription<AdminUser?> _subscription;

  /// Signs out. A failure is logged and leaves the session as it was; there
  /// is nothing to show but "try again", which the button already offers.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Object catch (error, stackTrace) {
      developer.log(
        'Sign-out failed',
        name: 'nesty_admin.session',
        error: error,
        stackTrace: stackTrace,
      );
    }
    // Read back instead of waiting for the stream, so the outcome doesn't
    // depend on event timing; the stream's later echo is then a no-op.
    _update(_auth.currentUser);
  }

  /// Emits only real changes. Cubit's own equality check does not cover
  /// this: bloc always lets a cubit's FIRST emit through, even when it equals
  /// the seeded state (e.g. Firebase replaying the current user on listen).
  void _update(AdminUser? user) {
    if (isClosed || user == state.user) return;
    emit(SessionState(user: user));
  }

  @override
  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
