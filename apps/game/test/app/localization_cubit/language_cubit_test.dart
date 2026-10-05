import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'support/launch_catalogs.dart';

class _MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late FakeDatabaseService database;
  final nine = AppLocaleResolver(nineLaunchCatalogs);
  const german = [Locale('de', 'DE')];

  LanguageCubit cubitOn(List<Locale> phone) =>
      LanguageCubit(database, resolver: nine, deviceLocales: phone);

  setUp(() => database = FakeDatabaseService());
  tearDown(() => database.close());

  group('a fresh install follows the phone', () {
    test('a German phone opens German', () {
      final cubit = cubitOn(german);
      addTearDown(cubit.close);

      expect(cubit.state.storedLanguageCode, LocaleSetting.system);
      expect(cubit.state.followsPhone, isTrue);
      expect(cubit.state.currentLanguageCode, 'de');
      expect(cubit.state.selectedLanguageCode, 'de');
      expect(cubit.currentLocale, const Locale('de'));
    });

    test('a Portuguese (Portugal) phone opens Brazilian Portuguese', () {
      final cubit = cubitOn(const [Locale('pt', 'PT')]);
      addTearDown(cubit.close);
      expect(cubit.state.currentLanguageCode, 'pt_BR');
      expect(cubit.currentLocale, const Locale('pt', 'BR'));
    });

    test('a Korean phone opens English', () {
      final cubit = cubitOn(const [Locale('ko', 'KR')]);
      addTearDown(cubit.close);
      expect(cubit.state.currentLanguageCode, 'en');
    });

    test('by default, over the catalogs present and the engine\'s list, it '
        'renders a supported language', () {
      final cubit = LanguageCubit(database);
      addTearDown(cubit.close);
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode),
        contains(cubit.currentLocale.languageCode),
      );
    });
  });

  test('a pinned language wins over the phone', () async {
    await database.setLanguage('ja');
    final cubit = cubitOn(german);
    addTearDown(cubit.close);

    expect(cubit.state.storedLanguageCode, 'ja');
    expect(cubit.state.followsPhone, isFalse);
    expect(cubit.state.currentLanguageCode, 'ja');
  });

  test(
    'a pinned language without a catalog renders as "system" would',
    () async {
      await database.setLanguage('de');
      final cubit = LanguageCubit(
        database,
        resolver: AppLocaleResolver(const [Locale('en')]),
        deviceLocales: german,
      );
      addTearDown(cubit.close);
      expect(cubit.state.storedLanguageCode, 'de');
      expect(cubit.state.currentLanguageCode, 'en');
    },
  );

  test('parses country-qualified codes into a Locale', () {
    const state = LanguageState(currentLanguageCode: 'pt_BR');
    expect(state.locale, const Locale('pt', 'BR'));
  });

  blocTest<LanguageCubit, LanguageState>(
    'changeLanguage pins the language and applies it at once, then persists '
    'it',
    build: () => cubitOn(german),
    act: (cubit) => cubit.changeLanguage('fr'),
    // The store's stream echo of 'fr' equals the current state and is
    // dropped, so exactly these two states are emitted.
    expect: () => const [
      LanguageState(
        storedLanguageCode: 'fr',
        currentLanguageCode: 'fr',
        selectedLanguageCode: 'fr',
        isLoading: true,
      ),
      LanguageState(
        storedLanguageCode: 'fr',
        currentLanguageCode: 'fr',
        selectedLanguageCode: 'fr',
      ),
    ],
    verify: (_) => expect(database.languageCode, 'fr'),
  );

  blocTest<LanguageCubit, LanguageState>(
    'picking the language the phone already gives still pins it',
    build: () => cubitOn(german),
    act: (cubit) => cubit.changeLanguage('de'),
    skip: 1,
    expect: () => const [
      LanguageState(
        storedLanguageCode: 'de',
        currentLanguageCode: 'de',
        selectedLanguageCode: 'de',
      ),
    ],
    verify: (cubit) {
      expect(database.languageCode, 'de');
      expect(cubit.state.followsPhone, isFalse);
    },
  );

  blocTest<LanguageCubit, LanguageState>(
    'changeLanguage("system") goes back to following the phone',
    setUp: () => database.setLanguage('ja'),
    build: () => cubitOn(german),
    act: (cubit) => cubit.changeLanguage(LocaleSetting.system),
    skip: 1,
    expect: () => const [
      LanguageState(currentLanguageCode: 'de', selectedLanguageCode: 'de'),
    ],
    verify: (_) => expect(database.languageCode, LocaleSetting.system),
  );

  group('deviceLocalesChanged', () {
    blocTest<LanguageCubit, LanguageState>(
      'while following the phone, the new language renders at once',
      build: () => cubitOn(german),
      act: (cubit) => cubit
        ..deviceLocalesChanged(const [Locale('ja', 'JP')])
        ..deviceLocalesChanged(const [Locale('ko'), Locale('ja')])
        ..deviceLocalesChanged(const [Locale('ko')]),
      expect: () => const [
        LanguageState(currentLanguageCode: 'ja', selectedLanguageCode: 'ja'),
        // [ko, ja] resolves to ja again: nothing new.
        LanguageState(),
      ],
    );

    blocTest<LanguageCubit, LanguageState>(
      'a pinned language ignores the phone',
      setUp: () => database.setLanguage('fr'),
      build: () => cubitOn(german),
      act: (cubit) => cubit.deviceLocalesChanged(const [Locale('ja')]),
      expect: () => const <LanguageState>[],
    );

    test(
      'a later "system" pick resolves against the latest phone list',
      () async {
        await database.setLanguage('fr');
        final cubit = cubitOn(german)
          ..deviceLocalesChanged(const [Locale('tr', 'TR')]);
        addTearDown(cubit.close);
        await cubit.changeLanguage(LocaleSetting.system);
        expect(cubit.state.currentLanguageCode, 'tr');
      },
    );
  });

  blocTest<LanguageCubit, LanguageState>(
    'follows locale changes written elsewhere through the stream',
    build: () => cubitOn(german),
    act: (_) async {
      await database.setLanguage('ja');
      await Future<void>.delayed(Duration.zero);
      await database.setLanguage(LocaleSetting.system);
    },
    expect: () => const [
      LanguageState(
        storedLanguageCode: 'ja',
        currentLanguageCode: 'ja',
        selectedLanguageCode: 'de',
      ),
      LanguageState(currentLanguageCode: 'de', selectedLanguageCode: 'de'),
    ],
  );

  blocTest<LanguageCubit, LanguageState>(
    'a failed write rolls back to the old setting and flags the error',
    build: () {
      final failing = _MockDatabaseService();
      when(() => failing.languageCode).thenReturn(LocaleSetting.system);
      when(
        () => failing.languageStream,
      ).thenAnswer((_) => const Stream.empty());
      when(() => failing.setLanguage(any())).thenThrow(Exception('disk full'));
      return LanguageCubit(failing, resolver: nine, deviceLocales: german);
    },
    act: (cubit) => cubit.changeLanguage('fr'),
    expect: () => const [
      LanguageState(
        storedLanguageCode: 'fr',
        currentLanguageCode: 'fr',
        selectedLanguageCode: 'fr',
        isLoading: true,
      ),
      LanguageState(
        currentLanguageCode: 'de',
        selectedLanguageCode: 'de',
        hasError: true,
      ),
    ],
  );
}
