import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/video_model.dart';

class YouTubeService {
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  /// Get video stream URL for playback
  Future<String> getVideoStreamUrl(String videoId) async {
    try {
      // Get video manifest
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Get the highest quality muxed stream (video + audio)
      final streamInfo = manifest.muxed.withHighestBitrate();

      return streamInfo.url.toString();
    } catch (e) {
      print('Error getting video stream: $e');
      rethrow;
    }
  }

  /// Search for videos
  Future<List<VideoModel>> searchVideos(String query, {int limit = 20}) async {
    try {
      final videos = await _yt.search.search(query);
      final videoList = <VideoModel>[];

      var count = 0;
      // Fix: Use regular for loop instead of await for since VideoSearchList is not a Stream
      for (final video in videos) {
        if (count >= limit) break;
        // Removed unnecessary type check since videos are already Video objects
        videoList.add(_convertToVideoModel(video));
        count++;
      }

      return videoList;
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  /// Get trending videos
  Future<List<VideoModel>> getTrendingVideos({int limit = 20}) async {
    try {
      final videos = await _yt.search.search('trending');
      final videoList = <VideoModel>[];

      var count = 0;
      // Fix: Use regular for loop instead of await for since VideoSearchList is not a Stream
      for (final video in videos) {
        if (count >= limit) break;
        // Removed unnecessary type check since videos are already Video objects
        videoList.add(_convertToVideoModel(video));
        count++;
      }

      return videoList;
    } catch (e) {
      print('Error getting trending videos: $e');
      return [];
    }
  }

  /// Get video details
  Future<VideoModel?> getVideoDetails(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      return _convertToVideoModel(video);
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }

  /// Convert YouTube video to our VideoModel
  VideoModel _convertToVideoModel(Video video) {
    return VideoModel(
      id: video.id.value,
      title: video.title,
      description: video.description ?? '',
      thumbnailUrl: video.thumbnails.highResUrl,
      videoUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
      category: _getCategoryFromVideo(video),
      duration: _parseDuration(video.duration),
      views: _parseViewCount(video.engagement.viewCount),
      uploadDate: video.uploadDate ?? DateTime.now(),
      quality: '1080p', // Default quality
      isDownloadable: false, // YouTube videos typically not downloadable
      isWatched: false,
      rating: _parseRating(
        video.engagement.likeCount,
        video.engagement.viewCount,
      ),
      likes: video.engagement.likeCount ?? 0,
      isLiked: false,
    );
  }

  /// Parse duration from YouTube format
  int _parseDuration(Duration? duration) {
    if (duration == null) return 0;
    return duration.inSeconds;
  }

  /// Parse view count
  int _parseViewCount(int? viewCount) {
    return viewCount ?? 0;
  }

  /// Parse rating based on likes/views ratio
  double _parseRating(int? likes, int views) {
    if (likes == null || views == 0) return 0.0;
    final ratio = likes / views;
    // Convert to 5-star rating
    return (ratio * 5).clamp(0.0, 5.0);
  }

  /// Get category from video tags
  String _getCategoryFromVideo(Video video) {
    final tags = video.keywords;
    if (tags.isEmpty) return 'General';

    // Simple category detection based on common tags
    final lowerTags = tags.map((tag) => tag.toLowerCase()).toList();

    if (lowerTags.any((tag) => ['action', 'fight', 'battle'].contains(tag))) {
      return 'Action';
    } else if (lowerTags.any(
      (tag) => ['comedy', 'funny', 'laugh'].contains(tag),
    )) {
      return 'Comedy';
    } else if (lowerTags.any(
      (tag) => ['anime', 'japan', 'manga'].contains(tag),
    )) {
      return 'Anime';
    } else if (lowerTags.any(
      (tag) => ['music', 'song', 'concert'].contains(tag),
    )) {
      return 'Music';
    } else if (lowerTags.any(
      (tag) => ['news', 'breaking', 'report'].contains(tag),
    )) {
      return 'News';
    } else if (lowerTags.any(
      (tag) => ['sports', 'game', 'match'].contains(tag),
    )) {
      return 'Sports';
    } else if (lowerTags.any(
      (tag) => ['tech', 'technology', 'review'].contains(tag),
    )) {
      return 'Technology';
    }

    return 'General';
  }

  /// Dispose resources
  void dispose() {
    _yt.close();
  }
}
