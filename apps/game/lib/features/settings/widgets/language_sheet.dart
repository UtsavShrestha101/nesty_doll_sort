import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// One of the 9 launch languages (frame 8.2): [code] is the locale
/// `DatabaseService`/`LanguageCubit` store, [autonym] is how the language
/// names itself — data, not ARB, because it reads the same in every locale
/// (m3-design §10.2).
@immutable
class LaunchLanguage {
  const LaunchLanguage(this.code, this.autonym);

  final String code;
  final String autonym;
}

/// The 9 launch languages, in frame 8.2's order. English is first (and, for
/// now, the only selectable one).
const launchLanguages = [
  LaunchLanguage('en', 'English'),
  LaunchLanguage('es', 'Español'),
  LaunchLanguage('pt_BR', 'Português (Brasil)'),
  LaunchLanguage('id', 'Bahasa Indonesia'),
  LaunchLanguage('hi', 'हिन्दी'),
  LaunchLanguage('de', 'Deutsch'),
  LaunchLanguage('fr', 'Français'),
  LaunchLanguage('tr', 'Türkçe'),
  LaunchLanguage('ja', '日本語'),
];

/// Frame 8.2's language sheet (`NestySheet`): each row is the autonym, its
/// name in the UI language (ARB `languageName`, hidden on the selected row,
/// which the frame's own data does too) and a selection ring; a language
/// without an ARB catalog is disabled (`TODO(M7)`) with `languageComingSoon`.
/// "Done", the orange text action on the title's row, closes.
///
/// The autonym is never cut: when a row has no room for it and the
/// trailing name on one line (1.3× text, a small phone), the trailing text
/// moves under it.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({
    required this.selectedCode,
    required this.onSelect,
    super.key,
  });

  final String selectedCode;
  final ValueChanged<String> onSelect;

  /// Opens the sheet over [context]; [onSelect] fires for the tapped
  /// language before it closes.
  static Future<void> show(
    BuildContext context, {
    required String selectedCode,
    required ValueChanged<String> onSelect,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0x00000000),
    barrierColor: AppColorTokens.scrim,
    builder: (sheetContext) => LanguageSheet(
      selectedCode: selectedCode,
      onSelect: (code) {
        onSelect(code);
        Navigator.of(sheetContext).pop();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: NestySheet(
        title: l10n.languageSheetTitle,
        titleAction: _DoneAction(
          label: l10n.languageSheetDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
        gap: 0,
        children: [
          for (final language in launchLanguages)
            _LanguageRow(
              language: language,
              selected: language.code == selectedCode,
              // Only English has an ARB catalog today (Q ...; TODO(M7)).
              enabled: language.code == 'en',
              onTap: () => onSelect(language.code),
            ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final LaunchLanguage language;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  static const _transparent = SurfaceStyle(
    color: Color(0x00000000),
    shadows: [],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Opacity(
      opacity: enabled || selected ? 1 : 0.55,
      child: TactileSurface(
        style: _transparent,
        radius: BorderRadius.zero,
        onPressed: enabled ? onTap : null,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        alignment: AlignmentDirectional.centerStart,
        semanticLabel: selected
            ? language.autonym
            : l10n.languageRowSemantics(
                language.autonym,
                enabled
                    ? l10n.languageName(language.code)
                    : l10n.languageComingSoon,
              ),
        excludeChildSemantics: true,
        child: Row(
          children: [
            // The autonym takes its whole width first (wrapping only if it
            // alone is wider than the row); the trailing name shares its
            // line when it fits, else runs under it. Never an ellipsis.
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    language.autonym,
                    style: AppTextStyleTokens.row.copyWith(
                      fontSize: 16,
                      height: 1.2,
                      color: AppColorTokens.textPrimary,
                    ),
                  ),
                  if (!selected)
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.languageName(language.code),
                          style: AppTextStyleTokens.caption.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColorTokens.textMuted,
                          ),
                        ),
                        if (!enabled)
                          Text(
                            l10n.languageComingSoon,
                            style: AppTextStyleTokens.caption.copyWith(
                              fontSize: 11,
                              color: AppColorTokens.textMuted,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _SelectionRing(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Frame 8.2's "Done": an orange 16/700 text action on the title's row,
/// inside a 48 dp tap target (spec §16).
class _DoneAction extends StatelessWidget {
  const _DoneAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  void _handleTap(BuildContext context) {
    TactileFeedback.of(context)?.activate();
    onPressed();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    onTap: () => _handleTap(context),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: () => _handleTap(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Align(
          widthFactor: 1,
          heightFactor: 1,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            label,
            style: AppTextStyleTokens.button.copyWith(
              fontSize: 16,
              height: 1,
              color: AppColorTokens.primaryEdge,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The frame's 24×24 ring: an outline when unselected, filled with a check
/// on the selected row.
class _SelectionRing extends StatelessWidget {
  const _SelectionRing({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? AppColorTokens.primary : null,
      border: selected
          ? null
          : Border.all(color: AppColorTokens.surfaceEdge, width: 2),
    ),
    child: selected
        ? const Icon(NestyIcons.check, size: 17, color: Color(0xFFFFFFFF))
        : null,
  );
}
