import 'dart:async';
import 'package:dartz/dartz.dart';
import '../config/app_config.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';
import 'deep_link_service.dart';
import 'url_launcher_service.dart';

/// Exception thrown when authentication is cancelled by user
class AuthCancelledException implements Exception {
  final String message;
  const AuthCancelledException([this.message = 'Authentication cancelled']);
}

/// Result of OAuth authorization containing the authorization code
class OAuthAuthorizationResult {
  final String code;
  final String state;

  const OAuthAuthorizationResult({required this.code, required this.state});
}

/// Abstract OAuth service interface
abstract class OAuthService {
  /// Start the OAuth authorization flow
  /// Returns the authorization code on success
  Future<Either<Failure, OAuthAuthorizationResult>> authorize({
    required String clientId,
    required List<String> scopes,
  });

  /// Cancel an ongoing authentication
  Future<void> cancel();

  /// Whether an authentication is currently in progress
  bool get isAuthenticating;
}

/// Spotify OAuth implementation using deep links
class SpotifyOAuthService implements OAuthService {
  final DeepLinkService deepLinkService;
  final UrlLauncherService urlLauncherService;

  StreamSubscription<Uri>? _linkSubscription;
  Completer<Uri>? _activeCompleter;
  bool _isCancelled = false;
  String? _expectedState;
  bool _isAuthenticating = false;

  SpotifyOAuthService({
    required this.deepLinkService,
    required this.urlLauncherService,
  });

  @override
  bool get isAuthenticating => _isAuthenticating;

  @override
  Future<void> cancel() async {
    AppLogger.info('Cancelling OAuth authentication...');
    _isCancelled = true;

    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.completeError(const AuthCancelledException());
    }

    await _cleanup();
    AppLogger.info('OAuth authentication cancelled and cleaned up');
  }

  Future<void> _cleanup() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _activeCompleter = null;
    _expectedState = null;
    _isAuthenticating = false;
  }

  @override
  Future<Either<Failure, OAuthAuthorizationResult>> authorize({
    required String clientId,
    required List<String> scopes,
  }) async {
    // Prevent multiple simultaneous auth attempts
    if (_isAuthenticating) {
      AppLogger.info(
        'OAuth already in progress, cancelling previous attempt...',
      );
      await cancel();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Reset state for new authentication
    _isCancelled = false;
    _isAuthenticating = true;
    await _cleanup();

    AppLogger.info('Starting OAuth authorization flow...');

    try {
      if (_isCancelled) {
        _isAuthenticating = false;
        return const Left(AuthFailure(message: 'Authentication cancelled'));
      }

      // Build authorization URL
      final authUrl = _buildAuthorizationUrl(clientId, scopes);

      AppLogger.info('Using redirect URI: ${AppConfig.spotifyRedirectUri}');

      // Set up deep link listener before opening browser
      _activeCompleter = Completer<Uri>();

      AppLogger.info('Setting up deep link listener...');
      _linkSubscription = deepLinkService.uriStream.listen(
        _onDeepLinkReceived,
        onError: _onDeepLinkError,
      );
      AppLogger.info('Deep link listener set up successfully');

      if (_isCancelled) {
        await _cleanup();
        return const Left(AuthFailure(message: 'Authentication cancelled'));
      }

      AppLogger.info('Opening authorization URL in browser...');

      // Open browser for user authorization
      final launched = await urlLauncherService.launchInBrowser(authUrl);

      if (!launched) {
        await _cleanup();
        return const Left(
          AuthFailure(message: 'Could not open browser for authentication'),
        );
      }

      // Wait for callback with 5 minute timeout
      final callbackUri = await _activeCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Authentication timed out');
        },
      );

      // Process the callback
      return await _processCallback(callbackUri);
    } on AuthCancelledException {
      _isAuthenticating = false;
      return const Left(
        AuthFailure(message: 'Authentication cancelled by user'),
      );
    } on TimeoutException {
      await _cleanup();
      return const Left(
        AuthFailure(message: 'Authentication timed out. Please try again.'),
      );
    } catch (e) {
      await _cleanup();
      AppLogger.error('OAuth authorization failed', e);
      return Left(AuthFailure(message: 'Authentication failed: $e'));
    }
  }

  Uri _buildAuthorizationUrl(String clientId, List<String> scopes) {
    final scopeString = scopes.join(' ');
    _expectedState = DateTime.now().millisecondsSinceEpoch.toString();

    return Uri.parse(AppConfig.spotifyAuthUrl).replace(
      queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': AppConfig.spotifyRedirectUri,
        'scope': scopeString,
        'state': _expectedState,
        'show_dialog': 'true',
      },
    );
  }

  void _onDeepLinkReceived(Uri uri) {
    AppLogger.info('Received deep link: $uri');
    if (uri.scheme == AppConfig.urlScheme &&
        _activeCompleter != null &&
        !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(uri);
    }
  }

  void _onDeepLinkError(dynamic error) {
    AppLogger.error('Deep link stream error', error);
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.completeError(error as Object);
    }
  }

  Future<Either<Failure, OAuthAuthorizationResult>> _processCallback(
    Uri callbackUri,
  ) async {
    final expectedState = _expectedState;

    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _activeCompleter = null;

    final params = callbackUri.queryParameters;

    // Check for errors
    final error = params['error'];
    if (error != null) {
      final errorDescription = params['error_description'] ?? error;
      _expectedState = null;
      _isAuthenticating = false;
      return Left(AuthFailure(message: 'OAuth error: $errorDescription'));
    }

    // Verify state
    final returnedState = params['state'];
    if (returnedState != expectedState) {
      AppLogger.error(
        'State mismatch: expected=$expectedState, returned=$returnedState',
      );
      _expectedState = null;
      _isAuthenticating = false;
      return Left(
        AuthFailure(message: 'Invalid state parameter - possible CSRF attack'),
      );
    }
    _expectedState = null;

    // Get authorization code
    final code = params['code'];
    if (code == null) {
      _isAuthenticating = false;
      return const Left(AuthFailure(message: 'No authorization code received'));
    }

    _isAuthenticating = false;
    AppLogger.info('OAuth authorization completed successfully');

    return Right(OAuthAuthorizationResult(code: code, state: returnedState!));
  }
}
