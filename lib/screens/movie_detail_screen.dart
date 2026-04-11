import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import 'video_player_screen.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final isAdded = movieProvider.watchlist.any((m) => m.id == widget.movie.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => _showCastDialog(context), icon: const Icon(Icons.cast, color: Colors.white)),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'), 
            icon: const Icon(Icons.search, color: Colors.white)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.movie.fullPosterPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                    placeholder: (context, url) => Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator(color: Colors.red)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(child: Icon(Icons.movie, size: 80, color: Colors.red)),
                    ),
                    fadeInDuration: const Duration(milliseconds: 400),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, Color(0xFF141414)],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _playVideo(context),
                    icon: const Icon(Icons.play_circle_outline, size: 70, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('2024', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(border: Border.all(color: AppTheme.greyText)),
                        child: const Text('18+', style: TextStyle(color: AppTheme.greyText, fontSize: 10)),
                      ),
                      const SizedBox(width: 12),
                      const Text('1h 45m', style: TextStyle(color: AppTheme.greyText)),
                      const SizedBox(width: 12),
                      const Icon(Icons.hd_outlined, color: AppTheme.greyText, size: 18),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _playVideo(context),
                    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                    label: const Text('Play', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showSnackbar(context, 'Starting download...'),
                    icon: const Icon(Icons.download, color: Colors.white, size: 24),
                    label: const Text('Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.movie.description, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text('Cast: ${widget.movie.cast.isEmpty ? "Cast info not available" : widget.movie.cast.join(", ")}', 
                    style: const TextStyle(color: AppTheme.greyText, fontSize: 13)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: isAdded ? Icons.check : Icons.add,
                        label: 'My List',
                        onTap: () {
                          movieProvider.toggleWatchlist(auth.user?.uid, widget.movie, isAdded);
                          if (auth.user != null) {
                            auth.toggleWatchlistLocal(widget.movie.id);
                          }
                          _showSnackbar(context, isAdded ? 'Removed from My List' : 'Added to My List');
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.thumb_up_alt_outlined,
                        label: 'Not Interested',
                        onTap: () => _showSnackbar(context, 'Not interested 👎'),
                      ),
                      _buildActionButton(
                        icon: Icons.thumb_up,
                        label: '👍',
                        onTap: () => _showSnackbar(context, 'Liked 👍'),
                      ),
                      if (widget.movie.isSeries)
                        _buildActionButton(
                          icon: Icons.list_alt,
                          label: 'Episodes',
                          onTap: () => _showEpisodesDialog(context),
                        ),
                      _buildActionButton(
                        icon: Icons.info_outline,
                        label: 'Info',
                        onTap: () => _showInfoDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoUrl: widget.movie.videoUrl,
          title: widget.movie.title,
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2), backgroundColor: Colors.red),
    );
  }

  void _showEpisodesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('${widget.movie.title} Episodes', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text('Episode ${index + 1}', style: const TextStyle(color: Colors.white)),
              subtitle: const Text('45m', style: TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.play_circle_outline, color: Colors.red),
              onTap: () => _showSnackbar(context, 'Playing Episode ${index + 1}'),
              tileColor: Colors.grey[850],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), 
                     child: const Text('Close', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(widget.movie.title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Genre: ${widget.movie.category}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Rating: ${widget.movie.rating}/10', style: const TextStyle(color: Colors.amber)),
              Text('Cast: ${widget.movie.cast.join(", ")}', style: TextStyle(color: Colors.white70)),
              Text('Duration: 1h 45m', style: TextStyle(color: Colors.white70)),
              Text('Released: 2024', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), 
                     child: const Text('Close', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showCastDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Connect to Device', style: TextStyle(color: Colors.white)),
        content: const Text('No devices found on this network.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
          ],
        ),
      ),
    );
  }
}

