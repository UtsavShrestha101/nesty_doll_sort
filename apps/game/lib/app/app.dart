import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/theme/app_theme.dart';

/// Root widget: app-level cubits + `MaterialApp.router`.
class App extends StatefulWidget {
  const App({required this.router, super.key});

  final AppRouter router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Built once so a locale rebuild of MaterialApp keeps the same router
  // delegate and navigation stack.
  late final RouterConfig<UrlState> _routerConfig = widget.router.config();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // App-level cubits only; feature cubits are provided at their route.
      providers: [BlocProvider.value(value: get<LanguageCubit>())],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        buildWhen: (previous, current) =>
            previous.currentLanguageCode != current.currentLanguageCode,
        builder: (context, languageState) => MaterialApp.router(
          title: FlavorConfig.values.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: languageState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _routerConfig,
          // Respect system text scaling in menus, up to 1.3× (spec §16).
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
