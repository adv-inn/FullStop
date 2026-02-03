import 'package:flutter/material.dart';
import 'package:fullstop/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_theme.dart';

/// GitHub icon using official SVG path
class _GitHubIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _GitHubIcon({this.size = 24, this.color = AppTheme.spotifyWhite});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GitHubIconPainter(color: color)),
    );
  }
}

class _GitHubIconPainter extends CustomPainter {
  final Color color;

  _GitHubIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Original viewBox: 98x96
    const originalWidth = 98.0;
    const originalHeight = 96.0;

    final scale = size.width / originalWidth;
    final offsetY = (size.height - originalHeight * scale) / 2;

    canvas.save();
    canvas.translate(0, offsetY);
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // GitHub Octocat path
    path.moveTo(48.854, 0);
    path.cubicTo(21.839, 0, 0, 22, 0, 49.217);
    path.cubicTo(0, 70.973, 13.993, 89.389, 33.405, 95.907);
    path.cubicTo(35.832, 96.397, 36.721, 94.848, 36.721, 93.545);
    path.cubicTo(36.721, 92.404, 36.641, 88.493, 36.641, 84.418);
    path.cubicTo(23.051, 87.352, 20.221, 78.551, 20.221, 78.551);
    path.cubicTo(18.037, 72.847, 14.801, 71.381, 14.801, 71.381);
    path.cubicTo(10.353, 68.366, 15.125, 68.366, 15.125, 68.366);
    path.cubicTo(20.059, 68.692, 22.648, 73.418, 22.648, 73.418);
    path.cubicTo(27.015, 80.914, 34.052, 78.796, 36.883, 77.492);
    path.cubicTo(37.287, 74.314, 38.582, 72.114, 39.957, 70.892);
    path.cubicTo(29.118, 69.751, 17.714, 65.514, 17.714, 46.609);
    path.cubicTo(17.714, 41.231, 19.654, 36.831, 22.728, 33.409);
    path.cubicTo(22.243, 32.187, 20.544, 27.134, 23.214, 20.371);
    path.cubicTo(23.214, 20.371, 27.339, 19.067, 36.64, 25.423);
    path.cubicTo(40.553, 24.311, 44.714, 23.793, 48.854, 23.793);
    path.cubicTo(52.979, 23.793, 57.184, 24.364, 61.067, 25.423);
    path.cubicTo(70.369, 19.067, 74.494, 20.371, 74.494, 20.371);
    path.cubicTo(77.164, 27.134, 75.464, 32.187, 74.979, 33.409);
    path.cubicTo(78.134, 36.831, 79.994, 41.231, 79.994, 46.609);
    path.cubicTo(79.994, 65.514, 68.59, 69.669, 57.67, 70.892);
    path.cubicTo(59.45, 72.44, 60.986, 75.373, 60.986, 80.018);
    path.cubicTo(60.986, 86.618, 60.906, 91.915, 60.906, 93.544);
    path.cubicTo(60.906, 94.848, 61.796, 96.397, 64.222, 95.908);
    path.cubicTo(83.634, 89.388, 97.627, 70.973, 97.627, 49.217);
    path.cubicTo(97.707, 22, 75.788, 0, 48.854, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// X (Twitter) icon using official SVG path
class _XIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _XIcon({this.size = 24, this.color = AppTheme.spotifyWhite});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _XIconPainter(color: color)),
    );
  }
}

class _XIconPainter extends CustomPainter {
  final Color color;

  _XIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Original viewBox: 1200x1227
    const originalWidth = 1200.0;
    const originalHeight = 1227.0;

    final scaleX = size.width / originalWidth;
    final scaleY = size.height / originalHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - originalWidth * scale) / 2;
    final offsetY = (size.height - originalHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // X logo path
    path.moveTo(714.163, 519.284);
    path.lineTo(1160.89, 0);
    path.lineTo(1055.03, 0);
    path.lineTo(667.137, 450.887);
    path.lineTo(357.328, 0);
    path.lineTo(0, 0);
    path.lineTo(468.492, 681.821);
    path.lineTo(0, 1226.37);
    path.lineTo(105.866, 1226.37);
    path.lineTo(515.491, 750.218);
    path.lineTo(842.672, 1226.37);
    path.lineTo(1200, 1226.37);
    path.lineTo(714.137, 519.284);
    path.lineTo(714.163, 519.284);
    path.close();

    path.moveTo(569.165, 687.828);
    path.lineTo(521.697, 619.934);
    path.lineTo(144.011, 79.6944);
    path.lineTo(306.615, 79.6944);
    path.lineTo(611.412, 515.685);
    path.lineTo(658.88, 583.579);
    path.lineTo(1055.08, 1150.3);
    path.lineTo(892.476, 1150.3);
    path.lineTo(569.165, 687.854);
    path.lineTo(569.165, 687.828);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spotify icon using official SVG path
class _SpotifyIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _SpotifyIcon({this.size = 24, this.color = AppTheme.spotifyBlack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SpotifyIconPainter(color: color)),
    );
  }
}

class _SpotifyIconPainter extends CustomPainter {
  final Color color;

  _SpotifyIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Original viewBox: 24x24
    const originalSize = 24.0;

    final scale = size.width / originalSize;

    canvas.save();
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Spotify logo path
    path.moveTo(12, 0);
    path.cubicTo(5.4, 0, 0, 5.4, 0, 12);
    path.cubicTo(0, 18.6, 5.4, 24, 12, 24);
    path.cubicTo(18.6, 24, 24, 18.6, 24, 12);
    path.cubicTo(24, 5.4, 18.66, 0, 12, 0);

    // First wave (top)
    path.moveTo(17.521, 17.34);
    path.cubicTo(17.281, 17.699, 16.861, 17.82, 16.5, 17.58);
    path.cubicTo(13.68, 15.84, 10.14, 15.479, 5.939, 16.439);
    path.cubicTo(5.521, 16.561, 5.16, 16.26, 5.04, 15.9);
    path.cubicTo(4.92, 15.479, 5.22, 15.12, 5.58, 15);
    path.cubicTo(10.14, 13.979, 14.1, 14.4, 17.22, 16.32);
    path.cubicTo(17.64, 16.5, 17.699, 16.979, 17.521, 17.34);

    // Second wave (middle)
    path.moveTo(18.961, 14.04);
    path.cubicTo(18.66, 14.46, 18.12, 14.64, 17.699, 14.34);
    path.cubicTo(14.46, 12.36, 9.54, 11.76, 5.76, 12.96);
    path.cubicTo(5.281, 13.08, 4.74, 12.84, 4.62, 12.36);
    path.cubicTo(4.5, 11.88, 4.74, 11.339, 5.22, 11.219);
    path.cubicTo(9.6, 9.9, 15, 10.561, 18.72, 12.84);
    path.cubicTo(19.081, 13.021, 19.26, 13.62, 18.961, 14.04);

    // Third wave (bottom)
    path.moveTo(19.081, 10.68);
    path.cubicTo(15.24, 8.4, 8.82, 8.16, 5.16, 9.301);
    path.cubicTo(4.56, 9.48, 3.96, 9.12, 3.78, 8.58);
    path.cubicTo(3.6, 7.979, 3.96, 7.38, 4.5, 7.199);
    path.cubicTo(8.76, 5.939, 15.78, 6.179, 20.221, 8.82);
    path.cubicTo(20.76, 9.12, 20.94, 9.84, 20.64, 10.38);
    path.cubicTo(20.341, 10.801, 19.62, 10.979, 19.081, 10.68);

    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.data?.version ?? '';
            final buildNumber = snapshot.data?.buildNumber ?? '';
            final display = buildNumber.isNotEmpty
                ? '$version+$buildNumber'
                : version;
            return ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutVersion),
              subtitle: Text(display),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.aboutPrivacySecurity),
          onTap: () => _showPrivacyPolicy(context),
        ),
        const Divider(indent: 16, endIndent: 16),
        // Developer contact
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.code,
              color: AppTheme.spotifyWhite,
              size: 20,
            ),
          ),
          title: Text(l10n.aboutDeveloper),
          subtitle: const Text('@0chencc'),
        ),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: _GitHubIcon(size: 24)),
          ),
          title: Text(l10n.aboutGitHub),
          subtitle: Text(l10n.aboutStarProject),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _launchUrl('https://github.com/0chencc/FullStop'),
        ),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: _XIcon(size: 18)),
          ),
          title: Text(l10n.aboutTwitter),
          subtitle: Text(l10n.aboutFollowUpdates),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () => _launchUrl('https://x.com/0chencc'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        title: Text(l10n.aboutPrivacySecurity),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrivacySection(
                l10n.privacySecureStorage,
                l10n.privacySecureStorageDesc,
              ),
              _buildPrivacySection(
                l10n.privacyDirectConnection,
                l10n.privacyDirectConnectionDesc,
              ),
              _buildPrivacySection(
                l10n.privacyNoDataCollection,
                l10n.privacyNoDataCollectionDesc,
              ),
              _buildPrivacySection(
                l10n.privacyOAuthSecurity,
                l10n.privacyOAuthSecurityDesc,
              ),
              _buildPrivacySection(
                l10n.privacyYouControl,
                l10n.privacyYouControlDesc,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.spotifyGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.spotifyLightGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class CreditsSection extends StatelessWidget {
  const CreditsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.spotifyGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: _SpotifyIcon(size: 24)),
          ),
          title: Text(l10n.aboutPoweredBySpotify),
          subtitle: Text(l10n.aboutUsesSpotifyApi),
          onTap: () => _launchUrl('https://developer.spotify.com'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
