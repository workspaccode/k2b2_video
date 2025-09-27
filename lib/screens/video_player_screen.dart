import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';
import '../services/video_player_service.dart';
import '../widgets/video_controls_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final bool isLocal; // Whether the video is a local file
  final String? localPath; // Path to local video file

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.isLocal = false,
    this.localPath,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  final VideoPlayerService _playerService = VideoPlayerService();
  late AnimationController _controlsController;
  late AnimationController _fadeController;
  bool _showControls = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _controlsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize video playback
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _playerService.playVideo(widget.video);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controlsController.dispose();
    _fadeController.dispose();
    _playerService.stop();
    _playerService.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsController.forward();
    } else {
      _controlsController.reverse();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    _playerService.toggleFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isFullscreen
            ? _buildFullscreenPlayer()
            : _buildPortraitPlayer(),
      ),
    );
  }

  Widget _buildPortraitPlayer() {
    return Column(
      children: [_buildVideoPlayer(), _buildVideoInfo(), _buildRelatedVideos()],
    );
  }

  Widget _buildFullscreenPlayer() {
    return Stack(children: [_buildVideoPlayer(), _buildFullscreenControls()]);
  }

  Widget _buildVideoPlayer() {
    return Expanded(
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video display
            StreamBuilder<PlaybackProgress>(
              stream: _playerService.progressStream,
              builder: (context, snapshot) {
                if (_playerService.hasController &&
                    _playerService.controller != null &&
                    _playerService.controller!.value.isInitialized) {
                  return VideoPlayer(_playerService.controller!);
                }

                // Loading state
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  ),
                );
              },
            ),

            // Overlay controls
            if (_showControls) ...[_buildVideoControls()],

            // Loading indicator
            StreamBuilder<PlaybackProgress>(
              stream: _playerService.progressStream,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data!.state == PlaybackState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return VideoControlsWidget(
      playerService: _playerService,
      isFullscreen: _isFullscreen,
      onToggleFullscreen: _toggleFullscreen,
      onBack: () {
        if (_isFullscreen) {
          _toggleFullscreen();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildFullscreenControls() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _controlsController,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 60,
          borderRadius: 30,
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
          child: VideoControlsWidget(
            playerService: _playerService,
            isFullscreen: _isFullscreen,
            onToggleFullscreen: _toggleFullscreen,
            onBack: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0F).withValues(alpha: 0.9),
            const Color(0xFF0A0A0F),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: IconlyBold.show,
                label: widget.video.formattedViews,
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                icon: IconlyBold.time_circle,
                label: widget.video.formattedDuration,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(IconlyBold.heart, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(IconlyBold.chat, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(IconlyBold.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideos() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1A1A2E),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/180x120/FF6B6B/FFFFFF?text=Related',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    'Related Video ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
