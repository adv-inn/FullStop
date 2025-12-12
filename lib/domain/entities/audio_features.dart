import 'package:equatable/equatable.dart';

/// Audio features for a track from Spotify's Audio Features API
class AudioFeatures extends Equatable {
  final String id;

  /// BPM (tempo) of the track
  final double tempo;

  /// Overall loudness in dB
  final double loudness;

  /// Musical key (0-11, C to B)
  final int key;

  /// Mode: 0 = minor, 1 = major
  final int mode;

  /// Time signature (beats per bar)
  final int timeSignature;

  /// 0.0 to 1.0 - how acoustic the track is
  final double acousticness;

  /// 0.0 to 1.0 - how danceable the track is
  final double danceability;

  /// 0.0 to 1.0 - energy/intensity
  final double energy;

  /// 0.0 to 1.0 - presence of spoken words
  final double speechiness;

  /// 0.0 to 1.0 - musical positiveness
  final double valence;

  /// 0.0 to 1.0 - likelihood of being instrumental
  final double instrumentalness;

  /// 0.0 to 1.0 - presence of live audience
  final double liveness;

  const AudioFeatures({
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

  int get bpm => tempo.round();

  String get keyName {
    const keys = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    return key >= 0 && key < 12 ? keys[key] : 'Unknown';
  }

  String get modeName => mode == 1 ? 'Major' : 'Minor';

  String get keySignature => '$keyName $modeName';

  @override
  List<Object?> get props => [
    id,
    tempo,
    loudness,
    key,
    mode,
    timeSignature,
    acousticness,
    danceability,
    energy,
    speechiness,
    valence,
    instrumentalness,
    liveness,
  ];
}
