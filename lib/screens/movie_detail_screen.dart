import 'package:flutter/material.dart';
import '../models/movie_detail.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'see_all_movies_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<MovieDetail> _movieDetailFuture;
  late AnimationController _animationController;
  late Animation<double> _backdropAnimation;
  late Animation<double> _contentFadeAnimation;
  final ScrollController _scrollController = ScrollController();

  // Track if we've initialized the animation
  bool _animationInitialized = false;

  @override
  void initState() {
    super.initState();
    _movieDetailFuture = _apiService.getMovieDetails(widget.movieId);
    
    // Setup animation controller with longer duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    // Backdrop animation - start taking full screen, then animate to collapse
    _backdropAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Content fade animation starts after backdrop animation is mostly done
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openTrailer(String? videoKey) async {
    if (videoKey != null) {
      final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      body: FutureBuilder<MovieDetail>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE21221)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No movie details available'));
          }

          final movie = snapshot.data!;
          
          // Once data is loaded, start animation if not already initialized
          if (!_animationInitialized) {
            // Add a tiny delay before starting animation for better UX
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _animationController.forward();
              }
            });
            _animationInitialized = true;
          }

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Animated fullscreen backdrop image
                  if (movie.backdropPath != null)
                    Positioned.fill(
                      child: FractionallySizedBox(
                        // Start with fullscreen and reduce height as animation progresses
                        heightFactor: 1.0 - (0.7 * (1 - _backdropAnimation.value)),
                        alignment: Alignment.topCenter,
                        child: Hero(
                          tag: 'movie-backdrop-${movie.id}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                '${ApiService.backdropBaseUrl}${movie.backdropPath}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                              ),
                              // Gradient overlay that increases as animation progresses
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF15141F).withOpacity(0.5 + (0.5 * (1 - _backdropAnimation.value))),
                                      const Color(0xFF15141F),
                                    ],
                                    stops: [0.3, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Main content - scrollable area with details
                  Positioned.fill(
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: _backdropAnimation.value > 0.1 
                          ? const NeverScrollableScrollPhysics() // Disable scrolling during initial animation
                          : const BouncingScrollPhysics(),
                      slivers: [
                        // Spacing SliverAppBar that takes the place of the animated backdrop
                        SliverAppBar(
                          expandedHeight: MediaQuery.of(context).size.height * (0.25 + (_backdropAnimation.value * 0.75)),
                          backgroundColor: Colors.transparent,
                          stretch: true,
                          pinned: true,
                          leading: AnimatedOpacity(
                            opacity: 1.0 - _backdropAnimation.value,
                            duration: const Duration(milliseconds: 200),
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          actions: [
                            AnimatedOpacity(
                              opacity: 1.0 - _backdropAnimation.value,
                              duration: const Duration(milliseconds: 200),
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.favorite_border),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(color: Colors.transparent),
                          ),
                        ),
                        
                        // Movie Content with Animation
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _contentFadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Movie Title and Year
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        movie.year,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Rating, Runtime, and Status
                                  Row(
                                    children: [
                                      // Rating Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE21221),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              movie.voteAverage.toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Runtime
                                      Text(
                                        movie.formattedRuntime,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                        child: Text('•', style: TextStyle(color: Colors.white70)),
                                      ),
                                      
                                      // Status
                                      Text(
                                        movie.status,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Genres
                                  SizedBox(
                                    height: 32,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: movie.genres.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF211F30),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          child: Text(
                                            movie.genres[index],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Watch Trailer Button
                                  if (movie.trailerKey != null)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _openTrailer(movie.trailerKey),
                                        icon: const Icon(Icons.play_circle_filled),
                                        label: const Text('Watch Trailer'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE21221),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // Overview Title
                                  const Text(
                                    'Overview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Overview Content
                                  Text(
                                    movie.overview,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Cast Title
                                  const Text(
                                    'Cast',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Cast List
                                  SizedBox(
                                    height: 140,
                                    child: movie.cast.isNotEmpty
                                        ? ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: movie.cast.length,
                                            itemBuilder: (context, index) {
                                              final cast = movie.cast[index];
                                              return Container(
                                                width: 90,
                                                margin: const EdgeInsets.only(right: 10),
                                                child: Column(
                                                  children: [
                                                    // Cast Image
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(45),
                                                      child: cast.profilePath != null
                                                          ? Image.network(
                                                              '${ApiService.imageBaseUrl}${cast.profilePath}',
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) => Container(
                                                                height: 70,
                                                                width: 70,
                                                                color: Colors.grey[800],
                                                                child: const Center(
                                                                  child: Icon(
                                                                    Icons.person,
                                                                    size: 30,
                                                                    color: Colors.white54,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 70,
                                                              width: 70,
                                                              color: Colors.grey[800],
                                                              child: const Center(
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 30,
                                                                  color: Colors.white54,
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Cast Name
                                                    Text(
                                                      cast.name,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    // Character Name
                                                    Text(
                                                      cast.character,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Text('No cast information available'),
                                          ),
                                  ),

                                  // Directors and Writers
                                  if (movie.crew.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    // Directors
                                    if (movie.crew.any((crew) => crew.job == 'Director')) ...[
                                      const Text(
                                        'Director',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...movie.crew
                                          .where((crew) => crew.job == 'Director')
                                          .map((director) => Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  director.name,
                                                  style: const TextStyle(color: Colors.white70),
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                    
                                    // Writers
                                    if (movie.crew.any((crew) => crew.department == 'Writing')) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Writers',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...movie.crew
                                          .where((crew) => crew.department == 'Writing')
                                          .map((writer) => Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  '${writer.name} (${writer.job})',
                                                  style: const TextStyle(color: Colors.white70),
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ],

                                  // Similar Movies Section
                                  if (movie.similarMovies.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    
                                    // Similar Movies Title
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Similar Movies',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context, 
                                              MaterialPageRoute(
                                                builder: (context) => SeeAllMoviesScreen(
                                                  title: 'Similar to ${movie.title}',
                                                  initialMovies: movie.similarMovies,
                                                  category: 'similar',
                                                  movieId: movie.id,
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
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Similar Movies Grid
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: movie.similarMovies.length.clamp(0, 4),
                                      itemBuilder: (context, index) {
                                        return MovieCard(movie: movie.similarMovies[index]);
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
