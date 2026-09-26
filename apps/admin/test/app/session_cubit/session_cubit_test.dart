import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_admin/app/session_cubit/session_cubit.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart';

class _MockAuthService extends Mock implements AuthService {}

const _admin = AdminUser(
  uid: 'fake-owner@example.com',
  email: 'owner@example.com',
  isAdmin: true,
);

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  test('seeds from the service’s current user', () async {
    await auth.signIn(email: 'owner@example.com', password: 'pw');

    final cubit = SessionCubit(auth);
    addTearDown(cubit.close);

    expect(cubit.state, const SessionState(user: _admin));
  });

  blocTest<SessionCubit, SessionState>(
    'follows sign-ins and sign-outs made anywhere',
    build: () => SessionCubit(auth),
    act: (_) async {
      await auth.signIn(email: 'owner@example.com', password: 'pw');
      await pumpEventQueue();
      await auth.signOut();
    },
    expect: () => const [SessionState(user: _admin), SessionState()],
  );

  blocTest<SessionCubit, SessionState>(
    'signOut signs out through the service, once',
    setUp: () => auth.signIn(email: 'owner@example.com', password: 'pw'),
    build: () => SessionCubit(auth),
    act: (cubit) => cubit.signOut(),
    // The read-back emits the change; the stream's later echo is a no-op.
    expect: () => const [SessionState()],
    verify: (_) => expect(auth.currentUser, isNull),
  );

  blocTest<SessionCubit, SessionState>(
    'a failed sign-out is logged and keeps the session',
    build: () {
      final failing = _MockAuthService();
      when(() => failing.currentUser).thenReturn(_admin);
      when(
        () => failing.userChanges,
      ).thenAnswer((_) => const Stream<AdminUser?>.empty());
      when(failing.signOut).thenThrow(StateError('offline'));
      return SessionCubit(failing);
    },
    act: (cubit) => cubit.signOut(),
    expect: () => <SessionState>[],
    verify: (cubit) => expect(cubit.state.user, _admin),
  );
}
