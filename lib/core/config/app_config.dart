class AppConfig {
  // Spotify Client ID (public client — safe to embed, PKCE replaces client_secret)
  static const String spotifyClientId = '94fcde08534f4025a402cd2bba93e1f0';

  // Custom URL scheme for OAuth callback
  static const String urlScheme = 'fullstop';

  // Redirect URI - using custom URL scheme for desktop OAuth
  static const String spotifyRedirectUri = '$urlScheme://callback';

  // Spotify API endpoints
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static const String spotifyTokenUrl =
      'https://accounts.spotify.com/api/token';
  static const String spotifyApiBaseUrl = 'https://api.spotify.com/v1';

  // Spotify OAuth scopes
  static const List<String> spotifyScopes = [
    'user-read-private',
    'user-read-email',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'playlist-read-private',
    'playlist-read-collaborative',
    'playlist-modify-private',
    'playlist-modify-public',
    'user-library-read',
    'user-library-modify', // Required for saving/removing tracks from library
    'user-top-read',
  ];
}
