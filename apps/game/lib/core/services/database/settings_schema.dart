import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';

/// Persisted keys of the settings box — spec §13.3 `"settings"` (and
/// spec-prop §13.3's M7 additions; docs/plans/m7-design.md §4).
///
/// These strings are a storage contract, like Hive typeIds: never rename or
/// reuse one. Retire a key by leaving it out and documenting it here.
/// Settings are not save-document fields, so a new key needs no schema
/// step: a missing one reads as its default.
abstract final class SettingsKeys {
  static const sound = 'sound';
  static const music = 'music';
  static const haptics = 'haptics';
  static const symbols = 'symbols';
  static const locale = 'locale';

  /// Relaxed mode (E6, spec-prop §8): a bool.
  static const relaxed = 'relaxed';

  /// Reduce motion (E14, spec-prop §16): `ReduceMotionMode.storageValue`,
  /// `system`, `on` or `off`.
  static const reduceMotion = 'reduceMotion';

  // The opt-in daily reminder (E4, spec-prop §7.9, §13.3's `reminder`
  // object, stored flat; docs/plans/m7-design.md P3.10). `ReminderSettings`
  // reads and writes the four together.

  /// The player opted in: a bool.
  static const reminderOn = 'reminderOn';

  /// The reminder's local hour, an int 0–23.
  static const reminderHour = 'reminderHour';

  /// The reminder's minute, an int 0–59.
  static const reminderMinute = 'reminderMinute';

  /// The one-time offer has appeared ("offered once"): a bool.
  static const reminderOffered = 'reminderOffered';

  /// The reminder's four keys, which `DatabaseService.reminderChanges`
  /// follows.
  static const reminder = [
    reminderOn,
    reminderHour,
    reminderMinute,
    reminderOffered,
  ];
}

/// Defaults for a fresh install — spec §13.3
/// `{"sound": true, "music": true, "haptics": true, "symbols": "subtle",
/// "locale": "en"}`, except [symbols], which the owner made `large`
/// (PROGRESS D91), plus spec-prop §13.3's `"relaxed": false` and
/// `"reduceMotion": "system"`. Every [DatabaseService] implementation reads these, so
/// the fake and Hive versions can't disagree.
abstract final class SettingsDefaults {
  static const sound = true;
  static const music = true;
  static const haptics = true;
  static const symbols = SymbolsMode.large;
  static const locale = 'en';

  /// Off on a fresh install (spec-prop §8).
  static const relaxed = false;

  /// Follow the system (spec-prop §16).
  static const reduceMotion = ReduceMotionMode.system;

  /// Off, at 19:00, never offered (spec-prop §7.9 "off until the player
  /// accepts"; plan decision 15).
  static const reminder = ReminderSettings();
}
