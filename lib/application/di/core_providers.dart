import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socks5_proxy/socks_client.dart' as socks5;
import '../../core/config/app_config.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/mini_player_service.dart';
import '../../core/services/token_refresh_service.dart';
import '../../core/services/url_launcher_service.dart';
import '../../core/services/window_service.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/credentials_local_datasource.dart';
import '../../domain/entities/proxy_settings.dart';
import '../../data/services/app_links_deep_link_service.dart';
import '../../data/services/default_url_launcher_service.dart';
import '../../data/services/window_manager_service.dart';

/// Core infrastructure providers
/// These are low-level services that other modules depend on

// Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
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

  final authLocalDataSource = ref.read(authLocalDataSourceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  final credentialsLocalDataSource = CredentialsLocalDataSourceImpl(
    secureStorage,
  );
  final authDio = ref.read(authDioProvider);

  final tokenRefreshService = _getOrCreateTokenRefreshService(
    authLocalDataSource,
    credentialsLocalDataSource,
    authDio,
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authLocalDataSource.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - attempt to refresh token
        if (error.response?.statusCode == 401) {
          AppLogger.info('Received 401, attempting to refresh token...');

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
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(secureStorage);
});

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
