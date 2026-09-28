import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';

void main() {
  test('answers a fixed version and build number', () async {
    final info = await FakeAppInfoService().load();
    expect(info.version, '1.0.0');
    expect(info.buildNumber, '42');
  });
}
