import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// The player's switches on the pause dialog (frame 3.9), read from and
/// written to `DatabaseService` by the page.
@immutable
final class PauseSettings {
  const PauseSettings({
    required this.sound,
    required this.music,
    required this.haptics,
  });

  final bool sound;
  final bool music;
  final bool haptics;

  PauseSettings copyWith({bool? sound, bool? music, bool? haptics}) =>
      PauseSettings(
        sound: sound ?? this.sound,
        music: music ?? this.music,
        haptics: haptics ?? this.haptics,
      );

  @override
  bool operator ==(Object other) =>
      other is PauseSettings &&
      other.sound == sound &&
      other.music == music &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(sound, music, haptics);
}

/// The race a race's Pause is over (frames 9.7, 9.7b; phase 4 architecture
/// §6.6): which computer rival, for the header ("vs Computer · Pebble", the
/// portrait and the Computer tag) and "Pebble is paused too." Lane R draws
/// it.
@immutable
final class RacePauseInfo {
  const RacePauseInfo({required this.rival});

  /// The computer rival, 1–3 (`RacePlay.rival`).
  final int rival;

  @override
  bool operator ==(Object other) =>
      other is RacePauseInfo && other.rival == rival;

  @override
  int get hashCode => Object.hash(RacePauseInfo, rival);
}

/// Frame 3.9, Pause (spec §10.2 #14): the "Paused" card over the scrim,
/// "Level 56 · Hard", the Sound, Music and Haptics toggles (so players don't
/// leave the level to change them), Resume, then Restart, Home and
/// Settings (pushes `SettingsRoute` over the level, which stays paused
/// underneath, m3-design §10.1).
///
/// In a race ([race] set; frame 9.7) the pill and Resume take versus's
/// indigo, a header names the computer rival ("vs Computer · Pebble", with
/// its portrait and [ComputerTag]) over "Pebble is paused too.", the toggles
/// sit in a card, and the tiles are Restart, Leave race and Settings. Leave
/// race asks once (frame 9.7b, "Leave this race?"): Keep racing resumes,
/// Leave race calls [onLeaveRace], which writes nothing.
///
/// The toggles are `ui_toggle` (`on` 0–11, `off` 11–22; LOTTIE.md "Settings
/// / Pause toggle"), with the static toggle when the file is missing.
class PauseDialog extends StatefulWidget {
  const PauseDialog({
    this.level,
    this.tier,
    this.race,
    required this.settings,
    required this.onSoundChanged,
    required this.onMusicChanged,
    required this.onHapticsChanged,
    required this.onResume,
    required this.onRestart,
    this.onHome,
    this.onSettings,
    this.onLeaveRace,
    this.library,
    super.key,
  }) : assert(
         race != null || (level != null && tier != null),
         'a race or a level and tier',
       );

  /// The normal subtitle, "Level N · Tier" (null in a race: [race]
  /// replaces it).
  final int? level;
  final Tier? tier;

  /// Set in a race (frame 9.7): the header, "{rival} is paused too." in
  /// place of "Level N · Tier".
  final RacePauseInfo? race;
  final PauseSettings settings;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onResume;
  final VoidCallback onRestart;

  /// Null hides the Home tile (a race has none).
  final VoidCallback? onHome;

  /// Pushes `SettingsRoute` over the level, which stays paused underneath
  /// (m3-design §10.1). Null hides the Settings tile.
  final VoidCallback? onSettings;

  /// Leave race (frame 9.7), after the one confirmation (9.7b): pops to
  /// rival select and writes nothing. Null outside a race.
  final VoidCallback? onLeaveRace;

  /// The loaded compositions: `ui_toggle` plays when it has it, else the
  /// toggles draw their static look (rule 3).
  final FxLibrary? library;

  /// NestyOverlay: the card sits 32 from each side, its top at 190 on a
  /// 59 safe area.
  static const double side = 32;
  static const double cardTop = 190 - 59;

  /// A race's Pause (frame 9.7): 24 from each side, top 176.
  static const double raceSide = 24;
  static const double raceCardTop = 176 - 59;

  /// 9.7b's card: top 236, 28 from each side.
  static const double leaveSide = 28;
  static const double leaveCardTop = 236 - 59;

  @override
  State<PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends State<PauseDialog> {
  /// 9.7b is up: Leave race was tapped once.
  bool _confirming = false;

  /// Restart, then whichever of Home, Settings and Leave race are wired up.
  /// A race's order is the frame's: Restart, Leave race, Settings.
  List<Widget> _tiles(AppLocalizations l10n) {
    final onHome = widget.onHome;
    final onSettings = widget.onSettings;
    final onLeave = widget.onLeaveRace == null
        ? null
        : () => setState(() => _confirming = true);
    final leave = onLeave == null
        ? null
        : _PauseTile(
            icon: IconUses.leaveRace,
            label: l10n.raceQuit,
            onPressed: onLeave,
          );
    final settings = onSettings == null
        ? null
        : _PauseTile(
            icon: NestyIcons.settings,
            label: l10n.settings,
            onPressed: onSettings,
          );
    return [
      _PauseTile(
        icon: NestyIcons.restartAlt,
        label: l10n.restart,
        onPressed: widget.onRestart,
      ),
      if (onHome != null)
        _PauseTile(icon: NestyIcons.home, label: l10n.home, onPressed: onHome),
      ?leave,
      ?settings,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final race = widget.race;
    if (race != null && _confirming) return _leaveConfirm(context, race);
    final tiles = _tiles(l10n);
    final versus = race != null;
    final toggles = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleRow(
          icon: NestyIcons.volumeUp,
          label: l10n.settingSound,
          value: widget.settings.sound,
          onChanged: widget.onSoundChanged,
          library: widget.library,
          versus: versus,
        ),
        _Divider(versus: versus),
        _ToggleRow(
          icon: NestyIcons.musicNote,
          label: l10n.settingMusic,
          value: widget.settings.music,
          onChanged: widget.onMusicChanged,
          library: widget.library,
          versus: versus,
        ),
        _Divider(versus: versus),
        _ToggleRow(
          icon: NestyIcons.vibration,
          label: l10n.settingHaptics,
          value: widget.settings.haptics,
          onChanged: widget.onHapticsChanged,
          library: widget.library,
          versus: versus,
        ),
        if (!versus) const _Divider(versus: false),
      ],
    );
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          // Tapping outside doesn't resume: Resume is the one way back.
          Scrim(opacity: progress),
          ModalPlacement(
            cardTop: versus ? PauseDialog.raceCardTop : PauseDialog.cardTop,
            side: versus ? PauseDialog.raceSide : PauseDialog.side,
            clearance: RibbonTitle.overhang,
            child: content,
          ),
        ],
      ),
      child: ModalCard(
        title: versus ? null : l10n.pauseTitle,
        ribbon: versus ? _versusRibbon(l10n.pauseTitle) : null,
        padding: versus ? const EdgeInsets.fromLTRB(18, 40, 18, 18) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (race != null) ...[
              _RaceHeader(rival: race.rival),
              const SizedBox(height: 4),
              Text(
                l10n.racePauseSubtitle(l10n.raceRivalName(race.rival)),
                textAlign: TextAlign.center,
                style: AppTextStyleTokens.bodySmall.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColorTokens.textSecondary,
                ),
              ),
            ] else
              Text(
                l10n.levelWithTier(
                  widget.level!,
                  l10n.tierName(widget.tier!.id),
                ),
                textAlign: TextAlign.center,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 15,
                  height: 1,
                  color: AppColorTokens.textMuted,
                ),
              ),
            const SizedBox(height: 12),
            if (versus)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColorTokens.surfaceWhite,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: AppColorTokens.divider, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: toggles,
                ),
              )
            else
              toggles,
            SizedBox(height: versus ? 14 : 20),
            TactileButton(
              label: l10n.resume,
              size: TactileButtonSize.medium,
              variant: versus
                  ? TactileButtonVariant.versus
                  : TactileButtonVariant.primary,
              onPressed: widget.onResume,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: tiles[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A versus-toned ribbon pill: `gradient.versus`, edge `versusEdge`.
  static RibbonTitle _versusRibbon(String title) => RibbonTitle(
    title,
    gradient: AppGradientTokens.versus,
    edgeColor: AppColorTokens.versusEdge,
  );

  /// Frame 9.7b: the one confirmation before a race is left. Keep racing
  /// (the safe default, first in reading order) resumes; Leave race is the
  /// secondary button, never a danger one, and leaves with no reward and no
  /// penalty (spec-prop §7.7 "Save").
  Widget _leaveConfirm(BuildContext context, RacePauseInfo race) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(race.rival);
    return OverlayEntrance(
      key: const ValueKey('raceLeaveConfirm'),
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          ModalPlacement(
            cardTop: PauseDialog.leaveCardTop,
            side: PauseDialog.leaveSide,
            clearance: RibbonTitle.overhang,
            child: content,
          ),
        ],
      ),
      child: ModalCard(
        ribbon: _versusRibbon(l10n.raceLeaveTitle),
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Semantics(
              label: l10n.raceRivalSemantics(name),
              container: true,
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RivalPortrait(number: race.rival, size: 88, emphasis: true),
                  const SizedBox(height: 12),
                  ComputerTag.responsive(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.raceLeaveBody,
              textAlign: TextAlign.center,
              style: context.scriptStyle(
                AppTextStyles.bodySmall.copyWith(fontSize: 16),
                role: ScriptTextRole.body,
              ),
            ),
            const SizedBox(height: 18),
            TactileButton(
              label: l10n.raceLeaveKeep,
              variant: TactileButtonVariant.versus,
              onPressed: widget.onResume,
            ),
            const SizedBox(height: 14),
            TactileButton(
              label: l10n.raceQuit,
              variant: TactileButtonVariant.secondary,
              onPressed: widget.onLeaveRace,
            ),
          ],
        ),
      ),
    );
  }
}

/// Frame 9.7's header: the rival's 30 dp portrait, "vs Computer · Pebble"
/// (Fredoka 700 17) and [ComputerTag], read as one line naming the computer.
class _RaceHeader extends StatelessWidget {
  const _RaceHeader({required this.rival});

  final int rival;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final header = l10n.racePauseHeader(l10n.raceRivalName(rival));
    final style = AppTextStyleTokens.cardTitle.copyWith(
      fontSize: 17,
      color: AppColorTokens.textPrimary,
    );
    return Semantics(
      label: header,
      header: true,
      container: true,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RivalPortrait(number: rival, size: 30),
              const SizedBox(width: 10),
              Text(header, style: style, maxLines: 1, softWrap: false),
              const SizedBox(width: 8),
              // The tag falls to its glyph when the full row would scale
              // below the readability floor (textFit short form); the
              // header ("vs Computer · {rival}") keeps the word (D271).
              ComputerTag(
                glyphOnly: ComputerTag.glyphOnlyForRow(
                  context,
                  lead: header,
                  leadStyle: style,
                  gap: 8 + 30 + 10,
                  maxWidth: constraints.maxWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A setting with its switch (NestyOverlay: 24 px `#8A5B3A` glyph, 17/700
/// Nunito label, 54×30 toggle, 11 px vertical padding).
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.library,
    this.versus = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final FxLibrary? library;

  /// The race pause's rows (frame 9.7, NestyMeta.dc.html:76): 50 dp tall,
  /// glyph `#6E4526`, Fredoka 600 17/1 label.
  final bool versus;

  static const double _rowPadding = 11;

  /// `NestyToggle.size`'s height.
  static const double _toggleHeight = 30;

  /// `TouchTarget`'s 48 dp minimum.
  static const double _touchHeight = 48;

  @override
  Widget build(BuildContext context) {
    final hasFile = library?[FxId.uiToggle];
    final labelStyle = versus
        ? AppTextStyleTokens.cardTitle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1,
            color: AppColorTokens.textPrimary,
          )
        : AppTextStyles.row.copyWith(color: AppColorTokens.textPrimary);
    final row = Padding(
      // NestyOverlay: 11 above and below the 30 px toggle. Its 48 dp touch
      // target already takes (48 − 30) / 2 of each.
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        // The race row is a flat 50 dp: the 48 dp touch target fills it.
        vertical: versus ? 0 : _rowPadding - (_touchHeight - _toggleHeight) / 2,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: 24,
              color: versus
                  ? AppColorTokens.iconBrown
                  : AppColorTokens.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ExcludeSemantics(child: Text(label, style: labelStyle)),
          ),
          const SizedBox(width: 8),
          NestyToggle(
            value: value,
            onChanged: onChanged,
            semanticLabel: label,
            // Without the file, NestyToggle draws its static look.
            lottie: hasFile == null
                ? null
                : LottieToggle(value: value, library: library),
          ),
        ],
      ),
    );
    return versus ? SizedBox(height: 50, child: Center(child: row)) : row;
  }
}

/// `ui_toggle` driven by [value]: rests on `off` (0) or `on` (11), and
/// plays `on` or `off` when it flips (180 ms; half under reduced motion).
class LottieToggle extends StatefulWidget {
  const LottieToggle({required this.value, this.library, super.key});

  final bool value;
  final FxLibrary? library;

  /// The file's `on` segment ends here: the "on" rest frame.
  static const double onFrame = 11;

  @override
  State<LottieToggle> createState() => _LottieToggleState();
}

class _LottieToggleState extends State<LottieToggle> {
  final LottieFxController _controller = LottieFxController(FxId.uiToggle);

  @override
  void initState() {
    super.initState();
    _controller.rest(widget.value ? LottieToggle.onFrame : 0);
  }

  @override
  void didUpdateWidget(LottieToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.playMarker(widget.value ? 'on' : 'off');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LottieFxView(
    id: FxId.uiToggle,
    controller: _controller,
    library: widget.library,
    fit: BoxFit.fill,
  );
}

/// The rows' divider: NestyOverlay's `1px dashed rgba(110,60,25,.2)`, or in
/// a race (frame 9.7) the solid `1.5px #F0DFC4` (token `divider`).
class _Divider extends StatelessWidget {
  const _Divider({required this.versus});

  final bool versus;

  @override
  Widget build(BuildContext context) => versus
      ? const SizedBox(
          height: 1.5,
          width: double.infinity,
          child: ColoredBox(color: AppColorTokens.divider),
        )
      : const SizedBox(
          height: 1,
          width: double.infinity,
          child: CustomPaint(painter: _DashPainter()),
        );
}

final class _DashPainter extends CustomPainter {
  const _DashPainter();

  static final Paint _paint = Paint()
    ..color = const Color(0x336E3C19)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 3.0;
    for (var x = 0.0; x < size.width; x += dash * 2) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset((x + dash).clamp(0, size.width), 0.5),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

/// Restart, Home and Settings (NestyOverlay: 62 tall, radius 18, white
/// with a 5 px edge, 24 px glyph over a 14/600 Fredoka label in `#6E4526`).
class _PauseTile extends StatelessWidget {
  const _PauseTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.disabledText
        : AppColors.iconBrown;
    return TactileSurface(
      style: SurfaceStyles.row,
      radius: const BorderRadius.all(Radius.circular(18)),
      onPressed: onPressed,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: AppTextStyleTokens.boosterLabel.copyWith(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
