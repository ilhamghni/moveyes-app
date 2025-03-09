import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'movie.dart';

class FavoritesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Map<int, FavoriteResponse> _favorites = {}; // Map by tmdbId
  bool _isLoading = false;
  bool _isInitialized = false;
  
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<Movie> get favorites => _favorites.values.map((fav) => fav.toMovie()).toList();
  
  // Check if a movie is in favorites
  bool isFavorite(int movieId) {
    return _favorites.values.any((fav) => fav.movie.tmdbId == movieId);
  }
  
  // Get the favorite ID for a movie (for removal)
  int? getFavoriteId(int movieId) {
    try {
      final favorite = _favorites.values.firstWhere(
        (fav) => fav.movie.tmdbId == movieId,
      );
      return favorite.id;
    } catch (e) {
      return null;
    }
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(Movie movie) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if it's already favorite
      if (isFavorite(movie.id)) {
        // Get favorite ID
        final favoriteId = getFavoriteId(movie.id);
        if (favoriteId == null) {
          throw Exception('Favorite ID not found');
        }
        
        // Remove from backend
        final success = await _apiService.removeFromFavorites(favoriteId);
        if (success) {
          // Remove locally
          _favorites.remove(movie.id);
          _isLoading = false;
          notifyListeners();
          return false; // No longer a favorite
        } else {
          throw Exception('Failed to remove from favorites');
        }
      } else {
        // Add to backend
        final response = await _apiService.addToFavorites(movie.id);
        
        // Add locally
        _favorites[movie.id] = response;
        _isLoading = false;
        notifyListeners();
        return true; // Now a favorite
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Failed to toggle favorite: $e');
      throw Exception('Failed to update favorites: $e');
    }
  }
  
  // Load favorites from API
  Future<void> loadFavorites() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final favoritesList = await _apiService.getFavorites();
      
      // Clear and rebuild favorites map
      _favorites.clear();
      for (final favorite in favoritesList) {
        _favorites[favorite.movie.tmdbId] = favorite;
      }
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isInitialized = true; // Mark as initialized to prevent endless retries
      notifyListeners();
      print('Failed to load favorites: $e');
    }
  }
}
