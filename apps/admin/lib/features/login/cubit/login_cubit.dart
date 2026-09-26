import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/base/base_async_cubit.dart';
import 'package:nesty_admin/core/base/base_async_state.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';

/// The sign-in form's request state (spec §15 Auth): loading while signing
/// in, the error to show, or the signed-in user.
///
/// It does not navigate or decide access. A successful sign-in reaches
/// `SessionCubit` through `AuthService.userChanges`, and `AuthGuard` then
/// sends the user to the Dashboard or Not authorized.
///
/// The state is `AdminUser` itself rather than a wrapper: the form keeps its
/// fields in text controllers, so the user is all there is to hold.
@injectable
class LoginCubit extends BaseAsyncCubit<AdminUser> {
  LoginCubit(this._auth);

  final AuthService _auth;

  Future<void> signIn({required String email, required String password}) async {
    // One request at a time: Enter plus a click must not sign in twice.
    if (state.isLoading) return;
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(
      // Trim the email only: whitespace can be part of a password.
      () => _auth.signIn(email: email.trim(), password: password),
    );
  }
}
