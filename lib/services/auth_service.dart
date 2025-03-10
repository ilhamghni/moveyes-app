import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/api/auth';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Use secure storage for sensitive information
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting login with: $email');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveAuthData(authResponse);
        if (kDebugMode) {
          print('Login successful, token saved');
        }
        return true;
      } else {
        debugPrint('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }
  
  Future<bool> register(String email, String password, String name) async {
    try {
      if (kDebugMode) {
        print('Attempting registration for: $email');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('Registration successful');
        return true;
      } else {
        debugPrint('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    // Save token in secure storage
    await _secureStorage.write(key: tokenKey, value: authResponse.token);
    
    // Save non-sensitive user data in SharedPreferences for faster access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(authResponse.user.toJson()));
    
    debugPrint('Auth data saved successfully');
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: tokenKey);
      final result = token != null && token.isNotEmpty;
      debugPrint('isLoggedIn check: $result');
      return result;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: tokenKey);
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
      
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }
}
