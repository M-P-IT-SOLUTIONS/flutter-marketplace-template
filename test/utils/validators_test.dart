import 'package:flutter_test/flutter_test.dart';
import 'package:randki/utils/validators.dart';

void main() {
  group('Validators', () {
    test('accepts a valid email address', () {
      final result = Validators.isValidEmail('john.doe@example.com');

      expect(result, isA<ValidationSuccess>());
    });

    test('rejects an invalid email address', () {
      final result = Validators.isValidEmail('john.doe@invalid');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Email has invalid format',
      );
    });

    test('rejects passwords with spaces', () {
      final result = Validators.validatePassword('abc def');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Password cannot contain spaces',
      );
    });

    test('rejects passwords shorter than six characters', () {
      final result = Validators.validatePassword('abc12');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Password must be at least 6 characters long',
      );
    });

    test('accepts a password that matches the requirements', () {
      final result = Validators.validatePassword('abc123');

      expect(result, isA<ValidationSuccess>());
    });

    test('rejects different passwords', () {
      final result = Validators.validatePasswordsMatch(
        'secret123',
        'secret321',
      );

      expect(result, isA<ValidationError>());
      expect((result as ValidationError).message, 'Passwords do not match');
    });

    test('accepts matching passwords', () {
      final result = Validators.validatePasswordsMatch(
        'secret123',
        'secret123',
      );

      expect(result, isA<ValidationSuccess>());
    });

    test('rejects a nickname that is too short after trimming', () {
      final result = Validators.validateNickname('  ab  ');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Nickname must be between 3 and 20 characters',
      );
    });

    test('rejects a nickname with unsupported characters', () {
      final result = Validators.validateNickname('Jan*Nowak');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Nickname can only contain letters, digits, spaces, dots, underscores, and hyphens',
      );
    });

    test('accepts a trimmed nickname with supported characters', () {
      final result = Validators.validateNickname('  Jan.Nowak-01  ');

      expect(result, isA<ValidationSuccess>());
    });
  });
}
