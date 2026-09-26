import 'dart:convert';

import 'package:nesty_tools/src/tokens/render_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';
import 'package:nesty_tools/src/tokens/ui_tokens_codegen.dart';

/// Repo-relative path of the token source.
const tokensJsonPath = 'design/tokens.json';

/// Repo-relative output paths.
const renderTokensPath =
    'packages/nesty_render/lib/src/tokens/render_tokens.gen.dart';
const uiTokensPath = 'apps/game/lib/core/ui/tokens/ui_tokens.gen.dart';

/// The result of one codegen run (unformatted sources plus the ledger).
final class DesignTokensOutput {
  DesignTokensOutput(this.files, this.reader);

  /// Repo-relative path → unformatted Dart source.
  final Map<String, String> files;

  /// The reader, whose `uses` say how each tokens.json leaf was consumed.
  final TokenReader reader;
}

/// Generates both token files from the decoded [tokensJson] text.
///
/// Throws [TokenFormatException] when a value has an unexpected shape and a
/// [StateError] when a tokens.json leaf is not accounted for, so a design
/// change never slips through half-generated.
DesignTokensOutput generateDesignTokens(String tokensJson) {
  final decoded = jsonDecode(tokensJson);
  if (decoded is! Map<String, Object?>) {
    throw TokenFormatException('', 'tokens.json must be an object');
  }
  final reader = TokenReader(decoded);
  final description = reader.documented(
    r'$description',
    reason: 'file header comment',
  );
  final header = [
    '// GENERATED — do not edit; run dart run nesty_tools:gen_design_tokens',
    '//',
    '// Source: $tokensJsonPath (tokens v${reader.peek('meta.version')}).',
    for (final line in _wrap(description)) '// $line',
    '',
  ].join('\n');
  final files = {
    renderTokensPath: renderTokensSource(reader, header: header),
    uiTokensPath: uiTokensSource(reader, header: header),
  };
  final missing = reader.unaccounted;
  if (missing.isNotEmpty) {
    throw StateError(
      'tokens.json leaves with no codegen mapping (emit or document them in '
      'tools/lib/src/tokens/):\n  ${missing.join('\n  ')}',
    );
  }
  return DesignTokensOutput(files, reader);
}

List<String> _wrap(String text) {
  final lines = <String>[];
  var line = '';
  for (final word in text.split(' ')) {
    if (line.isNotEmpty && line.length + word.length + 1 > 76) {
      lines.add(line);
      line = word;
    } else {
      line = line.isEmpty ? word : '$line $word';
    }
  }
  if (line.isNotEmpty) lines.add(line);
  return lines;
}
