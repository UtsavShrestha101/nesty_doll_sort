import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

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
  const StreakCard({required this.status, this.relit = false, super.key});

  final DailyStatus status;

  /// The relit look (10.7b): a paused streak the solve just lit again.
  final bool relit;

  // TODO(design): the lit card's peach face and edge are frame-only
  // (10.7: #FFF2E6 to #FFE7D0, edge #E6B79A); ask for tokens.json colors.
  static const _litGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF2E6), Color(0xFFFFE7D0)],
  );
  static const _litEdge = Color(0xFFE6B79A);

  static const _litStyle = SurfaceStyle(
    gradient: _litGradient,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: _litEdge, dy: 4),
    ],
  );

  static const _relitStyle = SurfaceStyle(
    gradient: _litGradient,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: _litEdge, dy: 4),
      NestyShadow(color: AppColorTokens.relitGlow, spread: 3),
    ],
  );

  static const _pausedStyle = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
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
    return Semantics(
      container: true,
      label: _semantics(l10n, resting: resting, paused: paused),
      child: ExcludeSemantics(
        child: NestySurface(
          style: relit ? _relitStyle : (resting ? _pausedStyle : _litStyle),
          radius: const BorderRadius.all(Radius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              _FlameDisc(resting: resting),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      // A Wrap: at a narrow width or a large text scale the
                      // Paused chip drops under the count instead of
                      // squeezing it.
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: [
                          ShrinkToFitText(
                            title,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: AppTextStyleTokens.h1.copyWith(
                              fontSize: relit ? 30 : 34,
                              height: 1.05,
                              color: AppColorTokens.textPrimary,
                            ),
                          ),
                          if (paused)
                            _PausedChip(label: l10n.dailyStreakPausedChip),
                        ],
                      ),
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      _subline(l10n, paused: paused),
                      style: AppTextStyleTokens.row.copyWith(
                        fontSize: 16,
                        height: 1.25,
                        color: AppColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!relit && status.unlocked) ...[
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
    ];
    return parts.where((p) => p.isNotEmpty).join('. ');
  }
}

class _PausedChip extends StatelessWidget {
  const _PausedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColorTokens.surfaceWhite,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      border: Border.all(color: AppColorTokens.surfaceEdge, width: 1.5),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Text(
        label,
        style: AppTextStyleTokens.caption.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: AppColorTokens.textSecondary,
        ),
      ),
    ),
  );
}

/// The 56 dp flame disc: `gradient.streak` with a white flame when lit, the
/// resting `streakPaused*` colours with `streakPausedGlyph` otherwise.
class _FlameDisc extends StatelessWidget {
  const _FlameDisc({required this.resting});

  final bool resting;

  @override
  Widget build(BuildContext context) => SizedBox.square(
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

class _FreezeChip extends StatelessWidget {
  const _FreezeChip({required this.freezes});

  final int freezes;

  static const _style = SurfaceStyle(
    color: AppColorTokens.iceTint,
    shadows: [NestyShadow(color: AppColors.infoEdge, dy: 3)],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(NestyIcons.acUnit, size: 22, color: AppColorTokens.ice),
        const SizedBox(height: 3),
        Text(
          context.localizations.dailyFreezes(freezes),
          style: AppTextStyleTokens.tierChip.copyWith(
            fontSize: 11,
            color: AppColors.freezeChipText,
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    ),
  );
}
