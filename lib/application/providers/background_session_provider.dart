import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/music_style.dart';
import '../../domain/services/track_dispatcher.dart';
import '../../domain/usecases/focus/create_focus_session.dart';
import '../di/injection_container.dart';
import 'auth_provider.dart';
import 'focus_session_provider.dart';

export '../../domain/usecases/focus/create_focus_session.dart'
    show SessionCreationPhase;

/// Status of a background session creation task
enum BackgroundSessionStatus {
  pending,
  fetchingAlbums,
  fetchingTracks,
  fetchingBpm,
  filtering,
  saving,
  completed,
  failed,
}

/// State for a single background session creation task
class BackgroundSessionTask {
  final String id;
  final String name;
  final List<Artist> artists;
  final FocusSessionSettings settings;

  // Smart scheduling parameters
  final List<int>? selectedTrackBpms;
  final MusicStyle? filterByStyle;
  final int? filterByBpm;

  // Traditional scheduling parameters
  final DispatchMode? dispatchMode;

  // Common parameters
  final int? trackLimit;
  final bool trueShuffle;
  final BackgroundSessionStatus status;
  final String? progressMessage;
  final int? currentProgress;
  final int? totalProgress;
  final String? errorMessage;
  final FocusSession? createdSession;

  const BackgroundSessionTask({
    required this.id,
    required this.name,
    required this.artists,
    required this.settings,
    this.selectedTrackBpms,
    this.filterByStyle,
    this.filterByBpm,
    this.dispatchMode,
    this.trackLimit,
    this.trueShuffle = true,
    this.status = BackgroundSessionStatus.pending,
    this.progressMessage,
    this.currentProgress,
    this.totalProgress,
    this.errorMessage,
    this.createdSession,
  });

  BackgroundSessionTask copyWith({
    BackgroundSessionStatus? status,
    String? progressMessage,
    int? currentProgress,
    int? totalProgress,
    String? errorMessage,
    FocusSession? createdSession,
  }) {
    return BackgroundSessionTask(
      id: id,
      name: name,
      artists: artists,
      settings: settings,
      selectedTrackBpms: selectedTrackBpms,
      filterByStyle: filterByStyle,
      filterByBpm: filterByBpm,
      dispatchMode: dispatchMode,
      trackLimit: trackLimit,
      trueShuffle: trueShuffle,
      status: status ?? this.status,
      progressMessage: progressMessage ?? this.progressMessage,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      errorMessage: errorMessage,
      createdSession: createdSession ?? this.createdSession,
    );
  }

  bool get isInProgress =>
      status != BackgroundSessionStatus.completed &&
      status != BackgroundSessionStatus.failed;
}

/// State for all background session creation tasks
class BackgroundSessionState {
  final List<BackgroundSessionTask> tasks;

  const BackgroundSessionState({this.tasks = const []});

  BackgroundSessionState copyWith({List<BackgroundSessionTask>? tasks}) {
    return BackgroundSessionState(tasks: tasks ?? this.tasks);
  }

  /// Get all in-progress tasks
  List<BackgroundSessionTask> get inProgressTasks =>
      tasks.where((t) => t.isInProgress).toList();

  /// Get the most recent in-progress task
  BackgroundSessionTask? get currentTask =>
      inProgressTasks.isNotEmpty ? inProgressTasks.last : null;

  /// Check if there are any in-progress tasks
  bool get hasInProgressTasks => inProgressTasks.isNotEmpty;
}

/// Parameters for creating a background session
class BackgroundSessionParams {
  final String taskId;
  final String name;
  final List<Artist> artists;
  final FocusSessionSettings settings;
  final List<int>? selectedTrackBpms;
  final MusicStyle? filterByStyle;
  final int? filterByBpm;
  final DispatchMode? dispatchMode;
  final int? trackLimit;
  final bool trueShuffle;

  const BackgroundSessionParams({
    required this.taskId,
    required this.name,
    required this.artists,
    required this.settings,
    this.selectedTrackBpms,
    this.filterByStyle,
    this.filterByBpm,
    this.dispatchMode,
    this.trackLimit,
    this.trueShuffle = true,
  });
}

class BackgroundSessionNotifier extends StateNotifier<BackgroundSessionState> {
  final Ref ref;

  BackgroundSessionNotifier(this.ref) : super(const BackgroundSessionState());

  /// Start a background session creation task
  Future<void> createSessionInBackground(BackgroundSessionParams params) async {
    final task = BackgroundSessionTask(
      id: params.taskId,
      name: params.name,
      artists: params.artists,
      settings: params.settings,
      selectedTrackBpms: params.selectedTrackBpms,
      filterByStyle: params.filterByStyle,
      filterByBpm: params.filterByBpm,
      dispatchMode: params.dispatchMode,
      trackLimit: params.trackLimit,
      trueShuffle: params.trueShuffle,
      status: BackgroundSessionStatus.pending,
    );

    state = state.copyWith(tasks: [...state.tasks, task]);
    await _executeTask(params.taskId);
  }

  Future<void> _executeTask(String taskId) async {
    try {
      final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;

      final task = state.tasks[taskIndex];

      // Update status to fetching tracks
      _updateTask(
        taskId,
        (t) => t.copyWith(
          status: BackgroundSessionStatus.fetchingTracks,
          progressMessage:
              'Fetching tracks from ${task.artists.length} artists...',
          currentProgress: 0,
          totalProgress: task.artists.length,
        ),
      );

      // Get dependencies
      final focusRepoAsync = await ref.read(
        focusSessionRepositoryProvider.future,
      );
      final spotifyRepo = ref.read(spotifyRepositoryProvider);
      final bpmRepo = await ref.read(bpmRepositoryProvider.future);

      final createUseCase = CreateFocusSession(
        focusRepository: focusRepoAsync,
        spotifyRepository: spotifyRepo,
        bpmRepository: bpmRepo,
      );

      // Get user's market (country code) for regional content filtering
      final authState = ref.read(authProvider);
      final market = authState.user?.country;

      // Execute the create session use case with progress callback
      final result = await createUseCase(
        CreateFocusSessionParams(
          artists: task.artists,
          name: task.name,
          settings: task.settings,
          selectedTrackBpms: task.selectedTrackBpms,
          filterByStyle: task.filterByStyle,
          filterByBpm: task.filterByBpm,
          dispatchMode: task.dispatchMode,
          trackLimit: task.trackLimit,
          trueShuffle: task.trueShuffle,
          market: market,
          onProgress: (phase, current, total, {String? detail}) {
            _handleProgressUpdate(
              taskId,
              phase,
              current,
              total,
              detail: detail,
            );
          },
        ),
      );

      result.fold(
        (failure) {
          _updateTask(
            taskId,
            (t) => t.copyWith(
              status: BackgroundSessionStatus.failed,
              errorMessage: failure.message,
            ),
          );
        },
        (session) {
          // Update the main sessions list
          ref.read(focusSessionProvider.notifier).addSession(session);

          _updateTask(
            taskId,
            (t) => t.copyWith(
              status: BackgroundSessionStatus.completed,
              createdSession: session,
              progressMessage:
                  'Session created with ${session.tracks.length} tracks',
            ),
          );
        },
      );
    } catch (e) {
      _updateTask(
        taskId,
        (t) => t.copyWith(
          status: BackgroundSessionStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _handleProgressUpdate(
    String taskId,
    SessionCreationPhase phase,
    int current,
    int total, {
    String? detail,
  }) {
    BackgroundSessionStatus status;
    switch (phase) {
      case SessionCreationPhase.fetchingAlbums:
        status = BackgroundSessionStatus.fetchingAlbums;
        break;
      case SessionCreationPhase.fetchingTracks:
        status = BackgroundSessionStatus.fetchingTracks;
        break;
      case SessionCreationPhase.fetchingBpm:
        status = BackgroundSessionStatus.fetchingBpm;
        break;
      case SessionCreationPhase.filtering:
        status = BackgroundSessionStatus.filtering;
        break;
      case SessionCreationPhase.saving:
        status = BackgroundSessionStatus.saving;
        break;
    }

    _updateTask(
      taskId,
      (t) => t.copyWith(
        status: status,
        currentProgress: current,
        totalProgress: total,
        progressMessage: detail,
      ),
    );
  }

  void _updateTask(
    String taskId,
    BackgroundSessionTask Function(BackgroundSessionTask) update,
  ) {
    final updatedTasks = state.tasks.map((t) {
      if (t.id == taskId) {
        return update(t);
      }
      return t;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);
  }

  /// Remove a completed or failed task from the list
  void removeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
    );
  }

  /// Clear all completed/failed tasks
  void clearCompletedTasks() {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.isInProgress).toList(),
    );
  }
}

final backgroundSessionProvider =
    StateNotifierProvider<BackgroundSessionNotifier, BackgroundSessionState>((
      ref,
    ) {
      return BackgroundSessionNotifier(ref);
    });
