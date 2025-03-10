import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/watch_history_item.dart';
import '../models/movie.dart';

class WatchHistoryService {
  final String baseUrl = 'http://10.0.2.2:3000/api/watch-history';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Get user's watch history with enhanced error handling
  Future<List<WatchHistoryItem>> getWatchHistory() async {
    try {
      final headers = await _getHeaders();
      
      // Add timeout to prevent hanging requests
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Connection timed out. Please check your internet connection.');
      });

      print('Watch history response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final movieData = item['movie'];
          final movie = Movie(
            id: movieData['tmdbId'],
            title: movieData['title'],
            overview: movieData['overview'],
            posterPath: movieData['posterPath'],
            releaseDate: movieData['releaseDate'] != null 
              ? DateTime.parse(movieData['releaseDate']).toString().substring(0, 10) 
              : '',
            voteAverage: movieData['voteAverage']?.toDouble() ?? 0.0,
          );
          
          return WatchHistoryItem(
            id: item['id'],
            movie: movie,
            progress: item['progress'],
            watchedAt: DateTime.parse(item['watchedAt']),
          );
        }).toList();
      } else if (response.statusCode == 401) {
        // Handle authentication issues
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode >= 500) {
        // Handle server errors
        throw Exception('Server error. The development team has been notified.');
      } else {
        // Generic error with response body info
        String message;
        try {
          message = jsonDecode(response.body)['message'] ?? 'Failed to fetch watch history';
        } catch (_) {
          message = 'Failed to fetch watch history';
        }
        throw Exception(message);
      }
    } catch (e) {
      print('Error getting watch history: $e');
      // Rethrow with a user-friendly message
      throw Exception('Failed to load watch history: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Update watch progress for a movie with enhanced error handling
  Future<WatchHistoryItem> updateWatchProgress({
    required int tmdbId,
    required int progress,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/update'),
        headers: headers,
        body: jsonEncode({
          'tmdbId': tmdbId,
          'progress': progress,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Connection timed out. Please check your internet connection.');
      });

      print('Update watch progress response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movieData = data['movie'];
        final movie = Movie(
          id: movieData['tmdbId'],
          title: movieData['title'],
          overview: movieData['overview'],
          posterPath: movieData['posterPath'],
          releaseDate: movieData['releaseDate'] != null 
            ? DateTime.parse(movieData['releaseDate']).toString().substring(0, 10)
            : '',
          voteAverage: movieData['voteAverage']?.toDouble() ?? 0.0,
        );
        
        return WatchHistoryItem(
          id: data['id'],
          movie: movie,
          progress: data['progress'],
          watchedAt: DateTime.parse(data['watchedAt']),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. The development team has been notified.');
      } else {
        String message;
        try {
          message = jsonDecode(response.body)['message'] ?? 'Failed to update watch progress';
        } catch (_) {
          message = 'Failed to update watch progress';
        }
        throw Exception(message);
      }
    } catch (e) {
      print('Error updating watch progress: $e');
      throw Exception('Failed to update watch progress: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
