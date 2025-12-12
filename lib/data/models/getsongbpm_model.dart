// Models for GetSongBPM API responses

class GetSongBpmSearchResponse {
  final List<GetSongBpmSongResult> search;

  GetSongBpmSearchResponse({required this.search});

  factory GetSongBpmSearchResponse.fromJson(Map<String, dynamic> json) {
    final searchData = json['search'];

    // Handle different response formats
    if (searchData == null) {
      return GetSongBpmSearchResponse(search: []);
    }

    // If search is a list (normal case)
    if (searchData is List) {
      return GetSongBpmSearchResponse(
        search: searchData
            .map(
              (e) => GetSongBpmSongResult.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    }

    // If search is a single object (edge case)
    if (searchData is Map<String, dynamic>) {
      return GetSongBpmSearchResponse(
        search: [GetSongBpmSongResult.fromJson(searchData)],
      );
    }

    return GetSongBpmSearchResponse(search: []);
  }
}

class GetSongBpmSongResult {
  final String id;
  final String title;
  final String? uri;
  final GetSongBpmArtist? artist;
  final int? tempo;
  final String? timeSignature;
  final String? keyOf;
  final String? openKey;

  GetSongBpmSongResult({
    required this.id,
    required this.title,
    this.uri,
    this.artist,
    this.tempo,
    this.timeSignature,
    this.keyOf,
    this.openKey,
  });

  factory GetSongBpmSongResult.fromJson(Map<String, dynamic> json) {
    return GetSongBpmSongResult(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      uri: json['uri'] as String?,
      artist: _parseArtist(json['artist']),
      tempo: _parseIntOrNull(json['tempo']),
      timeSignature: json['time_sig'] as String?,
      keyOf: json['key_of'] as String?,
      openKey: json['open_key'] as String?,
    );
  }

  static GetSongBpmArtist? _parseArtist(dynamic artistData) {
    if (artistData == null) return null;

    // Handle artist as object (expected format)
    if (artistData is Map<String, dynamic>) {
      return GetSongBpmArtist.fromJson(artistData);
    }

    // Handle artist as list (edge case - take first)
    if (artistData is List && artistData.isNotEmpty) {
      final first = artistData.first;
      if (first is Map<String, dynamic>) {
        return GetSongBpmArtist.fromJson(first);
      }
    }

    return null;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}

class GetSongBpmArtist {
  final String id;
  final String name;
  final String? uri;

  GetSongBpmArtist({required this.id, required this.name, this.uri});

  factory GetSongBpmArtist.fromJson(Map<String, dynamic> json) {
    return GetSongBpmArtist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      uri: json['uri'] as String?,
    );
  }
}

class GetSongBpmSongDetail {
  final GetSongBpmSongResult? song;

  GetSongBpmSongDetail({this.song});

  factory GetSongBpmSongDetail.fromJson(Map<String, dynamic> json) {
    return GetSongBpmSongDetail(
      song: json['song'] != null
          ? GetSongBpmSongResult.fromJson(json['song'] as Map<String, dynamic>)
          : null,
    );
  }
}
