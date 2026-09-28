import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/bundled_level_repository.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';
import 'package:nesty_game/core/repository/default_level_resolver.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/router/music_route_observer.dart';
import 'package:nesty_game/core/services/ads/ads_service.dart';
import 'package:nesty_game/core/services/ads/fake_ads_service.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/app_info/app_info_service.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';
import 'package:nesty_game/core/services/app_info/package_app_info_service.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/audio/soloud_engine_host.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/generator/isolate_level_generator_service.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart';
import 'package:nesty_game/core/services/links/fake_link_launcher.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';
import 'package:nesty_game/core/services/links/url_link_launcher.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/music/soloud_music_service.dart';
import 'package:nesty_game/core/services/purchase/purchase_service.dart';
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_lifecycle_flusher.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/asset_skin_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/services/solver/fake_solver_service.dart';
import 'package:nesty_game/core/services/solver/isolate_solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';

import '../../helpers/test_dependencies.dart';

/// Every type the app resolves, so a missing or duplicated registration in
/// either environment fails here instead of at runtime.
void _expectEverythingResolves() {
  expect(get<DatabaseService>(), isNotNull);
  expect(get<AdsService>(), isNotNull);
  expect(get<PurchaseService>(), isNotNull);
  expect(get<AnalyticsService>(), isNotNull);
  expect(get<RemoteConfigService>(), isNotNull);
  expect(get<SaveService>(), isNotNull);
  expect(get<AudioService>(), isNotNull);
  // One service plays the SFX and the jingles (AudioModule).
  expect(get<JinglePlayer>(), same(get<AudioService>()));
  expect(get<MusicService>(), same(get<MusicService>()));
  expect(get<JingleCues>(), same(get<JingleCues>()));
  expect(get<HapticsService>(), isNotNull);
  expect(get<LevelRepository>(), isNotNull);
  expect(get<SolverService>(), isNotNull);
  expect(get<SkinService>(), isNotNull);
  // M3 contracts (docs/plans/m3-design.md §11).
  expect(get<AppClock>(), same(get<AppClock>()));
  expect(get<CatalogRepository>(), same(get<CatalogRepository>()));
  expect(get<LevelGeneratorService>(), same(get<LevelGeneratorService>()));
  // Both envs (m3-design §11): one implementation, never the unit-test-only
  // fakes.
  expect(get<LevelResolver>(), isA<DefaultLevelResolver>());
  expect(get<DailyService>(), isA<StreakDailyService>());
  expect(get<AppInfoService>(), same(get<AppInfoService>()));
  expect(get<LinkLauncher>(), same(get<LinkLauncher>()));
  expect(get<SaveLifecycleFlusher>(), same(get<SaveLifecycleFlusher>()));
  expect(get<FxLibrary>(), same(get<FxLibrary>()));
  expect(get<AppRouter>(), same(get<AppRouter>()));
  expect(get<LanguageCubit>(), same(get<LanguageCubit>()));
  // A navigator takes its own observer.
  expect(get<MusicRouteObserver>(), isNot(same(get<MusicRouteObserver>())));
  // Feature cubits are factories: a fresh one per route.
  final splash = get<SplashCubit>();
  expect(get<SplashCubit>(), isNot(same(splash)));
  // Every page cubit resolves: a constructor parameter DI can't supply
  // (a test-only knob missing `@ignoreParam`) only fails when its route
  // opens.
  for (final cubit in <BlocBase<Object?>>[
    splash,
    get<HomeCubit>(),
    get<GameplayBloc>(),
    get<DailyCubit>(),
    get<MuseumCubit>(),
    get<SettingsCubit>(),
    get<ShopCubit>(),
    get<SkinDetailCubit>(),
  ]) {
    addTearDown(cubit.close);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(resetDependencies);

  test('fake env wires the in-memory fakes everywhere', () async {
    await configureTestDependencies();

    _expectEverythingResolves();
    expect(get<DatabaseService>(), isA<FakeDatabaseService>());
    expect(get<RemoteConfigService>(), isA<FakeRemoteConfigService>());
    expect(get<HapticsService>(), isA<FakeHapticsService>());
    expect(get<AudioService>(), isA<FakeAudioService>());
    expect(get<MusicService>(), isA<FakeMusicService>());
    expect(get<SaveService>(), isA<FakeSaveService>());
    expect(get<SolverService>(), isA<FakeSolverService>());
    expect(get<SkinService>(), isA<FakeSkinService>());
    expect(get<FxLibrary>(), isA<FakeFxLibrary>());
    expect(get<AppClock>(), isA<FakeClock>());
    expect(get<CatalogRepository>(), isA<FakeCatalogRepository>());
    expect(get<LevelGeneratorService>(), isA<FakeLevelGeneratorService>());
    expect(get<AppInfoService>(), isA<FakeAppInfoService>());
    expect(get<LinkLauncher>(), isA<FakeLinkLauncher>());
    // The fake env plays levels 1–3 (copies of the bundled L0001–L0003).
    final levels = get<LevelRepository>();
    expect(levels, isA<FakeLevelRepository>());
    await levels.load();
    expect(levels.levelCount, 3);
  });

  test('real env uses real implementations where they exist, fakes otherwise, '
      'and survives Hive failing to open', () async {
    await get.reset();
    // No path_provider plugin under flutter_test, so Hive.initFlutter throws:
    // this exercises the same graceful in-memory fallback a device without
    // usable storage would get.
    await configureDependencies(environment: AppEnv.real);

    _expectEverythingResolves();
    expect(get<DatabaseService>(), isA<FakeDatabaseService>());
    expect(get<RemoteConfigService>(), isA<DefaultsRemoteConfigService>());
    // M2's real implementations (docs/plans/m2-lottie-design.md §16).
    expect(get<AudioService>(), isA<SoLoudAudioService>());
    // The SFX and the music share one engine host (post-M2 audio).
    expect(get<MusicService>(), isA<SoLoudMusicService>());
    expect(get<SoLoudEngineHost>(), same(get<SoLoudEngineHost>()));
    expect(get<HapticsService>(), isA<SystemHapticsService>());
    expect(get<SolverService>(), isA<IsolateSolverService>());
    expect(get<LevelRepository>(), isA<BundledLevelRepository>());
    expect(get<SkinService>(), isA<AssetSkinService>());
    expect(get<FxLibrary>(), isA<AssetFxLibrary>());
    expect(get<AppClock>(), isA<SystemClock>());
    expect(get<CatalogRepository>(), isA<BundledCatalogRepository>());
    expect(get<LevelGeneratorService>(), isA<IsolateLevelGeneratorService>());
    expect(get<AppInfoService>(), isA<PackageAppInfoService>());
    expect(get<LinkLauncher>(), isA<UrlLinkLauncher>());
    // M3's persistent save (HiveSaveService extends InMemorySaveService,
    // which now only backs FakeSaveService, m3-design §3.2).
    expect(get<SaveService>(), isA<HiveSaveService>());
    expect(get<SaveService>(), isA<InMemorySaveService>());
    expect(get<SaveService>(), isNot(isA<FakeSaveService>()));
    // TODO(M6): flip as AdMob lands.
    expect(get<AdsService>(), isA<FakeAdsService>());
  });
}
