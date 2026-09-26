import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/bundled_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/ads/ads_service.dart';
import 'package:nesty_game/core/services/ads/fake_ads_service.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/soloud_audio_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart';
import 'package:nesty_game/core/services/purchase/purchase_service.dart';
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/asset_skin_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/services/solver/fake_solver_service.dart';
import 'package:nesty_game/core/services/solver/isolate_solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
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
  expect(get<HapticsService>(), isNotNull);
  expect(get<LevelRepository>(), isNotNull);
  expect(get<SolverService>(), isNotNull);
  expect(get<SkinService>(), isNotNull);
  expect(get<FxLibrary>(), same(get<FxLibrary>()));
  expect(get<AppRouter>(), same(get<AppRouter>()));
  expect(get<LanguageCubit>(), same(get<LanguageCubit>()));
  // Feature cubits are factories: a fresh one per route.
  final splash = get<SplashCubit>();
  final home = get<HomeCubit>();
  final gameplay = get<GameplayBloc>();
  expect(get<SplashCubit>(), isNot(same(splash)));
  addTearDown(splash.close);
  addTearDown(home.close);
  addTearDown(gameplay.close);
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
    expect(get<SaveService>(), isA<FakeSaveService>());
    expect(get<SolverService>(), isA<FakeSolverService>());
    expect(get<SkinService>(), isA<FakeSkinService>());
    expect(get<FxLibrary>(), isA<FakeFxLibrary>());
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
    expect(get<HapticsService>(), isA<SystemHapticsService>());
    expect(get<SolverService>(), isA<IsolateSolverService>());
    expect(get<LevelRepository>(), isA<BundledLevelRepository>());
    expect(get<SkinService>(), isA<AssetSkinService>());
    expect(get<FxLibrary>(), isA<AssetFxLibrary>());
    // The in-memory save is M2's real one (D13); M3's persistent save
    // replaces it and it then only backs FakeSaveService.
    expect(get<SaveService>(), isA<InMemorySaveService>());
    expect(get<SaveService>(), isNot(isA<FakeSaveService>()));
    // TODO(M6): flip as AdMob lands.
    expect(get<AdsService>(), isA<FakeAdsService>());
  });
}
