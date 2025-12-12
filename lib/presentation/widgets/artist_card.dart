import 'package:flutter/material.dart';
import '../../domain/entities/artist.dart';
import '../themes/app_theme.dart';
import 'cached_network_image.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final bool isSelected;
  final bool showAddButton;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.onAddPressed,
    this.isSelected = false,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? AppTheme.spotifyGreen.withValues(alpha: 0.2)
          : AppTheme.spotifyDarkGray,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Artist image
              CachedNetworkImage(
                imageUrl: artist.imageUrl,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(40),
                placeholderIcon: Icons.person,
                placeholderIconSize: 32,
              ),
              const SizedBox(width: 12),
              // Artist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist.genres.take(2).join(', '),
                      style: TextStyle(
                        color: AppTheme.spotifyLightGray,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_formatFollowers(artist.followers)} followers',
                      style: TextStyle(
                        color: AppTheme.spotifyLightGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Add button
              if (showAddButton)
                IconButton(
                  onPressed: onAddPressed,
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected
                        ? AppTheme.spotifyGreen
                        : AppTheme.spotifyWhite,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
