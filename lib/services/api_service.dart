import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_detail.dart';

class ApiService {
  static const String apiKey = '';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/original';

  // Get popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  // Get trending movies with pagination support
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/day?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }
  
  // Get movie details
  Future<MovieDetail> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&append_to_response=credits,videos,similar'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return MovieDetail.fromJson(data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  // Get upcoming movies
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  // Get now playing movies
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  // Get similar movies
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/similar?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load similar movies');
    }
  }

  // Search movies with optional filters
  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
    int? year,
    List<int>? genreIds,
    String? sortBy, // popularity.desc, release_date.desc, vote_average.desc, etc.
  }) async {
    if (query.isEmpty) {
      return [];
    }

    final queryParams = {
      'api_key': apiKey,
      'query': query,
      'page': page.toString(),
      'language': 'en-US',
      'include_adult': 'false',
    };

    // Add year filter if specified
    if (year != null) {
      queryParams['primary_release_year'] = year.toString();
    }

    // Add genre filter if specified
    if (genreIds != null && genreIds.isNotEmpty) {
      queryParams['with_genres'] = genreIds.join(',');
    }

    // Add sorting if specified
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }

    final uri = Uri.parse('$baseUrl/search/movie').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  // Discover movies with more advanced filtering
  Future<List<Movie>> discoverMovies({
    int page = 1,
    int? year,
    String? sortBy,
    List<int>? genreIds,
    String? releaseYear,
    double? voteAverageGte,
    String? withCast,
    String? withCrew,
  }) async {
    final queryParams = {
      'api_key': apiKey,
      'language': 'en-US',
      'page': page.toString(),
      'include_adult': 'false',
    };

    if (year != null) {
      queryParams['primary_release_year'] = year.toString();
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }

    if (genreIds != null && genreIds.isNotEmpty) {
      queryParams['with_genres'] = genreIds.join(',');
    }

    if (releaseYear != null && releaseYear.isNotEmpty) {
      queryParams['primary_release_year'] = releaseYear;
    }

    if (voteAverageGte != null) {
      queryParams['vote_average.gte'] = voteAverageGte.toString();
    }

    if (withCast != null && withCast.isNotEmpty) {
      queryParams['with_cast'] = withCast;
    }

    if (withCrew != null && withCrew.isNotEmpty) {
      queryParams['with_crew'] = withCrew;
    }

    final uri = Uri.parse('$baseUrl/discover/movie').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to discover movies');
    }
  }

  // Get movie genres
  Future<List<Genre>> getGenres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['genres'];
      return results.map((genre) => Genre.fromJson(genre)).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}
