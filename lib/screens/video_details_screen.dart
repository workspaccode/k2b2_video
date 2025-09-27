import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../models/video_model.dart';
import 'video_player_screen.dart';

class VideoDetailsScreen extends StatefulWidget {
  final VideoModel video;

  const VideoDetailsScreen({super.key, required this.video});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;

  double _userRating = 0.0;
  bool _isDownloading = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),

                    _buildVideoPreview()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 24),

                    _buildVideoInfo()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    _buildActionButtons()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 24),

                    _buildRatingSection()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 800.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 40),
                  ],
                ),
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
          children: List.generate(5, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 1.257);
            final size = 120.0 + (index * 40);
            final opacity = 0.03 - (index * 0.005);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (150 + index * 60) * (index.isEven ? 1 : -1) * 0.7,
              top:
                  MediaQuery.of(context).size.height * 0.4 +
                  (80 + index * 50) * (index.isEven ? 1 : -1) * 0.6,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF6B6B).withValues(alpha: opacity),
                        const Color(
                          0xFF4ECDC4,
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
          const Expanded(
            child: Text(
              'Video Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _shareVideo(),
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
                IconlyLight.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.video.thumbnailUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () => _playVideo(),
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
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: const Icon(
                    IconlyBold.play,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            if (widget.video.quality == '4K')
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '4K',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 300,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.video.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    icon: IconlyBold.category,
                    label: widget.video.category.toUpperCase(),
                    color: const Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: IconlyBold.time_circle,
                    label: _formatDuration(widget.video.duration),
                    color: const Color(0xFF4ECDC4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    IconlyBold.show,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.video.formattedViews,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    IconlyBold.calendar,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.video.uploadDate),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: IconlyBold.play,
              label: 'Watch Now',
              color: const Color(0xFFFF6B6B),
              onTap: () => _playVideo(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: _isDownloading ? Icons.downloading : IconlyBold.download,
              label: _isDownloading ? 'Downloading...' : 'Download',
              color: const Color(0xFF4ECDC4),
              onTap: () => _downloadVideo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 300,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    IconlyBold.star,
                    color: Color(0xFFFFD93D),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Rate this video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                      _showSnackBar(
                        _isBookmarked
                            ? 'Added to favorites'
                            : 'Removed from favorites',
                      );
                    },
                    child: Icon(
                      _isBookmarked
                          ? IconlyBold.bookmark
                          : IconlyLight.bookmark,
                      color: _isBookmarked
                          ? const Color(0xFFFF6B6B)
                          : Colors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _userRating = index + 1.0;
                      });
                      _showSnackBar('Rated ${index + 1} stars');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _userRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFD93D),
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              if (_userRating > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Thank you for rating! (${_userRating.toInt()}/5)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: widget.video),
      ),
    );
  }

  void _downloadVideo() {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    // Simulate download
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        _showSnackBar('Download completed!');
      }
    });
  }

  void _shareVideo() async {
    _showSnackBar('Sharing: ${widget.video.title}');
    // TODO: Implement sharing functionality
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
