class Episode {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final int season;
  final int number;
  final double duration; // in minutes
  final String description;

  Episode({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.season,
    required this.number,
    required this.duration,
    this.description = '',
  });

  factory Episode.fromMap(String id, Map<String, dynamic> map) {
    return Episode(
      id: id,
      title: map['title'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      season: map['season'] ?? 1,
      number: map['number'] ?? 1,
      duration: (map['duration'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'season': season,
      'number': number,
      'duration': duration,
      'description': description,
    };
  }
}
