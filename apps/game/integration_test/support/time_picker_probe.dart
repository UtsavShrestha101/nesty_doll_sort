import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/daily/widgets/reminder_time_picker.dart';

import 'board_probe.dart';

/// The reminder's time picker as the platform shows it
/// (`showReminderTimePicker`): the Cupertino wheel sheet on iOS, the
/// Material dial elsewhere.
bool get _wheel => defaultTargetPlatform == TargetPlatform.iOS;

extension TimePickerProbe on WidgetTester {
  Finder get _picker =>
      find.byType(_wheel ? ReminderWheelSheet : TimePickerDialog);

  Future<void> waitForTimePicker(String reason) async {
    await pumpUntil(() => _picker.evaluate().isNotEmpty, reason: reason);
    await pumpFor(const Duration(milliseconds: 600));
  }

  Future<void> cancelTimePicker() async {
    await tap(find.descendant(of: _picker, matching: find.text('Cancel')));
    await pumpUntil(
      () => _picker.evaluate().isEmpty,
      reason: 'the time picker closed',
    );
  }

  /// Confirms a changed time: the wheel is dragged one step first, since
  /// the dial's OK keeps the offered time.
  Future<void> confirmTimePicker() async {
    if (_wheel) {
      await drag(find.byType(CupertinoDatePicker), const Offset(0, -34));
      await pumpFor(const Duration(milliseconds: 600));
    }
    await tap(
      find.descendant(of: _picker, matching: find.text(_wheel ? 'Done' : 'OK')),
    );
  }
}
