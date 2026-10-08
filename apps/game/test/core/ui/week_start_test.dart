import 'dart:ui';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/week_start.dart';

void main() {
  // The app's own date data: the Material delegate loads Flutter's symbols
  // for every locale it knows (en_GB, pt_PT …), as it does at app start.
  setUpAll(() => GlobalMaterialLocalizations.delegate.load(const Locale('en')));

  int start(String rendered, List<Locale> device) =>
      WeekStart.of(rendered, device);

  test('en_US starts on Sunday', () {
    expect(start('en', const [Locale('en', 'US')]), DateTime.sunday);
  });

  test('en_GB renders as en but starts on Monday', () {
    expect(start('en', const [Locale('en', 'GB')]), DateTime.monday);
  });

  test('en with no device region uses the language: Sunday', () {
    expect(start('en', const []), DateTime.sunday);
    expect(start('en', const [Locale('de', 'DE')]), DateTime.sunday);
  });

  test('the first device locale of the rendered language wins', () {
    expect(
      start('en', const [Locale('de', 'DE'), Locale('en', 'GB')]),
      DateTime.monday,
    );
  });

  test('de_DE, pt_BR, ja_JP, hi_IN, tr_TR', () {
    expect(start('de', const [Locale('de', 'DE')]), DateTime.monday);
    expect(start('pt_BR', const [Locale('pt', 'BR')]), DateTime.sunday);
    expect(start('ja', const [Locale('ja', 'JP')]), DateTime.sunday);
    expect(start('hi', const [Locale('hi', 'IN')]), DateTime.sunday);
    expect(start('tr', const [Locale('tr', 'TR')]), DateTime.monday);
  });

  test('an unknown locale falls back to Monday', () {
    expect(start('xx', const []), DateTime.monday);
  });
}
