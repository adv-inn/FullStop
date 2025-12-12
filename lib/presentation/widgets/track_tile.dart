import 'package:flutter/material.dart';
import '../../domain/entities/track.dart';
import '../themes/app_theme.dart';
import 'audio_wave_animation.dart';
import 'cached_network_image.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final int? index;
  final VoidCallback? onTap;
  final bool isPlaying;
  final bool showAlbumArt;

  const TrackTile({
    super.key,
    required this.track,
    this.index,
    this.onTap,
    this.isPlaying = false,
    this.showAlbumArt = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _buildLeading(),
      title: Text(
        track.name,
        style: TextStyle(
          color: isPlaying ? AppTheme.spotifyGreen : AppTheme.spotifyWhite,
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (track.explicit)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.spotifyLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: AppTheme.spotifyBlack,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: Text(
              track.artistNames,
              style: const TextStyle(color: AppTheme.spotifyLightGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying) const AudioWaveIndicator(),
          const SizedBox(width: 8),
          Text(
            track.durationFormatted,
            style: const TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (index != null && !showAlbumArt) {
      return SizedBox(
        width: 24,
        child: Text(
          '${index! + 1}',
          style: TextStyle(
            color: isPlaying
                ? AppTheme.spotifyGreen
                : AppTheme.spotifyLightGray,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: track.imageUrl,
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(4),
      placeholderIconSize: 24,
    );
  }
}
