import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Coins and counters as text: grouped for the player's locale ("1,240",
/// "6,190"; NestyBoard HUD) in the given style.
///
/// TODO(M7): tabular figures (PROGRESS Q29; moved from M2, the approach
/// waits on the owner). The design asks for them, but Fredoka's digits are
/// proportional and it has no `tnum`, so a changing number still shifts.
/// This widget is the one place to apply the approach the owner picks (a
/// fixed-width digit layout, Nunito digits, or a patched Fredoka).
class NestyNumberText extends StatelessWidget {
  const NestyNumberText(
    this.value, {
    required this.style,
    this.prefix = '',
    super.key,
  });

  final int value;
  final TextStyle style;

  /// Text before the number, such as the win pill's "+".
  final String prefix;

  @override
  Widget build(BuildContext context) => Text(
    '$prefix${formatCount(context, value)}',
    style: style,
    maxLines: 1,
    softWrap: false,
  );

  static final Map<String, NumberFormat> _formats = {};

  /// [value] grouped for the current locale.
  static String formatCount(BuildContext context, int value) {
    final locale = Localizations.maybeLocaleOf(context)?.toString() ?? 'en';
    final format = _formats[locale] ??= NumberFormat.decimalPattern(
      Intl.canonicalizedLocale(locale),
    );
    return format.format(value);
  }
}
