import 'package:nesty_game/bootstrap.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';

// flutter run --flavor prod -t lib/main_prod.dart
void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    values: const FlavorValues(appTitle: 'Nesty: Doll Sort'),
  );
  bootstrap();
}
