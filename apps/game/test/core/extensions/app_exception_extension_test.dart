import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/app_exception_extension.dart';
import 'package:nesty_game/core/ui/icons/icon_uses.dart';
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

  test('the error card: storage names the phone\'s space and the size; '
      'every other kind is the shelves that didn\'t unpack (12.10, 12.11)', () {
    const storage = AppException(AppExceptionKind.storage, message: 'disk');
    expect(storage.errorTitle(l10n), 'Your phone is nearly full');
    expect(
      storage.errorBody(l10n),
      'Nesty needs about 60 MB to set up the shelves. Free some space, then '
      'try again.',
    );
    expect(storage.errorIcon, IconUses.storageError);
    for (final kind in AppExceptionKind.values) {
      if (kind == AppExceptionKind.storage) continue;
      final exception = AppException(kind, message: 'internal detail');
      expect(exception.errorTitle(l10n), 'The shelves didn’t unpack');
      expect(exception.errorBody(l10n), isNot(contains('internal detail')));
      expect(exception.errorIcon, IconUses.contentError, reason: kind.name);
    }
  });
}
