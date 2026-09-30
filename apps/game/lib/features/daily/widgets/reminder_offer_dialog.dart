import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_text_link.dart';

/// The one-time reminder offer, a card over the Daily screen after the first
/// solve (frames 10.2 and 10.2d; ui-spec-menus §6.2; spec-prop §7.9, §10.2
/// #11; phase 4 architecture §3.9): the bell disc, the title, the body, the
/// time chip and Change time, "Yes, remind me" and "No thanks". A denied Yes
/// morphs the same card into "Notifications are off for Nesty" with Open
/// phone settings and Not now (D190: the reminder stays on and blocked).
///
/// It is an overlay in the page's `Stack`, over a [ReminderOfferCubit]
/// ancestor ([provided] adds one). The scrim and the barrier do nothing;
/// system back answers "No thanks" (or "Not now" once denied). When the
/// phone allows notifications, on Yes or on return from its settings, the
/// card closes and the 10.2c "Reminder set for {time}." toast shows.
///
/// A reminder is off until the player says yes, so nothing here decides
/// anything for them.
class ReminderOfferDialog extends StatelessWidget {
  const ReminderOfferDialog({super.key});

  /// The dialog with its own [ReminderOfferCubit], loaded.
  static Widget provided() => BlocProvider(
    create: (_) => get<ReminderOfferCubit>()..load(),
    child: const ReminderOfferDialog(),
  );

  /// The card's side margin (frame 10.2: left and right 28).
  static const double sideMargin = 28;

  /// The bell disc and its halo (frame 10.2: 104 dp with an 8 px ring).
  static const double discSize = 104;
  static const double haloWidth = 8;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ReminderOfferCubit, AsyncValue<ReminderOfferState>>(
        listenWhen: (previous, current) =>
            previous.data?.step != ReminderOfferStep.enabled &&
            current.data?.step == ReminderOfferStep.enabled,
        listener: _onEnabled,
        buildWhen: (previous, current) => previous.data != current.data,
        builder: (context, value) {
          final data = value.data;
          if (data == null ||
              data.step == ReminderOfferStep.hidden ||
              data.step == ReminderOfferStep.enabled) {
            return const SizedBox.shrink();
          }
          return _Overlay(data: data);
        },
      );

  void _onEnabled(BuildContext context, AsyncValue<ReminderOfferState> value) {
    final data = value.data;
    if (data == null) return;
    final l10n = context.localizations;
    NestyToast.show(
      context,
      tone: NestyBannerTone.success,
      icon: IconUses.reminder,
      title: l10n.reminderOfferDone(_formatTime(context, data)),
    );
    context.read<ReminderOfferCubit>().dismiss();
  }
}

String _formatTime(BuildContext context, ReminderOfferState data) =>
    MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: data.hour, minute: data.minute));

class _Overlay extends StatelessWidget {
  const _Overlay({required this.data});

  final ReminderOfferState data;

  bool get _denied => data.step == ReminderOfferStep.denied;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReminderOfferCubit>();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final enterMs = reduced ? 120 : UiMotionTokens.modalInMs;
    return PopScope(
      // System back is "No thanks" / "Not now" (ui-spec-menus §6.2).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(cubit.decline());
      },
      // The Daily page draws the offer beside its Scaffold, not inside it
      // (it covers the status bar too), so no Material was above its text:
      // every line wore the no-Material yellow double underline on a
      // device (the phase-4 device run, 2026-09-30). A transparent Material
      // gives it the app's text defaults and paints nothing itself.
      child: Material(
        type: MaterialType.transparency,
        child: ModalSemanticsScope(
          child: Stack(
            children: [
              const Positioned.fill(
                child: ModalBarrier(
                  dismissible: false,
                  color: AppColorTokens.scrim,
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ReminderOfferDialog.sideMargin,
                        vertical: 16,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: enterMs),
                        curve: UiMotionTokens.curveEaseOut,
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: reduced
                              ? child
                              : Transform.scale(
                                  scale: 0.94 + 0.06 * t,
                                  child: child,
                                ),
                        ),
                        child: ModalCard(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: reduced ? 0 : 150),
                            child: KeyedSubtree(
                              key: ValueKey(_denied),
                              child: _denied
                                  ? _Denied(data: data)
                                  : _Ask(
                                      data: data,
                                      asking:
                                          data.step == ReminderOfferStep.asking,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 104 dp disc with its 8 px halo: the daily gradient with a bell (ask),
/// or the track colour with a bell-off (denied).
class _BellDisc extends StatelessWidget {
  const _BellDisc({required this.off});

  final bool off;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: ReminderOfferDialog.discSize + 2 * ReminderOfferDialog.haloWidth,
      height: ReminderOfferDialog.discSize + 2 * ReminderOfferDialog.haloWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: off
            ? AppColorTokens.surfaceTrack.withValues(alpha: 0.5)
            : AppColorTokens.dailyTop.withValues(alpha: 0.35),
      ),
      child: Container(
        width: ReminderOfferDialog.discSize,
        height: ReminderOfferDialog.discSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: off ? null : AppGradientTokens.daily,
          color: off ? AppColorTokens.surfaceTrack : null,
          boxShadow: [
            BoxShadow(
              color: off
                  ? AppColorTokens.surfaceEdge
                  : AppColorTokens.dailyEdge,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          off ? IconUses.reminderOff : IconUses.reminder,
          size: 52,
          color: off ? AppColorTokens.textSecondary : AppColorTokens.coinText,
        ),
      ),
    ),
  );
}

class _Ask extends StatelessWidget {
  const _Ask({required this.data, required this.asking});

  final ReminderOfferState data;
  final bool asking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final cubit = context.read<ReminderOfferCubit>();
    final time = _formatTime(context, data);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _BellDisc(off: false)),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            l10n.reminderOfferTitle,
            textAlign: TextAlign.center,
            style: AppTextStyleTokens.h2.copyWith(
              color: AppColorTokens.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.reminderOfferBody,
          textAlign: TextAlign.center,
          style: AppTextStyleTokens.body.copyWith(
            color: AppColorTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: _TimeChip(
            label: l10n.reminderOfferTime(time),
            semanticLabel:
                '${l10n.reminderOfferTime(time)}, ${l10n.reminderOfferChangeTime}',
            onPressed: asking
                ? null
                : () => unawaited(_pickTime(context, cubit)),
          ),
        ),
        Center(
          child: _AccentLink(
            label: l10n.reminderOfferChangeTime,
            onPressed: asking
                ? null
                : () => unawaited(_pickTime(context, cubit)),
          ),
        ),
        const SizedBox(height: 6),
        TactileButton(
          label: l10n.reminderOfferYes,
          onPressed: asking ? null : () => unawaited(cubit.accept()),
        ),
        const SizedBox(height: 4),
        Center(
          child: OverlayTextLink(
            label: l10n.reminderOfferNo,
            onPressed: asking ? null : () => unawaited(cubit.decline()),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, ReminderOfferCubit cubit) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: data.hour, minute: data.minute),
    );
    if (picked != null) cubit.setTime(hour: picked.hour, minute: picked.minute);
  }
}

class _Denied extends StatelessWidget {
  const _Denied({required this.data});

  final ReminderOfferState data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final cubit = context.read<ReminderOfferCubit>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _BellDisc(off: true)),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            l10n.reminderOfferDeniedTitle,
            textAlign: TextAlign.center,
            style: AppTextStyleTokens.h2.copyWith(
              color: AppColorTokens.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.reminderOfferDenied(_formatTime(context, data)),
          textAlign: TextAlign.center,
          style: AppTextStyleTokens.body.copyWith(
            color: AppColorTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        TactileButton(
          label: l10n.settingOpenPhoneSettings,
          onPressed: () => unawaited(cubit.openPhoneSettings()),
        ),
        const SizedBox(height: 4),
        Center(
          child: OverlayTextLink(
            label: l10n.notNow,
            onPressed: () => unawaited(cubit.decline()),
          ),
        ),
      ],
    );
  }
}

/// Frame 10.2's time chip: 48 tall, radius 24, white with a 4 px edge, a
/// 32 dp clock tile and the "Every day at {time}" line. It opens the
/// phone's time picker, like [_AccentLink].
class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) => TactileSurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(24)),
    onPressed: onPressed,
    height: 48,
    padding: const EdgeInsetsDirectional.only(start: 8, end: 20),
    semanticLabel: semanticLabel,
    excludeChildSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorTokens.woodLight,
          ),
          child: SizedBox.square(
            dimension: 32,
            child: Icon(
              IconUses.reminderTime,
              size: 20,
              color: AppColorTokens.coinText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyleTokens.buttonSmall.copyWith(
              fontSize: 19,
              color: AppColorTokens.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

/// "Change time": the orange text link of frame 10.2 (`primaryEdge`), a
/// 48 dp touch target around the line (lead note 3).
// TODO(design): 10.2's orange link has no `textLink` variant in tokens.json.
class _AccentLink extends StatelessWidget {
  const _AccentLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    void activate() {
      TactileFeedback.of(context)?.activate();
      onPressed?.call();
    }

    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: onPressed == null ? null : activate,
      child: TouchTarget(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onPressed == null ? null : activate,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: OverlayTextLink.style.copyWith(
              color: AppColorTokens.primaryEdge,
            ),
          ),
        ),
      ),
    );
  }
}
