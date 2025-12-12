import 'dart:async';

/// Abstract interface for deep link handling
/// This decouples the authentication logic from the platform-specific deep link implementation
abstract class DeepLinkService {
  /// Stream of incoming deep link URIs
  Stream<Uri> get uriStream;

  /// Get the initial URI that launched the app (if any)
  Future<Uri?> getInitialUri();
}
