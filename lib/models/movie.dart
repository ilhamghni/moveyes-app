import '../models/movie_detail.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] as String? ?? 'Unknown',
    );
  }
  
  // Create a Movie from a MovieDetail
  factory Movie.fromMovieDetail(MovieDetail detail) {
    return Movie(
      id: detail.id,
      title: detail.title,
      posterPath: detail.posterPath,
      backdropPath: detail.backdropPath,
      overview: detail.overview,
      voteAverage: detail.voteAverage,
      releaseDate: detail.releaseDate,
    );
  }
}
