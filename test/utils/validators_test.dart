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
        'Email ma nieodpowiedni format',
      );
    });

    test('rejects passwords with spaces', () {
      final result = Validators.validatePassword('abc def');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Hasło nie może zawierać spacji',
      );
    });

    test('rejects passwords shorter than six characters', () {
      final result = Validators.validatePassword('abc12');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Hasło musi mieć co najmniej 6 znaków',
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
      expect((result as ValidationError).message, 'Hasła się nie zgadzają');
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
        'Pseudonim musi mieć od 3 do 20 znaków',
      );
    });

    test('rejects a nickname with unsupported characters', () {
      final result = Validators.validateNickname('Jan*Nowak');

      expect(result, isA<ValidationError>());
      expect(
        (result as ValidationError).message,
        'Pseudonim może zawierać tylko litery, cyfry, spacje, kropki, podkreślenia i myślniki',
      );
    });

    test('accepts a trimmed nickname with supported characters', () {
      final result = Validators.validateNickname('  Jan.Nowak-01  ');

      expect(result, isA<ValidationSuccess>());
    });
  });
}
