import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/oauth_service.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'core_providers.dart';
import 'spotify_providers.dart';

/// Authentication-related providers

// Credentials Local Data Source
final credentialsLocalDataSourceProvider = Provider<CredentialsLocalDataSource>(
  (ref) {
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
  final credentialsDataSource = ref.watch(credentialsLocalDataSourceProvider);
  final apiClient = ref.watch(spotifyApiClientProvider);
  final dio = ref.watch(authDioProvider);
  final oauthService = ref.watch(oauthServiceProvider);

  return AuthRepositoryImpl(
    localDataSource: localDataSource,
    credentialsDataSource: credentialsDataSource,
    apiClient: apiClient,
    dio: dio,
    oauthService: oauthService,
  );
});
