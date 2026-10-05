import 'dart:async';
import 'dart:ui' show CheckedState, LocaleStringAttribute;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';

import '../../app/localization_cubit/support/launch_catalogs.dart';
import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// Frame 8.2's language sheet (NestyMenus `LANGS`; FIDELITY-9): the
/// autonym is never ellipsized (the trailing English name and "Coming
/// soon" give way instead), pt_BR's English name is "Portuguese", and
/// "Done" is an orange text action on the right of a left-aligned title.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> openSheet(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    Locale? locale,
  }) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: GestureDetector(
              onTap: () => LanguageSheet.show(
                context,
                selectedCode: 'en',
                onSelect: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      textScale: textScale,
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsOneWidget);
  }

  testWidgets('every row is a radio of one group: the chosen one checked, '
      'each a 56 dp target (review R16, R21; frame 8.2)', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    final english = tester.getSemantics(find.bySemanticsLabel('English'));
    final englishData = english.getSemanticsData();
    expect(englishData.flagsCollection.isChecked, CheckedState.isTrue);
    expect(englishData.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(englishData.flagsCollection.isButton, isFalse);
    expect(english.rect.height, greaterThanOrEqualTo(56));
    final spanish = tester.getSemantics(
      find.bySemanticsLabel(RegExp('^Español, ')),
    );
    expect(
      spanish.getSemanticsData().flagsCollection.isChecked,
      CheckedState.isFalse,
    );
    expect(spanish.rect.height, greaterThanOrEqualTo(56));
    handle.dispose();
  });

  testWidgets('pt_BR reads "Português (Brasil)" · "Portuguese" (the '
      'frame’s English name)', (tester) async {
    await openSheet(tester);
    expect(find.text('Português (Brasil)'), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Portuguese (Brazil)'), findsNothing);
  });

  testWidgets('the title row: "Language" left-aligned, "Done" an orange '
      'text action on its right; no bottom button', (tester) async {
    await openSheet(tester);
    final sheet = find.byType(LanguageSheet);
    final title = find.descendant(of: sheet, matching: find.text('Language'));
    final done = find.descendant(of: sheet, matching: find.text('Done'));
    expect(tester.getCenter(done).dy, closeTo(tester.getCenter(title).dy, 1));
    expect(tester.getCenter(done).dx, greaterThan(tester.getCenter(title).dx));
    expect(
      tester.getTopLeft(title).dx,
      lessThan(tester.getSize(sheet).width / 4),
    );
    expect(tester.widget<Text>(done).style?.color, AppColorTokens.primaryEdge);
    expect(tester.widget<Text>(title).style?.fontSize, 26);
    expect(
      find.descendant(of: sheet, matching: find.byType(TactileButton)),
      findsNothing,
    );
    // A real tap target (spec §16).
    final handle = tester.ensureSemantics();
    expect(tester.getSemantics(done).rect.height, greaterThanOrEqualTo(48));
    handle.dispose();

    await tester.tap(done);
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsNothing);
  });

  for (final size in screenSizes) {
    testWidgets('no autonym is ellipsized at 1.3× text on a '
        '${size.width.toInt()}-wide phone', (tester) async {
      await openSheet(tester, size: size, textScale: 1.3);
      for (final language in launchLanguages) {
        final text = tester.widget<Text>(find.text(language.autonym));
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(text.maxLines, isNull);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(language.autonym),
        );
        // Laid out whole: its one-line width fits, so it never wrapped
        // either.
        expect(
          paragraph.size.width,
          greaterThanOrEqualTo(
            paragraph.getMaxIntrinsicWidth(double.infinity) - 0.5,
          ),
          reason: language.autonym,
        );
      }
      expectNoLayoutErrors(tester);
    });
  }

  testWidgets('with room, the English name shares the autonym’s line', (
    tester,
  ) async {
    await openSheet(tester);
    expect(
      tester.getCenter(find.text('Portuguese')).dy,
      closeTo(tester.getCenter(find.text('Português (Brasil)')).dy, 2),
    );
  });

  testWidgets('without room (360 wide, 1.3×), the trailing text moves under '
      'the autonym instead of cutting it', (tester) async {
    await openSheet(tester, size: const Size(360, 640), textScale: 1.3);
    final autonym = find.text('Português (Brasil)');
    final name = find.text('Portuguese');
    expect(
      tester.getTopLeft(name).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(autonym).dy - 1),
    );
  });

  testWidgets('screen readers hear the autonym, then its name', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    expect(find.bySemanticsLabel('Español, Spanish'), findsOneWidget);
    expect(find.bySemanticsLabel('English'), findsWidgets);
    expect(find.text('Coming soon'), findsNothing);
    handle.dispose();
  });

  testWidgets('a row whose name in the app\'s language is its autonym shows '
      'it once ("Deutsch" in German, 日本語 in Japanese), to the eye and to a '
      'screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester, locale: const Locale('de'));
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.bySemanticsLabel('Deutsch'), findsOneWidget);
    expect(find.bySemanticsLabel('Español, Spanisch'), findsOneWidget);
    handle.dispose();
    await openSheet(tester, locale: const Locale('ja'));
    expect(find.text('日本語'), findsOneWidget);
  });

  testWidgets('the autonym is announced in its own language', (tester) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    final label = tester
        .getSemantics(find.bySemanticsLabel(RegExp('^Español, ')))
        .getSemanticsData()
        .attributedLabel;
    final spans = label.attributes.whereType<LocaleStringAttribute>();
    expect(spans, hasLength(1));
    expect(spans.single.locale, const Locale('es'));
    expect(spans.single.range, const TextRange(start: 0, end: 7));
    handle.dispose();
  });

  testWidgets('rows are 56 dp, with the English name on the right of every '
      'row but the English one', (tester) async {
    await openSheet(tester);
    final english = find.text('English');
    expect(english, findsOneWidget, reason: 'the autonym, no second name');
    final row = find.ancestor(
      of: find.text('Español'),
      matching: find.byType(TactileSurface),
    );
    expect(tester.getSize(row.first).height, greaterThanOrEqualTo(56));
    expect(
      tester.getCenter(find.text('Spanish')).dx,
      greaterThan(tester.getCenter(find.text('Español')).dx),
    );
    final name = tester.widget<Text>(find.text('Spanish'));
    expect(name.style?.fontSize, 13);
    expect(name.style?.color, AppColorTokens.textMuted);
  });

  testWidgets('the autonyms use Nunito 700 16 (Japanese 15), whose fallback '
      'draws Devanagari and Japanese', (tester) async {
    await openSheet(tester);
    final hindi = tester.widget<Text>(find.text('हिन्दी')).style!;
    expect(hindi.fontFamily, 'Nunito');
    expect(hindi.fontWeight, FontWeight.w700);
    expect(hindi.fontSize, 16);
    expect(hindi.fontFamilyFallback, AppFontTokens.bodyFallback);
    final japanese = tester.widget<Text>(find.text('日本語')).style!;
    expect(japanese.fontSize, closeTo(15, 0.05));
  });

  testWidgets('a row turns on when its catalog exists, and a tap applies it '
      'at once: the sheet stays open and the radio moves', (tester) async {
    final database = FakeDatabaseService();
    addTearDown(database.close);
    final nine = AppLocaleResolver(nineLaunchCatalogs);
    final cubit = LanguageCubit(
      database,
      resolver: nine,
      deviceLocales: const [Locale('en')],
    );
    addTearDown(cubit.close);
    final picked = <String>[];
    await pumpScreen(
      tester,
      BlocProvider<LanguageCubit>.value(
        value: cubit,
        child: Scaffold(
          body: LanguageSheet(
            selectedCode: 'en',
            resolver: nine,
            onSelect: (code) {
              picked.add(code);
              unawaited(cubit.changeLanguage(code));
            },
          ),
        ),
      ),
    );
    final handle = tester.ensureSemantics();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(picked, ['de']);
    expect(cubit.state.currentLanguageCode, 'de');
    expect(find.byType(LanguageSheet), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Deutsch'))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );
    expect(
      tester
          // Unselected, still once: its name is its autonym.
          .getSemantics(find.bySemanticsLabel('English'))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isFalse,
    );
    handle.dispose();
  });

  testWidgets('a row with no catalog does nothing when tapped', (tester) async {
    final picked = <String>[];
    await pumpScreen(
      tester,
      Scaffold(
        body: LanguageSheet(
          selectedCode: 'en',
          resolver: AppLocaleResolver(const [Locale('en')]),
          onSelect: picked.add,
        ),
      ),
    );
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(picked, isEmpty);
  });

  testWidgets('the sheet stops 72 dp under the safe top and scrolls under '
      'its title, with a fade while more rows are below', (tester) async {
    await openSheet(tester, size: const Size(390, 520));
    final sheet = tester.getRect(find.byType(NestySheet));
    final safeTop = safeAreaOf(const Size(390, 520)).top;
    expect(sheet.top, greaterThanOrEqualTo(safeTop + 72 - 0.5));
    final scroll = find.descendant(
      of: find.byType(LanguageSheet),
      matching: find.byType(SingleChildScrollView),
    );
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).last)
          .position
          .extentAfter,
      greaterThan(0),
    );
    DecoratedBox fadeBox() => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(NestySheet),
            matching: find.byType(DecoratedBox),
          ),
        )
        .firstWhere(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient is LinearGradient &&
              ((box.decoration as BoxDecoration).gradient! as LinearGradient)
                      .colors
                      .last ==
                  AppColorTokens.surfaceSunk,
        );
    expect(fadeBox, returnsNormally);
    await tester.drag(scroll, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(fadeBox, throwsStateError);
  });

  testWidgets('a short list shows no fade', (tester) async {
    await openSheet(tester, size: const Size(390, 1400));
    expect(
      find.descendant(
        of: find.byType(NestySheet),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient is LinearGradient &&
              ((w.decoration as BoxDecoration).gradient! as LinearGradient)
                      .colors
                      .last ==
                  AppColorTokens.surfaceSunk,
        ),
      ),
      findsNothing,
    );
  });
}
