import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import '../../data/datasources/auth_local_datasource.dart';

/// Service responsible for refreshing Spotify access tokens.
/// This is a low-level service used by the Dio interceptor.
class TokenRefreshService {
  final AuthLocalDataSource authDataSource;
  final Dio dio;
  final String clientId;

  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;

  TokenRefreshService({
    required this.authDataSource,
    required this.dio,
    required this.clientId,
  });

  /// Attempts to refresh the access token.
  /// Returns the new access token on success, null on failure.
  /// Handles concurrent refresh requests by reusing the same future.
  Future<String?> refreshToken() async {
    // If already refreshing, wait for the existing refresh to complete
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    _refreshFuture = _doRefresh();

    try {
      return await _refreshFuture;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Future<String?> _doRefresh() async {
    try {
      final refreshToken = await authDataSource.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return null;
      }

      final response = await dio.post(
        AppConfig.spotifyTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data as Map<String, dynamic>;

      final accessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;
      final expiresIn = data['expires_in'] as int;
      final expiry = DateTime.now().add(Duration(seconds: expiresIn));

      await authDataSource.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        expiry: expiry,
      );

      AppLogger.info('Token refreshed successfully via interceptor');
      return accessToken;
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed: ${e.message}', e);
      // If refresh token is invalid (401), user needs to re-authenticate
      if (e.response?.statusCode == 401) {
        await authDataSource.clearTokens();
      }
      return null;
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      return null;
    }
  }
}
