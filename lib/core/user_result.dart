import 'package:flutter_marketplace_template/models/app_user.dart';

sealed class UserResult {
  const UserResult();
}

/// Operation completed successfully, but without returning user data.
class UserSuccess extends UserResult {
  const UserSuccess();
}

/// Returns the loaded user from the profile.
class UserLoaded extends UserResult {
  final AppUser user;
  const UserLoaded(this.user);
}

/// Operation failed with an error message.
class UserError extends UserResult {
  final String errorMessage;
  const UserError({required this.errorMessage});
}
