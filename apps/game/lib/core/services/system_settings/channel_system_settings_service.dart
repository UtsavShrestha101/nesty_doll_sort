import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';

/// The real [SystemSettingsService]: [channelName]'s
/// [openNotificationSettingsMethod], answered by `MainActivity.kt` and
/// `AppDelegate.swift` (lane D writes their bodies; phase 4 architecture
/// §3.8). A platform with no handler (a host test, a build before the native
/// side lands) returns false.
@LazySingleton(as: SystemSettingsService, env: [AppEnv.real])
class ChannelSystemSettingsService implements SystemSettingsService {
  ChannelSystemSettingsService({@ignoreParam MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// The channel both platforms register.
  static const channelName = 'com.futrix.nesty/system_settings';

  /// Opens the notification settings; the platform answers true when a page
  /// opened.
  static const openNotificationSettingsMethod = 'openNotificationSettings';

  final MethodChannel _channel;

  @override
  Future<bool> openNotificationSettings() async {
    try {
      final opened = await _channel.invokeMethod<bool>(
        openNotificationSettingsMethod,
      );
      return opened ?? false;
    } on Object catch (error, stack) {
      // Rule 3: no settings page is no crash; the row keeps its hint.
      developer.log(
        'opening the notification settings failed',
        name: 'nesty.system_settings',
        error: error,
        stackTrace: stack,
      );
      return false;
    }
  }
}
