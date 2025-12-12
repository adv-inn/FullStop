import 'package:equatable/equatable.dart';
import 'artist.dart';

class Track extends Equatable {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  final int durationMs;
  final int trackNumber;
  final int discNumber;
  final bool explicit;
  final String? previewUrl;
  final int popularity;
  final String uri;
  final String? externalUrl;

  const Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
    this.trackNumber = 1,
    this.discNumber = 1,
    this.explicit = false,
    this.previewUrl,
    this.popularity = 0,
    required this.uri,
    this.externalUrl,
  });

  String get artistNames => artists.map((a) => a.name).join(', ');

  String get albumId => album.id;

  String get durationFormatted {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? get imageUrl => album.imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    artists,
    album,
    durationMs,
    trackNumber,
    discNumber,
    explicit,
    previewUrl,
    popularity,
    uri,
    externalUrl,
  ];
}

class Album extends Equatable {
  final String id;
  final String name;
  final String albumType;
  final List<SpotifyImage> images;
  final String? releaseDate;
  final int totalTracks;
  final String? externalUrl;

  const Album({
    required this.id,
    required this.name,
    required this.albumType,
    this.images = const [],
    this.releaseDate,
    this.totalTracks = 0,
    this.externalUrl,
  });

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;

  @override
  List<Object?> get props => [
    id,
    name,
    albumType,
    images,
    releaseDate,
    totalTracks,
    externalUrl,
  ];
}
