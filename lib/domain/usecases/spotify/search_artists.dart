import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/artist.dart';
import '../../repositories/spotify_repository.dart';
import '../usecase.dart';

class SearchArtists extends UseCase<List<Artist>, SearchArtistsParams> {
  final SpotifyRepository repository;

  SearchArtists(this.repository);

  @override
  Future<Either<Failure, List<Artist>>> call(SearchArtistsParams params) async {
    return await repository.searchArtists(
      params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchArtistsParams extends Equatable {
  final String query;
  final int limit;
  final int offset;

  const SearchArtistsParams({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, limit, offset];
}
