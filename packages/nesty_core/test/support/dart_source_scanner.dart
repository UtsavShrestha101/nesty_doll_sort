/// A tiny Dart lexer used by the architecture guard.
///
/// A plain regex over source text is fooled by comments (`// DateTime.now()`
/// in a doc comment) and by strings (`'Random()'` in an error message). This
/// scanner blanks those out while keeping every newline, so reported line
/// numbers still match the file. It understands line and nested block
/// comments, single/double/triple-quoted and raw strings, escapes, and both
/// `$name` and `${expression}` interpolation. Interpolated code is kept,
/// because `'${Random().nextInt(3)}'` must still be caught.
library;

/// One file after lexing. Both views have exactly the length of the source,
/// so an offset in one is the same position in the other and in the file.
class ScannedSource {
  ScannedSource._(this.code, this.codeAndStrings);

  /// Lexes [source].
  factory ScannedSource.parse(String source) {
    final lexer = _Lexer(source)..run();
    return ScannedSource._(lexer.code.toString(), lexer.strings.toString());
  }

  /// Source with comments and string-literal contents replaced by spaces.
  /// Quote characters and interpolated expressions are kept.
  final String code;

  /// Source with only comments replaced by spaces. Directive URIs are string
  /// literals, so they are read from this view.
  final String codeAndStrings;
}

/// A banned construct found in a scanned file.
class Violation {
  const Violation(this.file, this.line, this.detail);

  final String file;
  final int line;
  final String detail;

  @override
  String toString() => '$file:$line  $detail';
}

/// An `import` or `export` directive.
class Directive {
  const Directive(this.line, this.uris, this.code);

  /// 1-based line the directive starts on.
  final int line;

  /// Every URI in the directive, including conditional-import URIs.
  final List<String> uris;

  /// The directive with string contents blanked, e.g. to read combinators
  /// such as `show Random`.
  final String code;
}

/// Every `import` / `export` directive in [source].
List<Directive> directives(ScannedSource source) => [
  // Spans come from the `code` view: a line inside a multi-line string that
  // happens to read `import '...';` is blanked there and cannot match.
  for (final span in _directive.allMatches(source.code))
    Directive(_lineOf(source.code, span.start), [
      for (final uri in _stringLiteral.allMatches(
        source.codeAndStrings.substring(span.start, span.end),
      ))
        uri.group(2)!,
    ], span.group(0)!),
];

/// Lines (1-based) where [pattern] matches executable code, ignoring
/// comments, string contents and `import`/`export` directives (so that
/// `import 'dart:math' hide Random;` is not itself a violation).
List<int> codeMatches(ScannedSource source, RegExp pattern) {
  final code = source.code.replaceAllMapped(
    _directive,
    (m) => m.group(0)!.replaceAll(_notNewline, ' '),
  );
  return [
    for (final match in pattern.allMatches(code)) _lineOf(code, match.start),
  ];
}

// A directive starts a line and runs to its `;`. Applied to the `code` view,
// where a `;` inside a string literal has already been blanked.
final _directive = RegExp(r'^[ \t]*(?:import|export)\b[^;]*;', multiLine: true);
final _stringLiteral = RegExp(r'''r?(['"])(.*?)\1''');
final _notNewline = RegExp('[^\n]');
final _identifierChar = RegExp(r'[A-Za-z0-9_$]');
final _interpolationStart = RegExp('[A-Za-z_]');
final _interpolationChar = RegExp('[A-Za-z0-9_]');

int _lineOf(String text, int offset) =>
    '\n'.allMatches(text.substring(0, offset)).length + 1;

sealed class _Context {}

/// Code at top level, or inside `${...}` (where the matching `}` ends it).
final class _CodeContext extends _Context {
  _CodeContext({required this.isInterpolation});

  final bool isInterpolation;
  int braceDepth = 0;
}

final class _StringContext extends _Context {
  _StringContext({
    required this.quote,
    required this.isTriple,
    required this.isRaw,
  });

  final String quote;
  final bool isTriple;
  final bool isRaw;
}

class _Lexer {
  _Lexer(this.source);

  final String source;
  final StringBuffer code = StringBuffer();
  final StringBuffer strings = StringBuffer();
  final List<_Context> _stack = [_CodeContext(isInterpolation: false)];
  int _i = 0;

  void run() {
    while (_i < source.length) {
      switch (_stack.last) {
        case final _CodeContext context:
          _scanCode(context);
        case final _StringContext context:
          _scanString(context);
      }
    }
  }

  void _scanCode(_CodeContext context) {
    final char = source[_i];
    if (_startsWith('//')) {
      while (_i < source.length && source[_i] != '\n') {
        _blankBoth();
      }
    } else if (_startsWith('/*')) {
      _skipBlockComment();
    } else if (char == 'r' && _isQuoteAt(_i + 1) && !_isIdentifierAt(_i - 1)) {
      _emitBoth(); // The raw-string `r` prefix.
      _openString(isRaw: true);
    } else if (_isQuoteAt(_i)) {
      _openString(isRaw: false);
    } else if (char == '}' &&
        context.isInterpolation &&
        context.braceDepth == 0) {
      _stack.removeLast();
      _emitStringOnly();
    } else {
      if (char == '{') context.braceDepth++;
      if (char == '}') context.braceDepth--;
      _emitBoth();
    }
  }

  void _scanString(_StringContext context) {
    final char = source[_i];
    final closing = context.isTriple ? context.quote * 3 : context.quote;
    if (_startsWith(closing)) {
      for (var n = 0; n < closing.length; n++) {
        _emitBoth();
      }
      _stack.removeLast();
    } else if (char == '\n' && !context.isTriple) {
      // Unterminated single-line string: recover at the newline instead of
      // treating the rest of the file as string, which would hide violations.
      _stack.removeLast();
    } else if (!context.isRaw && char == r'\') {
      _emitStringOnly();
      if (_i < source.length) _emitStringOnly();
    } else if (!context.isRaw && _startsWith(r'${')) {
      _emitStringOnly();
      _emitStringOnly();
      _stack.add(_CodeContext(isInterpolation: true));
    } else if (!context.isRaw &&
        char == r'$' &&
        _matchesAt(_interpolationStart, _i + 1)) {
      // `$name` interpolation: the `$` becomes a space in the code view,
      // which keeps the name a separate token, and the name is code.
      _emitStringOnly();
      while (_matchesAt(_interpolationChar, _i)) {
        _emitBoth();
      }
    } else {
      _emitStringOnly();
    }
  }

  void _openString({required bool isRaw}) {
    final quote = source[_i];
    final isTriple = _startsWith(quote * 3);
    for (var n = 0; n < (isTriple ? 3 : 1); n++) {
      _emitBoth();
    }
    _stack.add(_StringContext(quote: quote, isTriple: isTriple, isRaw: isRaw));
  }

  void _skipBlockComment() {
    // Dart block comments nest.
    var depth = 0;
    do {
      if (_startsWith('/*')) {
        depth++;
        _blankBoth();
        _blankBoth();
      } else if (_startsWith('*/')) {
        depth--;
        _blankBoth();
        _blankBoth();
      } else {
        _blankBoth();
      }
    } while (depth > 0 && _i < source.length);
  }

  bool _startsWith(String text) => source.startsWith(text, _i);

  bool _isQuoteAt(int index) =>
      index < source.length && (source[index] == "'" || source[index] == '"');

  bool _isIdentifierAt(int index) =>
      index >= 0 && _matchesAt(_identifierChar, index);

  bool _matchesAt(RegExp pattern, int index) =>
      index < source.length && pattern.hasMatch(source[index]);

  void _emitBoth() {
    code.write(source[_i]);
    strings.write(source[_i]);
    _i++;
  }

  void _emitStringOnly() {
    final char = source[_i];
    code.write(char == '\n' ? '\n' : ' ');
    strings.write(char);
    _i++;
  }

  void _blankBoth() {
    final char = source[_i] == '\n' ? '\n' : ' ';
    code.write(char);
    strings.write(char);
    _i++;
  }
}
