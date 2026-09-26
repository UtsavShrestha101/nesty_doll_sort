import 'package:nesty_render/nesty_render.dart' show DollSymbols;

/// How the color-blind belly symbols are drawn (spec §12.3, §16; settings
/// `symbols`, spec §13.3).
///
/// Symbols are always present; [large] draws them bigger on a cream disc
/// (App Flow 8.4). [storageValue] is what gets persisted, so renaming an
/// enum value never breaks saved settings.
enum SymbolsMode {
  /// Spec §13.3 default `"symbols": "subtle"`.
  subtle('subtle', DollSymbols.subtle),

  /// Spec §10.2 / §12.3 "assist mode", stored as `large` (PROGRESS D19, Q4).
  /// Builds before M2 stored `assist`; [fromStorage] still reads it.
  large('large', DollSymbols.large);

  const SymbolsMode(this.storageValue, this.dollSymbols);

  final String storageValue;

  /// The renderer's mode: what `SkinService.prepareForLevel` bakes into the
  /// body rasters and `DollPaintParams.symbols` draws (D45: the bodies are
  /// rebuilt when this changes).
  final DollSymbols dollSymbols;

  /// Values earlier builds persisted, read as today's mode. Never write
  /// these: they are only accepted on read (D19).
  static const Map<String, SymbolsMode> legacyStorageValues = {'assist': large};

  /// Unknown or missing values fall back to [subtle] rather than throwing, so
  /// a corrupt or future value can't break settings loading.
  static SymbolsMode fromStorage(Object? value) {
    for (final mode in values) {
      if (mode.storageValue == value) return mode;
    }
    return legacyStorageValues[value] ?? subtle;
  }
}
