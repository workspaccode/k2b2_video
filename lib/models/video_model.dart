class VideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String category;
  final int duration; // in seconds
  final int views;
  final DateTime uploadDate;
  final String quality;
  final bool isDownloadable;
  final bool isWatched;
  final int? lastWatchedPosition; // in seconds

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.duration,
    required this.views,
    required this.uploadDate,
    this.quality = '720p',
    this.isDownloadable = true,
    this.isWatched = false,
    this.lastWatchedPosition,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    String? category,
    int? duration,
    int? views,
    DateTime? uploadDate,
    String? quality,
    bool? isDownloadable,
    bool? isWatched,
    int? lastWatchedPosition,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      uploadDate: uploadDate ?? this.uploadDate,
      quality: quality ?? this.quality,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isWatched: isWatched ?? this.isWatched,
      lastWatchedPosition: lastWatchedPosition ?? this.lastWatchedPosition,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$views views';
    }
  }
}
