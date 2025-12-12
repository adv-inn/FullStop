import 'package:dio/dio.dart';
import '../models/getsongbpm_model.dart';

/// API Client for GetSongBPM service
/// https://getsongbpm.com/api
class GetSongBpmApiClient {
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://api.getsong.co';

  GetSongBpmApiClient(this._dio, this._apiKey) {
    // Add X-API-KEY header for authentication
    _dio.options.headers['X-API-KEY'] = _apiKey;
  }

  /// Search for songs by title
  /// Returns a list of matching songs with BPM data
  Future<GetSongBpmSearchResponse> searchSong(String title) async {
    final response = await _dio.get(
      '$_baseUrl/search/',
      queryParameters: {'api_key': _apiKey, 'type': 'song', 'lookup': title},
    );
    return GetSongBpmSearchResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Search for songs by title and artist name
  /// More precise matching using "both" type with song: and artist: prefixes
  Future<GetSongBpmSearchResponse> searchSongByArtist(
    String title,
    String artistName,
  ) async {
    // GetSongBPM requires "song:title artist:name" format for type=both
    final query = 'song:$title artist:$artistName';
    final response = await _dio.get(
      '$_baseUrl/search/',
      queryParameters: {'api_key': _apiKey, 'type': 'both', 'lookup': query},
    );
    return GetSongBpmSearchResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Get song details by GetSongBPM song ID
  Future<GetSongBpmSongDetail> getSongById(String songId) async {
    final response = await _dio.get(
      '$_baseUrl/song/',
      queryParameters: {'api_key': _apiKey, 'id': songId},
    );
    return GetSongBpmSongDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Search for artist
  Future<GetSongBpmSearchResponse> searchArtist(String artistName) async {
    final response = await _dio.get(
      '$_baseUrl/search/',
      queryParameters: {
        'api_key': _apiKey,
        'type': 'artist',
        'lookup': artistName,
      },
    );
    return GetSongBpmSearchResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
