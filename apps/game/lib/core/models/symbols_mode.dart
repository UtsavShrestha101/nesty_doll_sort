/// How the color-blind belly symbols are drawn (spec §12.3, §16).
///
/// Symbols are always present; [assist] makes them larger with a white
/// backing. [storageValue] is what gets persisted, so renaming an enum value
/// never breaks saved settings.
enum SymbolsMode {
  /// Spec §13.3 default `"symbols": "subtle"`.
  subtle('subtle'),

  /// Spec §10.2 / §12.3 "assist mode". The persisted token isn't in the spec
  /// (only "subtle" is) — see docs/PROGRESS.md open questions.
  assist('assist');

  const SymbolsMode(this.storageValue);

  final String storageValue;

  /// Unknown or missing values fall back to [subtle] rather than throwing, so
  /// a corrupt or future value can't break settings loading.
  static SymbolsMode fromStorage(Object? value) => values.firstWhere(
    (mode) => mode.storageValue == value,
    orElse: () => subtle,
  );
}
