import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_projection.dart';
import 'package:nesty_game/core/services/home_widget/channel_home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/fake_home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';

/// `HomeWidgetService`'s contract for both implementations (stage 4 contract
/// §1): the real one's channel (the Dart half, over a fake binary
/// messenger; `AppDelegate.swift` and `MainActivity.kt` answer the same
/// methods) and the fake. Neither throws.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(ChannelHomeWidgetService.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late HomeWidgetSnapshot snapshot;

  setUpAll(() async {
    await initializeDateFormatting();
    final today = LocalDate(2026, 10, 8);
    snapshot = HomeWidgetSnapshot.compose(
      lang: 'en',
      scheme: 'nesty',
      unlocked: true,
      unlockLevel: 2,
      days: [
        for (var i = 0; i < 8; i++)
          DailyDayProjection(
            date: today.addDays(i),
            streak: 2,
            lit: true,
            solved: false,
            state: DailyDayState.ready,
          ),
      ],
    );
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('the channel and method names are the native side\'s contract', () {
    expect(
      ChannelHomeWidgetService.channelName,
      'com.futrix.nesty/home_widget',
    );
    expect(ChannelHomeWidgetService.publishMethod, 'publish');
    expect(ChannelHomeWidgetService.readBackMethod, 'readBack');
    expect(ChannelHomeWidgetService.storeInfoMethod, 'storeInfo');
  });

  group('ChannelHomeWidgetService', () {
    test(
      'publish hands the platform the snapshot\'s one JSON string',
      () async {
        Object? argument;
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'publish');
          argument = call.arguments;
          return true;
        });
        expect(await ChannelHomeWidgetService().publish(snapshot), isTrue);
        expect(argument, isA<String>());
        expect(jsonDecode(argument! as String), snapshot.toJson());
      },
    );

    test('false when the platform could not store it', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => false);
      expect(await ChannelHomeWidgetService().publish(snapshot), isFalse);
    });

    test(
      'false with no handler (a host test, a build with no widget)',
      () async {
        expect(await ChannelHomeWidgetService().publish(snapshot), isFalse);
        expect(await ChannelHomeWidgetService().readBack(), isNull);
        expect(await ChannelHomeWidgetService().storeInfo(), isNull);
      },
    );

    test('false when the platform throws, and never throws itself', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'boom');
      });
      expect(await ChannelHomeWidgetService().publish(snapshot), isFalse);
      expect(await ChannelHomeWidgetService().readBack(), isNull);
      expect(await ChannelHomeWidgetService().storeInfo(), isNull);
    });

    test(
      'readBack and storeInfo (debug builds) answer what the platform says',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          return switch (call.method) {
            'readBack' => '{"v":1}',
            'storeInfo' => {
              'group': 'group.com.futrix.nesty.dev',
              'resolves': true,
            },
            _ => null,
          };
        });
        final service = ChannelHomeWidgetService();
        expect(await service.readBack(), '{"v":1}');
        expect(await service.storeInfo(), {
          'group': 'group.com.futrix.nesty.dev',
          'resolves': true,
        });
      },
    );

    test('a release build\'s notImplemented is a quiet null', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw MissingPluginException();
      });
      expect(await ChannelHomeWidgetService().readBack(), isNull);
    });
  });

  group('FakeHomeWidgetService', () {
    test('records every publish and reads the last back', () async {
      final HomeWidgetService service = FakeHomeWidgetService();
      expect(await service.readBack(), isNull);
      expect(await service.publish(snapshot), isTrue);
      expect(await service.readBack(), snapshot.encode());
      expect((service as FakeHomeWidgetService).published, hasLength(1));
      service.clear();
      expect(service.lastJson, isNull);
    });

    test('answers what it was told to', () async {
      final service = FakeHomeWidgetService()..next = false;
      expect(await service.publish(snapshot), isFalse);
    });
  });
}
