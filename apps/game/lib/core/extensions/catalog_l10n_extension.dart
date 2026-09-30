import 'package:nesty_game/l10n/app_localizations.dart';

/// The catalog's ARB selects keyed by an id that isn't a valid ICU select
/// key: a skin id may hold `-` (`forest-bear`), which a select case can't, so
/// the ARB keys the case as `forest_bear` (copy.md H; phase 4 architecture
/// §4). Read a skin's name and description through these, never
/// `skinName(id)` directly.
extension CatalogL10n on AppLocalizations {
  /// [skinId]'s ICU select key: `-` becomes `_`.
  static String selectKeyOf(String skinId) => skinId.replaceAll('-', '_');

  /// The skin's display name (`skinName`).
  String skinNameOf(String skinId) => skinName(selectKeyOf(skinId));

  /// The skin's description (`skinDescription`), empty when it has none.
  String skinDescriptionOf(String skinId) =>
      skinDescription(selectKeyOf(skinId));
}
