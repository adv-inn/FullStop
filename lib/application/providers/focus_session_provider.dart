import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import 'credentials_provider.dart';
import '../../core/services/device_activation_service.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../../domain/usecases/focus/play_focus_session.dart';
import '../di/injection_container.dart';

enum FocusSessionStatus { initial, loading, success, error }

/// Separate status for playing operations to avoid full page reload
enum PlayingStatus { idle, loading, playing, error }

class FocusSessionState {
  final FocusSessionStatus status;
  final List<FocusSession> sessions;
  final FocusSession? currentSession;
  final String? errorMessage;

  /// Separate status for play operations - doesn't affect page loading
  final PlayingStatus playingStatus;

  /// The session ID currently being loaded for playback (loading indicator)
  final String? loadingSessionId;

  /// The session ID that is currently actively playing (for play/pause state)
  final String? activeSessionId;

  /// Optimistic UI state: expected playing state before API confirms
  /// null = no optimistic state, use actual playback state
  /// true = user clicked play, expecting to be playing
  /// false = user clicked pause, expecting to be paused
  final bool? optimisticIsPlaying;

  const FocusSessionState({
    this.status = FocusSessionStatus.initial,
    this.sessions = const [],
    this.currentSession,
    this.errorMessage,
    this.playingStatus = PlayingStatus.idle,
    this.loadingSessionId,
    this.activeSessionId,
    this.optimisticIsPlaying,
  });

  FocusSessionState copyWith({
    FocusSessionStatus? status,
    List<FocusSession>? sessions,
    FocusSession? currentSession,
    String? errorMessage,
    PlayingStatus? playingStatus,
    String? loadingSessionId,
    String? activeSessionId,
    bool? optimisticIsPlaying,
    bool clearLoadingSessionId = false,
    bool clearActiveSessionId = false,
    bool clearOptimisticState = false,
  }) {
    return FocusSessionState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      errorMessage: errorMessage,
      playingStatus: playingStatus ?? this.playingStatus,
      loadingSessionId: clearLoadingSessionId
          ? null
          : (loadingSessionId ?? this.loadingSessionId),
      activeSessionId: clearActiveSessionId
          ? null
          : (activeSessionId ?? this.activeSessionId),
      optimisticIsPlaying: clearOptimisticState
          ? null
          : (optimisticIsPlaying ?? this.optimisticIsPlaying),
    );
  }
}

class FocusSessionNotifier extends StateNotifier<FocusSessionState> {
  final Ref ref;

  FocusSessionNotifier(this.ref) : super(const FocusSessionState());

  Future<void> loadSessions() async {
    state = state.copyWith(status: FocusSessionStatus.loading);

    final repoAsync = await ref.read(focusSessionRepositoryProvider.future);
    final result = await repoAsync.getAllSessions();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FocusSessionStatus.error,
          errorMessage: failure.message,
        );
      },
      (sessions) async {
        // Load persisted active session ID
        final activeSessionId = await repoAsync.getActiveSessionId();

        state = state.copyWith(
          status: FocusSessionStatus.success,
          sessions: sessions,
          activeSessionId: activeSessionId,
        );
      },
    );
  }

  /// Add a newly created session to the list
  void addSession(FocusSession session) {
    // Add new session and re-sort to ensure correct order
    // New sessions have lowest sortOrder, so they appear at the top
    final updatedSessions = [...state.sessions, session];
    _sortSessions(updatedSessions);
    state = state.copyWith(sessions: updatedSessions, currentSession: session);
  }

  Future<void> playSession(
    FocusSession session, {
    String? deviceId,
    int? startIndex,
  }) async {
    // OPTIMISTIC UI: Immediately show playing state (no loading)
    state = state.copyWith(
      playingStatus: PlayingStatus.idle,
      currentSession: session,
      activeSessionId: session.id,
      optimisticIsPlaying: true,
    );

    try {
      final focusRepoAsync = await ref.read(focusSessionRepositoryProvider.future);
      final playbackRepo = ref.read(playbackRepositoryProvider);

      final playUseCase = PlayFocusSession(
        focusRepository: focusRepoAsync,
        playbackRepository: playbackRepo,
        clientId: ref.read(effectiveSpotifyClientIdProvider),
      );

      final result = await playUseCase(
        PlayFocusSessionParams(
          session: session,
          deviceId: deviceId,
          startIndex: startIndex,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            playingStatus: PlayingStatus.error,
            errorMessage: failure.message,
            clearOptimisticState: true,
          );
        },
        (_) {
          // Fire-and-forget persistence
          Future.wait<void>([
            focusRepoAsync.saveActiveSessionId(session.id),
            focusRepoAsync.saveActiveSessionTrackUris(
              session.tracks.map((t) => t.uri).toList(),
            ),
          ]).catchError((_) => <void>[]);
        },
      );
    } catch (e) {
      state = state.copyWith(
        playingStatus: PlayingStatus.error,
        errorMessage: e.toString(),
        clearOptimisticState: true,
      );
    }
  }

  /// Pause the currently playing session
  Future<void> pauseSession(String sessionId) async {
    // OPTIMISTIC UI: Immediately show paused state
    state = state.copyWith(optimisticIsPlaying: false);

    final playbackRepo = ref.read(playbackRepositoryProvider);
    final result = await playbackRepo.pause();
    _handlePlaybackResult(result);
  }

  /// Resume the paused session
  Future<void> resumeSession(String sessionId) async {
    // OPTIMISTIC UI: Immediately show playing state
    state = state.copyWith(optimisticIsPlaying: true);

    final playbackRepo = ref.read(playbackRepositoryProvider);
    final activationService = DeviceActivationService.instance(
      playbackRepository: playbackRepo,
      clientId: ref.read(effectiveSpotifyClientIdProvider),
    );

    String? deviceId;
    final activationResult = await activationService.ensureActiveDevice();
    activationResult.fold((_) {}, (result) => deviceId = result.deviceId);

    final playResult = await playbackRepo.play(deviceId: deviceId);

    if (playResult.isLeft()) {
      DeviceActivationService.clearCache();
    }
    _handlePlaybackResult(playResult);
  }

  /// Common handler for playback operation results
  void _handlePlaybackResult(Either<Failure, void> result) {
    result.fold(
      (failure) {
        state = state.copyWith(
          playingStatus: PlayingStatus.error,
          errorMessage: failure.message,
          clearOptimisticState: true,
        );
      },
      (_) {
        // Success - optimistic state will be cleared when polling confirms
      },
    );
  }

  /// Clear the active session (when playback stops or switches to non-session content)
  Future<void> clearActiveSession() async {
    state = state.copyWith(clearActiveSessionId: true);

    // Also clear persisted state
    final focusRepoAsync = await ref.read(
      focusSessionRepositoryProvider.future,
    );
    await focusRepoAsync.saveActiveSessionId(null);
  }

  Future<void> deleteSession(String sessionId) async {
    final repoAsync = await ref.read(focusSessionRepositoryProvider.future);
    final result = await repoAsync.deleteSession(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FocusSessionStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          sessions: state.sessions.where((s) => s.id != sessionId).toList(),
        );
      },
    );
  }

  Future<bool> updateSession(FocusSession session) async {
    final repoAsync = await ref.read(focusSessionRepositoryProvider.future);
    final result = await repoAsync.updateSession(session);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FocusSessionStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedSession) {
        state = state.copyWith(
          sessions: state.sessions.map((s) {
            return s.id == session.id ? updatedSession : s;
          }).toList(),
        );
        return true;
      },
    );
  }

  /// Move a session up in the list
  Future<bool> moveSessionUp(String sessionId) => _moveSession(sessionId, -1);

  /// Move a session down in the list
  Future<bool> moveSessionDown(String sessionId) => _moveSession(sessionId, 1);

  /// Move a session by offset (-1 = up, 1 = down)
  Future<bool> _moveSession(String sessionId, int offset) async {
    if (!_canMove(sessionId, offset)) return false;

    final sessions = List<FocusSession>.from(state.sessions);
    final index = sessions.indexWhere((s) => s.id == sessionId);
    final targetIndex = index + offset;

    final currentSession = sessions[index];
    final targetSession = sessions[targetIndex];

    // Swap sortOrders, handle same sortOrder case
    var newCurrentOrder = targetSession.sortOrder;
    var newTargetOrder = currentSession.sortOrder;
    if (newCurrentOrder == newTargetOrder) {
      newCurrentOrder += offset;
    }

    final updatedCurrent = currentSession.copyWithSortOrder(newCurrentOrder);
    final updatedTarget = targetSession.copyWithSortOrder(newTargetOrder);

    final repoAsync = await ref.read(focusSessionRepositoryProvider.future);
    final results = await Future.wait([
      repoAsync.updateSession(updatedCurrent),
      repoAsync.updateSession(updatedTarget),
    ]);

    if (results.every((r) => r.isRight())) {
      sessions[index] = updatedCurrent;
      sessions[targetIndex] = updatedTarget;
      _sortSessions(sessions);
      state = state.copyWith(sessions: sessions);
      return true;
    }
    return false;
  }

  /// Check if a session can be moved up
  bool canMoveUp(String sessionId) => _canMove(sessionId, -1);

  /// Check if a session can be moved down
  bool canMoveDown(String sessionId) => _canMove(sessionId, 1);

  /// Check if a session can be moved by offset
  bool _canMove(String sessionId, int offset) {
    final index = state.sessions.indexWhere((s) => s.id == sessionId);
    if (index < 0) return false;

    final session = state.sessions[index];
    if (session.isPinned) return false;

    final targetIndex = index + offset;
    if (targetIndex < 0 || targetIndex >= state.sessions.length) return false;

    return !state.sessions[targetIndex].isPinned;
  }

  /// Maximum number of pinned sessions allowed
  static const int maxPinnedSessions = 3;

  /// Toggle pin status for a session
  /// If pinning and already at max, the oldest pinned session will be unpinned
  Future<bool> togglePin(String sessionId) async {
    final session = state.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw StateError('Session not found'),
    );

    final repoAsync = await ref.read(focusSessionRepositoryProvider.future);

    // If pinning, check max limit
    if (!session.isPinned) {
      final pinnedCount = await repoAsync.getPinnedCount();
      if (pinnedCount >= maxPinnedSessions) {
        final oldest = _oldestPinnedSession;
        if (oldest != null &&
            !await _updatePinState(oldest, false, repoAsync)) {
          return false;
        }
      }
    }

    return _updatePinState(session, !session.isPinned, repoAsync);
  }

  /// Update pin state for a session
  Future<bool> _updatePinState(
    FocusSession session,
    bool pinned,
    FocusSessionRepository repo,
  ) async {
    final updated = session.copyWithPinned(pinned: pinned);
    final result = await repo.updateSession(updated);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (saved) {
        final updatedSessions = state.sessions
            .map((s) => s.id == session.id ? saved : s)
            .toList();
        _sortSessions(updatedSessions);
        state = state.copyWith(sessions: updatedSessions);
        return true;
      },
    );
  }

  /// Get the oldest pinned session
  FocusSession? get _oldestPinnedSession {
    final pinned = state.sessions.where((s) => s.isPinned).toList();
    if (pinned.isEmpty) return null;
    pinned.sort(
      (a, b) => (a.pinnedAt ?? DateTime.now()).compareTo(
        b.pinnedAt ?? DateTime.now(),
      ),
    );
    return pinned.first;
  }

  /// Sort sessions: pinned first (by pinnedAt, oldest first), then by sortOrder
  void _sortSessions(List<FocusSession> sessions) {
    sessions.sort((a, b) {
      // Both pinned: sort by pinnedAt (oldest first)
      if (a.isPinned && b.isPinned) {
        final aPinnedAt = a.pinnedAt ?? DateTime.now();
        final bPinnedAt = b.pinnedAt ?? DateTime.now();
        return aPinnedAt.compareTo(bPinnedAt);
      }
      // Only a is pinned: a comes first
      if (a.isPinned) return -1;
      // Only b is pinned: b comes first
      if (b.isPinned) return 1;
      // Neither pinned: sort by sortOrder
      return a.sortOrder.compareTo(b.sortOrder);
    });
  }

  /// Check if a session is pinned
  bool isPinned(String sessionId) {
    final session = state.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw StateError('Session not found'),
    );
    return session.isPinned;
  }

  /// Get the count of pinned sessions
  int get pinnedCount => state.sessions.where((s) => s.isPinned).length;

  /// Clear optimistic UI state
  /// Called when we receive real playback state from the API
  void clearOptimisticState() {
    if (state.optimisticIsPlaying != null) {
      state = state.copyWith(clearOptimisticState: true);
    }
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSessionState>((ref) {
      return FocusSessionNotifier(ref);
    });

// Provider for tracks of a specific artist
final artistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  artistId,
) async {
  final spotifyRepo = ref.watch(spotifyRepositoryProvider);
  final result = await spotifyRepo.getArtistTopTracks(artistId);
  return result.fold((failure) => [], (tracks) => tracks);
});
