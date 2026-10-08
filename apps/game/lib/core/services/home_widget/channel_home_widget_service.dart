import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';

/// The real [HomeWidgetService]: [channelName]'s [publishMethod], answered
/// by `AppDelegate.swift` and `MainActivity.kt` (stage 4 contract §1). A
/// platform with no handler (a host test, a build before the native side
/// lands) answers false, silently, like `ChannelSystemSettingsService`.
@LazySingleton(as: HomeWidgetService, env: [AppEnv.real])
class ChannelHomeWidgetService implements HomeWidgetService {
  ChannelHomeWidgetService({@ignoreParam MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// The channel both platforms register, beside `system_settings`.
  static const channelName = 'com.futrix.nesty/home_widget';

  /// `publish(String json) -> bool`.
  static const publishMethod = 'publish';

  /// `readBack() -> String?` (debug builds only).
  static const readBackMethod = 'readBack';

  /// `storeInfo() -> Map` (debug builds only).
  static const storeInfoMethod = 'storeInfo';

  final MethodChannel _channel;

  @override
  Future<bool> publish(HomeWidgetSnapshot snapshot) async {
    try {
      final stored = await _channel.invokeMethod<bool>(
        publishMethod,
        snapshot.encode(),
      );
      return stored ?? false;
    } on Object catch (error, stack) {
      _log('publishing the widget snapshot failed', error, stack);
      return false;
    }
  }

  @override
  Future<String?> readBack() async {
    try {
      return await _channel.invokeMethod<String>(readBackMethod);
    } on Object catch (error, stack) {
      _log('reading the widget snapshot back failed', error, stack);
      return null;
    }
  }

  @override
  Future<Map<String, Object?>?> storeInfo() async {
    try {
      return await _channel.invokeMapMethod<String, Object?>(storeInfoMethod);
    } on Object catch (error, stack) {
      _log('reading the widget store info failed', error, stack);
      return null;
    }
  }

  // Rule 3: no widget is no crash. A missing handler is the normal answer on
  // a host test, so the log is the only trace.
  static void _log(String message, Object error, StackTrace stack) {
    developer.log(
      message,
      name: 'nesty.home_widget',
      error: error,
      stackTrace: stack,
    );
  }
}
