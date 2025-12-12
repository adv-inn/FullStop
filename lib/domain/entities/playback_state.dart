import 'package:equatable/equatable.dart';
import 'repeat_mode.dart';
import 'track.dart';

export 'repeat_mode.dart';

class PlaybackState extends Equatable {
  final Track? currentTrack;
  final bool isPlaying;
  final int progressMs;
  final int durationMs;
  final Device? device;
  final String? context;
  final RepeatMode repeatMode;
  final bool shuffleState;
  final int timestamp;

  const PlaybackState({
    this.currentTrack,
    this.isPlaying = false,
    this.progressMs = 0,
    this.durationMs = 0,
    this.device,
    this.context,
    this.repeatMode = RepeatMode.off,
    this.shuffleState = false,
    this.timestamp = 0,
  });

  double get progressPercent {
    if (durationMs == 0) return 0;
    return progressMs / durationMs;
  }

  String get progressFormatted {
    final minutes = progressMs ~/ 60000;
    final seconds = (progressMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationFormatted {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get hasActiveDevice => device != null && device!.isActive;

  @override
  List<Object?> get props => [
    currentTrack,
    isPlaying,
    progressMs,
    durationMs,
    device,
    context,
    repeatMode,
    shuffleState,
    timestamp,
  ];
}

class Device extends Equatable {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final bool isRestricted;
  final int? volumePercent;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    this.isActive = false,
    this.isRestricted = false,
    this.volumePercent,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    isActive,
    isRestricted,
    volumePercent,
  ];
}
