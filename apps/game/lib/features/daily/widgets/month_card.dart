import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily_month/daily_month.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/week_start.dart';

/// A month of played days (local habit 2; frames 14.2 to 14.2g, tokens
/// `habits.month`) and the picker of the last days (local habit 3; frames
/// 14.3a to 14.3e): the Daily's month as a 7-column grid. A day solved on its
/// own date is lit, one a freeze covered has its own blue mark (never lit),
/// and any other past day has no mark at all: no red, no X, no lock, no word
/// (D92).
///
/// The days of the playable window (`DailyStatus.window`) are raised, 48 dp
/// buttons: a tap calls [onSelect]. Older days are flat and inert. The
/// ‹ chip shows only while the window reaches into the previous month, and
/// pages back exactly one month ([onShowMonth] -1) and forward again (0).
class MonthCard extends StatelessWidget {
  const MonthCard({
    required this.status,
    this.selected,
    this.monthOffset = 0,
    this.onSelect,
    this.onShowMonth,
    this.onShowToday,
    super.key,
  });

  final DailyStatus status;

  /// The day whose card is open: it sinks and wears the brown ring.
  final LocalDate? selected;

  /// 0 shows today's month, -1 the one before.
  final int monthOffset;

  /// A window day was tapped; null makes the grid inert.
  final ValueChanged<LocalDate>? onSelect;

  /// The chip was tapped: -1 to the previous month, 0 back.
  final ValueChanged<int>? onShowMonth;

  /// Today's cell was tapped: `habits.month.cell.today.tap` scrolls up to
  /// today's card. Wired only while the window's days are open, when every
  /// row is a 48 dp target.
  final VoidCallback? onShowToday;

  /// Under this screen height the 16:9 values apply (14.2b: 693 dp; 844
  /// uses the base ones).
  static const double shortBelow = 768;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final devices = View.of(context).platformDispatcher.locales;
    final weekStart = WeekStart.of(locale, devices);
    final reaches = DailyMonth.reachesPreviousMonth(
      status.today,
      status.window,
    );
    final paged = reaches && monthOffset == -1;
    final shown = paged
        ? DailyMonth.previousMonthOf(status.today)
        : status.today;
    final month = DailyMonth.of(
      today: status.today,
      shownMonth: shown,
      weekStart: weekStart,
      done: status.done,
      frozen: status.frozen,
      played: status.played,
      window: onSelect == null ? const [] : status.window,
    );
    final short = MediaQuery.sizeOf(context).height < shortBelow;
    final monthName = DateFormat.LLLL(locale).format(shown.startOfDay);
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
            chip: !reaches || onShowMonth == null
                ? null
                : _MonthChip(
                    month: _monthName(
                      locale,
                      paged
                          ? status.today
                          : DailyMonth.previousMonthOf(status.today),
                    ),
                    next: paged,
                    onTap: () => onShowMonth!(paged ? 0 : -1),
                  ),
          ),
          if (month.hasPlayable) ...[
            SizedBox(
              height: short
                  ? HabitsMonthShortTokens.hintGap
                  : HabitsMonthTokens.hintGap,
            ),
            const _Hint(),
          ],
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
                                // A window day is a 48 dp target.
                                height: math.max(
                                  face + HabitsMonthTokens.gridRowOverFace,
                                  month.hasPlayable ? 48 : 0,
                                ),
                                child: c.isBlank
                                    ? null
                                    : _DayButton(
                                        cell: c,
                                        locale: locale,
                                        face: face,
                                        small:
                                            face <=
                                            HabitsMonthTokens.gridSmallFace,
                                        numberSize: short
                                            ? HabitsMonthShortTokens.numberSize
                                            : null,
                                        selected: c.date == selected,
                                        onTap: c.playable && onSelect != null
                                            ? () => onSelect!(c.date!)
                                            : c.isToday && month.hasPlayable
                                            ? onShowToday
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

String _monthName(String locale, LocalDate date) {
  final name = DateFormat.LLLL(locale).format(date.startOfDay);
  return toBeginningOfSentenceCase(name, locale) ?? name;
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
  const _Header({
    required this.title,
    required this.height,
    this.size,
    this.chip,
  });

  final String title;
  final double height;
  final double? size;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    final base = HabitsMonthTokens.headerTitle;
    final chip = this.chip;
    final heading = Padding(
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
    );
    return SizedBox(
      height: chip == null
          ? height
          : math.max(height, HabitsMonthTokens.headerChipTarget),
      child: chip == null
          ? heading
          : Row(
              children: [
                Expanded(child: heading),
                chip,
              ],
            ),
    );
  }
}

/// The ‹ September / October › chip (frame 14.2c, tokens `headerChip*`): 30
/// dp tall on a 48 dp target, paging one month back or forward.
class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.month,
    required this.next,
    required this.onTap,
  });

  final String month;
  final bool next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final glyph = Icon(
      next ? NestyIcons.chevronRight : NestyIcons.chevronLeft,
      size: HabitsMonthTokens.headerChipGlyphSize,
      color: HabitsMonthTokens.headerChipLabel.color,
    );
    final label = Flexible(
      child: Text(
        month,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: context.scriptStyle(HabitsMonthTokens.headerChipLabel),
      ),
    );
    return Semantics(
      button: true,
      label: l10n.dailyMonthShowSemantics(month),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HabitsMonthTokens.headerChipTarget,
            minWidth: HabitsMonthTokens.headerChipTarget,
            maxWidth: 150,
          ),
          child: Center(
            child: NestySurface(
              style: const SurfaceStyle(
                color: HabitsMonthTokens.headerChipFace,
                shadows: HabitsMonthTokens.headerChipShadow,
              ),
              radius: BorderRadius.circular(HabitsMonthTokens.headerChipRadius),
              height: HabitsMonthTokens.headerChipHeight,
              padding: HabitsMonthTokens.headerChipPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: next ? [label, glyph] : [glyph, label],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The line under the title (frame 14.2a, textFit.habitsMonth.hint): the
/// full hint on one line, else its short form on one line, else the full
/// hint on two.
class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    // TODO(M4): the hint says "7 days" (copy.md) while `daily_archive_days`
    // is tunable 0–28. Before Remote Config can serve anything but 7, give
    // it a {days} plural in the nine catalogs (BACKLOG M4).
    final style = context.scriptStyle(HabitsMonthTokens.hintFont);
    final merged = DefaultTextStyle.of(context).style.merge(style);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: HabitsMonthTokens.headerInset,
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final painter = TextPainter(
            text: TextSpan(text: l10n.dailyMonthHint, style: merged),
            textDirection: direction,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final fullFits = painter.width <= box.maxWidth + 0.01;
          painter
            ..text = TextSpan(text: l10n.dailyMonthHintShort, style: merged)
            ..layout();
          final shortFits = painter.width <= box.maxWidth + 0.01;
          painter.dispose();
          final fullLines = fullFits || !shortFits;
          return Text(
            fullFits || !shortFits
                ? l10n.dailyMonthHint
                : l10n.dailyMonthHintShort,
            maxLines: fullLines && !fullFits
                ? TextFitTokens.habitsMonthHintMaxLines
                : 1,
            style: style,
          );
        },
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

/// A window day is a button that sinks 2 dp as it is pressed (tokens
/// `pressedShift`); any other day is just its cell, inert.
class _DayButton extends StatefulWidget {
  const _DayButton({
    required this.cell,
    required this.locale,
    required this.face,
    required this.small,
    required this.selected,
    this.numberSize,
    this.onTap,
  });

  final MonthCell cell;
  final String locale;
  final double face;
  final bool small;
  final double? numberSize;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_DayButton> createState() => _DayButtonState();
}

class _DayButtonState extends State<_DayButton> {
  bool _pressed = false;

  void _press(bool down) {
    if (_pressed != down) setState(() => _pressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final cell = _DayCell(
      cell: widget.cell,
      locale: widget.locale,
      face: widget.face,
      small: widget.small,
      numberSize: widget.numberSize,
      selected: widget.selected,
      pressed: _pressed,
      tappable: widget.onTap != null,
    );
    final onTap = widget.onTap;
    if (onTap == null) return cell;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press(true),
      onTapUp: (_) => _press(false),
      onTapCancel: () => _press(false),
      onTap: onTap,
      child: cell,
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
    this.selected = false,
    this.pressed = false,
    this.tappable = false,
  });

  /// Read as a button: a window day, or today's cell while it scrolls up.
  final bool tappable;

  final MonthCell cell;
  final String locale;
  final double face;
  final bool small;
  final double? numberSize;
  final bool selected;
  final bool pressed;

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
    final raised = playable && !today && edge != null && !selected;
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
              // The chosen day sinks with no edge under its rings; a
              // pressed one sinks onto a 1 dp edge (tokens `selected*`,
              // `pressed*`).
              if (selected) ...HabitsDayCellTokens.selectedRings,
              if (raised)
                NestyShadow(
                  color: edge,
                  dy: pressed
                      ? HabitsDayCellTokens.pressedEdgeDepth
                      : HabitsDayCellTokens.raisedEdgeDepth,
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
    final sink = selected
        ? HabitsDayCellTokens.selectedShift
        : pressed && playable
        ? HabitsDayCellTokens.pressedShift
        : 0.0;
    return Semantics(
      label: playable ? l10n.dailyMonthDayOpenSemantics(text) : text,
      button: tappable,
      selected: selected ? true : null,
      excludeSemantics: true,
      child: Center(
        child: AnimatedContainer(
          duration: Duration(
            milliseconds: context.reduceMotion
                ? 0
                : HabitsDayCellTokens.pressedMs,
          ),
          transform: Matrix4.translationValues(0, sink, 0),
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
      ),
    );
  }
}
