import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: TextField(
          controller: _searchController,
          autofocus: false,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search for a show, movie, etc.',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.greyText),
            prefixIcon: Icon(Icons.search, color: AppTheme.greyText),
          ),
          onChanged: (query) => movieProvider.search(query),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                movieProvider.search('');
              },
              icon: const Icon(Icons.clear, color: Colors.white),
            ),
        ],
      ),
      body: movieProvider.isLoading
          ? const Center(child: SpinKitFadingCircle(color: Colors.red))
          : movieProvider.searchResults.isEmpty && _searchController.text.isNotEmpty
              ? const Center(child: Text('No results found.', style: TextStyle(color: Colors.white)))
              : movieProvider.searchResults.isEmpty
                  ? _buildTopSearches(movieProvider)
                  : _buildSearchResults(movieProvider),
    );
  }

  Widget _buildTopSearches(MovieProvider movieProvider) {
    final movies = movieProvider.trendingMovies.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Top Searches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildSearchTile(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(MovieProvider movieProvider) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 16),
      itemCount: movieProvider.searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final movie = movieProvider.searchResults[index];
        return _buildSearchTile(movie);
      },
    );
  }

  Widget _buildSearchTile(dynamic movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)));
      },
      child: Container(
        height: 70,
        color: Colors.grey[900],
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 70,
              child: Image.network(
                movie.thumbnailUrl, 
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)));
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.movie, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
