import '../app_exception.dart';
import '../api_client.dart';
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
  }
}
