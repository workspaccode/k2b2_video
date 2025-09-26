import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ShorebirdUpdateService {
  static const MethodChannel _channel = MethodChannel('shorebird/update');

  /// Check if there's an update available
  static Future<bool> isUpdateAvailable() async {
    if (kDebugMode) {
      // Don't check for updates in debug mode
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod('isUpdateAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return false;
    }
  }

  /// Download and install available update
  static Future<bool> downloadAndInstallUpdate() async {
    if (kDebugMode) {
      return false;
    }

    try {
      final bool? result = await _channel.invokeMethod(
        'downloadAndInstallUpdate',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error downloading/installing update: $e');
      return false;
    }
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getCurrentVersion');
      return version ?? 'Unknown';
    } catch (e) {
      debugPrint('Error getting current version: $e');
      return 'Unknown';
    }
  }

  /// Check for updates periodically
  static Future<void> checkForUpdatesInBackground() async {
    if (kDebugMode) return;

    try {
      final bool updateAvailable = await isUpdateAvailable();
      if (updateAvailable) {
        debugPrint('Update available! Consider showing user notification.');
        // You can implement user notification logic here
      }
    } catch (e) {
      debugPrint('Background update check failed: $e');
    }
  }

  /// Initialize update checking with periodic checks
  static void initializeUpdateChecking() {
    if (kDebugMode) return;

    // Check for updates immediately
    checkForUpdatesInBackground();

    // Schedule periodic checks (every hour)
    // You would typically use a background service or timer for this
    // This is a simplified example
  }
}
