import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'auth_local_datasource.dart';

/// Alternative AuthLocalDataSource implementation using SharedPreferences
/// Used on platforms where Keychain/SecureStorage is problematic (macOS/iOS dev)
class AuthSharedPrefsDataSource implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthSharedPrefsDataSource(this._prefs);

  @override
  Future<String?> getAccessToken() async {
    try {
      return _prefs.getString(AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read refresh token: $e');
    }
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = _prefs.getString(AppConstants.tokenExpiryKey);
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
      await _prefs.setString(AppConstants.accessTokenKey, accessToken);
      await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
      await _prefs.setString(AppConstants.tokenExpiryKey, expiry.toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens: $e');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _prefs.remove(AppConstants.accessTokenKey);
      await _prefs.remove(AppConstants.refreshTokenKey);
      await _prefs.remove(AppConstants.tokenExpiryKey);
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
