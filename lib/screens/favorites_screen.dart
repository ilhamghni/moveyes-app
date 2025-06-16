import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Movie>> _favoritesFuture;
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<Movie>> _loadFavorites() async {
    try {
      final favorites = await _apiService.getFavorites();
      return favorites.map((favorite) => favorite.toMovie()).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<void> _refreshFavorites() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final refreshedFavorites = await _loadFavorites();
      setState(() {
        _favoritesFuture = Future.value(refreshedFavorites);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshFavorites,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        color: const Color(0xFFE21221),
        backgroundColor: const Color(0xFF211F30),
        child: FutureBuilder<List<Movie>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE21221)),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Color(0xFFE21221),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading favorites',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Please make sure you\'re logged in',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshFavorites,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE21221),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            final favorites = snapshot.data ?? [];
            
            if (favorites.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 80),
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.white30,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Favorites Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add movies to your favorites to see them here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the Home screen through bottom nav
                      final bottomNavBar = Navigator.of(context).canPop()
                          ? Navigator.of(context).pop
                          : () => Navigator.of(context).pushReplacementNamed('/home');
                      bottomNavBar();
                    },
                    icon: const Icon(Icons.movie_outlined),
                    label: const Text('Browse Movies'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE21221),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final movie = favorites[index];
                  return _buildFavoriteMovieCard(context, movie);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteMovieCard(BuildContext context, Movie movie) {
    return Stack(
      children: [
        // Make the whole card clickable
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movieId: movie.id),
              ),
            ).then((_) {
              // Refresh the list when returning from movie details
              _refreshFavorites();
            });
          },
          child: Hero(
            tag: 'movie-poster-${movie.id}',
            child: MovieCard(movie: movie),
          ),
        ),
        
        // Remove favorite button
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFFE21221),
                size: 22,
              ),
              onPressed: () => _removeFromFavorites(movie),
              tooltip: 'Remove from favorites',
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _removeFromFavorites(Movie movie) async {
    try {
      // Show confirmation dialog
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF211F30),
          title: const Text('Remove from Favorites?'),
          content: Text('Do you want to remove "${movie.title}" from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFE21221),
              ),
              child: const Text('REMOVE'),
            ),
          ],
        ),
      );

      if (shouldRemove != true) return;

      // Get the favorite ID for this movie
      final favoriteId = await _apiService.getFavoriteId(movie.id);
      if (favoriteId == null) {
        throw Exception('Could not find this movie in your favorites');
      }
      
      // Remove from favorites
      final success = await _apiService.removeFromFavorites(favoriteId);
      
      if (success && mounted) {
        // Store movie details for potential undo
        final removedMovie = movie;
        
        // Refresh the list
        _refreshFavorites();
        
        // Show snackbar with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} removed from favorites'),
            backgroundColor: Colors.red.shade800,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  // Add back to favorites
                  await _apiService.addToFavorites(removedMovie.id);
                  _refreshFavorites();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to restore: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
