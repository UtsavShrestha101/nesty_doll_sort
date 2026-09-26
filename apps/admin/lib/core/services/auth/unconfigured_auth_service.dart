import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';

/// The [AppEnv.real] [AuthService] until M5 adds `FirebaseAuthService`.
///
/// There is no auth backend yet, so nobody can sign in: a deployed build of
/// the skeleton must never get past Login. Sign-in fails like an unreachable
/// backend, which the login form already knows how to show.
///
/// TODO(M5): delete this class when `FirebaseAuthService` registers for
/// [AppEnv.real] (spec §15 Auth).
@LazySingleton(as: AuthService, env: [AppEnv.real])
class UnconfiguredAuthService implements AuthService {
  @override
  AdminUser? get currentUser => null;

  @override
  Stream<AdminUser?> get userChanges => const Stream<AdminUser?>.empty();

  @override
  Future<AdminUser> signIn({
    required String email,
    required String password,
  }) async => throw const AppException(
    AppExceptionKind.network,
    message:
        'No auth backend is configured until M5 (FirebaseAuthService). '
        'Debug builds can sign in with --dart-define=NESTY_FAKE_SERVICES=true.',
  );

  @override
  Future<void> signOut() async {}

  @override
  @disposeMethod
  Future<void> dispose() async {}
}
