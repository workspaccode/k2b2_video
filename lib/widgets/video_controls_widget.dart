import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../services/video_player_service.dart';

class VideoControlsWidget extends StatelessWidget {
  final VideoPlayerService playerService;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onBack;

  const VideoControlsWidget({
    super.key,
    required this.playerService,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackProgress>(
      stream: playerService.progressStream,
      builder: (context, snapshot) {
        final progress =
            snapshot.data ??
            PlaybackProgress(
              position: Duration.zero,
              duration: Duration.zero,
              state: PlaybackState.idle,
              currentQuality: VideoQuality.auto,
            );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top controls
            _buildTopControls(context),

            const Spacer(),

            // Progress bar
            _buildProgressBar(context, progress),

            const SizedBox(height: 8),

            // Bottom controls
            _buildBottomControls(progress),
          ],
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
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
              child: Icon(
                isFullscreen
                    ? IconlyLight
                          .arrow_left_2 // Using consistent light style
                    : IconlyLight.arrow_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          // Fullscreen toggle
          GestureDetector(
            onTap: onToggleFullscreen,
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
              child: Icon(
                isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, PlaybackProgress progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF6B6B),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: const Color(0xFFFF6B6B),
              overlayColor: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: progress.progressPercent.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (value * progress.duration.inMilliseconds)
                      .toInt(),
                );
                playerService.seekTo(newPosition);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress.positionText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  progress.durationText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(PlaybackProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip backward
          IconButton(
            onPressed: () => playerService.skipBackward(10),
            icon: const Icon(IconlyBold.arrow_left_2, color: Colors.white),
            iconSize: 32,
          ),

          // Play/Pause
          GestureDetector(
            onTap: () {
              if (progress.state == PlaybackState.playing) {
                playerService.pause();
              } else {
                playerService.resume();
              }
            },
            child: GlassmorphicContainer(
              width: 60,
              height: 60,
              borderRadius: 30,
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
              child: Icon(
                progress.state == PlaybackState.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Skip forward
          IconButton(
            onPressed: () => playerService.skipForward(10),
            icon: const Icon(IconlyBold.arrow_right_2, color: Colors.white),
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}
