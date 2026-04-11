import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class FirestoreService {
  FirebaseFirestore? _db;

  FirestoreService() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("FirestoreService: Firebase not initialized. Using Mock Data.");
    }
  }

  // Fetch all movies
  Future<List<Movie>> getMovies() async {
    if (_db == null) return [];
    var ref = _db!.collection('movies');
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())).toList();
  }

  // Fetch movies by category
  Future<List<Movie>> getMoviesByCategory(String category) async {
    if (_db == null) return [];
    var ref = _db!.collection('movies').where('category', isEqualTo: category);
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())).toList();
  }

  // Fetch trending movies
  Future<List<Movie>> getTrendingMovies() async {
    if (_db == null) return [];
    var ref = _db!.collection('movies').where('isTrending', isEqualTo: true);
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())).toList();
  }

  // Fetch popular movies
  Future<List<Movie>> getPopularMovies() async {
    if (_db == null) return [];
    var ref = _db!.collection('movies').where('isPopular', isEqualTo: true);
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())).toList();
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query) async {
    if (_db == null) return [];
    var ref = _db!.collection('movies')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff');
    var snapshot = await ref.get();
    return snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())).toList();
  }

  // Add to watchlist
  Future<void> addToWatchlist(String uid, String movieId) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).update({
      'watchlist': FieldValue.arrayUnion([movieId])
    });
  }

  // Remove from watchlist
  Future<void> removeFromWatchlist(String uid, String movieId) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).update({
      'watchlist': FieldValue.arrayRemove([movieId])
    });
  }

  // Get watchlist movies
  Future<List<Movie>> getWatchlist(List<String> movieIds) async {
    if (_db == null || movieIds.isEmpty) return [];
    
    List<Movie> movies = [];
    for (var i = 0; i < movieIds.length; i += 10) {
      var chunk = movieIds.sublist(i, i + 10 > movieIds.length ? movieIds.length : i + 10);
      var snapshot = await _db!.collection('movies').where(FieldPath.documentId, whereIn: chunk).get();
      movies.addAll(snapshot.docs.map((doc) => Movie.fromMap(doc.id, doc.data())));
    }
    return movies;
  }
}
