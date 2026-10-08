import AVFoundation
import Flutter
import UIKit
import UserNotifications
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Owner, audio plan Q39: Nesty's music and sounds mix with the player's
    // own audio (a podcast, their music) instead of stopping it, and follow
    // the silent switch. flutter_soloud 4.1.7 never sets a category
    // (miniaudio's session category "none"; it only reactivates the session
    // when its device resumes), so this, set before the engine starts, is
    // the one that holds. A failure leaves iOS's default and the game plays
    // on.
    try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)

    // The opt-in daily reminder (E4, spec-prop §7.9; docs/plans/m7-design.md
    // P3.10): flutter_local_notifications routes a tap through this
    // delegate. A tap just opens the app normally (Q141: no payload, no
    // custom routing), and the details' `presentAlert/Banner/List/Sound:
    // false` already keep it silent while the app is in the foreground, so
    // no `UNUserNotificationCenterDelegate` method is overridden here.
    UNUserNotificationCenter.current().delegate =
      self as? UNUserNotificationCenterDelegate

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerSystemSettingsChannel(with: engineBridge.pluginRegistry)
    registerHomeWidgetChannel(with: engineBridge.pluginRegistry)
  }

  /// The home-screen widget's store (local habits stage 4, contract §1–2):
  /// the Dart side is ChannelHomeWidgetService, fed by HomeWidgetBridge.
  /// `publish` stores the snapshot JSON in the App Group named by Info.plist
  /// `NestyAppGroup` (NestyWidgetStore) and reloads the widget's timelines;
  /// `readBack` and `storeInfo` exist in debug builds only, for
  /// integration_test/home_widget_test.dart. Nothing here ever throws to
  /// Dart: a store that can't open answers false.
  private func registerHomeWidgetChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "NestyHomeWidget") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "com.futrix.nesty/home_widget",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "publish":
        guard let json = call.arguments as? String, let store = NestyWidgetStore.from() else {
          result(false)
          return
        }
        let stored = store.write(json)
        if stored {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(stored)
      #if DEBUG
      case "readBack":
        result(NestyWidgetStore.from()?.read())
      case "storeInfo":
        let group = Bundle.main.object(forInfoDictionaryKey: NestyWidgetStore.groupInfoKey) as? String
        let info: [String: Any] = [
          "group": group.map { $0 as Any } ?? NSNull(),
          "resolves": NestyWidgetStore.from()?.containerResolves ?? false,
        ]
        result(info)
      #endif
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// "Open phone settings" (frames 10.2d and 10.2f, Q140; phase 4
  /// architecture 3.8): the Dart side is ChannelSystemSettingsService. iOS
  /// 16+ opens Nesty's notification settings, earlier versions its settings
  /// page. The reply is whether iOS accepted the URL, never an error.
  private func registerSystemSettingsChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "NestySystemSettings") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "com.futrix.nesty/system_settings",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "openNotificationSettings" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let urlString: String
      if #available(iOS 16.0, *) {
        urlString = UIApplication.openNotificationSettingsURLString
      } else {
        urlString = UIApplication.openSettingsURLString
      }
      guard let url = URL(string: urlString) else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    }
  }
}
