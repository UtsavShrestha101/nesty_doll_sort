/// The two kinds of tokens.json `font.scripts` entry.
///
/// m7-4's `deva` and `jpan` draw their own script per glyph: each is a
/// family in every Latin style's `fontFamilyFallback`, and maps only its
/// script (`AppFontTokens.displayFallback` / `bodyFallback`). m7-5's
/// `latnTr` (item 28) is the other kind: Fredoka has no ğ Ğ İ ş Ş, so in
/// Turkish Baloo 2 replaces the display face for the whole string, never per
/// glyph, and is in no fallback chain.
library;

/// Whether tokens.json `font.scripts.<script>` replaces a Latin face for
/// whole strings in its locales (a `latn…` key, m7-5 `latnTr`) rather than
/// drawing its own script per glyph through the fallback chain.
bool isWholeStringScript(String script) => script.startsWith('latn');

/// The pubspec family of a whole-string face: the design family without
/// spaces, then the script key (`Baloo 2` + `latnTr` → `Baloo2LatnTr`).
/// Its own name, because the per-glyph `Baloo2Display` files of `deva` hold
/// only Devanagari and answer other weights.
String wholeStringFamilyName(String designFamily, String script) =>
    '${designFamily.replaceAll(' ', '')}'
    '${script[0].toUpperCase()}${script.substring(1)}';
