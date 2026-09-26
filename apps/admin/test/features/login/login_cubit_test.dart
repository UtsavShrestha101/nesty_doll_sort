import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart';
import 'package:nesty_admin/features/login/cubit/login_cubit.dart';

const _admin = AdminUser(
  uid: 'fake-owner@example.com',
  email: 'owner@example.com',
  isAdmin: true,
);

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  blocTest<LoginCubit, AsyncValue<AdminUser>>(
    'signs in, trimming the email but never the password',
    build: () => LoginCubit(auth),
    act: (cubit) =>
        cubit.signIn(email: '  owner@example.com ', password: ' pw '),
    expect: () => const [
      AsyncValue<AdminUser>.loading(),
      AsyncValue<AdminUser>.data(data: _admin),
    ],
    verify: (_) => expect(auth.currentUser, _admin),
  );

  blocTest<LoginCubit, AsyncValue<AdminUser>>(
    'a non-admin still signs in: access is the guard’s decision',
    build: () => LoginCubit(auth..isAdmin = false),
    act: (cubit) => cubit.signIn(email: 'guest@example.com', password: 'pw'),
    expect: () => [
      const AsyncValue<AdminUser>.loading(),
      isA<AsyncValueData<AdminUser>>().having(
        (s) => s.data.isAdmin,
        'isAdmin',
        isFalse,
      ),
    ],
  );

  blocTest<LoginCubit, AsyncValue<AdminUser>>(
    'rejected credentials surface as an invalidCredentials error',
    build: () =>
        LoginCubit(auth..failSignInWith = AppExceptionKind.invalidCredentials),
    act: (cubit) => cubit.signIn(email: 'owner@example.com', password: 'nope'),
    expect: () => [
      const AsyncValue<AdminUser>.loading(),
      isA<AsyncValueError<AdminUser>>().having(
        (s) => s.exception.kind,
        'kind',
        AppExceptionKind.invalidCredentials,
      ),
    ],
    verify: (_) => expect(auth.currentUser, isNull),
  );

  blocTest<LoginCubit, AsyncValue<AdminUser>>(
    'a retry after an error keeps working',
    build: () => LoginCubit(auth),
    seed: () => const AsyncValue.error(
      exception: AppException(AppExceptionKind.network),
    ),
    act: (cubit) => cubit.signIn(email: 'owner@example.com', password: 'pw'),
    expect: () => const [
      AsyncValue<AdminUser>.loading(),
      AsyncValue<AdminUser>.data(data: _admin),
    ],
  );

  blocTest<LoginCubit, AsyncValue<AdminUser>>(
    'a second submit while one is in flight is ignored',
    build: () => LoginCubit(auth),
    act: (cubit) async {
      final first = cubit.signIn(email: 'owner@example.com', password: 'pw');
      await cubit.signIn(email: 'owner@example.com', password: 'pw');
      await first;
    },
    expect: () => const [
      AsyncValue<AdminUser>.loading(),
      AsyncValue<AdminUser>.data(data: _admin),
    ],
    verify: (_) => expect(auth.signInCount, 1),
  );
}
