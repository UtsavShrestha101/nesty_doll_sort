import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/app_info/app_info_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

/// Settings (frames 8.1, 8.2; spec §10.2 #13; docs/plans/m3-design.md
/// §10.2): the Sound/Music/Haptics toggles and Color symbols write only
/// `DatabaseService` (D14 note); the footer reads [AppInfoService] once and
/// [SaveService.playerId] (already loaded by the splash).
@injectable
class SettingsCubit extends BaseAsyncCubit<SettingsState> {
  SettingsCubit(this._database, this._appInfo, this._save);

  final DatabaseService _database;
  final AppInfoService _appInfo;
  final SaveService _save;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async {
      final info = await _appInfo.load();
      return SettingsState(
        soundEnabled: _database.soundEnabled,
        musicEnabled: _database.musicEnabled,
        hapticsEnabled: _database.hapticsEnabled,
        symbolsMode: _database.symbolsMode,
        version: info.version,
        buildNumber: info.buildNumber,
        playerId: _save.playerId,
      );
    });
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setSoundEnabled(enabled);
      return current.copyWith(soundEnabled: enabled);
    });
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setMusicEnabled(enabled);
      return current.copyWith(musicEnabled: enabled);
    });
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setHapticsEnabled(enabled);
      return current.copyWith(hapticsEnabled: enabled);
    });
  }

  /// "Color symbols": Subtle | Large (boards rebuild their bodies, D45).
  Future<void> setSymbolsMode(SymbolsMode mode) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setSymbolsMode(mode);
      return current.copyWith(symbolsMode: mode);
    });
  }
}
