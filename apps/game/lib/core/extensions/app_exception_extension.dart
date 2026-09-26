import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

extension AppExceptionL10n on AppException {
  /// The player-facing text for this failure. Exhaustive over
  /// [AppExceptionKind], so adding a kind forces a decision here.
  /// [AppException.message] is for logs and is never shown.
  ///
  /// TODO(M2): split `storage` and `content` (bundled levels failed to load)
  /// into their own keys once those screens exist.
  String localizedMessage(AppLocalizations l10n) => switch (kind) {
    AppExceptionKind.storage ||
    AppExceptionKind.content ||
    AppExceptionKind.network ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => l10n.genericLoadFailed,
  };
}
