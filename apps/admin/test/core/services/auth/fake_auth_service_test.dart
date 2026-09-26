import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart';

Matcher _throwsKind(AppExceptionKind kind) =>
    throwsA(isA<AppException>().having((e) => e.kind, 'kind', kind));

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  test('starts signed out', () {
    expect(auth.currentUser, isNull);
  });

  test('any non-empty credentials sign in an admin by default', () async {
    final changes = <AdminUser?>[];
    final subscription = auth.userChanges.listen(changes.add);
    addTearDown(subscription.cancel);

    final user = await auth.signIn(email: 'owner@example.com', password: 'pw');

    expect(user.email, 'owner@example.com');
    expect(user.isAdmin, isTrue);
    expect(auth.currentUser, user);
    await pumpEventQueue();
    expect(changes, [user]);
  });

  test('isAdmin = false signs in a user without an admins/{uid} doc', () async {
    auth.isAdmin = false;

    final user = await auth.signIn(email: 'guest@example.com', password: 'pw');

    expect(user.isAdmin, isFalse);
  });

  test('empty credentials are rejected like Firebase would', () async {
    await expectLater(
      auth.signIn(email: '', password: 'pw'),
      _throwsKind(AppExceptionKind.invalidCredentials),
    );
    await expectLater(
      auth.signIn(email: 'owner@example.com', password: ''),
      _throwsKind(AppExceptionKind.invalidCredentials),
    );
    expect(auth.currentUser, isNull);
  });

  test('failSignInWith forces the given failure', () async {
    auth.failSignInWith = AppExceptionKind.network;

    await expectLater(
      auth.signIn(email: 'owner@example.com', password: 'pw'),
      _throwsKind(AppExceptionKind.network),
    );
    expect(auth.currentUser, isNull);
    expect(auth.signInCount, 1);
  });

  test('signOut clears the user and announces it', () async {
    await auth.signIn(email: 'owner@example.com', password: 'pw');
    final changes = <AdminUser?>[];
    final subscription = auth.userChanges.listen(changes.add);
    addTearDown(subscription.cancel);

    await auth.signOut();

    expect(auth.currentUser, isNull);
    await pumpEventQueue();
    expect(changes, [null]);
  });
}
