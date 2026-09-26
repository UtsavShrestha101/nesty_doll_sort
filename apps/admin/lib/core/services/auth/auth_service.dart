import 'package:nesty_admin/core/models/admin_user.dart';

/// Admin-panel authentication (spec §15 Auth): email/password sign-in, and
/// whether the signed-in uid has an `admins/{uid}` document (spec §14.1).
///
/// Implementations:
/// * `FakeAuthService` (fake env): in-memory, accepts any credentials.
/// * `UnconfiguredAuthService` (real env until M5): nobody can sign in.
/// * TODO(M5): `FirebaseAuthService` (real env): Firebase Auth sign-in, then
///   a read of `admins/{uid}` to set [AdminUser.isAdmin]. It must restore the
///   persisted web session BEFORE `runApp` (await the first
///   `authStateChanges()` event in a `@preResolve` module), because
///   `AuthGuard` reads [currentUser] synchronously on a page reload.
abstract interface class AuthService {
  /// The signed-in user, or `null`. Synchronous so `AuthGuard` can decide a
  /// navigation without waiting.
  AdminUser? get currentUser;

  /// The new [currentUser] after every sign-in and sign-out (and, in M5, a
  /// session revoked elsewhere). An implementation may also emit the current
  /// value on listen, as Firebase does, so listeners must tolerate repeats.
  Stream<AdminUser?> get userChanges;

  /// Signs in and returns the user, admin or not: access is `AuthGuard`'s
  /// decision, not the caller's.
  ///
  /// Throws `AppException` with `AppExceptionKind.invalidCredentials` when
  /// the email/password is rejected, or `AppExceptionKind.network` when the
  /// backend can't be reached.
  Future<AdminUser> signIn({required String email, required String password});

  Future<void> signOut();

  /// Releases the [userChanges] stream. Called by DI on `get.reset()` (tests);
  /// the running app keeps its one instance for its whole life. It's on the
  /// interface because injectable calls it through the bound type.
  Future<void> dispose();
}
