import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';

/// Local storage: device settings (spec §13.3 `"settings"`) and the raw
/// save document (§13.3, D63).
///
/// Implementations: `HiveDatabaseService` (real) and `FakeDatabaseService`
/// (in-memory; tests, fake env and the fallback when Hive can't open).
/// Every read is synchronous — boxes are opened once during bootstrap, never
/// lazily in features.
///
/// Only `SaveService` reads and writes the save document; it holds the
/// schema, the migrations and the lenient decoding (docs/plans/m3-design.md
/// §3). This layer stores its text as it is given.
abstract interface class DatabaseService {
  bool get soundEnabled;
  Future<void> setSoundEnabled(bool enabled);

  bool get musicEnabled;
  Future<void> setMusicEnabled(bool enabled);

  /// Emits the Music setting every time the stored value changes, including
  /// a rollback or deletion back to the default. Each emission equals what
  /// [musicEnabled] reads at that point. The music service follows it, so
  /// the Pause and Settings toggles only write the setting.
  Stream<bool> get musicEnabledChanges;

  bool get hapticsEnabled;
  Future<void> setHapticsEnabled(bool enabled);

  SymbolsMode get symbolsMode;
  Future<void> setSymbolsMode(SymbolsMode mode);

  /// Emits the Color symbols mode every time the stored value changes,
  /// including a rollback or deletion back to the default. Each emission
  /// equals what [symbolsMode] reads at that point. The art that bakes the
  /// symbols in (the Home shelf, the Shop cards, the Daily card) follows
  /// it, so a change made in Settings reaches the screens that stay mounted
  /// under it.
  Stream<SymbolsMode> get symbolsModeChanges;

  /// Relaxed mode (E6, spec-prop §8; m7-design §10): undo is free and
  /// unlimited in every mode. Off by default.
  bool get relaxedMode;
  Future<void> setRelaxedMode(bool enabled);

  /// Emits the Relaxed mode setting every time the stored value changes,
  /// including a rollback or deletion back to the default. Each emission
  /// equals what [relaxedMode] reads at that point. The gameplay bloc
  /// follows it, so a toggle made from Pause → Settings applies to the
  /// level in play.
  Stream<bool> get relaxedModeChanges;

  /// The in-app reduce-motion override (E14, spec-prop §16; m7-design
  /// §14). `ReduceMotionMode.system` by default.
  ReduceMotionMode get reduceMotion;
  Future<void> setReduceMotion(ReduceMotionMode mode);

  /// Emits the reduce-motion override every time the stored value changes,
  /// including a rollback or deletion back to the default. Each emission
  /// equals what [reduceMotion] reads at that point. The app root follows
  /// it (`MediaQuery.disableAnimations`).
  Stream<ReduceMotionMode> get reduceMotionChanges;

  /// The opt-in daily reminder (E4, spec-prop §7.9; m7-design P3.10):
  /// `SettingsDefaults.reminder` (off, 19:00, not offered) on a fresh
  /// install. A stored value of the wrong type, or a time outside 0–23 /
  /// 0–59, reads as its default.
  ReminderSettings get reminder;

  /// Stores all four reminder keys in one write (Hive: one `putAll`).
  Future<void> setReminder(ReminderSettings reminder);

  /// Emits the reminder settings after any of its four keys changes,
  /// including a rollback or deletion back to the default. Only a value
  /// that differs from the last one (from what was stored when the stream
  /// was taken) is emitted, so one [setReminder] emits once and a write of
  /// the same settings emits nothing. Each emission equals what [reminder]
  /// reads at that point. `DailyReminder` follows it and reschedules.
  Stream<ReminderSettings> get reminderChanges;

  /// The `yyyy-MM-dd` of the relight Home's Daily tile last glowed for, or
  /// null (m7-4 4.10, `motion.relitHome`: the first Home visit after a
  /// relight, in that session or a later one, once). A value of the wrong
  /// type reads as null.
  String? get relitGlowSeen;
  Future<void> setRelitGlowSeen(String date);

  /// The latest `yyyy-MM-dd` the app was opened or resumed, or null (local
  /// habits 1, plan-local-habits §1). A value of the wrong type reads as
  /// null. Only `WelcomeBackRules`' high-water mark writes it.
  String? get lastOpenDate;
  Future<void> setLastOpenDate(String date);

  /// The `yyyy-MM-dd` a welcome-back card belongs to, or null. Passing null
  /// to [setWelcomeBackDate] clears it (a dismissal).
  String? get welcomeBackDate;
  Future<void> setWelcomeBackDate(String? date);

  /// The rival (1–3) the player last started a race against, or 0 (m7-4
  /// 4.5: rival select's pick on a new visit is the New rival, else this
  /// one). A stored value outside 1–3 reads as 0.
  int get lastRival;
  Future<void> setLastRival(int rival);

  /// The persisted language setting, as stored: `LocaleSetting.system`
  /// (follow the phone; the default, also for an install that never stored
  /// one) or a pinned locale code such as `en` or `pt_BR`. It is not
  /// resolved here: `AppLocaleResolver` turns it into the language the app
  /// renders in.
  String get languageCode;
  Future<void> setLanguage(String languageCode);

  /// Emits the locale every time the stored value changes, including a
  /// rollback or deletion back to the default. Each emission equals what
  /// [languageCode] reads at that point.
  Stream<String> get languageStream;

  /// The stored save document text (`SaveBoxKeys.document`), or null when
  /// there is none or the stored value is not a string.
  String? readSaveDocument();

  /// Stores [json] as the save document: one write of one key.
  Future<void> writeSaveDocument(String json);

  /// The text kept under [key] of the save box (`SaveBoxKeys.backup`,
  /// `SaveBoxKeys.invalidBackup`), or null.
  String? readSaveBackup(String key);

  /// Keeps [json] under the save box's [key].
  Future<void> writeSaveBackup(String key, String json);

  /// Makes the save box's writes durable (Hive's `flush`). Called on
  /// `AppLifecycleState.paused`/`detached`.
  Future<void> flushSave();

  /// Flushes and closes the underlying storage. Called on DI reset.
  Future<void> close();
}

/// A [DatabaseService] that lives only as long as the process, in place of
/// the device's storage: the real env's fallback when Hive can't open
/// (`HiveDatabaseService.openOrFallback`). Its reads are the defaults, not
/// the player's choices, so a caller that mirrors a setting into the OS
/// (`DailyReminder`: never cancel a reminder an earlier session scheduled)
/// or does something only once (the reminder offer) checks
/// `is SessionOnlyDatabase` first (M7 review R30).
///
/// A marker rather than a getter on [DatabaseService], so no other
/// implementation or test double has to change.
abstract interface class SessionOnlyDatabase implements DatabaseService {}
