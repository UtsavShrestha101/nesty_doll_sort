import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/app_exception_extension.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('every kind maps to localized text, never the log message', () {
    for (final kind in AppExceptionKind.values) {
      final exception = AppException(kind, message: 'internal detail');
      final text = exception.localizedMessage(l10n);
      expect(text, l10n.genericLoadFailed, reason: kind.name);
      expect(text, isNot(contains('internal detail')), reason: kind.name);
    }
  });
}
