import 'dart:ui';

/// The catalogs the nine launch languages will have once every ARB lands
/// (spec §16; l10n plan §5.3: `app_pt` holds Brazilian Portuguese,
/// `app_pt_BR` only its `@@locale`). The resolver and cubit tests run over
/// it, so they cover the nine before the translators' ARBs exist.
const nineLaunchCatalogs = [
  Locale('en'),
  Locale('es'),
  Locale('pt'),
  Locale('pt', 'BR'),
  Locale('id'),
  Locale('hi'),
  Locale('de'),
  Locale('fr'),
  Locale('tr'),
  Locale('ja'),
];

/// The nine launch languages' codes as the settings key stores them (the
/// language sheet's codes).
const nineLaunchCodes = [
  'en',
  'es',
  'pt_BR',
  'id',
  'hi',
  'de',
  'fr',
  'tr',
  'ja',
];
