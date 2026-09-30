import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';

/// [NotificationService] for the fake env and tests (m7-design P3.10): no
/// platform channel. It answers [permissionAnswer] and records what the
/// reminder asked for.
@LazySingleton(as: NotificationService, env: [AppEnv.fake])
class FakeNotificationService implements NotificationService {
  /// What [permission] reads and what [requestPermission] answers. A test
  /// sets it before the call (denied: the player said no, or revoked it).
  NotificationPermission permissionAnswer = NotificationPermission.granted;

  /// [scheduleDaily]'s result; a test sets false to simulate a failure.
  bool scheduleSucceeds = true;

  /// How many times [initialize] ran.
  int initializeCount = 0;

  /// How many times the OS prompt was asked for.
  int requestCount = 0;

  /// The plan pending with the "OS", or null.
  ReminderPlan? scheduled;

  /// Every plan [scheduleDaily] was given, in order.
  final List<ReminderPlan> scheduleCalls = [];

  /// How many times [cancelDaily] ran.
  int cancelCalls = 0;

  @override
  Future<void> initialize() async => initializeCount++;

  @override
  Future<NotificationPermission> permission() async => permissionAnswer;

  @override
  Future<NotificationPermission> requestPermission() async {
    requestCount++;
    return permissionAnswer;
  }

  @override
  Future<bool> scheduleDaily(ReminderPlan plan) async {
    scheduleCalls.add(plan);
    if (!scheduleSucceeds) return false;
    scheduled = plan;
    return true;
  }

  @override
  Future<void> cancelDaily() async {
    cancelCalls++;
    scheduled = null;
  }

  @override
  Future<bool> hasPendingDaily() async => scheduled != null;
}
