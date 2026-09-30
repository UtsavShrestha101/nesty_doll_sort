import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/system_settings/channel_system_settings_service.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';

/// `SystemSettingsService`'s platform channel (phase 4 architecture §3.8;
/// Q140): the Dart half, over a fake binary messenger. The native halves
/// (`MainActivity.kt`, `AppDelegate.swift`) answer the same method.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(ChannelSystemSettingsService.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('the channel and method names are the native side\'s contract', () {
    expect(
      ChannelSystemSettingsService.channelName,
      'com.futrix.nesty/system_settings',
    );
    expect(
      ChannelSystemSettingsService.openNotificationSettingsMethod,
      'openNotificationSettings',
    );
  });

  test('true when the platform opened a page, asked once', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });
    expect(
      await ChannelSystemSettingsService().openNotificationSettings(),
      isTrue,
    );
    expect(calls, ['openNotificationSettings']);
  });

  test('false when the platform could not open one', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);
    expect(
      await ChannelSystemSettingsService().openNotificationSettings(),
      isFalse,
    );
  });

  test('false on a null answer', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
    expect(
      await ChannelSystemSettingsService().openNotificationSettings(),
      isFalse,
    );
  });

  test('false, never a throw, when the platform errors (rule 3)', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'unavailable'),
    );
    expect(
      await ChannelSystemSettingsService().openNotificationSettings(),
      isFalse,
    );
  });

  test(
    'false when nothing handles the channel (a host test, an old build)',
    () async {
      expect(
        await ChannelSystemSettingsService().openNotificationSettings(),
        isFalse,
      );
    },
  );

  test('the fake counts calls and answers next', () async {
    final fake = FakeSystemSettingsService();
    expect(await fake.openNotificationSettings(), isTrue);
    fake.next = false;
    expect(await fake.openNotificationSettings(), isFalse);
    expect(fake.openCalls, 2);
  });
}
