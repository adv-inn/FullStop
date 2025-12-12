import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'application/di/injection_container.dart';
import 'core/utils/logger.dart';
import 'core/utils/url_protocol_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  try {
    await Hive.initFlutter();
    AppLogger.info('Hive initialized successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize Hive: $e');
  }

  // Initialize window manager for Windows (custom title bar)
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(420, 800),
      minimumSize: Size(380, 600),
      maximumSize: Size(800, 1200),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'FullStop',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // Prevent sub-pixel size adjustments by explicitly setting size after show
      await windowManager.setSize(const Size(420, 800));
    });

    // Register URL protocol on Windows
    final isRegistered = await UrlProtocolHandler.isProtocolRegistered();
    if (!isRegistered) {
      AppLogger.info('Registering fullstop:// URL protocol...');
      await UrlProtocolHandler.registerProtocol();
    }
  }

  // Create the ProviderContainer to pre-initialize critical services
  final container = ProviderContainer();

  // Pre-initialize the DeepLinkService to start listening early
  container.read(deepLinkServiceProvider);
  AppLogger.info('DeepLinkService pre-initialized');

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SpotifyFocusSomeoneApp(),
    ),
  );
}
