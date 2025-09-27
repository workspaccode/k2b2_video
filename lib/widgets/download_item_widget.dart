import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../models/download_models.dart';

class DownloadItemWidget extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onPlay;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const DownloadItemWidget({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
    this.onPlay,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: task.thumbnailUrl,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 60,
                      color: const Color(0xFF3D3D3D),
                      child: const Icon(
                        IconlyBold.play,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 60,
                      color: const Color(0xFF3D3D3D),
                      child: const Icon(
                        IconlyBold.play,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Quality and size info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF6C5CE7),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              task.qualityString,
                              style: const TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.formattedSize,
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                _buildActionButtons(),
              ],
            ),

            // Progress section (only for active downloads)
            if (_shouldShowProgress()) ...[
              const SizedBox(height: 16),
              _buildProgressSection(),
            ],

            // Download info section
            if (task.status != DownloadStatus.queued) ...[
              const SizedBox(height: 12),
              _buildDownloadInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getStatusColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary action button
        if (task.status == DownloadStatus.downloading && onPause != null)
          _actionButton(
            icon: Icons.pause,
            onTap: onPause!,
            color: Colors.orange,
            tooltip: 'Pause',
          )
        else if (task.status == DownloadStatus.paused && onResume != null)
          _actionButton(
            icon: Icons.play_arrow,
            onTap: onResume!,
            color: Colors.blue,
            tooltip: 'Resume',
          )
        else if (task.status == DownloadStatus.failed && onRetry != null)
          _actionButton(
            icon: Icons.refresh,
            onTap: onRetry!,
            color: Colors.green,
            tooltip: 'Retry',
          )
        else if (task.status == DownloadStatus.completed && onPlay != null)
          _actionButton(
            icon: IconlyBold.play,
            onTap: onPlay!,
            color: Colors.green,
            tooltip: 'Play',
          ),

        // Secondary actions
        if (_hasSecondaryActions()) ...[
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            color: const Color(0xFF3D3D3D),
            onSelected: (value) {
              switch (value) {
                case 'cancel':
                  onCancel?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
                case 'share':
                  onShare?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onCancel != null &&
                  (task.status == DownloadStatus.downloading ||
                      task.status == DownloadStatus.queued ||
                      task.status == DownloadStatus.paused))
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Cancel', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              if (onShare != null && task.status == DownloadStatus.completed)
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(IconlyBold.send, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(IconlyBold.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: const Color(0xFF3D3D3D),
                  valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              task.formattedProgress,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Speed and ETA (only for downloading)
        if (task.status == DownloadStatus.downloading) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speed: ${task.formattedSpeed}',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                'ETA: ${task.formattedETA}',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDownloadInfo() {
    return Row(
      children: [
        if (task.downloadedBytes > 0) ...[
          Text(
            '${task.formattedDownloadedSize} downloaded',
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
          ),
          if (task.totalBytes > 0) ...[
            Text(
              ' of ${task.formattedSize}',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
        const Spacer(),
        if (task.completedAt != null)
          Text(
            'Completed ${_formatDate(task.completedAt!)}',
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
          )
        else
          Text(
            'Started ${_formatDate(task.createdAt)}',
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
          ),
      ],
    );
  }

  bool _shouldShowProgress() {
    return task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.paused ||
        (task.status == DownloadStatus.failed && task.progress > 0);
  }

  bool _hasSecondaryActions() {
    return onCancel != null ||
        onDelete != null ||
        (onShare != null && task.status == DownloadStatus.completed);
  }

  Color _getStatusColor() {
    switch (task.status) {
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.queued:
        return Colors.orange;
      case DownloadStatus.paused:
        return Colors.yellow;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon() {
    switch (task.status) {
      case DownloadStatus.downloading:
        return const Icon(IconlyBold.download, size: 12);
      case DownloadStatus.queued:
        return const Icon(IconlyBold.time_circle, size: 12);
      case DownloadStatus.paused:
        return const Icon(Icons.pause, size: 12);
      case DownloadStatus.completed:
        return const Icon(IconlyBold.tick_square, size: 12);
      case DownloadStatus.failed:
        return const Icon(IconlyBold.close_square, size: 12);
      case DownloadStatus.cancelled:
        return const Icon(IconlyBold.delete, size: 12);
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
