// Small helpers that turn token values into Dart source. Output must be
// deterministic: same tokens.json → byte-identical files.

const _reserved = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case', //
  'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
  'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
  'external', 'factory', 'false', 'final', 'finally', 'for', 'function',
  'get', 'hide', 'if', 'implements', 'import', 'in', 'interface', 'is',
  'late', 'library', 'mixin', 'new', 'null', 'of', 'on', 'operator', 'part',
  'required', 'rethrow', 'return', 'sealed', 'set', 'show', 'static',
  'super', 'switch', 'sync', 'this', 'throw', 'true', 'try', 'type',
  'typedef', 'var', 'void', 'when', 'while', 'with', 'yield', 'values',
};

final _identifier = RegExp(r'^[a-z][A-Za-z0-9]*$');
final _sizeKey = RegExp(r'^(\d)xl$');

/// Turns a tokens.json key into a Dart member name. Keys are already
/// camelCase; the only rewrite is the t-shirt size `2xl` → `xxl` (a Dart
/// identifier can't start with a digit). Anything else that isn't a valid,
/// non-reserved identifier throws.
String memberName(String key) {
  final size = _sizeKey.firstMatch(key);
  final name = size == null ? key : '${'x' * (int.parse(size[1]!) - 1)}xl';
  if (!_identifier.hasMatch(name) || _reserved.contains(name)) {
    throw FormatException('Token key is not a usable Dart name', key);
  }
  return name;
}

/// `Color(0xAARRGGBB)`.
String colorLiteral(int argb) =>
    'Color(0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()})';

/// A double literal that always has a decimal point (`12.0`), so the
/// constant's inferred type is `double`.
String doubleLiteral(num value) {
  final d = value.toDouble();
  if (d.isNaN || d.isInfinite) {
    throw FormatException('Not a finite number', '$value');
  }
  final text = d == 0 ? '0.0' : d.toString();
  return text.contains('.') || text.contains('e') ? text : '$text.0';
}

/// A single-quoted Dart string literal.
String stringLiteral(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

/// `Size(w, h)`.
String sizeLiteral(num width, num height) =>
    'Size(${doubleLiteral(width)}, ${doubleLiteral(height)})';

/// `Offset(x, y)`.
String offsetLiteral(num x, num y) =>
    'Offset(${doubleLiteral(x)}, ${doubleLiteral(y)})';

/// `Cubic(a, b, c, d)`.
String cubicLiteral(List<double> points) =>
    'Cubic(${points.map(doubleLiteral).join(', ')})';

/// `Alignment(x, y)`, using the named constants where they apply.
String alignmentLiteral(double x, double y) {
  const named = {
    '0.0,-1.0': 'Alignment.topCenter',
    '0.0,1.0': 'Alignment.bottomCenter',
    '-1.0,0.0': 'Alignment.centerLeft',
    '1.0,0.0': 'Alignment.centerRight',
    '0.0,0.0': 'Alignment.center',
  };
  return named['${doubleLiteral(x)},${doubleLiteral(y)}'] ??
      'Alignment(${doubleLiteral(x)}, ${doubleLiteral(y)})';
}

/// A `///` doc comment block, wrapped at roughly 76 columns.
String docComment(String text, {String indent = '  '}) {
  final lines = <String>[];
  for (final paragraph in text.split('\n')) {
    var line = '';
    for (final word in paragraph.split(' ')) {
      if (line.isNotEmpty && line.length + word.length + 1 > 74) {
        lines.add(line);
        line = word;
      } else {
        line = line.isEmpty ? word : '$line $word';
      }
    }
    lines.add(line);
  }
  return lines
      .map((l) => l.isEmpty ? '$indent///' : '$indent/// $l')
      .join('\n');
}

/// Accumulates `static const` members of one `abstract final class` and
/// records each emitted symbol, e.g. `AppColorTokens.background`.
final class ConstClass {
  ConstClass(this.name, this.doc);

  final String name;
  final String doc;
  final _members = <String>[];
  final _names = <String>{};

  /// Adds `static const [member] = [expression];` (typed when [type] is
  /// given) and returns the qualified symbol for the parity ledger.
  String add(String member, String expression, {String? doc, String? type}) {
    if (!_names.add(member)) {
      throw StateError('Duplicate member $name.$member');
    }
    final buffer = StringBuffer();
    if (doc != null) buffer.writeln(docComment(doc));
    buffer.write(
      '  static const ${type == null ? '' : '$type '}$member = '
      '$expression;',
    );
    _members.add(buffer.toString());
    return '$name.$member';
  }

  /// Adds a hand-built member (e.g. a static method).
  void addRaw(String source) => _members.add(source);

  String build() => [
    docComment(doc, indent: ''),
    'abstract final class $name {',
    _members.join('\n\n'),
    '}',
  ].join('\n');
}
