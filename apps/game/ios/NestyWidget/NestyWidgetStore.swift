import Foundation

/// The store the app writes and the widget reads (stage 4 contract §2): the
/// App Group's `UserDefaults`, the snapshot JSON under one key.
///
/// Compiled into Runner (the `com.futrix.nesty/home_widget` channel in
/// AppDelegate.swift), the NestyWidget extension and RunnerTests. The group
/// comes from each bundle's Info.plist `NestyAppGroup` (the `APP_GROUP_ID`
/// build setting: `group.com.futrix.nesty`, `.dev`, `.stg`), never from a
/// literal, so the three flavors on one phone never share a widget.
struct NestyWidgetStore {
  static let snapshotKey = "nesty_widget_snapshot"
  static let groupInfoKey = "NestyAppGroup"
  static let schemeInfoKey = "NestyAppScheme"

  let group: String
  private let defaults: UserDefaults

  /// Nil for a missing group, or one whose build setting was never expanded.
  init?(group: String?) {
    guard let group, NestyWidgetStore.isUsable(group),
      let defaults = UserDefaults(suiteName: group)
    else { return nil }
    self.group = group
    self.defaults = defaults
  }

  /// The store named by [bundle]'s Info.plist.
  static func from(bundle: Bundle = .main) -> NestyWidgetStore? {
    NestyWidgetStore(group: bundle.object(forInfoDictionaryKey: groupInfoKey) as? String)
  }

  /// The flavor's URL scheme from [bundle]'s Info.plist (the `APP_URL_SCHEME`
  /// build setting), for the tap before the app has written anything.
  static func scheme(bundle: Bundle = .main) -> String? {
    guard let scheme = bundle.object(forInfoDictionaryKey: schemeInfoKey) as? String,
      isUsable(scheme)
    else { return nil }
    return scheme
  }

  /// Stores [json]; true when it reads back the same.
  @discardableResult
  func write(_ json: String) -> Bool {
    defaults.set(json, forKey: NestyWidgetStore.snapshotKey)
    return defaults.string(forKey: NestyWidgetStore.snapshotKey) == json
  }

  /// The stored JSON, or nil before the first write.
  func read() -> String? {
    defaults.string(forKey: NestyWidgetStore.snapshotKey)
  }

  /// True when the App Group's container exists, which needs the
  /// `com.apple.security.application-groups` entitlement in the signed
  /// binary.
  var containerResolves: Bool {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil
  }

  /// Removes the snapshot (tests only).
  func clear() {
    defaults.removeObject(forKey: NestyWidgetStore.snapshotKey)
  }

  private static func isUsable(_ value: String) -> Bool {
    !value.isEmpty && !value.contains("$(")
  }
}
