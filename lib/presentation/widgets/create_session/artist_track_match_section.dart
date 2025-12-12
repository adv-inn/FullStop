import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/di/injection_container.dart';
import '../../../application/providers/create_session_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/settings_screen.dart';
import '../../themes/app_theme.dart';
import '../cached_network_image.dart';

class ArtistTrackMatchSection extends ConsumerWidget {
  const ArtistTrackMatchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final createState = ref.watch(createSessionProvider);

    // Check if there are selected artists
    if (createState.selectedArtists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.selectArtistFirst,
            style: TextStyle(fontSize: 12, color: AppTheme.spotifyLightGray),
          ),
        ),
      );
    }

    // Loading state
    if (createState.isLoadingArtistTracks) {
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
                l10n.loadingArtistTracks,
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

    // No tracks found
    if (createState.artistTracksWithBpm.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.noArtistTracks,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.spotifyLightGray,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(createSessionProvider.notifier).loadArtistTracks(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Check if BPM API is configured
    final bpmApiKeyAsync = ref.watch(getSongBpmApiKeyProvider);
    final hasBpmApi = bpmApiKeyAsync.when(
      data: (key) => key != null && key.isNotEmpty,
      loading: () => true,
      error: (_, __) => false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show API not configured warning if needed
        if (!hasBpmApi) ...[
          _BpmApiNotConfiguredWarning(l10n: l10n),
          const SizedBox(height: 8),
        ],
        // Selected tracks summary
        if (createState.selectedArtistTrackIds.isNotEmpty) ...[
          _SelectedTracksSummary(sessionState: createState, l10n: l10n),
          const SizedBox(height: 8),
        ],
        // Track list header
        Row(
          children: [
            Text(
              l10n.selectTracksFromArtist,
              style: TextStyle(fontSize: 11, color: AppTheme.spotifyLightGray),
            ),
            const Spacer(),
            Text(
              '${createState.selectedArtistTrackIds.length}/${createState.artistTracksWithBpm.length}',
              style: TextStyle(fontSize: 10, color: AppTheme.spotifyLightGray),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Track list
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: createState.artistTracksWithBpm.length,
            itemBuilder: (context, index) {
              final trackWithBpm = createState.artistTracksWithBpm[index];
              final isSelected = createState.isArtistTrackSelected(
                trackWithBpm.track.id,
              );
              return _ArtistTrackListItem(
                trackWithBpm: trackWithBpm,
                isSelected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BpmApiNotConfiguredWarning extends StatelessWidget {
  final AppLocalizations l10n;

  const _BpmApiNotConfiguredWarning({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.getSongBpmHint,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}

class _SelectedTracksSummary extends ConsumerWidget {
  final CreateSessionState sessionState;
  final AppLocalizations l10n;

  const _SelectedTracksSummary({
    required this.sessionState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpmRanges = sessionState.selectedBpmRanges;
    final hasBpmData = bpmRanges.isNotEmpty;
    final isLoading = sessionState.selectedArtistTracks.any(
      (t) => t.isLoadingBpm,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.spotifyGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.spotifyGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppTheme.spotifyGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectedTracksCount(
                    sessionState.selectedArtistTracks.length,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isLoading)
                  Text(
                    l10n.loadingBpm,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.spotifyLightGray,
                    ),
                  )
                else if (hasBpmData)
                  Text(
                    l10n.bpmRangesHint(
                      bpmRanges.map((r) => '${r.$1}-${r.$2}').join(', '),
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.spotifyLightGray,
                    ),
                  )
                else
                  Text(
                    l10n.bpmUnavailable,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.spotifyLightGray,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, size: 18),
            onPressed: () =>
                ref.read(createSessionProvider.notifier).clearArtistTracks(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: l10n.clearAll,
          ),
        ],
      ),
    );
  }
}

class _ArtistTrackListItem extends ConsumerWidget {
  final TrackWithBpm trackWithBpm;
  final bool isSelected;

  const _ArtistTrackListItem({
    required this.trackWithBpm,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = trackWithBpm.track;
    return InkWell(
      onTap: () =>
          ref.read(createSessionProvider.notifier).toggleArtistTrack(track.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.spotifyGreen.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.spotifyLightGray.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => ref
                    .read(createSessionProvider.notifier)
                    .toggleArtistTrack(track.id),
                activeColor: AppTheme.spotifyGreen,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            // Album art
            CachedNetworkImage(
              imageUrl: track.imageUrl,
              width: 32,
              height: 32,
              borderRadius: BorderRadius.circular(2),
              placeholderIconSize: 16,
            ),
            const SizedBox(width: 8),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.spotifyGreen
                          : AppTheme.spotifyWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.artists.map((a) => a.name).join(', '),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.spotifyLightGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // BPM badge
            const SizedBox(width: 8),
            if (trackWithBpm.isLoadingBpm)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            else if (trackWithBpm.bpm != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
                      : AppTheme.spotifyLightGray.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${trackWithBpm.bpm}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? AppTheme.spotifyGreen
                        : AppTheme.spotifyLightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // Duration
            const SizedBox(width: 8),
            Text(
              track.durationFormatted,
              style: TextStyle(fontSize: 10, color: AppTheme.spotifyLightGray),
            ),
          ],
        ),
      ),
    );
  }
}
