import 'package:nesty_core/src/models/doll_color.dart';

/// JSON reading rules shared by the level codec and the session codec, so
/// the two can't drift apart on the web (D11, D29).
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class JsonValues {
  /// 2^53 − 1: the largest integer every platform reads exactly from JSON
  /// (the web's numbers are doubles).
  static const int maxInteger = 0x1FFFFFFFFFFFFF;

  /// [value] as an int when it is an integral JSON number within
  /// ±[maxInteger], else null (D29).
  ///
  /// On the web `3.0 is int` is true and every number is also a double, so
  /// this tests the value, not the Dart type: `3` and `3.0` read alike on
  /// the VM, in dart2js and in wasm.
  static int? integer(Object? value) {
    if (value is num &&
        value.isFinite &&
        value == value.truncateToDouble() &&
        value.abs() <= maxInteger) {
      return value.toInt();
    }
    return null;
  }

  /// A doll token, `<color><size>` such as `red4` (spec §5.1, design A21).
  /// Color ids are lowercase letters only (`DollColor.id`), so the size is
  /// everything after the letters.
  static final RegExp dollToken = RegExp(r'^([a-z]+)([1-6])$');

  /// Every `DollColor` by its id.
  static final Map<String, DollColor> colorsById = {
    for (final color in DollColor.values) color.id: color,
  };
}
