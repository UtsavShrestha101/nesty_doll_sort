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
import 'package:nesty_game/core/dependency_injection/audio_module.dart' as _i54;
import 'package:nesty_game/core/dependency_injection/database_module.dart'
    as _i832;
import 'package:nesty_game/core/models/play_request.dart' as _i143;
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart'
    as _i92;
import 'package:nesty_game/core/repository/bundled_level_repository.dart'
    as _i795;
import 'package:nesty_game/core/repository/catalog_repository.dart' as _i885;
import 'package:nesty_game/core/repository/default_level_resolver.dart'
    as _i231;
import 'package:nesty_game/core/repository/fake_catalog_repository.dart'
    as _i82;
import 'package:nesty_game/core/repository/fake_level_repository.dart' as _i3;
import 'package:nesty_game/core/repository/level_repository.dart' as _i789;
import 'package:nesty_game/core/repository/level_resolver.dart' as _i969;
import 'package:nesty_game/core/router/app_router.dart' as _i655;
import 'package:nesty_game/core/router/music_route_observer.dart' as _i760;
import 'package:nesty_game/core/services/ads/ads_service.dart' as _i746;
import 'package:nesty_game/core/services/ads/fake_ads_service.dart' as _i403;
import 'package:nesty_game/core/services/analytics/analytics_service.dart'
    as _i921;
import 'package:nesty_game/core/services/analytics/fake_analytics_service.dart'
    as _i974;
import 'package:nesty_game/core/services/app_info/app_info_service.dart'
    as _i627;
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart'
    as _i471;
import 'package:nesty_game/core/services/app_info/package_app_info_service.dart'
    as _i5;
import 'package:nesty_game/core/services/audio/audio_service.dart' as _i890;
import 'package:nesty_game/core/services/audio/fake_audio_service.dart'
    as _i989;
import 'package:nesty_game/core/services/audio/jingle_player.dart' as _i249;
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart'
    as _i456;
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart'
    as _i927;
import 'package:nesty_game/core/services/clock/app_clock.dart' as _i376;
import 'package:nesty_game/core/services/clock/fake_clock.dart' as _i339;
import 'package:nesty_game/core/services/clock/system_clock.dart' as _i716;
import 'package:nesty_game/core/services/daily/daily_service.dart' as _i843;
import 'package:nesty_game/core/services/daily/streak_daily_service.dart'
    as _i590;
import 'package:nesty_game/core/services/database/database_service.dart'
    as _i980;
import 'package:nesty_game/core/services/database/fake_database_service.dart'
    as _i916;
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart'
    as _i1029;
import 'package:nesty_game/core/services/generator/isolate_level_generator_service.dart'
    as _i157;
import 'package:nesty_game/core/services/generator/level_generator_service.dart'
    as _i644;
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart'
    as _i435;
import 'package:nesty_game/core/services/haptics/haptics_service.dart' as _i165;
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart'
    as _i684;
import 'package:nesty_game/core/services/links/fake_link_launcher.dart'
    as _i917;
import 'package:nesty_game/core/services/links/link_launcher.dart' as _i902;
import 'package:nesty_game/core/services/links/url_link_launcher.dart' as _i945;
import 'package:nesty_game/core/services/music/fake_music_service.dart'
    as _i514;
import 'package:nesty_game/core/services/music/jingle_cues.dart' as _i489;
import 'package:nesty_game/core/services/music/music_service.dart' as _i777;
import 'package:nesty_game/core/services/music/soloud_music_service.dart'
    as _i869;
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart'
    as _i791;
import 'package:nesty_game/core/services/notifications/local_notification_service.dart'
    as _i542;
import 'package:nesty_game/core/services/notifications/notification_service.dart'
    as _i981;
import 'package:nesty_game/core/services/purchase/fake_purchase_service.dart'
    as _i607;
import 'package:nesty_game/core/services/purchase/purchase_service.dart'
    as _i528;
import 'package:nesty_game/core/services/reminder/daily_reminder.dart' as _i87;
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart'
    as _i916;
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart'
    as _i553;
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart'
    as _i567;
import 'package:nesty_game/core/services/save/fake_save_service.dart' as _i31;
import 'package:nesty_game/core/services/save/hive_save_service.dart' as _i486;
import 'package:nesty_game/core/services/save/save_lifecycle_flusher.dart'
    as _i649;
import 'package:nesty_game/core/services/save/save_service.dart' as _i276;
import 'package:nesty_game/core/services/share/fake_share_service.dart'
    as _i214;
import 'package:nesty_game/core/services/share/share_plus_share_service.dart'
    as _i186;
import 'package:nesty_game/core/services/share/share_service.dart' as _i307;
import 'package:nesty_game/core/services/skin/asset_skin_service.dart' as _i545;
import 'package:nesty_game/core/services/skin/fake_skin_service.dart' as _i1035;
import 'package:nesty_game/core/services/skin/skin_service.dart' as _i267;
import 'package:nesty_game/core/services/solver/fake_solver_service.dart'
    as _i56;
import 'package:nesty_game/core/services/solver/isolate_solver_service.dart'
    as _i714;
import 'package:nesty_game/core/services/solver/solver_service.dart' as _i488;
import 'package:nesty_game/core/services/system_settings/channel_system_settings_service.dart'
    as _i771;
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart'
    as _i60;
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart'
    as _i382;
import 'package:nesty_game/core/services/ticker/frame_ticker.dart' as _i408;
import 'package:nesty_game/core/services/ticker/scheduler_frame_ticker.dart'
    as _i687;
import 'package:nesty_game/core/ui/art/ui_art_library.dart' as _i73;
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart'
    as _i900;
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart' as _i151;
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart'
    as _i401;
import 'package:nesty_game/features/fx/asset_fx_library.dart' as _i986;
import 'package:nesty_game/features/fx/fake_fx_library.dart' as _i65;
import 'package:nesty_game/features/fx/fx_library.dart' as _i184;
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart' as _i83;
import 'package:nesty_game/features/home/cubit/home_cubit.dart' as _i524;
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart'
    as _i1053;
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart' as _i344;
import 'package:nesty_game/features/race/cubit/race_cubit.dart' as _i110;
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart' as _i74;
import 'package:nesty_game/features/records/cubit/records_cubit.dart' as _i677;
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart'
    as _i538;
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart' as _i865;
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart' as _i711;
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart' as _i724;

const String _real = 'real';
const String _fake = 'fake';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    final audioModule = _$AudioModule();
    gh.lazySingleton<_i307.ShareService>(
      () => _i186.SharePlusShareService(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i981.NotificationService>(
      () => _i542.LocalNotificationService(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i885.CatalogRepository>(
      () => _i92.BundledCatalogRepository(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i528.PurchaseService>(
      () => _i607.FakePurchaseService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i376.AppClock>(
      () => _i716.SystemClock(),
      registerFor: {_real},
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
    gh.lazySingleton<_i927.SoLoudEngineHost>(
      () => _i927.SoLoudEngineHost(),
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
    gh.lazySingleton<_i644.LevelGeneratorService>(
      () => _i157.IsolateLevelGeneratorService(),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i627.AppInfoService>(
      () => _i5.PackageAppInfoService(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i746.AdsService>(
      () => _i403.FakeAdsService(),
      registerFor: {_fake, _real},
    );
    gh.lazySingleton<_i382.SystemSettingsService>(
      () => _i771.ChannelSystemSettingsService(),
      registerFor: {_real},
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
    gh.lazySingleton<_i73.UiArtLibrary>(
      () => _i73.AssetUiArtLibrary(),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i902.LinkLauncher>(
      () => _i945.UrlLinkLauncher(),
      registerFor: {_real},
    );
    gh.lazySingleton<_i885.CatalogRepository>(
      () => _i82.FakeCatalogRepository(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i789.LevelRepository>(
      () => _i3.FakeLevelRepository.fixtures(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i307.ShareService>(
      () => _i214.FakeShareService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i382.SystemSettingsService>(
      () => _i60.FakeSystemSettingsService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i376.AppClock>(
      () => _i339.FakeClock(),
      registerFor: {_fake},
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
    gh.lazySingleton<_i989.FakeAudioService>(
      () => _i989.FakeAudioService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i902.LinkLauncher>(
      () => _i917.FakeLinkLauncher(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i184.FxLibrary>(
      () => _i65.FakeFxLibrary(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i567.RemoteConfigService>(
      () => _i553.FakeRemoteConfigService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i627.AppInfoService>(
      () => _i471.FakeAppInfoService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i73.UiArtLibrary>(
      () => _i73.FakeUiArtLibrary(),
      registerFor: {_fake},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i777.MusicService>(
      () => _i514.FakeMusicService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i276.SaveService>(
      () => _i31.FakeSaveService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i890.AudioService>(
      () => audioModule.fakeAudio(gh<_i989.FakeAudioService>()),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i249.JinglePlayer>(
      () => audioModule.fakeJingles(gh<_i989.FakeAudioService>()),
      registerFor: {_fake},
    );
    gh.factory<_i408.FrameTicker>(
      () => _i687.SchedulerFrameTicker(),
      registerFor: {_real, _fake},
    );
    gh.lazySingleton<_i644.LevelGeneratorService>(
      () => _i1029.FakeLevelGeneratorService(),
      registerFor: {_fake},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i777.MusicService>(
      () => _i869.SoLoudMusicService(
        gh<_i980.DatabaseService>(),
        gh<_i927.SoLoudEngineHost>(),
      ),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i165.HapticsService>(
      () => _i435.FakeHapticsService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i267.SkinService>(
      () => _i1035.FakeSkinService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i981.NotificationService>(
      () => _i791.FakeNotificationService(),
      registerFor: {_fake},
    );
    gh.lazySingleton<_i571.LanguageCubit>(
      () => _i571.LanguageCubit(gh<_i980.DatabaseService>()),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i456.SoLoudAudioService>(
      () => _i456.SoLoudAudioService(
        gh<_i980.DatabaseService>(),
        gh<_i927.SoLoudEngineHost>(),
      ),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i276.SaveService>(
      () => _i486.HiveSaveService(
        gh<_i980.DatabaseService>(),
        gh<_i567.RemoteConfigService>(),
      ),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i267.SkinService>(
      () => _i545.AssetSkinService(gh<_i276.SaveService>()),
      registerFor: {_real},
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i74.RivalSelectCubit>(
      () => _i74.RivalSelectCubit(
        gh<_i276.SaveService>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i980.DatabaseService>(),
      ),
    );
    gh.lazySingleton<_i1053.ShowcaseDolls>(
      () => _i1053.ShowcaseDolls(
        gh<_i267.SkinService>(),
        gh<_i980.DatabaseService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i677.RecordsCubit>(
      () => _i677.RecordsCubit(
        gh<_i276.SaveService>(),
        gh<_i789.LevelRepository>(),
      ),
    );
    gh.lazySingleton<_i649.SaveLifecycleFlusher>(
      () => _i649.SaveLifecycleFlusher(gh<_i276.SaveService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i655.ContentReadyGuard>(
      () => _i655.ContentReadyGuard(gh<_i789.LevelRepository>()),
    );
    gh.factoryParam<_i110.RaceCubit, _i143.RacePlay, dynamic>(
      (request, _) => _i110.RaceCubit(
        request,
        gh<_i276.SaveService>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i408.FrameTicker>(),
      ),
    );
    gh.lazySingleton<_i890.AudioService>(
      () => audioModule.realAudio(gh<_i456.SoLoudAudioService>()),
      registerFor: {_real},
    );
    gh.lazySingleton<_i249.JinglePlayer>(
      () => audioModule.realJingles(gh<_i456.SoLoudAudioService>()),
      registerFor: {_real},
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
    gh.factory<_i760.MusicRouteObserver>(
      () => _i760.MusicRouteObserver(gh<_i777.MusicService>()),
    );
    gh.lazySingleton<_i969.LevelResolver>(
      () => _i231.DefaultLevelResolver(
        gh<_i789.LevelRepository>(),
        gh<_i644.LevelGeneratorService>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i276.SaveService>(),
        gh<_i885.CatalogRepository>(),
      ),
      registerFor: {_real, _fake},
    );
    gh.lazySingleton<_i843.DailyService>(
      () => _i590.StreakDailyService(
        gh<_i276.SaveService>(),
        gh<_i376.AppClock>(),
        gh<_i567.RemoteConfigService>(),
      ),
      registerFor: {_real, _fake},
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i655.AppRouter>(
      () => _i655.AppRouter(gh<_i655.ContentReadyGuard>()),
    );
    gh.factory<_i344.MuseumCubit>(
      () => _i344.MuseumCubit(
        gh<_i276.SaveService>(),
        gh<_i885.CatalogRepository>(),
        gh<_i969.LevelResolver>(),
      ),
    );
    gh.factory<_i900.ChaptersCubit>(
      () => _i900.ChaptersCubit(
        gh<_i276.SaveService>(),
        gh<_i789.LevelRepository>(),
        gh<_i885.CatalogRepository>(),
        gh<_i567.RemoteConfigService>(),
      ),
    );
    gh.factory<_i524.HomeCubit>(
      () => _i524.HomeCubit(
        gh<_i276.SaveService>(),
        gh<_i789.LevelRepository>(),
        gh<_i969.LevelResolver>(),
        gh<_i843.DailyService>(),
        gh<_i885.CatalogRepository>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i980.DatabaseService>(),
      ),
    );
    gh.factory<_i151.DailyCubit>(
      () => _i151.DailyCubit(
        gh<_i843.DailyService>(),
        gh<_i969.LevelResolver>(),
        gh<_i276.SaveService>(),
        gh<_i567.RemoteConfigService>(),
      ),
    );
    gh.lazySingleton<_i489.JingleCues>(
      () =>
          _i489.JingleCues(gh<_i777.MusicService>(), gh<_i249.JinglePlayer>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i87.DailyReminder>(
      () => _i87.DailyReminder(
        gh<_i981.NotificationService>(),
        gh<_i980.DatabaseService>(),
        gh<_i843.DailyService>(),
        clock: gh<_i376.AppClock>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i83.GameplayBloc>(
      () => _i83.GameplayBloc(
        gh<_i789.LevelRepository>(),
        gh<_i488.SolverService>(),
        gh<_i567.RemoteConfigService>(),
        gh<_i276.SaveService>(),
        gh<_i921.AnalyticsService>(),
        gh<_i969.LevelResolver>(),
        gh<_i843.DailyService>(),
        gh<_i376.AppClock>(),
        gh<_i980.DatabaseService>(),
      ),
    );
    gh.factory<_i711.SkinDetailCubit>(
      () => _i711.SkinDetailCubit(
        gh<_i885.CatalogRepository>(),
        gh<_i276.SaveService>(),
        gh<_i267.SkinService>(),
        gh<_i921.AnalyticsService>(),
        gh<_i489.JingleCues>(),
      ),
    );
    gh.factory<_i401.ReminderOfferCubit>(
      () => _i401.ReminderOfferCubit(
        gh<_i87.DailyReminder>(),
        gh<_i980.DatabaseService>(),
        gh<_i843.DailyService>(),
        gh<_i376.AppClock>(),
        systemSettings: gh<_i382.SystemSettingsService>(),
      ),
    );
    gh.factory<_i538.SettingsCubit>(
      () => _i538.SettingsCubit(
        gh<_i980.DatabaseService>(),
        gh<_i627.AppInfoService>(),
        gh<_i276.SaveService>(),
        gh<_i87.DailyReminder>(),
        systemSettings: gh<_i382.SystemSettingsService>(),
      ),
    );
    gh.factory<_i865.ShopCubit>(
      () => _i865.ShopCubit(
        gh<_i885.CatalogRepository>(),
        gh<_i276.SaveService>(),
        gh<_i267.SkinService>(),
        gh<_i789.LevelRepository>(),
        gh<_i921.AnalyticsService>(),
        gh<_i489.JingleCues>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i832.DatabaseModule {}

class _$AudioModule extends _i54.AudioModule {}
