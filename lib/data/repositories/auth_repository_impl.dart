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
import '../datasources/spotify_api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final SpotifyApiClient apiClient;
  final Dio dio;
  final OAuthService oauthService;
  final String clientId;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.apiClient,
    required this.dio,
    required this.oauthService,
    required this.clientId,
  });

  @override
  Future<void> cancelAuthentication() async {
    await oauthService.cancel();
  }

  @override
  Future<Either<Failure, String>> authenticate() async {
    try {
      // Use OAuth service to get authorization code (with PKCE code_verifier)
      final authResult = await oauthService.authorize(
        clientId: clientId,
        scopes: AppConfig.spotifyScopes,
      );

      return authResult.fold((failure) => Left(failure), (result) async {
        // Exchange code for tokens using PKCE
        final tokenResponse = await _exchangeCodeForTokens(
          result.code,
          clientId,
          result.codeVerifier,
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
    String codeVerifier,
  ) async {
    AppLogger.info('Exchanging code for tokens (PKCE)...');
    AppLogger.info('Client ID: ${clientId.substring(0, 4)}...${clientId.substring(clientId.length - 4)}');
    AppLogger.info('Redirect URI: ${AppConfig.spotifyRedirectUri}');
    AppLogger.info('Code: ${code.substring(0, 10)}...');

    try {
      final response = await dio.post(
        AppConfig.spotifyTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': AppConfig.spotifyRedirectUri,
          'client_id': clientId,
          'code_verifier': codeVerifier,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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
    } on DioException catch (e) {
      AppLogger.error('Token exchange failed with status: ${e.response?.statusCode}');
      AppLogger.error('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure(message: 'No refresh token available'));
      }

      final response = await dio.post(
        AppConfig.spotifyTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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
