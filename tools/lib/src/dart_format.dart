import 'dart:convert';
import 'dart:io';

/// Formats Dart [source] with the SDK's `dart format`, as if it were the file
/// at [targetPath], so the target package's language version (and therefore
/// its formatter style) applies. Using the CLI instead of `package:dart_style`
/// avoids a dependency and matches the format-on-write hook exactly.
///
/// Throws a [StateError] with the formatter's message when [source] does not
/// parse: that is a codegen bug and must fail loudly.
Future<String> formatDart(String source, {required String targetPath}) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'format',
    '--stdin-name=$targetPath',
  ]);
  final stdoutFuture = process.stdout.transform(utf8.decoder).join();
  final stderrFuture = process.stderr.transform(utf8.decoder).join();
  process.stdin.write(source);
  await process.stdin.close();
  final exitCode = await process.exitCode;
  final out = await stdoutFuture;
  final err = await stderrFuture;
  if (exitCode != 0) {
    throw StateError('dart format failed for $targetPath:\n$err');
  }
  return out;
}
