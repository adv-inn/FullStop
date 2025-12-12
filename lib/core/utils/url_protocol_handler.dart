import 'dart:io';
import 'logger.dart';

/// Utility class for registering custom URL protocol on Windows
class UrlProtocolHandler {
  static const String _urlScheme = 'fullstop';

  /// Check if the URL protocol is registered with the current executable
  static Future<bool> isProtocolRegistered() async {
    if (!Platform.isWindows) return true;

    try {
      final result = await Process.run('reg', [
        'query',
        'HKEY_CURRENT_USER\\Software\\Classes\\$_urlScheme\\shell\\open\\command',
        '/ve',
      ]);

      if (result.exitCode != 0) {
        return false;
      }

      // Check if the registered path matches current executable
      final output = result.stdout as String;
      final currentExe = Platform.resolvedExecutable;

      // The registry value contains the path in quotes
      if (output.contains(currentExe)) {
        AppLogger.info('URL protocol is correctly registered for: $currentExe');
        return true;
      } else {
        AppLogger.warning(
          'URL protocol registered but for different executable',
        );
        AppLogger.warning('Registry output: $output');
        AppLogger.warning('Current exe: $currentExe');
        return false;
      }
    } catch (e) {
      AppLogger.warning('Failed to check protocol registration: $e');
      return false;
    }
  }

  /// Register the URL protocol in Windows registry
  static Future<bool> registerProtocol() async {
    if (!Platform.isWindows) return true;

    try {
      final exePath = Platform.resolvedExecutable;
      AppLogger.info('Registering URL protocol for: $exePath');

      // Create protocol key
      await _runReg([
        'add',
        'HKEY_CURRENT_USER\\Software\\Classes\\$_urlScheme',
        '/ve',
        '/d',
        'URL:FullStop Protocol',
        '/f',
      ]);

      // Set URL Protocol flag
      await _runReg([
        'add',
        'HKEY_CURRENT_USER\\Software\\Classes\\$_urlScheme',
        '/v',
        'URL Protocol',
        '/d',
        '',
        '/f',
      ]);

      // Create DefaultIcon key
      await _runReg([
        'add',
        'HKEY_CURRENT_USER\\Software\\Classes\\$_urlScheme\\DefaultIcon',
        '/ve',
        '/d',
        '"$exePath",0',
        '/f',
      ]);

      // Create shell\open\command key
      await _runReg([
        'add',
        'HKEY_CURRENT_USER\\Software\\Classes\\$_urlScheme\\shell\\open\\command',
        '/ve',
        '/d',
        '"$exePath" "%1"',
        '/f',
      ]);

      AppLogger.info('URL protocol registered successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to register URL protocol', e);
      return false;
    }
  }

  static Future<ProcessResult> _runReg(List<String> args) async {
    final result = await Process.run('reg', args);
    if (result.exitCode != 0) {
      throw Exception('reg command failed: ${result.stderr}');
    }
    return result;
  }
}
