import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../models/video_model.dart';
import '../screens/video_player_screen.dart';
import '../services/youtube_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  final YouTubeService _youtubeService = YouTubeService();
  List<VideoModel> reels = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    try {
      // Load trending videos from YouTube
      final trendingVideos = await _youtubeService.getTrendingVideos(limit: 10);
      setState(() {
        reels = trendingVideos;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading reels: $e');
      // Fallback to mock data
      setState(() {
        reels = _getMockReels();
        isLoading = false;
      });
    }
  }

  List<VideoModel> _getMockReels() {
    return [
      VideoModel(
        id: 'reel_1',
        title: 'Amazing Action Scene',
        description: 'Epic fight scene from latest movie',
        thumbnailUrl:
            'https://via.placeholder.com/400x800/FF6B6B/FFFFFF?text=Action+Reel',
        videoUrl: 'sample_video_url',
        category: 'action',
        duration: 30,
        views: 125000,
        uploadDate: DateTime.now().subtract(const Duration(hours: 2)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'reel_2',
        title: 'Anime Highlight',
        description: 'Best moments from popular anime',
        thumbnailUrl:
            'https://via.placeholder.com/400x800/4ECDC4/FFFFFF?text=Anime+Reel',
        videoUrl: 'sample_video_url',
        category: 'anime',
        duration: 45,
        views: 89000,
        uploadDate: DateTime.now().subtract(const Duration(hours: 5)),
        quality: '1080p',
        isDownloadable: true,
      ),
      VideoModel(
        id: 'reel_3',
        title: 'Comedy Gold',
        description: 'Hilarious moments compilation',
        thumbnailUrl:
            'https://via.placeholder.com/400x800/9B59B6/FFFFFF?text=Comedy+Reel',
        videoUrl: 'sample_video_url',
        category: 'comedy',
        duration: 25,
        views: 200000,
        uploadDate: DateTime.now().subtract(const Duration(hours: 8)),
        quality: '1080p',
        isDownloadable: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading ? _buildLoading() : _buildReelsView(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
    );
  }

  Widget _buildReelsView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: reels.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildReelItem(reels[index], index);
          },
        ),
        _buildTopBar(),
        _buildSideActions(),
      ],
    );
  }

  Widget _buildReelItem(VideoModel reel, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: reel),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Video/Image Background
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: reel.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Play Button
            Center(
                  child: GlassmorphicContainer(
                    width: 80,
                    height: 80,
                    borderRadius: 40,
                    blur: 10,
                    alignment: Alignment.center,
                    border: 2,
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
                      IconlyBold.play,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
                .animate(delay: (index * 200).ms)
                .scale(begin: const Offset(0.5, 0.5))
                .fadeIn(),

            // Bottom Info
            Positioned(
              bottom: 100,
              left: 20,
              right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reel.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        IconlyBold.heart,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${reel.views}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        IconlyBold.time_circle,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${reel.duration}s',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: (index * 300).ms).slideX(begin: -0.3).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: GlassmorphicContainer(
              width: 40,
              height: 40,
              borderRadius: 20,
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
          const Spacer(),
          const Text(
            'Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GlassmorphicContainer(
            width: 40,
            height: 40,
            borderRadius: 20,
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
              IconlyLight.search,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideActions() {
    if (reels.isEmpty) return const SizedBox.shrink();

    final currentReel = reels[currentIndex];

    return Positioned(
      right: 20,
      bottom: 120,
      child: Column(
        children: [
          _buildActionButton(
            icon: IconlyBold.heart,
            label: _formatNumber(currentReel.views),
            onTap: () => _showSnackBar('Liked!'),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: IconlyBold.chat,
            label: '234',
            onTap: () => _showSnackBar('Comments'),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: IconlyBold.send,
            label: 'Share',
            onTap: () => _showSnackBar('Shared!'),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: IconlyBold.download,
            label: 'Save',
            onTap: () => _showSnackBar('Downloading...'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassmorphicContainer(
            width: 50,
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
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
