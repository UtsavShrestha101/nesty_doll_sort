import 'package:nesty_game/bootstrap.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';

// flutter run --flavor stg -t lib/main_stg.dart
void main() {
  FlavorConfig(
    flavor: Flavor.stg,
    values: const FlavorValues(appTitle: '[STG] Nesty'),
  );
  bootstrap();
}
