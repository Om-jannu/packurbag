import 'package:dio/dio.dart';

/// Uniform error surfaced by the data layer, replacing the copy-pasted
/// try/catch-per-screen pattern the app used before.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  /// Prefers the backend's own `{ success: false, message: "..." }` body
  /// (every route in the API replies with one on failure) over a generic
  /// message, so users see e.g. "Incorrect Password or Email" or "Enter a
  /// valid amount" instead of "Something went wrong" for every failure.
  factory AppException.fromDioError(DioException error) {
    final backendMessage = _backendMessage(error.response?.data);
    return AppException(backendMessage ?? _messageForType(error));
  }

  static String? _backendMessage(Object? data) {
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    return null;
  }

  static String _messageForType(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'No internet connection. Please check your network and try again.';
      case DioExceptionType.badCertificate:
        return 'Could not establish a secure connection to the server.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => message;
}
