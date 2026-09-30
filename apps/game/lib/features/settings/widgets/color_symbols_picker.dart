import 'dart:async';

import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

/// Frame 8.1's "Color symbols" (NestyMenus `isSettings`; spec §16's colour
/// assist): the row's visibility icon and label, then one card per
/// [SymbolsMode], each a Leaf doll preview drawn in the equipped skin with
/// that mode's symbols (Large bakes the cream disc and ink ring), so the
/// player sees what the setting does. The selected card wears the primary
/// ring and an orange label.
///
/// Reads [SkinService] and [FxLibrary] from the tree
/// (`SettingsPage.wrappedRoute`). The two previews are prepared once
/// (`SkinService.prepareShowcase`) and released with the picker; a skin
/// that can't be prepared draws the placeholder doll (rule 3).
class ColorSymbolsPicker extends StatefulWidget {
  const ColorSymbolsPicker({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final SymbolsMode mode;

  /// A card other than the selected one was tapped.
  final ValueChanged<SymbolsMode> onChanged;

  /// The frame's card padding (`12px 16px 14px`), for the enclosing
  /// `SettingsSection`.
  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(16, 12, 16, 14);

  /// The frame's preview doll (`doll-leaf.svg`).
  static const DollColor previewColor = DollColor.green;

  @override
  State<ColorSymbolsPicker> createState() => _ColorSymbolsPickerState();
}

class _ColorSymbolsPickerState extends State<ColorSymbolsPicker> {
  /// Each mode's preview art once prepared (null inside: it couldn't be).
  final Map<SymbolsMode, LevelSkin?> _art = {};
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    final skins = context.read<SkinService>();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    for (final mode in SymbolsMode.values) {
      unawaited(
        skins
            .prepareShowcase(
              colors: const [ColorSymbolsPicker.previewColor],
              devicePixelRatio: dpr,
              symbols: mode.dollSymbols,
            )
            .then((art) {
              if (!mounted) {
                art?.dispose();
                return;
              }
              setState(() => _art[mode] = art);
            }),
      );
    }
  }

  @override
  void dispose() {
    for (final art in _art.values) {
      art?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: SizedBox.square(
                dimension: SettingsTile.size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SettingsTile.wood.face,
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                  ),
                  child: const Icon(
                    NestyIcons.visibility,
                    size: 24,
                    color: AppColorTokens.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SettingsTile.gap),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.settingColorSymbols,
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    fontSize: 19,
                    height: 1.15,
                    color: AppColorTokens.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final mode in SymbolsMode.values) ...[
              if (mode != SymbolsMode.values.first) const SizedBox(width: 10),
              Expanded(
                child: _SymbolsCard(
                  label: switch (mode) {
                    SymbolsMode.subtle => l10n.symbolsSubtle,
                    SymbolsMode.large => l10n.symbolsLarge,
                  },
                  symbols: mode.dollSymbols,
                  ready: _art.containsKey(mode),
                  art: _art[mode],
                  selected: mode == widget.mode,
                  onTap: () => widget.onChanged(mode),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// One frame 8.1 card: the 40×60 doll preview over its label.
class _SymbolsCard extends StatelessWidget {
  const _SymbolsCard({
    required this.label,
    required this.symbols,
    required this.ready,
    required this.art,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final DollSymbols symbols;

  /// The preview's art request has finished (with [art] or without).
  final bool ready;
  final LevelSkin? art;
  final bool selected;
  final VoidCallback onTap;

  /// tokens.json `settings.colorSymbolCards` (F.3): selected is a #FFF1E4
  /// face inset with a 3 px orange ring, idle #FFFDF7 with a 2 px tan one.
  static const _selectedStyle = SurfaceStyle(
    color: SettingsTokens.colorSymbolCardsSelectedFace,
    shadows: SettingsTokens.colorSymbolCardsSelectedRing,
  );

  static const _style = SurfaceStyle(
    color: SettingsTokens.colorSymbolCardsIdleFace,
    shadows: SettingsTokens.colorSymbolCardsIdleRing,
  );

  /// The preview doll (F.3: 56 dp tall; the 2:3 doll makes it 37 wide).
  static const double dollHeight = 56;

  void _handleTap(BuildContext context) {
    if (selected) return;
    TactileFeedback.of(context)?.activate();
    onTap();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    label: label,
    excludeSemantics: true,
    onTap: () => _handleTap(context),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: () => _handleTap(context),
      child: NestySurface(
        style: selected ? _selectedStyle : _style,
        radius: const BorderRadius.all(
          Radius.circular(SettingsTokens.colorSymbolCardsRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dollHeight * 2 / 3,
              height: dollHeight,
              child: ready
                  ? SkinDollRow(
                      colors: const [ColorSymbolsPicker.previewColor],
                      heights: const [_SymbolsCard.dollHeight],
                      skin: art,
                      symbols: symbols,
                      library: context.read<FxLibrary>(),
                    )
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTextStyleTokens.buttonSmall.copyWith(
                fontSize: 16,
                height: 1,
                color: selected
                    ? AppColorTokens.primaryEdge
                    : AppColorTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
