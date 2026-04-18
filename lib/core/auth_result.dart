sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess();
}

class AuthError extends AuthResult {
  final String message;
  const AuthError(this.message);
}
