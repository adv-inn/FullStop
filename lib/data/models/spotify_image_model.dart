import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/artist.dart';

part 'spotify_image_model.g.dart';

@JsonSerializable()
class SpotifyImageModel {
  final String url;
  final int? width;
  final int? height;

  const SpotifyImageModel({required this.url, this.width, this.height});

  factory SpotifyImageModel.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyImageModelToJson(this);

  SpotifyImage toEntity() =>
      SpotifyImage(url: url, width: width, height: height);

  static SpotifyImageModel fromEntity(SpotifyImage entity) => SpotifyImageModel(
    url: entity.url,
    width: entity.width,
    height: entity.height,
  );
}
