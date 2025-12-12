import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Shows a loading dialog with a message
/// Returns the dialog context for closing later
Future<void> showLoadingDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: AppTheme.spotifyDarkGray,
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppTheme.spotifyGreen),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.spotifyWhite),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows a confirmation dialog with customizable actions
/// Returns true if confirmed, false if cancelled
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.spotifyDarkGray,
      title: Text(title, style: const TextStyle(color: AppTheme.spotifyWhite)),
      content: Text(
        message,
        style: TextStyle(color: AppTheme.spotifyWhite.withOpacity(0.8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText ?? 'Cancel',
            style: const TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText ?? 'Confirm',
            style: TextStyle(
              color:
                  confirmColor ??
                  (isDestructive ? Colors.red : AppTheme.spotifyGreen),
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows an error dialog with an optional retry action
Future<bool> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? retryText,
  bool showRetry = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.spotifyDarkGray,
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppTheme.spotifyWhite),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(color: AppTheme.spotifyWhite.withOpacity(0.8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'OK',
            style: TextStyle(color: AppTheme.spotifyLightGray),
          ),
        ),
        if (showRetry)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              retryText ?? 'Retry',
              style: const TextStyle(color: AppTheme.spotifyGreen),
            ),
          ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a snackbar with an optional action
///
/// Note: In Material 3, SnackBars with actions have indefinite duration by default.
/// We work around this by manually hiding the snackbar after the specified duration.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  // Clear any existing snackbars first
  scaffoldMessenger.clearSnackBars();

  // Store callback for later use (avoid closure issues)
  final callback = onAction;
  final hasAction = actionLabel != null && callback != null;

  // Create the snackbar
  final snackBar = SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.white)),
    backgroundColor: isError ? Colors.red.shade700 : AppTheme.spotifyDarkGray,
    // Set duration - this should work but Material 3 may override it for SnackBars with actions
    duration: duration,
    dismissDirection: DismissDirection.horizontal,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    // Always show close icon for better UX
    showCloseIcon: true,
    closeIconColor: Colors.white70,
    action: hasAction
        ? SnackBarAction(
            label: actionLabel,
            textColor: AppTheme.spotifyGreen,
            onPressed: () {
              callback();
            },
          )
        : null,
  );

  scaffoldMessenger.showSnackBar(snackBar);

  // Workaround: For SnackBars with actions, Material 3 may ignore duration
  // So we manually hide it after the specified duration
  if (hasAction) {
    Future.delayed(duration, () {
      scaffoldMessenger.hideCurrentSnackBar(
        reason: SnackBarClosedReason.timeout,
      );
    });
  }
}
