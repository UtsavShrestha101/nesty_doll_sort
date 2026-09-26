import 'package:nesty_admin/core/flavor/flavor.dart';
import 'package:nesty_admin/core/flavor/flavor_values.dart';

/// Process-wide flavor, set once by `lib/main_<flavor>.dart` before
/// `bootstrap()`.
///
/// The first call wins (later calls return the existing instance), so a test
/// helper can call it repeatedly without flipping the flavor mid-run.
class FlavorConfig {
  factory FlavorConfig({
    required Flavor flavor,
    required FlavorValues values,
  }) => _instance ??= FlavorConfig._(flavor, values);

  FlavorConfig._(this._flavor, this._values);

  final Flavor _flavor;
  final FlavorValues _values;

  static FlavorConfig? _instance;

  static FlavorConfig get _current =>
      _instance ??
      (throw StateError(
        'FlavorConfig is not initialised. Start the app from '
        'lib/main_<flavor>.dart, or call FlavorConfig(...) in the test setup.',
      ));

  static Flavor get flavor => _current._flavor;

  static FlavorValues get values => _current._values;

  static bool get isProd => flavor == Flavor.prod;
}
