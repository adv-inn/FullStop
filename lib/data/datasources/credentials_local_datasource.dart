import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/proxy_settings.dart';

/// Data source for storing and retrieving API credentials securely
abstract class CredentialsLocalDataSource {
  Future<String?> getSpotifyClientId();
  Future<String?> getSpotifyClientSecret();
  Future<void> saveSpotifyCredentials({
    required String clientId,
    required String clientSecret,
  });
  Future<void> clearSpotifyCredentials();
  Future<bool> hasSpotifyCredentials();

  // LLM credentials (optional)
  Future<String?> getLlmApiKey();
  Future<String?> getLlmModel();
  Future<String?> getLlmBaseUrl();
  Future<void> saveLlmCredentials({
    String apiKey = '',
    required String model,
    required String baseUrl,
  });
  Future<void> clearLlmCredentials();
  Future<bool> hasLlmConfig();

  // Proxy configuration
  Future<AppProxySettings> getAppProxySettings();
  Future<void> saveAppProxySettings(AppProxySettings config);
  Future<void> clearAppProxySettings();

  // Feature flags
  Future<bool> getAudioFeaturesEnabled();
  Future<void> setAudioFeaturesEnabled(bool enabled);
  Future<bool> getGpuAccelerationEnabled();
  Future<void> setGpuAccelerationEnabled(bool enabled);

  // GetSongBPM API
  Future<String?> getGetSongBpmApiKey();
  Future<void> setGetSongBpmApiKey(String apiKey);
  Future<void> clearGetSongBpmApiKey();
  Future<bool> hasGetSongBpmApiKey();
}

class CredentialsLocalDataSourceImpl implements CredentialsLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  CredentialsLocalDataSourceImpl(this._secureStorage);

  // Spotify credentials
  @override
  Future<String?> getSpotifyClientId() async {
    return await _secureStorage.read(key: AppConstants.spotifyClientIdKey);
  }

  @override
  Future<String?> getSpotifyClientSecret() async {
    return await _secureStorage.read(key: AppConstants.spotifyClientSecretKey);
  }

  @override
  Future<void> saveSpotifyCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    await _secureStorage.write(
      key: AppConstants.spotifyClientIdKey,
      value: clientId,
    );
    await _secureStorage.write(
      key: AppConstants.spotifyClientSecretKey,
      value: clientSecret,
    );
  }

  @override
  Future<void> clearSpotifyCredentials() async {
    await _secureStorage.delete(key: AppConstants.spotifyClientIdKey);
    await _secureStorage.delete(key: AppConstants.spotifyClientSecretKey);
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
    return await _secureStorage.read(key: AppConstants.llmApiKeyKey);
  }

  @override
  Future<String?> getLlmModel() async {
    return await _secureStorage.read(key: AppConstants.llmModelKey);
  }

  @override
  Future<String?> getLlmBaseUrl() async {
    return await _secureStorage.read(key: AppConstants.llmBaseUrlKey);
  }

  @override
  Future<void> saveLlmCredentials({
    String apiKey = '',
    required String model,
    required String baseUrl,
  }) async {
    await _secureStorage.write(key: AppConstants.llmApiKeyKey, value: apiKey);
    await _secureStorage.write(key: AppConstants.llmModelKey, value: model);
    await _secureStorage.write(key: AppConstants.llmBaseUrlKey, value: baseUrl);
  }

  @override
  Future<void> clearLlmCredentials() async {
    await _secureStorage.delete(key: AppConstants.llmApiKeyKey);
    await _secureStorage.delete(key: AppConstants.llmModelKey);
    await _secureStorage.delete(key: AppConstants.llmBaseUrlKey);
  }

  @override
  Future<bool> hasLlmConfig() async {
    final model = await getLlmModel();
    final baseUrl = await getLlmBaseUrl();
    // API key is optional (for Ollama), but model and baseUrl are required
    return model != null &&
        model.isNotEmpty &&
        baseUrl != null &&
        baseUrl.isNotEmpty;
  }

  // Proxy configuration
  @override
  Future<AppProxySettings> getAppProxySettings() async {
    final enabled = await _secureStorage.read(
      key: AppConstants.proxyEnabledKey,
    );
    final typeStr = await _secureStorage.read(key: AppConstants.proxyTypeKey);
    final host = await _secureStorage.read(key: AppConstants.proxyHostKey);
    final portStr = await _secureStorage.read(key: AppConstants.proxyPortKey);
    final username = await _secureStorage.read(
      key: AppConstants.proxyUsernameKey,
    );
    final password = await _secureStorage.read(
      key: AppConstants.proxyPasswordKey,
    );

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
    await _secureStorage.write(
      key: AppConstants.proxyEnabledKey,
      value: config.enabled.toString(),
    );
    await _secureStorage.write(
      key: AppConstants.proxyTypeKey,
      value: config.type == AppProxyType.socks5 ? 'socks5' : 'http',
    );
    await _secureStorage.write(
      key: AppConstants.proxyHostKey,
      value: config.host,
    );
    await _secureStorage.write(
      key: AppConstants.proxyPortKey,
      value: config.port.toString(),
    );
    if (config.username != null) {
      await _secureStorage.write(
        key: AppConstants.proxyUsernameKey,
        value: config.username,
      );
    }
    if (config.password != null) {
      await _secureStorage.write(
        key: AppConstants.proxyPasswordKey,
        value: config.password,
      );
    }
  }

  @override
  Future<void> clearAppProxySettings() async {
    await _secureStorage.delete(key: AppConstants.proxyEnabledKey);
    await _secureStorage.delete(key: AppConstants.proxyTypeKey);
    await _secureStorage.delete(key: AppConstants.proxyHostKey);
    await _secureStorage.delete(key: AppConstants.proxyPortKey);
    await _secureStorage.delete(key: AppConstants.proxyUsernameKey);
    await _secureStorage.delete(key: AppConstants.proxyPasswordKey);
  }

  // Feature flags
  @override
  Future<bool> getAudioFeaturesEnabled() async {
    final value = await _secureStorage.read(
      key: AppConstants.audioFeaturesEnabledKey,
    );
    return value == 'true';
  }

  @override
  Future<void> setAudioFeaturesEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConstants.audioFeaturesEnabledKey,
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> getGpuAccelerationEnabled() async {
    final value = await _secureStorage.read(
      key: AppConstants.gpuAccelerationEnabledKey,
    );
    return value == 'true';
  }

  @override
  Future<void> setGpuAccelerationEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConstants.gpuAccelerationEnabledKey,
      value: enabled.toString(),
    );
  }

  // GetSongBPM API
  @override
  Future<String?> getGetSongBpmApiKey() async {
    return await _secureStorage.read(key: AppConstants.getSongBpmApiKeyKey);
  }

  @override
  Future<void> setGetSongBpmApiKey(String apiKey) async {
    await _secureStorage.write(
      key: AppConstants.getSongBpmApiKeyKey,
      value: apiKey,
    );
  }

  @override
  Future<void> clearGetSongBpmApiKey() async {
    await _secureStorage.delete(key: AppConstants.getSongBpmApiKeyKey);
  }

  @override
  Future<bool> hasGetSongBpmApiKey() async {
    final apiKey = await getGetSongBpmApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}
