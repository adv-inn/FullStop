import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/artist.dart';
import 'spotify_image_model.dart';

part 'artist_model.g.dart';

@JsonSerializable()
class ArtistModel {
  final String id;
  final String name;
  final List<String>? genres;
  final int? popularity;
  final FollowersModel? followers;
  final List<SpotifyImageModel>? images;
  @JsonKey(name: 'external_urls')
  final ExternalUrlsModel? externalUrls;

  const ArtistModel({
    required this.id,
    required this.name,
    this.genres,
    this.popularity,
    this.followers,
    this.images,
    this.externalUrls,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) =>
      _$ArtistModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistModelToJson(this);

  Artist toEntity() => Artist(
    id: id,
    name: name,
    genres: genres ?? [],
    popularity: popularity ?? 0,
    followers: followers?.total ?? 0,
    images: images?.map((i) => i.toEntity()).toList() ?? [],
    externalUrl: externalUrls?.spotify,
  );

  static ArtistModel fromEntity(Artist entity) => ArtistModel(
    id: entity.id,
    name: entity.name,
    genres: entity.genres,
    popularity: entity.popularity,
    followers: FollowersModel(total: entity.followers),
    images: entity.images.map(SpotifyImageModel.fromEntity).toList(),
    externalUrls: entity.externalUrl != null
        ? ExternalUrlsModel(spotify: entity.externalUrl!)
        : null,
  );
}

@JsonSerializable()
class FollowersModel {
  final int? total;

  const FollowersModel({this.total});

  factory FollowersModel.fromJson(Map<String, dynamic> json) =>
      _$FollowersModelFromJson(json);

  Map<String, dynamic> toJson() => _$FollowersModelToJson(this);
}

@JsonSerializable()
class ExternalUrlsModel {
  final String? spotify;

  const ExternalUrlsModel({this.spotify});

  factory ExternalUrlsModel.fromJson(Map<String, dynamic> json) =>
      _$ExternalUrlsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalUrlsModelToJson(this);
}
