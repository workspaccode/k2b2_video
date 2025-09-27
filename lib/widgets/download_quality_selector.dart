import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../models/download_models.dart';
import '../models/video_model.dart';

class DownloadQualitySelector extends StatelessWidget {
  final VideoModel video;
  final Function(DownloadQuality) onQualitySelected;

  const DownloadQualitySelector({
    super.key,
    required this.video,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      IconlyBold.download,
                      color: Color(0xFF6C5CE7),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Download Quality',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        IconlyBold.close_square,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  video.title,
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Quality options
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              children: [
                _buildQualityOption(
                  context,
                  DownloadQuality.low,
                  '480p',
                  'Small file size',
                  'Good for mobile data',
                  Icons.phone_android,
                  '~50MB',
                ),
                const SizedBox(height: 12),
                _buildQualityOption(
                  context,
                  DownloadQuality.medium,
                  '720p',
                  'Balanced quality',
                  'Recommended for most devices',
                  Icons.tablet_android,
                  '~100MB',
                ),
                const SizedBox(height: 12),
                _buildQualityOption(
                  context,
                  DownloadQuality.high,
                  '1080p',
                  'High quality',
                  'Best for large screens',
                  Icons.tv,
                  '~200MB',
                ),
                const SizedBox(height: 12),
                _buildQualityOption(
                  context,
                  DownloadQuality.ultra,
                  '4K',
                  'Ultra HD quality',
                  'Maximum quality (large file)',
                  Icons.video_settings,
                  '~500MB',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption(
    BuildContext context,
    DownloadQuality quality,
    String qualityText,
    String title,
    String subtitle,
    IconData icon,
    String fileSize,
  ) {
    return GestureDetector(
      onTap: () => onQualitySelected(quality),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3D3D3D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4D4D4D), width: 1),
        ),
        child: Row(
          children: [
            // Quality icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getQualityColor(quality).withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: _getQualityColor(quality), width: 1),
              ),
              child: Icon(icon, color: _getQualityColor(quality), size: 24),
            ),
            const SizedBox(width: 16),

            // Quality info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        qualityText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getQualityColor(quality).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getQualityColor(quality),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          fileSize,
                          style: TextStyle(
                            color: _getQualityColor(quality),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Download icon
            const Icon(IconlyBold.download, color: Color(0xFF6C5CE7), size: 20),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(DownloadQuality quality) {
    switch (quality) {
      case DownloadQuality.low:
        return Colors.green;
      case DownloadQuality.medium:
        return Colors.blue;
      case DownloadQuality.high:
        return Colors.orange;
      case DownloadQuality.ultra:
        return Colors.purple;
    }
  }
}
