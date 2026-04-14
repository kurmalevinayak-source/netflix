import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 110,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: height - 30, // Adjust height for the label below
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[900],
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: movie.fullPosterPath,
                    fit: BoxFit.cover,
                    width: width,
                    height: height - 30,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[850],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[850],
                      child: const Center(child: Icon(Icons.movie, color: Colors.red, size: 30)),
                    ),
                    fadeInDuration: const Duration(milliseconds: 300),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Consumer2<MovieProvider, AuthProvider>(
                    builder: (context, movieProvider, authProvider, child) {
                      final isInList = movieProvider.watchlist.any((m) => m.id == movie.id);
                      return PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: Colors.white70, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 150),
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'mylist',
                            child: Row(
                              children: [
                                Icon(isInList ? Icons.check : Icons.add, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(isInList ? 'Remove from List' : 'Add to My List', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Share', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'mylist') {
                            movieProvider.toggleWatchlist(authProvider.user?.uid, movie, isInList);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              movie.title,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

