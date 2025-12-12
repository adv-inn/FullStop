class PlaylistPrompts {
  static String generatePlaylistDescription({
    required List<String> artistNames,
    required int trackCount,
    String? mood,
    String? activity,
  }) {
    return '''
You are a music curator assistant. Generate a short, engaging description for a playlist.

Artists: ${artistNames.join(', ')}
Number of tracks: $trackCount
${mood != null ? 'Mood: $mood' : ''}
${activity != null ? 'Activity: $activity' : ''}

Generate a 1-2 sentence playlist description that captures the essence of this artist-focused playlist.
Keep it concise and evocative. Do not use generic phrases.
''';
  }

  static String suggestTrackOrder({
    required List<Map<String, dynamic>> tracks,
    String? preference,
  }) {
    final trackList = tracks
        .map(
          (t) =>
              '- ${t['name']} by ${t['artist']} (BPM: ${t['bpm']}, Energy: ${t['energy']})',
        )
        .join('\n');

    return '''
You are a DJ assistant. Given the following tracks, suggest an optimal order for a focused listening session.

Tracks:
$trackList

${preference != null ? 'User preference: $preference' : 'Default: Create a flow that maintains energy while providing variety'}

Return ONLY a JSON array of track names in the suggested order. Example:
["Track 1", "Track 2", "Track 3"]
''';
  }

  static String filterTracksByMood({
    required List<Map<String, dynamic>> tracks,
    required String mood,
  }) {
    final trackList = tracks
        .map(
          (t) =>
              '- ${t['name']} (Valence: ${t['valence']}, Energy: ${t['energy']}, Tempo: ${t['tempo']})',
        )
        .join('\n');

    return '''
You are a music mood analyzer. Filter the following tracks to match the mood: "$mood"

Available tracks with audio features:
$trackList

Audio feature reference:
- Valence (0-1): Musical positiveness. Higher = happier
- Energy (0-1): Intensity and activity. Higher = more energetic
- Tempo: BPM of the track

Return ONLY a JSON array of track names that best match the mood. Include at least 5 tracks if available.
Example: ["Track 1", "Track 2"]
''';
  }

  static String suggestRelatedArtists({
    required List<String> currentArtists,
    required String genre,
  }) {
    return '''
Based on these artists: ${currentArtists.join(', ')}
Genre context: $genre

Suggest 5 similar artists that would complement this playlist well.
Focus on artists with similar:
- Musical style and sound
- Energy level
- Era/time period

Return ONLY a JSON array of artist names.
Example: ["Artist 1", "Artist 2", "Artist 3", "Artist 4", "Artist 5"]
''';
  }

  static String analyzeListeningPattern({
    required List<Map<String, dynamic>> recentTracks,
  }) {
    final trackSummary = recentTracks
        .map((t) => '${t['name']} - ${t['artist']} (${t['genre']})')
        .join('\n');

    return '''
Analyze these recently played tracks and identify patterns:

$trackSummary

Provide insights in JSON format:
{
  "dominantMood": "string",
  "preferredGenres": ["genre1", "genre2"],
  "energyPreference": "low|medium|high",
  "tempoPreference": "slow|moderate|fast",
  "suggestion": "A brief recommendation for next tracks"
}
''';
  }
}
