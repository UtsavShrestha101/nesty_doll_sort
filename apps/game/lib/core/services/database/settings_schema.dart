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

  /// The app's language: [LocaleSetting.system] (follow the phone; the
  /// default) or a pinned locale code such as `de` or `pt_BR`.
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

  /// The relight Home's Daily tile last glowed for (m7-4 4.10,
  /// `motion.relitHome`): the `yyyy-MM-dd` of the solve that relit the
  /// paused streak, a string. Missing reads as none.
  static const relitGlowSeen = 'relitGlowSeen';

  /// The rival (1–3) the player last started a race against (m7-4 4.5):
  /// rival select's pick on a new visit when no rival is New. An int;
  /// missing reads as 0 (none).
  static const lastRival = 'lastRival';

  /// The reminder's four keys, which `DatabaseService.reminderChanges`
  /// follows.
  static const reminder = [
    reminderOn,
    reminderHour,
    reminderMinute,
    reminderOffered,
  ];
}

/// The values of [SettingsKeys.locale] that are not a locale code.
abstract final class LocaleSetting {
  /// Follow the phone's language list: the first supported language in it,
  /// else English (`AppLocaleResolver`; M7 phase 5B, l10n plan §1.4). A
  /// language picked in Settings' sheet replaces it with that code.
  static const system = 'system';
}

/// Defaults for a fresh install — spec §13.3
/// `{"sound": true, "music": true, "haptics": true, "symbols": "subtle",
/// "locale": "en"}`, except [symbols], which the owner made `large`
/// (PROGRESS D91), and [locale], which follows the phone (M7 phase 5B: a
/// recorded deviation from §13.3's example "en"; the same key, so no schema
/// step), plus spec-prop §13.3's `"relaxed": false` and
/// `"reduceMotion": "system"`. Every [DatabaseService] implementation reads
/// these, so the fake and Hive versions can't disagree.
abstract final class SettingsDefaults {
  static const sound = true;
  static const music = true;
  static const haptics = true;
  static const symbols = SymbolsMode.large;

  /// Follow the phone. An install that never picked a language (no stored
  /// key) reads this too, so it opens in the phone's language when that is
  /// supported; a stored code, `en` included, stays pinned.
  static const locale = LocaleSetting.system;

  /// Off on a fresh install (spec-prop §8).
  static const relaxed = false;

  /// Follow the system (spec-prop §16).
  static const reduceMotion = ReduceMotionMode.system;

  /// Off, at 19:00, never offered (spec-prop §7.9 "off until the player
  /// accepts"; plan decision 15).
  static const reminder = ReminderSettings();
}
