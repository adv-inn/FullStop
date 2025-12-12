import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/constants/album_filters.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/dio_error_handler.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/audio_features.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../datasources/spotify_api_client.dart';

class SpotifyRepositoryImpl implements SpotifyRepository {
  final SpotifyApiClient apiClient;

  SpotifyRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<Artist>>> searchArtists(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.search(
        query,
        'artist',
        limit: limit,
        offset: offset,
      );

      final artists =
          response.artists?.items.map((model) => model.toEntity()).toList() ??
          [];

      return Right(artists);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Search artists'));
    } catch (e) {
      AppLogger.error('Search artists failed', e);
      return Left(SpotifyApiFailure(message: 'Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtist(String artistId) async {
    try {
      final artistModel = await apiClient.getArtist(artistId);
      return Right(artistModel.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get artist'));
    } catch (e) {
      AppLogger.error('Get artist failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get artist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getArtistTopTracks(
    String artistId, {
    String market = 'US',
  }) async {
    try {
      final response = await apiClient.getArtistTopTracks(
        artistId,
        market: market,
      );

      final tracks = response.tracks.map((model) => model.toEntity()).toList();
      return Right(tracks);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get artist top tracks'));
    } catch (e) {
      AppLogger.error('Get artist top tracks failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get top tracks: $e'));
    }
  }

  /// Batch size for concurrent API requests
  /// Reduced to 3 to avoid Spotify 429 rate limiting
  static const int _concurrentBatchSize = 3;

  /// Maximum pages to fetch (circuit breaker to prevent infinite loops)
  /// 50 pages * 50 items = 2500 albums max (more than enough for any artist)
  static const int _maxPaginationPages = 50;

  /// Delay between batches to avoid rate limiting (milliseconds)
  static const int _batchDelayMs = 100;

  @override
  Future<Either<Failure, List<Track>>> getArtistAllTracks(
    String artistId, {
    bool includeFeatures = true,
    bool includeLiveAlbums = false,
    String? market,
    TrackFetchProgressCallback? onProgress,
  }) async {
    try {
      // Phase 1: Get ALL albums for the artist using loop pagination
      // This ensures we fetch the complete discography for prolific artists
      onProgress?.call(0, 1, 'albums');
      final List<String> albumIds = [];
      int offset = 0;
      int pageCount = 0;
      const int pageSize = 50;

      // Loop pagination with circuit breaker
      while (pageCount < _maxPaginationPages) {
        pageCount++;

        final albumsResponse = await apiClient.getArtistAlbums(
          artistId,
          includeGroups: includeFeatures
              ? 'album,single,appears_on'
              : 'album,single',
          limit: pageSize,
          offset: offset,
          market: market,
        );

        // Conditional filtering based on includeLiveAlbums flag
        final targetAlbums = includeLiveAlbums
            ? albumsResponse
                  .items // Unfiltered: Keep everything
            : albumsResponse.items.where((album) {
                // Balanced/DeepDive: Filter out Live/Concert/Compilation albums
                return AlbumFilters.isClean(album.name);
              }).toList();

        albumIds.addAll(targetAlbums.map((a) => a.id));

        // Exit condition: if we got fewer items than pageSize, we've reached the end
        if (albumsResponse.items.length < pageSize) {
          break;
        }

        offset += pageSize;
      }

      // Log if circuit breaker was triggered
      if (pageCount >= _maxPaginationPages) {
        AppLogger.warning(
          'Album pagination hit circuit breaker limit ($_maxPaginationPages pages)',
        );
      }

      // Phase 2: Get tracks from albums using batched concurrent requests
      final totalAlbums = albumIds.length;
      final List<Track> allTracks = [];
      int completedAlbums = 0;

      // Process albums in batches for throttled concurrency
      // Pattern: Horizontal (concurrent batches) + Vertical (pagination inside each album)
      int failedAlbums = 0;
      for (var i = 0; i < albumIds.length; i += _concurrentBatchSize) {
        final batchEnd = (i + _concurrentBatchSize < albumIds.length)
            ? i + _concurrentBatchSize
            : albumIds.length;
        final batchAlbumIds = albumIds.sublist(i, batchEnd);

        // Fire concurrent requests for this batch with error resilience
        // Each request is wrapped in try-catch to prevent "fail fast" behavior
        final batchResults = await Future.wait(
          batchAlbumIds.map((albumId) async {
            try {
              return await _getAlbumTracksWithDetails(albumId, market: market);
            } catch (e) {
              // Resilience: If a single album fails, log it but return empty list
              // This prevents Future.wait from crashing the entire batch
              AppLogger.warning('Failed to fetch album $albumId: $e');
              failedAlbums++;
              return <Track>[];
            }
          }),
        );

        // Collect tracks from batch results
        for (final tracks in batchResults) {
          allTracks.addAll(tracks);
        }

        // Update progress after each batch
        completedAlbums += batchAlbumIds.length;
        onProgress?.call(completedAlbums, totalAlbums, 'tracks');

        // Add delay between batches to avoid rate limiting (429)
        if (i + _concurrentBatchSize < albumIds.length) {
          await Future.delayed(Duration(milliseconds: _batchDelayMs));
        }
      }

      // Log if any albums failed
      if (failedAlbums > 0) {
        AppLogger.warning(
          '$failedAlbums album(s) failed to fetch, continuing with available data',
        );
      }

      // Report completion of track fetching
      onProgress?.call(totalAlbums, totalAlbums, 'tracks');

      // Filter tracks to only include those where the artist is actually a performer
      // This is important for "appears_on" albums which may contain tracks
      // where the target artist is not involved
      final filteredTracks = allTracks.where((track) {
        return track.artists.any((artist) => artist.id == artistId);
      }).toList();

      // Remove duplicates
      final uniqueTracks = <String, Track>{};
      for (final track in filteredTracks) {
        uniqueTracks[track.id] = track;
      }

      final filterStatus = includeLiveAlbums ? 'unfiltered' : 'filtered';
      AppLogger.debug(
        'Album traversal ($filterStatus): ${uniqueTracks.length} tracks from $totalAlbums albums (concurrent batch size: $_concurrentBatchSize)',
      );

      return Right(uniqueTracks.values.toList());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get all artist tracks'));
    } catch (e) {
      AppLogger.error('Get all artist tracks failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get all tracks: $e'));
    }
  }

  /// Helper method to get album tracks with full track details
  /// Used for concurrent batch processing
  /// Uses loop pagination to handle albums with >50 tracks
  ///
  /// Architecture: This runs inside Future.wait (horizontal concurrency),
  /// and handles pagination internally (vertical pagination)
  Future<List<Track>> _getAlbumTracksWithDetails(
    String albumId, {
    String? market,
  }) async {
    final List<Track> tracks = [];
    final List<String> trackIds = [];
    int offset = 0;
    int pageCount = 0;
    const int pageSize = 50;
    const int maxTrackPages =
        20; // Circuit breaker: 20 * 50 = 1000 tracks per album max

    // Loop pagination for album tracks (some albums have >50 tracks)
    while (pageCount < maxTrackPages) {
      pageCount++;

      final tracksResponse = await apiClient.getAlbumTracks(
        albumId,
        limit: pageSize,
        offset: offset,
        market: market,
      );

      trackIds.addAll(tracksResponse.items.map((t) => t.id));

      // Exit condition: if we got fewer items than pageSize, we've reached the end
      if (tracksResponse.items.length < pageSize) {
        break;
      }

      offset += pageSize;
    }

    // Get full track details in batches of 50 (Spotify API limit)
    for (var i = 0; i < trackIds.length; i += 50) {
      final batch = trackIds.skip(i).take(50).toList();
      final ids = batch.join(',');
      final tracksListResponse = await apiClient.getTracks(ids);
      tracks.addAll(tracksListResponse.tracks.map((model) => model.toEntity()));
    }

    return tracks;
  }

  @override
  Future<Either<Failure, List<Track>>> getArtistPopularTracks(
    String artistId,
    String artistName, {
    int limit = 50,
  }) async {
    try {
      // Strategy: Use search API with artist name to get popular tracks
      // Search returns results sorted by popularity by default
      final List<Track> allTracks = [];

      // Fetch in batches of 50 (Spotify API limit)
      // Use multiple queries to get more diverse results
      final queries = [
        'artist:"$artistName"', // Primary: exact artist match
      ];

      for (final query in queries) {
        if (allTracks.length >= limit) break;

        int offset = 0;
        while (allTracks.length < limit && offset < 200) {
          // Max 4 pages
          final response = await apiClient.search(
            query,
            'track',
            limit: 50,
            offset: offset,
          );

          final tracks = response.tracks?.items ?? [];
          if (tracks.isEmpty) break;

          // Filter to only include tracks where this artist is a performer
          final artistTracks = tracks
              .map((model) => model.toEntity())
              .where((track) => track.artists.any((a) => a.id == artistId))
              .toList();

          // Add non-duplicate tracks
          for (final track in artistTracks) {
            if (!allTracks.any((t) => t.id == track.id)) {
              allTracks.add(track);
              if (allTracks.length >= limit) break;
            }
          }

          offset += 50;
        }
      }

      // Sort by popularity (highest first) and take the limit
      allTracks.sort((a, b) => b.popularity.compareTo(a.popularity));
      final result = allTracks.take(limit).toList();

      AppLogger.debug(
        'Quick fetch: got ${result.length} popular tracks for $artistName',
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(
        DioErrorHandler.handle(e, context: 'Get artist popular tracks'),
      );
    } catch (e) {
      AppLogger.error('Get artist popular tracks failed', e);
      return Left(
        SpotifyApiFailure(message: 'Failed to get popular tracks: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Track>>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.search(
        query,
        'track',
        limit: limit,
        offset: offset,
      );

      final tracks =
          response.tracks?.items.map((model) => model.toEntity()).toList() ??
          [];

      return Right(tracks);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Search tracks'));
    } catch (e) {
      AppLogger.error('Search tracks failed', e);
      return Left(SpotifyApiFailure(message: 'Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Track>> getTrack(String trackId) async {
    try {
      final trackModel = await apiClient.getTrack(trackId);
      return Right(trackModel.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get track'));
    } catch (e) {
      AppLogger.error('Get track failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get track: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getTracks(List<String> trackIds) async {
    try {
      final ids = trackIds.join(',');
      final response = await apiClient.getTracks(ids);
      final tracks = response.tracks.map((model) => model.toEntity()).toList();
      return Right(tracks);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get tracks'));
    } catch (e) {
      AppLogger.error('Get tracks failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get tracks: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioFeatures>> getAudioFeatures(
    String trackId,
  ) async {
    try {
      final model = await apiClient.getAudioFeatures(trackId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      // Audio Features API may return 403 for apps without Extended Quota Mode
      // This is expected behavior, so handle silently
      final isForbidden = e.response?.statusCode == 403;
      return Left(
        DioErrorHandler.handle(
          e,
          context: 'Get audio features',
          silent: isForbidden,
        ),
      );
    } catch (e) {
      AppLogger.error('Get audio features failed', e);
      return Left(
        SpotifyApiFailure(message: 'Failed to get audio features: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AudioFeatures>>> getMultipleAudioFeatures(
    List<String> trackIds,
  ) async {
    try {
      final ids = trackIds.join(',');
      final response = await apiClient.getMultipleAudioFeatures(ids);
      final features = response.audioFeatures
          .where((f) => f != null)
          .map((f) => f!.toEntity())
          .toList();
      return Right(features);
    } on DioException catch (e) {
      // Audio Features API may return 403 for apps without Extended Quota Mode
      final isForbidden = e.response?.statusCode == 403;
      return Left(
        DioErrorHandler.handle(
          e,
          context: 'Get multiple audio features',
          silent: isForbidden,
        ),
      );
    } catch (e) {
      AppLogger.error('Get multiple audio features failed', e);
      return Left(
        SpotifyApiFailure(message: 'Failed to get audio features: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Artist>>> getRelatedArtists(
    String artistId,
  ) async {
    try {
      final response = await apiClient.getRelatedArtists(artistId);
      final artists = response.artists
          .map((model) => model.toEntity())
          .toList();
      return Right(artists);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get related artists'));
    } catch (e) {
      AppLogger.error('Get related artists failed', e);
      return Left(
        SpotifyApiFailure(message: 'Failed to get related artists: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getCurrentUserPlaylists({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.getCurrentUserPlaylists(
        limit: limit,
        offset: offset,
      );
      final playlists = response.items
          .map((model) => model.toEntity())
          .toList();
      return Right(playlists);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get user playlists'));
    } catch (e) {
      AppLogger.error('Get user playlists failed', e);
      return Left(SpotifyApiFailure(message: 'Failed to get playlists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistTrack>>> getPlaylistTracks(
    String playlistId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.getPlaylistTracks(
        playlistId,
        limit: limit,
        offset: offset,
      );
      final tracks = response.items
          .map(
            (model) => PlaylistTrack(
              id: model.trackId,
              name: model.trackName,
              uri: model.trackUri,
              durationMs: model.durationMs,
              artistNames: model.artistNames,
              albumName: model.albumName,
              albumImageUrl: model.albumImageUrl,
            ),
          )
          .toList();
      return Right(tracks);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handle(e, context: 'Get playlist tracks'));
    } catch (e) {
      AppLogger.error('Get playlist tracks failed', e);
      return Left(
        SpotifyApiFailure(message: 'Failed to get playlist tracks: $e'),
      );
    }
  }
}
