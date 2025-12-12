import 'package:flutter/material.dart';
import '../../domain/entities/focus_session.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_theme.dart';
import 'audio_wave_animation.dart';
import 'cached_network_image.dart';

class FocusSessionCard extends StatefulWidget {
  final FocusSession session;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onPausePressed;
  final VoidCallback? onMenuPressed;

  /// Whether this session is currently being loaded for playback
  final bool isLoading;

  /// Whether this session is currently playing
  final bool isPlaying;

  /// Whether this session is the active session (playing or paused)
  /// Used to show wave animation even when paused
  final bool isActive;

  const FocusSessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onPlayPressed,
    this.onPausePressed,
    this.onMenuPressed,
    this.isLoading = false,
    this.isPlaying = false,
    this.isActive = false,
  });

  @override
  State<FocusSessionCard> createState() => _FocusSessionCardState();
}

class _FocusSessionCardState extends State<FocusSessionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final artists = widget.session.artists;
    final hasOverflow = artists.length > 3;

    final cardContent = Card(
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onMenuPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Artist images stacked
                  _buildArtistImages(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.session.isPinned)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.push_pin,
                                  size: 14,
                                  color: AppTheme.spotifyGreen,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                widget.session.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tracks(widget.session.trackCount),
                          style: const TextStyle(
                            color: AppTheme.spotifyLightGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onMenuPressed != null)
                    IconButton(
                      onPressed: widget.onMenuPressed,
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppTheme.spotifyLightGray,
                        size: 24,
                      ),
                    ),
                  _buildPlayButton(),
                ],
              ),
              const SizedBox(height: 12),
              // Artists chips (Wrap handles natural line breaks)
              _buildArtistChips(context, hasOverflow),
            ],
          ),
        ),
      ),
    );

    // Always wrap with wave background - unified "music fountain" style
    return AnimatedWaveBackground(
      heightRatio: 0.5,
      isLoading: widget.isLoading,
      isActive: widget.isActive,
      isPlaying: widget.isPlaying,
      child: cardContent,
    );
  }

  Widget _buildArtistChips(BuildContext context, bool hasOverflow) {
    final l10n = AppLocalizations.of(context)!;
    final artists = widget.session.artists;
    final hasMoreThanThree = artists.length > 3;

    // No expand/collapse needed for 3 or fewer artists
    if (!hasMoreThanThree) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: artists
            .map(
              (artist) => Chip(
                label: Text(artist.name, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppTheme.spotifyDarkGray,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
            )
            .toList(),
      );
    }

    // Row: Wrap (flexible) + toggle button (fixed on right, top-aligned)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap takes remaining space
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_isExpanded ? artists : artists.take(3))
                .map(
                  (artist) => Chip(
                    label: Text(
                      artist.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppTheme.spotifyDarkGray,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ),
        // Toggle button fixed on right (first row)
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? l10n.collapse : l10n.expand,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.spotifyLightGray,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppTheme.spotifyLightGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    // Use fixed size container to prevent layout shifts between states
    const buttonSize = 48.0;
    const totalSize = 64.0;

    if (widget.isLoading) {
      return SizedBox(
        width: totalSize,
        height: totalSize,
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.spotifyGreen,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: IconButton(
        onPressed: widget.isPlaying
            ? widget.onPausePressed
            : widget.onPlayPressed,
        icon: Icon(
          widget.isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled,
          color: AppTheme.spotifyGreen,
          size: buttonSize,
        ),
      ),
    );
  }

  Widget _buildArtistImages() {
    final artists = widget.session.artists;
    final count = artists.length;

    // For 1-3 artists: single row horizontal stack
    if (count <= 3) {
      const size = 48.0;
      final width = size + (count - 1) * 20.0;

      return SizedBox(
        width: width,
        height: size,
        child: Stack(
          children: [
            for (int i = 0; i < count; i++)
              Positioned(
                left: i * 20.0,
                child: _buildArtistAvatar(artists[i].imageUrl, size),
              ),
          ],
        ),
      );
    }

    // For 4-5 artists: Olympic rings style (2 rows)
    const size = 32.0;
    const overlap = 14.0;
    const verticalOverlap = 8.0;

    final topRowWidth = size + 2 * overlap;
    final bottomCount = count - 3;
    final bottomRowWidth = bottomCount == 1 ? size : size + overlap;
    final totalWidth = topRowWidth > bottomRowWidth
        ? topRowWidth
        : bottomRowWidth;
    const totalHeight = size * 2 - verticalOverlap;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: i * overlap,
              top: 0,
              child: _buildArtistAvatar(artists[i].imageUrl, size),
            ),
          for (int i = 0; i < bottomCount; i++)
            Positioned(
              left: (topRowWidth - bottomRowWidth) / 2 + i * overlap,
              top: size - verticalOverlap,
              child: _buildArtistAvatar(artists[3 + i].imageUrl, size),
            ),
        ],
      ),
    );
  }

  Widget _buildArtistAvatar(String? imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.spotifyDarkGray, width: 2),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
        placeholderIcon: Icons.person,
        placeholderIconSize: size / 2,
      ),
    );
  }
}
