/// Hive box names. Like typeIds these are a storage contract: renaming a box
/// orphans the data in the old one.
abstract final class HiveBoxes {
  /// Sub-directory of the app documents folder that holds every box, so Hive
  /// files never mix with other data.
  static const directory = 'hive';

  /// Device settings, one entry per `SettingsKeys` key.
  static const settings = 'settings';

  /// The save document (spec §13.3, D63; docs/plans/m3-design.md §3): one
  /// JSON text under [SaveBoxKeys.document], plus its backups.
  static const save = 'save';
}

/// Keys of the [HiveBoxes.save] box (a storage contract, like the box
/// names).
abstract final class SaveBoxKeys {
  /// The save document as JSON text. One `put` of it is one CRC-checked
  /// Hive frame: a write torn by a crash is dropped when the box reopens,
  /// and the previous document survives (spec §13.3's atomic write).
  static const document = 'doc';

  /// The raw text of a stored document of [schema], kept before its first
  /// migration or overwrite (m3-design §3.2).
  static String backup(int schema) => 'doc_backup_v$schema';

  /// The raw text of a stored document that wasn't a JSON object.
  static const invalidBackup = 'doc_backup_invalid';
}
