import '../../domain/entities/playlist.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int trackCount;
  final String ownerName;

  PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.trackCount,
    required this.ownerName,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    final tracks = json['tracks'] as Map<String, dynamic>?;

    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: images != null && images.isNotEmpty
          ? images.first['url'] as String?
          : null,
      trackCount: tracks?['total'] as int? ?? 0,
      ownerName:
          (json['owner'] as Map<String, dynamic>?)?['display_name']
              as String? ??
          '',
    );
  }

  Playlist toEntity() {
    return Playlist(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      trackCount: trackCount,
      ownerName: ownerName,
    );
  }
}

class PlaylistTrackModel {
  final String? addedAt;
  final String trackId;
  final String trackName;
  final String trackUri;
  final int durationMs;
  final List<String> artistNames;
  final String? albumName;
  final String? albumImageUrl;

  PlaylistTrackModel({
    this.addedAt,
    required this.trackId,
    required this.trackName,
    required this.trackUri,
    required this.durationMs,
    required this.artistNames,
    this.albumName,
    this.albumImageUrl,
  });

  factory PlaylistTrackModel.fromJson(Map<String, dynamic> json) {
    final track = json['track'] as Map<String, dynamic>?;
    if (track == null) {
      throw Exception('Track is null');
    }

    final artists = track['artists'] as List? ?? [];
    final album = track['album'] as Map<String, dynamic>?;
    final albumImages = album?['images'] as List? ?? [];

    return PlaylistTrackModel(
      addedAt: json['added_at'] as String?,
      trackId: track['id'] as String,
      trackName: track['name'] as String,
      trackUri: track['uri'] as String,
      durationMs: track['duration_ms'] as int? ?? 0,
      artistNames: artists
          .map((a) => (a as Map<String, dynamic>)['name'] as String)
          .toList(),
      albumName: album?['name'] as String?,
      albumImageUrl: albumImages.isNotEmpty
          ? albumImages.first['url'] as String?
          : null,
    );
  }
}
