import 'dart:ui' show Rect;

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/share/share_service.dart';

/// [ShareService] for the fake env and tests: records every text and origin
/// [shareText] was asked to share instead of opening a real share sheet, and
/// answers a settable [next] outcome (E3; docs/plans/m7-design.md P3.9).
@LazySingleton(as: ShareService, env: [AppEnv.fake])
class FakeShareService implements ShareService {
  /// Texts passed to [shareText], in order.
  final List<String> shared = [];

  /// [Rect]s passed alongside them, in order (mirrors [shared] by index).
  final List<Rect?> origins = [];

  /// What [shareText] answers next.
  ShareOutcome next = ShareOutcome.shared;

  @override
  Future<ShareOutcome> shareText(String text, {Rect? origin}) async {
    shared.add(text);
    origins.add(origin);
    return next;
  }
}
