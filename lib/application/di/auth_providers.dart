import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/oauth_service.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../../data/datasources/credentials_shared_prefs_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/proxy_settings.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/credentials_provider.dart';
import 'core_providers.dart';
import 'spotify_providers.dart';

/// Authentication-related providers

// SharedPreferences provider (async initialization required)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Credentials Local Data Source
// Uses SharedPreferences on macOS/iOS to avoid Keychain issues during development
final credentialsLocalDataSourceProvider = Provider<CredentialsLocalDataSource>(
  (ref) {
    // On macOS and iOS, use SharedPreferences to avoid Keychain/signing issues
    if (Platform.isMacOS || Platform.isIOS) {
      final prefsAsync = ref.watch(sharedPreferencesProvider);
      return prefsAsync.when(
        data: (prefs) => CredentialsSharedPrefsDataSource(prefs),
        loading: () => _PlaceholderCredentialsDataSource(),
        error: (_, __) => _PlaceholderCredentialsDataSource(),
      );
    }
    // On other platforms, use secure storage
    final secureStorage = ref.watch(secureStorageProvider);
    return CredentialsLocalDataSourceImpl(secureStorage);
  },
);

// OAuth Service
final oauthServiceProvider = Provider<OAuthService>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  final urlLauncherService = ref.watch(urlLauncherServiceProvider);
  return SpotifyOAuthService(
    deepLinkService: deepLinkService,
    urlLauncherService: urlLauncherService,
  );
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final apiClient = ref.watch(spotifyApiClientProvider);
  final dio = ref.watch(authDioProvider);
  final oauthService = ref.watch(oauthServiceProvider);
  final clientId = ref.watch(effectiveSpotifyClientIdProvider);

  return AuthRepositoryImpl(
    localDataSource: localDataSource,
    apiClient: apiClient,
    dio: dio,
    oauthService: oauthService,
    clientId: clientId,
  );
});

/// Placeholder implementation while SharedPreferences is loading
class _PlaceholderCredentialsDataSource implements CredentialsLocalDataSource {
  @override
  Future<void> clearGetSongBpmApiKey() async {}
  @override
  Future<void> clearLlmCredentials() async {}
  @override
  Future<void> clearAppProxySettings() async {}
  @override
  Future<bool> getAudioFeaturesEnabled() async => false;
  @override
  Future<String?> getGetSongBpmApiKey() async => null;
  @override
  Future<bool> getGpuAccelerationEnabled() async => false;
  @override
  Future<String?> getLlmApiKey() async => null;
  @override
  Future<String?> getLlmBaseUrl() async => null;
  @override
  Future<String?> getLlmModel() async => null;
  @override
  Future<AppProxySettings> getAppProxySettings() async => const AppProxySettings();
  @override
  Future<bool> hasGetSongBpmApiKey() async => false;
  @override
  Future<bool> hasLlmConfig() async => false;
  @override
  Future<void> saveAppProxySettings(AppProxySettings config) async {}
  @override
  Future<void> saveLlmCredentials({String apiKey = '', required String model, required String baseUrl}) async {}
  @override
  Future<void> setAudioFeaturesEnabled(bool enabled) async {}
  @override
  Future<void> setGetSongBpmApiKey(String apiKey) async {}
  @override
  Future<void> setGpuAccelerationEnabled(bool enabled) async {}
  @override
  Future<String?> getCustomSpotifyClientId() async => null;
  @override
  Future<void> saveCustomSpotifyClientId(String clientId) async {}
  @override
  Future<void> clearCustomSpotifyClientId() async {}
}
