import 'package:flutter/widgets.dart' show IconData;
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/ui/icons/icon_uses.dart';
import 'package:nesty_game/features/splash/splash_copy.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

extension AppExceptionL10n on AppException {
  /// The player-facing one-line text for this failure. Exhaustive over
  /// [AppExceptionKind], so adding a kind forces a decision here.
  /// [AppException.message] is for logs and is never shown.
  String localizedMessage(AppLocalizations l10n) => switch (kind) {
    AppExceptionKind.storage ||
    AppExceptionKind.content ||
    AppExceptionKind.network ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => l10n.genericLoadFailed,
  };

  /// The error card's head (frames 12.10, 12.11): storage is "Your phone is
  /// nearly full"; every other kind is "The shelves didn't unpack".
  String errorTitle(AppLocalizations l10n) => switch (kind) {
    AppExceptionKind.storage => l10n.splashStorageTitle,
    AppExceptionKind.content ||
    AppExceptionKind.network ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => l10n.splashContentTitle,
  };

  /// The error card's body: storage says what to do (free some space, then
  /// try again) and how much room Nesty wants (`SplashCopy`); the rest says
  /// to try again or restart.
  String errorBody(AppLocalizations l10n) => switch (kind) {
    AppExceptionKind.storage => l10n.splashStorageBody(
      SplashCopy.storageMegabytes,
    ),
    AppExceptionKind.content ||
    AppExceptionKind.network ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => l10n.splashContentBody,
  };

  /// The error card's glyph: `sd_card_alert` for storage, `inventory_2` for
  /// content and everything else (frame 12.10, 12.11).
  IconData get errorIcon => switch (kind) {
    AppExceptionKind.storage => IconUses.storageError,
    AppExceptionKind.content ||
    AppExceptionKind.network ||
    AppExceptionKind.cancelled ||
    AppExceptionKind.unknown => IconUses.contentError,
  };
}
