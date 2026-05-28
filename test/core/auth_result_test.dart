import 'package:flutter_test/flutter_test.dart';
import 'package:randki/core/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('AuthSuccess is a success marker type', () {
      const result = AuthSuccess();

      expect(result, isA<AuthResult>());
      expect(result, isNot(isA<AuthError>()));
    });

    test('AuthError keeps the provided message', () {
      const result = AuthError('No internet connection');

      expect(result.message, 'No internet connection');
      expect(result, isA<AuthResult>());
    });
  });
}
