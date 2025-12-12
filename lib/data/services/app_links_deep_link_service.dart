import 'dart:async';
import 'package:app_links/app_links.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/utils/logger.dart';

/// Implementation of DeepLinkService using app_links package
///
/// This service should be initialized early in the app lifecycle to ensure
/// no deep links are missed. It uses a broadcast stream to allow multiple
/// listeners to subscribe and unsubscribe without losing events.
class AppLinksDeepLinkService implements DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final StreamController<Uri> _streamController =
      StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _appLinksSubscription;

  AppLinksDeepLinkService() {
    _initialize();
  }

  void _initialize() {
    AppLogger.info('DeepLinkService: Initializing and subscribing to AppLinks');

    // Subscribe to the AppLinks stream immediately
    _appLinksSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        AppLogger.info('DeepLinkService: Received URI: $uri');
        if (!_streamController.isClosed) {
          _streamController.add(uri);
        }
      },
      onError: (dynamic error) {
        AppLogger.error('DeepLinkService: Stream error', error);
        if (!_streamController.isClosed) {
          _streamController.addError(error as Object);
        }
      },
    );

    AppLogger.info('DeepLinkService: Subscription established');

    // Also check for initial link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        AppLogger.info('DeepLinkService: Initial link found: $uri');
      }
    });
  }

  @override
  Stream<Uri> get uriStream => _streamController.stream;

  @override
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();

  void dispose() {
    AppLogger.info('DeepLinkService: Disposing');
    _appLinksSubscription?.cancel();
    _appLinksSubscription = null;
    _streamController.close();
  }
}
