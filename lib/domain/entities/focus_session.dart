import 'package:equatable/equatable.dart';
import 'artist.dart';
import 'repeat_mode.dart';
import 'track.dart';

export 'repeat_mode.dart';

/// Represents a focus session with specific artists
class FocusSession extends Equatable {
  final String id;
  final String name;
  final List<Artist> artists;
  final List<Track> tracks;
  final FocusSessionSettings settings;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;

  /// Sort order for display (lower = higher in list)
  final int sortOrder;

  /// Whether this session is pinned to the top
  final bool isPinned;

  /// Timestamp when the session was pinned (for ordering multiple pinned sessions)
  final DateTime? pinnedAt;

  const FocusSession({
    required this.id,
    required this.name,
    required this.artists,
    this.tracks = const [],
    this.settings = const FocusSessionSettings(),
    required this.createdAt,
    this.lastPlayedAt,
    this.sortOrder = 0,
    this.isPinned = false,
    this.pinnedAt,
  });

  bool get isEmpty => artists.isEmpty && tracks.isEmpty;
  int get trackCount => tracks.length;
  int get artistCount => artists.length;

  String get artistNames {
    if (artists.isEmpty) return '';
    if (artists.length == 1) return artists.first.name;
    if (artists.length == 2) {
      return '${artists[0].name} & ${artists[1].name}';
    }
    return '${artists.take(2).map((a) => a.name).join(', ')} +${artists.length - 2}';
  }

  Duration get totalDuration {
    final totalMs = tracks.fold<int>(0, (sum, track) => sum + track.durationMs);
    return Duration(milliseconds: totalMs);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    artists,
    tracks,
    settings,
    createdAt,
    lastPlayedAt,
    sortOrder,
    isPinned,
    pinnedAt,
  ];

  /// Create a copy with updated sortOrder
  FocusSession copyWithSortOrder(int newSortOrder) {
    return FocusSession(
      id: id,
      name: name,
      artists: artists,
      tracks: tracks,
      settings: settings,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt,
      sortOrder: newSortOrder,
      isPinned: isPinned,
      pinnedAt: pinnedAt,
    );
  }

  /// Create a copy with updated pin status
  FocusSession copyWithPinned({required bool pinned, DateTime? pinnedTime}) {
    return FocusSession(
      id: id,
      name: name,
      artists: artists,
      tracks: tracks,
      settings: settings,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt,
      sortOrder: sortOrder,
      isPinned: pinned,
      pinnedAt: pinned ? (pinnedTime ?? DateTime.now()) : null,
    );
  }
}

/// Playback control settings (shuffle, repeat mode)
/// These settings control how the session is played.
class PlaybackSettings extends Equatable {
  final bool shuffle;
  final RepeatMode repeatMode;

  const PlaybackSettings({
    this.shuffle = false,
    this.repeatMode = RepeatMode.context,
  });

  @override
  List<Object?> get props => [shuffle, repeatMode];
}

/// Content filter settings (BPM, energy, features, collaborations)
/// These settings define what tracks are included in the session.
class ContentFilterSettings extends Equatable {
  final int? minBpm;
  final int? maxBpm;
  final double? minEnergy;
  final double? maxEnergy;
  final bool includeFeatures;
  final bool includeCollaborations;

  const ContentFilterSettings({
    this.minBpm,
    this.maxBpm,
    this.minEnergy,
    this.maxEnergy,
    this.includeFeatures = true,
    this.includeCollaborations = true,
  });

  @override
  List<Object?> get props => [
    minBpm,
    maxBpm,
    minEnergy,
    maxEnergy,
    includeFeatures,
    includeCollaborations,
  ];
}

/// Combined settings for a focus session.
/// Separates playback control from content filtering for better organization.
class FocusSessionSettings extends Equatable {
  final PlaybackSettings playback;
  final ContentFilterSettings contentFilter;

  const FocusSessionSettings({
    this.playback = const PlaybackSettings(),
    this.contentFilter = const ContentFilterSettings(),
  });

  // Convenience getters for backward compatibility
  bool get shuffle => playback.shuffle;
  RepeatMode get repeatMode => playback.repeatMode;
  int? get minBpm => contentFilter.minBpm;
  int? get maxBpm => contentFilter.maxBpm;
  double? get minEnergy => contentFilter.minEnergy;
  double? get maxEnergy => contentFilter.maxEnergy;
  bool get includeFeatures => contentFilter.includeFeatures;
  bool get includeCollaborations => contentFilter.includeCollaborations;

  @override
  List<Object?> get props => [playback, contentFilter];
}
