import 'dart:async';

import 'package:nesty_admin/app/session_cubit/session_cubit.dart';
import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/core/flavor/flavor_config.dart';
import 'package:nesty_admin/core/router/app_router.dart';
import 'package:nesty_admin/core/ui/theme/app_theme.dart';

/// Root widget: the app-level session cubit + `MaterialApp.router`.
class App extends StatefulWidget {
  const App({required this.router, super.key});

  final AppRouter router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Built once so a rebuild of MaterialApp keeps the same router delegate
  // and navigation stack.
  late final RouterConfig<UrlState> _routerConfig = widget.router.config();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: get<SessionCubit>(),
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) => previous.user != current.user,
        // Every sign-in or sign-out re-enters the app root; AuthGuard then
        // sends the user to Login, Not authorized or the Dashboard. Access is
        // decided there only, never here or in a page.
        listener: (context, _) =>
            unawaited(widget.router.replaceAll([const AdminShellRoute()])),
        child: MaterialApp.router(
          title: FlavorConfig.values.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _routerConfig,
        ),
      ),
    );
  }
}
