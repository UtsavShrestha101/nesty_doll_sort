import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';

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

/// Frame 3.9, Pause (spec §10.2 #14): the "Paused" card over the scrim,
/// "Level 56 · Hard", the Sound, Music and Haptics toggles (so players don't
/// leave the level to change them), Resume, then Restart, Home and
/// Settings (pushes `SettingsRoute` over the level, which stays paused
/// underneath, m3-design §10.1).
///
/// The toggles are `ui_toggle` (`on` 0–11, `off` 11–22; LOTTIE.md "Settings
/// / Pause toggle"), with the static toggle when the file is missing.
class PauseDialog extends StatelessWidget {
  const PauseDialog({
    required this.level,
    required this.tier,
    required this.settings,
    required this.onSoundChanged,
    required this.onMusicChanged,
    required this.onHapticsChanged,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    required this.onSettings,
    this.library,
    super.key,
  });

  final int level;
  final Tier tier;
  final PauseSettings settings;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  /// Pushes `SettingsRoute` over the level, which stays paused underneath
  /// (m3-design §10.1).
  final VoidCallback onSettings;

  /// The loaded compositions: `ui_toggle` plays when it has it, else the
  /// toggles draw their static look (rule 3).
  final FxLibrary? library;

  /// NestyOverlay: the card sits 32 from each side, its top at 190 on a
  /// 59 safe area.
  static const double side = 32;
  static const double cardTop = 190 - 59;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          // Tapping outside doesn't resume: Resume is the one way back.
          Scrim(opacity: progress),
          ModalPlacement(
            cardTop: cardTop,
            side: side,
            clearance: RibbonTitle.overhang,
            child: content,
          ),
        ],
      ),
      child: ModalCard(
        title: l10n.pauseTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.levelWithTier(level, l10n.tierName(tier.id)),
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 15,
                height: 1,
                color: AppColorTokens.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              icon: NestyIcons.volumeUp,
              label: l10n.settingSound,
              value: settings.sound,
              onChanged: onSoundChanged,
              library: library,
            ),
            const _DashedDivider(),
            _ToggleRow(
              icon: NestyIcons.musicNote,
              label: l10n.settingMusic,
              value: settings.music,
              onChanged: onMusicChanged,
              library: library,
            ),
            const _DashedDivider(),
            _ToggleRow(
              icon: NestyIcons.vibration,
              label: l10n.settingHaptics,
              value: settings.haptics,
              onChanged: onHapticsChanged,
              library: library,
            ),
            const _DashedDivider(),
            const SizedBox(height: 20),
            TactileButton(
              label: l10n.resume,
              size: TactileButtonSize.medium,
              onPressed: onResume,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PauseTile(
                    icon: NestyIcons.restartAlt,
                    label: l10n.restart,
                    onPressed: onRestart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PauseTile(
                    icon: NestyIcons.home,
                    label: l10n.home,
                    onPressed: onHome,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PauseTile(
                    icon: NestyIcons.settings,
                    label: l10n.settings,
                    onPressed: onSettings,
                  ),
                ),
              ],
            ),
          ],
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
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final FxLibrary? library;

  static const double _rowPadding = 11;

  /// `NestyToggle.size`'s height.
  static const double _toggleHeight = 30;

  /// `TouchTarget`'s 48 dp minimum.
  static const double _touchHeight = 48;

  @override
  Widget build(BuildContext context) {
    final hasFile = library?[FxId.uiToggle];
    return Padding(
      // NestyOverlay: 11 above and below the 30 px toggle. Its 48 dp touch
      // target already takes (48 − 30) / 2 of each.
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: _rowPadding - (_touchHeight - _toggleHeight) / 2,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 24, color: AppColorTokens.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ExcludeSemantics(
              child: Text(
                label,
                style: AppTextStyles.row.copyWith(
                  color: AppColorTokens.textPrimary,
                ),
              ),
            ),
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

/// NestyOverlay's `1px dashed rgba(110,60,25,.2)` row divider.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
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
