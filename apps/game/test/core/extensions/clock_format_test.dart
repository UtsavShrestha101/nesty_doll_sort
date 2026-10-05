import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/extensions/clock_format_extension.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// Every time the game shows follows the phone's 24-hour switch as well as
/// the language (l10n.md §1.3).
void main() {
  Future<String> format(
    WidgetTester tester, {
    required bool alwaysUse24Hour,
  }) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: alwaysUse24Hour),
          child: child!,
        ),
        home: Builder(
          builder: (context) {
            text = context.formatClock(const TimeOfDay(hour: 19, minute: 5));
            return const SizedBox();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('English reads 7:05 PM until the phone is on 24 hours', (
    tester,
  ) async {
    expect(await format(tester, alwaysUse24Hour: false), '7:05 PM');
    expect(await format(tester, alwaysUse24Hour: true), '19:05');
  });
}
