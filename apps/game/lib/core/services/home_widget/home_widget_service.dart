import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';

/// Hands the home-screen widget what it shows (plan-local-habits §4; stage 4
/// contract §1–§2): one JSON string in a store both the app and the widget
/// can read, then a reload of the widget. No package: our own channel
/// (D299, rule 9).
///
/// The real implementation is `ChannelHomeWidgetService`, answered by
/// `AppDelegate.swift` and `MainActivity.kt`; tests and the fake env use
/// `FakeHomeWidgetService`. No call throws (rule 3): a phone with no widget
/// support, or a build with no handler, simply stores nothing.
abstract interface class HomeWidgetService {
  /// Stores [snapshot] for the widget and reloads it. True when the platform
  /// stored it; false on any failure.
  Future<bool> publish(HomeWidgetSnapshot snapshot);

  /// The JSON the platform stored last (debug builds only; release and any
  /// failure answer null). For `integration_test/home_widget_test.dart`.
  Future<String?> readBack();

  /// The store's own facts (debug builds only; null otherwise): iOS `{group,
  /// resolves}`, Android `{prefs, providers}`.
  Future<Map<String, Object?>?> storeInfo();
}
