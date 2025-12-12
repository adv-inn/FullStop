import 'package:dio/dio.dart';
import '../models/artist_model.dart';
import '../models/audio_features_model.dart';
import '../models/playback_state_model.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../models/user_model.dart';

class SpotifyApiClient {
  final Dio _dio;
  static const String _baseUrl = 'https://api.spotify.com/v1';

  SpotifyApiClient(this._dio);

  // User endpoints
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('$_baseUrl/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Search endpoints
  Future<SearchResponse> search(
    String query,
    String type, {
    int limit = 20,
    int offset = 0,
    String? market,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/search',
      queryParameters: {
        'q': query,
        'type': type,
        'limit': limit,
        'offset': offset,
        if (market != null) 'market': market,
      },
    );
    return SearchResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Artist endpoints
  Future<ArtistModel> getArtist(String artistId) async {
    final response = await _dio.get('$_baseUrl/artists/$artistId');
    return ArtistModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TopTracksResponse> getArtistTopTracks(
    String artistId, {
    String market = 'US',
  }) async {
    final response = await _dio.get(
      '$_baseUrl/artists/$artistId/top-tracks',
      queryParameters: {'market': market},
    );
    return TopTracksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AlbumsResponse> getArtistAlbums(
    String artistId, {
    String includeGroups = 'album,single',
    int limit = 50,
    int offset = 0,
    String? market,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/artists/$artistId/albums',
      queryParameters: {
        'include_groups': includeGroups,
        'limit': limit,
        'offset': offset,
        if (market != null) 'market': market,
      },
    );
    return AlbumsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RelatedArtistsResponse> getRelatedArtists(String artistId) async {
    final response = await _dio.get(
      '$_baseUrl/artists/$artistId/related-artists',
    );
    return RelatedArtistsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // Album endpoints
  Future<TracksResponse> getAlbumTracks(
    String albumId, {
    int limit = 50,
    int offset = 0,
    String? market,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/albums/$albumId/tracks',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (market != null) 'market': market,
      },
    );
    return TracksResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Track endpoints
  Future<TrackModel> getTrack(String trackId) async {
    final response = await _dio.get('$_baseUrl/tracks/$trackId');
    return TrackModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TracksListResponse> getTracks(String ids) async {
    final response = await _dio.get(
      '$_baseUrl/tracks',
      queryParameters: {'ids': ids},
    );
    return TracksListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Audio features endpoints
  Future<AudioFeaturesModel> getAudioFeatures(String trackId) async {
    final response = await _dio.get('$_baseUrl/audio-features/$trackId');
    return AudioFeaturesModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AudioFeaturesListResponse> getMultipleAudioFeatures(String ids) async {
    final response = await _dio.get(
      '$_baseUrl/audio-features',
      queryParameters: {'ids': ids},
    );
    return AudioFeaturesListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // Playback endpoints
  Future<PlaybackStateModel?> getPlaybackState() async {
    try {
      final response = await _dio.get('$_baseUrl/me/player');
      if (response.data == null || response.data == '') {
        return null;
      }
      return PlaybackStateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 204) {
        return null;
      }
      rethrow;
    }
  }

  Future<DevicesResponse> getAvailableDevices() async {
    final response = await _dio.get('$_baseUrl/me/player/devices');
    return DevicesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> transferPlayback(Map<String, dynamic> body) async {
    await _dio.put('$_baseUrl/me/player', data: body);
  }

  Future<void> play({String? deviceId, Map<String, dynamic>? body}) async {
    await _dio.put(
      '$_baseUrl/me/player/play',
      queryParameters: deviceId != null ? {'device_id': deviceId} : null,
      data: body,
    );
  }

  Future<void> pause({String? deviceId}) async {
    await _dio.put(
      '$_baseUrl/me/player/pause',
      queryParameters: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  Future<void> skipToNext({String? deviceId}) async {
    await _dio.post(
      '$_baseUrl/me/player/next',
      queryParameters: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  Future<void> skipToPrevious({String? deviceId}) async {
    await _dio.post(
      '$_baseUrl/me/player/previous',
      queryParameters: deviceId != null ? {'device_id': deviceId} : null,
    );
  }

  Future<void> seekToPosition(int positionMs, {String? deviceId}) async {
    await _dio.put(
      '$_baseUrl/me/player/seek',
      queryParameters: {
        'position_ms': positionMs,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  Future<void> setRepeatMode(String state, {String? deviceId}) async {
    await _dio.put(
      '$_baseUrl/me/player/repeat',
      queryParameters: {
        'state': state,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  Future<void> setShuffle(bool state, {String? deviceId}) async {
    await _dio.put(
      '$_baseUrl/me/player/shuffle',
      queryParameters: {
        'state': state,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  Future<void> setVolume(int volumePercent, {String? deviceId}) async {
    await _dio.put(
      '$_baseUrl/me/player/volume',
      queryParameters: {
        'volume_percent': volumePercent,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  Future<void> addToQueue(String uri, {String? deviceId}) async {
    await _dio.post(
      '$_baseUrl/me/player/queue',
      queryParameters: {
        'uri': uri,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
  }

  // Library endpoints (Like/Unlike tracks)
  /// Check if tracks are saved in user's library
  Future<List<bool>> checkSavedTracks(List<String> trackIds) async {
    final response = await _dio.get(
      '$_baseUrl/me/tracks/contains',
      queryParameters: {'ids': trackIds.join(',')},
    );
    return (response.data as List).cast<bool>();
  }

  /// Save tracks to user's library (Like)
  Future<void> saveTracks(List<String> trackIds) async {
    await _dio.put(
      '$_baseUrl/me/tracks',
      queryParameters: {'ids': trackIds.join(',')},
    );
  }

  /// Remove tracks from user's library (Unlike)
  Future<void> removeTracks(List<String> trackIds) async {
    await _dio.delete(
      '$_baseUrl/me/tracks',
      queryParameters: {'ids': trackIds.join(',')},
    );
  }

  /// Create a new playlist for the current user
  Future<Map<String, dynamic>> createPlaylist({
    required String userId,
    required String name,
    String? description,
    bool public = false,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/users/$userId/playlists',
      data: {'name': name, 'description': description ?? '', 'public': public},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Add tracks to a playlist
  Future<void> addTracksToPlaylist(
    String playlistId,
    List<String> trackUris,
  ) async {
    // Spotify limits to 100 tracks per request
    for (var i = 0; i < trackUris.length; i += 100) {
      final batch = trackUris.sublist(
        i,
        i + 100 > trackUris.length ? trackUris.length : i + 100,
      );
      await _dio.post(
        '$_baseUrl/playlists/$playlistId/tracks',
        data: {'uris': batch},
      );
    }
  }

  // Playlist endpoints
  Future<PlaylistsResponse> getCurrentUserPlaylists({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/me/playlists',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PlaylistsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlaylistTracksResponse> getPlaylistTracks(
    String playlistId, {
    int limit = 100,
    int offset = 0,
    String? market,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/playlists/$playlistId/tracks',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (market != null) 'market': market,
      },
    );
    return PlaylistTracksResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

// Response wrapper classes
class SearchResponse {
  final ArtistsWrapper? artists;
  final TracksWrapper? tracks;

  SearchResponse({this.artists, this.tracks});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      artists: json['artists'] != null
          ? ArtistsWrapper.fromJson(json['artists'] as Map<String, dynamic>)
          : null,
      tracks: json['tracks'] != null
          ? TracksWrapper.fromJson(json['tracks'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ArtistsWrapper {
  final List<ArtistModel> items;
  final int total;

  ArtistsWrapper({required this.items, required this.total});

  factory ArtistsWrapper.fromJson(Map<String, dynamic> json) {
    return ArtistsWrapper(
      items: (json['items'] as List)
          .map((e) => ArtistModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
    );
  }
}

class TracksWrapper {
  final List<TrackModel> items;
  final int total;

  TracksWrapper({required this.items, required this.total});

  factory TracksWrapper.fromJson(Map<String, dynamic> json) {
    return TracksWrapper(
      items: (json['items'] as List)
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
    );
  }
}

class TopTracksResponse {
  final List<TrackModel> tracks;

  TopTracksResponse({required this.tracks});

  factory TopTracksResponse.fromJson(Map<String, dynamic> json) {
    return TopTracksResponse(
      tracks: (json['tracks'] as List)
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AlbumsResponse {
  final List<AlbumSimplified> items;
  final int total;
  final String? next;

  AlbumsResponse({required this.items, required this.total, this.next});

  factory AlbumsResponse.fromJson(Map<String, dynamic> json) {
    return AlbumsResponse(
      items: (json['items'] as List)
          .map((e) => AlbumSimplified.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
      next: json['next'] as String?,
    );
  }
}

class AlbumSimplified {
  final String id;
  final String name;
  final String albumType;

  AlbumSimplified({
    required this.id,
    required this.name,
    required this.albumType,
  });

  factory AlbumSimplified.fromJson(Map<String, dynamic> json) {
    return AlbumSimplified(
      id: json['id'] as String,
      name: json['name'] as String,
      albumType: json['album_type'] as String,
    );
  }
}

class TracksResponse {
  final List<TrackSimplified> items;
  final int total;
  final String? next;

  TracksResponse({required this.items, required this.total, this.next});

  factory TracksResponse.fromJson(Map<String, dynamic> json) {
    return TracksResponse(
      items: (json['items'] as List)
          .map((e) => TrackSimplified.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
      next: json['next'] as String?,
    );
  }
}

class TrackSimplified {
  final String id;
  final String name;
  final String uri;

  TrackSimplified({required this.id, required this.name, required this.uri});

  factory TrackSimplified.fromJson(Map<String, dynamic> json) {
    return TrackSimplified(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
    );
  }
}

class TracksListResponse {
  final List<TrackModel> tracks;

  TracksListResponse({required this.tracks});

  factory TracksListResponse.fromJson(Map<String, dynamic> json) {
    return TracksListResponse(
      tracks: (json['tracks'] as List)
          .where((e) => e != null)
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AudioFeaturesListResponse {
  final List<AudioFeaturesModel?> audioFeatures;

  AudioFeaturesListResponse({required this.audioFeatures});

  factory AudioFeaturesListResponse.fromJson(Map<String, dynamic> json) {
    return AudioFeaturesListResponse(
      audioFeatures: (json['audio_features'] as List)
          .map(
            (e) => e != null
                ? AudioFeaturesModel.fromJson(e as Map<String, dynamic>)
                : null,
          )
          .toList(),
    );
  }
}

class RelatedArtistsResponse {
  final List<ArtistModel> artists;

  RelatedArtistsResponse({required this.artists});

  factory RelatedArtistsResponse.fromJson(Map<String, dynamic> json) {
    return RelatedArtistsResponse(
      artists: (json['artists'] as List)
          .map((e) => ArtistModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DevicesResponse {
  final List<DeviceModel> devices;

  DevicesResponse({required this.devices});

  factory DevicesResponse.fromJson(Map<String, dynamic> json) {
    return DevicesResponse(
      devices: (json['devices'] as List)
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlaylistsResponse {
  final List<PlaylistModel> items;
  final int total;
  final String? next;

  PlaylistsResponse({required this.items, required this.total, this.next});

  factory PlaylistsResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistsResponse(
      items: (json['items'] as List)
          .where((e) => e != null)
          .map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
      next: json['next'] as String?,
    );
  }
}

class PlaylistTracksResponse {
  final List<PlaylistTrackModel> items;
  final int total;
  final String? next;

  PlaylistTracksResponse({required this.items, required this.total, this.next});

  factory PlaylistTracksResponse.fromJson(Map<String, dynamic> json) {
    final items = <PlaylistTrackModel>[];
    for (final item in json['items'] as List) {
      if (item != null && (item as Map<String, dynamic>)['track'] != null) {
        try {
          items.add(PlaylistTrackModel.fromJson(item));
        } catch (_) {
          // Skip invalid tracks
        }
      }
    }
    return PlaylistTracksResponse(
      items: items,
      total: (json['total'] as int?) ?? 0,
      next: json['next'] as String?,
    );
  }
}
