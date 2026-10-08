import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/widgets/puzzle_card.dart';

/// A past day's card (frames 14.3b, 14.3e; tokens `habits.pastDay`): 5.1's
/// puzzle card for the chosen date, under the month card. Its parts: the
/// date title, the "5 colors · Hard" chip, the 120 dp preview, Play with no
/// coin chip, then the note that the streak stays as it is. A day already
/// solved (on its day or later) dims the preview under a green pill and
/// offers Play again instead.
///
/// It opens by sliding 12 dp down while it fades in; under reduced motion
/// it only fades.
class PastDayCard extends StatelessWidget {
  const PastDayCard({
    required this.state,
    required this.date,
    required this.onPlay,
    super.key,
  });

  final DailyState state;
  final LocalDate date;
  final VoidCallback onPlay;

  /// The Play button's key, for tests.
  static const playKey = Key('past-day-play');

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final locale = Localizations.localeOf(context).toString();
    final status = state.status;
    final onDay = status.done.contains(date);
    final later = !onDay && status.played.contains(date);
    final solved = onDay || later;
    final tier = state.pastTier;
    final title = l10n.pastDailyTitle(
      DateFormat(
        HabitsPastDayTokens.cardTitleDateSkeleton,
        locale,
      ).format(date.startOfDay),
    );
    return NestySurface(
      style: const SurfaceStyle(
        gradient: AppGradientTokens.surface,
        shadows: [
          NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
          NestyShadow(color: AppColorTokens.surfaceEdge, dy: 6),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(26)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PuzzleTitleRow(
            title: title,
            info: tier == null
                ? ''
                : l10n.dailyPuzzleInfo(
                    state.pastColorCount,
                    l10n.tierName(tier.id),
                  ),
          ),
          const SizedBox(height: 14),
          PuzzlePreview(
            colors: state.pastPreviewColors,
            failed: state.pastPreviewFailed,
            solvedLabel: onDay
                ? l10n.pastDailySolvedOnDay
                : later
                ? l10n.pastDailySolvedLater
                : null,
          ),
          const SizedBox(height: 14),
          if (solved)
            TactileButton(
              key: playKey,
              label: l10n.pastDailyPlayAgain,
              icon: NestyIcons.replay,
              variant: TactileButtonVariant.secondary,
              onPressed: onPlay,
            )
          else
            _PlayButton(onPressed: onPlay),
          const SizedBox(height: 10),
          Text(
            l10n.pastDailyNote,
            textAlign: TextAlign.center,
            style: context.scriptStyle(HabitsPastDayTokens.cardNote),
          ),
        ],
      ),
    );
  }
}

/// 5.1's Play button with no coin chip: the play triangle and "Play",
/// 60 dp tall.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return TactileSurface(
      key: PastDayCard.playKey,
      style: TactileButtonVariant.primary.surface(6),
      radius: BorderRadius.circular(22),
      onPressed: onPressed,
      height: HabitsPastDayTokens.cardPlayHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      semanticLabel: l10n.dailyPlay,
      excludeChildSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(NestyIcons.playArrow, size: 22, color: _white),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l10n.dailyPlay,
              maxLines: 1,
              style: AppTextStyleTokens.button.copyWith(
                fontSize: 22,
                color: _white,
                shadows: const [
                  Shadow(color: Color(0x59963C0A), offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The card's opening (tokens `habits.pastDay.open*`): it slides 12 dp down
/// and fades in over 240 ms, and the page scrolls just enough to show the
/// card's end (its note) over 300 ms. Reduced motion: a 150 ms fade and the
/// scroll jumps.
class PastDayReveal extends StatefulWidget {
  const PastDayReveal({required this.child, super.key});

  final Widget child;

  @override
  State<PastDayReveal> createState() => _PastDayRevealState();
}

class _PastDayRevealState extends State<PastDayReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  // Made once: a CurvedAnimation listens to its parent until disposed.
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: HabitsPastDayTokens.openCurve,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = context.reduceMotion;
    _controller.duration = Duration(
      milliseconds: reduced
          ? HabitsPastDayTokens.openReducedMs
          : HabitsPastDayTokens.openMs,
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.maybeOf(context)?.position.ensureVisible(
        context.findRenderObject()!,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: reduced
            ? Duration.zero
            : const Duration(milliseconds: HabitsPastDayTokens.openScrollMs),
        curve: HabitsPastDayTokens.openCurve,
      );
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = context.reduceMotion;
    final curved = _curved;
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            0,
            reduced ? 0 : (curved.value - 1) * HabitsPastDayTokens.openSlide,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
