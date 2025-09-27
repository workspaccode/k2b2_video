import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';

import '../models/download_models.dart';
import '../services/video_download_service.dart';
import '../widgets/download_item_widget.dart';
import '../widgets/download_settings_sheet.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final VideoDownloadService _downloadService = VideoDownloadService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _downloadService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: StreamBuilder<List<DownloadTask>>(
              stream: _downloadService.downloadsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildLoadingState();
                }

                final downloads = snapshot.data!;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveDownloads(downloads),
                    _buildCompletedDownloads(downloads),
                    _buildAllDownloads(downloads),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      title: const Text(
        'Downloads',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        StreamBuilder<List<DownloadTask>>(
          stream: _downloadService.downloadsStream,
          builder: (context, snapshot) {
            final hasActiveDownloads =
                snapshot.hasData &&
                snapshot.data!.any(
                  (task) =>
                      task.status == DownloadStatus.downloading ||
                      task.status == DownloadStatus.queued,
                );

            return Row(
              children: [
                // Pause all button (only show if there are active downloads)
                if (hasActiveDownloads)
                  IconButton(
                    onPressed: _pauseAllDownloads,
                    icon: const Icon(Icons.pause, color: Colors.white),
                    tooltip: 'Pause All',
                  ),

                // Settings button
                IconButton(
                  onPressed: _showDownloadSettings,
                  icon: const Icon(IconlyBold.setting, color: Colors.white),
                  tooltip: 'Download Settings',
                ),

                // Storage info button
                IconButton(
                  onPressed: _showStorageInfo,
                  icon: const Icon(IconlyBold.folder, color: Colors.white),
                  tooltip: 'Storage Info',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Color(0xFF333333), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF6C5CE7),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(IconlyBold.download, size: 20),
                const SizedBox(width: 8),
                const Text('Active'),
                StreamBuilder<List<DownloadTask>>(
                  stream: _downloadService.downloadsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final activeCount = snapshot.data!
                        .where(
                          (task) =>
                              task.status == DownloadStatus.downloading ||
                              task.status == DownloadStatus.queued,
                        )
                        .length;

                    if (activeCount == 0) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(IconlyBold.tick_square, size: 20),
                const SizedBox(width: 8),
                const Text('Completed'),
                StreamBuilder<List<DownloadTask>>(
                  stream: _downloadService.downloadsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final completedCount = snapshot.data!
                        .where(
                          (task) => task.status == DownloadStatus.completed,
                        )
                        .length;

                    if (completedCount == 0) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        completedCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconlyBold.category, size: 20),
                SizedBox(width: 8),
                Text('All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2D2D2D),
      highlightColor: const Color(0xFF3D3D3D),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveDownloads(List<DownloadTask> downloads) {
    final activeDownloads = downloads
        .where(
          (task) =>
              task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.queued ||
              task.status == DownloadStatus.paused,
        )
        .toList();

    if (activeDownloads.isEmpty) {
      return _buildEmptyState(
        icon: IconlyBold.download,
        title: 'No Active Downloads',
        subtitle: 'Your active downloads will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeDownloads.length,
      itemBuilder: (context, index) {
        return DownloadItemWidget(
          task: activeDownloads[index],
          onPause: () =>
              _downloadService.pauseDownload(activeDownloads[index].id),
          onResume: () =>
              _downloadService.resumeDownload(activeDownloads[index].id),
          onCancel: () => _showCancelDialog(activeDownloads[index]),
          onRetry: () => _retryDownload(activeDownloads[index]),
        );
      },
    );
  }

  Widget _buildCompletedDownloads(List<DownloadTask> downloads) {
    final completedDownloads = downloads
        .where((task) => task.status == DownloadStatus.completed)
        .toList();

    if (completedDownloads.isEmpty) {
      return _buildEmptyState(
        icon: IconlyBold.tick_square,
        title: 'No Completed Downloads',
        subtitle: 'Completed downloads will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedDownloads.length,
      itemBuilder: (context, index) {
        return DownloadItemWidget(
          task: completedDownloads[index],
          onPlay: () => _playVideo(completedDownloads[index]),
          onDelete: () => _showDeleteDialog(completedDownloads[index]),
          onShare: () => _shareVideo(completedDownloads[index]),
        );
      },
    );
  }

  Widget _buildAllDownloads(List<DownloadTask> downloads) {
    if (downloads.isEmpty) {
      return _buildEmptyState(
        icon: IconlyBold.category,
        title: 'No Downloads',
        subtitle: 'Start downloading videos to see them here',
      );
    }

    // Group downloads by status
    final Map<DownloadStatus, List<DownloadTask>> groupedDownloads = {};
    for (final task in downloads) {
      if (!groupedDownloads.containsKey(task.status)) {
        groupedDownloads[task.status] = [];
      }
      groupedDownloads[task.status]!.add(task);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedDownloads.length,
      itemBuilder: (context, index) {
        final status = groupedDownloads.keys.elementAt(index);
        final tasks = groupedDownloads[status]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _getStatusIcon(status),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusTitle(status),
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
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tasks.length.toString(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tasks list
            ...tasks
                .map(
                  (task) => DownloadItemWidget(
                    task: task,
                    onPause: task.status == DownloadStatus.downloading
                        ? () => _downloadService.pauseDownload(task.id)
                        : null,
                    onResume: task.status == DownloadStatus.paused
                        ? () => _downloadService.resumeDownload(task.id)
                        : null,
                    onCancel:
                        task.status == DownloadStatus.downloading ||
                            task.status == DownloadStatus.queued ||
                            task.status == DownloadStatus.paused
                        ? () => _showCancelDialog(task)
                        : null,
                    onRetry: task.status == DownloadStatus.failed
                        ? () => _retryDownload(task)
                        : null,
                    onPlay: task.status == DownloadStatus.completed
                        ? () => _playVideo(task)
                        : null,
                    onDelete: () => _showDeleteDialog(task),
                    onShare: task.status == DownloadStatus.completed
                        ? () => _shareVideo(task)
                        : null,
                  ),
                )
                ,
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return const Icon(IconlyBold.download, color: Colors.blue, size: 20);
      case DownloadStatus.queued:
        return const Icon(
          IconlyBold.time_circle,
          color: Colors.orange,
          size: 20,
        );
      case DownloadStatus.paused:
        return const Icon(Icons.pause, color: Colors.yellow, size: 20);
      case DownloadStatus.completed:
        return const Icon(
          IconlyBold.tick_square,
          color: Colors.green,
          size: 20,
        );
      case DownloadStatus.failed:
        return const Icon(IconlyBold.close_square, color: Colors.red, size: 20);
      case DownloadStatus.cancelled:
        return const Icon(IconlyBold.delete, color: Colors.grey, size: 20);
    }
  }

  String _getStatusTitle(DownloadStatus status) {
    switch (status) {
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

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
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

  void _pauseAllDownloads() async {
    final downloads = await _downloadService.downloadsStream.first;
    final activeDownloads = downloads
        .where((task) => task.status == DownloadStatus.downloading)
        .toList();

    for (final task in activeDownloads) {
      await _downloadService.pauseDownload(task.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paused ${activeDownloads.length} downloads'),
          backgroundColor: const Color(0xFF6C5CE7),
        ),
      );
    }
  }

  void _showDownloadSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DownloadSettingsSheet(),
    );
  }

  void _showStorageInfo() {
    // TODO: Implement storage info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage info feature coming soon'),
        backgroundColor: Color(0xFF6C5CE7),
      ),
    );
  }

  void _showCancelDialog(DownloadTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Cancel Download',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to cancel downloading "${task.title}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadService.cancelDownload(task.id);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(DownloadTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Delete Download',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadService.deleteDownload(task.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _retryDownload(DownloadTask task) async {
    try {
      await _downloadService.startDownload(
        videoId: task.videoId,
        title: task.title,
        thumbnailUrl: task.thumbnailUrl,
        videoUrl: task.videoUrl,
        quality: task.quality,
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

  void _playVideo(DownloadTask task) {
    // TODO: Navigate to video player with local file
    Navigator.pushNamed(
      context,
      '/video_player',
      arguments: {
        'videoPath': task.localPath,
        'title': task.title,
        'isLocal': true,
      },
    );
  }

  void _shareVideo(DownloadTask task) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        backgroundColor: Color(0xFF6C5CE7),
      ),
    );
  }
}
