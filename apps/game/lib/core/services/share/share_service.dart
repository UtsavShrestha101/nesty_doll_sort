import 'dart:ui' show Rect;

/// What the OS share sheet reported (E3; docs/plans/m7-design.md P3.9).
/// The Daily screen shows nothing for any of them: sharing is the player's
/// own act and pays nothing.
enum ShareOutcome {
  /// The player picked a target (Android reports this only on API 22+, and
  /// some targets report [dismissed] even after sharing).
  shared,

  /// The sheet closed without a target.
  dismissed,

  /// The sheet couldn't open, or the platform failed: silently (rule 3).
  unavailable,
}

/// The OS share sheet (E3, the daily share card; spec-prop §10.2 #11,
/// design request I.1; docs/plans/m7-design.md P3.9).
///
/// Implementations: `SharePlusShareService` (real env, over `share_plus`'s
/// `SharePlus.instance.share(ShareParams(...))`) and `FakeShareService`
/// (fake env and tests: records the texts and answers a set outcome). Both
/// are the share lane's (P3.13); the contracts froze this interface.
///
/// Offline-first: sharing plain text needs no network, and nothing the
/// game does waits on it.
abstract interface class ShareService {
  /// Opens the OS share sheet with plain [text]: no image, file or link
  /// (the store link lands in M8). [origin] is the Share button's global
  /// rect, where an iPad anchors its popover. Never throws: any failure is
  /// [ShareOutcome.unavailable], logged under `nesty.share` (rule 3).
  Future<ShareOutcome> shareText(String text, {Rect? origin});
}
