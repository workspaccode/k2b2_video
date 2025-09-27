import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';
import 'youtube_service.dart';

enum PlaybackState { idle, loading, playing, paused, buffering, ended, error }

enum VideoQuality {
  auto,
  p144,
  p240,
  p360,
  p480,
  p720,
  p1080,
  p1440,
  p2160, // 4K
}

class PlaybackProgress {
  final Duration position;
  final Duration duration;
  final PlaybackState state;
  final VideoQuality currentQuality;
  final bool isBuffering;
  final double bufferPercent;

  PlaybackProgress({
    required this.position,
    required this.duration,
    required this.state,
    required this.currentQuality,
    this.isBuffering = false,
    this.bufferPercent = 0.0,
  });

  double get progressPercent {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  String get positionText => _formatDuration(position);
  String get durationText => _formatDuration(duration);
  String get remainingText => _formatDuration(duration - position);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

class VideoPlayerService {
  static final VideoPlayerService _instance = VideoPlayerService._internal();
  factory VideoPlayerService() => _instance;
  VideoPlayerService._internal();

  final YouTubeService _youtubeService = YouTubeService();
  VideoPlayerController? _controller;
  final StreamController<PlaybackProgress> _progressController =
      StreamController<PlaybackProgress>.broadcast();

  Timer? _progressTimer;
  VideoModel? _currentVideo;
  PlaybackState _currentState = PlaybackState.idle;
  Duration _currentPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;
  VideoQuality _currentQuality = VideoQuality.auto;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;

  // Getters
  Stream<PlaybackProgress> get progressStream => _progressController.stream;
  VideoModel? get currentVideo => _currentVideo;
  PlaybackState get currentState => _currentState;
  Duration get currentPosition => _currentPosition;
  Duration get videoDuration => _videoDuration;
  VideoQuality get currentQuality => _currentQuality;
  bool get isFullscreen => _isFullscreen;
  double get playbackSpeed => _playbackSpeed;
  double get volume => _volume;
  bool get isPlaying => _currentState == PlaybackState.playing;
  bool get isPaused => _currentState == PlaybackState.paused;
  bool get hasController => _controller != null;
  VideoPlayerController? get controller => _controller;

  /// Initialize and play a video
  Future<void> playVideo(VideoModel video, {Duration? startPosition}) async {
    try {
      _currentVideo = video;
      _currentState = PlaybackState.loading;
      _notifyProgress();

      // Dispose existing controller
      await _controller?.dispose();
      _controller = null;

      // Get video stream URL
      String videoUrl;
      if (video.videoUrl.contains('youtube.com') ||
          video.videoUrl.contains('youtu.be')) {
        // Extract YouTube video ID
        final uri = Uri.parse(video.videoUrl);
        final videoId =
            uri.queryParameters['v'] ??
            uri.pathSegments.lastWhere(
              (segment) => segment.isNotEmpty,
              orElse: () => '',
            );

        if (videoId.isNotEmpty) {
          videoUrl = await _youtubeService.getVideoStreamUrl(videoId);
        } else {
          throw Exception('Invalid YouTube URL');
        }
      } else {
        videoUrl = video.videoUrl;
      }

      // Initialize video player controller
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _controller!.initialize();

      // Set initial position if provided
      if (startPosition != null) {
        await _controller!.seekTo(startPosition);
      }

      // Set up controller listeners
      _controller!.addListener(_onControllerUpdate);

      // Set video duration
      _videoDuration = _controller!.value.duration;
      _currentPosition = startPosition ?? Duration.zero;

      // Start playback
      await _controller!.setVolume(_volume);
      await _controller!.setPlaybackSpeed(_playbackSpeed);
      await _controller!.play();

      _currentState = PlaybackState.playing;
      _startProgressTimer();
      _notifyProgress();

      if (kDebugMode) {
        print('🎬 Playing: ${video.title}');
        print('📍 Starting at: ${_formatDuration(_currentPosition)}');
      }
    } catch (e) {
      _currentState = PlaybackState.error;
      _notifyProgress();
      if (kDebugMode) {
        print('❌ Error playing video: $e');
      }
    }
  }

  void _onControllerUpdate() {
    if (_controller == null) return;

    final value = _controller!.value;

    // Update state based on controller value
    if (value.isInitialized) {
      _videoDuration = value.duration;
      _currentPosition = value.position;

      // Update playback state
      if (value.isPlaying) {
        _currentState = PlaybackState.playing;
      } else if (value.position >= value.duration) {
        _currentState = PlaybackState.ended;
        _stopProgressTimer();
      } else {
        _currentState = PlaybackState.paused;
      }

      _notifyProgress();
    }
  }

  /// Pause playback
  void pause() {
    if (_controller != null && _controller!.value.isPlaying) {
      _controller!.pause();
      _currentState = PlaybackState.paused;
      _stopProgressTimer();
      _notifyProgress();

      if (kDebugMode) {
        print('⏸️ Video paused at: ${_formatDuration(_currentPosition)}');
      }
    }
  }

  /// Resume playback
  void resume() {
    if (_controller != null && !_controller!.value.isPlaying) {
      _controller!.play();
      _currentState = PlaybackState.playing;
      _startProgressTimer();
      _notifyProgress();

      if (kDebugMode) {
        print('▶️ Video resumed at: ${_formatDuration(_currentPosition)}');
      }
    }
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (_currentState == PlaybackState.playing) {
      pause();
    } else if (_currentState == PlaybackState.paused) {
      resume();
    }
  }

  /// Seek to specific position
  void seekTo(Duration position) {
    if (_controller == null || _currentVideo == null) return;

    // Custom clamp implementation for Duration
    Duration clampedPosition = position;
    if (position < Duration.zero) {
      clampedPosition = Duration.zero;
    } else if (position > _videoDuration && _videoDuration > Duration.zero) {
      clampedPosition = _videoDuration;
    }

    _controller!.seekTo(clampedPosition);
    _currentPosition = clampedPosition;
    _notifyProgress();

    if (kDebugMode) {
      print('⏭️ Seeked to: ${_formatDuration(_currentPosition)}');
    }
  }

  /// Skip forward by seconds
  void skipForward([int seconds = 10]) {
    final newPosition = _currentPosition + Duration(seconds: seconds);
    seekTo(newPosition);
  }

  /// Skip backward by seconds
  void skipBackward([int seconds = 10]) {
    final newPosition = _currentPosition - Duration(seconds: seconds);
    seekTo(newPosition);
  }

  /// Change video quality
  void changeQuality(VideoQuality quality) {
    _currentQuality = quality;
    _currentState = PlaybackState.buffering;
    _notifyProgress();

    // Simulate quality change buffering
    Timer(const Duration(milliseconds: 800), () {
      _currentState = PlaybackState.playing;
      _notifyProgress();

      if (kDebugMode) {
        print('🎥 Quality changed to: ${_getQualityName(quality)}');
      }
    });
  }

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed.clamp(0.25, 2.0);

    if (_controller != null) {
      _controller!.setPlaybackSpeed(_playbackSpeed);
      _stopProgressTimer();
      if (_currentState == PlaybackState.playing) {
        _startProgressTimer();
      }
    }

    _notifyProgress();

    if (kDebugMode) {
      print('⚡ Playback speed: ${_playbackSpeed}x');
    }
  }

  /// Set volume
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);

    if (_controller != null) {
      _controller!.setVolume(_volume);
    }

    if (kDebugMode) {
      print('🔊 Volume: ${(_volume * 100).round()}%');
    }
  }

  /// Toggle fullscreen
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;

    if (kDebugMode) {
      print('📺 Fullscreen: $_isFullscreen');
    }
  }

  /// Stop playback
  void stop() {
    _stopProgressTimer();
    _currentState = PlaybackState.idle;
    _currentPosition = Duration.zero;
    _currentVideo = null;
    _isFullscreen = false;

    // Dispose video controller
    _controller?.dispose();
    _controller = null;

    _notifyProgress();

    if (kDebugMode) {
      print('⏹️ Playback stopped');
    }
  }

  /// Get available quality options for current video
  List<VideoQuality> getAvailableQualities() {
    if (_currentVideo == null) return [VideoQuality.auto];

    // Return available qualities based on video
    return [
      VideoQuality.auto,
      VideoQuality.p360,
      VideoQuality.p480,
      VideoQuality.p720,
      if (_currentVideo!.quality == '4K') ...[
        VideoQuality.p1080,
        VideoQuality.p2160,
      ] else ...[
        VideoQuality.p1080,
      ],
    ];
  }

  /// Get quality display name
  String getQualityName(VideoQuality quality) => _getQualityName(quality);

  String _getQualityName(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.p144:
        return '144p';
      case VideoQuality.p240:
        return '240p';
      case VideoQuality.p360:
        return '360p';
      case VideoQuality.p480:
        return '480p';
      case VideoQuality.p720:
        return '720p HD';
      case VideoQuality.p1080:
        return '1080p Full HD';
      case VideoQuality.p1440:
        return '1440p QHD';
      case VideoQuality.p2160:
        return '2160p 4K';
    }
  }

  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _playbackSpeed).round()),
      (timer) {
        if (_currentState == PlaybackState.playing) {
          _currentPosition += const Duration(seconds: 1);

          if (_currentPosition >= _videoDuration) {
            _currentPosition = _videoDuration;
            _currentState = PlaybackState.ended;
            _stopProgressTimer();

            if (kDebugMode) {
              print('🏁 Video ended');
            }
          }

          _notifyProgress();
        }
      },
    );
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _notifyProgress() {
    final progress = PlaybackProgress(
      position: _currentPosition,
      duration: _videoDuration,
      state: _currentState,
      currentQuality: _currentQuality,
      isBuffering: _currentState == PlaybackState.buffering,
      bufferPercent: _currentState == PlaybackState.buffering ? 0.5 : 1.0,
    );

    _progressController.add(progress);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  /// Dispose resources
  void dispose() {
    _stopProgressTimer();
    _progressController.close();
    _controller?.dispose();
    _controller = null;
    _youtubeService.dispose();
  }
}
