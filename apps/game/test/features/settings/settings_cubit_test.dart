import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';

void main() {
  blocTest<SettingsCubit, AsyncValue<SettingsState>>(
    'reads the toggles, the symbols mode, the app info and the player id',
    build: () {
      final database = FakeDatabaseService();
      final save = FakeSaveService();
      return SettingsCubit(database, FakeAppInfoService(), save);
    },
    setUp: () async {},
    act: (cubit) => cubit.load(),
    expect: () => [
      const AsyncValue<SettingsState>.loading(),
      predicate<AsyncValue<SettingsState>>((v) {
        final data = v.data;
        return data != null &&
            data.soundEnabled &&
            data.musicEnabled &&
            data.hapticsEnabled &&
            data.symbolsMode == SymbolsMode.large &&
            data.version == '1.0.0' &&
            data.buildNumber == '42';
      }),
    ],
  );

  test('the player id comes from SaveService.load, once it has run', () async {
    final save = FakeSaveService();
    await save.load();
    final cubit = SettingsCubit(
      FakeDatabaseService(),
      FakeAppInfoService(),
      save,
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.playerId, save.playerId);
    expect(cubit.state.data?.playerId, isNotEmpty);
  });

  test('toggles write DatabaseService only, and update the state', () async {
    final database = FakeDatabaseService();
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      FakeSaveService(),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.setSoundEnabled(false);
    expect(cubit.state.data?.soundEnabled, isFalse);
    expect(database.soundEnabled, isFalse);

    await cubit.setMusicEnabled(false);
    expect(cubit.state.data?.musicEnabled, isFalse);
    expect(database.musicEnabled, isFalse);

    await cubit.setHapticsEnabled(false);
    expect(cubit.state.data?.hapticsEnabled, isFalse);
    expect(database.hapticsEnabled, isFalse);

    await cubit.setSymbolsMode(SymbolsMode.subtle);
    expect(cubit.state.data?.symbolsMode, SymbolsMode.subtle);
    expect(database.symbolsMode, SymbolsMode.subtle);
  });

  test('a toggle before load does nothing (no data to update yet)', () async {
    final database = FakeDatabaseService();
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      FakeSaveService(),
    );
    addTearDown(cubit.close);
    await cubit.setSoundEnabled(false);
    expect(cubit.state.hasData, isFalse);
  });
}
