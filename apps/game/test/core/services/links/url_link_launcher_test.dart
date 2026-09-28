import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/links/url_link_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('never throws, even with no platform implementation registered '
      '(rule 3): a launch failure is only logged', () async {
    final launcher = UrlLinkLauncher();

    // Under `flutter test` there is no url_launcher platform channel, so
    // this exercises the same silent-failure path a device without a
    // browser or mail app would hit.
    await launcher.openUrl('https://example.com/privacy');
    await launcher.email('support@example.com');
  });
}
