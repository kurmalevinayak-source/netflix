import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
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
  // For standard videos
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  // For YouTube videos
  YoutubePlayerController? _youtubeController;
  
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
    
    // Support all common YouTube URL formats
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
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: true,
        allowFullScreen: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: const Center(child: SpinKitPulse(color: Colors.red)),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white.withOpacity(0.5),
        ),
      );
      
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

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    // youtube_player_iframe controller doesn't need explicit dispose in this version
    // but we clear the reference for safety.
    _youtubeController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
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
    } else {
      return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const SpinKitFadingCircle(color: Colors.red);
    }
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Error loading video', 
               style: const TextStyle(color: Colors.white, fontSize: 16),
               textAlign: TextAlign.center),
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
