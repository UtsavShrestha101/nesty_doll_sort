import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// The Daily streak card (frames 5.1, 10.7; ui-spec-menus §6.5; NestyMenus
/// "isDaily") in the gentle streak's states (E2, m7-design §8):
///
/// - lit: a soft peach card, the flame disc on `gradient.streak`, "4 days"
///   and "Your flame is lit. See you tomorrow.";
/// - paused ([DailyStatus.paused], a missed day with no freeze): a white
///   card, the disc on the resting `streakPaused*` colours, a "Paused" chip
///   and "Your 4-day streak is resting. Solve today's puzzle to light it
///   again." Never red, and the number never drops;
/// - zero (nothing lit yet): the resting disc and no number, "Solve today's
///   puzzle to light your first flame.";
/// - [relit] (the win card's look, 10.7b): the lit card under a
///   `relitGlow` ring with "Streak relit!" and "Your 5-day streak is
///   glowing again.". Its two `fx_twinkle` sparkles belong to the win card's
///   own layer.
///
/// No sound and no haptic: it is a status, never a prompt.
class StreakCard extends StatelessWidget {
  const StreakCard({
    required this.status,
    this.relit = false,
    this.freezeKept = false,
    super.key,
  });

  final DailyStatus status;

  /// The relit look (10.7b): a paused streak the solve just lit again.
  final bool relit;

  /// A freeze covered a missed day and the "Streak saved!" toast is up
  /// (frame 5.2, m7-4 4.17): the lit card's line reads "A freeze kept your
  /// flame lit." until the solve.
  final bool freezeKept;

  // Frame 5.1 / 5.5 (NestyMenus "isDaily" streakLit): the Daily page's lit
  // card is the orange `gradient.streak` face with a 6 dp `streakEdge`
  // and a white 35 % top highlight. The peach `streakCard*` face is 10.7's
  // sheet card, which only the relit look (10.7b) keeps.
  static const _litStyle = SurfaceStyle(
    gradient: AppGradientTokens.streak,
    shadows: [
      NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.streakEdge, dy: 6),
    ],
  );

  static const _relitStyle = SurfaceStyle(
    gradient: AppGradientTokens.streakCard,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.streakCardEdge, dy: 5),
      NestyShadow(color: AppColorTokens.relitGlow, spread: 3),
    ],
  );

  // Frame 5.2b: a #FFF9EE face with the 6 dp `surfaceEdge`.
  static const _pausedStyle = SurfaceStyle(
    color: AppColorTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 6),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final resting = !relit && !status.lit;
    final paused = resting && status.paused;
    final zero = resting && !status.paused;
    final title = relit
        ? l10n.dailyStreakRelitTitle
        : (zero ? null : l10n.dailyStreakDays(status.streak));
    // The lit card (5.1) is the orange face with white type; the paused
    // and zero cards (5.2b) are the cream face; relit (10.7b) is peach.
    final orange = !relit && !resting;
    final freeze = !relit && status.unlocked;
    final textScaled = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    // 5.2b puts the freeze chip inline at the title row's end; a large text
    // scale moves it to its own line under the count so nothing squeezes.
    final inlineChip = paused && freeze && !textScaled;
    final countStyle = AppTextStyleTokens.h1.copyWith(
      fontSize: relit ? 30 : (orange ? 36 : 28),
      height: orange || resting ? 1 : 1.05,
      color: orange ? const Color(0xFFFFFFFF) : AppColorTokens.textPrimary,
    );
    final subStyle = AppTextStyleTokens.row.copyWith(
      fontSize: orange ? 14 : (resting ? 13 : 16),
      height: resting && !orange ? 1.35 : 1.25,
      color: orange
          ? const Color(0xFFFFEBDA)
          : (resting ? AppColorTokens.textBrown : AppColorTokens.textSecondary),
    );
    return Semantics(
      container: true,
      label: _semantics(l10n, resting: resting, paused: paused),
      child: ExcludeSemantics(
        child: NestySurface(
          style: relit ? _relitStyle : (resting ? _pausedStyle : _litStyle),
          radius: const BorderRadius.all(Radius.circular(24)),
          padding: resting && !relit
              ? const EdgeInsets.all(14)
              : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              _FlameDisc(resting: resting, orange: orange),
              SizedBox(width: resting && !relit ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      // A Wrap: at a narrow width or a large text scale the
                      // Paused chip drops under the count instead of
                      // squeezing it. It fills the row, so the freeze chip
                      // sits at the card's right edge (5.2b).
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                ShrinkToFitText(
                                  title,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  style: countStyle,
                                ),
                                if (paused)
                                  _PausedChip(
                                    label: l10n.dailyStreakPausedChip,
                                  ),
                              ],
                            ),
                          ),
                          if (inlineChip) ...[
                            const SizedBox(width: 8),
                            _FreezeChip(freezes: status.freezes, inline: true),
                          ],
                        ],
                      ),
                    if (paused && freeze && !inlineChip) ...[
                      const SizedBox(height: 6),
                      _FreezeChip(freezes: status.freezes, inline: true),
                    ],
                    if (title != null) SizedBox(height: resting ? 6 : 4),
                    Text(_subline(l10n, paused: paused), style: subStyle),
                  ],
                ),
              ),
              if (freeze && !paused) ...[
                const SizedBox(width: 8),
                _FreezeChip(freezes: status.freezes),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subline(AppLocalizations l10n, {required bool paused}) {
    if (relit) return l10n.dailyStreakRelitBody(status.streak);
    if (paused) return l10n.dailyStreakPaused(status.streak);
    if (!status.lit) return l10n.dailyStreakStart;
    if (freezeKept && !status.solvedToday) return l10n.dailySavedTitle;
    if (status.solvedToday) {
      return status.streak > 0 && status.streak % 7 == 0
          ? l10n.dailyStreakWeek
          : l10n.dailyStreakDone;
    }
    return l10n.dailyStreakKeep;
  }

  /// One reading for the card ("4 days. Paused. Your 4-day streak is
  /// resting. Solve today's puzzle to light it again.", ui-spec-menus §6.5).
  String _semantics(
    AppLocalizations l10n, {
    required bool resting,
    required bool paused,
  }) {
    final parts = <String>[
      if (relit)
        l10n.dailyStreakRelitTitle
      else if (resting && !paused)
        ''
      else
        l10n.dailyStreakDays(status.streak),
      if (paused) l10n.dailyStreakPausedChip,
      _subline(l10n, paused: paused),
      // a11y_freezes: the chip's count, read with the card (its own node is
      // excluded under the card's one label).
      if (!relit && status.unlocked) l10n.dailyFreezesSemantics(status.freezes),
    ];
    // A sentence that already ends in a full stop takes no second one.
    return l10n.joinSentences(parts);
  }
}

class _PausedChip extends StatelessWidget {
  const _PausedChip({required this.label});

  final String label;

  // Frame 5.2b: 22 dp high, radius 11, #FFFDF7 with a 1.5 dp `surfaceEdge`
  // ring, Nunito 800 11 `textBrown`.
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColorTokens.surfaceWhite,
      borderRadius: const BorderRadius.all(Radius.circular(11)),
      border: Border.all(color: AppColorTokens.surfaceEdge, width: 1.5),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 19),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: AppTextStyleTokens.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
              color: AppColorTokens.textBrown,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The flame disc: on the lit card (5.1) 64 dp, a 22 % white disc with a
/// 46 dp `#FFF6E6` flame; otherwise 56 dp: `gradient.streak` with a white
/// flame (relit), or the resting `streakPaused*` colours with
/// `streakPausedGlyph` (5.2b).
class _FlameDisc extends StatelessWidget {
  const _FlameDisc({required this.resting, required this.orange});

  final bool resting;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    if (orange) {
      return const SizedBox.square(
        dimension: 64,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x38FFFFFF),
          ),
          child: Icon(
            NestyIcons.localFireDepartment,
            size: 46,
            color: AppColorTokens.cream,
          ),
        ),
      );
    }
    return SizedBox.square(
      dimension: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: resting
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColorTokens.streakPausedTop,
                    AppColorTokens.streakPaused,
                  ],
                )
              : AppGradientTokens.streak,
          boxShadow: [
            BoxShadow(
              color: resting
                  ? AppColorTokens.streakPausedEdge
                  : AppColorTokens.streakEdge,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          NestyIcons.localFireDepartment,
          size: 34,
          color: resting
              ? AppColorTokens.streakPausedGlyph
              : const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

/// The freeze chip: a vertical 22 dp glyph over the count on the lit card
/// (5.1); [inline] is the paused card's 24 dp row (5.2b: radius 12, padding
/// 0/8/0/5, a 16 dp glyph, 11 dp type, a 2 dp edge).
class _FreezeChip extends StatelessWidget {
  const _FreezeChip({required this.freezes, this.inline = false});

  final int freezes;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final style = context.scriptStyle(
      AppTextStyleTokens.tierChip.copyWith(
        fontSize: 11,
        color: AppColorTokens.freezeChipText,
      ),
    );
    // textFit.freezeChip (m7-6 item 1): "{count} freezes" while it fits
    // 64 dp, else the number alone beside the snowflake. The screen reader
    // hears the card's own a11y_freezes line, so the chip adds none.
    final text = FitText.pick(
      full: l10n.dailyFreezes(freezes),
      short: l10n.dailyFreezesShort(freezes),
      style: DefaultTextStyle.of(context).style.merge(style),
      maxWidth: TextFitTokens.freezeChipMaxWidth,
      scaler: MediaQuery.textScalerOf(context),
      direction: Directionality.of(context),
      minScale: 1,
    );
    final label = Text(text, style: style, maxLines: 1, softWrap: false);
    return NestySurface(
      style: SurfaceStyle(
        color: AppColorTokens.iceTint,
        shadows: [
          NestyShadow(color: AppColorTokens.infoEdge, dy: inline ? 2 : 3),
        ],
      ),
      radius: BorderRadius.all(Radius.circular(inline ? 12 : 14)),
      padding: inline
          ? const EdgeInsets.fromLTRB(5, 4, 8, 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: inline
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  NestyIcons.acUnit,
                  size: 16,
                  color: AppColorTokens.ice,
                ),
                const SizedBox(width: 3),
                label,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  NestyIcons.acUnit,
                  size: 22,
                  color: AppColorTokens.ice,
                ),
                const SizedBox(height: 3),
                label,
              ],
            ),
    );
  }
}
