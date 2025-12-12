/// Abstract interface for URL launching
/// This decouples the authentication logic from the platform-specific URL launcher
abstract class UrlLauncherService {
  /// Launch a URL in external browser
  /// Returns true if successful, false otherwise
  Future<bool> launchInBrowser(Uri url);
}
