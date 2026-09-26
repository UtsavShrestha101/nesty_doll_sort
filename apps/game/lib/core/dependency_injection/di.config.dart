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
import 'package:nesty_game/app/localization_cubit/language_cubit.dart' as _i571;
import 'package:nesty_game/core/dependency_injection/database_module.dart'
    as _i832;
import 'package:nesty_game/core/repository/fake_level_repository.dart' as _i3;
import 'package:nesty_game/core/repository/level_repository.dart' as _i789;
import 'package:nesty_game/core/router/app_router.dart' as _i655;
import 'package:nesty_game/core/services/ads/ads_service.dart' as _i746;
import 'package:nesty_game/core/services/ads/fake_ads_service.dart' as _i403;
import 'package:nesty_game/core/services/analytics/analytics_service.dart'
    as _i921;
import 'package:nesty_game/core/services/analytics/fake_analytics_service.dart'
    as _i974;
import 'package:nesty_game/core/services/audio/audio_service.dart' as _i890;
import 'package:nesty_game/core/services/audio/fake_audio_service.dart'
    as _i989;
import 'package:nesty_game/core/services/database/database_service.dart'
    as _i980;
import 'package:nesty_game/core/services/database/fake_database_service.dart'
    as _i916;
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart'
    as _i435;
import 'package:nesty_game/core/services/haptics/haptics_service.dart' as _i165;
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart'
    as _i684;
import 'package:nesty_game/core/services/purchase/fake_purchase_service.dart'
    as _i607;
import 'package:nesty_game/core/services/purchase/purchase_service.dart'
    as _i528;
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart'
    as _i916;
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart'
    as _i553;
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart'
    as _i567;
import 'package:nesty_game/core/services/save/fake_save_service.dart' as _i31;
import 'package:nesty_game/core/services/save/save_service.dart' as _i276;
import 'package:nesty_game/features/home/cubit/home_cubit.dart' as _i524;
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart' as _i724;

const String _fake = 'fake';
const String _real = 'real';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i655.AppRouter>(() => _i655.AppRouter());
    gh.lazySingleton<_i890.AudioService>(
      () => _i989.FakeAudioService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i528.PurchaseService>(
      () => _i607.FakePurchaseService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i276.SaveService>(
      () => _i31.FakeSaveService(),
      registerFor: {_fake, _real},
    );
    await gh.singletonAsync<_i980.DatabaseService>(
      () => databaseModule.database,
      registerFor: {_real},
      preResolve: true,
      dispose: _i832.closeDatabase,
    );
    gh.lazySingleton<_i567.RemoteConfigService>(
      () => _i916.DefaultsRemoteConfigService(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i746.AdsService>(
      () => _i403.FakeAdsService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i789.LevelRepository>(
      () => _i3.FakeLevelRepository(),
      registerFor: {_fake, _real},
    );
    gh.factory<_i724.SplashCubit>(
      () => _i724.SplashCubit(
        gh<_i276.SaveService>(),
        gh<_i789.LevelRepository>(),
      ),
    );
    gh.factory<_i524.HomeCubit>(() => _i524.HomeCubit(gh<_i276.SaveService>()));
    gh.lazySingleton<_i921.AnalyticsService>(
      () => _i974.FakeAnalyticsService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i165.HapticsService>(
      () => _i684.SystemHapticsService(gh<_i980.DatabaseService>()),
      registerFor: {_real},
    );
    gh.singleton<_i980.DatabaseService>(
      () => _i916.FakeDatabaseService(),
      registerFor: {_fake},
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i567.RemoteConfigService>(
      () => _i553.FakeRemoteConfigService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i165.HapticsService>(
      () => _i435.FakeHapticsService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i571.LanguageCubit>(
      () => _i571.LanguageCubit(gh<_i980.DatabaseService>()),
      dispose: (i) => i.close(),
    );
    return this;
  }
}

class _$DatabaseModule extends _i832.DatabaseModule {}
