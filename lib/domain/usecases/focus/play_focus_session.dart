import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/device_activation_service.dart';
import '../../../core/utils/logger.dart';
import '../../entities/focus_session.dart';
import '../../repositories/focus_session_repository.dart';
import '../../repositories/playback_repository.dart';
import '../usecase.dart';

class PlayFocusSession extends UseCase<void, PlayFocusSessionParams> {
  final PlaybackRepository playbackRepository;
  final FocusSessionRepository focusRepository;
  final String? clientId;

  PlayFocusSession({
    required this.playbackRepository,
    required this.focusRepository,
    this.clientId,
  });

  @override
  Future<Either<Failure, void>> call(PlayFocusSessionParams params) async {
    final session = params.session;

    if (session.tracks.isEmpty) {
      return const Left(PlaybackFailure(message: 'No tracks in focus session'));
    }

    // Determine which device to use
    String? deviceId = params.deviceId;

    // If no device specified, use DeviceActivationService to find and activate one
    // OPTIMIZATION: Use singleton instance for caching benefits
    if (deviceId == null) {
      final activationService = DeviceActivationService.instance(
        playbackRepository: playbackRepository,
        clientId: clientId,
      );

      final activationResult = await activationService.ensureActiveDevice();

      final result = activationResult.fold((failure) => failure, (result) {
        deviceId = result.deviceId;
        return null;
      });

      if (result != null) {
        return Left(result);
      }
    }

    // Get track URIs
    List<String> trackUris = session.tracks.map((t) => t.uri).toList();

    // Determine the starting offset
    int? offsetPosition;

    // If user clicked a specific track, start from that position
    if (params.startIndex != null) {
      offsetPosition = params.startIndex;
    } else if (session.settings.shuffle) {
      // Only shuffle when playing the whole session (not clicking a track)
      trackUris = List.from(trackUris)..shuffle();
    }

    // CRITICAL PATH: Start playback - this is what the user is waiting for
    AppLogger.info(
      'PlayFocusSession: Starting playback with ${trackUris.length} tracks '
      'on device: $deviceId',
    );

    final playResult = await playbackRepository.play(
      uris: trackUris,
      deviceId: deviceId,
      offsetPosition: offsetPosition,
    );

    if (playResult.isLeft()) {
      // 🚨 CACHE INVALIDATION: If play fails, the cached device may be offline
      // Clear cache so next attempt will re-discover devices instead of using stale ID
      DeviceActivationService.clearCache();
      final failure = playResult.fold((f) => f, (_) => null);
      AppLogger.warning(
        'PlayFocusSession: Play failed (${failure?.message}), cleared device cache.',
      );
      return playResult;
    }

    AppLogger.info('PlayFocusSession: Playback started successfully');

    // OPTIMIZATION: Fire-and-forget for non-critical operations
    // These don't affect immediate playback, so don't block on them
    _executeNonCriticalTasks(session, deviceId);

    return const Right(null);
  }

  /// Execute non-critical tasks asynchronously (fire-and-forget)
  /// These operations don't affect immediate playback experience
  void _executeNonCriticalTasks(FocusSession session, String? deviceId) {
    Future.wait([
      // Set repeat mode
      playbackRepository.setRepeatMode(
        session.settings.repeatMode,
        deviceId: deviceId,
      ),
      // Update last played timestamp
      focusRepository.updateLastPlayed(session.id),
    ]).catchError((e) {
      // Non-fatal: log but don't crash
      AppLogger.warning('Non-critical playback tasks failed: $e');
      return <Either<Failure, void>>[];
    });
  }
}

class PlayFocusSessionParams extends Equatable {
  final FocusSession session;
  final String? deviceId;

  /// Starting track index when user clicks a specific track
  final int? startIndex;

  const PlayFocusSessionParams({
    required this.session,
    this.deviceId,
    this.startIndex,
  });

  @override
  List<Object?> get props => [session, deviceId, startIndex];
}
