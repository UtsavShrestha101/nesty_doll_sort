import 'package:nesty_admin/app/session_cubit/session_cubit.dart';
import 'package:nesty_admin/core/common_imports.dart';

/// Spec §15 Auth: "Users without an `admins/{uid}` document see
/// 'Not authorized'." `AuthGuard` only lets a signed-in non-admin reach it.
///
/// Signing out re-enters the router, which shows Login again so the user can
/// try another account.
///
/// TODO(design): no admin design export covers this screen yet.
@RoutePage()
class NotAuthorizedPage extends StatelessWidget {
  const NotAuthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final email = context.select(
      (SessionCubit cubit) => cubit.state.user?.email,
    );
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.notAuthorizedTitle,
                  style: context.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.notAuthorizedMessage,
                style: context.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (email != null) ...[
                const SizedBox(height: 8),
                Text(l10n.signedInAs(email), style: context.bodyMedium),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: context.read<SessionCubit>().signOut,
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
