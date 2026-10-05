import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'core/ui/support/ui_harness.dart';
import 'helpers/test_dependencies.dart';

/// The app's language on the whole app (M7 phase 5B; l10n plan §1.4, §7.1):
/// a fresh install follows the phone's languages, a pick in Settings' sheet
/// pins one, the app redraws in it at once, and the pin survives a restart.
///
/// The catalogs come from the ARBs present (`AppLocalizations
/// .supportedLocales`), so the per-language cases grow as the translators'
/// ARBs land; with English alone they check the wiring and the persistence.
/// A simulator can't change its own language mid-run, so the phone's list
/// is `tester.platformDispatcher.localesTestValue` here, and the device
/// step (`integration_test/locales_test.dart`) seeds or picks a language.
void main() {
  setUpAll(loadBundledFonts);
  setUp(configureTestDependencies);
  tearDown(resetDependencies);

  /// One locale per catalog language (pt and pt_BR are one language).
  final catalogLanguages = {
    for (final locale in AppLocalizations.supportedLocales) locale.languageCode,
  }.toList();
  final otherLanguages = [
    for (final language in catalogLanguages)
      if (language != 'en') language,
  ];

  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  /// See `app_flow_test.dart`'s `settle`: real Hive I/O only finishes by
  /// alternating `runAsync` with `pump`.
  Future<void> settle(WidgetTester tester, Future<void> future) async {
    var done = false;
    unawaited(future.whenComplete(() => done = true));
    for (var i = 0; i < 200 && !done; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(done, isTrue, reason: 'the disk work settled');
  }

  void phoneSpeaks(WidgetTester tester, List<Locale> locales) {
    tester.platformDispatcher.localesTestValue = locales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  void phoneSize(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// The locale the whole tree renders in (Material's and the app's
  /// catalogs read the same one).
  Locale rendered(WidgetTester tester) =>
      Localizations.localeOf(tester.element(find.byType(Navigator).first));

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(Navigator).first));

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
  }

  group('a fresh install follows the phone', () {
    for (final language in catalogLanguages) {
      testWidgets('a "$language" phone opens in it', (tester) async {
        phoneSpeaks(tester, [const Locale('ko'), Locale(language, 'XX')]);
        await seedSavePastFirstLevel();
        expect(get<DatabaseService>().languageCode, LocaleSetting.system);

        await pumpApp(tester);
        expect(find.byType(HomePage), findsOneWidget);
        expect(rendered(tester).languageCode, language);
        expect(l10nOf(tester).localeName, startsWith(language));
        expect(get<LanguageCubit>().state.followsPhone, isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a Korean phone opens English', (tester) async {
      phoneSpeaks(tester, const [Locale('ko', 'KR'), Locale('zh', 'CN')]);
      await seedSavePastFirstLevel();

      await pumpApp(tester);
      expect(rendered(tester), const Locale('en'));
      expect(get<LanguageCubit>().state.currentLanguageCode, 'en');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the app root feeds the phone list at start and on every '
        'change', (tester) async {
      phoneSpeaks(tester, const [Locale('ko')]);
      await seedSavePastFirstLevel();
      final seen = <List<Locale>>[];
      await get.unregister<LanguageCubit>();
      get.registerSingleton<LanguageCubit>(
        _RecordingLanguageCubit(get<DatabaseService>(), seen),
        dispose: (cubit) => cubit.close(),
      );

      await pumpApp(tester);
      expect(seen.first, const [Locale('ko')]);

      final next = [
        for (final language in otherLanguages) Locale(language),
        const Locale('en', 'GB'),
      ];
      tester.platformDispatcher.localesTestValue = next;
      await tester.pump();
      expect(seen.last, next);
      // The first catalog language in the new list renders at once.
      expect(
        rendered(tester).languageCode,
        otherLanguages.isEmpty ? 'en' : otherLanguages.first,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a pin redraws the app at once, under the open Settings page, '
      'for every catalog', (tester) async {
    phoneSize(tester);
    phoneSpeaks(tester, const [Locale('ko')]);
    await seedSavePastFirstLevel();
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel(l10nOf(tester).settings));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(SettingsPage), findsOneWidget);

    for (final locale in [
      ...AppLocalizations.supportedLocales.reversed,
      const Locale('en'),
    ]) {
      // As the sheet's onSelect does (settings_page.dart).
      unawaited(get<LanguageCubit>().changeLanguage(locale.toString()));
      await tester.pump();
      expect(rendered(tester).languageCode, locale.languageCode);
      expect(
        find.byType(SettingsPage),
        findsOneWidget,
        reason: 'the language changes in place: no navigation reset',
      );
      expect(get<DatabaseService>().languageCode, locale.toString());
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a language in the sheet pins it, and the pin survives '
      'a restart whatever the phone says', (tester) async {
    phoneSize(tester);
    // Every other catalog's language first, so "system" would never give
    // English once a translation exists: the restart proves the pin.
    phoneSpeaks(tester, [
      for (final language in otherLanguages) Locale(language),
      const Locale('ko'),
    ]);
    final tempDir = Directory.systemTemp.createTempSync('nesty_locale');
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    // As app_flow_test (a): the real Hive store on a temp directory, so
    // the restart is a round trip through disk.
    Future<void> bootOnTempDir({bool seed = false}) async {
      await tester.runAsync(() async {
        await configureTestDependencies();
        final database = await HiveDatabaseService.open(
          directory: tempDir.path,
        );
        await get.unregister<DatabaseService>();
        get.registerSingleton<DatabaseService>(database);
        if (seed) {
          await database.writeSaveDocument(
            SaveDocumentCodec.write(const SaveDocument(highestLevel: 2)),
          );
        }
        final save = HiveSaveService(database, get<RemoteConfigService>());
        await get.unregister<SaveService>();
        get.registerSingleton<SaveService>(save);
      });
      await pumpApp(tester);
      expect(find.byType(HomePage), findsOneWidget);
    }

    Future<void> shutDown() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await settle(tester, get<SaveService>().flush());
      await settle(tester, get<DatabaseService>().close());
    }

    // --- First launch: nothing stored, so the phone decides. ---
    await bootOnTempDir(seed: true);
    expect(get<DatabaseService>().languageCode, LocaleSetting.system);
    expect(
      rendered(tester).languageCode,
      otherLanguages.isEmpty ? 'en' : otherLanguages.first,
    );

    // --- Settings → Language → English. ---
    await tester.tap(find.bySemanticsLabel(l10nOf(tester).settings));
    await pumpFor(tester, const Duration(milliseconds: 500));
    await tester.tap(find.text(l10nOf(tester).settingLanguage).first);
    await pumpFor(tester, const Duration(milliseconds: 600));
    expect(find.byType(LanguageSheet), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(LanguageSheet),
        matching: find.text('English'),
      ),
    );
    await pumpFor(tester, const Duration(milliseconds: 600));
    expect(rendered(tester), const Locale('en'), reason: 'at once');
    expect(find.byType(SettingsPage), findsOneWidget);
    await settle(tester, Future<void>.value());
    expect(get<DatabaseService>().languageCode, 'en', reason: 'pinned');

    // --- Kill and relaunch on the same store. ---
    await shutDown();
    await bootOnTempDir();
    expect(get<DatabaseService>().languageCode, 'en');
    expect(get<LanguageCubit>().state.followsPhone, isFalse);
    expect(rendered(tester), const Locale('en'));

    // --- Each other catalog pinned survives a restart too. ---
    for (final language in otherLanguages) {
      final code = language == 'pt' ? 'pt_BR' : language;
      await settle(tester, get<LanguageCubit>().changeLanguage(code));
      await tester.pump();
      expect(rendered(tester).languageCode, language);
      await shutDown();
      await bootOnTempDir();
      expect(get<DatabaseService>().languageCode, code);
      expect(rendered(tester).languageCode, language, reason: code);
    }

    expect(tester.takeException(), isNull);
    await shutDown();
  });
}

/// Records every phone list the app root hands the cubit.
class _RecordingLanguageCubit extends LanguageCubit {
  _RecordingLanguageCubit(super.database, this.seen);

  final List<List<Locale>> seen;

  @override
  void deviceLocalesChanged(List<Locale> locales) {
    seen.add(locales);
    super.deviceLocalesChanged(locales);
  }
}
