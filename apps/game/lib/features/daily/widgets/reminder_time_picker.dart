import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/common_imports.dart';

/// The phone's own time picker for the reminder (frames 10.2b, 10.2c, 10.2e;
/// FU 3.7): the native-style wheel in a bottom sheet on iOS, the Material
/// dial elsewhere. Both are titled "Reminder time" (`reminderPickerTitle`).
/// Returns null when the player cancels.
Future<TimeOfDay?> showReminderTimePicker(
  BuildContext context, {
  required TimeOfDay initial,
  @visibleForTesting TargetPlatform? platform,
}) {
  final title = context.localizations.reminderPickerTitle;
  if ((platform ?? defaultTargetPlatform) == TargetPlatform.iOS) {
    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      // Frame 10.2b's scrim, `rgba(0,0,0,.25)`.
      barrierColor: const Color(0x40000000),
      builder: (_) => ReminderWheelSheet(initial: initial, title: title),
    );
  }
  return showTimePicker(
    context: context,
    initialTime: initial,
    helpText: title,
  );
}

/// Frame 10.2b's sheet: `#F2F2F7`, 14 dp top radius, padding 14/16/40, a
/// Cancel / title / Done row, then a 180 dp white wheel with radius 12.
class ReminderWheelSheet extends StatefulWidget {
  const ReminderWheelSheet({
    required this.initial,
    required this.title,
    super.key,
  });

  final TimeOfDay initial;
  final String title;

  @override
  State<ReminderWheelSheet> createState() => _ReminderWheelSheetState();
}

class _ReminderWheelSheetState extends State<ReminderWheelSheet> {
  late TimeOfDay _picked = widget.initial;

  static const _blue = Color(0xFF007AFF);
  static const _ink = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    final cancel = MaterialLocalizations.of(context).cancelButtonLabel;
    final done = context.localizations.languageSheetDone;
    const row = TextStyle(
      fontSize: 17,
      height: 1,
      color: _blue,
      decoration: TextDecoration.none,
    );
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: widget.title,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _SheetAction(
                      label: cancel,
                      style: row,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: row.copyWith(
                            color: _ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _SheetAction(
                      label: done,
                      style: row.copyWith(fontWeight: FontWeight.w600),
                      onTap: () => Navigator.of(context).pop(_picked),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: const Color(0xFFFFFFFF),
                    child: SizedBox(
                      height: 180,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: MediaQuery.alwaysUse24HourFormatOf(
                          context,
                        ),
                        initialDateTime: DateTime(
                          2000,
                          1,
                          1,
                          widget.initial.hour,
                          widget.initial.minute,
                        ),
                        onDateTimeChanged: (t) =>
                            _picked = TimeOfDay(hour: t.hour, minute: t.minute),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cancel or Done: a 48 dp hit box around the 17 dp label.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    onTap: onTap,
    child: ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(label, style: style),
          ),
        ),
      ),
    ),
  );
}
