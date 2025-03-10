import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/watch_history_item.dart';
import '../services/watch_history_service.dart';
import '../widgets/watch_progress_bar.dart';
import 'movie_detail_screen.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  final WatchHistoryService _watchHistoryService = WatchHistoryService();
  List<WatchHistoryItem> _watchHistory = [];
  bool _isLoading = true;
  bool _isRetrying = false;
  String? _errorMessage;
  int _retryCount = 0;
  
  @override
  void initState() {
    super.initState();
    _loadWatchHistory();
  }
  
  Future<void> _loadWatchHistory({bool isRetry = false}) async {
    if (isRetry) {
      setState(() {
        _isRetrying = true;
        _retryCount++;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final history = await _watchHistoryService.getWatchHistory();
      if (mounted) {
        setState(() {
          _watchHistory = history;
          _isLoading = false;
          _isRetrying = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isRetrying = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        title: const Text(
          'Watch History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isRetrying ? null : () => _loadWatchHistory(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE21221)),
            SizedBox(height: 16),
            Text(
              'Loading your watch history...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    
    if (_isRetrying) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFE21221)),
            const SizedBox(height: 16),
            Text(
              'Retrying... (Attempt $_retryCount)',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Error: ${_errorMessage!.replaceAll('Exception: ', '')}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'There might be an issue with the server or your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadWatchHistory(isRetry: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE21221),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Clear error and show any cached data or empty state
                setState(() {
                  _errorMessage = null;
                  _watchHistory = [];  
                });
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_watchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 60,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'You haven\'t watched any movies yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your watch history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/'); // Navigate to home screen
              },
              icon: const Icon(Icons.movie_outlined),
              label: const Text('Discover Movies'),
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
    
    return RefreshIndicator(
      onRefresh: _loadWatchHistory,
      color: const Color(0xFFE21221),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _watchHistory.length,
        itemBuilder: (context, index) {
          final item = _watchHistory[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(
                      movieId: item.movie.id,
                    ),
                  ),
                ).then((_) {
                  // Refresh data when returning from movie details
                  _loadWatchHistory();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF211F30),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie poster
                      Hero(
                        tag: 'poster_history_${item.movie.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w185${item.movie.posterPath}',
                            height: 120,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                width: 80,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.broken_image, color: Colors.white54),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Movie info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Watched on ${_formatDate(item.watchedAt)}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            WatchProgressBar(
                              progress: item.progress,
                              height: 8.0,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.progress == 100
                                      ? 'Completed'
                                      : '${item.progress}% watched',
                                  style: TextStyle(
                                    color: item.progress == 100
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.shade400,
                                    fontSize: 14.0,
                                    fontWeight: item.progress == 100
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (item.progress < 100)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieDetailScreen(
                                            movieId: item.movie.id,
                                          ),
                                        ),
                                      ).then((_) {
                                        _loadWatchHistory();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE21221),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
