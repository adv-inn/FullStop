import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/music_style.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../../domain/services/track_dispatcher.dart';
import '../../domain/usecases/focus/create_focus_session.dart'
    show CreateFocusSession, CreateFocusSessionParams;
import '../di/injection_container.dart';
import 'auth_provider.dart';
import 'create_session_state.dart';
import 'focus_session_provider.dart';
import 'schedule_preferences_provider.dart';

// Re-export state types for consumers
export 'create_session_state.dart';

class CreateSessionNotifier extends StateNotifier<CreateSessionState> {
  final Ref ref;

  CreateSessionNotifier(this.ref) : super(const CreateSessionState()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final prefs = ref.read(schedulePreferencesProvider);
    state = state.copyWith(
      traditionalScheduleEnabled:
          prefs.scheduleType == ScheduleType.traditional,
      smartScheduleEnabled: prefs.scheduleType == ScheduleType.smart,
      dispatchMode: prefs.dispatchMode,
    );
  }

  // ============================================================
  // Artist Management
  // ============================================================

  /// Try to add an artist. Returns true if successful, false if limit reached.
  bool addArtist(Artist artist) {
    // Check if already selected
    if (state.selectedArtists.any((a) => a.id == artist.id)) {
      return true; // Already selected, consider it success
    }

    // Check if we've reached the limit
    if (!state.canAddMoreArtists) {
      return false; // Limit reached
    }

    state = state.copyWith(selectedArtists: [...state.selectedArtists, artist]);

    if (state.smartScheduleEnabled &&
        state.scheduleMode == SmartScheduleMode.byArtistTrack) {
      _loadTracksForArtist(artist);
    }

    return true;
  }

  void removeArtist(String artistId) {
    state = state.copyWith(
      selectedArtists: state.selectedArtists
          .where((a) => a.id != artistId)
          .toList(),
    );

    if (state.smartScheduleEnabled &&
        state.scheduleMode == SmartScheduleMode.byArtistTrack) {
      _removeTracksForArtist(artistId);
    }
  }

  void clearSelectedArtists() {
    state = state.copyWith(selectedArtists: []);
  }

  // ============================================================
  // Smart Schedule Configuration
  // ============================================================

  void setSmartScheduleEnabled(bool enabled) {
    state = state.copyWith(
      smartScheduleEnabled: enabled,
      // Disable traditional scheduling when smart scheduling is enabled
      traditionalScheduleEnabled: enabled
          ? false
          : state.traditionalScheduleEnabled,
      clearStyle: !enabled,
      clearMatchTrack: !enabled,
      clearArtistTracks: !enabled,
    );

    // Save preference
    if (enabled) {
      ref
          .read(schedulePreferencesProvider.notifier)
          .setScheduleType(ScheduleType.smart);
    }

    if (enabled) {
      if (state.scheduleMode == SmartScheduleMode.byPlaylist) {
        loadPlaylists();
      } else if (state.scheduleMode == SmartScheduleMode.byArtistTrack) {
        loadArtistTracks();
      }
    }
  }

  void setTraditionalScheduleEnabled(bool enabled) {
    state = state.copyWith(
      traditionalScheduleEnabled: enabled,
      // Disable smart scheduling when traditional scheduling is enabled
      smartScheduleEnabled: enabled ? false : state.smartScheduleEnabled,
      clearStyle: enabled,
      clearMatchTrack: enabled,
      clearArtistTracks: enabled,
    );

    // Save preference
    if (enabled) {
      ref
          .read(schedulePreferencesProvider.notifier)
          .setScheduleType(ScheduleType.traditional);
    }
  }

  void setScheduleMode(SmartScheduleMode mode) {
    state = state.copyWith(
      scheduleMode: mode,
      clearStyle: mode != SmartScheduleMode.byStyle,
      clearMatchTrack: mode != SmartScheduleMode.byPlaylist,
      clearArtistTracks: mode != SmartScheduleMode.byArtistTrack,
    );

    if (mode == SmartScheduleMode.byPlaylist && state.playlists.isEmpty) {
      loadPlaylists();
    } else if (mode == SmartScheduleMode.byArtistTrack &&
        state.artistTracksWithBpm.isEmpty) {
      loadArtistTracks();
    }
  }

  void setSelectedStyle(MusicStyle? style) {
    state = state.copyWith(selectedStyle: style, clearStyle: style == null);
  }

  void setTrackLimitEnabled(bool enabled) {
    state = state.copyWith(trackLimitEnabled: enabled);
  }

  void setTrackLimitValue(int value) {
    state = state.copyWith(trackLimitValue: value);
  }

  void setDispatchMode(DispatchMode mode) {
    state = state.copyWith(dispatchMode: mode);
    // Save preference
    ref.read(schedulePreferencesProvider.notifier).setDispatchMode(mode);
  }

  // ============================================================
  // Playlist Loading and Selection
  // ============================================================

  Future<void> loadPlaylists() async {
    if (state.isLoadingPlaylists) return;

    state = state.copyWith(isLoadingPlaylists: true);

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final result = await spotifyRepo.getCurrentUserPlaylists();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPlaylists: false,
          errorMessage: failure.message,
        );
      },
      (playlists) {
        state = state.copyWith(isLoadingPlaylists: false, playlists: playlists);
      },
    );
  }

  Future<void> selectPlaylist(Playlist playlist) async {
    state = state.copyWith(
      selectedPlaylist: playlist,
      isLoadingPlaylistTracks: true,
      playlistTracks: [],
    );

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final result = await spotifyRepo.getPlaylistTracks(playlist.id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPlaylistTracks: false,
          errorMessage: failure.message,
        );
      },
      (tracks) {
        state = state.copyWith(
          isLoadingPlaylistTracks: false,
          playlistTracks: tracks,
        );
      },
    );
  }

  void clearSelectedPlaylist() {
    state = state.copyWith(clearSelectedPlaylist: true);
  }

  Future<void> selectMatchTrack(PlaylistTrack track) async {
    state = state.copyWith(selectedMatchTrack: track, matchTrackBpm: null);

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final result = await spotifyRepo.getAudioFeatures(track.id);

    result.fold(
      (failure) {
        state = state.copyWith(matchTrackBpm: 120);
      },
      (features) {
        state = state.copyWith(matchTrackBpm: features.bpm);
      },
    );
  }

  void clearMatchTrack() {
    state = state.copyWith(clearMatchTrack: true);
  }

  // ============================================================
  // Artist Tracks with BPM
  // ============================================================

  Future<void> loadArtistTracks() async {
    if (state.isLoadingArtistTracks || state.selectedArtists.isEmpty) return;

    state = state.copyWith(
      isLoadingArtistTracks: true,
      clearArtistTracks: true,
    );

    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final bpmRepo = await ref.read(bpmRepositoryProvider.future);
    final List<Track> allTracks = [];

    for (final artist in state.selectedArtists) {
      final result = await spotifyRepo.getArtistTopTracks(artist.id);
      result.fold((failure) {}, (tracks) {
        allTracks.addAll(tracks);
      });
    }

    final uniqueTracks = <String, Track>{};
    for (final track in allTracks) {
      uniqueTracks[track.id] = track;
    }

    final hasBpmRepo = bpmRepo != null;
    final tracksWithBpm = uniqueTracks.values
        .map((t) => TrackWithBpm(track: t, bpm: null, isLoadingBpm: hasBpmRepo))
        .toList();

    state = state.copyWith(
      isLoadingArtistTracks: false,
      artistTracksWithBpm: tracksWithBpm,
    );

    if (hasBpmRepo) {
      for (final trackWithBpm in tracksWithBpm) {
        _fetchBpmForTrack(trackWithBpm.track, bpmRepo);
      }
    }
  }

  Future<void> _fetchBpmForTrack(Track track, dynamic bpmRepo) async {
    final artistName = track.artists.isNotEmpty ? track.artists.first.name : '';
    final result = await bpmRepo.getBpmForSong(track.name, artistName);

    result.fold(
      (failure) {
        _updateTrackBpm(track.id, null);
      },
      (int? bpm) {
        _updateTrackBpm(track.id, bpm);
      },
    );
  }

  void _updateTrackBpm(String trackId, int? bpm) {
    state = state.copyWith(
      artistTracksWithBpm: state.artistTracksWithBpm.map((t) {
        if (t.track.id == trackId) {
          return t.copyWith(bpm: bpm, isLoadingBpm: false);
        }
        return t;
      }).toList(),
    );
  }

  Future<void> _loadTracksForArtist(Artist artist) async {
    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final bpmRepo = await ref.read(bpmRepositoryProvider.future);
    final hasBpmRepo = bpmRepo != null;
    final result = await spotifyRepo.getArtistTopTracks(artist.id);

    result.fold((failure) {}, (tracks) {
      final existingIds = state.artistTracksWithBpm
          .map((t) => t.track.id)
          .toSet();
      final newTracks = tracks
          .where((t) => !existingIds.contains(t.id))
          .toList();

      if (newTracks.isNotEmpty) {
        final newTracksWithBpm = newTracks
            .map(
              (t) =>
                  TrackWithBpm(track: t, bpm: null, isLoadingBpm: hasBpmRepo),
            )
            .toList();

        state = state.copyWith(
          artistTracksWithBpm: [
            ...state.artistTracksWithBpm,
            ...newTracksWithBpm,
          ],
        );

        if (hasBpmRepo) {
          for (final trackWithBpm in newTracksWithBpm) {
            _fetchBpmForTrack(trackWithBpm.track, bpmRepo);
          }
        }
      }
    });
  }

  void _removeTracksForArtist(String artistId) {
    final filteredTracks = state.artistTracksWithBpm.where((trackWithBpm) {
      return trackWithBpm.track.artists.isEmpty ||
          trackWithBpm.track.artists.first.id != artistId;
    }).toList();

    final removedTrackIds = state.artistTracksWithBpm
        .where(
          (t) =>
              t.track.artists.isNotEmpty &&
              t.track.artists.first.id == artistId,
        )
        .map((t) => t.track.id)
        .toSet();
    final filteredSelectedIds = state.selectedArtistTrackIds.difference(
      removedTrackIds,
    );

    state = state.copyWith(
      artistTracksWithBpm: filteredTracks,
      selectedArtistTrackIds: filteredSelectedIds,
    );
  }

  void toggleArtistTrack(String trackId) {
    final isSelected = state.selectedArtistTrackIds.contains(trackId);

    if (isSelected) {
      state = state.copyWith(
        selectedArtistTrackIds: Set.from(state.selectedArtistTrackIds)
          ..remove(trackId),
      );
    } else {
      state = state.copyWith(
        selectedArtistTrackIds: Set.from(state.selectedArtistTrackIds)
          ..add(trackId),
      );
    }
  }

  void removeArtistTrack(String trackId) {
    state = state.copyWith(
      selectedArtistTrackIds: Set.from(state.selectedArtistTrackIds)
        ..remove(trackId),
    );
  }

  void clearArtistTracks() {
    state = state.copyWith(clearArtistTracks: true);
  }

  // ============================================================
  // Session Creation
  // ============================================================

  void reset() {
    state = const CreateSessionState();
  }

  Future<FocusSession?> createSession({
    String? name,
    FocusSessionSettings settings = const FocusSessionSettings(),
  }) async {
    if (state.selectedArtists.isEmpty) {
      state = state.copyWith(
        status: CreateSessionStatus.error,
        errorMessage: 'Please select at least one artist',
      );
      return null;
    }

    state = state.copyWith(status: CreateSessionStatus.creating);

    final focusRepoAsync = await ref.read(
      focusSessionRepositoryProvider.future,
    );
    final spotifyRepo = ref.read(spotifyRepositoryProvider);
    final bpmRepo = await ref.read(bpmRepositoryProvider.future);

    final sessionName = (name == null || name.isEmpty)
        ? state.generateDefaultName()
        : name;

    final createUseCase = CreateFocusSession(
      focusRepository: focusRepoAsync,
      spotifyRepository: spotifyRepo,
      bpmRepository: bpmRepo,
    );

    MusicStyle? filterByStyle;
    int? filterByBpm;
    List<int>? selectedTrackBpms;

    if (state.smartScheduleEnabled) {
      if (state.scheduleMode == SmartScheduleMode.byStyle) {
        filterByStyle = state.selectedStyle;
      } else if (state.scheduleMode == SmartScheduleMode.byPlaylist &&
          state.matchTrackBpm != null) {
        filterByBpm = state.matchTrackBpm;
      } else if (state.scheduleMode == SmartScheduleMode.byArtistTrack &&
          state.selectedArtistTrackIds.isNotEmpty) {
        selectedTrackBpms = state.selectedArtistTracks
            .where((t) => t.bpm != null)
            .map((t) => t.bpm!)
            .toList();
      }
    }

    final trackLimit = state.trackLimitEnabled ? state.trackLimitValue : null;

    // Get user's market (country code) for regional content filtering
    final authState = ref.read(authProvider);
    final market = authState.user?.country;

    final result = await createUseCase(
      CreateFocusSessionParams(
        artists: state.selectedArtists,
        name: sessionName,
        settings: settings,
        filterByStyle: filterByStyle,
        filterByBpm: filterByBpm,
        selectedTrackBpms: selectedTrackBpms,
        trackLimit: trackLimit,
        market: market,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CreateSessionStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (session) {
        ref.read(focusSessionProvider.notifier).addSession(session);

        state = state.copyWith(
          status: CreateSessionStatus.success,
          createdSession: session,
          selectedArtists: [],
        );
        return session;
      },
    );
  }
}

final createSessionProvider =
    StateNotifierProvider.autoDispose<
      CreateSessionNotifier,
      CreateSessionState
    >((ref) {
      return CreateSessionNotifier(ref);
    });
