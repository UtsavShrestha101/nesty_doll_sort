/// External links the Settings screen shows (frame 8.1;
/// docs/plans/m3-design.md §10.2). A row whose value is empty hides
/// (`settingPrivacyPolicy`, `settingSupport`), so shipping with these empty
/// is safe: the rows just don't appear until the owner supplies them.
///
// TODO(M8): the owner's privacy policy URL and support email (Q73).
abstract final class AppLinks {
  static const String privacyPolicyUrl = '';
  static const String supportEmail = '';
}
