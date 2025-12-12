import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/focus_session_provider.dart';
import '../../application/providers/playback_provider.dart';
import '../../domain/entities/playback_state.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import 'cached_network_image.dart';

class NowPlayingBar extends ConsumerStatefulWidget {
  final VoidCallback? onTap;

  const NowPlayingBar({super.key, this.onTap});

  @override
  ConsumerState<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends ConsumerState<NowPlayingBar> {
  bool _isLiked = false;
  bool _isLikeLoading = false;
  String? _lastTrackId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playbackState = ref.watch(playbackProvider);

    // Use AnimatedSize to smoothly animate height changes
    // This prevents the jarring 1px jump when playback starts/stops
    final hasContent = playbackState.currentTrack != null;

    if (!hasContent) {
      // Return empty container with zero height but smooth transition
      return const SizedBox.shrink();
    }

    // Check if track changed and fetch like status
    if (playbackState.currentTrack!.id != _lastTrackId) {
      _lastTrackId = playbackState.currentTrack!.id;
      _fetchLikeStatus();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.spotifyDarkGray,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Album art
                  CachedNetworkImage(
                    imageUrl: playbackState.currentTrack!.imageUrl,
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(4),
                    placeholderIconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  // Track info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playbackState.currentTrack!.name,
                          style: const TextStyle(
                            color: AppTheme.spotifyWhite,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          playbackState.currentTrack!.artistNames,
                          style: const TextStyle(
                            color: AppTheme.spotifyLightGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Like button
                  _buildLikeButton(),
                  // Playback controls
                  _buildPlaybackControls(playbackState),
                ],
              ),
            ),
            // Control bar with shuffle, repeat, progress
            _buildControlBar(playbackState, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    if (_isLikeLoading) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.spotifyGreen,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _toggleLike,
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? AppTheme.spotifyGreen : AppTheme.spotifyLightGray,
        size: 22,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _buildPlaybackControls(PlaybackState playbackState) {
    // Use optimistic state for instant UI feedback
    final sessionState = ref.watch(focusSessionProvider);
    final isPlaying =
        sessionState.optimisticIsPlaying ?? playbackState.isPlaying;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        IconButton(
          onPressed: () {
            ref.read(playbackProvider.notifier).skipPrevious();
          },
          icon: const Icon(
            Icons.skip_previous,
            color: AppTheme.spotifyWhite,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        // Play/Pause button
        IconButton(
          onPressed: () {
            ref.read(playbackProvider.notifier).togglePlayPause();
          },
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: AppTheme.spotifyWhite,
            size: 40,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        // Next button
        IconButton(
          onPressed: () {
            ref.read(playbackProvider.notifier).skipNext();
          },
          icon: const Icon(
            Icons.skip_next,
            color: AppTheme.spotifyWhite,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  Widget _buildControlBar(PlaybackState playbackState, AppLocalizations l10n) {
    return Column(
      children: [
        // Shuffle and Repeat controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shuffle button
              _buildShuffleButton(playbackState, l10n),
              // Progress time
              Text(
                '${_formatDuration(playbackState.progressMs)} / ${_formatDuration(playbackState.durationMs)}',
                style: const TextStyle(
                  color: AppTheme.spotifyLightGray,
                  fontSize: 11,
                ),
              ),
              // Repeat button
              _buildRepeatButton(playbackState, l10n),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Progress bar
        LinearProgressIndicator(
          value: playbackState.progressPercent,
          backgroundColor: AppTheme.spotifyLightGray.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppTheme.spotifyGreen,
          ),
          minHeight: 2,
        ),
      ],
    );
  }

  Widget _buildShuffleButton(
    PlaybackState playbackState,
    AppLocalizations l10n,
  ) {
    return IconButton(
      onPressed: () {
        ref.read(playbackProvider.notifier).toggleShuffle();
      },
      icon: Icon(
        Icons.shuffle,
        color: playbackState.shuffleState
            ? AppTheme.spotifyGreen
            : AppTheme.spotifyLightGray,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: playbackState.shuffleState ? l10n.shuffleOn : l10n.shuffleOff,
    );
  }

  Widget _buildRepeatButton(
    PlaybackState playbackState,
    AppLocalizations l10n,
  ) {
    final IconData icon;
    final Color color;
    final String tooltip;

    switch (playbackState.repeatMode) {
      case RepeatMode.off:
        icon = Icons.repeat;
        color = AppTheme.spotifyLightGray;
        tooltip = l10n.repeatOff;
        break;
      case RepeatMode.context:
        icon = Icons.repeat;
        color = AppTheme.spotifyGreen;
        tooltip = l10n.repeatAll;
        break;
      case RepeatMode.track:
        icon = Icons.repeat_one;
        color = AppTheme.spotifyGreen;
        tooltip = l10n.repeatOne;
        break;
    }

    return IconButton(
      onPressed: () {
        ref.read(playbackProvider.notifier).cycleRepeatMode();
      },
      icon: Icon(icon, color: color, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: tooltip,
    );
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchLikeStatus() async {
    if (!mounted) return;

    setState(() => _isLikeLoading = true);

    final isSaved = await ref
        .read(playbackProvider.notifier)
        .isCurrentTrackSaved();

    if (mounted) {
      setState(() {
        _isLiked = isSaved;
        _isLikeLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _isLikeLoading = true);

    final result = await ref
        .read(playbackProvider.notifier)
        .toggleCurrentTrackLike(_isLiked);

    if (mounted) {
      setState(() {
        _isLiked = result.isLiked;
        _isLikeLoading = false;
      });

      // Show error message if operation failed
      if (!result.success && result.errorMessage != null) {
        final l10n = AppLocalizations.of(context)!;
        String message = result.errorMessage!;

        // Provide more helpful message for auth errors
        if (result.needsReauth) {
          message = l10n.errorNeedsReauth;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
