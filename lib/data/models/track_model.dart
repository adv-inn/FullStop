import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/track.dart';
import 'album_model.dart';
import 'artist_model.dart';

part 'track_model.g.dart';

@JsonSerializable()
class TrackModel {
  final String id;
  final String name;
  final List<ArtistModel> artists;
  final AlbumModel album;
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @JsonKey(name: 'track_number')
  final int? trackNumber;
  @JsonKey(name: 'disc_number')
  final int? discNumber;
  final bool? explicit;
  @JsonKey(name: 'preview_url')
  final String? previewUrl;
  final int? popularity;
  final String uri;
  @JsonKey(name: 'external_urls')
  final ExternalUrlsModel? externalUrls;

  const TrackModel({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
    this.trackNumber,
    this.discNumber,
    this.explicit,
    this.previewUrl,
    this.popularity,
    required this.uri,
    this.externalUrls,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) =>
      _$TrackModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackModelToJson(this);

  Track toEntity() => Track(
    id: id,
    name: name,
    artists: artists.map((a) => a.toEntity()).toList(),
    album: album.toEntity(),
    durationMs: durationMs,
    trackNumber: trackNumber ?? 1,
    discNumber: discNumber ?? 1,
    explicit: explicit ?? false,
    previewUrl: previewUrl,
    popularity: popularity ?? 0,
    uri: uri,
    externalUrl: externalUrls?.spotify,
  );
}
