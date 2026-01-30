import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/proxy_settings.dart';
import 'credentials_local_datasource.dart';

/// Alternative implementation using SharedPreferences
/// Used on platforms where Keychain/SecureStorage is problematic (macOS/iOS dev)
class CredentialsSharedPrefsDataSource implements CredentialsLocalDataSource {
  final SharedPreferences _prefs;

  CredentialsSharedPrefsDataSource(this._prefs);

  // Spotify credentials
  @override
  Future<String?> getSpotifyClientId() async {
    return _prefs.getString(AppConstants.spotifyClientIdKey);
  }

  @override
  Future<String?> getSpotifyClientSecret() async {
    return _prefs.getString(AppConstants.spotifyClientSecretKey);
  }

  @override
  Future<void> saveSpotifyCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    await _prefs.setString(AppConstants.spotifyClientIdKey, clientId);
    await _prefs.setString(AppConstants.spotifyClientSecretKey, clientSecret);
  }

  @override
  Future<void> clearSpotifyCredentials() async {
    await _prefs.remove(AppConstants.spotifyClientIdKey);
    await _prefs.remove(AppConstants.spotifyClientSecretKey);
  }

  @override
  Future<bool> hasSpotifyCredentials() async {
    final clientId = await getSpotifyClientId();
    final clientSecret = await getSpotifyClientSecret();
    return clientId != null &&
        clientId.isNotEmpty &&
        clientSecret != null &&
        clientSecret.isNotEmpty;
  }

  // LLM credentials
  @override
  Future<String?> getLlmApiKey() async {
    return _prefs.getString(AppConstants.llmApiKeyKey);
  }

  @override
  Future<String?> getLlmModel() async {
    return _prefs.getString(AppConstants.llmModelKey);
  }

  @override
  Future<String?> getLlmBaseUrl() async {
    return _prefs.getString(AppConstants.llmBaseUrlKey);
  }

  @override
  Future<void> saveLlmCredentials({
    String apiKey = '',
    required String model,
    required String baseUrl,
  }) async {
    await _prefs.setString(AppConstants.llmApiKeyKey, apiKey);
    await _prefs.setString(AppConstants.llmModelKey, model);
    await _prefs.setString(AppConstants.llmBaseUrlKey, baseUrl);
  }

  @override
  Future<void> clearLlmCredentials() async {
    await _prefs.remove(AppConstants.llmApiKeyKey);
    await _prefs.remove(AppConstants.llmModelKey);
    await _prefs.remove(AppConstants.llmBaseUrlKey);
  }

  @override
  Future<bool> hasLlmConfig() async {
    final model = await getLlmModel();
    final baseUrl = await getLlmBaseUrl();
    return model != null &&
        model.isNotEmpty &&
        baseUrl != null &&
        baseUrl.isNotEmpty;
  }

  // Proxy configuration
  @override
  Future<AppProxySettings> getAppProxySettings() async {
    final enabled = _prefs.getString(AppConstants.proxyEnabledKey);
    final typeStr = _prefs.getString(AppConstants.proxyTypeKey);
    final host = _prefs.getString(AppConstants.proxyHostKey);
    final portStr = _prefs.getString(AppConstants.proxyPortKey);
    final username = _prefs.getString(AppConstants.proxyUsernameKey);
    final password = _prefs.getString(AppConstants.proxyPasswordKey);

    return AppProxySettings(
      enabled: enabled == 'true',
      type: typeStr == 'socks5' ? AppProxyType.socks5 : AppProxyType.http,
      host: host ?? '',
      port: int.tryParse(portStr ?? '') ?? 0,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> saveAppProxySettings(AppProxySettings config) async {
    await _prefs.setString(
      AppConstants.proxyEnabledKey,
      config.enabled.toString(),
    );
    await _prefs.setString(
      AppConstants.proxyTypeKey,
      config.type == AppProxyType.socks5 ? 'socks5' : 'http',
    );
    await _prefs.setString(AppConstants.proxyHostKey, config.host);
    await _prefs.setString(AppConstants.proxyPortKey, config.port.toString());
    if (config.username != null) {
      await _prefs.setString(AppConstants.proxyUsernameKey, config.username!);
    }
    if (config.password != null) {
      await _prefs.setString(AppConstants.proxyPasswordKey, config.password!);
    }
  }

  @override
  Future<void> clearAppProxySettings() async {
    await _prefs.remove(AppConstants.proxyEnabledKey);
    await _prefs.remove(AppConstants.proxyTypeKey);
    await _prefs.remove(AppConstants.proxyHostKey);
    await _prefs.remove(AppConstants.proxyPortKey);
    await _prefs.remove(AppConstants.proxyUsernameKey);
    await _prefs.remove(AppConstants.proxyPasswordKey);
  }

  // Feature flags
  @override
  Future<bool> getAudioFeaturesEnabled() async {
    return _prefs.getString(AppConstants.audioFeaturesEnabledKey) == 'true';
  }

  @override
  Future<void> setAudioFeaturesEnabled(bool enabled) async {
    await _prefs.setString(
      AppConstants.audioFeaturesEnabledKey,
      enabled.toString(),
    );
  }

  @override
  Future<bool> getGpuAccelerationEnabled() async {
    return _prefs.getString(AppConstants.gpuAccelerationEnabledKey) == 'true';
  }

  @override
  Future<void> setGpuAccelerationEnabled(bool enabled) async {
    await _prefs.setString(
      AppConstants.gpuAccelerationEnabledKey,
      enabled.toString(),
    );
  }

  // GetSongBPM API
  @override
  Future<String?> getGetSongBpmApiKey() async {
    return _prefs.getString(AppConstants.getSongBpmApiKeyKey);
  }

  @override
  Future<void> setGetSongBpmApiKey(String apiKey) async {
    await _prefs.setString(AppConstants.getSongBpmApiKeyKey, apiKey);
  }

  @override
  Future<void> clearGetSongBpmApiKey() async {
    await _prefs.remove(AppConstants.getSongBpmApiKeyKey);
  }

  @override
  Future<bool> hasGetSongBpmApiKey() async {
    final apiKey = await getGetSongBpmApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}
