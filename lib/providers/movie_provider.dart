import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';

class MovieProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _recommendedMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchlist = [];
  bool _isLoading = false;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get recommendedMovies => _recommendedMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _trendingMovies = await _firestoreService.getTrendingMovies();
      _popularMovies = await _firestoreService.getPopularMovies();
      _recommendedMovies = await _firestoreService.getMoviesByCategory('Recommended');
      
      if (_trendingMovies.isEmpty && _popularMovies.isEmpty) {
        _seedDummyData();
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      _seedDummyData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedDummyData() {
    final List<Map<String, String>> movieData = [
      {'title': 'Squid Game', 'image': 'https://static0.srcdn.com/wordpress/wp-content/uploads/2024/12/ijmagery-from-squid-game.jpg?w=1600&h=900&fit=crop', 'video': 'https://youtu.be/Ed1sGgHUo88?si=LabthQBMtXd25qeB'}, // Add Image & Video Link here
      {'title': 'Stranger Things', 'image': 'https://i.guim.co.uk/img/media/344f3917f3e40dbb745e498dd31ab84e4b098981/0_901_3000_2400/master/3000.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=cdadb2f0061a9d1671d268efdd5a572d', 'video': 'https://youtu.be/AfQ13jsLDms?si=A2CIrlK6Skso0Lt8'}, // Add Image & Video Link here
      {'title': 'The Witcher', 'image': 'https://m.media-amazon.com/images/M/MV5BOTQzMzNmMzUtODgwNS00YTdhLTg5N2MtOWU1YTc4YWY3NjRlXkEyXkFqcGc@._V1_.jpg', 'video': 'https://youtu.be/ndl1W4ltcmg?si=AlMIKV561tkP5V0Z'}, // Add Image & Video Link here
      {'title': 'Money Heist', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNbKkrrVtlpQTnorGFOD4d3QAnfW23KdLpUA&s', 'video': 'https://youtu.be/_InqQJRqGW4?si=cR-l1jtToJnCQgjF'}, // Add Image & Video Link here
      {'title': 'The Crown', 'image': 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ab/The_Crown_s6_soundtrack.jpg/250px-The_Crown_s6_soundtrack.jpg', 'video': 'https://youtu.be/1weI6ICx-hg?si=nt7e8fegtwz2AjvE'}, // Add Image & Video Link here
      {'title': 'Black Mirror', 'image': 'https://m.media-amazon.com/images/S/pv-target-images/f776cee5ad6754be44f660d99be95740700fd98d0c1582a018df0c8c22bae049.jpg', 'video': 'https://youtu.be/jDiYGjp5iFg?si=KcBNeKlsmJ09RBP0'}, // Add Image & Video Link here
      {'title': 'Dark', 'image': 'https://m.media-amazon.com/images/M/MV5BOWJjMGViY2UtNTAzNS00ZGFjLWFkNTMtMDBiMDMyZTM1NTY3XkEyXkFqcGc@._V1_.jpg', 'video': 'https://youtu.be/cq2iTHoLrt0?si=LL_oGrEQ2PGKnqNd'}, // Add Image & Video Link here
      {'title': 'The Queen\'s Gambit', 'image': 'https://m.media-amazon.com/images/M/MV5BZGExZGNmYzMtZDAyYS00NzhiLTgzMWMtZTdhYTIzMDMwYzdjXkEyXkFqcGc@._V1_.jpg', 'video': 'https://youtu.be/oZn3qSgmLqI?si=SIGGv9hyAXw_M6Hd'}, // Add Image & Video Link here
      {'title': 'Extraction 2', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTs7MfR6fr2OH8tmrDa9SaNrANKt-OTLOv76Q&s', 'video': 'https://youtu.be/mO0OuR26IZM?si=aXJKQQ4icwqujqYU'}, // Add Image & Video Link here
      {'title': 'Spider-Man', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRa2sTZUCh20Jjrh-nf-36O9VGrV1igDnpdLA&s', 'video': 'https://youtu.be/8TZMtslA3UY?si=z9qHccbNKhGSo9SB'}, // Add Image & Video Link here
      {'title': 'Oppenheimer', 'image': 'https://www.indiewire.com/wp-content/uploads/2023/07/oppenheimer-cillian.webp', 'video': 'https://youtu.be/bK6ldnjE3Y0?si=pdym5gcpIHQiFjjC'}, // Add Image & Video Link here
      {'title': 'Barbie', 'image': 'https://m.media-amazon.com/images/M/MV5BNGY0ZjA3MzAtYjIwOS00NTk5LThmMzEtNjI0MmU4MzQ1NmRiXkEyXkFqcGdeQWFybm8@._V1_.jpg', 'video': 'https://youtu.be/GRyt3Ov4zz0?si=PRBvFPj4Z1SuLpvv'}, // Add Image & Video Link here
      {'title': 'John Wick 4', 'image': 'https://i.ytimg.com/vi/yjRHZEUamCc/sddefault.jpg', 'video': 'https://youtu.be/qEVUtrk8_B4?si=7Z7zHo8t1mJ8FWj3'}, // Add Image & Video Link here
      {'title': 'Super Mario', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwINOo_xuP82MmA1i0N_ZLhshHEuj6DqD4GQ&s', 'video': 'https://youtu.be/RjNcTBXTk4I?si=AeQLMSCAVZwBxai3'}, // Add Image & Video Link here
      {'title': 'Fast X', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFPHmEqRHtcV7NoT-j5Mw527FlEJbgLuSEWA&s', 'video': 'https://youtu.be/aOb15GVFZxU?si=Z8a3KFbmAt7elxUP'}, // Add Image & Video Link here
      {'title': 'Guardians 3', 'image': 'https://static0.colliderimages.com/wordpress/wp-content/uploads/2023/05/guardians-of-the-galaxy-vol-3-karen-gillan-chris-pratt-dave-bautista.jpg', 'video': 'https://youtu.be/u3V5KDHRQvk?si=3RY0XYuU7MiB-15M'}, // Add Image & Video Link here
      {'title': 'Avatar 2', 'image': 'https://m.media-amazon.com/images/M/MV5BNWI0Y2NkOWEtMmM2OC00MjQ3LWI1YzItZGQxYzQ3NzI4NWZmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg', 'video': 'https://youtu.be/d9MyW72ELq0?si=-sBuoNPbjB0Kx6b5'}, // Add Image & Video Link here
      {'title': 'Top Gun', 'image': 'https://m.media-amazon.com/images/S/pv-target-images/93e623607be6b45106165ac65f85571deb190e37babb56da2b3838d33cfcdc70.jpg', 'video': 'https://youtu.be/qSqVVswa420?si=iPbFia9Qq9yOcqA0'}, // Add Image & Video Link here
      {'title': 'Inception', 'image': 'https://m.media-amazon.com/images/I/91G0gTLz6GL._AC_UF1000,1000_QL80_.jpg', 'video': 'https://youtu.be/5EiV_HXIIGs?si=jYJukZqUsXwMP9YZ'}, // Add Image & Video Link here
      {'title': 'Interstellar', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZgarY79EPQu_BBe86NdqmVxRhgH0N6AgLEA&s', 'video': 'https://youtu.be/2LqzF5WauAw?si=0jY0WIBaPqt79xly'}, // Add Image & Video Link here
      {'title': 'The Matrix', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTO4rj-NVDTep7566NDZTfoE2aqWt-zq8Ca0w&s', 'video': 'https://youtu.be/9ix7TUGVYIo?si=z6-VFO53IUGDw1l4'}, // Add Image & Video Link here
      {'title': 'Blade Runner', 'image': 'https://m.media-amazon.com/images/M/MV5BNzA1Njg4NzYxOV5BMl5BanBnXkFtZTgwODk5NjU3MzI@._V1_.jpg', 'video': 'https://youtu.be/gCcx85zbxz4?si=Mi0ONuaEyJuKDRAF'}, // Add Image & Video Link here
      {'title': 'The Martian', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBRV6f4nBvO0iCrSSy89NgG1YFJwh3-4jfiA&s', 'video': 'https://youtu.be/Ue4PCI0NamI?si=dbYs3sZ1HbxZpmU5'}, // Add Image & Video Link here
      {'title': 'Arrival', 'image': 'https://m.media-amazon.com/images/I/81q31owGDsL._AC_UF1000,1000_QL80_.jpg', 'video': 'https://youtu.be/tFMo3UJ4B4g?si=NkxsZ02Y7VR08D-r'}, // Add Image & Video Link here
      {'title': 'Tenet', 'image': 'https://upload.wikimedia.org/wikipedia/en/1/14/Tenet_movie_poster.jpg', 'video': 'https://youtu.be/LdOM0x0XDMo?si=q3b3kd678hGGHAbD'}, // Add Image & Video Link here
      {'title': 'Dune', 'image': 'https://upload.wikimedia.org/wikipedia/en/8/8e/Dune_%282021_film%29.jpg', 'video': 'https://youtu.be/U2Qp5pL3ovA?si=MTDDJid9pk6GNDAy'}, // Add Image & Video Link here
      {'title': 'Gravity', 'image': 'https://m.media-amazon.com/images/M/MV5BNjE5MzYwMzYxMF5BMl5BanBnXkFtZTcwOTk4MTk0OQ@@._V1_FMjpg_UX1000_.jpg', 'video': 'https://youtu.be/OiTiKOy59o4?si=fB11qFhcGXRI9rav'}, // Add Image & Video Link here
      {'title': 'The Prestige', 'image': 'https://m.media-amazon.com/images/I/81AdI6L6nAL._AC_UF1000,1000_QL80_.jpg', 'video': 'https://youtu.be/RLtaA9fFNXU?si=6I6-ubcTcnGVQiE3'}, // Add Image & Video Link here
      {'title': 'The Gray Man', 'image': 'https://static0.colliderimages.com/wordpress/wp-content/uploads/2022/07/The-Gray-Man-cast--Character-Guide-feature.jpg', 'video': 'https://youtu.be/c1ICmUAe92E?si=plLXsvV1YJZ1Zili'}, // Add Image & Video Link here
      {'title': 'Red Notice', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6ggX2KZbKoKiUAcwn_bzji4kz1baNCOX4C8_x6g0mmlEn7Y5im3lgf58OA8P_d56HtNPEXNwK4HSl0s1huLz56p_n9A_GlFNvKoZbeqA&s=10', 'video': 'https://youtu.be/T6l3mM7AWew?si=0xV6uhb6JDYej15W'}, // Add Image & Video Link here
      {'title': 'Glass Onion', 'image': 'https://s3.amazonaws.com/nightjarprod/content/uploads/sites/192/2022/10/25111047/gOrfE0tX7aLjRR12vveQvBHHGa.jpg', 'video': 'https://youtu.be/-xR_lBtEvSc?si=TO0T3ihQFwb4CsFI'}, // Add Image & Video Link here
      {'title': 'The Irishman', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPGUSSq0QsgyvH-C-49qUWd4vaNNHQF30jkQ&s', 'video': 'https://youtu.be/WHXxVmeGQUc?si=TUPLAqEdS-y3I4RK'}, // Add Image & Video Link here
    ];

    final List<Movie> netflixMovies = [];
    for (int i = 0; i < movieData.length; i++) {
      final title = movieData[i]['title']!;
      final posterUrl = movieData[i]['image']!;
      final videoUrl = movieData[i]['video']!;
      
      netflixMovies.add(
        Movie(
          id: 'movie_$i',
          title: title,
          description: 'This is an exciting description for $title. Join the adventure in this high-quality production.',
          thumbnailUrl: posterUrl,
          videoUrl: videoUrl,
          category: i < 10 ? 'Trending' : (i < 20 ? 'Popular' : 'Recommended'),
          posterPath: posterUrl,
          isTrending: i < 10,
          isPopular: i >= 10 && i < 20,
          isSeries: i % 3 == 0,
          rating: 7.0 + (i % 20) / 10.0,
          cast: ['Actor A', 'Actor B', 'Actor C'],
        ),
      );
    }

    _trendingMovies = netflixMovies.where((m) => m.isTrending).toList();
    _popularMovies = netflixMovies.where((m) => m.isPopular).toList();
    _recommendedMovies = netflixMovies.where((m) => m.category == 'Recommended').toList();
    
    if (_recommendedMovies.isEmpty) {
      _recommendedMovies = netflixMovies.where((m) => !m.isTrending && !m.isPopular).toList();
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    
    _searchResults = await _firestoreService.searchMovies(query);
    
    if (_searchResults.isEmpty) {
      final List<Movie> allDummy = [..._trendingMovies, ..._popularMovies, ..._recommendedMovies];
      _searchResults = allDummy
          .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
          .toSet()
          .toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWatchlist(List<String> movieIds) async {
    _isLoading = true;
    notifyListeners();
    _watchlist = await _firestoreService.getWatchlist(movieIds);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWatchlist(String? uid, Movie movie, bool isAdded) async {
    if (uid != null) {
      if (isAdded) {
        await _firestoreService.removeFromWatchlist(uid, movie.id);
        _watchlist.removeWhere((m) => m.id == movie.id);
      } else {
        await _firestoreService.addToWatchlist(uid, movie.id);
        if (!_watchlist.any((m) => m.id == movie.id)) {
          _watchlist.add(movie);
        }
      }
    } else {
      if (isAdded) {
        _watchlist.removeWhere((m) => m.id == movie.id);
      } else {
        if (!_watchlist.any((m) => m.id == movie.id)) {
          _watchlist.add(movie);
        }
      }
    }
    notifyListeners();
  }
}

