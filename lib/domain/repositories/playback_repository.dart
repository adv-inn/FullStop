import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/playback_state.dart';

abstract class PlaybackRepository {
  /// Get current playback state
  Future<Either<Failure, PlaybackState>> getPlaybackState();

  /// Get available devices
  Future<Either<Failure, List<Device>>> getAvailableDevices();

  /// Transfer playback to a device
  Future<Either<Failure, void>> transferPlayback(
    String deviceId, {
    bool play = true,
  });

  /// Start/Resume playback
  Future<Either<Failure, void>> play({
    String? deviceId,
    String? contextUri,
    List<String>? uris,
    int? offsetPosition,
    int? positionMs,
  });

  /// Pause playback
  Future<Either<Failure, void>> pause({String? deviceId});

  /// Skip to next track
  Future<Either<Failure, void>> skipToNext({String? deviceId});

  /// Skip to previous track
  Future<Either<Failure, void>> skipToPrevious({String? deviceId});

  /// Seek to position
  Future<Either<Failure, void>> seekToPosition(
    int positionMs, {
    String? deviceId,
  });

  /// Set repeat mode
  Future<Either<Failure, void>> setRepeatMode(
    RepeatMode mode, {
    String? deviceId,
  });

  /// Toggle shuffle
  Future<Either<Failure, void>> setShuffle(bool state, {String? deviceId});

  /// Set volume
  Future<Either<Failure, void>> setVolume(
    int volumePercent, {
    String? deviceId,
  });

  /// Add track to queue
  Future<Either<Failure, void>> addToQueue(String uri, {String? deviceId});

  /// Check if a track is saved in user's library
  Future<Either<Failure, bool>> isTrackSaved(String trackId);

  /// Check which tracks are saved in user's library
  Future<Either<Failure, List<bool>>> areTracksSaved(List<String> trackIds);

  /// Save a track to user's library (Like)
  Future<Either<Failure, void>> saveTrack(String trackId);

  /// Save multiple tracks to user's library (Like)
  Future<Either<Failure, void>> saveTracks(List<String> trackIds);

  /// Remove a track from user's library (Unlike)
  Future<Either<Failure, void>> removeTrack(String trackId);

  /// Create a playlist and add tracks to it
  Future<Either<Failure, String>> createPlaylistWithTracks({
    required String userId,
    required String name,
    required List<String> trackUris,
    String? description,
  });
}
