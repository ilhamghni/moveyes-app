import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  
  List<Movie> _searchResults = [];
  List<Genre> _genres = [];
  List<int> _selectedGenreIds = [];
  int? _selectedYear;
  String _sortOption = 'popularity.desc';
  
  bool _isLoading = false;
  bool _hasMoreMovies = true;
  int _page = 1;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _scrollController.addListener(_scrollListener);
    
    _loadGenres();
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _apiService.getGenres();
      setState(() {
        _genres = genres;
      });
    } catch (e) {
      debugPrint('Error loading genres: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreMovies) {
        _loadMoreResults();
      }
    }
  }

  void _performSearch(String query) {
    // Reset state
    setState(() {
      _searchResults = [];
      _isLoading = true;
      _hasMoreMovies = true;
      _page = 1;
    });

    _searchMovies(query);
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasMoreMovies = false;
      });
      return;
    }

    try {
      final results = await _apiService.searchMovies(
        query: query,
        page: _page,
        genreIds: _selectedGenreIds.isNotEmpty ? _selectedGenreIds : null,
        year: _selectedYear,
        sortBy: _sortOption,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _hasMoreMovies = results.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching movies: $e')),
      );
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading || _searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _page++;
    });

    try {
      final results = await _apiService.searchMovies(
        query: _searchController.text,
        page: _page,
        genreIds: _selectedGenreIds.isNotEmpty ? _selectedGenreIds : null,
        year: _selectedYear,
        sortBy: _sortOption,
      );

      setState(() {
        if (results.isEmpty) {
          _hasMoreMovies = false;
        } else {
          _searchResults.addAll(results);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more results: $e')),
      );
    }
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _applyFilters() {
    _page = 1;
    _performSearch(_searchController.text);
    if (_isFilterVisible) {
      _toggleFilterVisibility();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedGenreIds = [];
      _selectedYear = null;
      _sortOption = 'popularity.desc';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211F30),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: const TextStyle(color: Colors.white60),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                });
              },
            ),
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              _performSearch(value);
            });
          },
          onSubmitted: (value) {
            _performSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _isFilterVisible || _selectedGenreIds.isNotEmpty || _selectedYear != null 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.white,
            ),
            onPressed: _toggleFilterVisibility,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterVisible ? null : 0,
            color: const Color(0xFF211F30),
            child: _isFilterVisible
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort options
                        const Text(
                          'Sort by',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildSortChip('Popularity', 'popularity.desc'),
                            _buildSortChip('Rating', 'vote_average.desc'),
                            _buildSortChip('Newest', 'release_date.desc'),
                            _buildSortChip('Oldest', 'release_date.asc'),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Year filter
                        const Text(
                          'Year',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildYearChip(null),
                              for (int year = DateTime.now().year; year >= 1990; year -= 1)
                                _buildYearChip(year),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Genre filter
                        const Text(
                          'Genres',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _genres.map((genre) {
                            return _buildGenreChip(genre);
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Filter buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _applyFilters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE21221),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Apply Filters'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _resetFilters,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30),
                              ),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          // Search Results
          if (_searchController.text.isEmpty && _searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Search for movies by title',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            )
          else if (_isLoading && _searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE21221)),
              ),
            )
          else if (_searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No movies found',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _searchResults.length + (_hasMoreMovies ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _searchResults.length) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE21221)),
                    );
                  }
                  return MovieCard(movie: _searchResults[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(Genre genre) {
    final isSelected = _selectedGenreIds.contains(genre.id);
    
    return FilterChip(
      label: Text(genre.name),
      selected: isSelected,
      checkmarkColor: Colors.white,
      selectedColor: const Color(0xFFE21221),
      backgroundColor: const Color(0xFF211F30),
      side: const BorderSide(color: Colors.white24),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white,
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedGenreIds.add(genre.id);
          } else {
            _selectedGenreIds.remove(genre.id);
          }
        });
      },
    );
  }

  Widget _buildYearChip(int? year) {
    final isSelected = _selectedYear == year;
    final label = year == null ? 'All Years' : year.toString();
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFE21221),
        backgroundColor: const Color(0xFF211F30),
        side: const BorderSide(color: Colors.white24),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedYear = selected ? year : null;
          });
        },
      ),
    );
  }

  Widget _buildSortChip(String label, String sortValue) {
    final isSelected = _sortOption == sortValue;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFE21221),
      backgroundColor: const Color(0xFF211F30),
      side: const BorderSide(color: Colors.white24),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortOption = sortValue;
          });
        }
      },
    );
  }
}
