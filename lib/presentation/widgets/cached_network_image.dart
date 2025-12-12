import 'package:cached_network_image/cached_network_image.dart' as cached;
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

// Re-export for convenience
export 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;

/// A network image widget with disk caching, error handling and loading states.
/// Uses cached_network_image package for persistent disk caching to reduce
/// network requests and save user bandwidth.
class CachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.music_note,
    this.placeholderIconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageUrl == null || imageUrl!.isEmpty) {
      image = _buildPlaceholder();
    } else {
      image = cached.CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoading(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        // Cache configuration
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        // Memory cache for quick access
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.spotifyDarkGray,
      child: Icon(
        placeholderIcon,
        size: placeholderIconSize,
        color: AppTheme.spotifyLightGray,
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.spotifyDarkGray,
      child: Center(
        child: SizedBox(
          width: placeholderIconSize,
          height: placeholderIconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.spotifyLightGray,
          ),
        ),
      ),
    );
  }
}

/// A cached background image widget that fills its parent.
/// Used for header backgrounds and full-bleed images.
class CachedBackgroundImage extends StatelessWidget {
  final String? imageUrl;
  final Widget fallback;
  final BoxFit fit;

  const CachedBackgroundImage({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return fallback;
    }

    return cached.CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      placeholder: (context, url) => fallback,
      errorWidget: (context, url, error) => fallback,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }
}
