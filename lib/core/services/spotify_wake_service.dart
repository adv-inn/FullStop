import 'dart:io';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Service for waking up the Spotify app using the Spotify SDK
class SpotifyWakeService {
  /// Attempts to wake up Spotify by connecting via SDK
  /// Returns true if connection successful, false otherwise
  static Future<bool> wakeSpotify({required String clientId}) async {
    // SDK is only available on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      AppLogger.info(
        'SpotifyWakeService: SDK not available on desktop, skipping',
      );
      return false;
    }

    try {
      AppLogger.info(
        'SpotifyWakeService: Attempting to wake Spotify via SDK...',
      );

      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: AppConfig.spotifyRedirectUri,
      );

      if (result) {
        AppLogger.info(
          'SpotifyWakeService: Successfully connected to Spotify Remote',
        );
        // Give Spotify a moment to fully wake up
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      } else {
        AppLogger.warning('SpotifyWakeService: Connection returned false');
        return false;
      }
    } catch (e) {
      AppLogger.error('SpotifyWakeService: Failed to connect to Spotify', e);
      return false;
    }
  }

  /// Check if Spotify SDK is available on this platform
  static bool get isAvailable => Platform.isAndroid || Platform.isIOS;

  /// Disconnect from Spotify Remote (cleanup)
  static Future<void> disconnect() async {
    if (!isAvailable) return;

    try {
      await SpotifySdk.disconnect();
      AppLogger.info('SpotifyWakeService: Disconnected from Spotify Remote');
    } catch (e) {
      AppLogger.error('SpotifyWakeService: Error disconnecting', e);
    }
  }
}
