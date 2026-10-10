import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';

/// No `TestWidgetsFlutterBinding` here on purpose: without a binding the
/// lifecycle listener can't be built, and [WelcomeBackTracker.start] must
/// still note the open and stay idempotent (CLAUDE.md rule 3, as
/// `HomeWidgetBridge.start`).
void main() {
  test('start without a binding notes the open, once', () async {
    final clock = FakeClock();
    final settings = FakeDatabaseService();
    final tracker = WelcomeBackTracker(
      settings,
      clock,
      FakeRemoteConfigService(),
    );
    var changes = 0;
    final subscription = tracker.changes.listen((_) => changes++);

    expect(tracker.start, returnsNormally);
    expect(settings.lastOpenDate, clock.today().toIso());
    expect(tracker.start, returnsNormally);
    expect(changes, 0);

    await subscription.cancel();
    await tracker.dispose();
    await settings.close();
  });
}
