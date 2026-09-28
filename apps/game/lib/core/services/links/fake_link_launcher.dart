import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';

/// [LinkLauncher] for tests and the fake env: records what it was asked to
/// open rather than touching a platform channel.
@LazySingleton(as: LinkLauncher, env: [AppEnv.fake])
class FakeLinkLauncher implements LinkLauncher {
  /// URLs passed to [openUrl], in order.
  final List<String> openedUrls = [];

  /// Addresses passed to [email], in order.
  final List<String> emailedAddresses = [];

  @override
  Future<void> openUrl(String url) async => openedUrls.add(url);

  @override
  Future<void> email(String address) async => emailedAddresses.add(address);
}
