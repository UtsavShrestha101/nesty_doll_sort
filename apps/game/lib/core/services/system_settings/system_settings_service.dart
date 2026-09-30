/// Opens the phone's own settings for Nesty (Q140's design answer: frames
/// 10.2d and 10.2f's "Open phone settings"; phase 4 architecture §3.8), so a
/// player whose phone blocks Nesty's notifications can allow them without
/// hunting for the page.
///
/// The real implementation is `ChannelSystemSettingsService`, a platform
/// channel the app's own Android and iOS code answers (no package: rule 9);
/// tests and the fake env use `FakeSystemSettingsService`. When the player
/// comes back, `DailyReminder.refresh` (on resume) clears the blocked row.
abstract interface class SystemSettingsService {
  /// Opens the phone's notification settings for Nesty (Android 8+: the
  /// app's notification page; Android 7: its app details; iOS 16+: its
  /// notification settings, else its settings page). Returns whether a page
  /// opened; false when nothing could. Never throws (rule 3).
  Future<bool> openNotificationSettings();
}
