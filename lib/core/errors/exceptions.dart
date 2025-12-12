class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Network error', super.code});
}

class AuthException extends AppException {
  const AuthException({super.message = 'Authentication error', super.code});
}

class SpotifyApiException extends AppException {
  final int? statusCode;

  const SpotifyApiException({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  String toString() =>
      'SpotifyApiException: $message (code: $code, status: $statusCode)';
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache error', super.code});
}

class LlmException extends AppException {
  const LlmException({super.message = 'LLM service error', super.code});
}

class PlaybackException extends AppException {
  const PlaybackException({super.message = 'Playback error', super.code});
}
