import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../models/download_models.dart';
import '../models/video_model.dart';
import '../services/video_download_service.dart';
import 'download_quality_selector.dart';

class DownloadButton extends StatefulWidget {
  final VideoModel video;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showProgress;

  const DownloadButton({
    super.key,
    required this.video,
    this.size = 24,
    this.iconColor,
    this.backgroundColor,
    this.showProgress = true,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton>
    with TickerProviderStateMixin {
  final VideoDownloadService _downloadService = VideoDownloadService.instance;
  late AnimationController _rotationController;
  DownloadTask? _currentTask;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _initializeDownloadService();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _initializeDownloadService() async {
    await _downloadService.initialize();
    _checkDownloadStatus();
    _listenToDownloadUpdates();
    setState(() {
      _isInitialized = true;
    });
  }

  void _checkDownloadStatus() {
    _currentTask = _downloadService.getDownloadedVideo(widget.video.id);
    if (_currentTask == null) {
      // Check if video is currently being downloaded
      final allDownloads = _downloadService.allDownloads;
      for (final task in allDownloads) {
        if (task.videoId == widget.video.id) {
          _currentTask = task;
          break;
        }
      }
    }

    if (_currentTask?.status == DownloadStatus.downloading) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  void _listenToDownloadUpdates() {
    _downloadService.downloadsStream.listen((downloads) {
      final task = downloads.firstWhere(
        (t) => t.videoId == widget.video.id,
        orElse: () => DownloadTask(
          id: '',
          videoId: '',
          title: '',
          thumbnailUrl: '',
          videoUrl: '',
          quality: DownloadQuality.medium,
          createdAt: DateTime.now(),
        ),
      );

      if (task.id.isNotEmpty) {
        setState(() {
          _currentTask = task;
        });

        if (task.status == DownloadStatus.downloading) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      } else if (_currentTask != null) {
        setState(() {
          _currentTask = null;
        });
        _rotationController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(widget.iconColor ?? Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: widget.size + 16,
        height: widget.size + 16,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular((widget.size + 16) / 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress indicator (for downloading status)
            if (widget.showProgress &&
                _currentTask?.status == DownloadStatus.downloading)
              SizedBox(
                width: widget.size + 8,
                height: widget.size + 8,
                child: CircularProgressIndicator(
                  value: _currentTask!.progress,
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C5CE7)),
                  backgroundColor: Colors.grey.withOpacity(0.3),
                ),
              ),

            // Main icon
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Icon(
                    _getIcon(),
                    size: widget.size,
                    color: _getIconColor(),
                  ),
                );
              },
            ),

            // Status badge (for completed/failed status)
            if (_currentTask != null && _shouldShowStatusBadge())
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusBadgeColor(),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(
                    _getStatusBadgeIcon(),
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (_currentTask == null) {
      return IconlyBold.download;
    }

    switch (_currentTask!.status) {
      case DownloadStatus.downloading:
        return IconlyBold.download;
      case DownloadStatus.queued:
        return IconlyBold.time_circle;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.completed:
        return IconlyBold.tick_square;
      case DownloadStatus.failed:
        return IconlyBold.close_square;
      case DownloadStatus.cancelled:
        return IconlyBold.download;
    }
  }

  Color _getIconColor() {
    if (_currentTask == null) {
      return widget.iconColor ?? Colors.white;
    }

    switch (_currentTask!.status) {
      case DownloadStatus.downloading:
        return const Color(0xFF6C5CE7);
      case DownloadStatus.queued:
        return Colors.orange;
      case DownloadStatus.paused:
        return Colors.yellow;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return widget.iconColor ?? Colors.white;
    }
  }

  bool _shouldShowStatusBadge() {
    return _currentTask!.status == DownloadStatus.completed ||
        _currentTask!.status == DownloadStatus.failed;
  }

  Color _getStatusBadgeColor() {
    switch (_currentTask!.status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusBadgeIcon() {
    switch (_currentTask!.status) {
      case DownloadStatus.completed:
        return Icons.check;
      case DownloadStatus.failed:
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  void _handleTap() {
    if (_currentTask == null) {
      _showQualitySelector();
    } else {
      switch (_currentTask!.status) {
        case DownloadStatus.downloading:
          _pauseDownload();
          break;
        case DownloadStatus.queued:
          _cancelDownload();
          break;
        case DownloadStatus.paused:
          _resumeDownload();
          break;
        case DownloadStatus.completed:
          _showDownloadOptions();
          break;
        case DownloadStatus.failed:
          _retryDownload();
          break;
        case DownloadStatus.cancelled:
          _showQualitySelector();
          break;
      }
    }
  }

  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadQualitySelector(
        video: widget.video,
        onQualitySelected: (quality) {
          Navigator.pop(context);
          _startDownload(quality);
        },
      ),
    );
  }

  Future<void> _startDownload(DownloadQuality quality) async {
    try {
      await _downloadService.startDownload(
        videoId: widget.video.id,
        title: widget.video.title,
        thumbnailUrl: widget.video.thumbnailUrl,
        videoUrl: widget.video.videoUrl,
        quality: quality,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download started: ${widget.video.title}'),
            backgroundColor: const Color(0xFF6C5CE7),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/downloads');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pauseDownload() async {
    if (_currentTask != null) {
      await _downloadService.pauseDownload(_currentTask!.id);
    }
  }

  Future<void> _resumeDownload() async {
    if (_currentTask != null) {
      try {
        await _downloadService.resumeDownload(_currentTask!.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resume download: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelDownload() async {
    if (_currentTask != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Cancel Download',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to cancel downloading "${widget.video.title}"?',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _downloadService.cancelDownload(_currentTask!.id);
      }
    }
  }

  Future<void> _retryDownload() async {
    if (_currentTask != null) {
      try {
        await _downloadService.startDownload(
          videoId: _currentTask!.videoId,
          title: _currentTask!.title,
          thumbnailUrl: _currentTask!.thumbnailUrl,
          videoUrl: _currentTask!.videoUrl,
          quality: _currentTask!.quality,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to retry download: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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

            const SizedBox(height: 20),

            // Title
            Text(
              widget.video.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Options
            ListTile(
              leading: const Icon(IconlyBold.play, color: Color(0xFF6C5CE7)),
              title: const Text(
                'Play Downloaded Video',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _playDownloadedVideo();
              },
            ),

            ListTile(
              leading: const Icon(IconlyBold.send, color: Colors.blue),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareVideo();
              },
            ),

            ListTile(
              leading: const Icon(IconlyBold.delete, color: Colors.red),
              title: const Text(
                'Delete Download',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteDownload();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _playDownloadedVideo() {
    Navigator.pushNamed(
      context,
      '/video_player',
      arguments: {
        'videoPath': _currentTask!.localPath,
        'title': widget.video.title,
        'isLocal': true,
      },
    );
  }

  void _shareVideo() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        backgroundColor: Color(0xFF6C5CE7),
      ),
    );
  }

  Future<void> _deleteDownload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Delete Download',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.video.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentTask != null) {
      await _downloadService.deleteDownload(_currentTask!.id);
    }
  }
}
