import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/notifications/local_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A double whose every call throws, standing in for a broken platform
/// implementation (a channel error, a plugin bug): every
/// [LocalNotificationService] method must still keep its "never throws"
/// promise (rule 3; m7-design P3.10; reminder lane test plan §3).
class _ThrowingAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  @override
  Future<bool> initialize({
    required AndroidInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) => throw StateError('initialize');

  @override
  Future<bool?> areNotificationsEnabled() => throw StateError('permission');

  @override
  Future<bool?> requestNotificationsPermission() =>
      throw StateError('requestPermission');

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    AndroidNotificationDetails? notificationDetails,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exact,
  }) => throw StateError('zonedSchedule');

  @override
  Future<void> cancel({required int id, String? tag}) =>
      throw StateError('cancel');

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      throw StateError('pendingNotificationRequests');
}

class _ThrowingIOSPlugin extends IOSFlutterLocalNotificationsPlugin {
  @override
  Future<bool> initialize({
    required DarwinInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) => throw StateError('initialize');

  @override
  Future<NotificationsEnabledOptions?> checkPermissions() =>
      throw StateError('permission');

  @override
  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
    bool provisional = false,
    bool critical = false,
    bool carPlay = false,
    bool providesAppNotificationSettings = false,
  }) => throw StateError('requestPermission');

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    DarwinNotificationDetails? notificationDetails,
  }) => throw StateError('zonedSchedule');

  @override
  Future<void> cancel({required int id}) => throw StateError('cancel');

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      throw StateError('pendingNotificationRequests');
}

/// A working double that records every call, so `scheduleDaily`'s "skip an
/// identical call" and its exact parameters can be checked without a real
/// platform channel.
class _RecordingAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  int initializeCalls = 0;
  bool? notificationsEnabled = true;
  bool? requestResult = true;
  final List<({int id, tz.TZDateTime date, AndroidScheduleMode mode})>
  scheduled = [];
  int cancelCalls = 0;
  List<PendingNotificationRequest> pending = [];

  @override
  Future<bool> initialize({
    required AndroidInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalls++;
    return true;
  }

  @override
  Future<bool?> areNotificationsEnabled() async => notificationsEnabled;

  @override
  Future<bool?> requestNotificationsPermission() async => requestResult;

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    AndroidNotificationDetails? notificationDetails,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exact,
  }) async {
    scheduled.add((id: id, date: scheduledDate, mode: scheduleMode));
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelCalls++;
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      Future.value(pending);
}

/// The real plugin's own channel, and flutter_timezone's.
const _pluginChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);
const _timezoneChannel = MethodChannel('flutter_timezone');

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// Answers flutter_timezone's `getLocalTimezone` with [identifier] (the
/// shape its Android and iOS sides return), or fails the read when null.
void _mockDeviceZone(String? identifier) {
  _messenger.setMockMethodCallHandler(_timezoneChannel, (call) async {
    if (call.method != 'getLocalTimezone') return null;
    if (identifier == null) throw PlatformException(code: 'unavailable');
    return <String, Object?>{
      'identifier': identifier,
      'localizedName': null,
      'locale': null,
    };
  });
}

/// Records every call the real platform plugin sends over its channel, so a
/// test sees exactly what the Java or Objective-C side would receive.
List<MethodCall> _recordPluginChannel() {
  final calls = <MethodCall>[];
  _messenger.setMockMethodCallHandler(_pluginChannel, (call) async {
    calls.add(call);
    return call.method == 'initialize' ? true : null;
  });
  return calls;
}

Map<Object?, Object?> _zonedScheduleArguments(List<MethodCall> calls) =>
    calls.singleWhere((call) => call.method == 'zonedSchedule').arguments
        as Map<Object?, Object?>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('a throwing plugin double: every call keeps its promise', () {
    late _ThrowingAndroidPlugin android;
    late LocalNotificationService service;

    setUp(() {
      android = _ThrowingAndroidPlugin();
      FlutterLocalNotificationsPlatform.instance = android;
      service = LocalNotificationService();
    });

    test('initialize never throws', () async {
      await service.initialize();
    });

    test('permission never throws, reads unknown', () async {
      expect(await service.permission(), NotificationPermission.unknown);
    });

    test('requestPermission never throws, reads unknown', () async {
      expect(await service.requestPermission(), NotificationPermission.unknown);
    });

    test('scheduleDaily never throws, returns false', () async {
      final plan = _plan();
      expect(await service.scheduleDaily(plan), isFalse);
    });

    test('cancelDaily never throws', () async {
      await service.cancelDaily();
    });

    test('hasPendingDaily never throws, returns false', () async {
      expect(await service.hasPendingDaily(), isFalse);
    });
  });

  group('a throwing plugin double on iOS', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      FlutterLocalNotificationsPlatform.instance = _ThrowingIOSPlugin();
    });

    test('every call keeps its "never throws" promise', () async {
      final service = LocalNotificationService();
      await service.initialize();
      expect(await service.permission(), NotificationPermission.unknown);
      expect(await service.requestPermission(), NotificationPermission.unknown);
      expect(await service.scheduleDaily(_plan()), isFalse);
      await service.cancelDaily();
      expect(await service.hasPendingDaily(), isFalse);
    });
  });

  group('a working double: the happy path', () {
    late _RecordingAndroidPlugin android;
    late LocalNotificationService service;

    setUp(() {
      android = _RecordingAndroidPlugin();
      FlutterLocalNotificationsPlatform.instance = android;
      service = LocalNotificationService();
    });

    test('permission maps true/false/null', () async {
      android.notificationsEnabled = true;
      expect(await service.permission(), NotificationPermission.granted);
      android.notificationsEnabled = false;
      expect(await service.permission(), NotificationPermission.denied);
      android.notificationsEnabled = null;
      expect(await service.permission(), NotificationPermission.unknown);
    });

    test('requestPermission never prompts on plain permission()', () async {
      await service.permission();
      expect(android.initializeCalls, 0);
    });

    test('scheduleDaily schedules the one id, inexact and by time', () async {
      final ok = await service.scheduleDaily(_plan());
      expect(ok, isTrue);
      expect(android.scheduled, hasLength(1));
      expect(android.scheduled.single.id, reminderId);
      expect(
        android.scheduled.single.mode,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });

    test('an identical (plan, zone) scheduleDaily call is skipped', () async {
      final plan = _plan();
      await service.scheduleDaily(plan);
      await service.scheduleDaily(plan);
      expect(android.scheduled, hasLength(1));
    });

    test('a changed plan schedules again', () async {
      await service.scheduleDaily(_plan());
      await service.scheduleDaily(_plan(hour: 20));
      expect(android.scheduled, hasLength(2));
    });

    test('cancelDaily cancels and clears the "already scheduled" memo, so '
        'the same plan schedules again next time', () async {
      final plan = _plan();
      await service.scheduleDaily(plan);
      await service.cancelDaily();
      expect(android.cancelCalls, 1);
      await service.scheduleDaily(plan);
      expect(android.scheduled, hasLength(2));
    });

    test('hasPendingDaily reads the plugin\'s own pending list', () async {
      expect(await service.hasPendingDaily(), isFalse);
      android.pending = [
        const PendingNotificationRequest(reminderId, 'title', 'body', null),
      ];
      expect(await service.hasPendingDaily(), isTrue);
    });
  });

  // m7-design P3.10's zone fallback, as the platform receives it (M7 review
  // R9): FLN sends `scheduledDate.location.name` as `timeZoneName`, and
  // Android's side calls `ZoneId.of(timeZoneName)`, which throws on a name
  // it doesn't know, so the reminder was never scheduled there.
  group('the zone name the platform receives', () {
    late List<MethodCall> calls;

    setUp(() {
      FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin();
      calls = _recordPluginChannel();
    });
    tearDown(() {
      _messenger
        ..setMockMethodCallHandler(_pluginChannel, null)
        ..setMockMethodCallHandler(_timezoneChannel, null);
    });

    test('a device id the bundled data lacks (Europe/Amsterdam) is sent as '
        'itself, which the platform that reported it resolves', () async {
      // The premise: latest_10y has no IANA backward links, so this id
      // takes the fixed-offset fallback.
      tzdata.initializeTimeZones();
      expect(
        () => tz.getLocation('Europe/Amsterdam'),
        throwsA(isA<tz.LocationNotFoundException>()),
      );
      _mockDeviceZone('Europe/Amsterdam');

      expect(await LocalNotificationService().scheduleDaily(_plan()), isTrue);

      final arguments = _zonedScheduleArguments(calls);
      expect(arguments['timeZoneName'], 'Europe/Amsterdam');
      expect(arguments['scheduledDateTime'], endsWith('T19:00:00'));
    });

    test('a device id the bundled data knows is sent as itself', () async {
      _mockDeviceZone('Europe/Brussels');

      await LocalNotificationService().scheduleDaily(_plan());

      expect(_zonedScheduleArguments(calls)['timeZoneName'], 'Europe/Brussels');
    });

    test('a failed zone read sends GMT±HH:MM at the current offset, which '
        'java.time.ZoneId and NSTimeZone both parse', () async {
      _mockDeviceZone(null);

      await LocalNotificationService().scheduleDaily(_plan());

      final offset = DateTime.now().timeZoneOffset;
      final minutes = offset.inMinutes.abs();
      final expected =
          'GMT${offset.isNegative ? '-' : '+'}'
          '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')}';
      expect(_zonedScheduleArguments(calls)['timeZoneName'], expected);
    });
  });

  // M7 review R10: FLN 22.3.1's iOS side attaches the default sound only
  // when `presentSound` is true or `sound` is set, so with no `sound` the
  // reminder was silent in the background too (P3.10: "in the background the
  // OS shows the alert and the sound").
  test('iOS: the reminder carries a sound for the background, and still '
      'presents nothing in the foreground', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance =
        IOSFlutterLocalNotificationsPlugin();
    final calls = _recordPluginChannel();
    _mockDeviceZone('Europe/Brussels');
    addTearDown(() {
      _messenger
        ..setMockMethodCallHandler(_pluginChannel, null)
        ..setMockMethodCallHandler(_timezoneChannel, null);
    });

    expect(await LocalNotificationService().scheduleDaily(_plan()), isTrue);

    final specifics =
        _zonedScheduleArguments(calls)['platformSpecifics']!
            as Map<Object?, Object?>;
    expect(specifics['sound'], '');
    expect(specifics['presentSound'], isFalse);
    expect(specifics['presentBanner'], isFalse);
    expect(specifics['presentList'], isFalse);
  });
}

ReminderPlan _plan({int hour = 19, int minute = 0}) => ReminderPlan(
  hour: hour,
  minute: minute,
  title: "Today's puzzle is ready",
  body: 'A new daily puzzle is on the shelf.',
  channelName: 'Daily reminder',
  channelDescription: 'One note a day when the daily puzzle is ready',
);
