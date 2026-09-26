/// One problem found in an SVG or a skin manifest.
///
/// A plain value with a stable [code] so tools can test for it and the admin
/// (M5) can map it to an ARB message; [message] is the English detail for
/// CLI output and logs.
final class SvgIssue {
  const SvgIssue(this.code, this.message);

  /// Stable, machine-readable identifier, e.g. `forbiddenElement`.
  final String code;

  /// Human-readable detail (English, for tools and logs only).
  final String message;

  @override
  bool operator ==(Object other) =>
      other is SvgIssue && other.code == code && other.message == message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => '$code: $message';
}
