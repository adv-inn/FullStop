import 'dart:convert';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/audio_features.dart';
import '../../domain/entities/track.dart';
import '../config/llm_config.dart';
import '../prompts/playlist_prompts.dart';
import '../providers/llm_provider.dart';

class PlaylistAgentService {
  BaseLlmProvider? _provider;
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled && _provider != null;

  void initialize(LlmConfig config) {
    if (config.isValid) {
      _provider = LlmProviderFactory.create(config);
      _isEnabled = true;
      AppLogger.info(
        'LLM provider initialized: ${config.model} @ ${config.baseUrl}',
      );
    }
  }

  void disable() {
    _provider = null;
    _isEnabled = false;
  }

  Future<String> generatePlaylistDescription({
    required List<Artist> artists,
    required int trackCount,
    String? mood,
    String? activity,
  }) async {
    _ensureEnabled();

    final prompt = PlaylistPrompts.generatePlaylistDescription(
      artistNames: artists.map((a) => a.name).toList(),
      trackCount: trackCount,
      mood: mood,
      activity: activity,
    );

    return await _provider!.complete(prompt);
  }

  Future<List<String>> suggestTrackOrder({
    required List<Track> tracks,
    required List<AudioFeatures> audioFeatures,
    String? preference,
  }) async {
    _ensureEnabled();

    final trackData = <Map<String, dynamic>>[];
    for (int i = 0; i < tracks.length && i < audioFeatures.length; i++) {
      trackData.add({
        'name': tracks[i].name,
        'artist': tracks[i].artistNames,
        'bpm': audioFeatures[i].bpm,
        'energy': audioFeatures[i].energy.toStringAsFixed(2),
      });
    }

    final prompt = PlaylistPrompts.suggestTrackOrder(
      tracks: trackData,
      preference: preference,
    );

    final response = await _provider!.complete(prompt);

    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list.cast<String>();
      }
    } catch (e) {
      AppLogger.warning('Failed to parse track order response', e);
    }

    return tracks.map((t) => t.name).toList();
  }

  Future<List<String>> filterTracksByMood({
    required List<Track> tracks,
    required List<AudioFeatures> audioFeatures,
    required String mood,
  }) async {
    _ensureEnabled();

    final trackData = <Map<String, dynamic>>[];
    for (int i = 0; i < tracks.length && i < audioFeatures.length; i++) {
      trackData.add({
        'name': tracks[i].name,
        'valence': audioFeatures[i].valence.toStringAsFixed(2),
        'energy': audioFeatures[i].energy.toStringAsFixed(2),
        'tempo': audioFeatures[i].tempo.round(),
      });
    }

    final prompt = PlaylistPrompts.filterTracksByMood(
      tracks: trackData,
      mood: mood,
    );

    final response = await _provider!.complete(prompt);

    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list.cast<String>();
      }
    } catch (e) {
      AppLogger.warning('Failed to parse mood filter response', e);
    }

    return tracks.map((t) => t.name).toList();
  }

  Future<List<String>> suggestRelatedArtists({
    required List<Artist> currentArtists,
  }) async {
    _ensureEnabled();

    final genres = currentArtists
        .expand((a) => a.genres)
        .toSet()
        .take(3)
        .join(', ');

    final prompt = PlaylistPrompts.suggestRelatedArtists(
      currentArtists: currentArtists.map((a) => a.name).toList(),
      genre: genres.isEmpty ? 'various' : genres,
    );

    final response = await _provider!.complete(prompt);

    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        final list = jsonDecode(jsonMatch.group(0)!) as List;
        return list.cast<String>();
      }
    } catch (e) {
      AppLogger.warning('Failed to parse artist suggestions', e);
    }

    return [];
  }

  Future<Map<String, dynamic>> analyzeListeningPattern({
    required List<Track> recentTracks,
  }) async {
    _ensureEnabled();

    final trackData = recentTracks
        .map(
          (t) => {
            'name': t.name,
            'artist': t.artistNames,
            'genre': 'unknown', // Would need genre data
          },
        )
        .toList();

    final prompt = PlaylistPrompts.analyzeListeningPattern(
      recentTracks: trackData,
    );

    return await _provider!.completeJson(prompt);
  }

  void _ensureEnabled() {
    if (!isEnabled || _provider == null) {
      throw const LlmException(
        message:
            'LLM features are not enabled. Configure your API key in settings.',
      );
    }
  }
}
