import 'package:flutter/material.dart';
import '../screens/search_screen.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onSearch;

  const SearchBarWidget({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF211F30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.white54,
            ),
            const SizedBox(width: 8),
            const Text(
              'Search for movies...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
