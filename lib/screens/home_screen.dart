import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/trending_movie_card.dart';
import '../widgets/search_bar_widget.dart';
import 'see_all_movies_screen.dart';
import 'search_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const HomeScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoadingPopular = true;
  bool _isLoadingTrending = true;
  List<Movie> _popularMoviesList = [];
  List<Movie> _trendingMoviesList = [];
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularMovies();
    _loadTrendingMovies();
    _loadUserData();
  }

  Future<void> _loadPopularMovies() async {
    setState(() {
      _isLoadingPopular = true;
    });
    try {
      _popularMoviesList = await _apiService.getPopularMovies();
    } catch (e) {
      debugPrint("Error loading popular movies: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPopular = false;
        });
      }
    }
  }

  Future<void> _loadTrendingMovies() async {
    setState(() {
      _isLoadingTrending = true;
    });
    try {
      _trendingMoviesList = await _apiService.getTrendingMovies();
    } catch (e) {
      debugPrint("Error loading trending movies: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTrending = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/logo.png',
          height: 35,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _user == null
              ? Center(child: Text('Error loading user data'))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Bar Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Watch Now",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to search screen when search bar is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SearchScreen(),
                                  ),
                                );
                              },
                              child: const SearchBarWidget(),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Trending Movies Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trending',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to See All Trending Movies
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeeAllMoviesScreen(
                                          title: 'Trending Movies',
                                          initialMovies: _trendingMoviesList,
                                          category: 'trending',
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white54,
                                  ),
                                  child: const Text("See all"),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            height: 200,
                            child: _isLoadingTrending
                                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                                : _trendingMoviesList.isEmpty
                                    ? const Center(child: Text('No trending movies available'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(left: 16),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _trendingMoviesList.length,
                                        itemBuilder: (context, index) {
                                          return TrendingMovieCard(movie: _trendingMoviesList[index]);
                                        },
                                      ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Popular Movies Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Popular',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to See All Popular Movies
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeeAllMoviesScreen(
                                          title: 'Popular Movies',
                                          initialMovies: _popularMoviesList,
                                          category: 'popular',
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white54,
                                  ),
                                  child: const Text("See all"),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _isLoadingPopular
                              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                              : _popularMoviesList.isEmpty
                                  ? const Center(child: Text('No popular movies available'))
                                  : GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _popularMoviesList.length > 4 ? 4 : _popularMoviesList.length, // Limit to 4 items
                                      itemBuilder: (context, index) {
                                        return MovieCard(movie: _popularMoviesList[index]);
                                      },
                                    ),
                                    
                          const SizedBox(height: 24),
                          
                          // Add more movie sections using the _buildMovieSection helper
                          // For example, you could add upcoming, top rated, now playing sections
                          _buildAdditionalMovieSections(),
                        ],
                      ),
                    ),
                  ),
                ),
      // Only show bottom nav if specifically requested (for standalone usage)
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomNavItem(Icons.home, 'Home', true),
          _bottomNavItem(Icons.play_circle_outline, 'Movies', false),
          _bottomNavItem(Icons.favorite_border, 'Favorites', false),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: _bottomNavItem(Icons.person_outline, 'Profile', false),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textDisabled,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primary : AppColors.textDisabled,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

 
  // Additional movie sections that could be added to the home screen
  Widget _buildAdditionalMovieSections() {
    // This is a placeholder for adding more movie sections
    // Each section would need its own state variables and data loading methods
    
    return const SizedBox.shrink(); // Return empty widget for now
    
    // Example of what you might add:
    // return Column(
    //   children: [
    //     _buildMovieSection(context, 'Upcoming Movies', _upcomingMoviesList, 'upcoming', _isLoadingUpcoming),
    //     const SizedBox(height: 24),
    //     _buildMovieSection(context, 'Top Rated', _topRatedMoviesList, 'top_rated', _isLoadingTopRated),
    //   ],
    // );
  }
}
