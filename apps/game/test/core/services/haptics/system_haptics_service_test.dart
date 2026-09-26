import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/haptics/system_haptics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseService database;
  late SystemHapticsService haptics;
  late List<MethodCall> calls;

  setUp(() {
    database = FakeDatabaseService();
    haptics = SystemHapticsService(database);
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await database.close();
  });

  test('maps each spec §11.2 moment to a platform haptic', () async {
    for (final pattern in HapticPattern.values) {
      await haptics.play(pattern);
    }

    expect(
      calls.map((call) => call.method),
      everyElement('HapticFeedback.vibrate'),
    );
    expect(calls.map((call) => call.arguments), [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.selectionClick',
    ]);
  });

  test('plays nothing when haptics are turned off in settings', () async {
    await database.setHapticsEnabled(false);

    await haptics.play(HapticPattern.complete);

    expect(calls, isEmpty);
  });
}
