import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain/Keystore-backed storage for auth tokens — separate from the
/// plain SharedPreferences used for the cached user profile, since leaking a
/// token is more sensitive than leaking a cached profile blob.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'packurbag_access_token';
  static const _refreshKey = 'packurbag_refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> get accessToken => _storage.read(key: _accessKey);

  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
