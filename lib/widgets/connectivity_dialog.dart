import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../services/connectivity_service.dart';

class ConnectivityDialog extends StatelessWidget {
  final ConnectivityStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;

  const ConnectivityDialog({
    super.key,
    required this.status,
    this.onRetry,
    this.onOfflineMode,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        height: _getDialogHeight(),
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0F).withValues(alpha: 0.9),
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  double _getDialogHeight() {
    switch (status) {
      case ConnectivityStatus.offline:
        return 320;
      case ConnectivityStatus.slow:
      case ConnectivityStatus.unstable:
        return 280;
      case ConnectivityStatus.online:
        return 240;
      case ConnectivityStatus.connecting:
        return 260;
    }
  }

  Widget _buildStatusIcon() {
    final connectivityService = ConnectivityService();
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            connectivityService.getStatusColor(status),
            connectivityService.getStatusColor(status).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: connectivityService
                .getStatusColor(status)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        connectivityService.getStatusIcon(status),
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    String title;
    switch (status) {
      case ConnectivityStatus.offline:
        title = 'No Internet Connection';
        break;
      case ConnectivityStatus.slow:
        title = 'Slow Connection Detected';
        break;
      case ConnectivityStatus.unstable:
        title = 'Unstable Connection';
        break;
      case ConnectivityStatus.online:
        title = 'Connection Restored';
        break;
      case ConnectivityStatus.connecting:
        title = 'Connecting...';
        break;
    }

    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    String description;
    switch (status) {
      case ConnectivityStatus.offline:
        description =
            'Please check your internet connection and try again. You can also browse downloaded content offline.';
        break;
      case ConnectivityStatus.slow:
        description =
            'Your connection is slow. Video streaming may be affected. Consider switching to lower quality or downloading for later.';
        break;
      case ConnectivityStatus.unstable:
        description =
            'Your connection is unstable. You may experience buffering during video playback.';
        break;
      case ConnectivityStatus.online:
        description =
            'Your internet connection has been restored. You can now enjoy high-quality streaming.';
        break;
      case ConnectivityStatus.connecting:
        description =
            'Establishing connection to the internet. Please wait a moment...';
        break;
    }

    return Text(
      description,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 14,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (status) {
      case ConnectivityStatus.offline:
        return Column(
          children: [
            _buildPrimaryButton('Retry Connection', Icons.refresh, () {
              Navigator.of(context).pop();
              onRetry?.call();
            }),
            const SizedBox(height: 12),
            _buildSecondaryButton('Browse Offline', IconlyBold.download, () {
              Navigator.of(context).pop();
              onOfflineMode?.call();
            }),
          ],
        );

      case ConnectivityStatus.slow:
      case ConnectivityStatus.unstable:
        return Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                'Continue',
                IconlyBold.arrow_right_2,
                () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPrimaryButton('Retry', Icons.refresh, () {
                Navigator.of(context).pop();
                onRetry?.call();
              }),
            ),
          ],
        );

      case ConnectivityStatus.online:
        return _buildPrimaryButton(
          'Great!',
          IconlyBold.tick_square,
          () => Navigator.of(context).pop(),
        );

      case ConnectivityStatus.connecting:
        return _buildSecondaryButton(
          'Please Wait...',
          Icons.hourglass_empty,
          () {}, // Disabled action while connecting
        );
    }
  }

  Widget _buildPrimaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context,
    ConnectivityStatus status, {
    VoidCallback? onRetry,
    VoidCallback? onOfflineMode,
  }) {
    showDialog(
      context: context,
      barrierDismissible: status != ConnectivityStatus.offline,
      builder: (context) => ConnectivityDialog(
        status: status,
        onRetry: onRetry,
        onOfflineMode: onOfflineMode,
      ),
    );
  }
}
