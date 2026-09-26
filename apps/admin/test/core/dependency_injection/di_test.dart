import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/app/session_cubit/session_cubit.dart';
import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/core/router/app_router.dart';
import 'package:nesty_admin/core/router/auth_guard.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart';
import 'package:nesty_admin/core/services/auth/unconfigured_auth_service.dart';
import 'package:nesty_admin/features/login/cubit/login_cubit.dart';

import '../../helpers/test_dependencies.dart';

/// Every type the app resolves, so a missing or duplicated registration in
/// either environment fails here instead of at runtime.
void _expectEverythingResolves() {
  expect(get<AuthService>(), same(get<AuthService>()));
  expect(get<AuthGuard>(), same(get<AuthGuard>()));
  expect(get<AppRouter>(), same(get<AppRouter>()));
  expect(get<SessionCubit>(), same(get<SessionCubit>()));
  // Page cubits are factories: a fresh one per route.
  final login = get<LoginCubit>();
  addTearDown(login.close);
  final another = get<LoginCubit>();
  addTearDown(another.close);
  expect(another, isNot(same(login)));
}

void main() {
  tearDown(resetDependencies);

  test('fake env wires the in-memory fakes', () async {
    await configureTestDependencies();

    _expectEverythingResolves();
    expect(get<AuthService>(), isA<FakeAuthService>());
  });

  test('real env lets nobody sign in until M5', () async {
    await get.reset();
    await configureDependencies(environment: AppEnv.real);

    _expectEverythingResolves();
    // TODO(M5): FirebaseAuthService.
    expect(get<AuthService>(), isA<UnconfiguredAuthService>());
  });
}
