import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socks5_proxy/socks_client.dart' as socks5;
import '../../core/config/app_config.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/mini_player_service.dart';
import '../../core/services/token_refresh_service.dart';
import '../../core/services/url_launcher_service.dart';
import '../../core/services/window_service.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_shared_prefs_datasource.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../../domain/entities/proxy_settings.dart';
import '../../data/services/app_links_deep_link_service.dart';
import '../../data/services/default_url_launcher_service.dart';
import '../../data/services/window_manager_service.dart';
import 'auth_providers.dart' show credentialsLocalDataSourceProvider;

// SharedPreferences provider for macOS/iOS
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Core infrastructure providers
/// These are low-level services that other modules depend on

// Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    mOptions: MacOsOptions(),
    iOptions: IOSOptions(
      accountName: 'com.sfo.fullstop',
    ),
  );
});

// Global proxy configuration holder
AppProxySettings? _currentProxyConfig;

// Provider to update proxy configuration
final proxyUpdaterProvider = Provider<void Function(AppProxySettings?)>((ref) {
  return (AppProxySettings? config) {
    _currentProxyConfig = config;
    // Force refresh of Dio providers
    ref.invalidate(authDioProvider);
    ref.invalidate(apiDioProvider);
    ref.invalidate(llmDioProvider);
  };
});

// Helper function to configure Dio with proxy
void _configureDioProxy(Dio dio, AppProxySettings? config) {
  if (config == null || !config.enabled || !config.isValid) {
    return;
  }

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();

      if (config.type == AppProxyType.socks5) {
        // SOCKS5 proxy
        socks5.SocksTCPClient.assignToHttpClient(client, [
          socks5.ProxySettings(
            InternetAddress(config.host),
            config.port,
            username: config.hasAuth ? config.username : null,
            password: config.hasAuth ? config.password : null,
          ),
        ]);
      } else {
        // HTTP proxy
        client.findProxy = (uri) {
          if (config.hasAuth) {
            return 'PROXY ${config.username}:${config.password}@${config.host}:${config.port}';
          }
          return 'PROXY ${config.host}:${config.port}';
        };
      }

      return client;
    },
  );
}

// Dio instance for authentication (no auth header)
final authDioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  _configureDioProxy(dio, _currentProxyConfig);
  return dio;
});

// Token Refresh Service (lazily initialized to avoid circular dependencies)
TokenRefreshService? _tokenRefreshService;

TokenRefreshService _getOrCreateTokenRefreshService(
  AuthLocalDataSource authDataSource,
  CredentialsLocalDataSource credentialsDataSource,
  Dio authDio,
) {
  _tokenRefreshService ??= TokenRefreshService(
    authDataSource: authDataSource,
    credentialsDataSource: credentialsDataSource,
    dio: authDio,
  );
  return _tokenRefreshService!;
}

// Dio instance for API calls (with auth interceptor and auto-refresh)
final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.spotifyApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Configure proxy if available
  _configureDioProxy(dio, _currentProxyConfig);

  // Use ref.read inside interceptor to get fresh data source each time
  // This ensures we don't use a stale placeholder when SharedPreferences loads
  final authDio = ref.read(authDioProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Dynamically get the data source to ensure we have the latest
        final authLocalDataSource = ref.read(authLocalDataSourceProvider);
        final token = await authLocalDataSource.getAccessToken();
        AppLogger.info('API Request - Token available: ${token != null}');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - attempt to refresh token
        if (error.response?.statusCode == 401) {
          AppLogger.info('Received 401, attempting to refresh token...');
          AppLogger.info('Request URL: ${error.requestOptions.uri}');

          // Get fresh data sources for token refresh
          final authLocalDataSource = ref.read(authLocalDataSourceProvider);
          final credentialsDataSource = ref.read(credentialsLocalDataSourceProvider);

          final tokenRefreshService = _getOrCreateTokenRefreshService(
            authLocalDataSource,
            credentialsDataSource,
            authDio,
          );

          final newToken = await tokenRefreshService.refreshToken();

          if (newToken != null) {
            // Retry the original request with new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            try {
              final response = await dio.fetch(opts);
              handler.resolve(response);
              return;
            } on DioException catch (e) {
              handler.next(e);
              return;
            }
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

// Platform Services
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return AppLinksDeepLinkService();
});

final urlLauncherServiceProvider = Provider<UrlLauncherService>((ref) {
  return DefaultUrlLauncherService();
});

final windowServiceProvider = Provider<WindowService>((ref) {
  return WindowManagerService();
});

final miniPlayerServiceProvider = Provider<MiniPlayerService>((ref) {
  final windowService = ref.watch(windowServiceProvider);
  return MiniPlayerService(windowService);
});

// Auth Local Data Source (needed by apiDioProvider, so kept here)
// Uses SharedPreferences on macOS/iOS to avoid Keychain issues during development
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  if (Platform.isMacOS || Platform.isIOS) {
    final prefsAsync = ref.watch(sharedPrefsProvider);
    return prefsAsync.when(
      data: (prefs) => AuthSharedPrefsDataSource(prefs),
      loading: () => _PlaceholderAuthDataSource(),
      error: (_, __) => _PlaceholderAuthDataSource(),
    );
  }
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(secureStorage);
});

/// Placeholder implementation while SharedPreferences is loading
class _PlaceholderAuthDataSource implements AuthLocalDataSource {
  @override
  Future<void> clearTokens() async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<DateTime?> getTokenExpiry() async => null;
  @override
  Future<bool> hasValidToken() async => false;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {}
}

// Dio instance for LLM API calls (with proxy support)
final llmDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );
  _configureDioProxy(dio, _currentProxyConfig);
  return dio;
});
