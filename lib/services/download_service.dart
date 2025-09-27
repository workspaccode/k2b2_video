import 'dart:async';

import '../models/video_model.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

class DownloadProgress {
  final String videoId;
  final double progress;
  final DownloadStatus status;
  final int downloadedBytes;
  final int totalBytes;
  final String? error;

  DownloadProgress({
    required this.videoId,
    required this.progress,
    required this.status,
    required this.downloadedBytes,
    required this.totalBytes,
    this.error,
  });

  String get progressPercentage => '${(progress * 100).toInt()}%';

  String get downloadedSize => _formatBytes(downloadedBytes);

  String get totalSize => _formatBytes(totalBytes);

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, StreamController<DownloadProgress>> _downloadStreams = {};
  final Map<String, Timer> _simulatedDownloads = {};
  final Map<String, DownloadProgress> _downloadProgress = {};

  /// Get download progress stream for a specific video
  Stream<DownloadProgress> getDownloadStream(String videoId) {
    if (!_downloadStreams.containsKey(videoId)) {
      _downloadStreams[videoId] =
          StreamController<DownloadProgress>.broadcast();
    }
    return _downloadStreams[videoId]!.stream;
  }

  /// Start downloading a video
  Future<void> startDownload(VideoModel video, {String quality = 'HD'}) async {
    if (_downloadProgress.containsKey(video.id)) {
      final currentStatus = _downloadProgress[video.id]!.status;
      if (currentStatus == DownloadStatus.downloading ||
          currentStatus == DownloadStatus.completed) {
        return; // Already downloading or completed
      }
    }

    // Initialize download progress
    final initialProgress = DownloadProgress(
      videoId: video.id,
      progress: 0.0,
      status: DownloadStatus.downloading,
      downloadedBytes: 0,
      totalBytes: _calculateFileSize(video, quality),
    );

    _downloadProgress[video.id] = initialProgress;
    _notifyProgress(video.id, initialProgress);

    // Simulate download progress
    await _simulateDownload(video, quality);
  }

  /// Pause download
  void pauseDownload(String videoId) {
    _simulatedDownloads[videoId]?.cancel();

    if (_downloadProgress.containsKey(videoId)) {
      final current = _downloadProgress[videoId]!;
      final paused = DownloadProgress(
        videoId: videoId,
        progress: current.progress,
        status: DownloadStatus.paused,
        downloadedBytes: current.downloadedBytes,
        totalBytes: current.totalBytes,
      );

      _downloadProgress[videoId] = paused;
      _notifyProgress(videoId, paused);
    }
  }

  /// Resume download
  Future<void> resumeDownload(String videoId) async {
    if (!_downloadProgress.containsKey(videoId)) return;

    final current = _downloadProgress[videoId]!;
    if (current.status != DownloadStatus.paused) return;

    final resumed = DownloadProgress(
      videoId: videoId,
      progress: current.progress,
      status: DownloadStatus.downloading,
      downloadedBytes: current.downloadedBytes,
      totalBytes: current.totalBytes,
    );

    _downloadProgress[videoId] = resumed;
    _notifyProgress(videoId, resumed);

    // Continue simulation from where it left off
    await _simulateDownloadFromProgress(
      videoId,
      current.progress,
      current.totalBytes,
    );
  }

  /// Cancel download
  void cancelDownload(String videoId) {
    _simulatedDownloads[videoId]?.cancel();
    _simulatedDownloads.remove(videoId);

    if (_downloadProgress.containsKey(videoId)) {
      final cancelled = DownloadProgress(
        videoId: videoId,
        progress: 0.0,
        status: DownloadStatus.cancelled,
        downloadedBytes: 0,
        totalBytes: _downloadProgress[videoId]!.totalBytes,
      );

      _downloadProgress[videoId] = cancelled;
      _notifyProgress(videoId, cancelled);
    }
  }

  /// Get current download status
  DownloadProgress? getDownloadProgress(String videoId) {
    return _downloadProgress[videoId];
  }

  /// Check if video is downloaded
  bool isVideoDownloaded(String videoId) {
    final progress = _downloadProgress[videoId];
    return progress?.status == DownloadStatus.completed;
  }

  /// Get all downloads
  List<DownloadProgress> getAllDownloads() {
    return _downloadProgress.values.toList();
  }

  /// Clear completed downloads
  void clearCompletedDownloads() {
    _downloadProgress.removeWhere(
      (key, value) => value.status == DownloadStatus.completed,
    );
  }

  Future<void> _simulateDownload(VideoModel video, String quality) async {
    final totalBytes = _calculateFileSize(video, quality);
    await _simulateDownloadFromProgress(video.id, 0.0, totalBytes);
  }

  Future<void> _simulateDownloadFromProgress(
    String videoId,
    double startProgress,
    int totalBytes,
  ) async {
    const updateInterval = Duration(milliseconds: 100);
    const progressIncrement = 0.01; // 1% per update

    double currentProgress = startProgress;

    _simulatedDownloads[videoId] = Timer.periodic(updateInterval, (timer) {
      if (!_downloadProgress.containsKey(videoId) ||
          _downloadProgress[videoId]!.status != DownloadStatus.downloading) {
        timer.cancel();
        return;
      }

      currentProgress += progressIncrement;

      if (currentProgress >= 1.0) {
        currentProgress = 1.0;
        timer.cancel();

        final completed = DownloadProgress(
          videoId: videoId,
          progress: 1.0,
          status: DownloadStatus.completed,
          downloadedBytes: totalBytes,
          totalBytes: totalBytes,
        );

        _downloadProgress[videoId] = completed;
        _notifyProgress(videoId, completed);
        _simulatedDownloads.remove(videoId);
      } else {
        final progress = DownloadProgress(
          videoId: videoId,
          progress: currentProgress,
          status: DownloadStatus.downloading,
          downloadedBytes: (currentProgress * totalBytes).round(),
          totalBytes: totalBytes,
        );

        _downloadProgress[videoId] = progress;
        _notifyProgress(videoId, progress);
      }
    });
  }

  int _calculateFileSize(VideoModel video, String quality) {
    // Simulate file sizes based on duration and quality
    final baseSizePerMinute = {
      '4K': 100 * 1024 * 1024, // 100MB per minute
      'HD': 50 * 1024 * 1024, // 50MB per minute
      'SD': 25 * 1024 * 1024, // 25MB per minute
    };

    final sizePerMinute =
        baseSizePerMinute[quality] ?? baseSizePerMinute['HD']!;
    final durationMinutes = video.duration / 60;

    return (sizePerMinute * durationMinutes).round();
  }

  void _notifyProgress(String videoId, DownloadProgress progress) {
    if (_downloadStreams.containsKey(videoId)) {
      _downloadStreams[videoId]!.add(progress);
    }
  }

  /// Dispose resources
  void dispose() {
    for (final timer in _simulatedDownloads.values) {
      timer.cancel();
    }
    _simulatedDownloads.clear();

    for (final stream in _downloadStreams.values) {
      stream.close();
    }
    _downloadStreams.clear();
    _downloadProgress.clear();
  }
}
