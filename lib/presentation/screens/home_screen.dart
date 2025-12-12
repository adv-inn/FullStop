import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/background_session_provider.dart';
import '../../application/providers/focus_session_provider.dart';
import '../../application/providers/playback_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/playback_state.dart';
import '../../l10n/app_localizations.dart';
import '../services/session_menu_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/focus_session_card.dart';
import '../widgets/now_playing_bar.dart';
import 'create_session_screen.dart';
import 'now_playing_screen.dart';
import 'session_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start playback polling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playbackProvider.notifier).startPolling();
      ref.read(focusSessionProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final sessionState = ref.watch(focusSessionProvider);
    final backgroundState = ref.watch(backgroundSessionProvider);

    // Listen for focus session errors (e.g., no device available)
    ref.listen<FocusSessionState>(focusSessionProvider, (previous, next) {
      // Check for general errors
      if (next.status == FocusSessionStatus.error &&
          next.errorMessage != null) {
        final errorMessage = next.errorMessage!;
        final displayMessage = _getLocalizedErrorMessage(errorMessage, l10n);
        showAppSnackBar(context, message: displayMessage, isError: true);
      }
      // Check for playing errors (separate from page loading status)
      if (next.playingStatus == PlayingStatus.error &&
          previous?.playingStatus != PlayingStatus.error &&
          next.errorMessage != null) {
        final errorMessage = next.errorMessage!;
        final displayMessage = _getLocalizedErrorMessage(errorMessage, l10n);
        showAppSnackBar(context, message: displayMessage, isError: true);
      }
    });

    // Listen for background session completion
    ref.listen<BackgroundSessionState>(backgroundSessionProvider, (
      previous,
      next,
    ) {
      // Check for newly completed sessions
      for (final task in next.tasks) {
        BackgroundSessionTask? prevTask;
        try {
          prevTask = previous?.tasks.firstWhere((t) => t.id == task.id);
        } catch (_) {
          prevTask = null;
        }

        // If task just completed successfully
        if (task.status == BackgroundSessionStatus.completed &&
            (prevTask == null ||
                prevTask.status != BackgroundSessionStatus.completed) &&
            task.createdSession != null) {
          final createdSession = task.createdSession!;
          final taskId = task.id;

          // Remove the task immediately to prevent duplicate notifications
          ref.read(backgroundSessionProvider.notifier).removeTask(taskId);

          showAppSnackBar(
            context,
            message: l10n.sessionCreatedBackground(
              createdSession.name,
              createdSession.tracks.length,
            ),
            actionLabel: l10n.play,
            onAction: () {
              ref
                  .read(focusSessionProvider.notifier)
                  .playSession(createdSession);
            },
          );
        }

        // If task failed
        if (task.status == BackgroundSessionStatus.failed &&
            (prevTask == null ||
                prevTask.status != BackgroundSessionStatus.failed)) {
          showAppSnackBar(
            context,
            message: l10n.sessionCreationFailed(
              task.errorMessage ?? 'Unknown error',
            ),
            isError: true,
          );
          ref.read(backgroundSessionProvider.notifier).removeTask(task.id);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.focusSessions),
        actions: [
          // User avatar
          if (authState.user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _showUserMenu(context),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: authState.user!.imageUrl != null
                      ? NetworkImage(authState.user!.imageUrl!)
                      : null,
                  child: authState.user!.imageUrl == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Background session progress indicator
          if (backgroundState.hasInProgressTasks)
            _buildBackgroundSessionProgress(backgroundState, l10n),
          // New Session button at top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSessionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.newSession),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.spotifyGreen,
                  side: const BorderSide(color: AppTheme.spotifyGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent(sessionState)),
          NowPlayingBar(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Calculate progress text and value for a background task
  (String, double?) _getTaskProgress(
    BackgroundSessionTask task,
    AppLocalizations l10n,
  ) {
    switch (task.status) {
      case BackgroundSessionStatus.pending:
        return (l10n.pendingSession, null);

      case BackgroundSessionStatus.fetchingAlbums:
        final name =
            task.progressMessage ?? task.artists.firstOrNull?.name ?? '';
        return (
          name.isNotEmpty
              ? '${l10n.fetchingArtistTracks(name)}...'
              : l10n.fetchingTracksProgress(1),
          null,
        );

      case BackgroundSessionStatus.fetchingTracks:
        final current = task.currentProgress;
        final total = task.totalProgress;
        if (current != null && total != null && total > 0) {
          final isSingle = task.artists.length == 1;
          final name = isSingle
              ? (task.progressMessage ?? task.artists.first.name)
              : (current < task.artists.length
                    ? task.artists[current].name
                    : '');
          final text = name.isNotEmpty
              ? '${l10n.fetchingArtistTracks(name)} (${current + 1}/$total)'
              : '${l10n.fetchingTracksProgress(total).replaceAll('...', '')} ($current/$total)...';
          return (text, current / total);
        }
        return (l10n.fetchingTracksProgress(task.artists.length), null);

      case BackgroundSessionStatus.fetchingBpm:
        final current = task.currentProgress;
        final total = task.totalProgress;
        if (current != null && total != null && total > 0) {
          return (l10n.fetchingBpmProgress(current, total), current / total);
        }
        return (l10n.loadingBpm, null);

      case BackgroundSessionStatus.filtering:
        return (l10n.filteringTracks, null);

      case BackgroundSessionStatus.saving:
        return (l10n.creatingSession, null);

      default:
        return (task.progressMessage ?? l10n.creatingSessionBackground, null);
    }
  }

  Widget _buildBackgroundSessionProgress(
    BackgroundSessionState state,
    AppLocalizations l10n,
  ) {
    final task = state.currentTask;
    if (task == null) return const SizedBox.shrink();

    final (statusText, progressValue) = _getTaskProgress(task, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.spotifyDarkGray,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.spotifyGreen.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.spotifyGreen,
                  value: progressValue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.spotifyWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.spotifyLightGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Show percentage if available
              if (progressValue != null)
                Text(
                  '${(progressValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.spotifyGreen,
                  ),
                ),
              if (progressValue == null)
                Icon(
                  Icons.science,
                  size: 16,
                  color: Colors.amber.withValues(alpha: 0.7),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.spotifyGreen),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FocusSessionState sessionState) {
    final l10n = AppLocalizations.of(context)!;
    final playbackState = ref.watch(playbackProvider);

    // Only show loading for initial load, not for play operations
    if (sessionState.status == FocusSessionStatus.loading &&
        sessionState.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sessionState.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 64,
                color: AppTheme.spotifyLightGray,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noSessionsYet,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createSessionHint,
                style: TextStyle(color: AppTheme.spotifyLightGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(focusSessionProvider.notifier).loadSessions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessionState.sessions.length,
        itemBuilder: (context, index) {
          final session = sessionState.sessions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(session.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) => _confirmDelete(context, session),
              onDismissed: (direction) {
                ref
                    .read(focusSessionProvider.notifier)
                    .deleteSession(session.id);
              },
              child: FocusSessionCard(
                session: session,
                isLoading: false, // No longer needed with optimistic UI
                isPlaying: _isSessionPlaying(
                  session,
                  sessionState,
                  playbackState,
                ),
                isActive: _isSessionActive(
                  session,
                  sessionState,
                  playbackState,
                ),
                onPlayPressed: () {
                  // If this session is already active (paused), resume instead of restart
                  if (_isSessionActive(session, sessionState, playbackState) &&
                      !playbackState.isPlaying) {
                    ref
                        .read(focusSessionProvider.notifier)
                        .resumeSession(session.id);
                  } else {
                    ref
                        .read(focusSessionProvider.notifier)
                        .playSession(session);
                  }
                },
                onPausePressed: () {
                  ref
                      .read(focusSessionProvider.notifier)
                      .pauseSession(session.id);
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionDetailScreen(session: session),
                    ),
                  );
                },
                onMenuPressed: () => _showSessionMenu(context, session),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get localized error message for error codes
  String _getLocalizedErrorMessage(String errorCode, AppLocalizations l10n) {
    switch (errorCode) {
      case 'NO_ACTIVE_DEVICE':
        return l10n.errorNoActiveDevice;
      case 'SPOTIFY_CONNECTION_FAILED':
        return l10n.errorSpotifyConnectionFailed;
      default:
        return errorCode;
    }
  }

  /// Check if a session is currently playing
  /// Uses activeSessionId to avoid race conditions with multiple sessions
  /// OPTIMISTIC UI: Uses optimisticIsPlaying when available for instant feedback
  bool _isSessionPlaying(
    FocusSession session,
    FocusSessionState sessionState,
    PlaybackState playbackState,
  ) {
    // OPTIMISTIC UI: If this is the active session and we have optimistic state, use it
    // This provides instant button feedback before API confirms
    if (sessionState.activeSessionId == session.id &&
        sessionState.optimisticIsPlaying != null) {
      return sessionState.optimisticIsPlaying!;
    }

    // Fallback to actual playback state
    // Must be playing and this session must be the active one
    if (!playbackState.isPlaying) {
      return false;
    }

    return _isSessionActive(session, sessionState, playbackState);
  }

  /// Check if a session is the active session (playing or paused)
  /// Used to show wave animation and determine resume vs restart behavior
  bool _isSessionActive(
    FocusSession session,
    FocusSessionState sessionState,
    PlaybackState playbackState,
  ) {
    // No current track means Spotify has no playback context
    // Don't show wave for any session in this case
    if (playbackState.currentTrack == null) {
      return false;
    }

    // Check if current track is actually in this session
    // This ensures we only show wave when Spotify's queue matches our session
    final currentTrackId = playbackState.currentTrack!.id;
    final isTrackInSession = session.tracks.any(
      (track) => track.id == currentTrackId,
    );

    if (!isTrackInSession) {
      return false;
    }

    // If we have an active session ID and it matches, trust it
    if (sessionState.activeSessionId != null) {
      return sessionState.activeSessionId == session.id;
    }

    // Fallback: Track is in session, consider it active
    return true;
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    FocusSession session,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return showConfirmDialog(
      context,
      title: l10n.deleteSession,
      message: l10n.deleteSessionConfirm(session.name),
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );
  }

  void _showUserMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authProvider).user;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.spotifyDarkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.imageUrl != null
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: user.imageUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (user.email != null)
              Text(
                user.email!,
                style: TextStyle(color: AppTheme.spotifyLightGray),
              ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.isPremium ? l10n.premium : l10n.free),
              backgroundColor: user.isPremium
                  ? AppTheme.spotifyGreen.withOpacity(0.2)
                  : AppTheme.spotifyDarkGray,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionMenu(BuildContext context, FocusSession session) {
    final l10n = AppLocalizations.of(context)!;
    final menuService = SessionMenuService(
      context: context,
      ref: ref,
      l10n: l10n,
    );
    menuService.showMenu(session);
  }
}
