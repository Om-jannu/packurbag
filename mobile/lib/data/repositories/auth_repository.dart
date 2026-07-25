import '../app_exception.dart';
import '../api_client.dart';
import '../token_storage.dart';
import '../../models/user.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<User> login({
    required String userEmail,
    required String password,
  }) async {
    final response = await _client.post('/login', data: {
      'userEmail': userEmail,
      'password': password,
    });

    if (response['success'] != true) {
      throw AppException(response['message'] as String? ?? 'Login failed');
    }
    await TokenStorage.instance.saveTokens(
      accessToken: response['accessToken'] as String,
      refreshToken: response['refreshToken'] as String,
    );
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> register({
    required String username,
    required String userEmail,
    required String password,
  }) async {
    final response = await _client.post('/register', data: {
      'username': username,
      'userEmail': userEmail,
      'password': password,
    });

    if (response['success'] != true) {
      throw AppException(
          response['message'] as String? ?? 'Registration failed');
    }
    // A token pair comes back here too, but registering still routes back
    // to the login screen rather than auto-signing in, so it's left unused.
  }

  /// Best-effort — the local session is cleared regardless of whether the
  /// backend call succeeds (e.g. no network at logout time).
  Future<void> logout(String? refreshToken) async {
    if (refreshToken != null) {
      try {
        await _client.post('/logout', data: {'refreshToken': refreshToken});
      } catch (_) {
        // Ignore — we're logging out either way.
      }
    }
    await TokenStorage.instance.clear();
  }
}
