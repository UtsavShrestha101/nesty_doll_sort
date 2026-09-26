import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';

/// In-memory [AuthService] for tests and for debug builds started with
/// `--dart-define=NESTY_FAKE_SERVICES=true`.
///
/// Any non-empty email and password signs in. Fake env only: registering it
/// for [AppEnv.real] would let anyone into a deployed admin panel.
@LazySingleton(as: AuthService, env: [AppEnv.fake])
class FakeAuthService implements AuthService {
  // Knobs are fields, not constructor parameters: injectable would try to
  // inject a constructor parameter (even an optional one) from DI.

  /// Whether users signed in through this fake are admins, i.e. have an
  /// `admins/{uid}` document (spec §15). Set it to false to exercise the
  /// Not authorized screen.
  bool isAdmin = true;

  /// When set, every sign-in fails with this kind (e.g.
  /// [AppExceptionKind.invalidCredentials] or [AppExceptionKind.network]).
  AppExceptionKind? failSignInWith;

  /// How many times [signIn] was called, for "submitted only once" tests.
  int signInCount = 0;

  AdminUser? _user;

  final StreamController<AdminUser?> _changes =
      StreamController<AdminUser?>.broadcast();

  @override
  AdminUser? get currentUser => _user;

  @override
  Stream<AdminUser?> get userChanges => _changes.stream;

  @override
  Future<AdminUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCount++;
    final forced = failSignInWith;
    if (forced != null) {
      throw AppException(forced, message: 'FakeAuthService: forced failure');
    }
    // Firebase rejects empty credentials too (invalid-email /
    // missing-password), so the fake does not accept what the real one won't.
    if (email.isEmpty || password.isEmpty) {
      throw const AppException(
        AppExceptionKind.invalidCredentials,
        message: 'FakeAuthService: empty email or password',
      );
    }
    final user = AdminUser(
      uid: 'fake-${email.toLowerCase()}',
      email: email,
      isAdmin: isAdmin,
    );
    _setUser(user);
    return user;
  }

  @override
  Future<void> signOut() async => _setUser(null);

  void _setUser(AdminUser? user) {
    _user = user;
    if (!_changes.isClosed) _changes.add(user);
  }

  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();
}
