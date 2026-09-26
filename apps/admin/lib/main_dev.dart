import 'package:nesty_admin/bootstrap.dart';
import 'package:nesty_admin/core/flavor/flavor.dart';
import 'package:nesty_admin/core/flavor/flavor_config.dart';
import 'package:nesty_admin/core/flavor/flavor_values.dart';

// flutter run -d chrome -t lib/main_dev.dart
// Until M5 adds Firebase Auth, sign in with any email/password on fakes:
// flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true
void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    values: const FlavorValues(appTitle: '[DEV] Nesty Admin'),
  );
  bootstrap();
}
