import 'dart:math' as math;
import 'dart:ui' show LocaleStringAttribute;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show AttributedString;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
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

/// The 9 launch languages, in frame 8.2's order. English is first.
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

/// Frame 8.2's language sheet (`layout.languageSheet`, frames 8.2 and 8.2b):
/// 56 dp radio rows, the autonym on the left in its script's face, its name
/// in the UI language on the right (none on the English row), a 24 dp ring.
///
/// A tap applies the language at once, with no confirmation: [onSelect]
/// fires, the app redraws in the new language, and the sheet stays open
/// (it redraws too). "Done" closes it. The sheet reads the chosen language
/// from `LanguageCubit` when the app provides one, so the radio follows a
/// change (and a rolled-back one); without one it follows its own taps.
///
/// The sheet stops 72 dp under the safe top; the rows scroll under the
/// pinned title, with a 16 dp fade at the bottom while more are below. A
/// row is enabled when its language has an ARB catalog
/// (`AppLocaleResolver.app.supports`).
///
/// The autonym is never cut: when a row has no room for it and the
/// trailing name on one line (1.3× text, a small phone), the trailing text
/// moves under it.
class LanguageSheet extends StatefulWidget {
  const LanguageSheet({
    required this.selectedCode,
    required this.onSelect,
    this.resolver,
    this.safeTop,
    super.key,
  });

  /// The language shown as chosen when no `LanguageCubit` is in scope.
  final String selectedCode;
  final ValueChanged<String> onSelect;

  /// Which languages have a catalog (a row of one that has none is
  /// disabled); the app's own by default, a test's to stand in for the
  /// catalogs that aren't in yet.
  @visibleForTesting
  final AppLocaleResolver? resolver;

  /// The top safe area of the screen under the sheet. The modal route
  /// strips the top padding from its own `MediaQuery`, so [show] reads it
  /// from the caller's.
  final double? safeTop;

  /// Opens the sheet over [context]; [onSelect] fires for each tapped
  /// language, and the sheet stays open.
  static Future<void> show(
    BuildContext context, {
    required String selectedCode,
    required ValueChanged<String> onSelect,
  }) {
    final safeTop = MediaQuery.viewPaddingOf(context).top;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      barrierColor: AppColorTokens.scrim,
      builder: (sheetContext) => LanguageSheet(
        selectedCode: selectedCode,
        onSelect: onSelect,
        safeTop: safeTop,
      ),
    );
  }

  /// frame 8.2: the sheet stops this far under the safe top.
  static const double topGap = 72;

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  late String _tapped = widget.selectedCode;

  void _select(String code) {
    setState(() => _tapped = code);
    widget.onSelect(code);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubitOrNull(context);
    if (cubit == null) return _sheet(context, _tapped);
    return BlocBuilder<LanguageCubit, LanguageState>(
      bloc: cubit,
      buildWhen: (a, b) => a.currentLanguageCode != b.currentLanguageCode,
      builder: (context, state) => _sheet(context, state.currentLanguageCode),
    );
  }

  static LanguageCubit? _cubitOrNull(BuildContext context) {
    try {
      return context.read<LanguageCubit>();
    } on Object {
      return null;
    }
  }

  Widget _sheet(BuildContext context, String selectedCode) {
    final l10n = context.localizations;
    final media = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            media.size.height -
            (widget.safeTop ?? media.viewPadding.top) -
            LanguageSheet.topGap,
      ),
      child: NestySheet(
        title: l10n.languageSheetTitle,
        scrollFade: AppColorTokens.surfaceSunk,
        titleAction: _DoneAction(
          label: l10n.languageSheetDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
        gap: 0,
        children: [
          for (var i = 0; i < launchLanguages.length; i++) ...[
            if (i > 0) const _Dashes(),
            _LanguageRow(
              language: launchLanguages[i],
              selected: launchLanguages[i].code == selectedCode,
              enabled: (widget.resolver ?? AppLocaleResolver.app).supports(
                launchLanguages[i].code,
              ),
              onTap: () => _select(launchLanguages[i].code),
            ),
          ],
        ],
      ),
    );
  }
}

/// The frame's dashed divider between rows.
class _Dashes extends StatelessWidget {
  const _Dashes();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 1, child: CustomPaint(painter: _DashPainter()));
}

final class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColorTokens.rowDash
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + 4, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
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

  /// The autonym's style (layout.languageSheet): Nunito 700 16. The script
  /// faces come through the fallback (Baloo 2 draws Devanagari at 600,
  /// M PLUS Rounded 1c Japanese at 700); Japanese is 15 (the script's
  /// size factor).
  TextStyle get _nativeStyle => AppTextStyleTokens.row.copyWith(
    fontSize: language.code == 'ja' ? 16 * AppFontTokens.jpanSizeFactor : 16,
    height: 1.2,
    color: AppColorTokens.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.languageName(language.code);
    // The English row names no English: the autonym is already that. Nor
    // does a row whose name in this language is its autonym ("Deutsch" in
    // German, 日本語 in Japanese).
    final showName = language.code != 'en' && name != language.autonym;
    final label = selected || !showName
        ? language.autonym
        : l10n.languageRowSemantics(language.autonym, name);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      child: TactileSurface(
        style: _transparent,
        radius: BorderRadius.zero,
        onPressed: enabled ? onTap : null,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: AlignmentDirectional.centerStart,
        // A radio of one group; the ring is only drawn, the row says it.
        radioChecked: selected,
        // The autonym is read in its own language where the screen reader
        // has the voice (Flutter's locale attribute).
        semanticAttributedLabel: AttributedString(
          label,
          attributes: [
            LocaleStringAttribute(
              locale: _localeOf(language.code),
              range: TextRange(start: 0, end: language.autonym.length),
            ),
          ],
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
                  Text(language.autonym, style: _nativeStyle),
                  if (showName)
                    Text(
                      name,
                      style: AppTextStyleTokens.caption.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColorTokens.textMuted,
                      ),
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

  static const double _rowHeight = 56;

  static Locale _localeOf(String code) {
    final parts = code.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
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
