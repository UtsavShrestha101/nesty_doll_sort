import 'dart:async';

import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/services/links/app_links.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';
import 'package:nesty_game/features/daily/widgets/reminder_time_picker.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';
import 'package:nesty_game/features/settings/widgets/color_symbols_picker.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';

/// Settings (spec §10.2 #13, frames 8.1–8.2; docs/plans/m3-design.md
/// §10.2), opened from Home's gear and Pause's Settings tile: header
/// "Settings" with a close button, the Sound/Music/Haptics toggles, the
/// Daily reminder (a toggle, its Time row, or its blocked state with "Open
/// phone settings"), Relaxed mode, Reduce motion's inline Off · On · System
/// and the Color symbols cards (all write only `DatabaseService` or
/// `DailyReminder`), Language (opens the 8.2 sheet), Restore Purchases and
/// Privacy choices (disabled, `TODO(M6)`), Privacy Policy and Support (each
/// hidden while its `AppLinks` value is empty), and the footer. Frames
/// 10.2e and 10.2f restyle every row on an icon tile.
@RoutePage()
class SettingsPage extends StatelessWidget implements AutoRouteWrapper {
  const SettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: get<LinkLauncher>()),
      // The Color symbols cards' doll previews (frame 8.1).
      RepositoryProvider.value(value: get<SkinService>()),
      RepositoryProvider.value(value: get<FxLibrary>()),
    ],
    child: BlocProvider(
      create: (_) => get<SettingsCubit>()..load(),
      child: this,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final links = context.read<LinkLauncher>();
    return Scaffold(
      body: CreamPage(
        child: SafeArea(
          // The list runs to the bottom edge; its padding clears the home
          // indicator (F-SAFE).
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ScreenHeader(
                  title: context.localizations.settings,
                  onClose: () => context.router.maybePop(),
                ),
              ),
              Expanded(
                child: BlocBuilder<SettingsCubit, AsyncValue<SettingsState>>(
                  builder: (context, state) {
                    final data = state.data;
                    if (data == null) return const SizedBox.shrink();
                    return _SettingsBody(state: data, links: links);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.state, required this.links});

  final SettingsState state;
  final LinkLauncher links;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final cubit = context.read<SettingsCubit>();
    final reminder = state.reminder;
    final blocked = reminder.blocked;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        32 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        SettingsSection(
          tiled: true,
          children: [
            SettingsToggleRow(
              icon: NestyIcons.volumeUp,
              label: l10n.settingSound,
              tile: SettingsTile.wood,
              value: state.soundEnabled,
              onChanged: (v) => unawaited(cubit.setSoundEnabled(v)),
            ),
            SettingsToggleRow(
              icon: NestyIcons.musicNote,
              label: l10n.settingMusic,
              tile: SettingsTile.wood,
              value: state.musicEnabled,
              onChanged: (v) => unawaited(cubit.setMusicEnabled(v)),
            ),
            SettingsToggleRow(
              icon: NestyIcons.vibration,
              label: l10n.settingHaptics,
              tile: SettingsTile.wood,
              value: state.hapticsEnabled,
              onChanged: (v) => unawaited(cubit.setHapticsEnabled(v)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SettingsSection(
          tiled: true,
          children: [
            if (reminder.available)
              SettingsToggleRow(
                icon: blocked ? IconUses.reminderOff : IconUses.reminder,
                label: l10n.settingReminder,
                // The tile follows the state (`iconTiles`): amber while it is
                // on, the wood tint when it is off (10.2h) and the muted
                // brown glyph when the phone blocks it (10.2f).
                tile: blocked
                    ? SettingsTile.reminderOff
                    : reminder.settings.on
                    ? SettingsTile.reminder
                    : SettingsTile.wood,
                // Blocked reads as off (frame 10.2f): the reminder is still on
                // in the player's own settings (D190), the phone just says no.
                value: reminder.settings.on && !blocked,
                // Blocked: the toggle is only drawn, a tap goes where the
                // fix is (ui-spec-menus §7.2).
                onChanged: (v) => unawaited(
                  blocked ? cubit.openPhoneSettings() : cubit.setReminderOn(v),
                ),
                subtitle: blocked ? l10n.settingReminderBlocked : null,
                // Two ways out, 18 dp apart, wrapping under each other when
                // narrow: the phone's settings, or Turn off, which stops the
                // reminder in the app (the Off row, 10.2h; Q158).
                footer: blocked
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: SettingsRowsTokens.blockedActionsGap,
                        children: [
                          SettingsPillButton(
                            icon: IconUses.openSettings,
                            label: l10n.settingOpenPhoneSettings,
                            onPressed: () =>
                                unawaited(cubit.openPhoneSettings()),
                          ),
                          TextLink(
                            inline: true,
                            label: l10n.settingReminderTurnOff,
                            onPressed: () =>
                                unawaited(cubit.setReminderOn(false)),
                          ),
                        ],
                      )
                    : null,
              ),
            if (reminder.available && reminder.settings.on && !blocked)
              SettingsRow(
                icon: IconUses.reminderTime,
                label: l10n.settingReminderTime,
                tile: SettingsTile.reminder,
                value: context.formatClock(
                  TimeOfDay(
                    hour: reminder.settings.hour,
                    minute: reminder.settings.minute,
                  ),
                ),
                onTap: () =>
                    unawaited(_pickReminderTime(context, cubit, state)),
              ),
            SettingsToggleRow(
              icon: IconUses.relaxedMode,
              label: l10n.settingRelaxedMode,
              tile: SettingsTile.relaxed,
              value: state.relaxedMode,
              onChanged: (v) => unawaited(cubit.setRelaxedMode(v)),
              subtitle: l10n.settingRelaxedModeSubtitle,
            ),
            SettingsSegmentedRow<ReduceMotionMode>(
              icon: IconUses.reduceMotion,
              label: l10n.settingReduceMotion,
              tile: SettingsTile.motion,
              selected: state.reduceMotion,
              onChanged: (mode) => unawaited(cubit.setReduceMotion(mode)),
              segments: [
                SettingsSegment(
                  value: ReduceMotionMode.off,
                  label: l10n.reduceMotionOff,
                ),
                SettingsSegment(
                  value: ReduceMotionMode.on,
                  label: l10n.reduceMotionOn,
                ),
                SettingsSegment(
                  value: ReduceMotionMode.system,
                  label: l10n.reduceMotionSystem,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        SettingsSection(
          padding: ColorSymbolsPicker.sectionPadding,
          children: [
            ColorSymbolsPicker(
              mode: state.symbolsMode,
              onChanged: (mode) => unawaited(cubit.setSymbolsMode(mode)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SettingsSection(
          tiled: true,
          children: [
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, language) => SettingsRow(
                icon: NestyIcons.translate,
                label: l10n.settingLanguage,
                tile: SettingsTile.wood,
                // The language's own name (data: it reads the same in every
                // UI language), l10n.md §1.2.
                value: launchLanguages
                    .firstWhere(
                      (l) => l.code == language.currentLanguageCode,
                      orElse: () => launchLanguages.first,
                    )
                    .autonym,
                onTap: () => unawaited(
                  LanguageSheet.show(
                    context,
                    selectedCode: language.currentLanguageCode,
                    onSelect: (code) => unawaited(
                      context.read<LanguageCubit>().changeLanguage(code),
                    ),
                  ),
                ),
              ),
            ),
            // TODO(M6): Restore Purchases (spec §9.2).
            SettingsRow(
              icon: NestyIcons.restore,
              label: l10n.settingRestorePurchases,
              tile: SettingsTile.wood,
              onTap: null,
            ),
            // TODO(M6): Privacy choices (the consent form's "Manage
            // options", spec §9.3).
            SettingsRow(
              icon: NestyIcons.adminPanelSettings,
              label: l10n.settingPrivacyChoices,
              tile: SettingsTile.wood,
              onTap: null,
            ),
            if (AppLinks.privacyPolicyUrl.isNotEmpty)
              SettingsRow(
                icon: NestyIcons.shield,
                label: l10n.settingPrivacyPolicy,
                tile: SettingsTile.wood,
                onTap: () =>
                    unawaited(links.openUrl(AppLinks.privacyPolicyUrl)),
              ),
            if (AppLinks.supportEmail.isNotEmpty)
              SettingsRow(
                icon: NestyIcons.mail,
                label: l10n.settingSupport,
                tile: SettingsTile.wood,
                value: l10n.settingSupportValue,
                onTap: () => unawaited(links.email(AppLinks.supportEmail)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.settingsFooter(state.version, state.buildNumber, state.playerId),
          textAlign: TextAlign.center,
          style: AppTextStyleTokens.caption.copyWith(
            fontSize: 12,
            color: AppColorTokens.textMuted,
          ),
        ),
      ],
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState state,
  ) async {
    final picked = await showReminderTimePicker(
      context,
      initial: TimeOfDay(
        hour: state.reminder.settings.hour,
        minute: state.reminder.settings.minute,
      ),
    );
    if (picked == null) return;
    final stored = await cubit.setReminderTime(
      hour: picked.hour,
      minute: picked.minute,
    );
    if (!stored || !context.mounted) return;
    // The 10.2c toast confirms the new time (ui-spec-menus §7.2).
    NestyToast.show(
      context,
      tone: NestyBannerTone.success,
      icon: IconUses.reminder,
      title: context.localizations.reminderOfferDone(
        context.formatClock(picked),
      ),
    );
  }
}
