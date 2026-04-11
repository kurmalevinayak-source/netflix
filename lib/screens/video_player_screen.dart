import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;

  YoutubePlayerController? _youtubeController;

  void _onVideoTick() => setState(() {});

  bool _isLoading = true;
  bool _isYoutube = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndInitialize();
  }

  void _checkAndInitialize() {
    final videoId = _extractVideoId(widget.videoUrl);

    if (videoId != null) {
      _isYoutube = true;
      _initializeYoutube(videoId);
    } else {
      _isYoutube = false;
      _initializeStandardPlayer();
    }
  }

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;

    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/').last.split('?').first;
      } else if (url.contains('youtube.com/watch')) {
        return url.split('v=').last.split('&').first;
      } else if (url.contains('youtube.com/embed/')) {
        return url.split('embed/').last.split('?').first;
      }
    } catch (e) {
      debugPrint('Error extracting Video ID: $e');
    }
    return null;
  }

  void _initializeYoutube(String videoId) {
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        strictRelatedVideos: true,
      ),
    );

    setState(() => _isLoading = false);
  }

  Future<void> _initializeStandardPlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_onVideoTick);
      await _videoPlayerController!.play();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Video init error: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Could not load video. Please check the URL format.';
      });
    }
  }

  void _togglePlayPause() {
    final c = _videoPlayerController;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoTick);
    _videoPlayerController?.dispose();
    _youtubeController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const SpinKitFadingCircle(color: Colors.red, size: 50)
            : _hasError
                ? _buildErrorWidget()
                : _buildPlayerContent(),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_isYoutube) {
      return YoutubePlayerScaffold(
        controller: _youtubeController!,
        aspectRatio: 16 / 9,
        builder: (context, player) {
          return player;
        },
      );
    }

    final c = _videoPlayerController;
    if (c == null || !c.value.isInitialized) {
      return const SpinKitFadingCircle(color: Colors.red);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: c.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(c),
                  GestureDetector(
                    onTap: _togglePlayPause,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      opacity: c.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.black26,
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 72,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: VideoProgressIndicator(
            c,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  c.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: _togglePlayPause,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Error loading video',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
