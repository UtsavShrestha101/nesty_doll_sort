import '../support/locale_rules.dart';
import 'de.dart';
import 'en.dart';
import 'es.dart';
import 'fr.dart';
import 'hi.dart';
import 'id.dart';
import 'ja.dart';
import 'pt.dart';
import 'tr.dart';

export '../support/locale_rules.dart';

/// The nine launch locales' ARB codes (spec §16; l10n.md §5.3): `pt` holds
/// the Brazilian catalog and `pt_BR` only its `@@locale`.
const launchArbCodes = [
  'en',
  'es',
  'pt',
  'pt_BR',
  'id',
  'hi',
  'de',
  'fr',
  'tr',
  'ja',
];

const _rules = <String, LocaleRules>{
  'en': enRules,
  'es': esRules,
  'pt': ptRules,
  'id': idRules,
  'hi': hiRules,
  'de': deRules,
  'fr': frRules,
  'tr': trRules,
  'ja': jaRules,
};

/// [code]'s rules: an ARB code (`fr`, `pt_BR`) or a stored setting. A
/// region inherits its language's rules (`pt_BR` → `pt`). Null for a
/// locale outside the launch set.
LocaleRules? rulesFor(String code) =>
    _rules[code] ?? _rules[code.split(RegExp('[_-]')).first];
