import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Real [LinkLauncher] over `url_launcher` (m3-design §10.2, D79).
@LazySingleton(as: LinkLauncher, env: [AppEnv.real])
class UrlLinkLauncher implements LinkLauncher {
  @override
  Future<void> openUrl(String url) => _launch(Uri.parse(url));

  @override
  Future<void> email(String address) =>
      _launch(Uri(scheme: 'mailto', path: address));

  Future<void> _launch(Uri uri) async {
    try {
      // Never `canLaunchUrl` first (m3-design §10.2): that would need
      // `<queries>`/`LSApplicationQueriesSchemes` entries this app doesn't
      // otherwise carry. A false return (nothing handled it) is ignored,
      // like any other failure (rule 3).
      await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } on Object catch (error, stack) {
      developer.log(
        'opening $uri failed',
        name: 'nesty.links',
        error: error,
        stackTrace: stack,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.links] open failed: $error');
    }
  }
}
