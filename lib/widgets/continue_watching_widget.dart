import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';

import '../models/video_model.dart';
import '../services/mock_data_service.dart';

class ContinueWatchingWidget extends StatefulWidget {
  const ContinueWatchingWidget({super.key});

  @override
  State<ContinueWatchingWidget> createState() => _ContinueWatchingWidgetState();
}

class _ContinueWatchingWidgetState extends State<ContinueWatchingWidget>
    with TickerProviderStateMixin {
  List<VideoModel> _watchingVideos = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadWatchingVideos();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadWatchingVideos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    _watchingVideos = MockDataService.getLastWatchedVideos();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader()
            .animate(controller: _animationController)
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 16),

        // Continue watching list
        SizedBox(
          height: 200,
          child: _isLoading ? _buildShimmerList() : _buildWatchingList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(IconlyBold.play, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Continue Watching',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),

          if (_watchingVideos.isNotEmpty)
            GestureDetector(
              onTap: _showAllWatchingVideos,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      IconlyLight.arrow_right_2,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWatchingList() {
    if (_watchingVideos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _watchingVideos.length,
      itemBuilder: (context, index) {
        final video = _watchingVideos[index];
        return _buildWatchingCard(video, index);
      },
    );
  }

  Widget _buildWatchingCard(VideoModel video, int index) {
    final lastPosition = video.lastWatchedPosition ?? 0;
    final progress = lastPosition / video.duration;
    final remainingTime = video.duration - lastPosition;

    return Container(
      width: 280,
      margin: EdgeInsets.only(
        right: index == _watchingVideos.length - 1 ? 0 : 16,
      ),
      child: GestureDetector(
        onTap: () => _handleVideoPlay(video),
        child:
            GlassmorphicContainer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 16,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                      const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                      const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Thumbnail with progress overlay
                      Container(
                        width: 100,
                        height: double.infinity,
                        margin: const EdgeInsets.all(8),
                        child: Stack(
                          children: [
                            // Thumbnail
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: video.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: const Color(0xFF1A1A2E),
                                        highlightColor: const Color(0xFF16213E),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF4ECDC4,
                                              ).withValues(alpha: 0.5),
                                              const Color(
                                                0xFFFF6B6B,
                                              ).withValues(alpha: 0.5),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                IconlyBold.download,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Downloaded',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),

                            // Progress overlay
                            Positioned(
                              bottom: 4,
                              left: 4,
                              right: 4,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4ECDC4),
                                          Color(0xFFFF6B6B),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Play icon overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withValues(alpha: 0.2),
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

                            // Quality badge
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video.quality,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Video info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Progress text
                              Text(
                                '${(progress * 100).toInt()}% watched',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF4ECDC4,
                                  ).withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),

                              // Time remaining
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_formatDuration(remainingTime)} left',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Action buttons
                              Row(
                                children: [
                                  // Continue button
                                  Expanded(
                                    child: Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4ECDC4),
                                            Color(0xFFFF6B6B),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Remove button
                                  GestureDetector(
                                    onTap: () =>
                                        _removeFromContinueWatching(video),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        IconlyLight.close_square,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: (index * 150).ms)
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.3, end: 0)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 280,
          margin: EdgeInsets.only(right: index == 2 ? 0 : 16),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            const Color(0xFFFFFFFF).withValues(alpha: 0.02),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            const Color(0xFFFFFFFF).withValues(alpha: 0.05),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.play,
              color: Colors.white.withValues(alpha: 0.4),
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              'No videos in progress',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Start watching to see your progress here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVideoPlay(VideoModel video) {
    // Show login dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassmorphicContainer(
          width: 320,
          height: 280,
          borderRadius: 24,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    IconlyBold.lock,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Login Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Please sign in to continue watching "${video.title}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to auth screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _removeFromContinueWatching(VideoModel video) {
    setState(() {
      _watchingVideos.removeWhere((v) => v.id == video.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${video.title}" from continue watching'),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _watchingVideos.add(video);
            });
          },
        ),
      ),
    );
  }

  void _showAllWatchingVideos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 24,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Continue Watching',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${_watchingVideos.length} videos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Videos list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _watchingVideos.length,
                  itemBuilder: (context, index) {
                    final video = _watchingVideos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildWatchingCard(video, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
