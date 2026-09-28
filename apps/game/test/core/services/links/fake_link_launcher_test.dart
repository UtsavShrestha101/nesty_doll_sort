import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/links/fake_link_launcher.dart';

void main() {
  test('records opened URLs and emailed addresses', () async {
    final launcher = FakeLinkLauncher();

    await launcher.openUrl('https://example.com/privacy');
    await launcher.email('support@example.com');

    expect(launcher.openedUrls, ['https://example.com/privacy']);
    expect(launcher.emailedAddresses, ['support@example.com']);
  });
}
