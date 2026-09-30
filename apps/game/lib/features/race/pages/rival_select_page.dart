import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';

/// Rival select (vs Computer; frames 9.2, 9.2b; spec-prop §7.7, §10.2 #17;
/// docs/plans/m7-design.md P2.8, P4.4), pushed on the root router from
/// Home's vs Computer tile. The player taps a rival to select it, and the
/// one Start stores the race's number (`RivalSelectCubit.begin`) and pushes
/// the gameplay page with the race.
@RoutePage()
class RivalSelectPage extends StatelessWidget implements AutoRouteWrapper {
  const RivalSelectPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<RivalSelectCubit>()..load(), child: this);

  @override
  Widget build(BuildContext context) => const RivalSelectView();
}

/// The rival select body over a `RivalSelectCubit` ancestor (frame 9.2):
/// the header, the subtitle, three rival cards in a [WideScreenColumn] (each
/// a computer opponent, spec-prop §1.1 rule 5: [ComputerTag] beside every
/// name), and, pinned at the bottom, the hint and the one Start.
class RivalSelectView extends StatelessWidget {
  const RivalSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return BlocBuilder<RivalSelectCubit, AsyncValue<RivalSelectState>>(
      builder: (context, value) {
        final data = value.data;
        final error = value.exceptionOrNull;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: l10n.raceSelectTitle,
                    onBack: () => context.router.maybePop(),
                    coins: data?.coins,
                  ),
                  const SizedBox(height: 8),
                  if (data != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        l10n.raceSelectSubtitle,
                        style: AppTextStyleTokens.row.copyWith(
                          color: AppColorTokens.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: data != null
                        ? WideScreenColumn(
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 12),
                              children: [
                                for (final rival in data.rivals) ...[
                                  _RivalCard(
                                    rival: rival,
                                    selected: rival.number == data.selected,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          )
                        : error != null
                        ? Center(
                            child: RetryView(
                              exception: error,
                              onRetry: () =>
                                  context.read<RivalSelectCubit>().load(),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  if (data != null) _StartBar(selected: data.selected),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The hint over the one Start (frame 9.2: `raceStartHint`, then a
/// `VersusButton` 60 tall with `play_arrow` and `raceStart`), pinned under
/// the list so a short screen scrolls the cards, never the button.
class _StartBar extends StatelessWidget {
  const _StartBar({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return WideScreenColumn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.raceStartHint,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.bodySmall.copyWith(
                fontSize: 16,
                height: 1.3,
                color: AppColorTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TactileButton(
              label: l10n.raceStart,
              icon: NestyIcons.playArrow,
              variant: TactileButtonVariant.versus,
              semanticLabel: l10n.raceStartFor(l10n.raceRivalName(selected)),
              onPressed: () => _start(context, selected),
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context, int rival) {
    final race = context.read<RivalSelectCubit>().begin(rival);
    if (race == null) return;
    unawaited(context.router.root.push(GameplayRoute(request: race)));
  }
}

/// One rival's card (frame 9.2, 9.2b): [RivalPortrait] 96, the name with its
/// [ComputerTag] (and "New"), the skill line, the personality, the reward
/// chip (shown before the race, spec-prop §1.1 rule 2). A radio of the
/// group: a tap selects it (a 3 dp indigo ring and a check disc). A beaten
/// rival wears a green check on its portrait. A locked card is inert: the
/// locked portrait, sunk at 0.7, "Beat {rival} to unlock", no reward chip,
/// no tap, no feedback.
class _RivalCard extends StatelessWidget {
  const _RivalCard({required this.rival, required this.selected});

  final RivalCard rival;
  final bool selected;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  static const _lockedStyle = SurfaceStyle(
    color: Color(0xB3FCEBD0),
    shadows: [],
  );

  static const _radius = BorderRadius.all(
    Radius.circular(RivalSelectTokens.cardRadius),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(rival.number);
    final unlocked = rival.unlocked;
    final skin = l10n.raceRivalSkill(rival.number);
    final blurb = l10n.raceRivalBlurb(rival.number);
    final lockedLine = l10n.raceRivalLocked(
      l10n.raceRivalName(rival.number - 1),
    );
    final label = [
      l10n.raceRivalSemantics(name),
      skin,
      if (unlocked) blurb,
      if (unlocked) l10n.raceRivalReward(rival.rewardCoins) else lockedLine,
      if (rival.beaten) l10n.raceRivalBeaten,
      if (rival.isNew) l10n.raceRivalNew,
    ].join('. ');
    final reduce = context.reduceMotion;
    final ringDuration = reduce ? Duration.zero : _ringDuration;
    // Its own hit box and semantics (a radio in an exclusive group): the
    // whole card, over 48 dp tall.
    return Semantics(
      container: true,
      label: label,
      enabled: unlocked,
      inMutuallyExclusiveGroup: true,
      checked: unlocked ? selected : null,
      excludeSemantics: true,
      onTap: unlocked ? () => _select(context) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: unlocked ? () => _select(context) : null,
        child: Stack(
          children: [
            NestySurface(
              style: unlocked ? _style : _lockedStyle,
              radius: _radius,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Portrait(
                    rival: rival,
                    selected: selected,
                    duration: ringDuration,
                    pop: !reduce,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _Details(
                      rival: rival,
                      name: name,
                      skill: skin,
                      blurb: blurb,
                      lockedLine: lockedLine,
                    ),
                  ),
                ],
              ),
            ),
            // The ring and the check disc fade in over 120 ms.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: selected && unlocked ? 1 : 0,
                  duration: ringDuration,
                  child: const _SelectedMark(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _ringDuration = Duration(milliseconds: 120);

  void _select(BuildContext context) {
    context.read<RivalSelectCubit>().select(rival.number);
  }
}

/// The selected card's ring (`layout.rivalSelect.selectedRing`) and the 30
/// dp check disc at its top right.
class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    const ring = RivalSelectTokens.selectedRing;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _RivalCard._radius,
              border: Border.all(color: ring.color, width: ring.width),
            ),
          ),
        ),
        const PositionedDirectional(
          top: 14,
          end: 14,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorTokens.versus,
            ),
            child: SizedBox.square(
              dimension: 30,
              child: Icon(
                NestyIcons.check,
                size: 20,
                color: AppColorTokens.surfaceWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 96 dp portrait: it pops to 1.04 while selected (not under reduced
/// motion), and a beaten rival's green check sits on its lower right.
class _Portrait extends StatelessWidget {
  const _Portrait({
    required this.rival,
    required this.selected,
    required this.duration,
    required this.pop,
  });

  final RivalCard rival;
  final bool selected;
  final Duration duration;
  final bool pop;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: RivalSelectTokens.portrait,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedScale(
          scale: pop && selected && rival.unlocked ? 1.04 : 1,
          duration: duration,
          child: RivalPortrait(
            number: rival.number,
            size: RivalSelectTokens.portrait,
            locked: !rival.unlocked,
          ),
        ),
        if (rival.beaten)
          const PositionedDirectional(
            end: -4,
            bottom: -2,
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorTokens.success,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColorTokens.surfaceWhite, width: 2),
                  ),
                ),
                child: SizedBox.square(
                  dimension: 28,
                  child: Icon(
                    NestyIcons.check,
                    size: 18,
                    color: AppColorTokens.surfaceWhite,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// The card's text column: the name row (name, tag, "New"), the skill line,
/// the personality, then the reward chip or the lock line.
class _Details extends StatelessWidget {
  const _Details({
    required this.rival,
    required this.name,
    required this.skill,
    required this.blurb,
    required this.lockedLine,
  });

  final RivalCard rival;
  final String name;
  final String skill;
  final String blurb;
  final String lockedLine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final unlocked = rival.unlocked;
    final nameColor = unlocked
        ? AppColorTokens.textPrimary
        : AppColorTokens.textMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The check disc's 30 dp sits over the row's right end: the row
        // leaves it room, and scales down rather than cut (R28).
        Padding(
          padding: EdgeInsetsDirectional.only(end: unlocked ? 36 : 0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    fontSize: 26,
                    color: nameColor,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(width: 8),
                ComputerTag.responsive(),
                if (rival.isNew) ...[
                  const SizedBox(width: 6),
                  _NewChip(label: l10n.raceRivalNew),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          skill,
          style: AppTextStyleTokens.row.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: unlocked
                ? AppColorTokens.versusEdge
                : AppColorTokens.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          blurb,
          style: AppTextStyleTokens.bodySmall.copyWith(
            fontSize: 16,
            height: 23 / 16,
            color: AppColorTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (unlocked)
          _RewardChip(coins: rival.rewardCoins)
        else
          Row(
            children: [
              const Icon(
                NestyIcons.lock,
                size: 20,
                color: AppColorTokens.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lockedLine,
                  style: AppTextStyleTokens.button.copyWith(
                    fontSize: 16,
                    color: AppColorTokens.textMuted,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// The "New" chip (frame 9.2b: `gradient.success`, Fredoka 700 12 white,
/// radius 12) on an unlocked rival the player hasn't raced.
class _NewChip extends StatelessWidget {
  const _NewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RivalSelectTokens.newChipFill,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      child: Text(
        label,
        style: RivalSelectTokens.newChipText.copyWith(
          color: const Color(0xFFFFFFFF),
        ),
        maxLines: 1,
        softWrap: false,
      ),
    ),
  );
}

/// The reward chip (`CoinIcon` + `raceRivalReward` on a `gradient.daily`
/// pill 40 tall with a 4 dp `dailyEdge`), shown on every unlocked card
/// before the race (spec-prop §1.1 rule 2: every reward is shown in
/// advance). A rematch pays too, so a beaten rival keeps it.
class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.coins});

  final int coins;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.daily,
    shadows: [NestyShadow(color: AppColorTokens.dailyEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: NestySurface(
        style: _style,
        radius: const BorderRadius.all(Radius.circular(20)),
        height: 40,
        padding: const EdgeInsetsDirectional.only(start: 6, end: 14),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinIcon(size: 28),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.raceRivalReward(coins),
                  style: AppTextStyleTokens.number.copyWith(
                    fontSize: 18,
                    color: AppColorTokens.coinText,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
