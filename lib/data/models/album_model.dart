import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/track.dart';
import 'artist_model.dart';
import 'spotify_image_model.dart';

part 'album_model.g.dart';

@JsonSerializable()
class AlbumModel {
  final String id;
  final String name;
  @JsonKey(name: 'album_type')
  final String albumType;
  final List<SpotifyImageModel>? images;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'total_tracks')
  final int? totalTracks;
  @JsonKey(name: 'external_urls')
  final ExternalUrlsModel? externalUrls;

  const AlbumModel({
    required this.id,
    required this.name,
    required this.albumType,
    this.images,
    this.releaseDate,
    this.totalTracks,
    this.externalUrls,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) =>
      _$AlbumModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumModelToJson(this);

  Album toEntity() => Album(
    id: id,
    name: name,
    albumType: albumType,
    images: images?.map((i) => i.toEntity()).toList() ?? [],
    releaseDate: releaseDate,
    totalTracks: totalTracks ?? 0,
    externalUrl: externalUrls?.spotify,
  );
}
