import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/features/login/cubit/login_cubit.dart';
import 'package:nesty_admin/features/login/widgets/login_form.dart';

/// Spec §15 Auth: email/password sign-in.
///
/// There is no navigation here: once signed in, `App` re-enters the router
/// and `AuthGuard` picks the Dashboard or Not authorized.
///
/// TODO(design): design/admin/*.png has no login screen yet (DESIGN_BRIEF
/// Prompt 14 lists Levels, Level Editor and Skin upload only).
@RoutePage()
class LoginPage extends StatelessWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) =>
      BlocProvider(create: (_) => get<LoginCubit>(), child: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Not const: ConstrainedBox asserts its constraints at runtime.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: const LoginForm(),
          ),
        ),
      ),
    );
  }
}
