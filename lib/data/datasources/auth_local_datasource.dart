import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<DateTime?> getTokenExpiry();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  });
  Future<void> clearTokens();
  Future<bool> hasValidToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read refresh token: $e');
    }
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = await _secureStorage.read(
        key: AppConstants.tokenExpiryKey,
      );
      if (expiryStr == null) return null;
      return DateTime.parse(expiryStr);
    } catch (e) {
      throw CacheException(message: 'Failed to read token expiry: $e');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    try {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
      await _secureStorage.write(
        key: AppConstants.tokenExpiryKey,
        value: expiry.toIso8601String(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens: $e');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear tokens: $e');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final accessToken = await getAccessToken();
      final expiry = await getTokenExpiry();

      if (accessToken == null || expiry == null) return false;

      // Token is valid if it expires more than 5 minutes from now
      return expiry.isAfter(DateTime.now().add(const Duration(minutes: 5)));
    } catch (e) {
      return false;
    }
  }
}
