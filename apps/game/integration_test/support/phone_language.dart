import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';

/// Pins the phone's languages to English for one on-device check. The app
/// follows the phone until a language is picked (5B), and these checks look
/// for English copy, so a simulator left in another language must not fail
/// them. Call it first in the test body, before `app.main()`. Only
/// `locales_test` (which picks languages itself) and `daily_fingerprint_test`
/// (which reads no copy) don't.
void pinEnglishPhone(WidgetTester tester) {
  tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}
