part of 'shop_cubit.dart';

/// What the Shop shows (frames 7.1–7.7; docs/plans/m3-design.md §10.7): the
/// catalog with the save's ownership overlaid, so every tab renders from
/// one snapshot.
@freezed
abstract class ShopState with _$ShopState {
  const factory ShopState({
    /// The segmented control's current tab.
    required ShopTab tab,

    /// The coin pill (header) and the "You have N coins" lines.
    required int coins,

    /// Sold skins only, in catalog order (`forest-bear` never appears,
    /// D75).
    required List<SkinInfo> skins,

    /// `SaveDocument.ownedSkins` (`classic` is always in it).
    required List<String> ownedSkins,

    /// The skin every board actually draws
    /// ([SkinService.selectedSkinId]): the green-ring "Equipped" skin.
    required String selectedSkinId,

    /// Every theme, in catalog (chapter) order.
    required List<ThemeInfo> themes,

    /// `SaveDocument.ownedThemes` (bought early, or `ch01`).
    required List<String> ownedThemes,

    /// `SaveDocument.selectedTheme`: null means "Match each chapter".
    required String? selectedThemeId,

    /// The theme of the chapter the player has reached (or the last
    /// published one in Bonus Endless): what turning the toggle back on
    /// picks, and what "Match each chapter" would show right now.
    required String currentChapterThemeId,

    /// The reached chapter's number, for [ThemeInfo.isOwned].
    required int reachedChapterNumber,
  }) = _ShopState;

  const ShopState._();

  /// The "Match each chapter" toggle (frame 7.7): on exactly while no
  /// theme is explicitly selected.
  bool get matchesChapter => selectedThemeId == null;

  bool ownsSkin(SkinInfo skin) => ownedSkins.contains(skin.id);

  bool isSkinEquipped(SkinInfo skin) => skin.id == selectedSkinId;

  bool ownsTheme(ThemeInfo theme) => theme.isOwned(
    ownedThemes: ownedThemes,
    reachedChapter: reachedChapterNumber,
  );

  /// The green-ring "In use" theme (frame 7.7): the one the board shows
  /// right now, so with "Match each chapter" on it is the current
  /// chapter's theme (FIDELITY-3).
  bool isThemeInUse(ThemeInfo theme) => matchesChapter
      ? theme.id == currentChapterThemeId
      : theme.id == selectedThemeId;
}
