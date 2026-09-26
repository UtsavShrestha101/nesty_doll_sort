// Level tools: validate, solve, simulate and report on levels; build and
// check the game's bundled levels; run the generator; check nesty_core's
// solver fixtures. Every rule and number comes from nesty_core (CLAUDE.md
// rule 2); see tools/README.md and tools/levels/README.md.
//
// Usage: dart run nesty_tools:nesty_levels <command> [arguments]
//   validate|solve|simulate|report [paths]   bundle build|check
//   generate --params <json|file> --seed S [--count N] [--out DIR]
//   fixtures check
// Run with --help for the full list. Exit codes: 0 ok, 1 a check failed,
// 64 bad usage.
import 'dart:io';

import 'package:nesty_tools/src/levels/cli.dart';

void main(List<String> arguments) {
  exitCode = runNestyLevels(arguments, out: stdout, err: stderr);
}
