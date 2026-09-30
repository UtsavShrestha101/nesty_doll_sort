import 'dart:developer' as developer;
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:share_plus/share_plus.dart';

/// Real [ShareService] over `share_plus` 13.x's current API (E3;
/// docs/plans/m7-design.md P3.9): `SharePlus.instance.share(ShareParams(...))`,
/// not the deprecated `Share.share(text)` (research-packages.md).
///
/// [origin] becomes [ShareParams.sharePositionOrigin], which only an iPad or
/// Mac popover reads; every other platform ignores it. Any failure —
/// including one `SharePlatform` itself throws — is swallowed and logged
/// under `nesty.share`, never surfaced to the player (rule 3).
@LazySingleton(as: ShareService, env: [AppEnv.real])
class SharePlusShareService implements ShareService {
  @override
  Future<ShareOutcome> shareText(String text, {Rect? origin}) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: origin),
      );
      return outcomeOf(result.status);
    } on Object catch (error, stack) {
      developer.log(
        'sharing the daily result failed',
        name: 'nesty.share',
        error: error,
        stackTrace: stack,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.share] share failed: $error');
      return ShareOutcome.unavailable;
    }
  }
}

/// The mapping share_plus's `ShareResultStatus` → [ShareOutcome], pulled out
/// so a plain test can pin it without a platform double (`share_plus`
/// doesn't export `SharePlatform`, only these result types).
@visibleForTesting
ShareOutcome outcomeOf(ShareResultStatus status) => switch (status) {
  ShareResultStatus.success => ShareOutcome.shared,
  ShareResultStatus.dismissed => ShareOutcome.dismissed,
  ShareResultStatus.unavailable => ShareOutcome.unavailable,
};
