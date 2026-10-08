import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily_month/daily_month.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/week_start.dart';

/// A month of played days (local habit 2; frames 14.2 to 14.2g, tokens
/// `habits.month`): the Daily's month as a 7-column grid. A day solved on
/// its own date is lit, one a freeze covered has its own blue mark (never
/// lit), and any other past day has no mark at all: no red, no X, no
/// lock, no word (D92). The grid isn't tappable yet.
///
/// TODO(later): the hint line ("Play any of the last 7 days"), the raised
/// past days and the previous-month chip come with local-habits stage 3's
/// past-day play (BACKLOG "Local habits"); the cell look below already
/// draws a `playable` day, but nothing passes a window yet.
class MonthCard extends StatelessWidget {
  const MonthCard({required this.status, super.key});

  final DailyStatus status;

  /// Under this screen height the 16:9 values apply (14.2b: 693 dp; 844
  /// uses the base ones).
  static const double shortBelow = 768;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final devices = View.of(context).platformDispatcher.locales;
    final weekStart = WeekStart.of(locale, devices);
    final month = DailyMonth.of(
      today: status.today,
      weekStart: weekStart,
      done: status.done,
      frozen: status.frozen,
    );
    final short = MediaQuery.sizeOf(context).height < shortBelow;
    final monthName = DateFormat.LLLL(locale).format(status.today.startOfDay);
    // The stand-alone month name with its first letter capitalised, by the
    // locale's own rule (Turkish i).
    final title = l10n.dailyMonthTitle(
      toBeginningOfSentenceCase(monthName, locale) ?? monthName,
    );
    const style = SurfaceStyle(
      gradient: HabitsMonthTokens.cardFace,
      shadows: HabitsMonthTokens.cardShadow,
    );
    final holds = _Holds.of(month);
    return NestySurface(
      style: style,
      radius: BorderRadius.circular(HabitsMonthTokens.cardRadius),
      padding: short
          ? HabitsMonthShortTokens.padding
          : HabitsMonthTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: title,
            height: short
                ? HabitsMonthShortTokens.headerHeight
                : HabitsMonthTokens.headerHeight,
            size: short ? HabitsMonthShortTokens.titleSize : null,
          ),
          SizedBox(
            height: short
                ? HabitsMonthShortTokens.weekdaysGap
                : HabitsMonthTokens.weekdaysGap,
          ),
          LayoutBuilder(
            builder: (context, box) {
              final pitch = math.min(
                HabitsMonthTokens.gridPitchMax,
                (box.maxWidth / 7).floorToDouble(),
              );
              final faceMax = short
                  ? HabitsMonthShortTokens.faceSize
                  : HabitsMonthTokens.gridFaceMax;
              final face = math.min(
                faceMax,
                pitch - HabitsMonthTokens.gridFaceInset,
              );
              final gap = short
                  ? HabitsMonthShortTokens.gridGap
                  : HabitsMonthTokens.gridGap;
              return Center(
                child: SizedBox(
                  width: pitch * 7,
                  child: Column(
                    children: [
                      _WeekdayHeader(
                        locale: locale,
                        weekStart: weekStart,
                        cell: pitch,
                        height: short
                            ? HabitsMonthShortTokens.weekdaysHeight
                            : HabitsMonthTokens.weekdaysHeight,
                      ),
                      SizedBox(height: gap),
                      for (final row in month.rows)
                        Row(
                          children: [
                            for (final c in row)
                              SizedBox(
                                width: pitch,
                                height:
                                    face + HabitsMonthTokens.gridRowOverFace,
                                child: c.isBlank
                                    ? null
                                    : _DayCell(
                                        cell: c,
                                        locale: locale,
                                        face: face,
                                        small:
                                            face <=
                                            HabitsMonthTokens.gridSmallFace,
                                        numberSize: short
                                            ? HabitsMonthShortTokens.numberSize
                                            : null,
                                      ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (holds.any) ...[
            SizedBox(
              height: short
                  ? HabitsMonthShortTokens.legendGap
                  : HabitsMonthTokens.legendGap,
            ),
            _Legend(holds: holds),
          ],
        ],
      ),
    );
  }
}

/// Which marks the month holds: the legend names only those (14.2: lit,
/// later, freeze).
class _Holds {
  const _Holds({required this.lit, required this.later, required this.freeze});

  factory _Holds.of(DailyMonth month) {
    var lit = false;
    var later = false;
    var freeze = false;
    for (final row in month.rows) {
      for (final c in row) {
        switch (c.state) {
          case DayState.solved:
            lit = true;
          case DayState.playedLater:
            later = true;
          case DayState.frozen:
            freeze = true;
          case DayState.notPlayed || DayState.future || null:
            break;
        }
      }
    }
    return _Holds(lit: lit, later: later, freeze: freeze);
  }

  final bool lit;
  final bool later;
  final bool freeze;

  bool get any => lit || later || freeze;
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.height, this.size});

  final String title;
  final double height;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final base = HabitsMonthTokens.headerTitle;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: HabitsMonthTokens.headerInset,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          // One line, scaled down rather than cut (textFit.habitsMonth).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: context.scriptStyle(
                  size == null ? base : base.copyWith(fontSize: size),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({
    required this.locale,
    required this.weekStart,
    required this.cell,
    required this.height,
  });

  final String locale;
  final int weekStart;
  final double cell;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = context.scriptStyle(HabitsMonthTokens.weekdaysFont);
    final symbols = DateFormat.d(locale).dateSymbols;
    // intl counts 0 = Sunday here; DateTime.sunday is 7.
    List<String> ordered(List<String> names) => [
      for (var i = 0; i < 7; i++) names[(weekStart + i) % 7],
    ];
    final short = ordered(symbols.STANDALONESHORTWEEKDAYS);
    final merged = DefaultTextStyle.of(context).style.merge(style);
    final scaler = MediaQuery.textScalerOf(context);
    // The short names when the widest fits its cell, else the narrow ones.
    var fits = true;
    for (final name in short) {
      final painter = TextPainter(
        text: TextSpan(text: name, style: merged),
        textDirection: Directionality.of(context),
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > cell - 2) fits = false;
      painter.dispose();
    }
    final names = fits ? short : ordered(symbols.STANDALONENARROWWEEKDAYS);
    return ExcludeSemantics(
      child: Row(
        children: [
          for (final name in names)
            SizedBox(
              width: cell,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.holds});

  final _Holds holds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final label = context.scriptStyle(HabitsMonthTokens.legendLabel);
    Widget item(SurfaceStyle swatch, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NestySurface(
          style: swatch,
          radius: BorderRadius.circular(HabitsMonthTokens.legendSwatchRadius),
          width: HabitsMonthTokens.legendSwatch,
          height: HabitsMonthTokens.legendSwatch,
        ),
        const SizedBox(width: 6),
        Text(text, style: label),
      ],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: HabitsMonthTokens.headerInset,
      ),
      child: Wrap(
        spacing: HabitsMonthTokens.legendItemGap,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (holds.lit)
            item(
              const SurfaceStyle(
                gradient: HabitsDayCellTokens.litFace,
                shadows: [],
              ),
              l10n.dailyMonthKeyLit,
            ),
          if (holds.later)
            item(
              const SurfaceStyle(
                color: HabitsDayCellTokens.laterFace,
                shadows: HabitsDayCellTokens.laterInner,
              ),
              l10n.dailyMonthKeyLater,
            ),
          if (holds.freeze)
            item(
              const SurfaceStyle(
                color: HabitsDayCellTokens.freezeFace,
                shadows: HabitsDayCellTokens.freezeInner,
              ),
              l10n.dailyMonthKeyFreeze,
            ),
        ],
      ),
    );
  }
}

/// One day: its face, number and (for a freeze) glyph by state, read as one
/// element. A day in the playable window (stage 3) adds its edge.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.cell,
    required this.locale,
    required this.face,
    required this.small,
    this.numberSize,
  });

  final MonthCell cell;
  final String locale;
  final double face;
  final bool small;
  final double? numberSize;

  @override
  Widget build(BuildContext context) {
    final date = cell.date!;
    final state = cell.state!;
    final today = cell.isToday;
    final playable = cell.playable;

    // The face, its shadows and the number's colour and weight.
    final (
      Color? color,
      Gradient? gradient,
      List<NestyShadow> shadows,
      Color? edge,
      Color numberColor,
      FontWeight weight,
    ) = switch (state) {
      DayState.solved when today => (
        null,
        HabitsDayCellTokens.todayLitFace,
        HabitsDayCellTokens.todayLitShadow,
        null,
        HabitsDayCellTokens.todayLitNumberColor,
        HabitsDayCellTokens.todayLitNumberWeight,
      ),
      DayState.solved => (
        null,
        HabitsDayCellTokens.litFace,
        HabitsDayCellTokens.litInner,
        HabitsDayCellTokens.litEdge,
        HabitsDayCellTokens.litNumberColor,
        HabitsDayCellTokens.litNumberWeight,
      ),
      DayState.playedLater => (
        HabitsDayCellTokens.laterFace,
        null,
        HabitsDayCellTokens.laterInner,
        HabitsDayCellTokens.laterEdge,
        HabitsDayCellTokens.laterNumberColor,
        HabitsDayCellTokens.laterNumberWeight,
      ),
      DayState.frozen => (
        HabitsDayCellTokens.freezeFace,
        null,
        HabitsDayCellTokens.freezeInner,
        HabitsDayCellTokens.freezeEdge,
        HabitsDayCellTokens.freezeNumberColor,
        HabitsDayCellTokens.freezeNumberWeight,
      ),
      _ when today => (
        HabitsDayCellTokens.todayFace,
        null,
        HabitsDayCellTokens.todayShadow,
        null,
        HabitsDayCellTokens.todayNumberColor,
        HabitsDayCellTokens.todayNumberWeight,
      ),
      DayState.notPlayed when playable => (
        HabitsDayCellTokens.openFace,
        null,
        HabitsDayCellTokens.openInner,
        HabitsDayCellTokens.openEdge,
        HabitsDayCellTokens.openNumberColor,
        HabitsDayCellTokens.openNumberWeight,
      ),
      DayState.future => (
        null,
        null,
        const <NestyShadow>[],
        null,
        HabitsDayCellTokens.futureNumberColor,
        HabitsDayCellTokens.futureNumberWeight,
      ),
      _ => (
        null,
        null,
        const <NestyShadow>[],
        null,
        HabitsDayCellTokens.blankNumberColor,
        HabitsDayCellTokens.blankNumberWeight,
      ),
    };
    final raised = playable && !today && edge != null;
    final hasFace = color != null || gradient != null;
    final frozen = state == DayState.frozen;
    final number = Text(
      '${date.day}',
      maxLines: 1,
      softWrap: false,
      style: context
          .scriptStyle(HabitsMonthTokens.gridNumber)
          .copyWith(
            fontSize:
                numberSize ??
                (small ? HabitsMonthTokens.gridNumberSizeSmall : null),
            color: numberColor,
            fontWeight: weight,
          ),
    );
    final Widget content = frozen
        ? Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: const Offset(
                      0,
                      -HabitsDayCellTokens.freezeNumberLift,
                    ),
                    child: number,
                  ),
                ),
              ),
              const Positioned(
                bottom: HabitsDayCellTokens.freezeGlyphBottom,
                child: Icon(
                  NestyIcons.acUnit,
                  size: HabitsDayCellTokens.freezeGlyphSize,
                  color: HabitsDayCellTokens.freezeGlyphColor,
                ),
              ),
            ],
          )
        : Center(child: number);

    final style = hasFace
        ? SurfaceStyle(
            color: color,
            gradient: gradient,
            shadows: [
              ...shadows,
              if (raised)
                NestyShadow(
                  color: edge,
                  dy: HabitsDayCellTokens.raisedEdgeDepth,
                ),
            ],
          )
        : null;
    final l10n = context.localizations;
    final key = switch (state) {
      DayState.solved when today => 'todaySolved',
      DayState.solved => 'solved',
      DayState.playedLater => 'later',
      DayState.frozen => 'frozen',
      DayState.future => 'future',
      _ when today => 'today',
      _ => 'other',
    };
    final text = l10n.dailyMonthDaySemantics(
      key,
      DateFormat.MMMMd(locale).format(date.startOfDay),
    );
    return Semantics(
      label: playable ? l10n.dailyMonthDayOpenSemantics(text) : text,
      excludeSemantics: true,
      child: Center(
        child: style == null
            ? SizedBox.square(dimension: face, child: content)
            : NestySurface(
                style: style,
                radius: BorderRadius.circular(
                  small
                      ? HabitsMonthTokens.gridRadiusSmall
                      : HabitsMonthTokens.gridRadius,
                ),
                width: face,
                height: face,
                child: content,
              ),
      ),
    );
  }
}
