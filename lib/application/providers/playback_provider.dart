import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import 'credentials_provider.dart';
import '../../core/services/device_activation_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/playback_state.dart';
import '../di/injection_container.dart';
import 'focus_session_provider.dart';

/// Result of a like/unlike operation
class LikeResult {
  final bool isLiked;
  final bool success;
  final String? errorMessage;
  final bool needsReauth;

  const LikeResult({
    required this.isLiked,
    required this.success,
    this.errorMessage,
    this.needsReauth = false,
  });

  factory LikeResult.success(bool isLiked) =>
      LikeResult(isLiked: isLiked, success: true);

  factory LikeResult.failure(
    bool currentState,
    String message, {
    bool needsReauth = false,
  }) => LikeResult(
    isLiked: currentState,
    success: false,
    errorMessage: message,
    needsReauth: needsReauth,
  );
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;

  /// Timer for scheduling next poll
  Timer? _pollTimer;

  /// Whether polling is active
  bool _isPolling = false;

  /// Consecutive error count for exponential backoff
  int _errorCount = 0;

  /// Base polling interval (1 second)
  static const Duration _baseInterval = Duration(seconds: 1);

  /// Maximum backoff interval (10 seconds)
  static const int _maxBackoffSeconds = 10;

  PlaybackNotifier(this.ref) : super(const PlaybackState());

  /// Perform a single fetch with error handling and backoff logic
  Future<void> _performFetch() async {
    if (!_isPolling) return;

    final playbackRepo = ref.read(playbackRepositoryProvider);

    try {
      final result = await playbackRepo.getPlaybackState();

      result.fold(
        (failure) {
          // API returned an error (but connection was successful)
          _handleFetchError(failure.message, isNetworkError: false);
        },
        (playbackState) async {
          // ✅ Success: Reset backoff
          _errorCount = 0;

          final previousTrackUri = state.currentTrack?.uri;
          state = playbackState;

          // Clear optimistic UI state now that we have real data from API
          _clearOptimisticState();

          // Check if current track changed and validate against active session
          if (playbackState.currentTrack != null &&
              playbackState.currentTrack!.uri != previousTrackUri) {
            await _validateActiveSession(playbackState.currentTrack!.uri);
          }

          // Schedule next tick at base interval
          _scheduleNextTick(_baseInterval);
        },
      );
    } on SocketException catch (e) {
      // Network-level error (connection failed, timeout, etc.)
      _handleFetchError('Network error: ${e.message}', isNetworkError: true);
    } on HttpException catch (e) {
      // HTTP connection error
      _handleFetchError('Connection error: ${e.message}', isNetworkError: true);
    } catch (e) {
      // Other unexpected errors
      _handleFetchError('Unexpected error: $e', isNetworkError: false);
    }
  }

  /// Handle fetch errors with exponential backoff
  void _handleFetchError(String message, {required bool isNetworkError}) {
    _errorCount++;

    // Calculate backoff delay: 2^errorCount, capped at max
    // errorCount 1 -> 2s, 2 -> 4s, 3 -> 8s, 4+ -> 10s
    final delaySeconds = (1 << _errorCount).clamp(1, _maxBackoffSeconds);

    // Log simplified message during backoff (avoid spamming full stack traces)
    if (_errorCount == 1) {
      AppLogger.warning('Playback polling failed: $message');
    } else if (_errorCount <= 3) {
      AppLogger.info(
        'Playback polling unstable (x$_errorCount). '
        'Retrying in ${delaySeconds}s...',
      );
    }
    // After 3 failures, stay silent to avoid log spam

    _scheduleNextTick(Duration(seconds: delaySeconds));
  }

  /// Schedule the next polling tick
  void _scheduleNextTick(Duration delay) {
    _pollTimer?.cancel();
    if (_isPolling) {
      _pollTimer = Timer(delay, _performFetch);
    }
  }

  /// Clear optimistic UI state when actual state matches expected state
  /// Only clears when Spotify confirms the state we expected
  void _clearOptimisticState() {
    final focusState = ref.read(focusSessionProvider);
    final optimistic = focusState.optimisticIsPlaying;

    // No optimistic state to clear
    if (optimistic == null) return;

    // Only clear when actual state matches optimistic state
    // This prevents UI flickering when Spotify hasn't caught up yet
    if (state.isPlaying == optimistic) {
      ref.read(focusSessionProvider.notifier).clearOptimisticState();
    }
  }

  /// Force an immediate refresh (called after user interactions)
  /// Resets backoff and fetches immediately
  void forceRefresh() {
    _errorCount = 0;
    _scheduleNextTick(Duration.zero);
  }

  /// Legacy method for compatibility - now uses backoff-aware fetch
  Future<void> fetchPlaybackState() async {
    // Reset error count when manually called
    _errorCount = 0;
    await _performFetch();
  }

  void startPolling() {
    stopPolling();
    _isPolling = true;
    _errorCount = 0;
    _scheduleNextTick(Duration.zero); // Start immediately
  }

  void stopPolling() {
    _isPolling = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Validate that the current track is in the active session's queue
  /// If not, clear the active session (user has left our session)
  Future<void> _validateActiveSession(String currentTrackUri) async {
    final focusSessionState = ref.read(focusSessionProvider);

    // No active session, nothing to validate
    if (focusSessionState.activeSessionId == null) return;

    // Get the stored track URIs for the active session
    final focusRepoAsync = await ref.read(
      focusSessionRepositoryProvider.future,
    );
    final storedTrackUris = await focusRepoAsync.getActiveSessionTrackUris();

    // If we have stored track URIs, check if current track is in the list
    if (storedTrackUris != null && storedTrackUris.isNotEmpty) {
      final isInSession = storedTrackUris.contains(currentTrackUri);

      if (!isInSession) {
        // User has left our session - clear active session
        await ref.read(focusSessionProvider.notifier).clearActiveSession();
      }
    }
  }

  Future<void> play({List<String>? uris, String? contextUri}) async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.play(uris: uris, contextUri: contextUri);
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> pause() async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.pause();
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  /// Resume playback without changing the queue
  /// Used when resuming a paused session
  Future<void> resume() async {
    final playbackRepo = ref.read(playbackRepositoryProvider);

    // Ensure we have an active device before resuming
    final activationService = DeviceActivationService.instance(
      playbackRepository: playbackRepo,
      clientId: ref.read(effectiveSpotifyClientIdProvider),
    );

    String? deviceId;
    final activationResult = await activationService.ensureActiveDevice();
    activationResult.fold(
      (failure) => null, // Will try to resume anyway
      (result) => deviceId = result.deviceId,
    );

    // Call play without uris to resume current playback
    await playbackRepo.play(deviceId: deviceId);
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> skipNext() async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.skipToNext();
    // Small delay to allow Spotify to update
    await Future.delayed(const Duration(milliseconds: 300));
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> skipPrevious() async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.skipToPrevious();
    await Future.delayed(const Duration(milliseconds: 300));
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> seekTo(int positionMs) async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.seekToPosition(positionMs);
    state = PlaybackState(
      currentTrack: state.currentTrack,
      isPlaying: state.isPlaying,
      progressMs: positionMs,
      durationMs: state.durationMs,
      device: state.device,
      context: state.context,
      repeatMode: state.repeatMode,
      shuffleState: state.shuffleState,
      timestamp: state.timestamp,
    );
    // No forceRefresh for seek - local state is already updated
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.setRepeatMode(mode);
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> toggleShuffle() async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.setShuffle(!state.shuffleState);
    forceRefresh(); // User action: reset backoff and fetch immediately
  }

  Future<void> setVolume(int volumePercent) async {
    final playbackRepo = ref.read(playbackRepositoryProvider);
    await playbackRepo.setVolume(volumePercent);
  }

  /// Cycle through repeat modes: off -> context -> track -> off
  Future<void> cycleRepeatMode() async {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.context,
      RepeatMode.context => RepeatMode.track,
      RepeatMode.track => RepeatMode.off,
    };
    await setRepeatMode(nextMode);
  }

  /// Check if current track is saved in user's library
  Future<bool> isCurrentTrackSaved() async {
    if (state.currentTrack == null) return false;
    final playbackRepo = ref.read(playbackRepositoryProvider);
    final result = await playbackRepo.isTrackSaved(state.currentTrack!.id);
    return result.fold((failure) => false, (isSaved) => isSaved);
  }

  /// Toggle like state for current track
  Future<LikeResult> toggleCurrentTrackLike(bool currentlyLiked) async {
    if (state.currentTrack == null) {
      return LikeResult.failure(currentlyLiked, 'No track playing');
    }

    final playbackRepo = ref.read(playbackRepositoryProvider);
    final trackId = state.currentTrack!.id;

    final result = currentlyLiked
        ? await playbackRepo.removeTrack(trackId)
        : await playbackRepo.saveTrack(trackId);

    return result.fold(
      (failure) => LikeResult.failure(
        currentlyLiked,
        failure.message,
        needsReauth: failure is AuthFailure,
      ),
      (_) => LikeResult.success(!currentlyLiked),
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);

// Available devices provider
final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final playbackRepo = ref.watch(playbackRepositoryProvider);
  final result = await playbackRepo.getAvailableDevices();
  return result.fold((failure) => [], (devices) => devices);
});

// Provider to check if current track is saved (liked)
// This auto-updates when current track changes
final currentTrackSavedProvider = FutureProvider.autoDispose<bool>((ref) async {
  final playbackState = ref.watch(playbackProvider);
  if (playbackState.currentTrack == null) return false;

  final playbackRepo = ref.watch(playbackRepositoryProvider);
  final result = await playbackRepo.isTrackSaved(
    playbackState.currentTrack!.id,
  );
  return result.fold((failure) => false, (isSaved) => isSaved);
});
