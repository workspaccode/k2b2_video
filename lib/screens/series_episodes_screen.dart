import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../models/video_model.dart';
import 'reels_screen.dart';
import 'video_details_screen.dart';

class Episode {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int episodeNumber;
  final int seasonNumber;
  final int duration;
  final bool isWatched;
  final double? watchProgress;
  final bool isReelFormat;
  final DateTime releaseDate;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.duration,
    this.isWatched = false,
    this.watchProgress,
    this.isReelFormat = false,
    required this.releaseDate,
  });
}

class SeriesEpisodesScreen extends StatefulWidget {
  final VideoModel series;

  const SeriesEpisodesScreen({super.key, required this.series});

  @override
  State<SeriesEpisodesScreen> createState() => _SeriesEpisodesScreenState();
}

class _SeriesEpisodesScreenState extends State<SeriesEpisodesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late TabController _tabController;

  List<Episode> episodes = [];
  List<Episode> reels = [];
  int selectedSeason = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _tabController = TabController(length: 2, vsync: this);

    _loadSeriesData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSeriesData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      episodes = _getMockEpisodes();
      reels = _getMockReels();
      isLoading = false;
    });
  }

  List<Episode> _getMockEpisodes() {
    return [
      Episode(
        id: 'ep_1',
        title: 'The Beginning',
        description: 'Our hero\'s journey starts with an unexpected discovery',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Episode+1',
        episodeNumber: 1,
        seasonNumber: 1,
        duration: 2400, // 40 minutes
        isWatched: true,
        watchProgress: 1.0,
        releaseDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Episode(
        id: 'ep_2',
        title: 'The Challenge',
        description: 'First obstacles appear as the adventure unfolds',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Episode+2',
        episodeNumber: 2,
        seasonNumber: 1,
        duration: 2580, // 43 minutes
        isWatched: true,
        watchProgress: 0.7,
        releaseDate: DateTime.now().subtract(const Duration(days: 23)),
      ),
      Episode(
        id: 'ep_3',
        title: 'The Alliance',
        description: 'Unexpected allies join the quest',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/9B59B6/FFFFFF?text=Episode+3',
        episodeNumber: 3,
        seasonNumber: 1,
        duration: 2520, // 42 minutes
        isWatched: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 16)),
      ),
      Episode(
        id: 'ep_4',
        title: 'The Revelation',
        description: 'Hidden truths are revealed',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/F39C12/FFFFFF?text=Episode+4',
        episodeNumber: 4,
        seasonNumber: 1,
        duration: 2640, // 44 minutes
        isWatched: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 9)),
      ),
    ];
  }

  List<Episode> _getMockReels() {
    return [
      Episode(
        id: 'reel_1',
        title: 'Behind the Scenes',
        description: 'Making of Episode 1',
        thumbnailUrl:
            'https://via.placeholder.com/400x600/FF6B6B/FFFFFF?text=BTS+Reel',
        episodeNumber: 1,
        seasonNumber: 1,
        duration: 30,
        isReelFormat: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Episode(
        id: 'reel_2',
        title: 'Character Spotlight',
        description: 'Meet the main character',
        thumbnailUrl:
            'https://via.placeholder.com/400x600/4ECDC4/FFFFFF?text=Character+Reel',
        episodeNumber: 2,
        seasonNumber: 1,
        duration: 45,
        isReelFormat: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 18)),
      ),
      Episode(
        id: 'reel_3',
        title: 'Action Highlights',
        description: 'Best action scenes compilation',
        thumbnailUrl:
            'https://via.placeholder.com/400x600/9B59B6/FFFFFF?text=Action+Reel',
        episodeNumber: 3,
        seasonNumber: 1,
        duration: 60,
        isReelFormat: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0F),
              const Color(0xFF1A1A2E).withValues(alpha: 0.9),
              const Color(0xFF16213E).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader()
                      .animate(controller: _animationController)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0),

                  _buildSeriesInfo()
                      .animate(controller: _animationController)
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0),

                  _buildTabBar()
                      .animate(controller: _animationController)
                      .fadeIn(duration: 800.ms, delay: 400.ms)
                      .slideX(begin: -0.3, end: 0),

                  Expanded(
                    child: isLoading
                        ? _buildLoading()
                        : _buildTabBarView()
                              .animate(controller: _animationController)
                              .fadeIn(duration: 800.ms, delay: 600.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(4, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 1.57);
            final size = 100.0 + (index * 50);
            final opacity = 0.03 - (index * 0.007);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (150 + index * 80) * (index.isEven ? 1 : -1) * 0.6,
              top:
                  MediaQuery.of(context).size.height * 0.4 +
                  (100 + index * 70) * (index.isEven ? 1 : -1) * 0.5,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withValues(alpha: opacity),
                        const Color(
                          0xFFFF6B6B,
                        ).withValues(alpha: opacity * 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: GlassmorphicContainer(
              width: 48,
              height: 48,
              borderRadius: 16,
              blur: 10,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              child: const Icon(
                IconlyLight.arrow_left_2,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.series.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GlassmorphicContainer(
            width: 48,
            height: 48,
            borderRadius: 16,
            blur: 10,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            child: const Icon(
              IconlyLight.bookmark,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 120,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.series.thumbnailUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.series.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Season $selectedSeason • ${episodes.length} Episodes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4ECDC4,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.series.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.series.quality == '4K')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '4K',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 50,
        borderRadius: 25,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Episodes'),
            Tab(text: 'Reels'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [_buildEpisodesList(), _buildReelsList()],
    );
  }

  Widget _buildEpisodesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        return _buildEpisodeCard(episodes[index], index);
      },
    );
  }

  Widget _buildEpisodeCard(Episode episode, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _watchEpisode(episode),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 120,
          borderRadius: 16,
          blur: 10,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: episode.thumbnailUrl,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (episode.isWatched || episode.watchProgress != null)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: episode.watchProgress ?? 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Icon(
                            IconlyBold.play,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B6B,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'EP ${episode.episodeNumber}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (episode.isWatched)
                            const Icon(
                              IconlyBold.tick_square,
                              color: Color(0xFF27AE60),
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        episode.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        episode.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            IconlyBold.time_circle,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(episode.duration),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn();
  }

  Widget _buildReelsList() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        return _buildReelCard(reels[index], index);
      },
    );
  }

  Widget _buildReelCard(Episode reel, int index) {
    return GestureDetector(
          onTap: () => _watchReel(reel),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: reel.thumbnailUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'REEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(IconlyBold.play, color: Colors.white, size: 32),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reel.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reel.duration}s',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 150).ms)
        .scale(begin: const Offset(0.8, 0.8))
        .fadeIn();
  }

  void _watchEpisode(Episode episode) {
    final videoModel = VideoModel(
      id: episode.id,
      title: episode.title,
      description: episode.description,
      thumbnailUrl: episode.thumbnailUrl,
      videoUrl: 'sample_video_url',
      category: widget.series.category,
      duration: episode.duration,
      views: 0,
      uploadDate: episode.releaseDate,
      quality: widget.series.quality,
      isDownloadable: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoDetailsScreen(video: videoModel),
      ),
    );
  }

  void _watchReel(Episode reel) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ReelsScreen()));
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
