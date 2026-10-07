import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Coins and counters as text: grouped for the player's locale ("1,240",
/// "6,190"; NestyBoard HUD) in the given style.
///
/// TODO(M8): tabular figures (PROGRESS Q29; moved from M2, the approach
/// waits on the owner). The design asks for them, but Fredoka's digits are
/// proportional and it has no `tnum`, so a changing number still shifts.
/// This widget is the one place to apply the approach the owner picks (a
/// fixed-width digit layout, Nunito digits, or a patched Fredoka).
class NestyNumberText extends StatelessWidget {
  const NestyNumberText(
    this.value, {
    required this.style,
    this.prefix = '',
    this.compact = false,
    super.key,
  });

  final int value;
  final TextStyle style;

  /// The locale's compact form ("1.2M", "1,2 Mn", "123万") instead of the
  /// grouped number, for a box that can't hold the full one readably.
  final bool compact;

  /// Text before the number, such as the win pill's "+".
  final String prefix;

  @override
  Widget build(BuildContext context) => Text(
    '$prefix${compact ? formatCompact(context, value) : formatCount(context, value)}',
    style: style,
    maxLines: 1,
    softWrap: false,
  );

  static final Map<String, NumberFormat> _formats = {};
  static final Map<String, NumberFormat> _compactFormats = {};

  /// [value] in the current locale's compact form (intl
  /// `NumberFormat.compact`; the language alone where intl has no data for
  /// the region).
  static String formatCompact(BuildContext context, int value) {
    final tag = Intl.canonicalizedLocale(
      Localizations.maybeLocaleOf(context)?.toString() ?? 'en',
    );
    final locale = NumberFormat.localeExists(tag) ? tag : tag.split('_').first;
    final format = _compactFormats[locale] ??= NumberFormat.compact(
      locale: NumberFormat.localeExists(locale) ? locale : 'en',
    );
    return format.format(value);
  }

  /// [value] grouped for the current locale.
  static String formatCount(BuildContext context, int value) {
    final locale = Localizations.maybeLocaleOf(context)?.toString() ?? 'en';
    final format = _formats[locale] ??= NumberFormat.decimalPattern(
      Intl.canonicalizedLocale(locale),
    );
    return format.format(value);
  }
}
