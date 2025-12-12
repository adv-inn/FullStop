import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/audio_features.dart';

part 'audio_features_model.g.dart';

@JsonSerializable()
class AudioFeaturesModel {
  final String id;
  final double tempo;
  final double loudness;
  final int key;
  final int mode;
  @JsonKey(name: 'time_signature')
  final int timeSignature;
  final double acousticness;
  final double danceability;
  final double energy;
  final double speechiness;
  final double valence;
  final double instrumentalness;
  final double liveness;

  const AudioFeaturesModel({
    required this.id,
    required this.tempo,
    required this.loudness,
    required this.key,
    required this.mode,
    required this.timeSignature,
    required this.acousticness,
    required this.danceability,
    required this.energy,
    required this.speechiness,
    required this.valence,
    required this.instrumentalness,
    required this.liveness,
  });

  factory AudioFeaturesModel.fromJson(Map<String, dynamic> json) =>
      _$AudioFeaturesModelFromJson(json);

  Map<String, dynamic> toJson() => _$AudioFeaturesModelToJson(this);

  AudioFeatures toEntity() => AudioFeatures(
    id: id,
    tempo: tempo,
    loudness: loudness,
    key: key,
    mode: mode,
    timeSignature: timeSignature,
    acousticness: acousticness,
    danceability: danceability,
    energy: energy,
    speechiness: speechiness,
    valence: valence,
    instrumentalness: instrumentalness,
    liveness: liveness,
  );
}
