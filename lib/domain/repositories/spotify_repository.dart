import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/artist.dart';
import '../entities/audio_features.dart';
import '../entities/playlist.dart';
import '../entities/track.dart';

/// Progress callback for track fetching operations
/// [current] is the current item being processed (0-indexed)
/// [total] is the total number of items
/// [phase] describes what's being fetched (e.g., 'albums', 'tracks')
typedef TrackFetchProgressCallback =
    void Function(int current, int total, String phase);

abstract class SpotifyRepository {
  /// Search for artists by name
  Future<Either<Failure, List<Artist>>> searchArtists(
    String query, {
    int limit = 20,
    int offset = 0,
  });

  /// Get artist by ID
  Future<Either<Failure, Artist>> getArtist(String artistId);

  /// Get artist's top tracks
  Future<Either<Failure, List<Track>>> getArtistTopTracks(
    String artistId, {
    String market = 'US',
  });

  /// Get all tracks from an artist (albums + singles)
  /// Uses Album Traversal strategy - fetches complete discography
  ///
  /// [includeFeatures] - whether to include "appears_on" albums
  /// [includeLiveAlbums] - if false, filters out Live/Concert/Compilation albums
  ///                       if true, includes everything (for Unfiltered mode)
  /// [market] - ISO 3166-1 alpha-2 country code for regional content filtering
  /// [onProgress] is called to report progress during fetching
  Future<Either<Failure, List<Track>>> getArtistAllTracks(
    String artistId, {
    bool includeFeatures = true,
    bool includeLiveAlbums = false,
    String? market,
    TrackFetchProgressCallback? onProgress,
  });

  /// Get popular tracks from an artist using search
  /// Uses Quick Search strategy - fetches ~50 most popular tracks
  /// Faster than getArtistAllTracks, suitable for HitsOnly mode
  Future<Either<Failure, List<Track>>> getArtistPopularTracks(
    String artistId,
    String artistName, {
    int limit = 50,
  });

  /// Search for tracks by name
  Future<Either<Failure, List<Track>>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  });

  /// Get track by ID
  Future<Either<Failure, Track>> getTrack(String trackId);

  /// Get multiple tracks by IDs
  Future<Either<Failure, List<Track>>> getTracks(List<String> trackIds);

  /// Get audio features for a track
  Future<Either<Failure, AudioFeatures>> getAudioFeatures(String trackId);

  /// Get audio features for multiple tracks
  Future<Either<Failure, List<AudioFeatures>>> getMultipleAudioFeatures(
    List<String> trackIds,
  );

  /// Get related artists
  Future<Either<Failure, List<Artist>>> getRelatedArtists(String artistId);

  /// Get current user's playlists
  Future<Either<Failure, List<Playlist>>> getCurrentUserPlaylists({
    int limit = 50,
    int offset = 0,
  });

  /// Get playlist tracks
  Future<Either<Failure, List<PlaylistTrack>>> getPlaylistTracks(
    String playlistId, {
    int limit = 100,
    int offset = 0,
  });
}
