import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileService {
  final String baseUrl = 'http://10.0.2.2:3000/api/profile';
  
  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Profile> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Profile> updateProfile({
    String? bio,
    String? avatarUrl,
    String? name,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final Map<String, dynamic> requestBody = {};
      if (bio != null) requestBody['bio'] = bio;
      if (avatarUrl != null) requestBody['avatarUrl'] = avatarUrl;
      if (name != null) requestBody['name'] = name;

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
