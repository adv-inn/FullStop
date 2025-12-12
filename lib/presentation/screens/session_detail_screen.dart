import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/focus_session_provider.dart';
import '../../application/providers/navigation_provider.dart';
import '../../application/providers/playback_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/entities/track.dart';
import '../../l10n/app_localizations.dart';
import '../services/session_menu_service.dart';
import '../themes/app_theme.dart';
import '../widgets/cached_network_image.dart';
import '../widgets/track_tile.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final FocusSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  late FocusSession _session;
  bool _isEditing = false;
  List<Track>? _editedTracks;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    // Enable transparent title bar mode on Windows
    if (Platform.isWindows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(navigationProvider.notifier).setTransparentMode(true);
        }
      });
    }
  }

  void _resetTransparentMode() {
    if (Platform.isWindows) {
      ref.read(navigationProvider.notifier).setTransparentMode(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playbackState = ref.watch(playbackProvider);
    final currentTrackId = playbackState.currentTrack?.id;

    // On Windows, use full-bleed design with title bar overlay
    if (Platform.isWindows) {
      return _buildWindowsLayout(context, l10n, currentTrackId);
    }

    return _buildDefaultLayout(context, l10n, currentTrackId);
  }

  Widget _buildDefaultLayout(
    BuildContext context,
    AppLocalizations l10n,
    String? currentTrackId,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l10n),
          _buildSessionInfoSliver(l10n),
          const SliverToBoxAdapter(child: Divider(height: 1)),
          if (_isEditing)
            _buildEditableTrackList(l10n)
          else
            _buildTrackList(currentTrackId),
        ],
      ),
    );
  }

  Widget _buildWindowsLayout(
    BuildContext context,
    AppLocalizations l10n,
    String? currentTrackId,
  ) {
    // Full-bleed layout - the CustomTitleBar becomes transparent and overlays the content
    // Use PopScope to reset transparent mode when user navigates back
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetTransparentMode();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Full-bleed header that extends behind title bar area
            SliverToBoxAdapter(child: _buildFullBleedHeader(l10n)),
            _buildSessionInfoSliver(l10n),
            const SliverToBoxAdapter(child: Divider(height: 1)),
            if (_isEditing)
              _buildEditableTrackList(l10n)
            else
              _buildTrackList(currentTrackId),
          ],
        ),
      ),
    );
  }

  Widget _buildFullBleedHeader(AppLocalizations l10n) {
    // Get image URL
    String? imageUrl;
    if (_session.tracks.isNotEmpty) {
      imageUrl = _session.tracks.first.imageUrl;
    } else if (_session.artists.isNotEmpty) {
      imageUrl = _session.artists.first.imageUrl;
    }

    // Height: 32px title bar + 200px content = 232px total
    const totalHeight = 232.0;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (cached)
          CachedBackgroundImage(
            imageUrl: imageUrl,
            fallback: _buildGradientBackground(),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  AppTheme.spotifyBlack.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          // Title and action buttons
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _session.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.spotifyWhite,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.spotifyWhite,
                        ),
                        onPressed: _startEditing,
                        tooltip: l10n.edit,
                      ),
                    if (_isEditing) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.spotifyWhite,
                        ),
                        onPressed: _cancelEditing,
                        tooltip: l10n.cancel,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: AppTheme.spotifyWhite,
                        ),
                        onPressed: _saveChanges,
                        tooltip: l10n.save,
                      ),
                    ],
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppTheme.spotifyWhite,
                      ),
                      onPressed: _showSessionMenu,
                      tooltip: l10n.more,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _startEditing,
            tooltip: l10n.edit,
          ),
        if (_isEditing) ...[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelEditing,
            tooltip: l10n.cancel,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
            tooltip: l10n.save,
          ),
        ],
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showSessionMenu,
          tooltip: l10n.more,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _session.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildSessionInfoSliver(AppLocalizations l10n) {
    final playbackState = ref.watch(playbackProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artists
            Text(
              _session.artistNames,
              style: TextStyle(color: AppTheme.spotifyLightGray, fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                Text(
                  l10n.tracks(_session.trackCount),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatDuration(_session.totalDuration),
                  style: TextStyle(
                    color: AppTheme.spotifyLightGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Play button and playback controls
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _playSession(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.play),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.spotifyGreen,
                    foregroundColor: AppTheme.spotifyBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Shuffle toggle
                _buildShuffleButton(playbackState, l10n),
                const SizedBox(width: 4),
                // Repeat cycle button
                _buildRepeatButton(playbackState, l10n),
              ],
            ),
          ],
        ),
      ),
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
      ),
      tooltip: playbackState.shuffleState ? l10n.shuffle : l10n.shuffle,
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
      icon: Icon(icon, color: color),
      tooltip: tooltip,
    );
  }

  Widget _buildHeaderBackground() {
    // Use first track's album art or artist image as background
    String? imageUrl;
    if (_session.tracks.isNotEmpty) {
      imageUrl = _session.tracks.first.imageUrl;
    } else if (_session.artists.isNotEmpty) {
      imageUrl = _session.artists.first.imageUrl;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image (cached)
        CachedBackgroundImage(
          imageUrl: imageUrl,
          fallback: _buildGradientBackground(),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.spotifyBlack.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.spotifyGreen, AppTheme.spotifyDarkGray],
        ),
      ),
    );
  }

  Widget _buildTrackList(String? currentTrackId) {
    final tracks = _session.tracks;

    if (tracks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_off, size: 48, color: AppTheme.spotifyLightGray),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noTracksInSession,
                style: TextStyle(color: AppTheme.spotifyLightGray),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final track = tracks[index];
        return TrackTile(
          track: track,
          index: index,
          isPlaying: track.id == currentTrackId,
          onTap: () => _playTrack(index),
        );
      }, childCount: tracks.length),
    );
  }

  Widget _buildEditableTrackList(AppLocalizations l10n) {
    final tracks = _editedTracks ?? _session.tracks;

    if (tracks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            l10n.noTracksInSession,
            style: TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ),
      );
    }

    return SliverReorderableList(
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ReorderableDragStartListener(
          key: ValueKey(track.id),
          index: index,
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.drag_handle,
                    color: AppTheme.spotifyLightGray,
                  ),
                  const SizedBox(width: 8),
                  CachedNetworkImage(
                    imageUrl: track.imageUrl,
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(4),
                    placeholderIconSize: 20,
                  ),
                ],
              ),
              title: Text(
                track.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.artistNames,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.spotifyLightGray),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => _removeTrack(index),
                tooltip: l10n.removeTrack,
              ),
            ),
          ),
        );
      },
      itemCount: tracks.length,
      onReorder: _reorderTracks,
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editedTracks = List.from(_session.tracks);
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editedTracks = null;
    });
  }

  Future<void> _saveChanges() async {
    if (_editedTracks == null) return;

    final updatedSession = FocusSession(
      id: _session.id,
      name: _session.name,
      artists: _session.artists,
      tracks: _editedTracks!,
      settings: _session.settings,
      createdAt: _session.createdAt,
      lastPlayedAt: _session.lastPlayedAt,
    );

    await ref.read(focusSessionProvider.notifier).updateSession(updatedSession);

    if (mounted) {
      setState(() {
        _session = updatedSession;
        _isEditing = false;
        _editedTracks = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sessionUpdated)),
      );
    }
  }

  void _removeTrack(int index) {
    if (_editedTracks == null) return;

    setState(() {
      _editedTracks!.removeAt(index);
    });
  }

  void _reorderTracks(int oldIndex, int newIndex) {
    if (_editedTracks == null) return;

    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final track = _editedTracks!.removeAt(oldIndex);
      _editedTracks!.insert(newIndex, track);
    });
  }

  void _playSession() {
    ref.read(focusSessionProvider.notifier).playSession(_session);
  }

  void _playTrack(int index) {
    // Play the session starting from the clicked track
    ref
        .read(focusSessionProvider.notifier)
        .playSession(_session, startIndex: index);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSession),
        content: Text(l10n.deleteSessionConfirm(_session.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(focusSessionProvider.notifier).deleteSession(_session.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sessionDeleted)));
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  void _showSessionMenu() {
    final l10n = AppLocalizations.of(context)!;
    final menuService = SessionMenuService(
      context: context,
      ref: ref,
      l10n: l10n,
    );
    menuService.showMenu(
      _session,
      onDeleted: () {
        // Pop back to home when session is deleted
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
