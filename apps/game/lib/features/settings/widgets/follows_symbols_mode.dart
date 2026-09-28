import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_render/nesty_render.dart' show DollSymbols;

/// For a [State] whose doll art bakes the Color symbols in (spec §12.3,
/// D45): [onSymbolsModeChanged] runs each time the stored mode changes.
/// Settings opens over screens that stay mounted (Home, the Shop tab, the
/// Daily page under a level), so art they prepared earlier must be
/// prepared again in the new mode (D91). Reads [DatabaseService] from the
/// tree.
mixin FollowsSymbolsMode<T extends StatefulWidget> on State<T> {
  StreamSubscription<SymbolsMode>? _symbolsChanges;

  /// The stored mode is now [mode]. It can repeat the mode already in use,
  /// so compare before preparing anything.
  void onSymbolsModeChanged(SymbolsMode mode);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _symbolsChanges ??= context
        .read<DatabaseService>()
        .symbolsModeChanges
        .listen((mode) {
          if (mounted) onSymbolsModeChanged(mode);
        });
  }

  @override
  void dispose() {
    unawaited(_symbolsChanges?.cancel());
    super.dispose();
  }
}

/// Builds [builder] with the stored Color symbols mode, and again each time
/// it changes (D91).
class SymbolsModeBuilder extends StatefulWidget {
  const SymbolsModeBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, DollSymbols symbols) builder;

  @override
  State<SymbolsModeBuilder> createState() => _SymbolsModeBuilderState();
}

class _SymbolsModeBuilderState extends State<SymbolsModeBuilder>
    with FollowsSymbolsMode {
  @override
  void onSymbolsModeChanged(SymbolsMode mode) => setState(() {});

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    context.read<DatabaseService>().symbolsMode.dollSymbols,
  );
}
