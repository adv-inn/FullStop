import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/di/injection_container.dart';
import '../../application/providers/auth_provider.dart';
import '../../application/providers/focus_session_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import '../widgets/app_dialogs.dart';

/// Service for handling session menu operations.
/// This service encapsulates the menu display and all menu action logic
/// to be reusable across different screens (home, session detail, etc.)
class SessionMenuService {
  final BuildContext context;
  final WidgetRef ref;
  final AppLocalizations l10n;

  SessionMenuService({
    required this.context,
    required this.ref,
    required this.l10n,
  });

  /// Show the session menu bottom sheet
  void showMenu(FocusSession session, {VoidCallback? onDeleted}) {
    final sessionNotifier = ref.read(focusSessionProvider.notifier);
    final canMoveUp = sessionNotifier.canMoveUp(session.id);
    final canMoveDown = sessionNotifier.canMoveDown(session.id);
    final isPinned = session.isPinned;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.spotifyDarkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Session name header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPinned)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.push_pin,
                            size: 16,
                            color: AppTheme.spotifyGreen,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.spotifyWhite,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Pin/Unpin
                ListTile(
                  leading: Icon(
                    isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                    color: isPinned
                        ? AppTheme.spotifyLightGray
                        : AppTheme.spotifyGreen,
                  ),
                  title: Text(isPinned ? l10n.unpinSession : l10n.pinSession),
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(ctx);
                    _togglePin(session);
                  },
                ),
                // Only show move options for non-pinned sessions
                if (!isPinned) ...[
                  const Divider(height: 1),
                  // Move Up
                  ListTile(
                    leading: Icon(
                      Icons.arrow_upward,
                      color: canMoveUp
                          ? AppTheme.spotifyWhite
                          : AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                    ),
                    title: Text(
                      l10n.moveUp,
                      style: TextStyle(
                        color: canMoveUp
                            ? null
                            : AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    enabled: canMoveUp,
                    onTap: canMoveUp
                        ? () {
                            Navigator.pop(ctx);
                            _moveSessionUp(session);
                          }
                        : null,
                  ),
                  // Move Down
                  ListTile(
                    leading: Icon(
                      Icons.arrow_downward,
                      color: canMoveDown
                          ? AppTheme.spotifyWhite
                          : AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                    ),
                    title: Text(
                      l10n.moveDown,
                      style: TextStyle(
                        color: canMoveDown
                            ? null
                            : AppTheme.spotifyLightGray.withValues(alpha: 0.5),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    enabled: canMoveDown,
                    onTap: canMoveDown
                        ? () {
                            Navigator.pop(ctx);
                            _moveSessionDown(session);
                          }
                        : null,
                  ),
                ],
                const Divider(height: 1),
                // Rename
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.spotifyWhite),
                  title: Text(l10n.rename),
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRenameDialog(session);
                  },
                ),
                // Like all tracks
                ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: AppTheme.spotifyWhite,
                  ),
                  title: Text(l10n.likeAllTracks),
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(ctx);
                    _likeAllTracks(session);
                  },
                ),
                // Create playlist
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add,
                    color: AppTheme.spotifyWhite,
                  ),
                  title: Text(l10n.createPlaylistFromSession),
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(ctx);
                    _createPlaylistFromSession(session);
                  },
                ),
                const Divider(height: 1),
                // Delete (destructive)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(session, onDeleted: onDeleted);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _togglePin(FocusSession session) async {
    final success = await ref
        .read(focusSessionProvider.notifier)
        .togglePin(session.id);
    if (success && context.mounted) {
      showAppSnackBar(
        context,
        message: session.isPinned ? l10n.sessionUnpinned : l10n.sessionPinned,
      );
    }
  }

  Future<void> _moveSessionUp(FocusSession session) async {
    await ref.read(focusSessionProvider.notifier).moveSessionUp(session.id);
  }

  Future<void> _moveSessionDown(FocusSession session) async {
    await ref.read(focusSessionProvider.notifier).moveSessionDown(session.id);
  }

  Future<void> _showRenameDialog(FocusSession session) async {
    final controller = TextEditingController(text: session.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        title: Text(l10n.renameSession),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.sessionNameHint),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (newName != null &&
        newName.trim().isNotEmpty &&
        newName != session.name) {
      final updatedSession = FocusSession(
        id: session.id,
        name: newName.trim(),
        artists: session.artists,
        tracks: session.tracks,
        settings: session.settings,
        createdAt: session.createdAt,
        lastPlayedAt: session.lastPlayedAt,
        sortOrder: session.sortOrder,
        isPinned: session.isPinned,
        pinnedAt: session.pinnedAt,
      );
      final success = await ref
          .read(focusSessionProvider.notifier)
          .updateSession(updatedSession);
      if (success && context.mounted) {
        showAppSnackBar(context, message: l10n.sessionRenamed);
      }
    }
  }

  Future<void> _likeAllTracks(FocusSession session) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppTheme.spotifyGreen),
            const SizedBox(width: 16),
            Text(l10n.checkingLikedStatus),
          ],
        ),
      ),
    );

    try {
      final playbackRepo = ref.read(playbackRepositoryProvider);
      final trackIds = session.tracks.map((t) => t.id).toList();

      // Check which tracks are already liked
      final result = await playbackRepo.areTracksSaved(trackIds);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      await result.fold(
        (failure) async {
          showAppSnackBar(context, message: failure.message, isError: true);
        },
        (savedStatuses) async {
          // Find tracks that aren't liked yet
          final tracksToLike = <String>[];
          for (int i = 0; i < trackIds.length; i++) {
            if (!savedStatuses[i]) {
              tracksToLike.add(trackIds[i]);
            }
          }

          if (tracksToLike.isEmpty) {
            showAppSnackBar(context, message: l10n.tracksAlreadyLiked);
            return;
          }

          // Confirm with user
          final confirmed = await showConfirmDialog(
            context,
            title: l10n.likeAllTracks,
            message: l10n.likeAllTracksConfirm(tracksToLike.length),
            confirmText: l10n.likeAllTracks,
            cancelText: l10n.cancel,
          );

          if (confirmed != true || !context.mounted) return;

          // Show liking progress
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.spotifyDarkGray,
              content: Row(
                children: [
                  const CircularProgressIndicator(color: AppTheme.spotifyGreen),
                  const SizedBox(width: 16),
                  Text(l10n.likingTracks),
                ],
              ),
            ),
          );

          final saveResult = await playbackRepo.saveTracks(tracksToLike);

          if (!context.mounted) return;
          Navigator.pop(context); // Close liking dialog

          saveResult.fold(
            (failure) {
              showAppSnackBar(context, message: failure.message, isError: true);
            },
            (_) {
              showAppSnackBar(
                context,
                message: l10n.tracksLiked(tracksToLike.length),
              );
            },
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        showAppSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  Future<void> _createPlaylistFromSession(FocusSession session) async {
    final user = ref.read(authProvider).user;

    if (user == null) {
      showAppSnackBar(context, message: 'User not found', isError: true);
      return;
    }

    // Confirm with user
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.createPlaylistFromSession,
      message: l10n.createPlaylistConfirm(session.name, session.tracks.length),
      confirmText: l10n.create,
      cancelText: l10n.cancel,
    );

    if (confirmed != true || !context.mounted) return;

    // Show creating progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppTheme.spotifyGreen),
            const SizedBox(width: 16),
            Text(l10n.creatingPlaylist),
          ],
        ),
      ),
    );

    try {
      final playbackRepo = ref.read(playbackRepositoryProvider);
      final trackUris = session.tracks.map((t) => t.uri).toList();

      final result = await playbackRepo.createPlaylistWithTracks(
        userId: user.id,
        name: session.name,
        trackUris: trackUris,
        description: 'Created from FullStop focus session',
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close creating dialog

      result.fold(
        (failure) {
          showAppSnackBar(
            context,
            message: l10n.playlistCreationFailed,
            isError: true,
          );
        },
        (_) {
          showAppSnackBar(context, message: l10n.playlistCreated(session.name));
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showAppSnackBar(
          context,
          message: l10n.playlistCreationFailed,
          isError: true,
        );
      }
    }
  }

  Future<void> _confirmDelete(
    FocusSession session, {
    VoidCallback? onDeleted,
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteSession,
      message: l10n.deleteSessionConfirm(session.name),
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(focusSessionProvider.notifier).deleteSession(session.id);
      if (context.mounted) {
        showAppSnackBar(context, message: l10n.sessionDeleted);
        onDeleted?.call();
      }
    }
  }
}
