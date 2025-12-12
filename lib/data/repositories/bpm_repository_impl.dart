import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/bpm_repository.dart';
import '../datasources/bpm_cache_local_datasource.dart';
import '../datasources/getsongbpm_api_client.dart';
import '../models/getsongbpm_model.dart';

/// Implementation of BpmRepository using GetSongBPM API with local caching
class BpmRepositoryImpl implements BpmRepository {
  final GetSongBpmApiClient _apiClient;
  final BpmCacheLocalDataSource? _cacheDataSource;

  BpmRepositoryImpl(this._apiClient, [this._cacheDataSource]);

  @override
  Future<Either<Failure, int>> getBpmForSong(
    String title,
    String artistName,
  ) async {
    // Check cache first
    if (_cacheDataSource != null) {
      final cachedBpm = await _cacheDataSource.getCachedBpm(title, artistName);
      if (cachedBpm != null) {
        AppLogger.debug(
          'BPM cache hit for "$title" by "$artistName": $cachedBpm',
        );
        return Right(cachedBpm);
      }
    }

    try {
      // Search for the song with artist name for better accuracy
      final response = await _apiClient.searchSongByArtist(title, artistName);

      if (response.search.isEmpty) {
        // Try searching by title only
        final titleOnlyResponse = await _apiClient.searchSong(title);
        if (titleOnlyResponse.search.isEmpty) {
          return const Left(BpmApiFailure(message: 'Song not found'));
        }

        // Find best match by artist name
        final match = _findBestMatch(titleOnlyResponse.search, artistName);
        if (match?.tempo != null) {
          final bpm = match!.tempo!;
          // Cache the result
          await _cacheBpm(title, artistName, bpm);
          return Right(bpm);
        }
        return const Left(BpmApiFailure(message: 'BPM data not available'));
      }

      // Find best match from results
      final match = _findBestMatch(response.search, artistName);
      if (match?.tempo != null) {
        final bpm = match!.tempo!;
        // Cache the result
        await _cacheBpm(title, artistName, bpm);
        return Right(bpm);
      }

      // If no exact match, try the first result with tempo
      for (final song in response.search) {
        if (song.tempo != null) {
          final bpm = song.tempo!;
          // Cache the result
          await _cacheBpm(title, artistName, bpm);
          return Right(bpm);
        }
      }

      return const Left(BpmApiFailure(message: 'BPM data not available'));
    } on DioException catch (e) {
      AppLogger.error('GetSongBPM API error', e);
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return const Left(BpmApiFailure(message: 'Invalid API key'));
      }
      if (e.response?.statusCode == 429) {
        return const Left(BpmApiFailure(message: 'Rate limit exceeded'));
      }
      return Left(BpmApiFailure(message: 'API error: ${e.message}'));
    } catch (e) {
      AppLogger.error('GetSongBPM error', e);
      return Left(BpmApiFailure(message: 'Failed to get BPM: $e'));
    }
  }

  /// Cache a BPM value
  Future<void> _cacheBpm(String title, String artistName, int bpm) async {
    if (_cacheDataSource != null) {
      await _cacheDataSource.cacheBpm(title, artistName, bpm);
      AppLogger.debug('Cached BPM for "$title" by "$artistName": $bpm');
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getBpmForSongs(
    List<({String title, String artistName})> songs, {
    BpmProgressCallback? onProgress,
  }) async {
    final results = <String, int>{};
    final failures = <String>[];
    final totalSongs = songs.length;

    // First, check cache for all songs
    if (_cacheDataSource != null) {
      final cachedBpms = await _cacheDataSource.getCachedBpms(songs);
      results.addAll(cachedBpms);
      AppLogger.info('BPM cache: ${cachedBpms.length}/${songs.length} hits');
    }

    // Filter out songs that were found in cache
    final uncachedSongs = songs.where((song) {
      final key = '${song.title}|${song.artistName}';
      return !results.containsKey(key);
    }).toList();

    // Report initial progress (cache hits count towards progress)
    final cachedCount = results.length;
    onProgress?.call(cachedCount, totalSongs);

    // Fetch remaining songs from API
    if (uncachedSongs.isNotEmpty) {
      AppLogger.info(
        'Fetching ${uncachedSongs.length} songs from GetSongBPM API...',
      );
      final newBpms = <String, int>{};

      for (var i = 0; i < uncachedSongs.length; i++) {
        final song = uncachedSongs[i];
        final result = await getBpmForSong(song.title, song.artistName);
        result.fold(
          (failure) => failures.add('${song.artistName} - ${song.title}'),
          (bpm) {
            final key = '${song.title}|${song.artistName}';
            results[key] = bpm;
            newBpms[key] = bpm;
          },
        );

        // Report progress after each song
        onProgress?.call(cachedCount + i + 1, totalSongs);

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Batch cache the new results
      if (_cacheDataSource != null && newBpms.isNotEmpty) {
        await _cacheDataSource.cacheBpms(newBpms);
        AppLogger.info('Cached ${newBpms.length} new BPM entries');
      }
    }

    if (results.isEmpty && failures.isNotEmpty) {
      return Left(BpmApiFailure(message: 'Could not find BPM for any songs'));
    }

    return Right(results);
  }

  /// Find the best matching song from search results based on artist name
  GetSongBpmSongResult? _findBestMatch(
    List<GetSongBpmSongResult> songs,
    String artistName,
  ) {
    final normalizedArtist = artistName.toLowerCase().trim();

    for (final song in songs) {
      final songArtist = song.artist?.name.toLowerCase().trim() ?? '';
      if (songArtist == normalizedArtist ||
          songArtist.contains(normalizedArtist) ||
          normalizedArtist.contains(songArtist)) {
        return song;
      }
    }

    // Return first result if no artist match
    return songs.isNotEmpty ? songs.first : null;
  }
}
