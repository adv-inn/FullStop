import 'package:dio/dio.dart';
import '../errors/failures.dart';
import 'logger.dart';

/// Type of failure to return for domain-specific errors
enum FailureType { spotify, playback }

/// Global handler for Dio errors
/// Provides consistent error handling across all repositories
class DioErrorHandler {
  /// Convert DioException to appropriate Failure type
  static Failure handle(
    DioException e, {
    FailureType failureType = FailureType.spotify,
    String? context,
    bool silent = false,
  }) {
    final statusCode = e.response?.statusCode;
    final message = _extractErrorMessage(e);

    _logError(e, context, silent, failureType);

    return _mapStatusCodeToFailure(statusCode, message, failureType);
  }

  /// Log the error with appropriate severity
  static void _logError(
    DioException e,
    String? context,
    bool silent,
    FailureType failureType,
  ) {
    if (context == null || silent) return;

    final isTransientError = _isTimeoutError(e) || _isNetworkError(e);
    final isPlayback = failureType == FailureType.playback;

    if (_isNetworkError(e) && isPlayback) {
      AppLogger.debug('$context failed (network): ${e.error}');
    } else if (isTransientError || isPlayback) {
      AppLogger.warning('$context failed', e);
    } else {
      AppLogger.error('$context failed', e);
    }
  }

  static bool _isTimeoutError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  static bool _isNetworkError(DioException e) {
    if (e.type == DioExceptionType.connectionError) return true;
    if (e.type != DioExceptionType.unknown) return false;

    final errorStr = e.error?.toString() ?? '';
    return errorStr.contains('HandshakeException') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('Connection reset') ||
        errorStr.contains('Connection closed') ||
        errorStr.contains('HttpException');
  }

  /// Map HTTP status code to appropriate Failure
  static Failure _mapStatusCodeToFailure(
    int? statusCode,
    String message,
    FailureType failureType,
  ) {
    switch (statusCode) {
      case 401:
        return AuthFailure(message: 'Unauthorized: $message');
      case 403:
        return AuthFailure(message: 'Access denied: $message');
      case 404:
        final msg = failureType == FailureType.playback
            ? 'No active device found'
            : 'Resource not found: $message';
        return _createFailure(
          failureType,
          message: msg,
          statusCode: statusCode,
        );
      case 429:
        return _createFailure(
          failureType,
          message: 'Rate limit exceeded. Please try again later.',
          statusCode: statusCode,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return _createFailure(
            failureType,
            message: 'Server error: $message',
            statusCode: statusCode,
          );
        }
        return _createFailure(
          failureType,
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// Create appropriate failure type based on context
  static Failure _createFailure(
    FailureType type, {
    required String message,
    int? statusCode,
  }) {
    switch (type) {
      case FailureType.spotify:
        return SpotifyApiFailure(message: message, statusCode: statusCode);
      case FailureType.playback:
        return PlaybackFailure(message: message);
    }
  }

  /// Extract error message from DioException
  static String _extractErrorMessage(DioException e) {
    final apiMessage = _extractApiErrorMessage(e);
    if (apiMessage != null) return apiMessage;

    return _mapExceptionTypeToMessage(e);
  }

  static String? _extractApiErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is! Map<String, dynamic>) return null;

    final error = data['error'];
    if (error is Map<String, dynamic>) {
      return error['message'] as String?;
    }
    if (error is String) {
      return error;
    }
    return null;
  }

  static String _mapExceptionTypeToMessage(DioException e) {
    const messages = {
      DioExceptionType.connectionTimeout:
          'Connection timeout. Please check your internet connection.',
      DioExceptionType.sendTimeout: 'Send timeout. Please try again.',
      DioExceptionType.receiveTimeout: 'Receive timeout. Please try again.',
      DioExceptionType.connectionError:
          'Connection error. Please check your internet connection.',
      DioExceptionType.cancel: 'Request was cancelled.',
    };

    if (messages.containsKey(e.type)) {
      return messages[e.type]!;
    }

    if (e.type == DioExceptionType.unknown) {
      return _extractUnknownErrorMessage(e);
    }

    return e.message ?? 'API request failed';
  }

  static String _extractUnknownErrorMessage(DioException e) {
    final errorStr = e.error?.toString() ?? '';

    if (errorStr.contains('HandshakeException')) {
      return 'Network connection interrupted. Please try again.';
    }
    if (errorStr.contains('SocketException')) {
      return 'Network unavailable. Please check your connection.';
    }
    if (errorStr.contains('Connection reset')) {
      return 'Connection was reset. Please try again.';
    }
    if (errorStr.contains('Connection closed') ||
        errorStr.contains('HttpException')) {
      return 'Connection interrupted. Please try again.';
    }

    return e.message ?? 'API request failed';
  }
}
