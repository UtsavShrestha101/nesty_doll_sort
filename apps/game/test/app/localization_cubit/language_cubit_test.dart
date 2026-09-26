import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';

class _MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late FakeDatabaseService database;

  setUp(() => database = FakeDatabaseService());
  tearDown(() => database.close());

  test('seeds from the persisted locale', () async {
    await database.setLanguage('de');
    final cubit = LanguageCubit(database);
    addTearDown(cubit.close);

    expect(cubit.state.currentLanguageCode, 'de');
    expect(cubit.state.selectedLanguageCode, 'de');
    expect(cubit.currentLocale, const Locale('de'));
  });

  test('parses country-qualified codes into a Locale', () {
    const state = LanguageState(currentLanguageCode: 'pt_BR');
    expect(state.locale, const Locale('pt', 'BR'));
  });

  blocTest<LanguageCubit, LanguageState>(
    'changeLanguage applies the locale at once, then persists it',
    build: () => LanguageCubit(database),
    act: (cubit) => cubit.changeLanguage('fr'),
    // The store's stream echo of 'fr' equals the current state and is
    // dropped, so exactly these two states are emitted.
    expect: () => const [
      LanguageState(
        currentLanguageCode: 'fr',
        selectedLanguageCode: 'fr',
        isLoading: true,
      ),
      LanguageState(currentLanguageCode: 'fr', selectedLanguageCode: 'fr'),
    ],
    verify: (_) => expect(database.languageCode, 'fr'),
  );

  blocTest<LanguageCubit, LanguageState>(
    'follows locale changes written elsewhere through the stream',
    build: () => LanguageCubit(database),
    act: (_) => database.setLanguage('ja'),
    expect: () => const [LanguageState(currentLanguageCode: 'ja')],
  );

  blocTest<LanguageCubit, LanguageState>(
    'a failed write rolls back to the old locale and flags the error',
    build: () {
      final failing = _MockDatabaseService();
      when(() => failing.languageCode).thenReturn('en');
      when(
        () => failing.languageStream,
      ).thenAnswer((_) => const Stream.empty());
      when(() => failing.setLanguage(any())).thenThrow(Exception('disk full'));
      return LanguageCubit(failing);
    },
    act: (cubit) => cubit.changeLanguage('fr'),
    expect: () => const [
      LanguageState(
        currentLanguageCode: 'fr',
        selectedLanguageCode: 'fr',
        isLoading: true,
      ),
      LanguageState(hasError: true),
    ],
  );
}
