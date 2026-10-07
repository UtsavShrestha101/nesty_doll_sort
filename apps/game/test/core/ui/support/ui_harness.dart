import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../../l10n/support/test_locale.dart';

export '../../../l10n/support/test_locale.dart'
    show testL10n, testLocale, testLocaleCode;

/// Loads the bundled Fredoka, Nunito and NestySymbols files, so text is laid
/// out with the real glyph widths. flutter_test otherwise draws every glyph
/// one em wide (FlutterTest font), which makes overflow checks meaningless.
Future<void> loadBundledFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<Object?>;
  for (final entry in manifest.cast<Map<String, Object?>>()) {
    final family = entry['family']! as String;
    if (family.startsWith('packages/') || family == 'MaterialIcons') continue;
    final loader = FontLoader(family);
    for (final font
        in (entry['fonts']! as List<Object?>).cast<Map<String, Object?>>()) {
      loader.addFont(rootBundle.load(font['asset']! as String));
    }
    await loader.load();
  }
}

/// Counts activations instead of playing sounds and haptics.
final class RecordingFeedback implements TactileFeedback {
  int activations = 0;

  @override
  void activate() => activations++;
}

/// Pumps [child] in the app theme and the run's localizations
/// ([testLocale], English by default, or [locale]; build/m7-p5/p5/l10n.md
/// §6.2) on a [width]-wide phone at [textScale], optionally with reduced
/// motion.
Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double height = 844,
  double textScale = 1,
  bool reduceMotion = false,
  TactileFeedback? feedback,
  Locale? locale,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget body = child;
  if (feedback != null) {
    body = TactileFeedbackScope(feedback: feedback, child: body);
  }
  await tester.pumpWidget(
    MaterialApp(
      // The app's own locale wiring (app.dart): the script's theme, and
      // its size factor and display face under the run's text scale.
      theme: AppTheme.forLocale(checkedLocale(locale)),
      debugShowCheckedModeBanner: false,
      locale: checkedLocale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: LocaleScriptScope(child: child!),
      ),
      home: Scaffold(body: body),
    ),
  );
}
