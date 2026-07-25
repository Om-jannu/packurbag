import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Backend base URL. Override at build/run time with
/// `--dart-define=API_BASE_URL=https://your-server` (e.g. an ngrok URL when
/// running on a physical device against a local backend).
const _defaultBaseUrl = 'http://localhost:5000';
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _defaultBaseUrl,
);

/// Thin wrapper around [Dio] shared by every repository. Centralizes base
/// URL, timeouts, and error mapping instead of each screen hand-rolling
/// `http.get`/`jsonDecode`/try-catch.
class ApiClient {
  ApiClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? query}) {
    return _request(() => dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) {
    return _request(() => dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> put(String path, {Object? data}) {
    return _request(() => dio.put(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) {
    return _request(() => dio.delete(path));
  }

  Future<Map<String, dynamic>> _request(
    Future<Response> Function() send,
  ) async {
    try {
      final response = await send();
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'success': true, 'data': data};
      return {'success': true, 'data': data};
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
