/// Tiny hand-rolled argument parser (no `package:args`, CLAUDE.md rule 9):
/// boolean `--flags` and `--option=value` / `--option value` pairs.
final class CliArgs {
  CliArgs._(this.flags, this.options, this.rest);

  /// Parses [arguments]. [flags] and [options] list the accepted names
  /// without the leading `--`; anything else is a [FormatException], so a
  /// typo such as `--chek` fails instead of being ignored.
  factory CliArgs.parse(
    List<String> arguments, {
    Set<String> flags = const {},
    Set<String> options = const {},
  }) {
    final seenFlags = <String>{};
    final seenOptions = <String, String>{};
    final rest = <String>[];
    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (!arg.startsWith('--')) {
        rest.add(arg);
        continue;
      }
      final body = arg.substring(2);
      final eq = body.indexOf('=');
      final name = eq == -1 ? body : body.substring(0, eq);
      if (flags.contains(name) && eq == -1) {
        seenFlags.add(name);
      } else if (options.contains(name)) {
        if (eq != -1) {
          seenOptions[name] = body.substring(eq + 1);
        } else if (i + 1 < arguments.length) {
          seenOptions[name] = arguments[++i];
        } else {
          throw FormatException('Option --$name needs a value.');
        }
      } else {
        final accepted = [
          ...flags.map((f) => '--$f'),
          ...options.map((o) => '--$o=<value>'),
        ];
        throw FormatException(
          'Unknown argument "$arg". Accepted: '
          '${accepted.isEmpty ? 'none' : accepted.join(', ')}.',
        );
      }
    }
    return CliArgs._(seenFlags, seenOptions, rest);
  }

  /// The boolean flags that were passed.
  final Set<String> flags;

  /// The options that were passed, by name.
  final Map<String, String> options;

  /// Positional arguments.
  final List<String> rest;

  bool flag(String name) => flags.contains(name);
}
