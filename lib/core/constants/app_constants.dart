class AppConstants {

  // Storage keys
  static const String accessTokenKey = 'spotify_access_token';
  static const String refreshTokenKey = 'spotify_refresh_token';
  static const String tokenExpiryKey = 'spotify_token_expiry';
  static const String userProfileKey = 'user_profile';

  // LLM Config keys
  static const String llmProviderKey = 'llm_provider';
  static const String llmApiKeyKey = 'llm_api_key';
  static const String llmModelKey = 'llm_model';
  static const String llmBaseUrlKey = 'llm_base_url';

  // Proxy Config keys
  static const String proxyEnabledKey = 'proxy_enabled';
  static const String proxyTypeKey = 'proxy_type'; // 'http' or 'socks5'
  static const String proxyHostKey = 'proxy_host';
  static const String proxyPortKey = 'proxy_port';
  static const String proxyUsernameKey = 'proxy_username';
  static const String proxyPasswordKey = 'proxy_password';

  // Feature flags
  static const String audioFeaturesEnabledKey = 'audio_features_enabled';
  static const String gpuAccelerationEnabledKey = 'gpu_acceleration_enabled';

  // Custom Spotify Client ID
  static const String customSpotifyClientIdKey = 'custom_spotify_client_id';

  // GetSongBPM API
  static const String getSongBpmApiKeyKey = 'getsongbpm_api_key';

  // Cache durations
  static const Duration artistCacheDuration = Duration(hours: 24);
  static const Duration trackCacheDuration = Duration(hours: 12);
  static const Duration searchCacheDuration = Duration(minutes: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Playback
  static const Duration playbackPollInterval = Duration(seconds: 1);
  static const Duration seekDebounce = Duration(milliseconds: 300);
}
