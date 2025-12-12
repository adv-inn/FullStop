import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/playback_state.dart';
import 'track_model.dart';

part 'playback_state_model.g.dart';

@JsonSerializable()
class PlaybackStateModel {
  final TrackModel? item;
  @JsonKey(name: 'is_playing')
  final bool isPlaying;
  @JsonKey(name: 'progress_ms')
  final int? progressMs;
  final DeviceModel? device;
  final ContextModel? context;
  @JsonKey(name: 'repeat_state')
  final String? repeatState;
  @JsonKey(name: 'shuffle_state')
  final bool? shuffleState;
  final int? timestamp;

  const PlaybackStateModel({
    this.item,
    required this.isPlaying,
    this.progressMs,
    this.device,
    this.context,
    this.repeatState,
    this.shuffleState,
    this.timestamp,
  });

  factory PlaybackStateModel.fromJson(Map<String, dynamic> json) =>
      _$PlaybackStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaybackStateModelToJson(this);

  PlaybackState toEntity() => PlaybackState(
    currentTrack: item?.toEntity(),
    isPlaying: isPlaying,
    progressMs: progressMs ?? 0,
    durationMs: item?.durationMs ?? 0,
    device: device?.toEntity(),
    context: context?.uri,
    repeatMode: _parseRepeatMode(repeatState),
    shuffleState: shuffleState ?? false,
    timestamp: timestamp ?? 0,
  );

  RepeatMode _parseRepeatMode(String? state) {
    return switch (state) {
      'track' => RepeatMode.track,
      'context' => RepeatMode.context,
      _ => RepeatMode.off,
    };
  }
}

@JsonSerializable()
class DeviceModel {
  final String id;
  final String name;
  final String type;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_restricted')
  final bool isRestricted;
  @JsonKey(name: 'volume_percent')
  final int? volumePercent;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.isRestricted,
    this.volumePercent,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);

  Device toEntity() => Device(
    id: id,
    name: name,
    type: type,
    isActive: isActive,
    isRestricted: isRestricted,
    volumePercent: volumePercent,
  );
}

@JsonSerializable()
class ContextModel {
  final String? uri;
  final String? type;

  const ContextModel({this.uri, this.type});

  factory ContextModel.fromJson(Map<String, dynamic> json) =>
      _$ContextModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContextModelToJson(this);
}
