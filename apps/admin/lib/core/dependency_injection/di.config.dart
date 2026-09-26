// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:nesty_admin/app/session_cubit/session_cubit.dart' as _i16;
import 'package:nesty_admin/core/router/app_router.dart' as _i293;
import 'package:nesty_admin/core/router/auth_guard.dart' as _i946;
import 'package:nesty_admin/core/services/auth/auth_service.dart' as _i741;
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart' as _i495;
import 'package:nesty_admin/core/services/auth/unconfigured_auth_service.dart'
    as _i289;
import 'package:nesty_admin/features/login/cubit/login_cubit.dart' as _i469;

const String _real = 'real';
const String _fake = 'fake';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i741.AuthService>(
      () => _i289.UnconfiguredAuthService(),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i741.AuthService>(
      () => _i495.FakeAuthService(),
      registerFor: {_fake},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i16.SessionCubit>(
      () => _i16.SessionCubit(gh<_i741.AuthService>()),
      dispose: (i) => i.close(),
    );
    gh.factory<_i469.LoginCubit>(
      () => _i469.LoginCubit(gh<_i741.AuthService>()),
    );
    gh.lazySingleton<_i946.AuthGuard>(
      () => _i946.AuthGuard(gh<_i741.AuthService>()),
    );
    gh.lazySingleton<_i293.AppRouter>(
      () => _i293.AppRouter(gh<_i946.AuthGuard>()),
    );
    return this;
  }
}
