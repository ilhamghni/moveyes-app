import '../models/movie.dart';

class WatchHistory {
  final int id;
  final int userId;
  final Movie movie;
  final int progress; // Progress as a percentage (0-100)
  final DateTime watchedAt;

  WatchHistory({
    required this.id,
    required this.userId,
    required this.movie,
    required this.progress,
    required this.watchedAt,
  });

  factory WatchHistory.fromJson(Map<String, dynamic> json) {
    return WatchHistory(
      id: json['id'],
      userId: json['userId'],
      movie: Movie(
        id: json['movie']['tmdbId'],
        title: json['movie']['title'],
        overview: json['movie']['overview'],
        posterPath: json['movie']['posterPath'],
        backdropPath: json['movie']['backdropPath'],
        releaseDate: json['movie']['releaseDate'] ?? 'Unknown',
        voteAverage: json['movie']['voteAverage'] is int 
          ? (json['movie']['voteAverage'] as int).toDouble() 
          : (json['movie']['voteAverage'] as num).toDouble(),
      ),
      progress: json['progress'],
      watchedAt: DateTime.parse(json['watchedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movie.id,
      'progress': progress,
      'watchedAt': watchedAt.toIso8601String(),
    };
  }
}