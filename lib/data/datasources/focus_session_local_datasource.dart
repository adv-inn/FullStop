import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/track.dart';

abstract class FocusSessionLocalDataSource {
  Future<List<FocusSession>> getAllSessions();
  Future<FocusSession?> getSession(String sessionId);
  Future<void> saveSession(FocusSession session);
  Future<void> deleteSession(String sessionId);
  Future<List<FocusSession>> getRecentSessions({int limit = 5});
  Future<void> updateLastPlayed(String sessionId);

  /// Get the maximum sortOrder value among all sessions
  Future<int> getMaxSortOrder();

  /// Get the minimum sortOrder value among all sessions
  Future<int> getMinSortOrder();

  /// Get the count of pinned sessions
  Future<int> getPinnedCount();

  /// Get the currently active session ID (persisted across app restarts)
  Future<String?> getActiveSessionId();

  /// Save the active session ID
  Future<void> saveActiveSessionId(String? sessionId);

  /// Get the track URIs of the active session for queue validation
  Future<List<String>?> getActiveSessionTrackUris();

  /// Save the track URIs of the active session
  Future<void> saveActiveSessionTrackUris(List<String> trackUris);
}

class FocusSessionLocalDataSourceImpl implements FocusSessionLocalDataSource {
  static const String _boxName = 'focus_sessions';
  static const String _settingsBoxName = 'focus_session_settings';
  static const String _activeSessionIdKey = 'active_session_id';
  static const String _activeSessionTrackUrisKey = 'active_session_track_uris';

  final Box<String> _box;
  final Box<String> _settingsBox;

  FocusSessionLocalDataSourceImpl(this._box, this._settingsBox);

  static Future<FocusSessionLocalDataSourceImpl> create() async {
    final box = await Hive.openBox<String>(_boxName);
    final settingsBox = await Hive.openBox<String>(_settingsBoxName);
    return FocusSessionLocalDataSourceImpl(box, settingsBox);
  }

  @override
  Future<List<FocusSession>> getAllSessions() async {
    try {
      final sessions = <FocusSession>[];
      for (final key in _box.keys) {
        final json = _box.get(key);
        if (json != null) {
          sessions.add(_decodeSession(json));
        }
      }
      // Sort: pinned sessions first (by pinnedAt, oldest first), then by sortOrder
      sessions.sort((a, b) {
        // Both pinned: sort by pinnedAt (oldest first)
        if (a.isPinned && b.isPinned) {
          final aPinnedAt = a.pinnedAt ?? DateTime.now();
          final bPinnedAt = b.pinnedAt ?? DateTime.now();
          return aPinnedAt.compareTo(bPinnedAt);
        }
        // Only a is pinned: a comes first
        if (a.isPinned) return -1;
        // Only b is pinned: b comes first
        if (b.isPinned) return 1;
        // Neither pinned: sort by sortOrder (ascending - lower values first)
        return a.sortOrder.compareTo(b.sortOrder);
      });
      return sessions;
    } catch (e) {
      throw CacheException(message: 'Failed to get sessions: $e');
    }
  }

  @override
  Future<FocusSession?> getSession(String sessionId) async {
    try {
      final json = _box.get(sessionId);
      if (json == null) return null;
      return _decodeSession(json);
    } catch (e) {
      throw CacheException(message: 'Failed to get session: $e');
    }
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    try {
      final json = _encodeSession(session);
      await _box.put(session.id, json);
    } catch (e) {
      throw CacheException(message: 'Failed to save session: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _box.delete(sessionId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete session: $e');
    }
  }

  @override
  Future<List<FocusSession>> getRecentSessions({int limit = 5}) async {
    try {
      final allSessions = await getAllSessions();
      allSessions.sort((a, b) {
        final aTime = a.lastPlayedAt ?? a.createdAt;
        final bTime = b.lastPlayedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      return allSessions.take(limit).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get recent sessions: $e');
    }
  }

  @override
  Future<void> updateLastPlayed(String sessionId) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) return;

      final updatedSession = FocusSession(
        id: session.id,
        name: session.name,
        artists: session.artists,
        tracks: session.tracks,
        settings: session.settings,
        createdAt: session.createdAt,
        lastPlayedAt: DateTime.now(),
        sortOrder: session.sortOrder,
        isPinned: session.isPinned,
        pinnedAt: session.pinnedAt,
      );

      await saveSession(updatedSession);
    } catch (e) {
      throw CacheException(message: 'Failed to update last played: $e');
    }
  }

  @override
  Future<int> getMaxSortOrder() async {
    try {
      final sessions = await getAllSessions();
      if (sessions.isEmpty) return -1;
      return sessions.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b);
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<int> getMinSortOrder() async {
    try {
      final sessions = await getAllSessions();
      if (sessions.isEmpty) return 1;
      return sessions.map((s) => s.sortOrder).reduce((a, b) => a < b ? a : b);
    } catch (e) {
      return 1;
    }
  }

  @override
  Future<int> getPinnedCount() async {
    try {
      final sessions = await getAllSessions();
      return sessions.where((s) => s.isPinned).length;
    } catch (e) {
      return 0;
    }
  }

  String _encodeSession(FocusSession session) {
    final map = {
      'id': session.id,
      'name': session.name,
      'artists': session.artists.map(_encodeArtist).toList(),
      'tracks': session.tracks.map(_encodeTrack).toList(),
      'settings': {
        'playback': {
          'shuffle': session.settings.playback.shuffle,
          'repeatMode': session.settings.playback.repeatMode.name,
        },
        'contentFilter': {
          'minBpm': session.settings.contentFilter.minBpm,
          'maxBpm': session.settings.contentFilter.maxBpm,
          'minEnergy': session.settings.contentFilter.minEnergy,
          'maxEnergy': session.settings.contentFilter.maxEnergy,
          'includeFeatures': session.settings.contentFilter.includeFeatures,
          'includeCollaborations':
              session.settings.contentFilter.includeCollaborations,
        },
      },
      'createdAt': session.createdAt.toIso8601String(),
      'lastPlayedAt': session.lastPlayedAt?.toIso8601String(),
      'sortOrder': session.sortOrder,
      'isPinned': session.isPinned,
      'pinnedAt': session.pinnedAt?.toIso8601String(),
    };
    return jsonEncode(map);
  }

  FocusSession _decodeSession(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return FocusSession(
      id: map['id'] as String,
      name: map['name'] as String,
      artists: (map['artists'] as List).map(_decodeArtist).toList(),
      tracks: (map['tracks'] as List).map(_decodeTrack).toList(),
      settings: _decodeSettings(map['settings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'] as String)
          : null,
      sortOrder: (map['sortOrder'] as int?) ?? 0,
      isPinned: (map['isPinned'] as bool?) ?? false,
      pinnedAt: map['pinnedAt'] != null
          ? DateTime.parse(map['pinnedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> _encodeArtist(Artist artist) => {
    'id': artist.id,
    'name': artist.name,
    'genres': artist.genres,
    'popularity': artist.popularity,
    'followers': artist.followers,
    'images': artist.images
        .map((i) => {'url': i.url, 'width': i.width, 'height': i.height})
        .toList(),
    'externalUrl': artist.externalUrl,
  };

  Artist _decodeArtist(dynamic map) => Artist(
    id: map['id'] as String,
    name: map['name'] as String,
    genres: List<String>.from(map['genres'] as List? ?? []),
    popularity: (map['popularity'] as int?) ?? 0,
    followers: (map['followers'] as int?) ?? 0,
    images:
        (map['images'] as List?)
            ?.map(
              (i) => SpotifyImage(
                url: i['url'] as String,
                width: i['width'] as int?,
                height: i['height'] as int?,
              ),
            )
            .toList() ??
        [],
    externalUrl: map['externalUrl'] as String?,
  );

  Map<String, dynamic> _encodeTrack(Track track) => {
    'id': track.id,
    'name': track.name,
    'artists': track.artists.map(_encodeArtist).toList(),
    'album': {
      'id': track.album.id,
      'name': track.album.name,
      'albumType': track.album.albumType,
      'images': track.album.images
          .map((i) => {'url': i.url, 'width': i.width, 'height': i.height})
          .toList(),
      'releaseDate': track.album.releaseDate,
      'totalTracks': track.album.totalTracks,
      'externalUrl': track.album.externalUrl,
    },
    'durationMs': track.durationMs,
    'trackNumber': track.trackNumber,
    'discNumber': track.discNumber,
    'explicit': track.explicit,
    'previewUrl': track.previewUrl,
    'popularity': track.popularity,
    'uri': track.uri,
    'externalUrl': track.externalUrl,
  };

  Track _decodeTrack(dynamic map) {
    final albumMap = map['album'] as Map<String, dynamic>;
    return Track(
      id: map['id'] as String,
      name: map['name'] as String,
      artists: (map['artists'] as List).map(_decodeArtist).toList(),
      album: Album(
        id: albumMap['id'] as String,
        name: albumMap['name'] as String,
        albumType: (albumMap['albumType'] as String?) ?? 'album',
        images:
            (albumMap['images'] as List?)
                ?.map(
                  (i) => SpotifyImage(
                    url: i['url'] as String,
                    width: i['width'] as int?,
                    height: i['height'] as int?,
                  ),
                )
                .toList() ??
            [],
        releaseDate: albumMap['releaseDate'] as String?,
        totalTracks: (albumMap['totalTracks'] as int?) ?? 0,
        externalUrl: albumMap['externalUrl'] as String?,
      ),
      durationMs: map['durationMs'] as int,
      trackNumber: (map['trackNumber'] as int?) ?? 1,
      discNumber: (map['discNumber'] as int?) ?? 1,
      explicit: (map['explicit'] as bool?) ?? false,
      previewUrl: map['previewUrl'] as String?,
      popularity: (map['popularity'] as int?) ?? 0,
      uri: map['uri'] as String,
      externalUrl: map['externalUrl'] as String?,
    );
  }

  FocusSessionSettings _decodeSettings(Map<String, dynamic> map) {
    // Support both old flat format and new nested format for backward compatibility
    if (map.containsKey('playback')) {
      // New nested format
      final playbackMap = map['playback'] as Map<String, dynamic>;
      final contentFilterMap = map['contentFilter'] as Map<String, dynamic>;

      return FocusSessionSettings(
        playback: PlaybackSettings(
          shuffle: (playbackMap['shuffle'] as bool?) ?? false,
          repeatMode: RepeatMode.values.byName(
            (playbackMap['repeatMode'] as String?) ?? 'context',
          ),
        ),
        contentFilter: ContentFilterSettings(
          minBpm: contentFilterMap['minBpm'] as int?,
          maxBpm: contentFilterMap['maxBpm'] as int?,
          minEnergy: (contentFilterMap['minEnergy'] as num?)?.toDouble(),
          maxEnergy: (contentFilterMap['maxEnergy'] as num?)?.toDouble(),
          includeFeatures:
              (contentFilterMap['includeFeatures'] as bool?) ?? true,
          includeCollaborations:
              (contentFilterMap['includeCollaborations'] as bool?) ?? true,
        ),
      );
    } else {
      // Legacy flat format (backward compatibility)
      return FocusSessionSettings(
        playback: PlaybackSettings(
          shuffle: (map['shuffle'] as bool?) ?? false,
          repeatMode: RepeatMode.values.byName(
            (map['repeatMode'] as String?) ?? 'context',
          ),
        ),
        contentFilter: ContentFilterSettings(
          minBpm: map['minBpm'] as int?,
          maxBpm: map['maxBpm'] as int?,
          minEnergy: (map['minEnergy'] as num?)?.toDouble(),
          maxEnergy: (map['maxEnergy'] as num?)?.toDouble(),
          includeFeatures: (map['includeFeatures'] as bool?) ?? true,
          includeCollaborations:
              (map['includeCollaborations'] as bool?) ?? true,
        ),
      );
    }
  }

  @override
  Future<String?> getActiveSessionId() async {
    try {
      return _settingsBox.get(_activeSessionIdKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveActiveSessionId(String? sessionId) async {
    try {
      if (sessionId == null) {
        await _settingsBox.delete(_activeSessionIdKey);
        await _settingsBox.delete(_activeSessionTrackUrisKey);
      } else {
        await _settingsBox.put(_activeSessionIdKey, sessionId);
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  @override
  Future<List<String>?> getActiveSessionTrackUris() async {
    try {
      final json = _settingsBox.get(_activeSessionTrackUrisKey);
      if (json == null) return null;
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveActiveSessionTrackUris(List<String> trackUris) async {
    try {
      await _settingsBox.put(_activeSessionTrackUrisKey, jsonEncode(trackUris));
    } catch (e) {
      // Silently fail - not critical
    }
  }
}
