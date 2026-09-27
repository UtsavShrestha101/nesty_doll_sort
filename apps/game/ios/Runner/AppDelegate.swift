import AVFoundation
import Flutter
import UIKit

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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
