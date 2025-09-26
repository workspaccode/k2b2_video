import 'package:dio/dio.dart';

import '../../models/video_model.dart';

// Jikan API Models
class JikanAnime {
  final int malId;
  final String title;
  final String titleEnglish;
  final String titleJapanese;
  final String synopsis;
  final double score;
  final int episodes;
  final String status;
  final String aired;
  final List<String> genres;
  final String imageUrl;
  final String trailerUrl;
  final String type;
  final String source;
  final int duration;
  final String rating;

  JikanAnime({
    required this.malId,
    required this.title,
    required this.titleEnglish,
    required this.titleJapanese,
    required this.synopsis,
    required this.score,
    required this.episodes,
    required this.status,
    required this.aired,
    required this.genres,
    required this.imageUrl,
    required this.trailerUrl,
    required this.type,
    required this.source,
    required this.duration,
    required this.rating,
  });

  factory JikanAnime.fromJson(Map<String, dynamic> json) {
    return JikanAnime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? '',
      titleEnglish: json['title_english'] ?? '',
      titleJapanese: json['title_japanese'] ?? '',
      synopsis: json['synopsis'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      episodes: json['episodes'] ?? 0,
      status: json['status'] ?? '',
      aired: json['aired']?['string'] ?? '',
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((genre) => genre['name'].toString())
          .toList(),
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? '',
      trailerUrl: json['trailer']?['url'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      duration: json['duration_per_episode'] ?? 1440, // 24 minutes default
      rating: json['rating'] ?? '',
    );
  }

  VideoModel toVideoModel() {
    return VideoModel(
      id: malId.toString(),
      title: title,
      description: synopsis.length > 200
          ? '${synopsis.substring(0, 200)}...'
          : synopsis,
      thumbnailUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=${Uri.encodeComponent(title)}',
      videoUrl: trailerUrl.isNotEmpty ? trailerUrl : '',
      category: 'anime',
      duration: duration * 60, // Convert minutes to seconds
      views: (score * 100000).toInt(), // Estimate views based on score
      uploadDate: DateTime.now().subtract(Duration(days: malId % 365)),
      quality: score > 8.0 ? '4K' : '1080p',
      isDownloadable: true,
    );
  }
}

class YouTubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['id']?['videoId'] ?? '',
      title: json['snippet']?['title'] ?? '',
      description: json['snippet']?['description'] ?? '',
      thumbnailUrl: json['snippet']?['thumbnails']?['high']?['url'] ?? '',
      channelTitle: json['snippet']?['channelTitle'] ?? '',
      publishedAt:
          DateTime.tryParse(json['snippet']?['publishedAt'] ?? '') ??
          DateTime.now(),
    );
  }
}

class AnimeApiService {
  static const String _jikanBaseUrl = 'https://api.jikan.moe/v4';
  static const String _youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _youtubeApiKey =
      'AIzaSyAQxVyic7I7DgJvHWPelaqtH8LxNN6wsz4'; // Replace with real key

  late final Dio _dio;

  AnimeApiService() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Get anime by ID from Jikan
  Future<JikanAnime> getAnimeById(int animeId) async {
    try {
      final response = await _dio.get('$_jikanBaseUrl/anime/$animeId');
      return JikanAnime.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch anime data: $e');
    }
  }

  // Get popular anime
  Future<List<JikanAnime>> getPopularAnime({int page = 1}) async {
    try {
      print('🚀 Fetching popular anime from Jikan API...');
      final response = await _dio.get(
        '$_jikanBaseUrl/anime',
        queryParameters: {
          'order_by': 'score',
          'sort': 'desc',
          'page': page,
          'limit': 10,
        },
      );

      print(
        '✅ Jikan API Response received: ${response.data['data']?.length ?? 0} anime',
      );
      final List<dynamic> animeList = response.data['data'] ?? [];
      final animeResults = animeList
          .map((anime) => JikanAnime.fromJson(anime))
          .toList();

      // Log the first few anime titles for verification
      for (
        int i = 0;
        i < (animeResults.length > 3 ? 3 : animeResults.length);
        i++
      ) {
        print(
          '📺 Anime ${i + 1}: ${animeResults[i].title} (Score: ${animeResults[i].score})',
        );
      }

      return animeResults;
    } catch (e) {
      print('❌ Jikan API Error: $e');
      throw Exception('Failed to fetch popular anime: $e');
    }
  }

  // Get seasonal anime
  Future<List<JikanAnime>> getSeasonalAnime() async {
    try {
      final now = DateTime.now();
      final season = _getCurrentSeason(now.month);
      final year = now.year;

      final response = await _dio.get(
        '$_jikanBaseUrl/seasons/$year/$season',
        queryParameters: {'limit': 15},
      );

      final List<dynamic> animeList = response.data['data'] ?? [];
      return animeList.map((anime) => JikanAnime.fromJson(anime)).toList();
    } catch (e) {
      throw Exception('Failed to fetch seasonal anime: $e');
    }
  }

  // Search anime
  Future<List<JikanAnime>> searchAnime(String query) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime',
        queryParameters: {'q': query, 'limit': 10},
      );

      final List<dynamic> animeList = response.data['data'] ?? [];
      return animeList.map((anime) => JikanAnime.fromJson(anime)).toList();
    } catch (e) {
      throw Exception('Failed to search anime: $e');
    }
  }

  // Search for Arabic summaries on YouTube
  Future<List<YouTubeVideo>> searchArabicSummary(String animeTitle) async {
    try {
      final searchQuery = 'ملخص $animeTitle أنمي';

      final response = await _dio.get(
        '$_youtubeBaseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': searchQuery,
          'type': 'video',
          'relevanceLanguage': 'ar',
          'maxResults': 5,
          'key': _youtubeApiKey,
        },
      );

      final List<dynamic> videoList = response.data['items'] ?? [];
      return videoList.map((video) => YouTubeVideo.fromJson(video)).toList();
    } catch (e) {
      print('YouTube API Error: $e');
      // Return empty list if YouTube API fails
      return [];
    }
  }

  // Get anime with Arabic summaries
  Future<Map<String, dynamic>> getAnimeWithArabicSummary(int animeId) async {
    try {
      // Get anime data from Jikan
      final anime = await getAnimeById(animeId);

      // Search for Arabic summaries
      final arabicSummaries = await searchArabicSummary(anime.title);

      return {
        'anime': anime,
        'arabicSummaries': arabicSummaries,
        'videoModel': anime.toVideoModel(),
      };
    } catch (e) {
      throw Exception('Failed to get anime with Arabic summary: $e');
    }
  }

  String _getCurrentSeason(int month) {
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'fall';
    return 'winter';
  }
}
