import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Authenticate user with Spotify OAuth
  Future<Either<Failure, String>> authenticate();

  /// Cancel the current authentication flow
  Future<void> cancelAuthentication();

  /// Refresh access token using refresh token
  Future<Either<Failure, String>> refreshToken();

  /// Get current user profile
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Logout and clear stored tokens
  Future<Either<Failure, void>> logout();
}
