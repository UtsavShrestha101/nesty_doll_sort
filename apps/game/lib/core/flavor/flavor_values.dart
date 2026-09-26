/// Values that genuinely differ per flavor.
///
/// Keep this small: only add a field when a value really changes between
/// dev/stg/prod. Secrets never go here — real ad unit IDs arrive through
/// `--dart-define` at build time (CLAUDE.md rule 5), and Firebase options come
/// from the owner's `flutterfire configure` output (M4).
class FlavorValues {
  const FlavorValues({required this.appTitle});

  /// `MaterialApp.title` (task switcher / recent apps). Dev and stg are
  /// prefixed so side-by-side installs are easy to tell apart.
  final String appTitle;
}
