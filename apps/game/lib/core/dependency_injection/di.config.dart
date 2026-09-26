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
import 'package:nesty_game/core/repository/bundled_level_repository.dart'
    as _i795;
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
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart'
    as _i456;
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
import 'package:nesty_game/core/services/save/in_memory_save_service.dart'
    as _i85;
import 'package:nesty_game/core/services/save/save_service.dart' as _i276;
import 'package:nesty_game/core/services/skin/asset_skin_service.dart' as _i545;
import 'package:nesty_game/core/services/skin/fake_skin_service.dart' as _i1035;
import 'package:nesty_game/core/services/skin/skin_service.dart' as _i267;
import 'package:nesty_game/core/services/solver/fake_solver_service.dart'
    as _i56;
import 'package:nesty_game/core/services/solver/isolate_solver_service.dart'
    as _i714;
import 'package:nesty_game/core/services/solver/solver_service.dart' as _i488;
import 'package:nesty_game/features/fx/asset_fx_library.dart' as _i986;
import 'package:nesty_game/features/fx/fake_fx_library.dart' as _i65;
import 'package:nesty_game/features/fx/fx_library.dart' as _i184;
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart' as _i83;
import 'package:nesty_game/features/home/cubit/home_cubit.dart' as _i524;
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart'
    as _i1053;
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
    gh.lazySingleton<_i528.PurchaseService>(
      () => _i607.FakePurchaseService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i267.SkinService>(
      () => _i545.AssetSkinService(),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i789.LevelRepository>(
      () => _i795.BundledLevelRepository(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i488.SolverService>(
      () => _i714.IsolateSolverService(),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
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
    gh.lazySingleton<_i890.AudioService>(
      () => _i456.SoLoudAudioService(gh<_i980.DatabaseService>()),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i921.AnalyticsService>(
      () => _i974.FakeAnalyticsService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i184.FxLibrary>(
      () => _i986.AssetFxLibrary(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i165.HapticsService>(
      () => _i684.SystemHapticsService(gh<_i980.DatabaseService>()),
      registerFor: {_real},
    );
    gh.lazySingleton<_i789.LevelRepository>(
      () => _i3.FakeLevelRepository.fixtures(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i276.SaveService>(
      () => _i85.InMemorySaveService(gh<_i567.RemoteConfigService>()),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i488.SolverService>(
      () => _i56.FakeSolverService(),
      registerFor: {_fake},
    );
    gh.singleton<_i980.DatabaseService>(
      () => _i916.FakeDatabaseService(),
      registerFor: {_fake},
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i184.FxLibrary>(
      () => _i65.FakeFxLibrary(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i567.RemoteConfigService>(
      () => _i553.FakeRemoteConfigService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i276.SaveService>(
      () => _i31.FakeSaveService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i890.AudioService>(
      () => _i989.FakeAudioService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i165.HapticsService>(
      () => _i435.FakeHapticsService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i267.SkinService>(
      () => _i1035.FakeSkinService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i571.LanguageCubit>(
      () => _i571.LanguageCubit(gh<_i980.DatabaseService>()),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i1053.ShowcaseDolls>(
      () => _i1053.ShowcaseDolls(
        gh<_i267.SkinService>(),
        gh<_i980.DatabaseService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i524.HomeCubit>(
      () =>
          _i524.HomeCubit(gh<_i276.SaveService>(), gh<_i789.LevelRepository>()),
    );
    gh.lazySingleton<_i655.ContentReadyGuard>(
      () => _i655.ContentReadyGuard(gh<_i789.LevelRepository>()),
    );
    gh.factory<_i83.GameplayBloc>(
      () => _i83.GameplayBloc(
        gh<_i789.LevelRepository>(),
        gh<_i488.SolverService>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i276.SaveService>(),
        gh<_i921.AnalyticsService>(),
      ),
    );
    gh.factory<_i724.SplashCubit>(
      () => _i724.SplashCubit(
        gh<_i276.SaveService>(),
        gh<_i789.LevelRepository>(),
        gh<_i184.FxLibrary>(),
        gh<_i267.SkinService>(),
        gh<_i890.AudioService>(),
        gh<_i1053.ShowcaseDolls>(),
      ),
    );
    gh.lazySingleton<_i655.AppRouter>(
      () => _i655.AppRouter(gh<_i655.ContentReadyGuard>()),
    );
    return this;
  }
}

class _$DatabaseModule extends _i832.DatabaseModule {}
