import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/watch_history.dart';

class ApiService {
  static const String apiKey = '4e26b5f5a2434ba176b20acf95c32d09';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/original';
  static const String backendBaseUrl = 'http://10.0.2.2:3000/api/movies';
  static const String watchHistoryBaseUrl = 'http://10.0.2.2:3000/api/watch-history';
  
  static const String tokenKey = 'auth_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token == null || token.isEmpty) {
        print('No token found in secure storage');
      }
      return token;
    } catch (e) {
      print('Error retrieving token from secure storage: $e');
      return null;
    }
  }

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


  Future<bool> addToFavorites(int movieId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('No token available for adding to favorites');
        throw Exception('Authentication token not found');
      }

      print('Sending add to favorites request for movieId: $movieId');
      
      final response = await http.post(
        Uri.parse('$backendBaseUrl/addToFavorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tmdbId': movieId}),
      );

      print('Add to favorites response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add to favorites: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      throw Exception('Failed to add to favorites: $e');
    }
  }
  
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('No token available for removing from favorites');
        throw Exception('Authentication token not found');
      }

      // Get favorites to find the one with matching TMDB ID
      final favorites = await getFavorites();
      print('Looking for tmdbId: $movieId in ${favorites.length} favorites');
      
      // Debug all favorites to find potential mismatches
      for (var fav in favorites) {
        print('Favorite: id=${fav.id}, movieId=${fav.movieId}, tmdbId=${fav.movie.tmdbId}, title="${fav.movie.title}"');
      }
      
      // Find the favorite with matching TMDB ID
      final favorite = favorites.firstWhere(
        (fav) => fav.movie.tmdbId == movieId,
        orElse: () => throw Exception('Movie not found in favorites'),
      );
      
      final favoriteId = favorite.id;
      print('Found favorite: id=$favoriteId, title="${favorite.movie.title}", tmdbId=${favorite.movie.tmdbId}');

      print('Sending remove from favorites request for favoriteId: $favoriteId');
      
      final response = await http.delete(
        Uri.parse('$backendBaseUrl/favorites/$favoriteId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Remove from favorites response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to remove from favorites: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      throw Exception('Failed to remove from favorites: $e');
    }
  }
  
  Future<List<FavoriteResponse>> getFavorites() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('No token available for getting favorites');
        throw Exception('Authentication token not found');
      }

      print('Sending get favorites request');
      
      final response = await http.get(
        Uri.parse('$backendBaseUrl/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get favorites response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => FavoriteResponse.fromJson(item)).toList();
      } else {
        print('Get favorites failed: ${response.body}');
        throw Exception('Failed to get favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting favorites: $e');
      throw Exception('Failed to get favorites: $e');
    }
  }
  
  Future<bool> checkIfFavorite(int movieId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('No token available for checking favorite status');
        return false;
      }

      final response = await http.get(
        Uri.parse('$backendBaseUrl/checkFavorite/$movieId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Check favorite status response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorited'] ?? false;
      } else {
        print('Failed to check favorite status: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
  
  Future<int?> getFavoriteId(int movieId) async {
    try {
      final favorites = await getFavorites();
      
      // Debug logging
      print('Looking for tmdbId: $movieId in favorites');
      for (var fav in favorites) {
        print('Favorite: id=${fav.id}, movieId=${fav.movieId}, tmdbId=${fav.movie.tmdbId}, title="${fav.movie.title}"');
      }
      
      // Try to find the favorite with matching TMDB ID
      final favorite = favorites.firstWhere(
        (fav) => fav.movie.tmdbId == movieId,
        orElse: () => throw Exception('Movie not found in favorites'),
      );
      
      print('Found favorite with id: ${favorite.id} for movie: "${favorite.movie.title}"');
      return favorite.id;
    } catch (e) {
      print('Error getting favorite ID: $e');
      return null;
    }
  }

  Future<List<WatchHistory>> getWatchHistory() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(watchHistoryBaseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WatchHistory.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Failed to fetch watch history: $error');
      }
    } catch (e) {
      print('Error getting watch history: $e');
      throw Exception('Failed to fetch watch history: $e');
    }
  }

  Future<WatchHistory> updateWatchProgress({
    required int tmdbId,
    required int progress,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$watchHistoryBaseUrl/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tmdbId': tmdbId,
          'progress': progress,
        }),
      );

      if (response.statusCode == 200) {
        return WatchHistory.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Failed to update watch progress: $error');
      }
    } catch (e) {
      print('Error updating watch progress: $e');
      throw Exception('Failed to update watch progress: $e');
    }
  }

}

// Models for the backend API responses

class FavoriteResponse {
  final int id;
  final int userId;
  final int movieId;
  final String createdAt;
  final FavoriteMovieDetails movie;

  FavoriteResponse({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.createdAt,
    required this.movie,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      id: json['id'],
      userId: json['userId'],
      movieId: json['movieId'],
      createdAt: json['createdAt'],
      movie: FavoriteMovieDetails.fromJson(json['movie']),
    );
  }
  
  // Convert to Movie object
  Movie toMovie() {
    return Movie(
      id: movie.tmdbId,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseDate: movie.releaseDate ?? 'Unknown',
      voteAverage: movie.voteAverage,
    );
  }
}

class FavoriteMovieDetails {
  final int id;
  final int tmdbId;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;

  FavoriteMovieDetails({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
  });

  factory FavoriteMovieDetails.fromJson(Map<String, dynamic> json) {
    return FavoriteMovieDetails(
      id: json['id'],
      tmdbId: json['tmdbId'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['posterPath'],
      backdropPath: json['backdropPath'],
      releaseDate: json['releaseDate'],
      voteAverage: json['voteAverage'] is int 
          ? (json['voteAverage'] as int).toDouble() 
          : (json['voteAverage'] as num).toDouble(),
    );
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
