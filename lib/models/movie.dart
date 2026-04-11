class Movie {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
final String category;
  final List<String> cast;
  final bool isTrending;
  final bool isPopular;
  final bool isSeries;
  final double rating;
  final String posterPath;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.posterPath,
    this.cast = const [],
    this.isTrending = false,
    this.isPopular = false,
    this.isSeries = false,
    this.rating = 0.0,
  });

  factory Movie.fromMap(String id, Map<String, dynamic> map) {
    return Movie(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      category: map['category'] ?? 'General',
      posterPath: map['posterPath'] ?? '',
      cast: List<String>.from(map['cast'] ?? []),
      isTrending: map['isTrending'] ?? false,
      isPopular: map['isPopular'] ?? false,
      isSeries: map['isSeries'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  String get fullPosterPath {
    if (posterPath.isEmpty) return thumbnailUrl;
    if (posterPath.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500\$posterPath';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'category': category,
      'posterPath': posterPath,
      'cast': cast,
      'isTrending': isTrending,
      'isPopular': isPopular,
      'isSeries': isSeries,
      'rating': rating,
    };
  }
}
