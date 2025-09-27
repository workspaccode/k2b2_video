import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

import '../services/youtube_service.dart';

class YouTubeShortsScreen extends StatefulWidget {
  const YouTubeShortsScreen({super.key});

  @override
  State<YouTubeShortsScreen> createState() => _YouTubeShortsScreenState();
}

class _YouTubeShortsScreenState extends State<YouTubeShortsScreen> {
  final YouTubeService _youtubeService = YouTubeService();
  late final ShortsController _controller;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadShorts();
  }

  Future<void> _loadShorts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // For now, we'll use some sample YouTube Shorts URLs
      // In a real implementation, you would fetch actual YouTube Shorts
      final shortUrls = [
        'https://www.youtube.com/shorts/PiWJWfzVwjU',
        'https://www.youtube.com/shorts/AeZ3dmC676c',
        'https://www.youtube.com/shorts/L1lg_lxUxfw',
        'https://www.youtube.com/shorts/OWPsdhLHK7c',
        'https://www.youtube.com/shorts/jXH9cIAi4MU',
      ];

      _controller = ShortsController(
        youtubeVideoSourceController: VideosSourceController.fromUrlList(
          videoIds: shortUrls,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load shorts: $e';
      });
      print('Error loading shorts: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Shorts'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadShorts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : YoutubeShortsPage(
              controller: _controller,
              willHaveDefaultShortsControllers: true,
              loadingWidget: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
              ),
              errorWidget: (error, stackTrace) {
                return Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
    );
  }
}
