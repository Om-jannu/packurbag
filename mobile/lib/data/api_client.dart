import 'dart:async';

import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'token_storage.dart';

/// Backend base URL. Override at build/run time with
/// `--dart-define=API_BASE_URL=https://your-server` (e.g. an ngrok URL when
/// running on a physical device against a local backend), or with
/// `--dart-define-from-file=config.json` (see config.json.example) once
/// there are enough build-time values that individual flags get unwieldy —
/// CI uses the latter.
const _defaultBaseUrl = 'http://localhost:5000';
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _defaultBaseUrl,
);

/// Thin wrapper around [Dio] shared by every repository. Centralizes base
/// URL, timeouts, error mapping, and the access/refresh token lifecycle
/// instead of each screen hand-rolling `http.get`/`jsonDecode`/try-catch.
class ApiClient {
  ApiClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;

  /// Called when the refresh token itself is invalid, expired, or revoked —
  /// there's no way back into this session short of logging in again.
  void Function()? onUnauthorized;

  Completer<bool>? _refreshCompleter;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.instance.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final isUnauthorized = error.response?.statusCode == 401;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        try {
          final retryOptions = error.requestOptions..extra['retried'] = true;
          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        } catch (_) {
          // Fall through and surface the original error.
        }
      } else {
        onUnauthorized?.call();
      }
    }
    handler.next(error);
  }

  /// Refreshes the access/refresh token pair. Concurrent callers (several
  /// requests failing with 401 at once) all await the same in-flight
  /// refresh instead of racing to hit `/refresh` independently.
  Future<bool> _refreshTokens() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    try {
      final refreshToken = await TokenStorage.instance.refreshToken;
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      // A bare Dio instance — this must never go through our own
      // interceptors, or a failed refresh would recurse into itself.
      final refreshDio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      if (body?['success'] == true) {
        await TokenStorage.instance.saveTokens(
          accessToken: body!['accessToken'] as String,
          refreshToken: body['refreshToken'] as String,
        );
        completer.complete(true);
        return true;
      }
      await TokenStorage.instance.clear();
      completer.complete(false);
      return false;
    } catch (_) {
      await TokenStorage.instance.clear();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

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
