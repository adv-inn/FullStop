import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/oauth_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/credentials_local_datasource.dart';
import '../datasources/spotify_api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final CredentialsLocalDataSource credentialsDataSource;
  final SpotifyApiClient apiClient;
  final Dio dio;
  final OAuthService oauthService;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.credentialsDataSource,
    required this.apiClient,
    required this.dio,
    required this.oauthService,
  });

  @override
  Future<void> cancelAuthentication() async {
    await oauthService.cancel();
  }

  @override
  Future<Either<Failure, String>> authenticate() async {
    try {
      // Get credentials from secure storage
      final clientId = await credentialsDataSource.getSpotifyClientId();
      final clientSecret = await credentialsDataSource.getSpotifyClientSecret();

      if (clientId == null ||
          clientId.isEmpty ||
          clientSecret == null ||
          clientSecret.isEmpty) {
        return const Left(
          AuthFailure(
            message:
                'Spotify API credentials not configured. Please set up your credentials first.',
          ),
        );
      }

      // Use OAuth service to get authorization code
      final authResult = await oauthService.authorize(
        clientId: clientId,
        scopes: AppConfig.spotifyScopes,
      );

      return authResult.fold((failure) => Left(failure), (result) async {
        // Exchange code for tokens
        final tokenResponse = await _exchangeCodeForTokens(
          result.code,
          clientId,
          clientSecret,
        );

        AppLogger.info('Authentication completed successfully');
        return Right(tokenResponse['access_token'] as String);
      });
    } catch (e) {
      AppLogger.error('Authentication failed', e);
      return Left(AuthFailure(message: 'Authentication failed: $e'));
    }
  }

  Future<Map<String, dynamic>> _exchangeCodeForTokens(
    String code,
    String clientId,
    String clientSecret,
  ) async {
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await dio.post(
      AppConfig.spotifyTokenUrl,
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': AppConfig.spotifyRedirectUri,
      },
      options: Options(
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final data = response.data as Map<String, dynamic>;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final expiresIn = data['expires_in'] as int;
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));

    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
    );

    AppLogger.info('Tokens saved successfully');

    return data;
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure(message: 'No refresh token available'));
      }

      // Get credentials from secure storage
      final clientId = await credentialsDataSource.getSpotifyClientId();
      final clientSecret = await credentialsDataSource.getSpotifyClientSecret();

      if (clientId == null ||
          clientId.isEmpty ||
          clientSecret == null ||
          clientSecret.isEmpty) {
        return const Left(
          AuthFailure(message: 'Spotify API credentials not configured.'),
        );
      }

      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await dio.post(
        AppConfig.spotifyTokenUrl,
        data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data as Map<String, dynamic>;

      final accessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;
      final expiresIn = data['expires_in'] as int;
      final expiry = DateTime.now().add(Duration(seconds: expiresIn));

      await localDataSource.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        expiry: expiry,
      );

      AppLogger.info('Token refreshed successfully');

      return Right(accessToken);
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      return Left(AuthFailure(message: 'Token refresh failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await apiClient.getCurrentUser();
      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(
        SpotifyApiFailure(
          message: e.message ?? 'Failed to get user profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.hasValidToken();
  }

  @override
  Future<String?> getAccessToken() async {
    return await localDataSource.getAccessToken();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearTokens();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
