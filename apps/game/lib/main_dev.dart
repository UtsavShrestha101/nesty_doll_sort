import 'package:nesty_game/bootstrap.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';

// flutter run --flavor dev -t lib/main_dev.dart
void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    values: const FlavorValues(appTitle: '[DEV] Nesty'),
  );
  bootstrap();
}
