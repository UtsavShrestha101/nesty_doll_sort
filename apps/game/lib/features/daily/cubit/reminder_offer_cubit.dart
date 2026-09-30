import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';

part 'reminder_offer_cubit.freezed.dart';
part 'reminder_offer_state.dart';

/// The one-time reminder offer on the Daily screen (E4; spec-prop §7.9
/// "offered once, after the player's first solved daily, and off until
/// the player accepts"; docs/plans/m7-design.md P3.10).
///
/// [load] shows [ReminderOfferStep.ask] when the daily is unlocked, today
/// is solved, the reminder is neither offered nor on, and the settings are
/// kept (never over the Hive fallback, [SessionOnlyDatabase]); at that first
/// appearance it stores `offered` with the solve's hour (Q81), so it never
/// shows twice. Yes asks the OS through `DailyReminder.enable` (the only
/// place the permission prompt can come from); No thanks just hides it,
/// storing nothing further (the first appearance already wrote `offered`).
///
/// A denied Yes leaves the reminder on and blocked (D190), so the denied
/// step (frame 10.2d) offers "Open phone settings" ([openPhoneSettings]);
/// when the player comes back with notifications allowed (the app's resume
/// refresh reaches [DailyReminder.changes]), the step becomes
/// [ReminderOfferStep.enabled] and the page shows the 10.2c toast.
@injectable
class ReminderOfferCubit extends BaseAsyncCubit<ReminderOfferState> {
  /// [reminder] enables it, [settings] holds `offered`, [daily] says
  /// whether today is solved (and its solve's minute), [clock] is the
  /// hour when the solve has none, and [systemSettings] opens the phone's
  /// notification page from the denied step.
  ReminderOfferCubit(
    this._reminder,
    this._settings,
    this._daily,
    this._clock, {
    SystemSettingsService? systemSettings,
  }) : _systemSettings = systemSettings;

  final DailyReminder _reminder;
  final DatabaseService _settings;
  final DailyService _daily;
  final AppClock _clock;
  final SystemSettingsService? _systemSettings;
  StreamSubscription<ReminderStatus>? _changes;

  /// Shows [ReminderOfferStep.ask] exactly at its first appearance (see the
  /// class doc); every later call this save sees [ReminderOfferStep.hidden]
  /// instead, because that appearance already wrote `offered`.
  Future<void> load() async {
    await runGuarded(() async {
      final reminder = _settings.reminder;
      final status = _daily.status;
      final shouldAsk =
          // Over the session fallback (Hive didn't open) `offered` reads its
          // default and can't be kept, so "offered once" would break (M7
          // review R30).
          _settings is! SessionOnlyDatabase &&
          _daily.isUnlocked &&
          status.solvedToday &&
          !reminder.offered &&
          !reminder.on;
      if (!shouldAsk) return const ReminderOfferState();
      final solveMinute = status.solve?.minuteOfDay;
      final hour = solveMinute != null ? solveMinute ~/ 60 : _clock.now().hour;
      // "Offered once" (Q138): written now, at the offer's first
      // appearance, whether the player answers it or not.
      await _settings.setReminder(
        reminder.copyWith(offered: true, hour: hour, minute: 0),
      );
      return ReminderOfferState(
        step: ReminderOfferStep.ask,
        hour: hour,
        minute: 0,
      );
    });
  }

  /// The time chip's new time (from `showTimePicker`): kept only in this
  /// cubit's own state until [accept] persists it.
  void setTime({required int hour, required int minute}) {
    final current = state.data;
    if (current == null || current.step != ReminderOfferStep.ask) return;
    emit(
      AsyncValue.data(
        data: current.copyWith(hour: hour, minute: minute),
      ),
    );
  }

  /// "Yes, remind me": [ReminderOfferStep.asking] while `DailyReminder
  /// .enable` asks the OS, then [ReminderOfferStep.enabled] or
  /// [ReminderOfferStep.denied].
  Future<void> accept() async {
    final current = state.data;
    if (current == null || current.step != ReminderOfferStep.ask) return;
    emit(
      AsyncValue.data(data: current.copyWith(step: ReminderOfferStep.asking)),
    );
    await runGuarded(() async {
      final result = await _reminder.enable(
        hour: current.hour,
        minute: current.minute,
      );
      return current.copyWith(
        step: result == ReminderEnableResult.enabled
            ? ReminderOfferStep.enabled
            : ReminderOfferStep.denied,
      );
    });
  }

  /// The denied step's primary: opens the phone's notification settings
  /// (frame 10.2d). Follows [DailyReminder.changes] from now on, so coming
  /// back with notifications allowed ends in [ReminderOfferStep.enabled].
  Future<void> openPhoneSettings() async {
    final current = state.data;
    if (current == null || current.step != ReminderOfferStep.denied) return;
    _changes ??= _reminder.changes.listen(_onReminderChanged);
    await _systemSettings?.openNotificationSettings();
  }

  void _onReminderChanged(ReminderStatus status) {
    if (isClosed) return;
    final current = state.data;
    if (current == null || current.step != ReminderOfferStep.denied) return;
    if (status.settings.on &&
        status.permission == NotificationPermission.granted) {
      emit(
        AsyncValue.data(
          data: current.copyWith(step: ReminderOfferStep.enabled),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_changes?.cancel());
    return super.close();
  }

  /// "No thanks": hidden. The first appearance already wrote `offered`, so
  /// nothing more is stored.
  Future<void> decline() async {
    final current = state.data;
    if (current == null) return;
    emit(
      AsyncValue.data(data: current.copyWith(step: ReminderOfferStep.hidden)),
    );
  }

  /// The close button of the enabled or denied step: hidden.
  void dismiss() {
    final current = state.data;
    if (current == null) return;
    emit(
      AsyncValue.data(data: current.copyWith(step: ReminderOfferStep.hidden)),
    );
  }
}
