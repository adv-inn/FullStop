import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final List<String> genres;
  final int popularity;
  final int followers;
  final List<SpotifyImage> images;
  final String? externalUrl;

  const Artist({
    required this.id,
    required this.name,
    this.genres = const [],
    this.popularity = 0,
    this.followers = 0,
    this.images = const [],
    this.externalUrl,
  });

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;

  String? get thumbnailUrl {
    if (images.isEmpty) return null;
    // Return smallest image for thumbnails
    return images.last.url;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    genres,
    popularity,
    followers,
    images,
    externalUrl,
  ];
}

class SpotifyImage extends Equatable {
  final String url;
  final int? width;
  final int? height;

  const SpotifyImage({required this.url, this.width, this.height});

  @override
  List<Object?> get props => [url, width, height];
}
