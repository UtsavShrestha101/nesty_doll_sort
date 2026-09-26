import 'package:nesty_admin/bootstrap.dart';
import 'package:nesty_admin/core/flavor/flavor.dart';
import 'package:nesty_admin/core/flavor/flavor_config.dart';
import 'package:nesty_admin/core/flavor/flavor_values.dart';

// flutter run -d chrome -t lib/main_stg.dart
void main() {
  FlavorConfig(
    flavor: Flavor.stg,
    values: const FlavorValues(appTitle: '[STG] Nesty Admin'),
  );
  bootstrap();
}
