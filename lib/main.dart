import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moveyes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1D192B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9A4FFF), 
          secondary: Color(0xFFB277F8), 
          surface: Color(0xFF2D2741), 
          background: Color(0xFF1D192B),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1D192B),
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.poppins(
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.poppins(
            color: Colors.white70,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2D2741).withOpacity(0.9), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
