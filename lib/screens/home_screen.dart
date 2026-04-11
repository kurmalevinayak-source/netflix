import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/horizontal_movie_list.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<MovieProvider>(context, listen: false).fetchHomeData();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    final List<Widget> screens = [
      _buildHomeContent(movieProvider),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _currentIndex == 0 ? AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/2560px-Netflix_2015_logo.svg.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.red),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCastDialog(context), 
            icon: const Icon(Icons.cast, color: Colors.white)
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ) : null,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(MovieProvider movieProvider) {
    if (movieProvider.isLoading) {
      return const Center(child: SpinKitFadingCircle(color: Colors.red));
    }

    return RefreshIndicator(
      onRefresh: () => movieProvider.fetchHomeData(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            BannerCarousel(movies: movieProvider.trendingMovies.take(5).toList()),
            const SizedBox(height: 10),
            HorizontalMovieList(title: 'Trending Now', movies: movieProvider.trendingMovies),
            HorizontalMovieList(title: 'Popular on Netflix', movies: movieProvider.popularMovies),
            HorizontalMovieList(title: 'Top Rated', movies: movieProvider.recommendedMovies),
            // Dummy categories
            HorizontalMovieList(title: 'My List', movies: movieProvider.watchlist),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
