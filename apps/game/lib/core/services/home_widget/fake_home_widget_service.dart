import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';

/// The fake [HomeWidgetService] (the fake env and tests): it stores nothing
/// on the phone, remembers what was published and answers [next].
@LazySingleton(as: HomeWidgetService, env: [AppEnv.fake])
class FakeHomeWidgetService implements HomeWidgetService {
  /// What [publish] answers (true: the platform "stored" it).
  bool next = true;

  /// The JSON of every [publish], oldest first. Cleared by [clear].
  final List<String> published = [];

  /// The JSON of the last [publish], or null before any.
  String? get lastJson => published.isEmpty ? null : published.last;

  @override
  Future<bool> publish(HomeWidgetSnapshot snapshot) async {
    published.add(snapshot.encode());
    return next;
  }

  @override
  Future<String?> readBack() async => lastJson;

  @override
  Future<Map<String, Object?>?> storeInfo() async => const {
    'prefs': 'fake',
    'providers': 0,
  };

  /// Forgets the published history.
  void clear() => published.clear();
}
