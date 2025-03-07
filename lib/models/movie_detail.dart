import 'movie.dart';

class MovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<String> genres;
  final int runtime;
  final String status;
  final List<Cast> cast;
  final List<Crew> crew;
  final String? trailerKey;
  final List<Movie> similarMovies;

  MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.cast,
    required this.crew,
    this.trailerKey,
    required this.similarMovies,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    // Extract genres
    List<String> genresList = [];
    if (json['genres'] != null) {
      genresList = (json['genres'] as List)
          .map((genre) => genre['name'] as String)
          .toList();
    }

    // Extract cast
    List<Cast> castList = [];
    if (json['credits'] != null && json['credits']['cast'] != null) {
      castList = (json['credits']['cast'] as List)
          .take(8) // Limit to 8 cast members
          .map((cast) => Cast.fromJson(cast))
          .toList();
    }

    // Extract crew (directors, writers)
    List<Crew> crewList = [];
    if (json['credits'] != null && json['credits']['crew'] != null) {
      crewList = (json['credits']['crew'] as List)
          .where((crew) => crew['job'] == 'Director' || crew['department'] == 'Writing')
          .map((crew) => Crew.fromJson(crew))
          .toList();
    }

    // Extract trailer
    String? trailerKey;
    if (json['videos'] != null && json['videos']['results'] != null) {
      final videos = (json['videos']['results'] as List);
      final trailers = videos.where((video) => 
        video['type'] == 'Trailer' && video['site'] == 'YouTube'
      ).toList();
      
      if (trailers.isNotEmpty) {
        trailerKey = trailers.first['key'];
      }
    }

    // Extract similar movies
    List<Movie> similarMoviesList = [];
    if (json['similar'] != null && json['similar']['results'] != null) {
      similarMoviesList = (json['similar']['results'] as List)
          .take(6) 
          .map((movie) => Movie.fromJson(movie))
          .toList();
    }

    return MovieDetail(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? 'Unknown',
      genres: genresList,
      runtime: json['runtime'] ?? 0,
      status: json['status'] ?? 'Unknown',
      cast: castList,
      crew: crewList,
      trailerKey: trailerKey,
      similarMovies: similarMoviesList,
    );
  }

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get year {
    if (releaseDate != 'Unknown') {
      return releaseDate.substring(0, 4);
    }
    return 'Unknown';
  }
}

class Cast {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'] ?? '',
    );
  }
}

class Crew {
  final int id;
  final String name;
  final String job;
  final String department;

  Crew({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'],
      name: json['name'],
      job: json['job'] ?? '',
      department: json['department'] ?? '',
    );
  }
}

