import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/repositories/playback_repository.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';
import 'spotify_wake_service.dart';

/// Result of device activation attempt
class DeviceActivationResult {
  final String deviceId;
  final bool wasActivated;
  final bool fromCache;

  const DeviceActivationResult({
    required this.deviceId,
    required this.wasActivated,
    this.fromCache = false,
  });
}

/// Service for finding and activating Spotify devices with retry logic
///
/// OPTIMIZATION: Uses singleton pattern with smart device caching
/// to avoid redundant API calls within a short time window.
class DeviceActivationService {
  final PlaybackRepository playbackRepository;
  final String? clientId;

  /// Maximum retry attempts for polling devices
  static const int _maxRetries = 3;

  /// Delay between retry attempts
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Delay after transferring playback to let state sync
  static const Duration _transferDelay = Duration(milliseconds: 300);

  /// Cache duration for device ID (10 minutes)
  static const Duration _cacheDuration = Duration(minutes: 10);

  // ============ SMART CACHING ============
  /// Cached device ID from last successful activation
  static String? _lastActiveDeviceId;

  /// Timestamp of last successful device activation
  static DateTime? _lastActiveTime;

  /// Singleton instance for caching benefits
  static DeviceActivationService? _instance;

  /// Factory constructor that returns singleton instance
  /// This ensures cache is shared across all usages
  factory DeviceActivationService.instance({
    required PlaybackRepository playbackRepository,
    String? clientId,
  }) {
    _instance ??= DeviceActivationService._(
      playbackRepository: playbackRepository,
      clientId: clientId,
    );
    // Update repository reference in case it changed
    return DeviceActivationService._(
      playbackRepository: playbackRepository,
      clientId: clientId,
    );
  }

  /// Private constructor
  DeviceActivationService._({required this.playbackRepository, this.clientId});

  /// Legacy constructor for backwards compatibility
  DeviceActivationService({required this.playbackRepository, this.clientId});

  /// Clear the device cache (call when user logs out or changes account)
  static void clearCache() {
    _lastActiveDeviceId = null;
    _lastActiveTime = null;
    AppLogger.info('DeviceActivationService: Cache cleared');
  }

  /// Find and activate a device with retry logic
  /// Returns the device ID if successful, or a failure
  ///
  /// OPTIMIZATION: Uses smart caching but validates device is still available
  Future<Either<Failure, DeviceActivationResult>> ensureActiveDevice() async {
    // ============ CACHE HIT CHECK WITH VALIDATION ============
    // If we have a cached device ID, validate it's still available
    if (_lastActiveDeviceId != null &&
        _lastActiveTime != null &&
        DateTime.now().difference(_lastActiveTime!) < _cacheDuration) {
      AppLogger.info(
        'DeviceActivationService: Cache hit, validating device: $_lastActiveDeviceId '
        '(age: ${DateTime.now().difference(_lastActiveTime!).inSeconds}s)',
      );

      // Quick validation: check if cached device is still in the device list
      final devicesResult = await playbackRepository.getAvailableDevices();
      final devices = devicesResult.fold(
        (failure) => <Device>[],
        (devices) => devices,
      );

      final cachedDevice = devices
          .where((d) => d.id == _lastActiveDeviceId)
          .firstOrNull;
      if (cachedDevice != null) {
        AppLogger.info(
          'DeviceActivationService: Cached device validated, still available',
        );
        // Device exists - if not active, try to activate it
        if (!cachedDevice.isActive) {
          AppLogger.info(
            'DeviceActivationService: Cached device is zombie, activating...',
          );
          final activationResult = await _activateDevice(devices);
          if (activationResult != null) {
            _updateCache(activationResult.deviceId);
            return Right(activationResult);
          }
          // Activation failed, fall through to full discovery
        } else {
          // Device is active, use it
          return Right(
            DeviceActivationResult(
              deviceId: _lastActiveDeviceId!,
              wasActivated: false,
              fromCache: true,
            ),
          );
        }
      } else {
        AppLogger.warning(
          'DeviceActivationService: Cached device no longer available, clearing cache',
        );
        clearCache();
      }
    }

    AppLogger.info('DeviceActivationService: Starting device discovery...');

    // Step 1: First check if we already have available devices (no wake needed)
    final initialDevicesResult = await playbackRepository.getAvailableDevices();
    final initialDevices = initialDevicesResult.fold(
      (failure) => <Device>[],
      (devices) => devices,
    );

    if (initialDevices.isNotEmpty) {
      AppLogger.info(
        'DeviceActivationService: Found ${initialDevices.length} device(s) immediately',
      );
      final activationResult = await _activateDevice(initialDevices);
      if (activationResult != null) {
        _updateCache(activationResult.deviceId);
        return Right(activationResult);
      }
    }

    // Step 2: No devices found - fire wake attempt based on platform
    AppLogger.info(
      'DeviceActivationService: No devices found, attempting to wake Spotify...',
    );
    _fireWakeAttempt();

    // Step 3: Poll for devices with retry (fewer retries since we already checked once)
    for (int retry = 0; retry < _maxRetries; retry++) {
      AppLogger.info(
        'DeviceActivationService: Polling attempt ${retry + 1}/$_maxRetries',
      );

      // Wait before polling to give Spotify time to start
      await Future<void>.delayed(_retryDelay);

      final devicesResult = await playbackRepository.getAvailableDevices();
      final devices = devicesResult.fold(
        (failure) => <Device>[],
        (devices) => devices,
      );

      if (devices.isNotEmpty) {
        // Found devices - try to activate one
        final activationResult = await _activateDevice(devices);
        if (activationResult != null) {
          _updateCache(activationResult.deviceId);
          return Right(activationResult);
        }
      }
    }

    // All retries exhausted - try Deep Link as final fallback (only on desktop)
    if (!Platform.isAndroid && !Platform.isIOS) {
      AppLogger.info(
        'DeviceActivationService: Retries exhausted, trying Deep Link fallback...',
      );
      final deepLinkResult = await _tryDeepLinkFallback();
      if (deepLinkResult != null) {
        _updateCache(deepLinkResult.deviceId);
        return Right(deepLinkResult);
      }
    }

    // Complete failure - clear cache since device may have disconnected
    clearCache();
    AppLogger.warning('DeviceActivationService: Failed to find any device');
    return const Left(PlaybackFailure(message: 'SPOTIFY_CONNECTION_FAILED'));
  }

  /// Update the device cache after successful activation
  void _updateCache(String deviceId) {
    _lastActiveDeviceId = deviceId;
    _lastActiveTime = DateTime.now();
    AppLogger.info(
      'DeviceActivationService: Cache updated with device: $deviceId',
    );
  }

  /// Fire and forget wake attempt based on platform
  void _fireWakeAttempt() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use SDK wake (fire and forget)
      if (clientId != null) {
        AppLogger.info('DeviceActivationService: Firing SDK wake (mobile)...');
        SpotifyWakeService.wakeSpotify(clientId: clientId!).catchError((_) {
          AppLogger.warning(
            'DeviceActivationService: SDK wake failed (ignored)',
          );
          return false;
        });
      }
    } else {
      // Desktop: Use Deep Link wake (fire and forget)
      AppLogger.info(
        'DeviceActivationService: Firing Deep Link wake (desktop)...',
      );
      _launchSpotifyDeepLink().catchError((_) {
        AppLogger.warning(
          'DeviceActivationService: Deep Link wake failed (ignored)',
        );
        return false;
      });
    }
  }

  /// Try to activate a device from the list
  /// Returns activation result if successful, null otherwise
  Future<DeviceActivationResult?> _activateDevice(List<Device> devices) async {
    // Prefer active device, otherwise use first available
    final activeDevice = devices.where((d) => d.isActive).firstOrNull;
    final targetDevice = activeDevice ?? devices.first;

    AppLogger.info(
      'DeviceActivationService: Found device "${targetDevice.name}" '
      '(active: ${targetDevice.isActive})',
    );

    // If device is already active, we're good
    if (targetDevice.isActive) {
      return DeviceActivationResult(
        deviceId: targetDevice.id,
        wasActivated: false,
      );
    }

    // Device is in "zombie" state - need to transfer playback to wake it
    AppLogger.info(
      'DeviceActivationService: Device is zombie, transferring playback...',
    );
    final transferResult = await playbackRepository.transferPlayback(
      targetDevice.id,
      play: false, // Don't start playing yet
    );

    final isSuccess = transferResult.isRight();
    if (!isSuccess) {
      final failure = transferResult.fold((f) => f, (_) => null);
      AppLogger.error(
        'DeviceActivationService: Transfer failed: ${failure?.message}',
      );
      return null;
    }

    // Wait for state to sync
    await Future<void>.delayed(_transferDelay);
    AppLogger.info('DeviceActivationService: Device activated successfully');
    return DeviceActivationResult(
      deviceId: targetDevice.id,
      wasActivated: true,
    );
  }

  /// Try Deep Link as final fallback with additional polling
  Future<DeviceActivationResult?> _tryDeepLinkFallback() async {
    // Launch Deep Link
    final launched = await _launchSpotifyDeepLink();
    if (!launched) {
      AppLogger.warning('DeviceActivationService: Deep Link not available');
      return null;
    }

    AppLogger.info(
      'DeviceActivationService: Deep Link launched, polling for devices...',
    );

    // Poll for devices after Deep Link (3 attempts, 1 second apart)
    for (int i = 0; i < 3; i++) {
      await Future<void>.delayed(_retryDelay);

      final devicesResult = await playbackRepository.getAvailableDevices();
      final devices = devicesResult.fold(
        (failure) => <Device>[],
        (devices) => devices,
      );

      if (devices.isNotEmpty) {
        final result = await _activateDevice(devices);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  /// Launch Spotify via Deep Link (spotify:)
  Future<bool> _launchSpotifyDeepLink() async {
    try {
      final spotifyUri = Uri.parse('spotify:');

      if (await canLaunchUrl(spotifyUri)) {
        AppLogger.info(
          'DeviceActivationService: Launching spotify: deep link...',
        );
        await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        AppLogger.warning(
          'DeviceActivationService: Cannot launch spotify: URI',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('DeviceActivationService: Deep Link error', e);
      return false;
    }
  }
}
