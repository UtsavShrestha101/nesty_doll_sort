import 'package:flutter/material.dart';

/// A time of day as the player's phone writes it: the locale's pattern, and
/// 24-hour when the phone's 24-hour switch is on (l10n.md §1.3).
/// `MaterialLocalizations.formatTimeOfDay` alone ignores that switch.
extension ClockFormat on BuildContext {
  String formatClock(TimeOfDay time) =>
      MaterialLocalizations.of(this).formatTimeOfDay(
        time,
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(this),
      );
}
