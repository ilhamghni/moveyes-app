import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'package:moveyes_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = const [
    HomeScreen(showBottomNav: false),
    // Placeholder pages for movies and favorites
    Center(child: Text('Movies Screen - Coming Soon')),
    Center(child: Text('Favorites Screen - Coming Soon')),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2741).withOpacity(0.9),
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
            _bottomNavItem(0, Icons.home, 'Home'),
            _bottomNavItem(1, Icons.play_circle_outline, 'Movies'),
            _bottomNavItem(2, Icons.favorite_border, 'Favorites'),
            _bottomNavItem(3, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF9A4FFF) : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF9A4FFF) : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
