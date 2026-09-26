import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/l10n/app_localizations.dart';

extension AppExceptionL10n on AppException {
  /// The user-facing text for this failure. Exhaustive over
  /// [AppExceptionKind], so adding a kind forces a decision here.
  /// [AppException.message] is for logs and is never shown.
  String localizedMessage(AppLocalizations l10n) => switch (kind) {
    AppExceptionKind.invalidCredentials => l10n.errorInvalidCredentials,
    AppExceptionKind.network => l10n.errorNetwork,
    AppExceptionKind.content ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => l10n.errorGeneric,
  };
}
