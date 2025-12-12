import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../domain/entities/playlist.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/app_theme.dart';
import '../cached_network_image.dart';
import '../horizontal_scroll_view.dart';

class PlaylistMatchSection extends ConsumerWidget {
  const PlaylistMatchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    // If track is already selected, show it
    if (createState.selectedMatchTrack != null) {
      return _SelectedTrackCard(sessionState: createState, l10n: l10n);
    }

    // If playlist is selected, show tracks
    if (createState.selectedPlaylist != null) {
      return _PlaylistTracksSection(sessionState: createState, l10n: l10n);
    }

    // Otherwise, show playlist picker
    return _PlaylistPickerSection(sessionState: createState, l10n: l10n);
  }
}

class _SelectedTrackCard extends ConsumerWidget {
  final CreateSessionState sessionState;
  final AppLocalizations l10n;

  const _SelectedTrackCard({required this.sessionState, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = sessionState.selectedMatchTrack!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.spotifyGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: track.albumImageUrl,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(4),
            placeholderIconSize: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artistsString,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.spotifyLightGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sessionState.matchTrackBpm != null)
                  Text(
                    l10n.matchingBpm(sessionState.matchTrackBpm!),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.spotifyGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () =>
                ref.read(createSessionProvider.notifier).clearMatchTrack(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _PlaylistPickerSection extends ConsumerWidget {
  final CreateSessionState sessionState;
  final AppLocalizations l10n;

  const _PlaylistPickerSection({
    required this.sessionState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sessionState.isLoadingPlaylists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loadingPlaylists,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.spotifyLightGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sessionState.playlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.noPlaylists,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.spotifyLightGray,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(createSessionProvider.notifier).loadPlaylists(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectPlaylist,
          style: TextStyle(fontSize: 12, color: AppTheme.spotifyLightGray),
        ),
        const SizedBox(height: 8),
        HorizontalListView(
          height: 80,
          itemCount: sessionState.playlists.length,
          itemBuilder: (context, index) {
            final playlist = sessionState.playlists[index];
            return _PlaylistCard(playlist: playlist);
          },
        ),
      ],
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(createSessionProvider.notifier).selectPlaylist(playlist),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.spotifyBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.spotifyLightGray.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: playlist.imageUrl,
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(4),
              placeholderIcon: Icons.queue_music,
              placeholderIconSize: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${playlist.trackCount} tracks',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.spotifyLightGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTracksSection extends ConsumerWidget {
  final CreateSessionState sessionState;
  final AppLocalizations l10n;

  const _PlaylistTracksSection({
    required this.sessionState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () => ref
                  .read(createSessionProvider.notifier)
                  .clearSelectedPlaylist(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sessionState.selectedPlaylist!.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.selectTrackForMatch,
          style: TextStyle(fontSize: 11, color: AppTheme.spotifyLightGray),
        ),
        const SizedBox(height: 8),
        if (sessionState.isLoadingPlaylistTracks)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          HorizontalListView(
            height: 120,
            itemCount: sessionState.playlistTracks.length,
            itemBuilder: (context, index) {
              final track = sessionState.playlistTracks[index];
              return _TrackCard(track: track);
            },
          ),
      ],
    );
  }
}

class _TrackCard extends ConsumerWidget {
  final PlaylistTrack track;

  const _TrackCard({required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(createSessionProvider.notifier).selectMatchTrack(track),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: track.albumImageUrl,
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(4),
              placeholderIconSize: 32,
            ),
            const SizedBox(height: 4),
            Text(
              track.name,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              track.artistsString,
              style: TextStyle(fontSize: 9, color: AppTheme.spotifyLightGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
