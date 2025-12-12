import '../../domain/entities/artist.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/music_style.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../domain/services/track_dispatcher.dart';

/// Maximum number of artists allowed per session
/// This limit ensures:
/// 1. Enough "material" for each artist after smart dedupe
/// 2. Fast API response (avoid rate limiting)
/// 3. Coherent music style (avoid vibe fragmentation)
const int kMaxArtistsPerSession = 5;

/// Status for the create session flow
enum CreateSessionStatus { idle, creating, success, error }

/// Smart schedule matching mode
enum SmartScheduleMode {
  /// Match by predefined music style (BPM range)
  byStyle,

  /// Match by a selected track from user's Spotify playlists
  byPlaylist,

  /// Match by selected tracks from the chosen artists (multi-select, multi-BPM ranges)
  byArtistTrack,
}

/// A track with its BPM for artist track matching mode
class TrackWithBpm {
  final Track track;
  final int? bpm;
  final bool isLoadingBpm;

  const TrackWithBpm({
    required this.track,
    this.bpm,
    this.isLoadingBpm = false,
  });

  TrackWithBpm copyWith({int? bpm, bool? isLoadingBpm}) {
    return TrackWithBpm(
      track: track,
      bpm: bpm ?? this.bpm,
      isLoadingBpm: isLoadingBpm ?? this.isLoadingBpm,
    );
  }

  /// Get the BPM range this track falls into (±10 BPM tolerance)
  (int, int)? get bpmRange {
    if (bpm == null) return null;
    return (bpm! - 10, bpm! + 10);
  }
}

/// State for the create session flow
class CreateSessionState {
  final CreateSessionStatus status;
  final List<Artist> selectedArtists;
  final String? errorMessage;
  final FocusSession? createdSession;

  /// Whether smart scheduling is enabled
  final bool smartScheduleEnabled;

  /// Whether traditional scheduling is enabled
  final bool traditionalScheduleEnabled;

  /// Smart schedule mode (by style or by track)
  final SmartScheduleMode scheduleMode;

  /// Selected music style for smart scheduling (null means all styles)
  final MusicStyle? selectedStyle;

  /// Selected track for BPM matching (when mode is byTrack)
  final PlaylistTrack? selectedMatchTrack;

  /// The BPM of the selected track (cached after fetching audio features)
  final int? matchTrackBpm;

  /// Loading state for playlists
  final bool isLoadingPlaylists;

  /// User's playlists
  final List<Playlist> playlists;

  /// Currently selected playlist for browsing tracks
  final Playlist? selectedPlaylist;

  /// Loading state for playlist tracks
  final bool isLoadingPlaylistTracks;

  /// Tracks from selected playlist
  final List<PlaylistTrack> playlistTracks;

  /// Loading state for artist tracks
  final bool isLoadingArtistTracks;

  /// Tracks from selected artists with BPM data (for byArtistTrack mode)
  final List<TrackWithBpm> artistTracksWithBpm;

  /// Selected track IDs from artist tracks (for byArtistTrack mode, multi-select)
  final Set<String> selectedArtistTrackIds;

  /// Whether track limit is enabled for smart schedule
  final bool trackLimitEnabled;

  /// Track limit value (default 50)
  final int trackLimitValue;

  /// Dispatch mode for traditional scheduling (non-BPM based)
  /// Only used when smart scheduling is disabled
  final DispatchMode dispatchMode;

  const CreateSessionState({
    this.status = CreateSessionStatus.idle,
    this.selectedArtists = const [],
    this.errorMessage,
    this.createdSession,
    this.smartScheduleEnabled = false,
    this.traditionalScheduleEnabled = true, // Default to traditional scheduling
    this.scheduleMode = SmartScheduleMode.byStyle,
    this.selectedStyle,
    this.selectedMatchTrack,
    this.matchTrackBpm,
    this.isLoadingPlaylists = false,
    this.playlists = const [],
    this.selectedPlaylist,
    this.isLoadingPlaylistTracks = false,
    this.playlistTracks = const [],
    this.isLoadingArtistTracks = false,
    this.artistTracksWithBpm = const [],
    this.selectedArtistTrackIds = const {},
    this.trackLimitEnabled = true,
    this.trackLimitValue = 50,
    this.dispatchMode = DispatchMode.balanced,
  });

  CreateSessionState copyWith({
    CreateSessionStatus? status,
    List<Artist>? selectedArtists,
    String? errorMessage,
    FocusSession? createdSession,
    bool? smartScheduleEnabled,
    bool? traditionalScheduleEnabled,
    SmartScheduleMode? scheduleMode,
    MusicStyle? selectedStyle,
    PlaylistTrack? selectedMatchTrack,
    int? matchTrackBpm,
    bool? isLoadingPlaylists,
    List<Playlist>? playlists,
    Playlist? selectedPlaylist,
    bool? isLoadingPlaylistTracks,
    List<PlaylistTrack>? playlistTracks,
    bool? isLoadingArtistTracks,
    List<TrackWithBpm>? artistTracksWithBpm,
    Set<String>? selectedArtistTrackIds,
    bool? trackLimitEnabled,
    int? trackLimitValue,
    DispatchMode? dispatchMode,
    bool clearStyle = false,
    bool clearMatchTrack = false,
    bool clearSelectedPlaylist = false,
    bool clearArtistTracks = false,
  }) {
    return CreateSessionState(
      status: status ?? this.status,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      errorMessage: errorMessage,
      createdSession: createdSession,
      smartScheduleEnabled: smartScheduleEnabled ?? this.smartScheduleEnabled,
      traditionalScheduleEnabled:
          traditionalScheduleEnabled ?? this.traditionalScheduleEnabled,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      selectedStyle: clearStyle ? null : (selectedStyle ?? this.selectedStyle),
      selectedMatchTrack: clearMatchTrack
          ? null
          : (selectedMatchTrack ?? this.selectedMatchTrack),
      matchTrackBpm: clearMatchTrack
          ? null
          : (matchTrackBpm ?? this.matchTrackBpm),
      isLoadingPlaylists: isLoadingPlaylists ?? this.isLoadingPlaylists,
      playlists: playlists ?? this.playlists,
      selectedPlaylist: clearSelectedPlaylist
          ? null
          : (selectedPlaylist ?? this.selectedPlaylist),
      isLoadingPlaylistTracks:
          isLoadingPlaylistTracks ?? this.isLoadingPlaylistTracks,
      playlistTracks: clearSelectedPlaylist
          ? const []
          : (playlistTracks ?? this.playlistTracks),
      isLoadingArtistTracks:
          isLoadingArtistTracks ?? this.isLoadingArtistTracks,
      artistTracksWithBpm: clearArtistTracks
          ? const []
          : (artistTracksWithBpm ?? this.artistTracksWithBpm),
      selectedArtistTrackIds: clearArtistTracks
          ? const {}
          : (selectedArtistTrackIds ?? this.selectedArtistTrackIds),
      trackLimitEnabled: trackLimitEnabled ?? this.trackLimitEnabled,
      trackLimitValue: trackLimitValue ?? this.trackLimitValue,
      dispatchMode: dispatchMode ?? this.dispatchMode,
    );
  }

  bool get canCreate =>
      selectedArtists.isNotEmpty && status != CreateSessionStatus.creating;
  bool get isCreating => status == CreateSessionStatus.creating;

  /// Check if we can add more artists (under the limit)
  bool get canAddMoreArtists => selectedArtists.length < kMaxArtistsPerSession;

  /// Number of remaining artist slots
  int get remainingArtistSlots =>
      kMaxArtistsPerSession - selectedArtists.length;

  /// Generate default session name based on artists and style
  String generateDefaultName() {
    if (selectedArtists.isEmpty) return '';

    final artistNames = selectedArtists.length <= 2
        ? selectedArtists.map((a) => a.name).join(' & ')
        : '${selectedArtists.first.name} +${selectedArtists.length - 1}';

    if (smartScheduleEnabled &&
        scheduleMode == SmartScheduleMode.byPlaylist &&
        matchTrackBpm != null) {
      return '$artistNames ~${matchTrackBpm}BPM';
    }

    if (smartScheduleEnabled &&
        scheduleMode == SmartScheduleMode.byArtistTrack &&
        selectedArtistTrackIds.isNotEmpty) {
      final selectedTracks = artistTracksWithBpm.where(
        (t) => selectedArtistTrackIds.contains(t.track.id),
      );
      final bpms = selectedTracks
          .where((t) => t.bpm != null)
          .map((t) => t.bpm!)
          .toList();
      if (bpms.isNotEmpty) {
        if (bpms.length == 1) {
          return '$artistNames ~${bpms.first}BPM';
        } else {
          return '$artistNames ${bpms.length}曲';
        }
      }
    }

    if (smartScheduleEnabled &&
        scheduleMode == SmartScheduleMode.byStyle &&
        selectedStyle != null) {
      return '$artistNames ${selectedStyle!.icon}';
    }

    return artistNames;
  }

  /// Check if a track is selected in byArtistTrack mode
  bool isArtistTrackSelected(String trackId) {
    return selectedArtistTrackIds.contains(trackId);
  }

  /// Get selected tracks with BPM data
  List<TrackWithBpm> get selectedArtistTracks {
    return artistTracksWithBpm
        .where((t) => selectedArtistTrackIds.contains(t.track.id))
        .toList();
  }

  /// Get all unique BPM ranges from selected artist tracks
  List<(int, int)> get selectedBpmRanges {
    final ranges = <(int, int)>[];
    for (final track in selectedArtistTracks) {
      final range = track.bpmRange;
      if (range != null &&
          !ranges.any((r) => r.$1 == range.$1 && r.$2 == range.$2)) {
        ranges.add(range);
      }
    }
    return ranges;
  }
}
