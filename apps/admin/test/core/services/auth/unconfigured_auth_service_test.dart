import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/services/auth/unconfigured_auth_service.dart';

/// The real-env stand-in until M5: a deployed skeleton must let nobody in.
void main() {
  final auth = UnconfiguredAuthService();

  test('nobody is ever signed in', () async {
    expect(auth.currentUser, isNull);
    expect(await auth.userChanges.isEmpty, isTrue);
  });

  test('every sign-in fails as an unreachable backend', () async {
    await expectLater(
      auth.signIn(email: 'owner@example.com', password: 'anything'),
      throwsA(
        isA<AppException>().having(
          (e) => e.kind,
          'kind',
          AppExceptionKind.network,
        ),
      ),
    );
    expect(auth.currentUser, isNull);
  });

  test('signOut is a harmless no-op', () async {
    await auth.signOut();
    expect(auth.currentUser, isNull);
  });
}
