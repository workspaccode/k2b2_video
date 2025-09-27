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
  final double rating;
  final int likes;
  final bool isLiked;
  final bool isDownloaded;

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
    this.rating = 0.0,
    this.likes = 0,
    this.isLiked = false,
    this.isDownloaded = false,
  });

  /// Create VideoModel from API response
  factory VideoModel.fromApi(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString() ?? '',
      thumbnailUrl:
          json['thumbnail_url']?.toString() ??
          json['thumbnail']?.toString() ??
          '',
      videoUrl: json['video_url']?.toString() ?? json['url']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      duration: _parseDuration(json['duration']),
      views: _parseInt(json['views']),
      uploadDate: _parseDate(json['upload_date'] ?? json['created_at']),
      quality: json['quality']?.toString() ?? '720p',
      isDownloadable: json['is_downloadable'] == true,
      isWatched: json['is_watched'] == true,
      lastWatchedPosition: _parseInt(json['last_watched_position']),
      rating: _parseDouble(json['rating']),
      likes: _parseInt(json['likes']),
      isLiked: json['is_liked'] == true,
      isDownloaded: json['is_downloaded'] == true,
    );
  }

  /// Helper methods for parsing API data
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseDuration(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      // Try to parse duration in format "HH:MM:SS" or "MM:SS"
      final parts = value.split(':');
      if (parts.length == 3) {
        return (int.tryParse(parts[0]) ?? 0) * 3600 +
            (int.tryParse(parts[1]) ?? 0) * 60 +
            (int.tryParse(parts[2]) ?? 0);
      } else if (parts.length == 2) {
        return (int.tryParse(parts[0]) ?? 0) * 60 +
            (int.tryParse(parts[1]) ?? 0);
      } else {
        return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

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
    double? rating,
    int? likes,
    bool? isLiked,
    bool? isDownloaded,
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
      rating: rating ?? this.rating,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
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
