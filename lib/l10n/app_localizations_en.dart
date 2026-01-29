// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FullStop';

  @override
  String get focusSessions => 'Focus Moments';

  @override
  String get newSession => 'New Session';

  @override
  String get noSessionsYet => 'No focus sessions yet';

  @override
  String get createSessionHint =>
      'Create a session to focus on your favorite artists';

  @override
  String get focusOnFavoriteArtists => 'Focus on your favorite artists';

  @override
  String get connectWithSpotify => 'Connect with Spotify';

  @override
  String get connectingToSpotify => 'Connecting to Spotify...';

  @override
  String get completeLoginInBrowser =>
      'Please complete the login in your browser.';

  @override
  String get afterAgreeCloseBrowser =>
      'After clicking \"Agree\", you can close the browser tab';

  @override
  String get cancelLogin => 'Cancel Login';

  @override
  String get cancelHint => 'Click to cancel and return to login screen';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get errorCopied => 'Error message copied to clipboard';

  @override
  String get reconfigureCredentials => 'Reconfigure Credentials';

  @override
  String get apiConfigured => 'API configured';

  @override
  String get change => 'Change';

  @override
  String get credentialsStayOnDevice => 'Your credentials stay on your device';

  @override
  String get controlsExistingSession =>
      'Controls your existing Spotify session';

  @override
  String get requiresPremium => 'Requires Spotify Premium';

  @override
  String get logout => 'Logout';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Free';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get systemDefault => 'System Default';

  @override
  String get createSession => 'Create Session';

  @override
  String get searchArtists => 'Search artists...';

  @override
  String get addMoreArtists => 'Add more...';

  @override
  String get selectedArtists => 'Selected Artists';

  @override
  String get sessionName => 'Session Name';

  @override
  String get sessionNameHint => 'e.g., My Chill Mix';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get nothingPlaying => 'Nothing playing';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get setupGuide => 'Setup Guide';

  @override
  String get welcomeToApp => 'Welcome to Spotify Focus Someone!';

  @override
  String get setupDescription =>
      'To get started, you\'ll need to create a Spotify Developer App and enter your credentials.';

  @override
  String get step1Title => 'Go to Spotify Developer Dashboard';

  @override
  String get step2Title => 'Create a new app';

  @override
  String get step3Title => 'Add redirect URI';

  @override
  String get step4Title => 'Copy your credentials';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get errorInvalidClient =>
      'Invalid API credentials. Please check your Client ID and Secret.';

  @override
  String get errorRedirectUri =>
      'Redirect URI mismatch! Your Spotify app must have the correct Redirect URI configured.';

  @override
  String get errorNetwork =>
      'Network error. Please check your internet connection.';

  @override
  String get errorCancelled => 'Login was cancelled. Please try again.';

  @override
  String get errorTimeout => 'Authentication timed out. Please try again.';

  @override
  String get errorAccessDenied =>
      'Access denied. You need to authorize the app to access your Spotify account.';

  @override
  String get errorNeedsReauth =>
      'Permission denied. Please log out and log in again to grant the required permissions.';

  @override
  String tracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: 'No tracks',
    );
    return '$_temp0';
  }

  @override
  String artists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
      zero: 'No artists',
    );
    return '$_temp0';
  }

  @override
  String get deleteSession => 'Delete Session';

  @override
  String deleteSessionConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get shuffleOn => 'Shuffle On';

  @override
  String get shuffleOff => 'Shuffle Off';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatOff => 'Play Once';

  @override
  String get repeatAll => 'Loop';

  @override
  String get repeatOne => 'One';

  @override
  String get sessionNameOptional => 'Session name (optional)';

  @override
  String get searchForArtists => 'Search for artists to add to your session';

  @override
  String get noArtistsFound => 'No artists found';

  @override
  String createdSession(String name) {
    return 'Created session: $name';
  }

  @override
  String get more => 'More';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get noTracksInSession => 'No tracks in this session';

  @override
  String get removeTrack => 'Remove track';

  @override
  String get sessionUpdated => 'Session updated';

  @override
  String get editSession => 'Edit Session';

  @override
  String get dragToReorder => 'Drag to reorder tracks';

  @override
  String get creatingSession => 'Creating session, fetching tracks...';

  @override
  String get smartSchedule => 'Smart Schedule';

  @override
  String get smartScheduleHint => 'Filter tracks by tempo style';

  @override
  String get styleSlow => 'Slow';

  @override
  String get styleSlowDesc => 'Ballads, emotional, relaxed';

  @override
  String get styleMidTempo => 'Mid-tempo';

  @override
  String get styleMidTempoDesc => 'Easy listening, R&B groove';

  @override
  String get styleUpTempo => 'Up-tempo';

  @override
  String get styleUpTempoDesc => 'Energetic, pop, dance';

  @override
  String get styleFast => 'Fast';

  @override
  String get styleFastDesc => 'Rock, metal, intense';

  @override
  String bpmRange(int min, int max) {
    return '$min-$max BPM';
  }

  @override
  String get selectStyle => 'Select a style';

  @override
  String get proxy => 'Proxy';

  @override
  String get proxyEnabled => 'Enable Proxy';

  @override
  String get proxyType => 'Proxy Type';

  @override
  String get proxyHost => 'Host';

  @override
  String get proxyPort => 'Port';

  @override
  String get proxyUsername => 'Username (optional)';

  @override
  String get proxyPassword => 'Password (optional)';

  @override
  String get proxyHint =>
      'Use SOCKS5 or HTTP proxy to accelerate Spotify API access';

  @override
  String get proxySaved => 'Proxy settings saved';

  @override
  String get proxyCleared => 'Proxy settings cleared';

  @override
  String get proxyInvalid => 'Invalid proxy configuration';

  @override
  String get testProxy => 'Test Connection';

  @override
  String get proxyTestSuccess => 'Proxy connection successful';

  @override
  String proxyTestFailed(String error) {
    return 'Proxy connection failed: $error';
  }

  @override
  String get matchByStyle => 'By Style';

  @override
  String get matchByArtistTrack => 'By Artist';

  @override
  String get matchByPlaylist => 'By Playlist';

  @override
  String get selectPlaylist => 'Select a Playlist';

  @override
  String get selectTrackForMatch => 'Select a track to match BPM';

  @override
  String get yourPlaylists => 'Your Playlists';

  @override
  String get loadingPlaylists => 'Loading playlists...';

  @override
  String get noPlaylists => 'No playlists found';

  @override
  String matchingBpm(int bpm) {
    return 'Matching BPM: $bpm';
  }

  @override
  String get selectArtistFirst => 'Please select an artist first';

  @override
  String get loadingArtistTracks => 'Loading artist tracks...';

  @override
  String get noArtistTracks => 'No tracks found for selected artists';

  @override
  String get selectTrackFromArtist => 'Select a track from the artist';

  @override
  String get selectTracksFromArtist => 'Select tracks to match BPM';

  @override
  String selectedTracksCount(int count) {
    return '$count tracks selected';
  }

  @override
  String bpmRangesHint(String ranges) {
    return 'BPM ranges: $ranges';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get retry => 'Retry';

  @override
  String get loadingBpm => 'Loading BPM...';

  @override
  String get bpmUnavailable => 'BPM data unavailable';

  @override
  String get advancedFeatures => 'BPM Features';

  @override
  String get getSongBpmAttribution => 'Powered by GetSongBPM';

  @override
  String get getSongBpmHint =>
      'BPM data is provided by GetSongBPM.com. Register for a free API key to enable BPM matching features.';

  @override
  String get getSongBpmApiKey => 'GetSongBPM API Key';

  @override
  String get getSongBpmApiKeyHint => 'Enter your GetSongBPM API key';

  @override
  String get getSongBpmApiKeyConfigured => 'API key configured';

  @override
  String get getSongBpmApiKeySaved => 'API key saved successfully';

  @override
  String get getSongBpmApiKeyError => 'Failed to save API key';

  @override
  String get getSongBpmApiKeyEmpty => 'Please enter an API key';

  @override
  String get getSongBpmApiKeyCleared => 'API key cleared';

  @override
  String get experimentalFeature => 'Experimental Feature';

  @override
  String get experimentalSmartScheduleWarning =>
      'This mode fetches BPM for all tracks which may take several minutes. The session will be created in the background - you can continue using the app.';

  @override
  String get continueButton => 'Continue';

  @override
  String get creatingSessionBackground => 'Creating session in background...';

  @override
  String fetchingTracksProgress(int count) {
    return 'Fetching tracks from $count artists...';
  }

  @override
  String fetchingArtistTracks(String artistName) {
    return 'Fetching: $artistName';
  }

  @override
  String fetchingBpmProgress(int current, int total) {
    return 'Analyzing BPM ($current/$total)...';
  }

  @override
  String get filteringTracks => 'Filtering tracks by BPM...';

  @override
  String sessionCreatedBackground(String name, int count) {
    return 'Session \"$name\" created with $count tracks';
  }

  @override
  String sessionCreationFailed(String error) {
    return 'Failed to create session: $error';
  }

  @override
  String get pendingSession => 'Creating...';

  @override
  String get viewPendingSession => 'View';

  @override
  String get trackLimit => 'Track Limit';

  @override
  String trackLimitEnabled(int count) {
    return 'Limit to $count tracks';
  }

  @override
  String get trackLimitDisabled => 'No track limit';

  @override
  String get trackLimitHint =>
      'Limit the number of tracks in smart schedule sessions';

  @override
  String bpmCacheStats(int count) {
    return 'BPM Cache: $count entries';
  }

  @override
  String get clearBpmCache => 'Clear BPM Cache';

  @override
  String get bpmCacheCleared => 'BPM cache cleared';

  @override
  String get trayShowWindow => 'Show FullStop';

  @override
  String get trayExit => 'Exit';

  @override
  String get trayPreviousTrack => 'Previous Track';

  @override
  String get trayNextTrack => 'Next Track';

  @override
  String get trayTooltip => 'FullStop - Spotify Controller';

  @override
  String get errorNoActiveDevice =>
      'No active Spotify device found. Please open Spotify on your phone, computer, or other device first.';

  @override
  String get errorSpotifyConnectionFailed =>
      'FullStop cannot connect to Spotify. Please manually open Spotify and play any music, then try again.';

  @override
  String get connectingToSpotifyDevice => 'Connecting to Spotify...';

  @override
  String get spotifyNotInstalled => 'Spotify app not detected';

  @override
  String get traditionalSchedule => 'Traditional';

  @override
  String get dispatchHitsOnly => 'Hits Only';

  @override
  String get dispatchHitsOnlyDesc =>
      'No skips needed. Every track\'s a banger.';

  @override
  String get dispatchBalanced => 'Balanced';

  @override
  String get dispatchBalancedDesc =>
      'Familiar favorites with pleasant surprises.';

  @override
  String get dispatchDeepDive => 'Deep Dive';

  @override
  String get dispatchDeepDiveDesc => 'Hunt for that forgotten B-side gem.';

  @override
  String get dispatchUnfiltered => 'Unfiltered';

  @override
  String get dispatchUnfilteredDesc => 'Relive the concert. Feel every encore.';

  @override
  String get trueShuffle => 'True Shuffle';

  @override
  String get trueShuffleDesc => 'Smart dedupe & album spread';

  @override
  String get artistLimitReached => 'Artist limit reached';

  @override
  String artistLimitHint(int count) {
    return 'For best focus experience and dedupe quality, limit to $count artists.';
  }

  @override
  String selectedArtistsCount(int current, int max) {
    return 'Selected ($current/$max)';
  }

  @override
  String get tapToExpand => 'Tap to expand';

  @override
  String get cacheManagement => 'Cache';

  @override
  String get imageCacheSize => 'Image Cache';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get cacheClearFailed => 'Failed to clear cache';

  @override
  String get calculating => 'Calculating...';

  @override
  String get rename => 'Rename';

  @override
  String get renameSession => 'Rename Session';

  @override
  String get sessionRenamed => 'Session renamed';

  @override
  String get likeAllTracks => 'Like All Tracks';

  @override
  String likeAllTracksConfirm(int count) {
    return 'Add $count tracks to your Liked Songs?';
  }

  @override
  String get tracksAlreadyLiked => 'All tracks are already liked';

  @override
  String tracksLiked(int count) {
    return '$count tracks added to Liked Songs';
  }

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get createPlaylistFromSession => 'Create Playlist from This';

  @override
  String createPlaylistConfirm(String name, int count) {
    return 'Create a Spotify playlist \"$name\" with $count tracks?';
  }

  @override
  String playlistCreated(String name) {
    return 'Playlist \"$name\" created';
  }

  @override
  String get playlistCreationFailed => 'Failed to create playlist';

  @override
  String get checkingLikedStatus => 'Checking liked status...';

  @override
  String get likingTracks => 'Liking tracks...';

  @override
  String get creatingPlaylist => 'Creating playlist...';

  @override
  String get moveUp => 'Move Up';

  @override
  String get moveDown => 'Move Down';

  @override
  String get pinToTop => 'Pin to top';

  @override
  String get unpinFromTop => 'Unpin from top';

  @override
  String lastPlayed(String time) {
    return 'Last played: $time';
  }

  @override
  String get moreArtists => 'More Artists';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get performance => 'Performance';

  @override
  String get gpuAcceleration => 'GPU Acceleration';

  @override
  String get gpuAccelerationDesc => 'Use GPU for smoother animations';

  @override
  String get gpuAccelerationHint =>
      'Enable GPU acceleration for smoother wave animations. Disable if you experience graphics issues or don\'t have a dedicated GPU.';

  @override
  String get pinSession => 'Pin to Top';

  @override
  String get unpinSession => 'Unpin';

  @override
  String get pinSessionHint => 'Max 3 pinned sessions';

  @override
  String get sessionPinned => 'Session pinned';

  @override
  String get sessionUnpinned => 'Session unpinned';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutPrivacySecurity => 'Privacy & Security';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutStarProject => 'Star the project';

  @override
  String get aboutTwitter => 'X (Twitter)';

  @override
  String get aboutFollowUpdates => 'Follow for updates';

  @override
  String get aboutPoweredBySpotify => 'Powered by Spotify';

  @override
  String get aboutUsesSpotifyApi => 'Uses Spotify Web API';

  @override
  String get privacySecureStorage => 'Secure Local Storage';

  @override
  String get privacySecureStorageDesc =>
      'Your API credentials are encrypted and stored only on your device. They are never transmitted to any external server.';

  @override
  String get privacyDirectConnection => 'Direct Spotify Connection';

  @override
  String get privacyDirectConnectionDesc =>
      'This app connects directly to Spotify\'s official API. We don\'t relay your data through any intermediary servers.';

  @override
  String get privacyNoDataCollection => 'No Data Collection';

  @override
  String get privacyNoDataCollectionDesc =>
      'We do not collect, store, or transmit any usage analytics, listening history, or personal information.';

  @override
  String get privacyOAuthSecurity => 'OAuth Security';

  @override
  String get privacyOAuthSecurityDesc =>
      'Authentication uses a local HTTP server on ports 8888-8891, 8080, or 3000 with CSRF protection via state parameter.';

  @override
  String get privacyYouControl => 'You Control Your Data';

  @override
  String get privacyYouControlDesc =>
      'You can clear your credentials at any time from this settings page. Uninstalling the app removes all stored data.';

  @override
  String get close => 'Close';

  @override
  String get welcomeToFullStop => 'Welcome to FullStop';

  @override
  String get updateCredentials => 'Update Credentials';

  @override
  String get connectSpotifyToStart =>
      'Connect your Spotify account to get started';

  @override
  String get updateSpotifyCredentials => 'Update your Spotify API credentials';

  @override
  String get credentialsSecurelyStored =>
      'Your credentials are stored securely on your device only';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get step1CreateApp => 'Step 1: Create a Spotify App';

  @override
  String get openDeveloperDashboard => 'Open Spotify Developer Dashboard';

  @override
  String get openDeveloperDashboardHint =>
      'Click the button below to open the Spotify Developer Dashboard in your browser.';

  @override
  String get createNewApp => 'Create a New App';

  @override
  String get createNewAppDesc =>
      'Click \"Create App\" and fill in:\n• App name: Any name (e.g., \"My Focus App\")\n• App description: Personal use\n• Website: Leave empty or use any URL\n• Check \"Web API\" option';

  @override
  String get createNewAppDescShort =>
      'Click \"Create App\" and fill in the following fields. Check \"Web API\" option.';

  @override
  String get appNameLabel => 'App name';

  @override
  String get appNameCopied => 'App name copied!';

  @override
  String get appDescriptionLabel => 'App description';

  @override
  String get appDescriptionCopied => 'App description copied!';

  @override
  String get redirectUriLabel => 'Redirect URI';

  @override
  String get setRedirectUri => 'Set Redirect URI (IMPORTANT!)';

  @override
  String get setRedirectUriDesc =>
      'In \"Redirect URIs\" field, add this EXACT URI:';

  @override
  String get copy => 'Copy';

  @override
  String get redirectUriCopied => 'Redirect URI copied!';

  @override
  String get redirectUriWarning =>
      'Click \"Add\" after pasting, then click \"Save\" at the bottom!';

  @override
  String get step2EnterCredentials => 'Step 2: Enter Your Credentials';

  @override
  String get updateYourCredentials => 'Update Your Credentials';

  @override
  String get findCredentialsHint =>
      'Find your credentials in the app settings page on the Spotify Developer Dashboard.';

  @override
  String get modifyCredentialsHint =>
      'Modify the credentials below. Leave unchanged if correct.';

  @override
  String get enterClientId => 'Enter your Client ID';

  @override
  String get clientIdRequired => 'Client ID is required';

  @override
  String get clientIdTooShort => 'Client ID seems too short';

  @override
  String get enterClientSecret => 'Enter your Client Secret';

  @override
  String get clientSecretRequired => 'Client Secret is required';

  @override
  String get clientSecretTooShort => 'Client Secret seems too short';

  @override
  String get whereToFindCredentials => 'Where to find these?';

  @override
  String get whereToFindCredentialsDesc =>
      'In your Spotify app\'s Settings page, you\'ll see Client ID. Click \"View client secret\" to reveal the secret.';

  @override
  String get step3ReadyToConnect => 'Step 3: Ready to Connect';

  @override
  String get credentialsSaved => 'Credentials Saved!';

  @override
  String get waitingForCredentials => 'Waiting for Credentials';

  @override
  String get credentialsSavedDesc =>
      'Your Spotify API credentials have been securely stored. You can now connect to Spotify.';

  @override
  String get waitingForCredentialsDesc =>
      'Please go back to Step 2 and enter your credentials.';

  @override
  String get spotifyPremiumRequired => 'Spotify Premium Required';

  @override
  String get spotifyPremiumRequiredDesc =>
      'This app requires Spotify Premium for playback control features.';

  @override
  String get back => 'Back';

  @override
  String get nextEnterCredentials => 'Next: Enter Credentials';

  @override
  String get saveCredentials => 'Save Credentials';

  @override
  String get updateCredentialsButton => 'Update Credentials';

  @override
  String get connectToSpotify => 'Connect to Spotify';

  @override
  String get reconfigureApiCredentials => 'Reconfigure API Credentials';

  @override
  String get changeClientIdSecret => 'Change your Client ID and Secret';

  @override
  String get reconfigureDialogTitle => 'Reconfigure API Credentials';

  @override
  String get reconfigureDialogContent =>
      'This will clear your current API credentials and log you out.\n\nYou will need to enter your Client ID and Secret again.';

  @override
  String get reconfigure => 'Reconfigure';

  @override
  String get redirectUriForSpotifyApp => 'Redirect URI for Spotify App';

  @override
  String get spotifyApi => 'Spotify API';

  @override
  String configured(String clientId) {
    return 'Configured ($clientId)';
  }

  @override
  String get notConfigured => 'Not configured';

  @override
  String get llmOpenAiCompatible => 'OpenAI-Compatible API';

  @override
  String get llmOpenAiCompatibleDesc =>
      'Works with OpenAI, Ollama, and other OpenAI-compatible APIs.\nAPI Key is optional for local models like Ollama.';

  @override
  String get enableAiFeatures => 'Enable AI Features';

  @override
  String get smartPlaylistCuration => 'Smart playlist curation with LLM';

  @override
  String get llmBaseUrl => 'Base URL *';

  @override
  String get llmBaseUrlHint => 'https://api.openai.com/v1';

  @override
  String get llmBaseUrlHelper =>
      '/chat/completions will be added automatically';

  @override
  String get llmModel => 'Model *';

  @override
  String get llmModelHint => 'gpt-4';

  @override
  String get llmModelHelper => 'e.g., gpt-4o-mini, llama3, qwen2, gemini-pro';

  @override
  String get llmApiKey => 'API Key (Optional)';

  @override
  String get llmApiKeyHint => 'sk-...';

  @override
  String get llmApiKeyHelper => 'Leave empty for local models like Ollama';

  @override
  String get test => 'Test';

  @override
  String get llmExamples => 'Examples:';

  @override
  String llmConfigured(String model) {
    return 'LLM configured: $model';
  }

  @override
  String get llmConfigSaved => 'LLM configuration saved';

  @override
  String get llmConfigSaveFailed => 'Failed to save configuration';

  @override
  String get llmBaseUrlModelRequired => 'Base URL and Model are required';

  @override
  String llmTesting(String url) {
    return 'Testing: $url';
  }

  @override
  String llmTestSuccess(String response) {
    return 'Success! Response: $response...';
  }

  @override
  String get request => 'Request:';

  @override
  String get llmError404 =>
      'Error 404: Endpoint not found. Please check if the API Endpoint URL is correct';

  @override
  String get llmError401 => 'Error 401: Invalid API key or unauthorized access';

  @override
  String get llmError403 =>
      'Error 403: Access forbidden. Check your API key permissions';

  @override
  String get llmError429 =>
      'Error 429: Rate limit exceeded. Please wait and try again';

  @override
  String get llmErrorServer =>
      'Server error: The API server is temporarily unavailable';

  @override
  String get llmErrorTimeout =>
      'Connection timeout: Server took too long to respond';

  @override
  String get llmErrorConnection =>
      'Connection failed: Check your network and proxy settings';

  @override
  String get miniPlayer => 'Mini Player';

  @override
  String get exitMiniPlayer => 'Exit Mini Player';
}
