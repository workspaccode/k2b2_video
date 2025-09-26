import 'lib/services/api/anime_api_service.dart';

/// Test script to verify the Jikan API integration
/// Run this with: dart test_anime_api.dart
void main() async {
  print('🎌 Testing Anime API Integration (Jikan + YouTube)');
  print('=' * 50);

  final animeService = AnimeApiService();

  try {
    // Test 1: Get anime by ID (using popular anime ID)
    print('\n📺 Test 1: Fetching specific anime (One Piece - ID: 21)...');
    final anime = await animeService.getAnimeById(21);
    print('✅ Success: ${anime.title}');
    print('   Score: ${anime.score}');
    print('   Synopsis: ${anime.synopsis.substring(0, 100)}...');
    print('   Image URL: ${anime.imageUrl}');

    // Test 2: Get popular anime list
    print('\n🏆 Test 2: Fetching popular anime list...');
    final popularAnime = await animeService.getPopularAnime();
    print('✅ Success: Found ${popularAnime.length} popular anime');

    for (
      int i = 0;
      i < (popularAnime.length > 5 ? 5 : popularAnime.length);
      i++
    ) {
      final anime = popularAnime[i];
      print('   ${i + 1}. ${anime.title} (Score: ${anime.score})');
    }

    // Test 3: Get seasonal anime
    print('\n🗓️ Test 3: Fetching current seasonal anime...');
    final seasonalAnime = await animeService.getSeasonalAnime();
    print('✅ Success: Found ${seasonalAnime.length} seasonal anime');

    for (
      int i = 0;
      i < (seasonalAnime.length > 3 ? 3 : seasonalAnime.length);
      i++
    ) {
      final anime = seasonalAnime[i];
      print('   ${i + 1}. ${anime.title} (${anime.type})');
    }

    // Test 4: Search for Arabic summaries (demo with mock)
    print('\n🎥 Test 4: Testing Arabic summary search format...');
    if (popularAnime.isNotEmpty) {
      final testAnime = popularAnime.first;
      print('✅ Sample search query for "${testAnime.title}":');
      print('   YouTube Query: "ملخص ${testAnime.title} أنمي"');
      print('   This would search for Arabic anime summaries on YouTube');
    }

    // Test 5: Convert to VideoModel
    print('\n🎬 Test 5: Converting anime to VideoModel...');
    if (popularAnime.isNotEmpty) {
      final videoModel = popularAnime.first.toVideoModel();
      print('✅ Success: VideoModel created');
      print('   ID: ${videoModel.id}');
      print('   Title: ${videoModel.title}');
      print('   Category: ${videoModel.category}');
      print('   Views: ${videoModel.views}');
      print('   Quality: ${videoModel.quality}');
    }

    print('\n' + '=' * 50);
    print('🎉 All tests completed successfully!');
    print('🌟 Jikan API integration is working with satisfying results!');
    print('\n📊 Summary:');
    print('   ✅ Anime fetching from Jikan API: Working');
    print('   ✅ Popular anime ranking: Working');
    print('   ✅ Seasonal anime: Working');
    print('   ✅ VideoModel conversion: Working');
    print('   ✅ Arabic summary search format: Ready');
    print('\n💡 Note: YouTube API requires valid API key for Arabic summaries');
  } catch (e) {
    print('\n❌ Error during testing: $e');
    print('\n🔧 This might be due to:');
    print('   - Network connectivity issues');
    print('   - Jikan API rate limiting');
    print('   - API temporary unavailability');
    print('\n📝 The app will fallback to mock anime data in such cases.');
  }
}
