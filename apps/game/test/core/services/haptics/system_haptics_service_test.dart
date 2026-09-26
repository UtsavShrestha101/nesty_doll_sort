import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseService database;
  late SystemHapticsService haptics;

  /// The platform calls and the injected pauses, in the order they happened.
  late List<String> timeline;

  setUp(() {
    database = FakeDatabaseService();
    timeline = [];
    haptics = SystemHapticsService(
      database,
      delay: (duration) async =>
          timeline.add('wait ${duration.inMilliseconds}'),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          expect(call.method, 'HapticFeedback.vibrate');
          timeline.add((call.arguments as String).split('.').last);
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await database.close();
  });

  Future<List<String>> timelineOf(HapticPattern pattern) async {
    timeline.clear();
    await haptics.play(pattern);
    return List.of(timeline);
  }

  test('single-pulse moments follow tokens.json haptics', () async {
    expect(await timelineOf(HapticPattern.pick), ['lightImpact']);
    expect(await timelineOf(HapticPattern.nest), ['mediumImpact']);
    expect(await timelineOf(HapticPattern.unlock), ['mediumImpact']);
    expect(await timelineOf(HapticPattern.iceCrack), ['lightImpact']);
    expect(await timelineOf(HapticPattern.button), ['selectionClick']);
  });

  test('success (complete, win) is medium, then light 80 ms later', () async {
    const success = ['mediumImpact', 'wait 80', 'lightImpact'];
    expect(await timelineOf(HapticPattern.complete), success);
    expect(await timelineOf(HapticPattern.win), success);
  });

  test('soft error (invalid) is light twice, 60 ms apart', () async {
    expect(await timelineOf(HapticPattern.invalid), [
      'lightImpact',
      'wait 60',
      'lightImpact',
    ]);
  });

  test('plays nothing when haptics are turned off in settings', () async {
    await database.setHapticsEnabled(false);

    for (final pattern in HapticPattern.values) {
      expect(await timelineOf(pattern), isEmpty, reason: pattern.name);
    }
  });

  test('turning haptics off mid-pattern stops the pattern', () async {
    haptics = SystemHapticsService(
      database,
      delay: (duration) => database.setHapticsEnabled(false),
    );

    expect(await timelineOf(HapticPattern.complete), ['mediumImpact']);
  });

  test('a platform that refuses haptics is silent, not an error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => throw PlatformException(code: 'no-vibrator'),
        );

    await expectLater(haptics.play(HapticPattern.complete), completes);
  });

  test('the default delay really waits between pulses', () async {
    final real = SystemHapticsService(database);
    final watch = Stopwatch()..start();
    await real.play(HapticPattern.invalid);
    expect(watch.elapsed, greaterThanOrEqualTo(HapticPatterns.softErrorGap));
  });

  test('the fake records every pattern in order', () async {
    final fake = FakeHapticsService();
    await fake.play(HapticPattern.pick);
    await fake.play(HapticPattern.complete);

    expect(fake.played, [HapticPattern.pick, HapticPattern.complete]);
    expect(fake.lastPattern, HapticPattern.complete);
    expect(fake.playCount, 2);
    fake.clear();
    expect(fake.lastPattern, isNull);
  });
}
