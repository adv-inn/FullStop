import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/playback_state.dart';
import '../../repositories/playback_repository.dart';
import '../usecase.dart';

class ControlPlayback extends UseCase<void, PlaybackCommand> {
  final PlaybackRepository repository;

  ControlPlayback(this.repository);

  @override
  Future<Either<Failure, void>> call(PlaybackCommand command) async {
    return switch (command) {
      PlayCommand cmd => repository.play(
        deviceId: cmd.deviceId,
        contextUri: cmd.contextUri,
        uris: cmd.uris,
        offsetPosition: cmd.offsetPosition,
        positionMs: cmd.positionMs,
      ),
      PauseCommand cmd => repository.pause(deviceId: cmd.deviceId),
      NextCommand cmd => repository.skipToNext(deviceId: cmd.deviceId),
      PreviousCommand cmd => repository.skipToPrevious(deviceId: cmd.deviceId),
      SeekCommand cmd => repository.seekToPosition(
        cmd.positionMs,
        deviceId: cmd.deviceId,
      ),
      RepeatCommand cmd => repository.setRepeatMode(
        cmd.mode,
        deviceId: cmd.deviceId,
      ),
      ShuffleCommand cmd => repository.setShuffle(
        cmd.state,
        deviceId: cmd.deviceId,
      ),
      VolumeCommand cmd => repository.setVolume(
        cmd.volumePercent,
        deviceId: cmd.deviceId,
      ),
      QueueCommand cmd => repository.addToQueue(
        cmd.uri,
        deviceId: cmd.deviceId,
      ),
    };
  }
}

sealed class PlaybackCommand extends Equatable {
  final String? deviceId;

  const PlaybackCommand({this.deviceId});
}

class PlayCommand extends PlaybackCommand {
  final String? contextUri;
  final List<String>? uris;
  final int? offsetPosition;
  final int? positionMs;

  const PlayCommand({
    super.deviceId,
    this.contextUri,
    this.uris,
    this.offsetPosition,
    this.positionMs,
  });

  @override
  List<Object?> get props => [
    deviceId,
    contextUri,
    uris,
    offsetPosition,
    positionMs,
  ];
}

class PauseCommand extends PlaybackCommand {
  const PauseCommand({super.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

class NextCommand extends PlaybackCommand {
  const NextCommand({super.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

class PreviousCommand extends PlaybackCommand {
  const PreviousCommand({super.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

class SeekCommand extends PlaybackCommand {
  final int positionMs;

  const SeekCommand({required this.positionMs, super.deviceId});

  @override
  List<Object?> get props => [positionMs, deviceId];
}

class RepeatCommand extends PlaybackCommand {
  final RepeatMode mode;

  const RepeatCommand({required this.mode, super.deviceId});

  @override
  List<Object?> get props => [mode, deviceId];
}

class ShuffleCommand extends PlaybackCommand {
  final bool state;

  const ShuffleCommand({required this.state, super.deviceId});

  @override
  List<Object?> get props => [state, deviceId];
}

class VolumeCommand extends PlaybackCommand {
  final int volumePercent;

  const VolumeCommand({required this.volumePercent, super.deviceId});

  @override
  List<Object?> get props => [volumePercent, deviceId];
}

class QueueCommand extends PlaybackCommand {
  final String uri;

  const QueueCommand({required this.uri, super.deviceId});

  @override
  List<Object?> get props => [uri, deviceId];
}
