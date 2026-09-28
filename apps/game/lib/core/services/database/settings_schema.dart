import 'package:nesty_game/core/models/symbols_mode.dart';

/// Persisted keys of the settings box — spec §13.3 `"settings"`.
///
/// These strings are a storage contract, like Hive typeIds: never rename or
/// reuse one. Retire a key by leaving it out and documenting it here.
abstract final class SettingsKeys {
  static const sound = 'sound';
  static const music = 'music';
  static const haptics = 'haptics';
  static const symbols = 'symbols';
  static const locale = 'locale';
}

/// Defaults for a fresh install — spec §13.3
/// `{"sound": true, "music": true, "haptics": true, "symbols": "subtle",
/// "locale": "en"}`, except [symbols], which the owner made `large`
/// (PROGRESS D91). Every [DatabaseService] implementation reads these, so
/// the fake and Hive versions can't disagree.
abstract final class SettingsDefaults {
  static const sound = true;
  static const music = true;
  static const haptics = true;
  static const symbols = SymbolsMode.large;
  static const locale = 'en';
}
