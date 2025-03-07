import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class SeeAllMoviesScreen extends StatefulWidget {
  final String title;
  final List<Movie> initialMovies;
  final String category;
  final int? movieId; // Used for similar movies

  const SeeAllMoviesScreen({
    super.key,
    required this.title,
    required this.initialMovies,
    required this.category,
    this.movieId,
  });

  @override
  State<SeeAllMoviesScreen> createState() => _SeeAllMoviesScreenState();
}

class _SeeAllMoviesScreenState extends State<SeeAllMoviesScreen> {
  late final ApiService _apiService = ApiService();
  late List<Movie> _movies = widget.initialMovies;
  bool _isLoading = false;
  bool _hasMoreMovies = true;
  int _page = 1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // If initial list is empty or too small, load first page
    if (_movies.length < 10) {
      _loadMoreMovies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreMovies) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _page++;
      List<Movie> newMovies;

      switch (widget.category) {
        case 'popular':
          newMovies = await _apiService.getPopularMovies(page: _page);
          break;
        case 'upcoming':
          newMovies = await _apiService.getUpcomingMovies(page: _page);
          break;
        case 'top_rated':
          newMovies = await _apiService.getTopRatedMovies(page: _page);
          break;
        case 'now_playing':
          newMovies = await _apiService.getNowPlayingMovies(page: _page);
          break;
        case 'trending':
          newMovies = await _apiService.getTrendingMovies(page: _page);
          break;
        case 'similar':
          if (widget.movieId != null) {
            newMovies = await _apiService.getSimilarMovies(widget.movieId!, page: _page);
          } else {
            newMovies = [];
          }
          break;
        default:
          newMovies = [];
      }

      if (mounted) {
        setState(() {
          if (newMovies.isEmpty) {
            _hasMoreMovies = false;
          } else {
            _movies.addAll(newMovies);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more movies: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211F30),
        title: Text(widget.title),
        elevation: 0,
      ),
      body: _movies.isEmpty && _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE21221)),
            )
          : _movies.isEmpty
              ? const Center(
                  child: Text('No movies available'),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _movies.length + (_hasMoreMovies ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _movies.length) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE21221)),
                      );
                    }
                    return MovieCard(movie: _movies[index]);
                  },
                ),
    );
  }
}
