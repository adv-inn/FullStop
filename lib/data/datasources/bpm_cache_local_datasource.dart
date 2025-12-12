import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/logger.dart';

/// Cached BPM entry
class BpmCacheEntry {
  final int bpm;
  final DateTime cachedAt;

  BpmCacheEntry({required this.bpm, required this.cachedAt});

  Map<String, dynamic> toJson() => {
    'bpm': bpm,
    'cachedAt': cachedAt.toIso8601String(),
  };

  factory BpmCacheEntry.fromJson(Map<String, dynamic> json) => BpmCacheEntry(
    bpm: json['bpm'] as int,
    cachedAt: DateTime.parse(json['cachedAt'] as String),
  );

  /// Check if the cache entry is still valid (default 30 days)
  bool isValid({Duration maxAge = const Duration(days: 30)}) {
    return DateTime.now().difference(cachedAt) < maxAge;
  }
}

/// Data source for caching BPM data locally using Hive
/// Cache is stored in the app's data directory
abstract class BpmCacheLocalDataSource {
  /// Get cached BPM for a song
  /// Returns null if not cached or cache is expired
  Future<int?> getCachedBpm(String title, String artistName);

  /// Cache BPM for a song
  Future<void> cacheBpm(String title, String artistName, int bpm);

  /// Get multiple cached BPMs
  /// Returns a map of "title|artistName" -> bpm for found entries
  Future<Map<String, int>> getCachedBpms(
    List<({String title, String artistName})> songs,
  );

  /// Cache multiple BPMs at once
  Future<void> cacheBpms(Map<String, int> bpmMap);

  /// Clear all cached BPM data
  Future<void> clearCache();

  /// Get cache statistics
  Future<({int totalEntries, int validEntries, int expiredEntries})>
  getCacheStats();
}

class BpmCacheLocalDataSourceImpl implements BpmCacheLocalDataSource {
  static const String _boxName = 'bpm_cache';
  Box<Map>? _box;

  /// Generate a cache key from title and artist name
  String _generateKey(String title, String artistName) {
    // Normalize the key to handle case differences and extra whitespace
    final normalizedTitle = title.toLowerCase().trim();
    final normalizedArtist = artistName.toLowerCase().trim();
    return '$normalizedTitle|$normalizedArtist';
  }

  /// Ensure the Hive box is open
  Future<Box<Map>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Map>(_boxName);
    return _box!;
  }

  @override
  Future<int?> getCachedBpm(String title, String artistName) async {
    try {
      final box = await _getBox();
      final key = _generateKey(title, artistName);
      final data = box.get(key);

      if (data == null) return null;

      final entry = BpmCacheEntry.fromJson(Map<String, dynamic>.from(data));
      if (!entry.isValid()) {
        // Cache expired, remove it
        await box.delete(key);
        return null;
      }

      return entry.bpm;
    } catch (e) {
      AppLogger.error('Error getting cached BPM', e);
      return null;
    }
  }

  @override
  Future<void> cacheBpm(String title, String artistName, int bpm) async {
    try {
      final box = await _getBox();
      final key = _generateKey(title, artistName);
      final entry = BpmCacheEntry(bpm: bpm, cachedAt: DateTime.now());
      await box.put(key, entry.toJson());
    } catch (e) {
      AppLogger.error('Error caching BPM', e);
    }
  }

  @override
  Future<Map<String, int>> getCachedBpms(
    List<({String title, String artistName})> songs,
  ) async {
    final results = <String, int>{};

    try {
      final box = await _getBox();

      for (final song in songs) {
        final key = _generateKey(song.title, song.artistName);
        final data = box.get(key);

        if (data != null) {
          try {
            final entry = BpmCacheEntry.fromJson(
              Map<String, dynamic>.from(data),
            );
            if (entry.isValid()) {
              // Use the original format for the result key to match API format
              results['${song.title}|${song.artistName}'] = entry.bpm;
            } else {
              // Remove expired entry
              await box.delete(key);
            }
          } catch (e) {
            // Invalid entry, remove it
            await box.delete(key);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error getting cached BPMs', e);
    }

    return results;
  }

  @override
  Future<void> cacheBpms(Map<String, int> bpmMap) async {
    try {
      final box = await _getBox();
      final now = DateTime.now();

      for (final entry in bpmMap.entries) {
        // Parse the key format "title|artistName"
        final parts = entry.key.split('|');
        if (parts.length >= 2) {
          final title = parts[0];
          final artistName = parts
              .sublist(1)
              .join('|'); // Handle artist names with |
          final cacheKey = _generateKey(title, artistName);
          final cacheEntry = BpmCacheEntry(bpm: entry.value, cachedAt: now);
          await box.put(cacheKey, cacheEntry.toJson());
        }
      }
    } catch (e) {
      AppLogger.error('Error caching BPMs', e);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      AppLogger.info('BPM cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing BPM cache', e);
    }
  }

  @override
  Future<({int totalEntries, int validEntries, int expiredEntries})>
  getCacheStats() async {
    try {
      final box = await _getBox();
      int validCount = 0;
      int expiredCount = 0;

      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          try {
            final entry = BpmCacheEntry.fromJson(
              Map<String, dynamic>.from(data),
            );
            if (entry.isValid()) {
              validCount++;
            } else {
              expiredCount++;
            }
          } catch (e) {
            expiredCount++;
          }
        }
      }

      return (
        totalEntries: box.length,
        validEntries: validCount,
        expiredEntries: expiredCount,
      );
    } catch (e) {
      AppLogger.error('Error getting cache stats', e);
      return (totalEntries: 0, validEntries: 0, expiredEntries: 0);
    }
  }
}
