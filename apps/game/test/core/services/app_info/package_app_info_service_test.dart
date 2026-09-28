import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/app_info/package_app_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the version and build number once, cached', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Nesty',
      packageName: 'com.futrix.nesty.dev',
      version: '1.0.0',
      buildNumber: '42',
      buildSignature: '',
    );
    final service = PackageAppInfoService();

    final info = await service.load();
    expect(info.version, '1.0.0');
    expect(info.buildNumber, '42');
    // The same future both times: read once (m3-design §10.2).
    expect(identical(service.load(), service.load()), isTrue);
  });
}
