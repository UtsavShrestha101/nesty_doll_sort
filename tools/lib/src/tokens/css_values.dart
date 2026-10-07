// Parsers for the CSS-flavoured strings in design/tokens.json. Each one
// accepts exactly the shapes the design uses and throws a FormatException on
// anything else, so a new value shape fails the codegen instead of being
// silently mis-translated.
import 'dart:math' as math;

final _hex = RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
final _rgba = RegExp(
  r'^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*'
  r'(?:,\s*(\d*\.?\d+)\s*)?\)$',
);
final _number = RegExp(r'^-?(?:\d+\.?\d*|\.\d+)$');
final _cubic = RegExp(
  r'^cubic-bezier\(\s*([^,\s]+)\s*,\s*([^,\s]+)\s*,\s*([^,\s]+)\s*,'
  r'\s*([^,\s)]+)\s*\)$',
);

/// Parses `#RGB`, `#RRGGBB`, `#RRGGBBAA`, `rgb(r,g,b)`, `rgba(r,g,b,a)` or
/// the one CSS name the design writes, `white` (tokens v3: "Fredoka 700 21
/// white"), into a 32-bit ARGB integer (the `Color(0xAARRGGBB)` layout).
int parseCssColor(String value) {
  if (value.trim() == 'white') return 0xFFFFFFFF;
  final hex = _hex.firstMatch(value.trim());
  if (hex != null) {
    var digits = hex.group(1)!;
    if (digits.length == 3) {
      digits = digits.split('').map((d) => '$d$d').join();
    }
    final rgb = int.parse(digits.substring(0, 6), radix: 16);
    final alpha = digits.length == 8
        ? int.parse(digits.substring(6), radix: 16)
        : 0xFF;
    return (alpha << 24) | rgb;
  }
  final rgba = _rgba.firstMatch(value.trim());
  if (rgba != null) {
    final channels = [for (var i = 1; i <= 3; i++) int.parse(rgba[i]!)];
    if (channels.any((c) => c > 255)) {
      throw FormatException('Color channel above 255', value);
    }
    final a = rgba[4] == null ? 1.0 : double.parse(rgba[4]!);
    final isRgba = value.trim().startsWith('rgba');
    if ((rgba[4] == null) == isRgba || a < 0 || a > 1) {
      throw FormatException('Malformed alpha', value);
    }
    final alpha = (a * 255).round();
    return (alpha << 24) |
        (channels[0] << 16) |
        (channels[1] << 8) |
        channels[2];
  }
  throw FormatException('Unsupported color', value);
}

/// True when [value] is a color [parseCssColor] accepts.
bool isCssColor(String value) {
  try {
    parseCssColor(value);
    return true;
  } on FormatException {
    return false;
  }
}

/// Where a gradient stop sits: a fraction of the gradient line, an absolute
/// offset in logical px from its start, or unspecified (CSS then spaces it
/// evenly between its neighbours).
sealed class StopPosition {
  const StopPosition();
}

final class FractionStop extends StopPosition {
  const FractionStop(this.fraction);
  final double fraction;
  @override
  bool operator ==(Object other) =>
      other is FractionStop && other.fraction == fraction;
  @override
  int get hashCode => fraction.hashCode;
  @override
  String toString() => 'FractionStop($fraction)';
}

final class PxStop extends StopPosition {
  const PxStop(this.px);
  final double px;
  @override
  bool operator ==(Object other) => other is PxStop && other.px == px;
  @override
  int get hashCode => px.hashCode;
  @override
  String toString() => 'PxStop($px)';
}

final class ImplicitStop extends StopPosition {
  const ImplicitStop();
  @override
  bool operator ==(Object other) => other is ImplicitStop;
  @override
  int get hashCode => 0;
  @override
  String toString() => 'ImplicitStop()';
}

/// One parsed gradient stop.
typedef GradientStop = ({int color, StopPosition position});

/// Parses a stop such as `#F2893B`, `#F2893B 60%`, `#D8995A 0` or
/// `#BD7B40 14px`.
GradientStop parseGradientStop(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.length > 2) {
    throw FormatException('Expected "<color> [position]"', value);
  }
  final color = parseCssColor(parts[0]);
  if (parts.length == 1) {
    return (color: color, position: const ImplicitStop());
  }
  final pos = parts[1];
  if (pos.endsWith('%')) {
    final n = _parseNumber(pos.substring(0, pos.length - 1), value);
    if (n < 0 || n > 100) throw FormatException('Stop outside 0–100%', value);
    return (color: color, position: FractionStop(n / 100));
  }
  if (pos.endsWith('px')) {
    return (
      color: color,
      position: PxStop(_parseNumber(pos.substring(0, pos.length - 2), value)),
    );
  }
  // CSS allows a unitless 0 and nothing else.
  if (pos == '0') return (color: color, position: const FractionStop(0));
  throw FormatException('Stop position needs % or px', value);
}

/// Resolves implicit stop positions the way CSS does: an implicit first stop
/// is 0, an implicit last stop is 1, and a run of implicit stops between two
/// fractions is spread evenly between them. Pixel stops are returned as they
/// are (they need the rendered extent); an implicit stop next to one can't
/// be resolved and throws.
List<StopPosition> resolveStopPositions(List<StopPosition> stops) {
  if (stops.length < 2) {
    throw const FormatException('A gradient needs at least two stops');
  }
  final out = [...stops];
  if (out.first is ImplicitStop) out[0] = const FractionStop(0);
  if (out.last is ImplicitStop) out[out.length - 1] = const FractionStop(1);
  var i = 0;
  while (i < out.length) {
    if (out[i] is! ImplicitStop) {
      i++;
      continue;
    }
    final start = i - 1;
    var end = i;
    while (out[end] is ImplicitStop) {
      end++;
    }
    final from = out[start];
    final to = out[end];
    if (from is! FractionStop || to is! FractionStop) {
      throw const FormatException(
        'An implicit stop next to a px stop cannot be resolved',
      );
    }
    final step = (to.fraction - from.fraction) / (end - start);
    for (var k = start + 1; k < end; k++) {
      out[k] = FractionStop(_round(from.fraction + step * (k - start)));
    }
    i = end;
  }
  return out;
}

/// Parses `cubic-bezier(x1,y1,x2,y2)` (numbers like `.34` allowed).
List<double> parseCubicBezier(String value) {
  final match = _cubic.firstMatch(value.trim());
  if (match == null) throw FormatException('Expected cubic-bezier()', value);
  final points = [for (var i = 1; i <= 4; i++) _parseNumber(match[i]!, value)];
  if (points[0] < 0 || points[0] > 1 || points[2] < 0 || points[2] > 1) {
    throw FormatException('cubic-bezier x values must be within 0–1', value);
  }
  return points;
}

/// One parsed CSS box shadow.
typedef CssShadow = ({
  bool inset,
  double dx,
  double dy,
  double blur,
  double spread,
  int color,
});

/// Parses a comma-separated CSS `box-shadow` list, e.g.
/// `inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A, 0 9px 14px rgba(90,50,20,0.22)`.
List<CssShadow> parseBoxShadowList(String value) {
  final layers = _splitTopLevel(value, ',');
  if (layers.isEmpty || layers.any((l) => l.trim().isEmpty)) {
    throw FormatException('Empty box-shadow layer', value);
  }
  return [for (final layer in layers) _parseShadow(layer.trim(), value)];
}

CssShadow _parseShadow(String layer, String whole) {
  var inset = false;
  int? color;
  // CSS allows the color before or after the lengths, not between them.
  var colorAfterLengths = false;
  final lengths = <double>[];
  for (final token in _splitTopLevel(layer, ' ')) {
    if (token == 'inset') {
      if (inset) throw FormatException('Duplicate inset', whole);
      inset = true;
    } else if (token.startsWith('#') || token.startsWith('rgb')) {
      if (color != null) throw FormatException('Two colors in a layer', whole);
      color = parseCssColor(token);
      colorAfterLengths = lengths.isNotEmpty;
    } else {
      if (colorAfterLengths) {
        throw FormatException('Length after the color', whole);
      }
      lengths.add(_parseLength(token, whole));
    }
  }
  if (color == null) throw FormatException('Shadow without a color', whole);
  if (lengths.length < 2 || lengths.length > 4) {
    throw FormatException('A shadow needs 2–4 lengths', whole);
  }
  if (lengths.length > 2 && lengths[2] < 0) {
    throw FormatException('Negative blur radius', whole);
  }
  return (
    inset: inset,
    dx: lengths[0],
    dy: lengths[1],
    blur: lengths.length > 2 ? lengths[2] : 0,
    spread: lengths.length > 3 ? lengths[3] : 0,
    color: color,
  );
}

/// Parses a CSS length: a unitless `0` or a number of `px`.
double _parseLength(String token, String whole) {
  if (token == '0') return 0;
  if (!token.endsWith('px')) {
    throw FormatException('Lengths must be px (or a bare 0): "$token"', whole);
  }
  return _parseNumber(token.substring(0, token.length - 2), whole);
}

double _parseNumber(String token, String whole) {
  if (!_number.hasMatch(token)) {
    throw FormatException('Not a number: "$token"', whole);
  }
  return double.parse(token);
}

/// Splits [value] on [separator] outside parentheses.
List<String> _splitTopLevel(String value, String separator) {
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < value.length; i++) {
    final c = value[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (depth < 0) throw FormatException('Unbalanced parentheses', value);
    if (depth == 0 && c == separator) {
      parts.add(value.substring(start, i));
      start = i + 1;
    }
  }
  if (depth != 0) throw FormatException('Unbalanced parentheses', value);
  parts.add(value.substring(start));
  return separator == ' '
      ? [
          for (final p in parts)
            if (p.isNotEmpty) p,
        ]
      : parts;
}

/// Converts a CSS `linear-gradient` angle (0deg = to top, clockwise) into
/// Flutter `Alignment` begin/end coordinates.
///
/// CSS stretches the gradient line so its ends touch the box's corners; for
/// a square box that is a line of half-length |sin θ| + |cos θ| in Alignment
/// units, which is what this returns. 180 gives exactly topCenter →
/// bottomCenter. Values are rounded to 4 decimals for stable output.
({double beginX, double beginY, double endX, double endY}) cssAngleToAlignment(
  num degrees,
) {
  final radians = degrees * math.pi / 180;
  final sin = math.sin(radians);
  final cos = math.cos(radians);
  final length = sin.abs() + cos.abs();
  final x = _round(sin * length);
  final y = _round(-cos * length);
  return (beginX: _neg(x), beginY: _neg(y), endX: x, endY: y);
}

/// CSS `radial-gradient` default (ellipse, farthest-corner) radius for a
/// square box, as a fraction of the side, which is Flutter's
/// `RadialGradient.radius` unit (the shortest side).
double farthestCornerRadius(double cx, double cy) {
  final dx = math.max(cx, 1 - cx);
  final dy = math.max(cy, 1 - cy);
  return _round(math.sqrt(dx * dx + dy * dy));
}

double _round(double v) {
  final r = (v * 10000).round() / 10000;
  return r == 0 ? 0 : r; // no -0.0 in the output
}

double _neg(double v) => v == 0 ? 0 : -v;

/// A parsed CSS `linear-gradient(<angle>deg, <stop>, <stop>…)` (tokens v3's
/// `gradient.versus` and `layout.chapters.current.header.scrim`).
typedef CssLinearGradient = ({double angle, List<GradientStop> stops});

final _linearGradient = RegExp(
  r'^linear-gradient\(\s*(-?\d+(?:\.\d+)?)deg\s*,(.+)\)$',
);

/// Parses `linear-gradient(180deg, #7B8BEF, #4E5FD9)`, stops as
/// [parseGradientStop] reads them (colors may be `rgba(…)` with commas).
CssLinearGradient parseCssLinearGradient(String value) {
  final m = _linearGradient.firstMatch(value.trim());
  if (m == null) {
    throw FormatException('Expected linear-gradient(<n>deg, …)', value);
  }
  final stops = [
    for (final stop in _splitTopLevel(m[2]!, ','))
      parseGradientStop(stop.trim()),
  ];
  if (stops.length < 2) {
    throw FormatException('A gradient needs at least two stops', value);
  }
  return (angle: double.parse(m[1]!), stops: stops);
}

/// True when [value] is a `linear-gradient(…)` [parseCssLinearGradient]
/// accepts.
bool isCssLinearGradient(String value) {
  try {
    parseCssLinearGradient(value);
    return true;
  } on FormatException {
    return false;
  }
}

/// A parsed CSS `radial-gradient(circle at <x>% <y>%, <stop>…)` (tokens v5's
/// `gift.button.readyDot.face`): the centre as fractions of the box, and the
/// stops. The size is CSS's default, farthest-corner.
typedef CssRadialGradient = ({double cx, double cy, List<GradientStop> stops});

final _radialGradient = RegExp(
  r'^radial-gradient\(\s*circle at (\d+(?:\.\d+)?)% (\d+(?:\.\d+)?)%\s*,(.+)\)$',
);

/// Parses `radial-gradient(circle at 35% 30%, #FFF3B0, #F5C518 55%, #C9960A)`,
/// stops as [parseGradientStop] reads them.
CssRadialGradient parseCssRadialGradient(String value) {
  final m = _radialGradient.firstMatch(value.trim());
  if (m == null) {
    throw FormatException(
      'Expected radial-gradient(circle at <x>% <y>%, …)',
      value,
    );
  }
  final cx = double.parse(m[1]!) / 100;
  final cy = double.parse(m[2]!) / 100;
  if (cx > 1 || cy > 1) throw FormatException('Centre outside the box', value);
  final stops = [
    for (final stop in _splitTopLevel(m[3]!, ','))
      parseGradientStop(stop.trim()),
  ];
  if (stops.length < 2) {
    throw FormatException('A gradient needs at least two stops', value);
  }
  return (cx: cx, cy: cy, stops: stops);
}

/// True when [value] is a `radial-gradient(…)` [parseCssRadialGradient]
/// accepts.
bool isCssRadialGradient(String value) {
  try {
    parseCssRadialGradient(value);
    return true;
  } on FormatException {
    return false;
  }
}

/// A parsed font shorthand of tokens v3: `Fredoka 700 16 #5B3A21`,
/// `Nunito 800 9.5`, `Fredoka 700 17 #3242A8 tabular`, and the prose tail
/// the design sometimes writes after it (`, sentence case`, `; thinking = …`,
/// ` on a brass gradient`, ` with the replay glyph`).
typedef FontSpec = ({
  String family,
  int weight,
  double size,

  /// Tokens v4's line height (`24/1.15`, `16/23`) as a multiple of [size]:
  /// a number below 4 is already a multiple, a larger one is px (CSS
  /// `line-height`). Null when the value gives none.
  double? height,
  int? color,
  bool tabular,
  String? tail,
});

final _fontSpec = RegExp(
  r'^(Fredoka|Nunito) (\d{3}) (\d+(?:\.\d+)?)(?:/(\d+(?:\.\d+)?))?'
  r'(?: (#[0-9A-Fa-f]{3,8}|rgba?\([^)]*\)|white))?( tabular)?'
  r'(?:(?:, |; | (?=on |with ))(.+))?$',
);

/// Parses a font shorthand ([FontSpec]), or returns null when [value] is
/// not one. The weight is not checked against the bundled ones here: the
/// codegen does that against `font.<role>.weights`.
FontSpec? tryParseFontSpec(String value) {
  final m = _fontSpec.firstMatch(value.trim());
  if (m == null) return null;
  final size = double.parse(m[3]!);
  final lineHeight = m[4] == null ? null : double.parse(m[4]!);
  return (
    family: m[1]!,
    weight: int.parse(m[2]!),
    size: size,
    height: lineHeight == null
        ? null
        : lineHeight < 4
        ? lineHeight
        : double.parse((lineHeight / size).toStringAsFixed(6)),
    color: m[5] == null ? null : parseCssColor(m[5]!),
    tabular: m[6] != null,
    tail: m[7],
  );
}

/// A parsed stroke of tokens v3: `2px #FFFDF7`, `1.5px #D8B07A`.
typedef CssStroke = ({double width, int color});

final _stroke = RegExp(
  r'^(\d+(?:\.\d+)?)px (#[0-9A-Fa-f]{3,8}|rgba?\([^)]*\))$',
);

/// Parses `<n>px <color>`, or returns null when [value] is not one.
CssStroke? tryParseStroke(String value) {
  final m = _stroke.firstMatch(value.trim());
  if (m == null) return null;
  return (width: double.parse(m[1]!), color: parseCssColor(m[2]!));
}

/// The chest card's rays (tokens v3 `chestModal.glow.rays`): one lit wedge
/// of [litDeg] out of every [periodDeg], in [color].
typedef ConicRays = ({int color, double litDeg, double periodDeg});

final _conicRays = RegExp(
  r'^repeating-conic-gradient\((rgba?\([^)]*\)) 0deg (\d+(?:\.\d+)?)deg, '
  r'(rgba?\([^)]*\)) (\d+(?:\.\d+)?)deg (\d+(?:\.\d+)?)deg\)$',
);

/// Parses `repeating-conic-gradient(C 0deg Adeg, C0 Adeg Bdeg)`, where C0
/// is the same colour as C at alpha 0 and starts where C ends.
ConicRays parseConicRays(String value) {
  final m = _conicRays.firstMatch(value.trim());
  if (m == null) {
    throw FormatException('Expected repeating-conic-gradient rays', value);
  }
  final lit = parseCssColor(m[1]!);
  final clear = parseCssColor(m[3]!);
  if (clear != (lit & 0x00FFFFFF) || m[2] != m[4]) {
    throw FormatException(
      'The rays fade to the same colour at 0 alpha, from where they end',
      value,
    );
  }
  final litDeg = double.parse(m[2]!);
  final period = double.parse(m[5]!);
  if (litDeg <= 0 || period <= litDeg || 360 % period != 0) {
    throw FormatException('The ray period must divide 360°', value);
  }
  return (color: lit, litDeg: litDeg, periodDeg: period);
}
