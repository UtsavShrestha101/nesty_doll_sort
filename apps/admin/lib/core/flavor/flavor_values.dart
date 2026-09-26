/// Values that genuinely differ per flavor.
///
/// Keep this small: only add a field when a value really changes between
/// dev/stg/prod. Secrets never go here — Firebase options come from the
/// owner's `flutterfire configure` output (M5), never from this class.
class FlavorValues {
  const FlavorValues({required this.appTitle});

  /// `MaterialApp.title`, which is the browser tab title on web. Dev and stg
  /// are prefixed so tabs pointed at different projects are easy to tell
  /// apart.
  final String appTitle;
}
