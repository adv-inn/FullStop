import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/track.dart';
import '../../repositories/spotify_repository.dart';
import '../usecase.dart';

class GetArtistTracks extends UseCase<List<Track>, GetArtistTracksParams> {
  final SpotifyRepository repository;

  GetArtistTracks(this.repository);

  @override
  Future<Either<Failure, List<Track>>> call(
    GetArtistTracksParams params,
  ) async {
    if (params.allTracks) {
      return await repository.getArtistAllTracks(
        params.artistId,
        includeFeatures: params.includeFeatures,
      );
    } else {
      return await repository.getArtistTopTracks(
        params.artistId,
        market: params.market,
      );
    }
  }
}

class GetArtistTracksParams extends Equatable {
  final String artistId;
  final bool allTracks;
  final bool includeFeatures;
  final String market;

  const GetArtistTracksParams({
    required this.artistId,
    this.allTracks = false,
    this.includeFeatures = true,
    this.market = 'US',
  });

  @override
  List<Object?> get props => [artistId, allTracks, includeFeatures, market];
}
