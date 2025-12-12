import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/track.dart';
import '../di/injection_container.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState {
  final SearchStatus status;
  final List<Artist> artists;
  final List<Track> tracks;
  final String query;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.artists = const [],
    this.tracks = const [],
    this.query = '',
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Artist>? artists,
    List<Track>? tracks,
    String? query,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      artists: artists ?? this.artists,
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;

  SearchNotifier(this.ref) : super(const SearchState());

  Future<void> searchArtists(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading, query: query);

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final result = await spotifyRepo.searchArtists(query);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
        );
      },
      (artists) {
        state = state.copyWith(status: SearchStatus.success, artists: artists);
      },
    );
  }

  Future<void> searchTracks(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading, query: query);

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final result = await spotifyRepo.searchTracks(query);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
        );
      },
      (tracks) {
        state = state.copyWith(status: SearchStatus.success, tracks: tracks);
      },
    );
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref);
});
