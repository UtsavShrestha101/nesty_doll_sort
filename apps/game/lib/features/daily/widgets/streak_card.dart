import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The Daily streak card (frame 5.1: orange gradient, "4 days", the
/// subline, a freeze chip; NestyMenus "isDaily").
class StreakCard extends StatelessWidget {
  const StreakCard({required this.status, super.key});

  final DailyStatus status;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.streak,
    shadows: [
      NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.streakEdge, dy: 6),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return NestySurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          const _FlameDisc(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dailyStreakDays(status.streak),
                  style: AppTextStyleTokens.h1.copyWith(
                    fontSize: 36,
                    height: 1,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subline(l10n),
                  style: AppTextStyleTokens.row.copyWith(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFEBDA),
                  ),
                ),
              ],
            ),
          ),
          _FreezeChip(freezes: status.freezes),
        ],
      ),
    );
  }

  String _subline(AppLocalizations l10n) {
    if (status.solvedToday) {
      return status.streak > 0 && status.streak % 7 == 0
          ? l10n.dailyStreakWeek
          : l10n.dailyStreakDone;
    }
    return status.streak > 0 ? l10n.dailyStreakKeep : l10n.dailyStreakStart;
  }
}

class _FlameDisc extends StatelessWidget {
  const _FlameDisc();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 64,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x38FFFFFF),
      ),
      child: Icon(
        NestyIcons.localFireDepartment,
        size: 42,
        color: AppColors.cream,
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
