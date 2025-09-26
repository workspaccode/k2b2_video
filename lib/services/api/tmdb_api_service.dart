import 'package:dio/dio.dart';

import '../../models/video_model.dart';

// TMDB API Models
class TMDBMovie {
  final int id;
  final String title;
  final String description;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final bool isAdult;
  final String originalLanguage;
  final double popularity;

  TMDBMovie({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.isAdult,
    required this.originalLanguage,
    required this.popularity,
  });

  factory TMDBMovie.fromJson(Map<String, dynamic> json) {
    return TMDBMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      isAdult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
    );
  }

  // Convert to VideoModel
  VideoModel toVideoModel() {
    return VideoModel(
      id: id.toString(),
      title: title,
      description: description,
      thumbnailUrl: posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : 'https://via.placeholder.com/500x750?text=${Uri.encodeComponent(title)}',
      videoUrl: '', // TMDB doesn't provide direct video URLs
      category: _mapGenreToCategory(genreIds.isNotEmpty ? genreIds.first : 0),
      duration: 7200, // Default 2 hours for movies
      views: voteCount,
      uploadDate: DateTime.tryParse(releaseDate) ?? DateTime.now(),
      quality: voteAverage > 7.0 ? '4K' : '1080p',
      isDownloadable: !isAdult,
    );
  }

  String _mapGenreToCategory(int genreId) {
    switch (genreId) {
      case 28:
        return 'action';
      case 16:
        return 'anime';
      case 35:
        return 'comedy';
      case 18:
        return 'drama';
      case 27:
        return 'horror';
      case 99:
        return 'documentary';
      default:
        return 'drama';
    }
  }
}

class TMDBResponse {
  final int page;
  final int totalResults;
  final int totalPages;
  final List<TMDBMovie> results;

  TMDBResponse({
    required this.page,
    required this.totalResults,
    required this.totalPages,
    required this.results,
  });

  factory TMDBResponse.fromJson(Map<String, dynamic> json) {
    return TMDBResponse(
      page: json['page'] ?? 1,
      totalResults: json['total_results'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => TMDBMovie.fromJson(item))
          .toList(),
    );
  }
}

class TMDBService {
  static const String _apiKey =
      '0e639ce559dc95a787ce4c3267cb79cb'; // Replace with your TMDB API key from https://www.themoviedb.org/settings/api
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _language = 'en-US';

  late final Dio _dio;

  TMDBService() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Get popular videos
  Future<List<VideoModel>> getPopularVideos({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': _language,
        },
      );

      final tmdbResponse = TMDBResponse.fromJson(response.data);
      return tmdbResponse.results.map((movie) => movie.toVideoModel()).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular videos: $e');
    }
  }

  // Get trending videos
  Future<List<VideoModel>> getTrendingVideos({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/trending/movie/day',
        queryParameters: {'api_key': _apiKey, 'page': page},
      );

      final tmdbResponse = TMDBResponse.fromJson(response.data);
      return tmdbResponse.results.map((movie) => movie.toVideoModel()).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending videos: $e');
    }
  }

  // Get new releases
  Future<List<VideoModel>> getNewReleases({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': _language,
        },
      );

      final tmdbResponse = TMDBResponse.fromJson(response.data);
      return tmdbResponse.results.map((movie) => movie.toVideoModel()).toList();
    } catch (e) {
      throw Exception('Failed to fetch new releases: $e');
    }
  }

  // Search videos
  Future<List<VideoModel>> searchVideos(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'page': page,
          'language': _language,
        },
      );

      final tmdbResponse = TMDBResponse.fromJson(response.data);
      return tmdbResponse.results.map((movie) => movie.toVideoModel()).toList();
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }

  // Get videos by category
  Future<List<VideoModel>> getVideosByCategory(
    String category, {
    int page = 1,
  }) async {
    try {
      final genreId = _getCategoryGenreId(category);
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': _apiKey,
          'with_genres': genreId.toString(),
          'page': page,
          'language': _language,
          'sort_by': 'popularity.desc',
        },
      );

      final tmdbResponse = TMDBResponse.fromJson(response.data);
      return tmdbResponse.results.map((movie) => movie.toVideoModel()).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos by category: $e');
    }
  }

  int _getCategoryGenreId(String category) {
    switch (category.toLowerCase()) {
      case 'action':
        return 28;
      case 'anime':
        return 16;
      case 'comedy':
        return 35;
      case 'drama':
        return 18;
      case 'horror':
        return 27;
      case 'documentary':
        return 99;
      default:
        return 18; // Drama as default
    }
  }
}
