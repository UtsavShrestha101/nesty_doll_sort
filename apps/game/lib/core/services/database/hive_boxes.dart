/// Hive box names. Like typeIds these are a storage contract: renaming a box
/// orphans the data in the old one.
abstract final class HiveBoxes {
  /// Sub-directory of the app documents folder that holds every box, so Hive
  /// files never mix with the M3 save file (spec §13.3) or other data.
  static const directory = 'hive';

  /// Device settings, one entry per `SettingsKeys` key.
  static const settings = 'settings';
}
