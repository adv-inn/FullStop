import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../entities/artist.dart';
import '../../entities/audio_features.dart';
import '../../entities/focus_session.dart';
import '../../entities/music_style.dart';
import '../../entities/track.dart';
import '../../repositories/bpm_repository.dart';
import '../../repositories/focus_session_repository.dart';
import '../../repositories/spotify_repository.dart';
import '../../services/track_dispatcher.dart';
import '../usecase.dart';

class CreateFocusSession
    extends UseCase<FocusSession, CreateFocusSessionParams> {
  final FocusSessionRepository focusRepository;
  final SpotifyRepository spotifyRepository;
  final BpmRepository? bpmRepository;

  CreateFocusSession({
    required this.focusRepository,
    required this.spotifyRepository,
    this.bpmRepository,
  });

  @override
  Future<Either<Failure, FocusSession>> call(
    CreateFocusSessionParams params,
  ) async {
    final onProgress = params.onProgress;

    // Phase 0: Fetch tracks
    final artistTrackPools = await _fetchArtistTracks(params, onProgress);

    // Phase 1: Selection (filter and schedule)
    final allTracks = artistTrackPools.values.expand((x) => x).toList();
    var filteredTracks = await _selectTracks(
      params,
      artistTrackPools,
      allTracks,
      onProgress,
    );

    // Phase 2: Apply True Shuffle post-processing
    filteredTracks = _applyTrueShuffle(params, filteredTracks);

    // Phase 3: Save session
    return _saveSession(params, filteredTracks, onProgress);
  }

  /// Phase 0: Fetch tracks from all artists
  /// Uses different sourcing strategies based on DispatchMode
  Future<Map<String, List<Track>>> _fetchArtistTracks(
    CreateFocusSessionParams params,
    SessionCreationProgressCallback? onProgress,
  ) async {
    final config = _FetchConfig.fromParams(params, _hasSmartScheduling(params));
    final artistIds = params.artists.map((a) => a.id).toSet();
    final artistTrackPools = <String, List<Track>>{};

    if (!config.showAlbumProgress) {
      onProgress?.call(
        SessionCreationPhase.fetchingTracks,
        0,
        params.artists.length,
      );
    }

    for (var i = 0; i < params.artists.length; i++) {
      final artist = params.artists[i];
      final tracks = await _fetchTracksForArtist(
        artist,
        params,
        config,
        onProgress,
      );

      artistTrackPools[artist.id] = _processArtistTracks(
        tracks,
        artistIds,
        params.settings.includeCollaborations,
      );

      if (!config.showAlbumProgress) {
        onProgress?.call(
          SessionCreationPhase.fetchingTracks,
          i + 1,
          params.artists.length,
          detail: artist.name,
        );
      }
    }

    _logFetchResult(artistTrackPools, params.artists.length, config);
    return artistTrackPools;
  }

  /// Fetch tracks for a single artist using the appropriate strategy
  Future<List<Track>> _fetchTracksForArtist(
    Artist artist,
    CreateFocusSessionParams params,
    _FetchConfig config,
    SessionCreationProgressCallback? onProgress,
  ) async {
    if (config.needsFullDiscography) {
      return _fetchFullDiscography(artist, params, config, onProgress);
    } else {
      return _fetchPopularTracks(artist);
    }
  }

  /// Strategy B: Album Traversal - for Balanced, DeepDive, Unfiltered, and Smart scheduling
  Future<List<Track>> _fetchFullDiscography(
    Artist artist,
    CreateFocusSessionParams params,
    _FetchConfig config,
    SessionCreationProgressCallback? onProgress,
  ) async {
    final albumProgressCallback = _createAlbumProgressCallback(
      artist,
      config.showAlbumProgress,
      onProgress,
    );

    final tracksResult = await spotifyRepository.getArtistAllTracks(
      artist.id,
      includeFeatures: params.settings.includeFeatures,
      includeLiveAlbums: config.includeLiveAlbums,
      market: params.market,
      onProgress: albumProgressCallback,
    );

    return tracksResult.fold((failure) => <Track>[], (result) => result);
  }

  /// Strategy A: Quick Search - for HitsOnly mode (faster)
  Future<List<Track>> _fetchPopularTracks(Artist artist) async {
    final tracksResult = await spotifyRepository.getArtistPopularTracks(
      artist.id,
      artist.name,
      limit: 50,
    );
    return tracksResult.fold((failure) => <Track>[], (result) => result);
  }

  /// Create progress callback for album-level progress reporting
  TrackFetchProgressCallback? _createAlbumProgressCallback(
    Artist artist,
    bool showAlbumProgress,
    SessionCreationProgressCallback? onProgress,
  ) {
    if (!showAlbumProgress || onProgress == null) return null;

    return (current, total, phase) {
      if (phase == 'albums') {
        onProgress(
          SessionCreationPhase.fetchingAlbums,
          0,
          1,
          detail: artist.name,
        );
      } else {
        onProgress(
          SessionCreationPhase.fetchingTracks,
          current,
          total,
          detail: artist.name,
        );
      }
    };
  }

  /// Log the fetch result summary
  void _logFetchResult(
    Map<String, List<Track>> pools,
    int artistCount,
    _FetchConfig config,
  ) {
    final totalFetched = pools.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final strategy = config.needsFullDiscography
        ? 'Album Traversal'
        : 'Quick Search';
    final filterStatus = config.includeLiveAlbums
        ? ' (unfiltered)'
        : ' (filtered)';
    AppLogger.info(
      '[$strategy$filterStatus] Fetched $totalFetched total tracks from $artistCount artists',
    );
  }

  /// Process tracks for a single artist (filter collaborations, remove duplicates)
  List<Track> _processArtistTracks(
    List<Track> tracks,
    Set<String> artistIds,
    bool includeCollaborations,
  ) {
    var artistTracks = tracks;
    if (!includeCollaborations) {
      artistTracks = tracks.where((track) {
        return track.artists.any((a) => artistIds.contains(a.id));
      }).toList();
    }

    final uniqueTracks = <String, Track>{};
    for (final track in artistTracks) {
      uniqueTracks[track.id] = track;
    }
    return uniqueTracks.values.toList();
  }

  /// Phase 1: Select and filter tracks based on scheduling mode
  Future<List<Track>> _selectTracks(
    CreateFocusSessionParams params,
    Map<String, List<Track>> artistTrackPools,
    List<Track> allTracks,
    SessionCreationProgressCallback? onProgress,
  ) async {
    final hasSmartScheduling = _hasSmartScheduling(params);

    if (hasSmartScheduling) {
      return _applySmartScheduling(params, allTracks, onProgress);
    } else if (params.dispatchMode != null) {
      return _applyTraditionalScheduling(params, artistTrackPools, allTracks);
    } else {
      return _applyNoScheduling(allTracks, params.trackLimit);
    }
  }

  bool _hasSmartScheduling(CreateFocusSessionParams params) {
    return (params.selectedTrackBpms != null &&
            params.selectedTrackBpms!.isNotEmpty) ||
        params.filterByStyle != null ||
        params.filterByBpm != null;
  }

  /// Apply smart scheduling (BPM-based filtering)
  Future<List<Track>> _applySmartScheduling(
    CreateFocusSessionParams params,
    List<Track> allTracks,
    SessionCreationProgressCallback? onProgress,
  ) async {
    List<Track> filteredTracks;

    if (params.selectedTrackBpms != null &&
        params.selectedTrackBpms!.isNotEmpty) {
      filteredTracks = await _filterBySelectedBpms(
        allTracks,
        params.selectedTrackBpms!,
        onProgress,
      );
    } else if (params.filterByStyle != null) {
      filteredTracks = await _filterByStyle(
        allTracks,
        params.filterByStyle!,
        onProgress,
      );
    } else if (params.filterByBpm != null) {
      filteredTracks = await _filterByBpm(
        allTracks,
        params.filterByBpm!,
        onProgress,
      );
    } else {
      filteredTracks = allTracks;
    }

    return _applyTrackLimit(filteredTracks, params.trackLimit);
  }

  /// Buffer size for selection to account for potential drops during shuffle
  /// This ensures we always have enough tracks after final processing
  static const int _selectionBuffer = 5;

  /// Apply traditional scheduling (rule-based)
  ///
  /// 管道顺序 (Pipeline Order):
  /// 1. Pre-Dedupe: 先清洗原始池，去除 Live/Remix 重复
  /// 2. Buffered Selection: 多选 _selectionBuffer 首，防止 shuffle 后不够
  /// 3. True Shuffle: 专辑隔离洗牌
  /// 4. Final Trim: 截断到精确目标数量
  List<Track> _applyTraditionalScheduling(
    CreateFocusSessionParams params,
    Map<String, List<Track>> artistTrackPools,
    List<Track> allTracks,
  ) {
    final dispatchMode = params.dispatchMode!;
    final isMultiArtist = params.artists.length > 1;
    final targetCount = params.trackLimit ?? 50;
    final skipDedupe = dispatchMode == DispatchMode.unfiltered;

    AppLogger.info(
      'Traditional scheduling: ${dispatchMode.displayName} mode '
      '(${isMultiArtist ? "multi-artist" : "single artist"})',
    );

    // === Step 1: Pre-Dedupe (前置去重) ===
    // 在选品前清洗所有池子，避免"选50→去重变44"的问题
    Map<String, List<Track>> cleanPools;
    List<Track> cleanAllTracks;

    if (skipDedupe) {
      // Unfiltered 模式：保留所有版本
      cleanPools = artistTrackPools;
      cleanAllTracks = allTracks;
    } else {
      // 对每个歌手的池子独立去重
      cleanPools = artistTrackPools.map(
        (artistId, tracks) =>
            MapEntry(artistId, TrueShufflePipeline.preDedupe(tracks)),
      );
      cleanAllTracks = TrueShufflePipeline.preDedupe(allTracks);

      final rawCount = allTracks.length;
      final cleanCount = cleanAllTracks.length;
      AppLogger.debug(
        'Pre-Dedupe: $rawCount → $cleanCount tracks (removed ${rawCount - cleanCount} duplicates)',
      );
    }

    // === Step 2-4: Selection + Shuffle + Trim ===
    if (isMultiArtist) {
      return _multiArtistScheduling(
        cleanPools,
        dispatchMode,
        targetCount,
        params,
      );
    } else {
      return _singleArtistScheduling(
        cleanAllTracks,
        dispatchMode,
        targetCount,
        params,
      );
    }
  }

  List<Track> _multiArtistScheduling(
    Map<String, List<Track>> artistTrackPools,
    DispatchMode dispatchMode,
    int targetCount,
    CreateFocusSessionParams params,
  ) {
    // === Step 2: Buffered Selection (冗余选品) ===
    // 多选 _selectionBuffer 首，为 shuffle 过程预留余量
    final bufferedTarget = targetCount + _selectionBuffer;

    var tracks = MultiArtistPipeline.mix(
      artistTrackPools: artistTrackPools,
      targetCount: bufferedTarget,
      mode: dispatchMode,
      skipDedupe: true, // 已在 Pre-Dedupe 阶段完成，这里跳过
    );

    // === Step 3: True Shuffle (专辑隔离洗牌) ===
    if (params.trueShuffle) {
      tracks = TrueShufflePipeline.shuffle(tracks);
    }

    // === Step 4: Final Trim (最终截断) ===
    // 洗牌后截断到精确目标数量
    if (tracks.length > targetCount) {
      tracks = tracks.take(targetCount).toList();
    }

    AppLogger.info(
      'Multi-artist: ${tracks.length} tracks (target: $targetCount, buffered: $bufferedTarget)',
    );
    return tracks;
  }

  List<Track> _singleArtistScheduling(
    List<Track> allTracks,
    DispatchMode dispatchMode,
    int targetCount,
    CreateFocusSessionParams params,
  ) {
    // === Step 2: Buffered Selection (冗余选品) ===
    // 多选 _selectionBuffer 首，为 shuffle 过程预留余量
    final bufferedTarget = targetCount + _selectionBuffer;

    // 使用新版 dispatch，传入 buffered target，跳过内部去重
    var tracks = TrackDispatcher.dispatch(
      allTracks,
      dispatchMode,
      trackLimit: bufferedTarget,
      trueShuffle: false, // 手动控制 shuffle 流程
    );

    // === Step 3: True Shuffle (专辑隔离洗牌) ===
    if (params.trueShuffle) {
      tracks = TrueShufflePipeline.shuffle(tracks);
    } else {
      // 即使不启用 True Shuffle，也做简单 shuffle
      tracks.shuffle();
    }

    // === Step 4: Final Trim (最终截断) ===
    // 洗牌后截断到精确目标数量
    if (tracks.length > targetCount) {
      tracks = tracks.take(targetCount).toList();
    }

    AppLogger.info(
      'Single artist: ${tracks.length} tracks (target: $targetCount, buffered: $bufferedTarget, mode: ${dispatchMode.displayName})',
    );
    return tracks;
  }

  List<Track> _applyNoScheduling(List<Track> allTracks, int? trackLimit) {
    return _applyTrackLimit(allTracks, trackLimit);
  }

  List<Track> _applyTrackLimit(List<Track> tracks, int? trackLimit) {
    if (trackLimit != null && trackLimit > 0 && tracks.length > trackLimit) {
      final shuffled = List<Track>.from(tracks)..shuffle();
      AppLogger.info('Applied track limit: $trackLimit tracks');
      return shuffled.take(trackLimit).toList();
    }
    return tracks;
  }

  /// Phase 2: Apply True Shuffle post-processing
  List<Track> _applyTrueShuffle(
    CreateFocusSessionParams params,
    List<Track> tracks,
  ) {
    final hasSmartScheduling = _hasSmartScheduling(params);
    final needsTrueShuffle =
        params.trueShuffle &&
        (hasSmartScheduling || params.dispatchMode == null);

    if (needsTrueShuffle) {
      AppLogger.info('Applied True Shuffle to ${tracks.length} tracks');
      return TrueShufflePipeline.shuffle(tracks);
    }
    return tracks;
  }

  /// Phase 3: Save the session
  Future<Either<Failure, FocusSession>> _saveSession(
    CreateFocusSessionParams params,
    List<Track> tracks,
    SessionCreationProgressCallback? onProgress,
  ) async {
    onProgress?.call(SessionCreationPhase.saving, 0, 1);

    // New sessions go to the top (lowest sortOrder)
    final minSortOrder = await focusRepository.getMinSortOrder();

    final session = FocusSession(
      id: const Uuid().v4(),
      name: params.name ?? _generateSessionName(params.artists),
      artists: params.artists,
      tracks: tracks,
      settings: params.settings,
      createdAt: DateTime.now(),
      sortOrder: minSortOrder - 1,
    );

    final result = await focusRepository.createSession(session);
    onProgress?.call(SessionCreationPhase.saving, 1, 1);

    return result;
  }

  /// Filter tracks by selected BPM values using GetSongBPM API
  Future<List<Track>> _filterBySelectedBpms(
    List<Track> tracks,
    List<int> selectedBpms,
    SessionCreationProgressCallback? onProgress,
  ) async {
    if (tracks.isEmpty || selectedBpms.isEmpty) return tracks;
    if (bpmRepository == null) {
      AppLogger.warning('BPM repository not available, returning all tracks');
      return tracks;
    }

    final bpmRanges = _createBpmRanges(selectedBpms);
    final bpmMap = await _fetchBpmData(tracks, onProgress);

    if (bpmMap == null) return tracks;

    return _filterTracksByBpmRanges(tracks, bpmMap, bpmRanges, onProgress);
  }

  /// Create BPM ranges from selected BPMs (±10 tolerance)
  List<(int, int)> _createBpmRanges(List<int> selectedBpms) {
    return selectedBpms.map((bpm) => (bpm - 10, bpm + 10)).toList();
  }

  /// Fetch BPM data for all tracks
  Future<Map<String, int>?> _fetchBpmData(
    List<Track> tracks,
    SessionCreationProgressCallback? onProgress,
  ) async {
    AppLogger.info('Fetching BPM for ${tracks.length} tracks...');

    final songs = tracks
        .map(
          (t) => (
            title: t.name,
            artistName: t.artists.isNotEmpty ? t.artists.first.name : '',
          ),
        )
        .toList();

    onProgress?.call(SessionCreationPhase.fetchingBpm, 0, tracks.length);

    final bpmResult = await bpmRepository!.getBpmForSongs(
      songs,
      onProgress: onProgress != null
          ? (current, total) =>
                onProgress(SessionCreationPhase.fetchingBpm, current, total)
          : null,
    );

    return bpmResult.fold((failure) {
      AppLogger.error('Failed to fetch BPM data: ${failure.message}');
      return null;
    }, (bpmMap) => bpmMap);
  }

  /// Filter tracks that match any of the BPM ranges
  List<Track> _filterTracksByBpmRanges(
    List<Track> tracks,
    Map<String, int> bpmMap,
    List<(int, int)> bpmRanges,
    SessionCreationProgressCallback? onProgress,
  ) {
    onProgress?.call(SessionCreationPhase.filtering, 0, 1);

    final filteredTracks = tracks.where((track) {
      final key =
          '${track.name}|${track.artists.isNotEmpty ? track.artists.first.name : ''}';
      final bpm = bpmMap[key];
      if (bpm == null) return false;
      return bpmRanges.any((range) => bpm >= range.$1 && bpm <= range.$2);
    }).toList();

    onProgress?.call(SessionCreationPhase.filtering, 1, 1);

    final rangesStr = bpmRanges.map((r) => '${r.$1}-${r.$2}').join(', ');
    AppLogger.info(
      'Smart scheduling (byArtistTrack): fetched BPM for ${bpmMap.length}/${tracks.length} tracks, '
      'filtered to ${filteredTracks.length} for BPM ranges: [$rangesStr]',
    );

    return filteredTracks;
  }

  /// Filter tracks by music style using BPM from audio features
  Future<List<Track>> _filterByStyle(
    List<Track> tracks,
    MusicStyle style,
    SessionCreationProgressCallback? onProgress,
  ) async {
    if (tracks.isEmpty) return tracks;

    onProgress?.call(SessionCreationPhase.fetchingBpm, 0, tracks.length);
    final featuresMap = await _fetchAudioFeatures(tracks, onProgress);

    // Report filtering phase
    onProgress?.call(SessionCreationPhase.filtering, 0, 1);

    // Filter tracks that match the style's BPM range
    final filteredTracks = tracks.where((track) {
      final features = featuresMap[track.id];
      if (features == null) return false;
      return style.matchesBpm(features.tempo);
    }).toList();

    // Report filtering complete
    onProgress?.call(SessionCreationPhase.filtering, 1, 1);

    AppLogger.info(
      'Smart scheduling: filtered ${tracks.length} tracks to ${filteredTracks.length} '
      'for style ${style.name} (BPM range: ${style.bpmRange})',
    );

    return filteredTracks;
  }

  /// Filter tracks by a specific BPM (with tolerance of ±10 BPM)
  Future<List<Track>> _filterByBpm(
    List<Track> tracks,
    int targetBpm,
    SessionCreationProgressCallback? onProgress,
  ) async {
    if (tracks.isEmpty) return tracks;

    const int tolerance = 10;
    final minBpm = targetBpm - tolerance;
    final maxBpm = targetBpm + tolerance;

    onProgress?.call(SessionCreationPhase.fetchingBpm, 0, tracks.length);
    final featuresMap = await _fetchAudioFeatures(tracks, onProgress);

    // Report filtering phase
    onProgress?.call(SessionCreationPhase.filtering, 0, 1);

    // Filter tracks that match the target BPM range
    final filteredTracks = tracks.where((track) {
      final features = featuresMap[track.id];
      if (features == null) return false;
      return features.tempo >= minBpm && features.tempo <= maxBpm;
    }).toList();

    // Report filtering complete
    onProgress?.call(SessionCreationPhase.filtering, 1, 1);

    AppLogger.info(
      'Smart scheduling: filtered ${tracks.length} tracks to ${filteredTracks.length} '
      'for BPM $targetBpm (range: $minBpm-$maxBpm)',
    );

    return filteredTracks;
  }

  /// Fetch audio features for all tracks in batches
  Future<Map<String, AudioFeatures>> _fetchAudioFeatures(
    List<Track> tracks,
    SessionCreationProgressCallback? onProgress,
  ) async {
    final trackIds = tracks.map((t) => t.id).toList();
    final Map<String, AudioFeatures> featuresMap = {};
    final totalTracks = tracks.length;

    // Spotify API allows up to 100 tracks per request
    for (var i = 0; i < trackIds.length; i += 100) {
      final batch = trackIds.skip(i).take(100).toList();
      final result = await spotifyRepository.getMultipleAudioFeatures(batch);

      result.fold(
        (failure) {
          AppLogger.error('Failed to get audio features for batch $i', failure);
        },
        (features) {
          for (final feature in features) {
            featuresMap[feature.id] = feature;
          }
        },
      );

      // Report progress after each batch
      final processedCount = (i + batch.length).clamp(0, totalTracks);
      onProgress?.call(
        SessionCreationPhase.fetchingBpm,
        processedCount,
        totalTracks,
      );
    }

    return featuresMap;
  }

  String _generateSessionName(List<Artist> artists) {
    if (artists.isEmpty) return 'New Focus Session';
    if (artists.length == 1) return 'Focus: ${artists.first.name}';
    if (artists.length == 2) {
      return 'Focus: ${artists[0].name} & ${artists[1].name}';
    }
    return 'Focus: ${artists.first.name} +${artists.length - 1}';
  }
}

/// Progress callback for session creation
/// [phase] is the current phase name
/// [current] is the current item being processed (0-based)
/// [total] is the total number of items to process
/// [detail] is optional additional detail (e.g., artist name, album count)
typedef SessionCreationProgressCallback =
    void Function(
      SessionCreationPhase phase,
      int current,
      int total, {
      String? detail,
    });

/// Phases of session creation for progress reporting
enum SessionCreationPhase {
  /// Fetching albums for an artist
  fetchingAlbums,

  /// Fetching tracks from albums
  fetchingTracks,

  /// Fetching BPM data
  fetchingBpm,

  /// Filtering tracks
  filtering,

  /// Saving session
  saving,
}

class CreateFocusSessionParams extends Equatable {
  final List<Artist> artists;
  final String? name;
  final FocusSessionSettings settings;

  // ============================================================
  // Smart Scheduling Parameters (BPM-based)
  // ============================================================

  /// If set, filter tracks by this music style using BPM
  final MusicStyle? filterByStyle;

  /// If set, filter tracks by this specific BPM (±10 tolerance)
  final int? filterByBpm;

  /// Selected track BPM values for byArtistTrack mode (used to create BPM ranges)
  /// The use case will fetch BPM for ALL artist tracks using GetSongBPM
  final List<int>? selectedTrackBpms;

  // ============================================================
  // Traditional Scheduling Parameters (Rule-based)
  // ============================================================

  /// Dispatch mode for traditional scheduling (non-BPM based)
  /// Only used when no smart scheduling parameters are set
  /// Default: DispatchMode.balanced
  final DispatchMode? dispatchMode;

  // ============================================================
  // Common Parameters
  // ============================================================

  /// Maximum number of tracks to include in the session (null = no limit)
  final int? trackLimit;

  /// Whether to apply True Shuffle post-processing
  /// True Shuffle includes:
  /// - Smart dedupe (remove Live/Remix duplicates)
  /// - Album spread shuffle (avoid consecutive same-album tracks)
  /// Default: true
  final bool trueShuffle;

  /// User's market (country code) for regional content filtering
  /// ISO 3166-1 alpha-2 country code (e.g., 'US', 'JP', 'CN')
  /// Used to filter out region-locked content
  final String? market;

  /// Optional progress callback for reporting creation progress
  final SessionCreationProgressCallback? onProgress;

  const CreateFocusSessionParams({
    required this.artists,
    this.name,
    this.settings = const FocusSessionSettings(),
    this.filterByStyle,
    this.filterByBpm,
    this.selectedTrackBpms,
    this.dispatchMode,
    this.trackLimit,
    this.trueShuffle = true,
    this.market,
    this.onProgress,
  });

  @override
  List<Object?> get props => [
    artists,
    name,
    settings,
    filterByStyle,
    filterByBpm,
    selectedTrackBpms,
    dispatchMode,
    trackLimit,
    trueShuffle,
    market,
  ];
}

/// Configuration for track fetching strategy
/// Extracted to reduce complexity of _fetchArtistTracks
class _FetchConfig {
  final bool needsFullDiscography;
  final bool includeLiveAlbums;
  final bool showAlbumProgress;

  const _FetchConfig({
    required this.needsFullDiscography,
    required this.includeLiveAlbums,
    required this.showAlbumProgress,
  });

  factory _FetchConfig.fromParams(
    CreateFocusSessionParams params,
    bool hasSmartScheduling,
  ) {
    final useQuickSearch = params.dispatchMode == DispatchMode.hitsOnly;
    final needsFullDiscography = !useQuickSearch || hasSmartScheduling;
    final includeLiveAlbums = params.dispatchMode == DispatchMode.unfiltered;
    final isSingleArtist = params.artists.length == 1;
    final showAlbumProgress = isSingleArtist && needsFullDiscography;

    return _FetchConfig(
      needsFullDiscography: needsFullDiscography,
      includeLiveAlbums: includeLiveAlbums,
      showAlbumProgress: showAlbumProgress,
    );
  }
}
