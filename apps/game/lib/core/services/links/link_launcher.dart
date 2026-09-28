/// Opens external links from Settings (frame 8.1: Privacy Policy, Support
/// — docs/plans/m3-design.md §10.2).
///
/// `UrlLinkLauncher` (real env) wraps `url_launcher` with
/// `LaunchMode.externalApplication`, never calling `canLaunchUrl` first (so
/// no `<queries>`/`LSApplicationQueriesSchemes` entries are needed); a
/// launch that fails or returns false is ignored (rule 3).
/// `FakeLinkLauncher` (fake env) records what it was asked to open.
abstract interface class LinkLauncher {
  /// Opens [url] in the platform browser or app. Never throws.
  Future<void> openUrl(String url);

  /// Opens the platform email composer addressed to [address]. Never
  /// throws.
  Future<void> email(String address);
}
