import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';

/// Device settings a seeded run starts with, through `DatabaseService`'s own
/// setters (so the keys are the app's `SettingsKeys`, never re-typed here).
/// Null leaves a setting at its default.
final class SeededSettings {
  const SeededSettings({
    this.relaxedMode,
    this.reminder,
    this.sound,
    this.music,
    this.haptics,
  });

  final bool? relaxedMode;
  final ReminderSettings? reminder;
  final bool? sound;
  final bool? music;
  final bool? haptics;
}

/// Starts a device check from a known save (phase 4 architecture §6.6,
/// §7.3): writes [document] (schema 2, as `SaveDocumentCodec.write` makes it)
/// and [settings] into the app's own Hive boxes, then closes them, so the
/// `app.main()` that follows loads them as a returning player's.
///
/// Call it before `app.main()`, from a fresh install (`nesty-test` installs
/// fresh), e.g. a 6-day streak for the day-7 chest, past Level 20 for vs
/// Computer, three families for the Museum. It writes nothing else: the
/// splash's own load (and the star backfill) runs as on any launch.
Future<void> seedSave(
  SaveDocument document, {
  SeededSettings settings = const SeededSettings(),
}) async {
  final database = await HiveDatabaseService.open();
  try {
    await database.writeSaveDocument(SaveDocumentCodec.write(document));
    await database.flushSave();
    if (settings.relaxedMode case final on?) {
      await database.setRelaxedMode(on);
    }
    if (settings.reminder case final reminder?) {
      await database.setReminder(reminder);
    }
    if (settings.sound case final on?) await database.setSoundEnabled(on);
    if (settings.music case final on?) await database.setMusicEnabled(on);
    if (settings.haptics case final on?) {
      await database.setHapticsEnabled(on);
    }
  } finally {
    // The app opens the boxes itself (`DatabaseModule`); Hive's own
    // `initFlutter` then finds these files.
    await database.close();
  }
}
