// The home-screen widget's native strings (stage 4 of the local habits,
// docs/plans/plan-local-habits.md §4): the gallery's name and description
// and the "open the game" title before the app has written a snapshot all
// exist before Dart runs, so the ARBs' three keys are generated into iOS
// `Localizable.strings` files and Android `widget_strings.xml` resources.
// Every other widget line comes in the snapshot, already localized.
import 'dart:convert';

/// The ARB keys that become native strings.
const widgetStringKeys = [
  'widgetGalleryName',
  'widgetGalleryDescription',
  'widgetLockedTitle',
];

/// One language of the widget's native strings.
final class WidgetStringsLocale {
  const WidgetStringsLocale(
    this.arb, {
    required this.ios,
    required this.android,
    this.fallbackArb,
  });

  /// The ARB code (`app_<arb>.arb`).
  final String arb;

  /// The iOS `<ios>.lproj` folder name.
  final String ios;

  /// The Android resource folder: `values` (the default) or `values-<tag>`.
  final String android;

  /// The ARB a key falls back to when [arb] doesn't carry it: `pt_BR` is a
  /// regional overlay of `pt`.
  final String? fallbackArb;
}

/// The nine launch languages, English first (the Android default).
const widgetStringsLocales = [
  WidgetStringsLocale('en', ios: 'en', android: 'values'),
  WidgetStringsLocale('es', ios: 'es', android: 'values-es'),
  WidgetStringsLocale('pt', ios: 'pt', android: 'values-pt'),
  WidgetStringsLocale(
    'pt_BR',
    ios: 'pt-BR',
    android: 'values-pt-rBR',
    fallbackArb: 'pt',
  ),
  WidgetStringsLocale('id', ios: 'id', android: 'values-id'),
  WidgetStringsLocale('hi', ios: 'hi', android: 'values-hi'),
  WidgetStringsLocale('de', ios: 'de', android: 'values-de'),
  WidgetStringsLocale('fr', ios: 'fr', android: 'values-fr'),
  WidgetStringsLocale('tr', ios: 'tr', android: 'values-tr'),
  WidgetStringsLocale('ja', ios: 'ja', android: 'values-ja'),
];

/// Repo-relative ARB folder and the two native output roots.
const widgetArbDir = 'apps/game/lib/l10n';
const widgetIosDir = 'apps/game/ios/NestyWidget';
const widgetAndroidValuesDir = 'apps/game/android/app/src/main/res';

/// `NestyWidget/<lproj>.lproj/Localizable.strings` of [locale].
String iosStringsPath(WidgetStringsLocale locale) =>
    '$widgetIosDir/${locale.ios}.lproj/Localizable.strings';

/// `res/<values>/widget_strings.xml` of [locale].
String androidStringsPath(WidgetStringsLocale locale) =>
    '$widgetAndroidValuesDir/${locale.android}/widget_strings.xml';

/// The Android resource name of an ARB key: `widgetGalleryName` →
/// `widget_gallery_name`.
String androidNameOf(String key) =>
    key.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// The value of each of [widgetStringKeys] for [locale]: from its ARB
/// ([arbs] maps an ARB code to its decoded JSON), else its fallback's, else
/// the English one is an error. Throws a [FormatException] when a key is
/// missing everywhere, isn't a string, or carries an ICU placeholder (these
/// three lines are plain text).
Map<String, String> widgetStringsFor(
  WidgetStringsLocale locale,
  Map<String, Map<String, Object?>> arbs,
) {
  final result = <String, String>{};
  for (final key in widgetStringKeys) {
    Object? value;
    for (final code in [locale.arb, ?locale.fallbackArb]) {
      value = arbs[code]?[key];
      if (value != null) break;
    }
    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'app_${locale.arb}.arb: "$key" is missing or not a string',
      );
    }
    if (value.contains('{') || value.contains('}')) {
      throw FormatException(
        'app_${locale.arb}.arb: "$key" has a placeholder; the native strings '
        'are plain text',
      );
    }
    result[key] = value;
  }
  return result;
}

/// `Localizable.strings` for [values] (key → text), keys as the ARB's.
String iosStringsFile(WidgetStringsLocale locale, Map<String, String> values) {
  final buffer = StringBuffer()
    ..writeln('/*')
    ..writeln(
      '  GENERATED — do not edit; run dart run nesty_tools:gen_widget_strings',
    )
    ..writeln()
    ..writeln(
      '  Source: $widgetArbDir/app_${locale.arb}.arb. The widget gallery\'s '
      'name',
    )
    ..writeln(
      '  and description, and the title shown before the app has written '
      'anything',
    )
    ..writeln('  (stage 4 of the local habits).')
    ..writeln('*/');
  for (final MapEntry(:key, :value) in values.entries) {
    buffer.writeln('"$key" = "${_iosEscape(value)}";');
  }
  return buffer.toString();
}

/// `widget_strings.xml` for [values] (key → text), names snake-cased.
String androidStringsFile(
  WidgetStringsLocale locale,
  Map<String, String> values,
) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="utf-8"?>')
    ..writeln('<!--')
    ..writeln(
      '  GENERATED — do not edit; run dart run nesty_tools:gen_widget_strings',
    )
    ..writeln()
    ..writeln(
      '  Source: $widgetArbDir/app_${locale.arb}.arb. The widget picker\'s '
      'name and',
    )
    ..writeln(
      '  description, and the title shown before the app has written '
      'anything',
    )
    ..writeln('  (stage 4 of the local habits).')
    ..writeln('-->')
    ..writeln('<resources>');
  for (final MapEntry(:key, :value) in values.entries) {
    buffer.writeln(
      '    <string name="${androidNameOf(key)}">${_androidEscape(value)}'
      '</string>',
    );
  }
  buffer.writeln('</resources>');
  return buffer.toString();
}

String _iosEscape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('"', r'\"')
    .replaceAll('\n', r'\n');

/// Android string resources: XML-escaped, then the characters aapt reads as
/// syntax (`'`, `"`, a leading `@` or `?`, `\`, a newline) escaped.
String _androidEscape(String value) {
  var text = value
      .replaceAll(r'\', r'\\')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll("'", r"\'")
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n');
  if (text.startsWith('@') || text.startsWith('?')) text = '\\$text';
  return text;
}

/// Every generated file as repo-relative path → content, read from the
/// decoded ARBs.
Map<String, String> widgetStringFiles(Map<String, Map<String, Object?>> arbs) {
  final files = <String, String>{};
  for (final locale in widgetStringsLocales) {
    final values = widgetStringsFor(locale, arbs);
    files[iosStringsPath(locale)] = iosStringsFile(locale, values);
    files[androidStringsPath(locale)] = androidStringsFile(locale, values);
  }
  return files;
}

/// Decodes one ARB file's text.
Map<String, Object?> decodeArb(String text) =>
    jsonDecode(text) as Map<String, Object?>;
