import 'dart:async';

import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/services/links/app_links.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';
import 'package:nesty_game/features/settings/widgets/color_symbols_picker.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';

/// Settings (spec §10.2 #13, frames 8.1–8.2; docs/plans/m3-design.md
/// §10.2), opened from Home's gear and Pause's Settings tile: header
/// "Settings" with a close button, the Sound/Music/Haptics toggles and
/// the Color symbols cards (both write only `DatabaseService`), Language (opens the
/// 8.2 sheet), Restore Purchases and Privacy choices (disabled, `TODO(M6)`),
/// Privacy Policy and Support (each hidden while its `AppLinks` value is
/// empty), and the footer.
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
      body: SafeArea(
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        SettingsSection(
          children: [
            SettingsToggleRow(
              icon: NestyIcons.volumeUp,
              label: l10n.settingSound,
              value: state.soundEnabled,
              onChanged: (v) => unawaited(cubit.setSoundEnabled(v)),
            ),
            SettingsToggleRow(
              icon: NestyIcons.musicNote,
              label: l10n.settingMusic,
              value: state.musicEnabled,
              onChanged: (v) => unawaited(cubit.setMusicEnabled(v)),
            ),
            SettingsToggleRow(
              icon: NestyIcons.vibration,
              label: l10n.settingHaptics,
              value: state.hapticsEnabled,
              onChanged: (v) => unawaited(cubit.setHapticsEnabled(v)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          padding: ColorSymbolsPicker.sectionPadding,
          children: [
            ColorSymbolsPicker(
              mode: state.symbolsMode,
              onChanged: (mode) => unawaited(cubit.setSymbolsMode(mode)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          children: [
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, language) => SettingsRow(
                icon: NestyIcons.translate,
                label: l10n.settingLanguage,
                value: language.currentLanguageCode == 'en'
                    ? 'English'
                    : l10n.languageName(language.currentLanguageCode),
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
              onTap: null,
            ),
            // TODO(M6): Privacy choices (the consent form's "Manage
            // options", spec §9.3).
            SettingsRow(
              icon: NestyIcons.adminPanelSettings,
              label: l10n.settingPrivacyChoices,
              onTap: null,
            ),
            if (AppLinks.privacyPolicyUrl.isNotEmpty)
              SettingsRow(
                icon: NestyIcons.shield,
                label: l10n.settingPrivacyPolicy,
                onTap: () =>
                    unawaited(links.openUrl(AppLinks.privacyPolicyUrl)),
              ),
            if (AppLinks.supportEmail.isNotEmpty)
              SettingsRow(
                icon: NestyIcons.mail,
                label: l10n.settingSupport,
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
}
