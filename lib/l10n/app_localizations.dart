import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'FullStop'**
  String get appTitle;

  /// Title for focus sessions screen
  ///
  /// In en, this message translates to:
  /// **'Focus Moments'**
  String get focusSessions;

  /// Button text to create new session
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// Text shown when there are no sessions
  ///
  /// In en, this message translates to:
  /// **'No focus sessions yet'**
  String get noSessionsYet;

  /// Hint text for creating a session
  ///
  /// In en, this message translates to:
  /// **'Create a session to focus on your favorite artists'**
  String get createSessionHint;

  /// App subtitle
  ///
  /// In en, this message translates to:
  /// **'Focus on your favorite artists'**
  String get focusOnFavoriteArtists;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Connect with Spotify'**
  String get connectWithSpotify;

  /// Loading text during login
  ///
  /// In en, this message translates to:
  /// **'Connecting to Spotify...'**
  String get connectingToSpotify;

  /// Instruction for login
  ///
  /// In en, this message translates to:
  /// **'Please complete the login in your browser.'**
  String get completeLoginInBrowser;

  /// Hint about closing browser after authorization
  ///
  /// In en, this message translates to:
  /// **'After clicking \"Agree\", you can close the browser tab'**
  String get afterAgreeCloseBrowser;

  /// Cancel login button text
  ///
  /// In en, this message translates to:
  /// **'Cancel Login'**
  String get cancelLogin;

  /// Cancel button hint text
  ///
  /// In en, this message translates to:
  /// **'Click to cancel and return to login screen'**
  String get cancelHint;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// Snackbar message when error is copied
  ///
  /// In en, this message translates to:
  /// **'Error message copied to clipboard'**
  String get errorCopied;

  /// Security info text
  ///
  /// In en, this message translates to:
  /// **'Your credentials stay on your device'**
  String get credentialsStayOnDevice;

  /// Feature info text
  ///
  /// In en, this message translates to:
  /// **'Controls your existing Spotify session'**
  String get controlsExistingSession;

  /// Premium requirement text
  ///
  /// In en, this message translates to:
  /// **'Requires Spotify Premium'**
  String get requiresPremium;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Premium status label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Free account label
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// Use system default language
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Create session screen title
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get createSession;

  /// Search artists placeholder
  ///
  /// In en, this message translates to:
  /// **'Search artists...'**
  String get searchArtists;

  /// Placeholder when artists are already selected
  ///
  /// In en, this message translates to:
  /// **'Add more...'**
  String get addMoreArtists;

  /// Selected artists section title
  ///
  /// In en, this message translates to:
  /// **'Selected Artists'**
  String get selectedArtists;

  /// Session name field label
  ///
  /// In en, this message translates to:
  /// **'Session Name'**
  String get sessionName;

  /// Session name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., My Chill Mix'**
  String get sessionNameHint;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Now playing screen title
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Text when nothing is playing
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get nothingPlaying;

  /// Play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Previous track button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Next track button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Invalid client error message
  ///
  /// In en, this message translates to:
  /// **'Invalid API credentials. Please check your Client ID and Secret.'**
  String get errorInvalidClient;

  /// Redirect URI error message
  ///
  /// In en, this message translates to:
  /// **'Redirect URI mismatch! Your Spotify app must have the correct Redirect URI configured.'**
  String get errorRedirectUri;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get errorNetwork;

  /// Login cancelled message
  ///
  /// In en, this message translates to:
  /// **'Login was cancelled. Please try again.'**
  String get errorCancelled;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Authentication timed out. Please try again.'**
  String get errorTimeout;

  /// Access denied error message
  ///
  /// In en, this message translates to:
  /// **'Access denied. You need to authorize the app to access your Spotify account.'**
  String get errorAccessDenied;

  /// Error when user needs to re-authenticate for new permissions
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please log out and log in again to grant the required permissions.'**
  String get errorNeedsReauth;

  /// Track count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tracks} =1{1 track} other{{count} tracks}}'**
  String tracks(int count);

  /// Artist count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No artists} =1{1 artist} other{{count} artists}}'**
  String artists(int count);

  /// Delete session button
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSession;

  /// Delete session confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteSessionConfirm(String name);

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Session deleted confirmation
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// Shuffle playback option
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// Shuffle is enabled
  ///
  /// In en, this message translates to:
  /// **'Shuffle On'**
  String get shuffleOn;

  /// Shuffle is disabled
  ///
  /// In en, this message translates to:
  /// **'Shuffle Off'**
  String get shuffleOff;

  /// Repeat playback option
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// Repeat mode off
  ///
  /// In en, this message translates to:
  /// **'Play Once'**
  String get repeatOff;

  /// Repeat all tracks
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get repeatAll;

  /// Repeat one track
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get repeatOne;

  /// Session name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Session name (optional)'**
  String get sessionNameOptional;

  /// Search hint when no search query
  ///
  /// In en, this message translates to:
  /// **'Search for artists to add to your session'**
  String get searchForArtists;

  /// Text when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No artists found'**
  String get noArtistsFound;

  /// Session created confirmation
  ///
  /// In en, this message translates to:
  /// **'Created session: {name}'**
  String createdSession(String name);

  /// More options button tooltip
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Empty state for session with no tracks
  ///
  /// In en, this message translates to:
  /// **'No tracks in this session'**
  String get noTracksInSession;

  /// Remove track button tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove track'**
  String get removeTrack;

  /// Session updated confirmation
  ///
  /// In en, this message translates to:
  /// **'Session updated'**
  String get sessionUpdated;

  /// Edit session title
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get editSession;

  /// Hint for reordering tracks
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder tracks'**
  String get dragToReorder;

  /// Loading text while creating session
  ///
  /// In en, this message translates to:
  /// **'Creating session, fetching tracks...'**
  String get creatingSession;

  /// Smart scheduling feature toggle
  ///
  /// In en, this message translates to:
  /// **'Smart Schedule'**
  String get smartSchedule;

  /// Hint for smart scheduling
  ///
  /// In en, this message translates to:
  /// **'Filter tracks by tempo style'**
  String get smartScheduleHint;

  /// Slow tempo style (60-80 BPM)
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get styleSlow;

  /// Description for slow style
  ///
  /// In en, this message translates to:
  /// **'Ballads, emotional, relaxed'**
  String get styleSlowDesc;

  /// Mid tempo style (90-110 BPM)
  ///
  /// In en, this message translates to:
  /// **'Mid-tempo'**
  String get styleMidTempo;

  /// Description for mid-tempo style
  ///
  /// In en, this message translates to:
  /// **'Easy listening, R&B groove'**
  String get styleMidTempoDesc;

  /// Up tempo style (120-140 BPM)
  ///
  /// In en, this message translates to:
  /// **'Up-tempo'**
  String get styleUpTempo;

  /// Description for up-tempo style
  ///
  /// In en, this message translates to:
  /// **'Energetic, pop, dance'**
  String get styleUpTempoDesc;

  /// Fast tempo style (150+ BPM)
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get styleFast;

  /// Description for fast style
  ///
  /// In en, this message translates to:
  /// **'Rock, metal, intense'**
  String get styleFastDesc;

  /// BPM range display
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} BPM'**
  String bpmRange(int min, int max);

  /// Prompt to select a music style
  ///
  /// In en, this message translates to:
  /// **'Select a style'**
  String get selectStyle;

  /// Proxy settings section title
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get proxy;

  /// Toggle to enable proxy
  ///
  /// In en, this message translates to:
  /// **'Enable Proxy'**
  String get proxyEnabled;

  /// Proxy type selector label
  ///
  /// In en, this message translates to:
  /// **'Proxy Type'**
  String get proxyType;

  /// Proxy host field label
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get proxyHost;

  /// Proxy port field label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get proxyPort;

  /// Proxy username field label
  ///
  /// In en, this message translates to:
  /// **'Username (optional)'**
  String get proxyUsername;

  /// Proxy password field label
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get proxyPassword;

  /// Hint text for proxy settings
  ///
  /// In en, this message translates to:
  /// **'Use SOCKS5 or HTTP proxy to accelerate Spotify API access'**
  String get proxyHint;

  /// Toast message when proxy is saved
  ///
  /// In en, this message translates to:
  /// **'Proxy settings saved'**
  String get proxySaved;

  /// Toast message when proxy is cleared
  ///
  /// In en, this message translates to:
  /// **'Proxy settings cleared'**
  String get proxyCleared;

  /// Error message for invalid proxy
  ///
  /// In en, this message translates to:
  /// **'Invalid proxy configuration'**
  String get proxyInvalid;

  /// Button to test proxy connection
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testProxy;

  /// Message when proxy test succeeds
  ///
  /// In en, this message translates to:
  /// **'Proxy connection successful'**
  String get proxyTestSuccess;

  /// Message when proxy test fails
  ///
  /// In en, this message translates to:
  /// **'Proxy connection failed: {error}'**
  String proxyTestFailed(String error);

  /// Smart schedule mode - match by music style
  ///
  /// In en, this message translates to:
  /// **'By Style'**
  String get matchByStyle;

  /// Smart schedule mode - match by artist track
  ///
  /// In en, this message translates to:
  /// **'By Artist'**
  String get matchByArtistTrack;

  /// Smart schedule mode - match by playlist track
  ///
  /// In en, this message translates to:
  /// **'By Playlist'**
  String get matchByPlaylist;

  /// Prompt to select a playlist
  ///
  /// In en, this message translates to:
  /// **'Select a Playlist'**
  String get selectPlaylist;

  /// Hint for track matching mode
  ///
  /// In en, this message translates to:
  /// **'Select a track to match BPM'**
  String get selectTrackForMatch;

  /// Section title for user playlists
  ///
  /// In en, this message translates to:
  /// **'Your Playlists'**
  String get yourPlaylists;

  /// Loading text for playlists
  ///
  /// In en, this message translates to:
  /// **'Loading playlists...'**
  String get loadingPlaylists;

  /// Empty state for playlists
  ///
  /// In en, this message translates to:
  /// **'No playlists found'**
  String get noPlaylists;

  /// Shows the BPM being matched
  ///
  /// In en, this message translates to:
  /// **'Matching BPM: {bpm}'**
  String matchingBpm(int bpm);

  /// Hint when no artist selected for artist track mode
  ///
  /// In en, this message translates to:
  /// **'Please select an artist first'**
  String get selectArtistFirst;

  /// Loading text for artist tracks
  ///
  /// In en, this message translates to:
  /// **'Loading artist tracks...'**
  String get loadingArtistTracks;

  /// Empty state for artist tracks
  ///
  /// In en, this message translates to:
  /// **'No tracks found for selected artists'**
  String get noArtistTracks;

  /// Hint for selecting track from artist
  ///
  /// In en, this message translates to:
  /// **'Select a track from the artist'**
  String get selectTrackFromArtist;

  /// Hint for selecting multiple tracks from artist
  ///
  /// In en, this message translates to:
  /// **'Select tracks to match BPM'**
  String get selectTracksFromArtist;

  /// Shows count of selected tracks
  ///
  /// In en, this message translates to:
  /// **'{count} tracks selected'**
  String selectedTracksCount(int count);

  /// Shows BPM ranges for selected tracks
  ///
  /// In en, this message translates to:
  /// **'BPM ranges: {ranges}'**
  String bpmRangesHint(String ranges);

  /// Clear all button tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading text while fetching BPM data
  ///
  /// In en, this message translates to:
  /// **'Loading BPM...'**
  String get loadingBpm;

  /// Text shown when BPM data cannot be fetched (API restriction)
  ///
  /// In en, this message translates to:
  /// **'BPM data unavailable'**
  String get bpmUnavailable;

  /// Section title for BPM features
  ///
  /// In en, this message translates to:
  /// **'BPM Features'**
  String get advancedFeatures;

  /// Attribution for GetSongBPM API
  ///
  /// In en, this message translates to:
  /// **'Powered by GetSongBPM'**
  String get getSongBpmAttribution;

  /// Hint for GetSongBPM API
  ///
  /// In en, this message translates to:
  /// **'BPM data is provided by GetSongBPM.com. Register for a free API key to enable BPM matching features.'**
  String get getSongBpmHint;

  /// Label for GetSongBPM API key field
  ///
  /// In en, this message translates to:
  /// **'GetSongBPM API Key'**
  String get getSongBpmApiKey;

  /// Hint for GetSongBPM API key field
  ///
  /// In en, this message translates to:
  /// **'Enter your GetSongBPM API key'**
  String get getSongBpmApiKeyHint;

  /// Status when API key is configured
  ///
  /// In en, this message translates to:
  /// **'API key configured'**
  String get getSongBpmApiKeyConfigured;

  /// Toast when API key is saved
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully'**
  String get getSongBpmApiKeySaved;

  /// Toast when API key save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save API key'**
  String get getSongBpmApiKeyError;

  /// Error when API key is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter an API key'**
  String get getSongBpmApiKeyEmpty;

  /// Toast when API key is cleared
  ///
  /// In en, this message translates to:
  /// **'API key cleared'**
  String get getSongBpmApiKeyCleared;

  /// Experimental feature warning title
  ///
  /// In en, this message translates to:
  /// **'Experimental Feature'**
  String get experimentalFeature;

  /// Experimental feature warning message for smart schedule
  ///
  /// In en, this message translates to:
  /// **'This mode fetches BPM for all tracks which may take several minutes. The session will be created in the background - you can continue using the app.'**
  String get experimentalSmartScheduleWarning;

  /// Button to continue with experimental feature
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Background session creation notification title
  ///
  /// In en, this message translates to:
  /// **'Creating session in background...'**
  String get creatingSessionBackground;

  /// Progress message for fetching tracks
  ///
  /// In en, this message translates to:
  /// **'Fetching tracks from {count} artists...'**
  String fetchingTracksProgress(int count);

  /// Progress message showing which artist is being fetched
  ///
  /// In en, this message translates to:
  /// **'Fetching: {artistName}'**
  String fetchingArtistTracks(String artistName);

  /// Progress message for fetching BPM data
  ///
  /// In en, this message translates to:
  /// **'Analyzing BPM ({current}/{total})...'**
  String fetchingBpmProgress(int current, int total);

  /// Progress message for filtering tracks
  ///
  /// In en, this message translates to:
  /// **'Filtering tracks by BPM...'**
  String get filteringTracks;

  /// Session created in background notification
  ///
  /// In en, this message translates to:
  /// **'Session \"{name}\" created with {count} tracks'**
  String sessionCreatedBackground(String name, int count);

  /// Session creation failed notification
  ///
  /// In en, this message translates to:
  /// **'Failed to create session: {error}'**
  String sessionCreationFailed(String error);

  /// Pending session indicator
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get pendingSession;

  /// View pending sessions
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewPendingSession;

  /// Track limit toggle label
  ///
  /// In en, this message translates to:
  /// **'Track Limit'**
  String get trackLimit;

  /// Track limit enabled label
  ///
  /// In en, this message translates to:
  /// **'Limit to {count} tracks'**
  String trackLimitEnabled(int count);

  /// Track limit disabled label
  ///
  /// In en, this message translates to:
  /// **'No track limit'**
  String get trackLimitDisabled;

  /// Hint for track limit setting
  ///
  /// In en, this message translates to:
  /// **'Limit the number of tracks in smart schedule sessions'**
  String get trackLimitHint;

  /// BPM cache statistics
  ///
  /// In en, this message translates to:
  /// **'BPM Cache: {count} entries'**
  String bpmCacheStats(int count);

  /// Button to clear BPM cache
  ///
  /// In en, this message translates to:
  /// **'Clear BPM Cache'**
  String get clearBpmCache;

  /// Toast when BPM cache is cleared
  ///
  /// In en, this message translates to:
  /// **'BPM cache cleared'**
  String get bpmCacheCleared;

  /// System tray menu item to show main window
  ///
  /// In en, this message translates to:
  /// **'Show FullStop'**
  String get trayShowWindow;

  /// System tray menu item to exit app
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trayExit;

  /// System tray menu item for previous track
  ///
  /// In en, this message translates to:
  /// **'Previous Track'**
  String get trayPreviousTrack;

  /// System tray menu item for next track
  ///
  /// In en, this message translates to:
  /// **'Next Track'**
  String get trayNextTrack;

  /// System tray tooltip
  ///
  /// In en, this message translates to:
  /// **'FullStop - Spotify Focus Player'**
  String get trayTooltip;

  /// Error message when no active Spotify device is found
  ///
  /// In en, this message translates to:
  /// **'No active Spotify device found. Please open Spotify on your phone, computer, or other device first.'**
  String get errorNoActiveDevice;

  /// Error message when Spotify connection fails even after SDK wake attempt
  ///
  /// In en, this message translates to:
  /// **'FullStop cannot connect to Spotify. Please manually open Spotify and play any music, then try again.'**
  String get errorSpotifyConnectionFailed;

  /// Status message when trying to connect to Spotify device
  ///
  /// In en, this message translates to:
  /// **'Connecting to Spotify...'**
  String get connectingToSpotifyDevice;

  /// Error message when Spotify app is not installed
  ///
  /// In en, this message translates to:
  /// **'Spotify app not detected'**
  String get spotifyNotInstalled;

  /// Traditional scheduling feature toggle
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get traditionalSchedule;

  /// Dispatch mode - hits only
  ///
  /// In en, this message translates to:
  /// **'Hits Only'**
  String get dispatchHitsOnly;

  /// Description for hits only mode
  ///
  /// In en, this message translates to:
  /// **'No skips needed. Every track\'s a banger.'**
  String get dispatchHitsOnlyDesc;

  /// Dispatch mode - balanced
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get dispatchBalanced;

  /// Description for balanced mode
  ///
  /// In en, this message translates to:
  /// **'Familiar favorites with pleasant surprises.'**
  String get dispatchBalancedDesc;

  /// Dispatch mode - deep dive
  ///
  /// In en, this message translates to:
  /// **'Deep Dive'**
  String get dispatchDeepDive;

  /// Description for deep dive mode
  ///
  /// In en, this message translates to:
  /// **'Hunt for that forgotten B-side gem.'**
  String get dispatchDeepDiveDesc;

  /// Dispatch mode - unfiltered
  ///
  /// In en, this message translates to:
  /// **'Unfiltered'**
  String get dispatchUnfiltered;

  /// Description for unfiltered mode
  ///
  /// In en, this message translates to:
  /// **'Relive the concert. Feel every encore.'**
  String get dispatchUnfilteredDesc;

  /// True shuffle feature toggle
  ///
  /// In en, this message translates to:
  /// **'True Shuffle'**
  String get trueShuffle;

  /// Description for true shuffle feature
  ///
  /// In en, this message translates to:
  /// **'Smart dedupe & album spread'**
  String get trueShuffleDesc;

  /// Toast message when artist limit is reached
  ///
  /// In en, this message translates to:
  /// **'Artist limit reached'**
  String get artistLimitReached;

  /// Hint explaining the artist limit
  ///
  /// In en, this message translates to:
  /// **'For best focus experience and dedupe quality, limit to {count} artists.'**
  String artistLimitHint(int count);

  /// Artist counter showing current/max
  ///
  /// In en, this message translates to:
  /// **'Selected ({current}/{max})'**
  String selectedArtistsCount(int current, int max);

  /// Hint text for expanding bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get tapToExpand;

  /// Cache management section title
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cacheManagement;

  /// Image cache size label
  ///
  /// In en, this message translates to:
  /// **'Image Cache'**
  String get imageCacheSize;

  /// Clear cache button text
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Toast message when cache is cleared
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// Toast message when cache clear fails
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache'**
  String get cacheClearFailed;

  /// Text shown while calculating cache size
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// Rename option in menu
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Dialog title for renaming session
  ///
  /// In en, this message translates to:
  /// **'Rename Session'**
  String get renameSession;

  /// Toast when session is renamed
  ///
  /// In en, this message translates to:
  /// **'Session renamed'**
  String get sessionRenamed;

  /// Option to like all tracks in session
  ///
  /// In en, this message translates to:
  /// **'Like All Tracks'**
  String get likeAllTracks;

  /// Confirmation for liking all tracks
  ///
  /// In en, this message translates to:
  /// **'Add {count} tracks to your Liked Songs?'**
  String likeAllTracksConfirm(int count);

  /// Message when all tracks are already liked
  ///
  /// In en, this message translates to:
  /// **'All tracks are already liked'**
  String get tracksAlreadyLiked;

  /// Success message for liking tracks
  ///
  /// In en, this message translates to:
  /// **'{count} tracks added to Liked Songs'**
  String tracksLiked(int count);

  /// Option to add tracks to a playlist
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// Option to create a new Spotify playlist from session tracks
  ///
  /// In en, this message translates to:
  /// **'Create Playlist from This'**
  String get createPlaylistFromSession;

  /// Confirmation for creating playlist
  ///
  /// In en, this message translates to:
  /// **'Create a Spotify playlist \"{name}\" with {count} tracks?'**
  String createPlaylistConfirm(String name, int count);

  /// Success message for playlist creation
  ///
  /// In en, this message translates to:
  /// **'Playlist \"{name}\" created'**
  String playlistCreated(String name);

  /// Error message for playlist creation failure
  ///
  /// In en, this message translates to:
  /// **'Failed to create playlist'**
  String get playlistCreationFailed;

  /// Loading message when checking liked status
  ///
  /// In en, this message translates to:
  /// **'Checking liked status...'**
  String get checkingLikedStatus;

  /// Loading message when liking tracks
  ///
  /// In en, this message translates to:
  /// **'Liking tracks...'**
  String get likingTracks;

  /// Loading message when creating playlist
  ///
  /// In en, this message translates to:
  /// **'Creating playlist...'**
  String get creatingPlaylist;

  /// Menu option to move session up in list
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUp;

  /// Menu option to move session down in list
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDown;

  /// Tooltip for always on top button when unpinned
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get pinToTop;

  /// Tooltip for always on top button when pinned
  ///
  /// In en, this message translates to:
  /// **'Unpin from top'**
  String get unpinFromTop;

  /// Last played time label
  ///
  /// In en, this message translates to:
  /// **'Last played: {time}'**
  String lastPlayed(String time);

  /// Header for overflow artists popup
  ///
  /// In en, this message translates to:
  /// **'More Artists'**
  String get moreArtists;

  /// Expand button text
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// Collapse button text
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// Performance settings section title
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// GPU acceleration toggle label
  ///
  /// In en, this message translates to:
  /// **'GPU Acceleration'**
  String get gpuAcceleration;

  /// GPU acceleration description
  ///
  /// In en, this message translates to:
  /// **'Use GPU for smoother animations'**
  String get gpuAccelerationDesc;

  /// GPU acceleration hint text
  ///
  /// In en, this message translates to:
  /// **'Enable GPU acceleration for smoother wave animations. Disable if you experience graphics issues or don\'t have a dedicated GPU.'**
  String get gpuAccelerationHint;

  /// Menu option to pin a session to the top of the list
  ///
  /// In en, this message translates to:
  /// **'Pin to Top'**
  String get pinSession;

  /// Menu option to unpin a session
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinSession;

  /// Hint text explaining the pin limit
  ///
  /// In en, this message translates to:
  /// **'Max 3 pinned sessions'**
  String get pinSessionHint;

  /// Toast message when session is pinned
  ///
  /// In en, this message translates to:
  /// **'Session pinned'**
  String get sessionPinned;

  /// Toast message when session is unpinned
  ///
  /// In en, this message translates to:
  /// **'Session unpinned'**
  String get sessionUnpinned;

  /// Version label in about section
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// Privacy and security section title
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get aboutPrivacySecurity;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// GitHub link label
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutGitHub;

  /// GitHub star hint
  ///
  /// In en, this message translates to:
  /// **'Star the project'**
  String get aboutStarProject;

  /// Twitter/X link label
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get aboutTwitter;

  /// Twitter follow hint
  ///
  /// In en, this message translates to:
  /// **'Follow for updates'**
  String get aboutFollowUpdates;

  /// Spotify attribution
  ///
  /// In en, this message translates to:
  /// **'Powered by Spotify'**
  String get aboutPoweredBySpotify;

  /// Spotify API attribution hint
  ///
  /// In en, this message translates to:
  /// **'Uses Spotify Web API'**
  String get aboutUsesSpotifyApi;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Secure Local Storage'**
  String get privacySecureStorage;

  /// Privacy section description
  ///
  /// In en, this message translates to:
  /// **'Your API credentials are encrypted and stored only on your device. They are never transmitted to any external server.'**
  String get privacySecureStorageDesc;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Direct Spotify Connection'**
  String get privacyDirectConnection;

  /// Privacy section description
  ///
  /// In en, this message translates to:
  /// **'This app connects directly to Spotify\'s official API. We don\'t relay your data through any intermediary servers.'**
  String get privacyDirectConnectionDesc;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'No Data Collection'**
  String get privacyNoDataCollection;

  /// Privacy section description
  ///
  /// In en, this message translates to:
  /// **'We do not collect, store, or transmit any usage analytics, listening history, or personal information.'**
  String get privacyNoDataCollectionDesc;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'You Control Your Data'**
  String get privacyYouControl;

  /// Privacy section description
  ///
  /// In en, this message translates to:
  /// **'You can clear your credentials at any time from this settings page. Uninstalling the app removes all stored data.'**
  String get privacyYouControlDesc;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for redirect URI info
  ///
  /// In en, this message translates to:
  /// **'Redirect URI for Spotify App'**
  String get redirectUriForSpotifyApp;

  /// Spotify API settings title
  ///
  /// In en, this message translates to:
  /// **'Spotify API'**
  String get spotifyApi;

  /// Status when API is configured
  ///
  /// In en, this message translates to:
  /// **'Configured ({clientId})'**
  String configured(String clientId);

  /// LLM section title
  ///
  /// In en, this message translates to:
  /// **'OpenAI-Compatible API'**
  String get llmOpenAiCompatible;

  /// LLM section description
  ///
  /// In en, this message translates to:
  /// **'Works with OpenAI, Ollama, and other OpenAI-compatible APIs.\nAPI Key is optional for local models like Ollama.'**
  String get llmOpenAiCompatibleDesc;

  /// Toggle for AI features
  ///
  /// In en, this message translates to:
  /// **'Enable AI Features'**
  String get enableAiFeatures;

  /// AI features subtitle
  ///
  /// In en, this message translates to:
  /// **'Smart playlist curation with LLM'**
  String get smartPlaylistCuration;

  /// LLM base URL field label
  ///
  /// In en, this message translates to:
  /// **'Base URL *'**
  String get llmBaseUrl;

  /// LLM base URL hint
  ///
  /// In en, this message translates to:
  /// **'https://api.openai.com/v1'**
  String get llmBaseUrlHint;

  /// LLM base URL helper text
  ///
  /// In en, this message translates to:
  /// **'/chat/completions will be added automatically'**
  String get llmBaseUrlHelper;

  /// LLM model field label
  ///
  /// In en, this message translates to:
  /// **'Model *'**
  String get llmModel;

  /// LLM model hint
  ///
  /// In en, this message translates to:
  /// **'gpt-4'**
  String get llmModelHint;

  /// LLM model helper text
  ///
  /// In en, this message translates to:
  /// **'e.g., gpt-4o-mini, llama3, qwen2, gemini-pro'**
  String get llmModelHelper;

  /// LLM API key field label
  ///
  /// In en, this message translates to:
  /// **'API Key (Optional)'**
  String get llmApiKey;

  /// LLM API key hint
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get llmApiKeyHint;

  /// LLM API key helper text
  ///
  /// In en, this message translates to:
  /// **'Leave empty for local models like Ollama'**
  String get llmApiKeyHelper;

  /// Test button text
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// LLM examples title
  ///
  /// In en, this message translates to:
  /// **'Examples:'**
  String get llmExamples;

  /// LLM configured status
  ///
  /// In en, this message translates to:
  /// **'LLM configured: {model}'**
  String llmConfigured(String model);

  /// Toast when LLM config is saved
  ///
  /// In en, this message translates to:
  /// **'LLM configuration saved'**
  String get llmConfigSaved;

  /// Toast when LLM config save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save configuration'**
  String get llmConfigSaveFailed;

  /// Validation error for LLM config
  ///
  /// In en, this message translates to:
  /// **'Base URL and Model are required'**
  String get llmBaseUrlModelRequired;

  /// Testing connection message
  ///
  /// In en, this message translates to:
  /// **'Testing: {url}'**
  String llmTesting(String url);

  /// Test success message
  ///
  /// In en, this message translates to:
  /// **'Success! Response: {response}...'**
  String llmTestSuccess(String response);

  /// Request label in error dialog
  ///
  /// In en, this message translates to:
  /// **'Request:'**
  String get request;

  /// LLM 404 error message
  ///
  /// In en, this message translates to:
  /// **'Error 404: Endpoint not found. Please check if the API Endpoint URL is correct'**
  String get llmError404;

  /// LLM 401 error message
  ///
  /// In en, this message translates to:
  /// **'Error 401: Invalid API key or unauthorized access'**
  String get llmError401;

  /// LLM 403 error message
  ///
  /// In en, this message translates to:
  /// **'Error 403: Access forbidden. Check your API key permissions'**
  String get llmError403;

  /// LLM 429 error message
  ///
  /// In en, this message translates to:
  /// **'Error 429: Rate limit exceeded. Please wait and try again'**
  String get llmError429;

  /// LLM server error message
  ///
  /// In en, this message translates to:
  /// **'Server error: The API server is temporarily unavailable'**
  String get llmErrorServer;

  /// LLM timeout error message
  ///
  /// In en, this message translates to:
  /// **'Connection timeout: Server took too long to respond'**
  String get llmErrorTimeout;

  /// LLM connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection failed: Check your network and proxy settings'**
  String get llmErrorConnection;

  /// Tooltip for mini player mode button
  ///
  /// In en, this message translates to:
  /// **'Mini Player'**
  String get miniPlayer;

  /// Tooltip for exiting mini player mode
  ///
  /// In en, this message translates to:
  /// **'Exit Mini Player'**
  String get exitMiniPlayer;

  /// Advanced options section title
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptions;

  /// Custom Spotify Client ID field label
  ///
  /// In en, this message translates to:
  /// **'Custom Client ID'**
  String get customClientId;

  /// Description explaining why custom Client ID may be needed
  ///
  /// In en, this message translates to:
  /// **'The shared Client ID may be rate-limited by Spotify under heavy usage. You can create your own app on Spotify Developer Dashboard and use your own Client ID.'**
  String get customClientIdDescription;

  /// Hint for custom Client ID input
  ///
  /// In en, this message translates to:
  /// **'Enter your Spotify Client ID'**
  String get customClientIdHint;

  /// Toast when custom Client ID is saved
  ///
  /// In en, this message translates to:
  /// **'Custom Client ID saved'**
  String get customClientIdSaved;

  /// Toast when custom Client ID is cleared
  ///
  /// In en, this message translates to:
  /// **'Restored to default Client ID'**
  String get customClientIdCleared;

  /// Button to clear custom Client ID and use default
  ///
  /// In en, this message translates to:
  /// **'Use Default'**
  String get useDefaultClient;

  /// Dialog message when Client ID changes requiring re-authentication
  ///
  /// In en, this message translates to:
  /// **'Switching Client ID requires re-login. Log out now?'**
  String get customClientIdReauthRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
