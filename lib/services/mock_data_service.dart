import '../models/category_model.dart';
import '../models/video_model.dart';
import 'api/anime_api_service.dart';
import 'api/tmdb_api_service.dart';

class MockDataService {
  static final TMDBService _tmdbService = TMDBService();
  static final AnimeApiService _animeService = AnimeApiService();

  // Use real API for new videos with fallback
  static Future<List<VideoModel>> getNewVideos() async {
    try {
      // Add loading delay to show shimmer
      await Future.delayed(const Duration(seconds: 2));

      final apiVideos = await _tmdbService.getNewReleases();
      return apiVideos.isNotEmpty ? apiVideos : _getMockNewVideos();
    } catch (e) {
      print('API Error: $e');
      // Always return mock data when API fails
      return _getMockNewVideos();
    }
  }

  // Use real API for trending/most watched videos with fallback
  static Future<List<VideoModel>> getMostWatchedVideos() async {
    try {
      // Add loading delay to show shimmer
      await Future.delayed(const Duration(seconds: 1));

      final apiVideos = await _tmdbService.getTrendingVideos();
      return apiVideos.isNotEmpty ? apiVideos : _getMockMostWatchedVideos();
    } catch (e) {
      print('API Error: $e');
      // Always return mock data when API fails
      return _getMockMostWatchedVideos();
    }
  }

  // Get anime videos with Arabic summaries
  static Future<List<VideoModel>> getAnimeVideos() async {
    try {
      print('🎌 Starting anime data fetch...');
      // Add loading delay to show shimmer
      await Future.delayed(const Duration(seconds: 1));

      print('📡 Attempting to fetch from Jikan API...');
      // Get popular anime from Jikan API
      final animeList = await _animeService.getPopularAnime();

      if (animeList.isNotEmpty) {
        print(
          '✅ Successfully fetched ${animeList.length} anime from Jikan API',
        );
        final videoModels = animeList
            .map((anime) => anime.toVideoModel())
            .toList();
        return videoModels;
      } else {
        print('⚠️ Jikan API returned empty list, using mock data');
        return _getMockAnimeVideos();
      }
    } catch (e) {
      print('❌ Anime API Error: $e');
      print('🔄 Falling back to mock anime data...');
      // Always return mock anime data when API fails
      return _getMockAnimeVideos();
    }
  }

  // Get specific anime with Arabic summaries
  static Future<Map<String, dynamic>> getAnimeWithSummary(int animeId) async {
    try {
      final result = await _animeService.getAnimeWithArabicSummary(animeId);
      return result;
    } catch (e) {
      print('Anime with summary error: $e');
      // Return mock data
      return {
        'anime': null,
        'arabicSummaries': <dynamic>[],
        'videoModel': _getMockAnimeVideos().first,
      };
    }
  }

  // Search anime
  static Future<List<VideoModel>> searchAnime(String query) async {
    try {
      final animeList = await _animeService.searchAnime(query);
      return animeList.map((anime) => anime.toVideoModel()).toList();
    } catch (e) {
      print('Anime search error: $e');
      return _getMockAnimeVideos()
          .where(
            (video) => video.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // Categories (static data)
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: 'anime',
        name: 'Anime',
        iconUrl: 'https://via.placeholder.com/120x120/FF6B6B/FFFFFF?text=🎌',
        coverImageUrl:
            'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Anime',
        description: 'Japanese animated series and movies',
        subCategories: ['Shonen', 'Shoujo', 'Seinen', 'Josei', 'Mecha'],
        videoCount: 250,
        isPopular: true,
      ),
      CategoryModel(
        id: 'action',
        name: 'Action',
        iconUrl: 'https://via.placeholder.com/120x120/4ECDC4/FFFFFF?text=💥',
        coverImageUrl:
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Action',
        description: 'High-energy action movies and series',
        subCategories: [
          'Martial Arts',
          'Thriller',
          'Adventure',
          'Crime',
          'War',
        ],
        videoCount: 180,
        isPopular: true,
      ),
      CategoryModel(
        id: 'drama',
        name: 'Drama',
        iconUrl: 'https://via.placeholder.com/120x120/45B7D1/FFFFFF?text=🎭',
        coverImageUrl:
            'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Drama',
        description: 'Emotional and character-driven stories',
        subCategories: ['Romance', 'Family', 'Historical', 'Medical', 'Legal'],
        videoCount: 320,
        isPopular: true,
      ),
      CategoryModel(
        id: 'comedy',
        name: 'Comedy',
        iconUrl: 'https://via.placeholder.com/120x120/F7DC6F/000000?text=😂',
        coverImageUrl:
            'https://via.placeholder.com/300x200/F7DC6F/000000?text=Comedy',
        description: 'Funny and entertaining content',
        subCategories: ['Romantic Comedy', 'Stand-up', 'Sitcom', 'Parody'],
        videoCount: 150,
        isPopular: false,
      ),
      CategoryModel(
        id: 'horror',
        name: 'Horror',
        iconUrl: 'https://via.placeholder.com/120x120/8E44AD/FFFFFF?text=👻',
        coverImageUrl:
            'https://via.placeholder.com/300x200/8E44AD/FFFFFF?text=Horror',
        description: 'Scary and suspenseful content',
        subCategories: ['Psychological', 'Supernatural', 'Slasher', 'Zombie'],
        videoCount: 95,
        isPopular: false,
      ),
      CategoryModel(
        id: 'documentary',
        name: 'Documentary',
        iconUrl: 'https://via.placeholder.com/120x120/E67E22/FFFFFF?text=📹',
        coverImageUrl:
            'https://via.placeholder.com/300x200/E67E22/FFFFFF?text=Documentary',
        description: 'Educational and informative content',
        subCategories: [
          'Nature',
          'History',
          'Science',
          'True Crime',
          'Biography',
        ],
        videoCount: 120,
        isPopular: false,
      ),
    ];
  }

  // Mock data fallback methods
  static List<VideoModel> _getMockNewVideos() {
    return [
      VideoModel(
        id: 'new_1',
        title: 'Attack on Titan Final Season',
        description: 'The epic conclusion of the popular anime series',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=AOT+Final',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 2500000,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'new_2',
        title: 'John Wick 4: Extended Cut',
        description: 'The latest installment in the action-packed series',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=John+Wick+4',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 9600,
        views: 1800000,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'new_3',
        title: 'Spider-Man: Across the Spider-Verse',
        description: 'Miles Morales catapults across the Multiverse',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/9B59B6/FFFFFF?text=Spider+Verse',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 8400,
        views: 3200000,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'new_4',
        title: 'Wednesday Season 2',
        description: 'More dark humor and supernatural mysteries',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/34495E/FFFFFF?text=Wednesday',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        duration: 3600,
        views: 1900000,
        uploadDate: DateTime.now().subtract(const Duration(days: 4)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'new_5',
        title: 'The Last of Us Episode 9',
        description: 'The highly anticipated season finale',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/E67E22/FFFFFF?text=Last+of+Us',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        duration: 4200,
        views: 4100000,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        quality: '4K',
        isDownloadable: true,
      ),
    ];
  }

  static List<VideoModel> _getMockMostWatchedVideos() {
    return [
      VideoModel(
        id: 'popular_1',
        title: 'One Piece: Wano Arc',
        description: 'The legendary arc everyone\'s talking about',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=One+Piece',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 8500000,
        uploadDate: DateTime.now().subtract(const Duration(days: 30)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'popular_2',
        title: 'Avengers: Endgame',
        description: 'The epic conclusion to the Infinity Saga',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Avengers',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 10800,
        views: 12000000,
        uploadDate: DateTime.now().subtract(const Duration(days: 45)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'popular_3',
        title: 'Stranger Things 4',
        description: 'The gang faces their biggest threat yet',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/E74C3C/FFFFFF?text=Stranger+Things',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        duration: 4800,
        views: 9800000,
        uploadDate: DateTime.now().subtract(const Duration(days: 60)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'popular_4',
        title: 'Top Gun: Maverick',
        description: 'Pete "Maverick" Mitchell returns to action',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/F39C12/FFFFFF?text=Top+Gun',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 7800,
        views: 7200000,
        uploadDate: DateTime.now().subtract(const Duration(days: 90)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'popular_5',
        title: 'The Bear Season 2',
        description: 'More culinary chaos and kitchen drama',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/27AE60/FFFFFF?text=The+Bear',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'comedy',
        duration: 1800,
        views: 5400000,
        uploadDate: DateTime.now().subtract(const Duration(days: 75)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'popular_6',
        title: 'Oppenheimer',
        description: 'The story of the atomic bomb creator',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/2C3E50/FFFFFF?text=Oppenheimer',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        duration: 10800,
        views: 6900000,
        uploadDate: DateTime.now().subtract(const Duration(days: 50)),
        quality: '4K',
        isDownloadable: true,
      ),
    ];
  }

  static List<VideoModel> _getMockAnimeVideos() {
    return [
      VideoModel(
        id: 'anime_1',
        title: 'Attack on Titan (Shingeki no Kyojin)',
        description:
            'Humanity fights for survival against giant humanoid Titans. Eren Yeager vows to wipe out every last Titan.',
        thumbnailUrl:
            'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Attack+on+Titan',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440, // 24 minutes
        views: 5200000,
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'anime_2',
        title: 'One Piece',
        description:
            'Follow Monkey D. Luffy on his quest to become the Pirate King and find the legendary treasure One Piece.',
        thumbnailUrl:
            'https://via.placeholder.com/300x400/4ECDC4/FFFFFF?text=One+Piece',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 8900000,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'anime_3',
        title: 'Demon Slayer (Kimetsu no Yaiba)',
        description:
            'Tanjiro Kamado becomes a demon slayer to save his sister Nezuko and avenge his family.',
        thumbnailUrl:
            'https://via.placeholder.com/300x400/9B59B6/FFFFFF?text=Demon+Slayer',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 6700000,
        uploadDate: DateTime.now().subtract(const Duration(days: 14)),
        quality: '4K',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'anime_4',
        title: 'Jujutsu Kaisen',
        description:
            'Yuji Itadori joins a secret organization of Jujutsu Sorcerers to kill a powerful Curse named Ryomen Sukuna.',
        thumbnailUrl:
            'https://via.placeholder.com/300x400/E74C3C/FFFFFF?text=Jujutsu+Kaisen',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 4800000,
        uploadDate: DateTime.now().subtract(const Duration(days: 21)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'anime_5',
        title: 'My Hero Academia (Boku no Hero Academia)',
        description:
            'In a world where superpowers are common, Izuku Midoriya dreams of becoming a hero despite being born without powers.',
        thumbnailUrl:
            'https://via.placeholder.com/300x400/27AE60/FFFFFF?text=My+Hero+Academia',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1440,
        views: 5500000,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        quality: '4K',
        isDownloadable: true,
      ),
    ];
  }

  // User-specific data (kept as sync for now)
  static List<VideoModel> getLastWatchedVideos() {
    return [
      VideoModel(
        id: 'watched_1',
        title: 'Demon Slayer: Entertainment District',
        description: 'Tanjiro and friends face new demons',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Demon+Slayer',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'anime',
        duration: 1380,
        views: 3200000,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        quality: '1080p',
        isWatched: true,
        lastWatchedPosition: 890,
      ),
      VideoModel(
        id: 'watched_2',
        title: 'Mission Impossible 7',
        description: 'Ethan Hunt\'s most dangerous mission yet',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=MI+7',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 9000,
        views: 2100000,
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        quality: '4K',
        isWatched: true,
        lastWatchedPosition: 4500,
      ),
      VideoModel(
        id: 'watched_3',
        title: 'House of the Dragon Episode 8',
        description: 'The Targaryen civil war intensifies',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/8E44AD/FFFFFF?text=House+Dragon',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        duration: 3600,
        views: 4800000,
        uploadDate: DateTime.now().subtract(const Duration(days: 20)),
        quality: '4K',
        isWatched: true,
        lastWatchedPosition: 2100,
      ),
      VideoModel(
        id: 'watched_4',
        title: 'The Mandalorian Season 3',
        description: 'Din Djarin continues his journey',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/34495E/FFFFFF?text=Mandalorian',
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        duration: 2700,
        views: 6200000,
        uploadDate: DateTime.now().subtract(const Duration(days: 8)),
        quality: '4K',
        isWatched: true,
        lastWatchedPosition: 1800,
      ),
    ];
  }

  static VideoModel? getCurrentVideo() {
    return VideoModel(
      id: 'current_1',
      title: 'Stranger Things Season 4',
      description: 'The kids face their biggest threat yet',
      thumbnailUrl:
          'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Stranger+Things',
      videoUrl:
          'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      category: 'drama',
      duration: 4200,
      views: 5200000,
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      quality: '1080p',
      isWatched: false,
      lastWatchedPosition: 1200,
    );
  }

  // Search and category methods
  static Future<List<VideoModel>> searchVideos(String query) async {
    try {
      return await _tmdbService.searchVideos(query);
    } catch (e) {
      return [];
    }
  }

  static Future<List<VideoModel>> getVideosByCategory(String categoryId) async {
    try {
      return await _tmdbService.getVideosByCategory(categoryId);
    } catch (e) {
      // Fallback to filtering mock data
      final allVideos = [
        ..._getMockNewVideos(),
        ..._getMockMostWatchedVideos(),
      ];
      return allVideos.where((video) => video.category == categoryId).toList();
    }
  }
}
