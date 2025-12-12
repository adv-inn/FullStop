import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.code});
}

class SpotifyApiFailure extends Failure {
  final int? statusCode;

  const SpotifyApiFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

class LlmFailure extends Failure {
  const LlmFailure({super.message = 'LLM service error', super.code});
}

class PlaybackFailure extends Failure {
  const PlaybackFailure({
    super.message = 'Playback error occurred',
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class BpmApiFailure extends Failure {
  const BpmApiFailure({super.message = 'BPM service error', super.code});
}
