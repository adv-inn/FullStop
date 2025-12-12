import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/playback_provider.dart';
import '../../domain/entities/playback_state.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import '../widgets/cached_network_image.dart';
import '../widgets/draggable_app_bar.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final track = playbackState.currentTrack;

    return Scaffold(
      appBar: DraggableAppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)?.nowPlaying ?? 'Now Playing'),
        centerTitle: true,
      ),
      body: track == null
          ? _buildNoTrack()
          : _buildNowPlaying(context, ref, playbackState),
    );
  }

  Widget _buildNoTrack() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 64, color: AppTheme.spotifyLightGray),
          const SizedBox(height: 16),
          Text(
            'No track playing',
            style: TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(
    BuildContext context,
    WidgetRef ref,
    PlaybackState playbackState,
  ) {
    final track = playbackState.currentTrack!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          // Album art
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: track.imageUrl,
              width: 280,
              height: 280,
              borderRadius: BorderRadius.circular(8),
              placeholderIconSize: 64,
            ),
          ),
          const SizedBox(height: 32),
          // Track info
          Text(
            track.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            track.artistNames,
            style: TextStyle(fontSize: 16, color: AppTheme.spotifyLightGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Progress bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: playbackState.progressMs.toDouble(),
                  min: 0,
                  max: playbackState.durationMs.toDouble(),
                  onChanged: (value) {
                    ref.read(playbackProvider.notifier).seekTo(value.toInt());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      playbackState.progressFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.spotifyLightGray,
                      ),
                    ),
                    Text(
                      playbackState.durationFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.spotifyLightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle
              IconButton(
                onPressed: () {
                  ref.read(playbackProvider.notifier).toggleShuffle();
                },
                icon: Icon(
                  Icons.shuffle,
                  color: playbackState.shuffleState
                      ? AppTheme.spotifyGreen
                      : AppTheme.spotifyWhite,
                ),
              ),
              // Previous
              IconButton(
                onPressed: () {
                  ref.read(playbackProvider.notifier).skipPrevious();
                },
                icon: const Icon(Icons.skip_previous, size: 40),
              ),
              // Play/Pause
              IconButton(
                onPressed: () {
                  ref.read(playbackProvider.notifier).togglePlayPause();
                },
                icon: Icon(
                  playbackState.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 72,
                  color: AppTheme.spotifyWhite,
                ),
              ),
              // Next
              IconButton(
                onPressed: () {
                  ref.read(playbackProvider.notifier).skipNext();
                },
                icon: const Icon(Icons.skip_next, size: 40),
              ),
              // Repeat
              IconButton(
                onPressed: () {
                  final nextMode = switch (playbackState.repeatMode) {
                    RepeatMode.off => RepeatMode.context,
                    RepeatMode.context => RepeatMode.track,
                    RepeatMode.track => RepeatMode.off,
                  };
                  ref.read(playbackProvider.notifier).setRepeatMode(nextMode);
                },
                icon: Icon(
                  playbackState.repeatMode == RepeatMode.track
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: playbackState.repeatMode != RepeatMode.off
                      ? AppTheme.spotifyGreen
                      : AppTheme.spotifyWhite,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Device info
          if (playbackState.device != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getDeviceIcon(playbackState.device!.type),
                  size: 16,
                  color: AppTheme.spotifyGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  playbackState.device!.name,
                  style: TextStyle(fontSize: 12, color: AppTheme.spotifyGreen),
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    return switch (type.toLowerCase()) {
      'computer' => Icons.computer,
      'smartphone' => Icons.smartphone,
      'speaker' => Icons.speaker,
      'tv' => Icons.tv,
      _ => Icons.devices,
    };
  }
}
