import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/audio_features.dart';
import '../../repositories/spotify_repository.dart';
import '../usecase.dart';

class GetAudioFeatures
    extends UseCase<List<AudioFeatures>, GetAudioFeaturesParams> {
  final SpotifyRepository repository;

  GetAudioFeatures(this.repository);

  @override
  Future<Either<Failure, List<AudioFeatures>>> call(
    GetAudioFeaturesParams params,
  ) async {
    if (params.trackIds.length == 1) {
      final result = await repository.getAudioFeatures(params.trackIds.first);
      return result.map((features) => [features]);
    }
    return await repository.getMultipleAudioFeatures(params.trackIds);
  }
}

class GetAudioFeaturesParams extends Equatable {
  final List<String> trackIds;

  const GetAudioFeaturesParams({required this.trackIds});

  @override
  List<Object?> get props => [trackIds];
}
