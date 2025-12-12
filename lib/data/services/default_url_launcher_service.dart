import 'package:url_launcher/url_launcher.dart';
import '../../core/services/url_launcher_service.dart';

/// Implementation of UrlLauncherService using url_launcher package
class DefaultUrlLauncherService implements UrlLauncherService {
  @override
  Future<bool> launchInBrowser(Uri url) async {
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
