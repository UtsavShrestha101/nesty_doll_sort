import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// The `ui_spinner` loop (LOTTIE.md: a loading state) at [size], shown
/// while a doll preview's skin art is prepared, so a card never flashes
/// the placeholder dolls first; a plain progress ring stands in when the
/// Lottie file can't load.
class FxSpinner extends StatelessWidget {
  const FxSpinner({this.size = 32, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const LottieFxView(id: FxId.uiSpinner, fallback: _FallbackSpinner()),
  );
}

class _FallbackSpinner extends StatelessWidget {
  const _FallbackSpinner();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColorTokens.primary,
      ),
    ),
  );
}
