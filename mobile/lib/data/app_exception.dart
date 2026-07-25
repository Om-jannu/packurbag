/// Uniform error surfaced by the data layer, replacing the copy-pasted
/// try/catch-per-screen pattern the app used before.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  factory AppException.fromDioError(Object error) {
    return AppException(_messageFor(error));
  }

  static String _messageFor(Object error) {
    final description = error.toString();
    if (description.contains('SocketException') ||
        description.contains('Connection') ||
        description.contains('Network')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  String toString() => message;
}
