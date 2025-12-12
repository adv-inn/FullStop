import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/spotify_api_client.dart';
import '../../data/repositories/playback_repository_impl.dart';
import '../../data/repositories/spotify_repository_impl.dart';
import '../../domain/repositories/playback_repository.dart';
import '../../domain/repositories/spotify_repository.dart';
import 'core_providers.dart';

/// Spotify API related providers

// API Client
final spotifyApiClientProvider = Provider<SpotifyApiClient>((ref) {
  final dio = ref.watch(apiDioProvider);
  return SpotifyApiClient(dio);
});

// Spotify Repository
final spotifyRepositoryProvider = Provider<SpotifyRepository>((ref) {
  final apiClient = ref.watch(spotifyApiClientProvider);
  return SpotifyRepositoryImpl(apiClient: apiClient);
});

// Playback Repository
final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final apiClient = ref.watch(spotifyApiClientProvider);
  return PlaybackRepositoryImpl(apiClient: apiClient);
});
