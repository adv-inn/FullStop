import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/dio_error_handler.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/repositories/playback_repository.dart';
import '../datasources/spotify_api_client.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  final SpotifyApiClient apiClient;

  PlaybackRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, PlaybackState>> getPlaybackState() async {
    try {
      final model = await apiClient.getPlaybackState();
      if (model == null) {
        return const Right(PlaybackState());
      }
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Get playback state',
        ),
      );
    } catch (e) {
      AppLogger.error('Get playback state failed', e);
      return Left(PlaybackFailure(message: 'Failed to get playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Device>>> getAvailableDevices() async {
    try {
      final response = await apiClient.getAvailableDevices();
      final devices = response.devices.map((d) => d.toEntity()).toList();
      return Right(devices);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Get devices',
        ),
      );
    } catch (e) {
      AppLogger.error('Get devices failed', e);
      return Left(PlaybackFailure(message: 'Failed to get devices: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> transferPlayback(
    String deviceId, {
    bool play = true,
  }) async {
    try {
      await apiClient.transferPlayback({
        'device_ids': [deviceId],
        'play': play,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Transfer playback',
        ),
      );
    } catch (e) {
      AppLogger.error('Transfer playback failed', e);
      return Left(PlaybackFailure(message: 'Failed to transfer playback: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> play({
    String? deviceId,
    String? contextUri,
    List<String>? uris,
    int? offsetPosition,
    int? positionMs,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (contextUri != null) {
        body['context_uri'] = contextUri;
      }
      if (uris != null && uris.isNotEmpty) {
        body['uris'] = uris;
      }
      if (offsetPosition != null) {
        body['offset'] = {'position': offsetPosition};
      }
      if (positionMs != null) {
        body['position_ms'] = positionMs;
      }

      await apiClient.play(
        deviceId: deviceId,
        body: body.isEmpty ? null : body,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Play',
        ),
      );
    } catch (e) {
      AppLogger.error('Play failed', e);
      return Left(PlaybackFailure(message: 'Failed to start playback: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pause({String? deviceId}) async {
    try {
      await apiClient.pause(deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Pause',
        ),
      );
    } catch (e) {
      AppLogger.error('Pause failed', e);
      return Left(PlaybackFailure(message: 'Failed to pause: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToNext({String? deviceId}) async {
    try {
      await apiClient.skipToNext(deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Skip next',
        ),
      );
    } catch (e) {
      AppLogger.error('Skip next failed', e);
      return Left(PlaybackFailure(message: 'Failed to skip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToPrevious({String? deviceId}) async {
    try {
      await apiClient.skipToPrevious(deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Skip previous',
        ),
      );
    } catch (e) {
      AppLogger.error('Skip previous failed', e);
      return Left(PlaybackFailure(message: 'Failed to skip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> seekToPosition(
    int positionMs, {
    String? deviceId,
  }) async {
    try {
      await apiClient.seekToPosition(positionMs, deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Seek',
        ),
      );
    } catch (e) {
      AppLogger.error('Seek failed', e);
      return Left(PlaybackFailure(message: 'Failed to seek: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(
    RepeatMode mode, {
    String? deviceId,
  }) async {
    try {
      final state = switch (mode) {
        RepeatMode.off => 'off',
        RepeatMode.context => 'context',
        RepeatMode.track => 'track',
      };
      await apiClient.setRepeatMode(state, deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Set repeat mode',
        ),
      );
    } catch (e) {
      AppLogger.error('Set repeat mode failed', e);
      return Left(PlaybackFailure(message: 'Failed to set repeat mode: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setShuffle(
    bool state, {
    String? deviceId,
  }) async {
    try {
      await apiClient.setShuffle(state, deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Set shuffle',
        ),
      );
    } catch (e) {
      AppLogger.error('Set shuffle failed', e);
      return Left(PlaybackFailure(message: 'Failed to set shuffle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(
    int volumePercent, {
    String? deviceId,
  }) async {
    try {
      await apiClient.setVolume(volumePercent, deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Set volume',
        ),
      );
    } catch (e) {
      AppLogger.error('Set volume failed', e);
      return Left(PlaybackFailure(message: 'Failed to set volume: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToQueue(
    String uri, {
    String? deviceId,
  }) async {
    try {
      await apiClient.addToQueue(uri, deviceId: deviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Add to queue',
        ),
      );
    } catch (e) {
      AppLogger.error('Add to queue failed', e);
      return Left(PlaybackFailure(message: 'Failed to add to queue: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isTrackSaved(String trackId) async {
    try {
      final results = await apiClient.checkSavedTracks([trackId]);
      return Right(results.isNotEmpty && results.first);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Check saved track',
        ),
      );
    } catch (e) {
      AppLogger.error('Check saved track failed', e);
      return Left(PlaybackFailure(message: 'Failed to check saved track: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTrack(String trackId) async {
    try {
      await apiClient.saveTracks([trackId]);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Save track',
        ),
      );
    } catch (e) {
      AppLogger.error('Save track failed', e);
      return Left(PlaybackFailure(message: 'Failed to save track: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeTrack(String trackId) async {
    try {
      await apiClient.removeTracks([trackId]);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Remove track',
        ),
      );
    } catch (e) {
      AppLogger.error('Remove track failed', e);
      return Left(PlaybackFailure(message: 'Failed to remove track: $e'));
    }
  }

  @override
  Future<Either<Failure, List<bool>>> areTracksSaved(
    List<String> trackIds,
  ) async {
    try {
      // Spotify limits to 50 IDs per request
      final results = <bool>[];
      for (var i = 0; i < trackIds.length; i += 50) {
        final batch = trackIds.sublist(
          i,
          i + 50 > trackIds.length ? trackIds.length : i + 50,
        );
        final batchResults = await apiClient.checkSavedTracks(batch);
        results.addAll(batchResults);
      }
      return Right(results);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Check saved tracks',
        ),
      );
    } catch (e) {
      AppLogger.error('Check saved tracks failed', e);
      return Left(PlaybackFailure(message: 'Failed to check saved tracks: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTracks(List<String> trackIds) async {
    try {
      // Spotify limits to 50 IDs per request
      for (var i = 0; i < trackIds.length; i += 50) {
        final batch = trackIds.sublist(
          i,
          i + 50 > trackIds.length ? trackIds.length : i + 50,
        );
        await apiClient.saveTracks(batch);
      }
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Save tracks',
        ),
      );
    } catch (e) {
      AppLogger.error('Save tracks failed', e);
      return Left(PlaybackFailure(message: 'Failed to save tracks: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createPlaylistWithTracks({
    required String userId,
    required String name,
    required List<String> trackUris,
    String? description,
  }) async {
    try {
      // Create the playlist
      final playlistData = await apiClient.createPlaylist(
        userId: userId,
        name: name,
        description: description,
      );

      final playlistId = playlistData['id'] as String;

      // Add tracks to the playlist
      if (trackUris.isNotEmpty) {
        await apiClient.addTracksToPlaylist(playlistId, trackUris);
      }

      return Right(playlistId);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(
          e,
          failureType: FailureType.playback,
          context: 'Create playlist',
        ),
      );
    } catch (e) {
      AppLogger.error('Create playlist failed', e);
      return Left(PlaybackFailure(message: 'Failed to create playlist: $e'));
    }
  }
}
