import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';

/// A signed-in admin-panel user (spec §15 Auth).
@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    /// Firebase Auth uid (M5); also the `admins/{uid}` document id.
    required String uid,
    required String email,

    /// Whether `admins/{uid}` exists (spec §14.1, created by hand in the
    /// console). Defaults to false so a user is never an admin by accident.
    /// Only admins get past `AuthGuard`; everyone else sees Not authorized.
    @Default(false) bool isAdmin,
  }) = _AdminUser;
}
