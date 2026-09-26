import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// Spec §16 (menus fit at 1.3x text) and the M7 criterion "no layout
/// overflows": the four boosters must fit the narrowest supported phones.
void main() {
  const sizes = [Size(320, 568), Size(360, 640), Size(393, 852)];
  const textScales = [1.0, 1.3];

  for (final size in sizes) {
    for (final textScale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}x${size.height.toInt()} at ${textScale}x text',
        (tester) async {
          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: BoosterBar(),
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
        },
      );
    }
  }
}
