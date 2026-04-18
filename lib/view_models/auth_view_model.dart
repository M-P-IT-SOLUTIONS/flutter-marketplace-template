import 'package:flutter/material.dart';
import 'package:randki/core/auth_result.dart';
import 'package:randki/services/auth_service.dart';
import 'package:randki/services/logger_service.dart';
import 'package:randki/utils/validators.dart';

/// Provider responsible for login and registration logic.
/// Stores the state of the last error that can be displayed in the UI.
class AuthViewModel extends ChangeNotifier {
  final IAuthService _authService;
  String? errorMessage;
  String? emailErrorMessage;
  String? passwordErrorMessage;
  String? confirmPasswordErrorMessage;

  AuthViewModel(this._authService);

  /// Attempts to log in the user with email and password.
  /// Validates input data and passes the result to AuthService.
  Future<bool> login(String email, String password) async {
    if (!validateEmail(email)) {
      return false;
    }
    if (!validatePassword(password)) {
      return false;
    }

    final result = await _authService.signInWithPassword(email, password);
    switch (result) {
      case AuthSuccess():
        Log.info('Login successful');
        clearErrors();
        return true;
      case AuthError(:final message):
        Log.warning('Login failed!');
        errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  bool validateEmail(String email) {
    final emailValidation = Validators.isValidEmail(email);
    if (emailValidation is ValidationError) {
      emailErrorMessage = emailValidation.message;
      notifyListeners();
      return false;
    }
    emailErrorMessage = null;
    notifyListeners();
    return true;
  }

  bool validatePassword(String password) {
    final passwordValidation = Validators.validatePassword(password);
    if (passwordValidation is ValidationError) {
      passwordErrorMessage = passwordValidation.message;
      notifyListeners();
      return false;
    }
    passwordErrorMessage = null;
    notifyListeners();
    return true;
  }

  bool validatePasswordsMatch(String password, String confirmPassword) {
    final passwordsMatchValidation = Validators.validatePasswordsMatch(
      password,
      confirmPassword,
    );
    if (passwordsMatchValidation is ValidationError) {
      confirmPasswordErrorMessage = passwordsMatchValidation.message;
      notifyListeners();
      return false;
    }
    confirmPasswordErrorMessage = null;
    notifyListeners();
    return true;
  }

  /// Attempts to register a new user.
  /// Validates email, password, and password confirmation.
  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (!validateEmail(email)) {
      return false;
    }
    if (!validatePassword(password)) {
      return false;
    }
    if (!validatePasswordsMatch(password, confirmPassword)) {
      return false;
    }

    final result = await _authService.signUpWithPassword(email, password);
    switch (result) {
      case AuthSuccess():
        Log.info('Registration successful');
        clearErrors();
        return true;
      case AuthError(:final message):
        Log.warning('Registration failed');
        errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  void clearErrors() {
    errorMessage = null;
    emailErrorMessage = null;
    passwordErrorMessage = null;
    confirmPasswordErrorMessage = null;
    notifyListeners();
  }
}
