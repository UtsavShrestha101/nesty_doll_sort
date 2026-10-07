import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// The Home coin pill takes the locale's compact count only when its full
/// count would be drawn below the readable scale (a huge balance on a 360 dp
/// phone, worst in Turkish's Baloo 2 digits, m7-5 item 28).
void main() {
  setUpAll(loadBundledFonts);

  Future<bool> needsCompact(
    WidgetTester tester, {
    required int coins,
    required double width,
    Locale locale = const Locale('en'),
  }) async {
    late bool out;
    await pumpUi(
      tester,
      Builder(
        builder: (context) {
          out = CoinPill.homeNeedsCompact(context, coins, width);
          return const SizedBox();
        },
      ),
      locale: locale,
    );
    return out;
  }

  testWidgets('an everyday balance keeps its full count', (tester) async {
    expect(await needsCompact(tester, coins: 1240, width: 140), isFalse);
    expect(
      await needsCompact(
        tester,
        coins: 1240,
        width: 140,
        locale: const Locale('tr'),
      ),
      isFalse,
    );
  });

  testWidgets('a huge balance in a narrow header turns compact, and only '
      'then', (tester) async {
    expect(
      await needsCompact(
        tester,
        coins: 1234567,
        width: 110,
        locale: const Locale('tr'),
      ),
      isTrue,
    );
    expect(await needsCompact(tester, coins: 1234567, width: 400), isFalse);
    expect(
      await needsCompact(tester, coins: 1234567, width: double.infinity),
      isFalse,
    );
  });

  testWidgets('the compact pill shows the locale\'s compact form', (
    tester,
  ) async {
    await pumpUi(
      tester,
      CoinPill(coins: 1234567, onAdd: () {}, compact: true),
      locale: const Locale('tr'),
    );
    expect(
      find.text(NumberFormat.compact(locale: 'tr').format(1234567)),
      findsOneWidget,
    );
    expect(find.text('1.234.567'), findsNothing);
  });
}
