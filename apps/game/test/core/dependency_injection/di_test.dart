import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/ads/ads_service.dart';
import 'package:nesty_game/core/services/ads/fake_ads_service.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
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
import 'package:nesty_game/core/services/save/save_service.dart';
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
  expect(get<AppRouter>(), same(get<AppRouter>()));
  expect(get<LanguageCubit>(), same(get<LanguageCubit>()));
  // Feature cubits are factories: a fresh one per route.
  final splash = get<SplashCubit>();
  final home = get<HomeCubit>();
  expect(get<SplashCubit>(), isNot(same(splash)));
  addTearDown(splash.close);
  addTearDown(home.close);
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
    expect(get<HapticsService>(), isA<SystemHapticsService>());
    // TODO(M3/M4/M6): flip these as real implementations land.
    expect(get<AdsService>(), isA<FakeAdsService>());
    expect(get<SaveService>(), isA<FakeSaveService>());
    expect(get<LevelRepository>(), isA<FakeLevelRepository>());
  });
}
