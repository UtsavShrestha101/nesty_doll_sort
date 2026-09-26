import 'package:nesty_admin/bootstrap.dart';
import 'package:nesty_admin/core/flavor/flavor.dart';
import 'package:nesty_admin/core/flavor/flavor_config.dart';
import 'package:nesty_admin/core/flavor/flavor_values.dart';

// flutter build web -t lib/main_prod.dart
void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    values: const FlavorValues(appTitle: 'Nesty Admin'),
  );
  bootstrap();
}
