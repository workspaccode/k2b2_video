import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'download_models.g.dart';

@HiveType(typeId: 2)
enum DownloadStatus {
  @HiveField(0)
  queued,
  @HiveField(1)
  downloading,
  @HiveField(2)
  paused,
  @HiveField(3)
  completed,
  @HiveField(4)
  failed,
  @HiveField(5)
  cancelled,
}

@HiveType(typeId: 3)
enum DownloadQuality {
  @HiveField(0)
  low, // 480p
  @HiveField(1)
  medium, // 720p
  @HiveField(2)
  high, // 1080p
  @HiveField(3)
  ultra, // 4K
}

@HiveType(typeId: 0)
class DownloadTask extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String videoId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String thumbnailUrl;
  @HiveField(4)
  final String videoUrl;
  @HiveField(5)
  final DownloadQuality quality;
  @HiveField(6)
  final DownloadStatus status;
  @HiveField(7)
  final double progress;
  @HiveField(8)
  final int downloadedBytes;
  @HiveField(9)
  final int totalBytes;
  @HiveField(10)
  final String? localPath;
  @HiveField(11)
  final DateTime createdAt;
  @HiveField(12)
  final DateTime? completedAt;
  @HiveField(13)
  final String? errorMessage;
  @HiveField(14)
  final double downloadSpeed; // bytes per second
  @HiveField(15)
  final Duration estimatedTimeRemaining;

  const DownloadTask({
    required this.id,
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.quality,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.localPath,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.downloadSpeed = 0.0,
    this.estimatedTimeRemaining = Duration.zero,
  });

  DownloadTask copyWith({
    String? id,
    String? videoId,
    String? title,
    String? thumbnailUrl,
    String? videoUrl,
    DownloadQuality? quality,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? localPath,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    double? downloadSpeed,
    Duration? estimatedTimeRemaining,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      quality: quality ?? this.quality,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      estimatedTimeRemaining:
          estimatedTimeRemaining ?? this.estimatedTimeRemaining,
    );
  }

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  String get formattedSize {
    if (totalBytes > 0) {
      final sizeInMB = totalBytes / (1024 * 1024);
      if (sizeInMB > 1024) {
        return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
      }
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
    return 'Unknown';
  }

  String get formattedDownloadedSize {
    final sizeInMB = downloadedBytes / (1024 * 1024);
    if (sizeInMB > 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  String get formattedSpeed {
    if (downloadSpeed <= 0) return '0 KB/s';

    final speedKB = downloadSpeed / 1024;
    if (speedKB > 1024) {
      return '${(speedKB / 1024).toStringAsFixed(1)} MB/s';
    }
    return '${speedKB.toStringAsFixed(1)} KB/s';
  }

  String get formattedETA {
    if (estimatedTimeRemaining.inSeconds <= 0) return '--';

    final hours = estimatedTimeRemaining.inHours;
    final minutes = estimatedTimeRemaining.inMinutes % 60;
    final seconds = estimatedTimeRemaining.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get qualityString {
    switch (quality) {
      case DownloadQuality.low:
        return '480p';
      case DownloadQuality.medium:
        return '720p';
      case DownloadQuality.high:
        return '1080p';
      case DownloadQuality.ultra:
        return '4K';
    }
  }

  @override
  List<Object?> get props => [
    id,
    videoId,
    title,
    thumbnailUrl,
    videoUrl,
    quality,
    status,
    progress,
    downloadedBytes,
    totalBytes,
    localPath,
    createdAt,
    completedAt,
    errorMessage,
    downloadSpeed,
    estimatedTimeRemaining,
  ];
}

class DownloadProgress extends Equatable {
  final String taskId;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double speed;
  final Duration estimatedTimeRemaining;

  const DownloadProgress({
    required this.taskId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.estimatedTimeRemaining,
  });

  @override
  List<Object?> get props => [
    taskId,
    progress,
    downloadedBytes,
    totalBytes,
    speed,
    estimatedTimeRemaining,
  ];
}

@HiveType(typeId: 1)
class DownloadSettings extends Equatable {
  @HiveField(0)
  final DownloadQuality defaultQuality;
  @HiveField(1)
  final bool downloadOnlyOnWifi;
  @HiveField(2)
  final bool allowDownloadOnMobileData;
  @HiveField(3)
  final int maxConcurrentDownloads;
  @HiveField(4)
  final bool autoDownloadWatchLater;
  @HiveField(5)
  final String downloadLocation;
  @HiveField(6)
  final bool deleteAfterDays;
  @HiveField(7)
  final int deleteAfterDaysCount;

  const DownloadSettings({
    this.defaultQuality = DownloadQuality.medium,
    this.downloadOnlyOnWifi = true,
    this.allowDownloadOnMobileData = false,
    this.maxConcurrentDownloads = 2,
    this.autoDownloadWatchLater = false,
    required this.downloadLocation,
    this.deleteAfterDays = false,
    this.deleteAfterDaysCount = 30,
  });

  DownloadSettings copyWith({
    DownloadQuality? defaultQuality,
    bool? downloadOnlyOnWifi,
    bool? allowDownloadOnMobileData,
    int? maxConcurrentDownloads,
    bool? autoDownloadWatchLater,
    String? downloadLocation,
    bool? deleteAfterDays,
    int? deleteAfterDaysCount,
  }) {
    return DownloadSettings(
      defaultQuality: defaultQuality ?? this.defaultQuality,
      downloadOnlyOnWifi: downloadOnlyOnWifi ?? this.downloadOnlyOnWifi,
      allowDownloadOnMobileData:
          allowDownloadOnMobileData ?? this.allowDownloadOnMobileData,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      autoDownloadWatchLater:
          autoDownloadWatchLater ?? this.autoDownloadWatchLater,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      deleteAfterDays: deleteAfterDays ?? this.deleteAfterDays,
      deleteAfterDaysCount: deleteAfterDaysCount ?? this.deleteAfterDaysCount,
    );
  }

  @override
  List<Object?> get props => [
    defaultQuality,
    downloadOnlyOnWifi,
    allowDownloadOnMobileData,
    maxConcurrentDownloads,
    autoDownloadWatchLater,
    downloadLocation,
    deleteAfterDays,
    deleteAfterDaysCount,
  ];
}
