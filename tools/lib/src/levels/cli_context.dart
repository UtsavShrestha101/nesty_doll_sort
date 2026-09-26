import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_inputs.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';

/// Exit codes of `nesty_levels`.
abstract final class ExitCodes {
  static const int ok = 0;

  /// A check failed: an invalid level, drift, a tier mismatch, …
  static const int failed = 1;

  /// Bad arguments (as in the other nesty_tools scripts).
  static const int usage = 64;
}

/// Thrown for bad arguments; the CLI prints it with a hint and exits 64.
final class UsageError implements Exception {
  const UsageError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// What every command gets: where to print, the repo root and the directory
/// relative paths resolve against.
final class CliContext {
  CliContext({
    required this.out,
    required this.err,
    required this.root,
    required this.cwd,
  });

  /// Reports and tables.
  final StringSink out;

  /// Findings and errors.
  final StringSink err;

  final Directory root;
  final Directory cwd;

  /// [CliArgs.parse], with its errors as [UsageError]s.
  CliArgs parse(
    List<String> arguments, {
    Set<String> flags = const {},
    Set<String> options = const {},
  }) {
    try {
      return CliArgs.parse(arguments, flags: flags, options: options);
    } on FormatException catch (e) {
      throw UsageError(e.message);
    }
  }

  /// The integer option [name], or [fallback] when absent. Outside
  /// [[min], [max]] is a [UsageError].
  int intOption(
    CliArgs args,
    String name, {
    required int fallback,
    int min = 0,
    int? max,
  }) {
    final text = args.options[name];
    if (text == null) return fallback;
    final value = int.tryParse(text);
    if (value == null || value < min || (max != null && value > max)) {
      throw UsageError(
        '--$name must be an integer ${max == null ? 'of $min or more' : 'in $min–$max'} '
        '(got "$text").',
      );
    }
    return value;
  }

  /// The levels named by [args]' positional paths; with none, the game's
  /// bundle.
  LoadedInputs inputs(CliArgs args) => loadLevelInputs(
    args.rest.isEmpty
        ? [LevelPaths.file(root, LevelPaths.bundle).path]
        : args.rest,
    root: root,
    cwd: cwd,
  );

  /// Prints [findings] to [err], then a one-line tally. Returns the number
  /// of errors.
  int report(List<Finding> findings, {String? what}) {
    for (final finding in findings) {
      err.writeln(finding);
    }
    final errors = findings.where((f) => f.isError).length;
    final warnings = findings.length - errors;
    if (what != null) {
      (errors == 0 ? out : err).writeln(
        '$what: ${errors == 0 ? 'OK' : 'FAILED'} '
        '($errors error${errors == 1 ? '' : 's'}, '
        '$warnings warning${warnings == 1 ? '' : 's'})',
      );
    }
    return errors;
  }
}
