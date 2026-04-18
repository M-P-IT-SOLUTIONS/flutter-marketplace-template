/// Collection of methods for validating input data (email, password, etc.)
class Validators {
  /// Checks if the email has a valid format.
  ///
  /// Returns [ValidationSuccess] if the format is correct,
  /// otherwise returns [ValidationError] with a message.
  static ValidationResult isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (emailRegex.hasMatch(email)) return const ValidationSuccess();

    return const ValidationError('Email has invalid format');
  }

  /// Checks if the password meets minimum requirements:
  /// no spaces and a minimum length of 6 characters.
  static ValidationResult validatePassword(String password) {
    if (password.contains(' ')) {
      return const ValidationError('Password cannot contain spaces');
    }
    if (password.length < 6) {
      return const ValidationError('Password must be at least 6 characters long');
    }
    return const ValidationSuccess();
  }

  /// Checks if the repeated password matches the original password.
  static ValidationResult validatePasswordsMatch(
    String password,
    String confirmPassword,
  ) {
    if (password != confirmPassword) {
      return const ValidationError('Passwords do not match');
    }
    return const ValidationSuccess();
  }

  /// Validates a nickname.
  /// Rules:
  /// - 3–20 characters,
  /// - allowed: letters, digits, spaces, dots, underscores, and hyphens,
  /// - leading/trailing spaces are trimmed.
  static ValidationResult validateNickname(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      return const ValidationError('Nickname cannot be empty');
    }
    if (trimmed.length < 3 || trimmed.length > 20) {
      return const ValidationError('Nickname must be between 3 and 20 characters');
    }
    final nickRegex = RegExp(r'^[a-zA-Z0-9._\- ]+$');
    if (!nickRegex.hasMatch(trimmed)) {
      return const ValidationError(
        'Nickname can only contain letters, digits, spaces, dots, underscores, and hyphens',
      );
    }
    return const ValidationSuccess();
  }
}

/// Abstract base class representing a validation result.
/// Used as the return type for validation functions.
sealed class ValidationResult {
  const ValidationResult();
}

/// Represents a successful validation result.
class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

/// Represents a validation error with an associated message.
class ValidationError extends ValidationResult {
  final String message;
  const ValidationError(this.message);
}
