import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureAuthStorage {
  static const _storage = FlutterSecureStorage();

  /// Saves token in secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Gets the saved token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Removes the saved token (e.g., during logout)
  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
