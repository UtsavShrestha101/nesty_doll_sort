import 'dart:async';

import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/features/login/cubit/login_cubit.dart';

/// Email + password form driving [LoginCubit].
///
/// Validation only checks that both fields are filled in; whether the
/// credentials are right is the auth backend's call.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      context.read<LoginCubit>().signIn(
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return BlocBuilder<LoginCubit, AsyncValue<AdminUser>>(
      builder: (context, state) {
        final busy = state.isLoading;
        final error = state.exceptionOrNull;
        // AutofillGroup lets browser password managers fill both fields.
        return AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.appName,
                    style: context.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  enabled: !busy,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? l10n.emailRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  enabled: !busy,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) =>
                      (value ?? '').isEmpty ? l10n.passwordRequired : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error.localizedMessage(l10n),
                    style: context.bodyMedium.copyWith(
                      color: context.theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            semanticsLabel: l10n.signingIn,
                          ),
                        )
                      : Text(l10n.signIn),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
