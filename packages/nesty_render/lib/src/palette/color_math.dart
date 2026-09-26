import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:nesty_render/src/tokens/render_token_types.dart';

// The colour arithmetic of design/generator/nesty-doll.js, ported operation
// for operation (same order, same rounding) so a colour computed here equals
// the hex the design's reference renders were built with
// (design/skins/classic/renders/*.svg). The palette parity tests compare the
// two byte for byte.

/// The 8-bit red, green and blue channels of [color], as `hex2rgb` returns.
({int r, int g, int b}) rgbOf(Color color) {
  final argb = color.toARGB32();
  return (r: (argb >> 16) & 0xFF, g: (argb >> 8) & 0xFF, b: argb & 0xFF);
}

/// An opaque colour from channel values, rounded and clamped like the JS
/// `rgb2hex` (`Math.round`, then clamp to 0–255).
Color colorFromChannels(double r, double g, double b) =>
    Color.fromARGB(0xFF, _channel(r), _channel(g), _channel(b));

// Math.round for the non-negative values this sees: Dart's round() breaks
// ties away from zero, which is the same as JS for x >= 0.
int _channel(double v) => math.max(0, math.min(255, v.round()));

/// `mul(base, gray)` in nesty-doll.js: each channel of [base] times
/// [gray] / 255. This is what `BlendMode.modulate` does to a gray mask pixel
/// (design/README.md "Doll rendering" step 1), rounded to 8 bits.
Color multiplyByGray(Color base, int gray) {
  final c = rgbOf(base);
  return colorFromChannels(
    c.r * gray / 255,
    c.g * gray / 255,
    c.b * gray / 255,
  );
}

/// `ramp(stops, t)` in nesty-doll.js: linear interpolation between the two
/// stops around [t]; past the last stop, the last colour.
Color rampColor(List<RampStop> stops, double t) {
  for (var i = 1; i < stops.length; i++) {
    if (t <= stops[i].position) {
      final t0 = stops[i - 1].position;
      final span = stops[i].position - t0;
      // JS `(t1 - t0 || 1)`: two stops at one position must not divide by 0.
      final k = (t - t0) / (span == 0 ? 1 : span);
      final a = rgbOf(stops[i - 1].color);
      final b = rgbOf(stops[i].color);
      return colorFromChannels(
        a.r + (b.r - a.r) * k,
        a.g + (b.g - a.g) * k,
        a.b + (b.b - a.b) * k,
      );
    }
  }
  return stops.last.color;
}

/// `#RRGGBB`, upper case, as the JS `rgb2hex` writes it into SVG attributes.
String hexOf(Color color) {
  final c = rgbOf(color);
  String two(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${two(c.r)}${two(c.g)}${two(c.b)}'.toUpperCase();
}

final _hex = RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

/// The gray level of an SVG colour value when it is a `#rgb` or `#rrggbb`
/// hex with equal channels (JS `isGray`), else null. Named colours,
/// `currentColor`, `none` and `url(#…)` are not gray, exactly as in the JS.
int? grayLevelOf(String value) {
  if (!_hex.hasMatch(value)) return null;
  var digits = value.substring(1);
  if (digits.length == 3) {
    digits = digits.split('').map((d) => '$d$d').join();
  }
  final n = int.parse(digits, radix: 16);
  final r = (n >> 16) & 0xFF;
  final g = (n >> 8) & 0xFF;
  final b = n & 0xFF;
  return r == g && g == b ? r : null;
}
