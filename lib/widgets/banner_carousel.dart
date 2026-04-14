                                                                                                                                                                                                                    import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/video_player_screen.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';

class BannerCarousel extends StatelessWidget {
  final List<Movie> movies;

  const BannerCarousel({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    
    final movieProvider = Provider.of<MovieProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return CarouselSlider(
      options: CarouselOptions(
        height: 550, // More cinematic height
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 8),
        enlargeCenterPage: false,
      ),
      items: movies.map((movie) {
        final isInWatchlist = movieProvider.watchlist.any((m) => m.id == movie.id);
        
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                );
              },
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.fullPosterPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 550,
                    placeholder: (context, url) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.movie, color: Colors.red, size: 80),
                          const SizedBox(height: 10),
                          Text(
                            movie.title,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text('Image unavailable', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    fadeInDuration: const Duration(milliseconds: 500),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.transparent, Color(0xFF141414)],
                        stops: [0.0, 0.4, 1.0], // Deeper fade
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('👍 Liked'), backgroundColor: Colors.green),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.thumb_up, color: Colors.white70, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('👎 Not interested'), backgroundColor: Colors.red),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.thumb_down, color: Colors.white70, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          movie.title.toUpperCase(),
                          style: GoogleFonts.bebasNeue(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Exciting • Action • New Release',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(
                                      videoUrl: movie.videoUrl,
                                      title: movie.title,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                              label: const Text('Play', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                movieProvider.toggleWatchlist(
                                  authProvider.user?.uid,
                                  movie,
                                  isInWatchlist,
                                );
                                if (authProvider.user != null) {
                                  authProvider.toggleWatchlistLocal(movie.id);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isInWatchlist ? 'Removed from My List' : 'Added to My List'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              icon: Icon(isInWatchlist ? Icons.check : Icons.add, color: Colors.white, size: 28),
                              label: const Text('My List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

