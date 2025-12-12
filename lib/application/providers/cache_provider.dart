import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// State for cache management
class CacheState {
  final int imageCacheSize;
  final bool isCalculating;
  final bool isClearing;

  const CacheState({
    this.imageCacheSize = 0,
    this.isCalculating = false,
    this.isClearing = false,
  });

  CacheState copyWith({
    int? imageCacheSize,
    bool? isCalculating,
    bool? isClearing,
  }) {
    return CacheState(
      imageCacheSize: imageCacheSize ?? this.imageCacheSize,
      isCalculating: isCalculating ?? this.isCalculating,
      isClearing: isClearing ?? this.isClearing,
    );
  }

  /// Format cache size for display
  String get formattedSize {
    if (imageCacheSize < 1024) {
      return '$imageCacheSize B';
    } else if (imageCacheSize < 1024 * 1024) {
      return '${(imageCacheSize / 1024).toStringAsFixed(1)} KB';
    } else if (imageCacheSize < 1024 * 1024 * 1024) {
      return '${(imageCacheSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(imageCacheSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}

/// Notifier for cache management
class CacheNotifier extends StateNotifier<CacheState> {
  CacheNotifier() : super(const CacheState()) {
    calculateCacheSize();
  }

  /// Calculate the total cache size (image cache only)
  Future<void> calculateCacheSize() async {
    if (state.isCalculating) return;

    state = state.copyWith(isCalculating: true);

    try {
      int totalSize = 0;

      // Get image cache directory size
      final cacheDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${cacheDir.path}/libCachedImageData');

      if (await imageCacheDir.exists()) {
        totalSize += await _calculateDirectorySize(imageCacheDir);
      }

      state = state.copyWith(imageCacheSize: totalSize, isCalculating: false);
    } catch (e) {
      state = state.copyWith(isCalculating: false);
    }
  }

  /// Clear image cache only (preserves user config and session data)
  Future<bool> clearImageCache() async {
    if (state.isClearing) return false;

    state = state.copyWith(isClearing: true);

    try {
      // Clear the default cache manager (used by cached_network_image)
      await DefaultCacheManager().emptyCache();

      // Also try to clear the cache directory manually
      final cacheDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${cacheDir.path}/libCachedImageData');

      if (await imageCacheDir.exists()) {
        await imageCacheDir.delete(recursive: true);
      }

      state = state.copyWith(imageCacheSize: 0, isClearing: false);

      return true;
    } catch (e) {
      state = state.copyWith(isClearing: false);
      return false;
    }
  }

  /// Calculate size of a directory recursively
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;

    try {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      // Ignore errors (permission issues, etc.)
    }

    return totalSize;
  }
}

/// Provider for cache management
final cacheProvider = StateNotifierProvider<CacheNotifier, CacheState>((ref) {
  return CacheNotifier();
});
