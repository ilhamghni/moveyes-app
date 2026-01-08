import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class ProfileService {
  final String baseUrl = '${dotenv.env['BASE_URL']!}/profile';
  static const String tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get auth token with error handling
  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token == null || token.isEmpty) {
        print('No token found in secure storage');
      }
      return token;
    } catch (e) {
      print('Error retrieving token from secure storage: $e');
      return null;
    }
  }

  // Get user profile
  Future<Profile> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Profile.fromJson(data);
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Failed to fetch profile';
        throw Exception(error);
      }
    } catch (e) {
      print('Error getting profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  Future<Profile> updateProfile({
    String? bio,
    String? avatarUrl,
    String? name,
    String? nickname,
    String? hobbies,
    Map<String, dynamic>? socialMedia,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Build request body with only the fields that are provided
      final Map<String, dynamic> requestBody = {};
      if (bio != null) requestBody['bio'] = bio;
      if (avatarUrl != null) requestBody['avatarUrl'] = avatarUrl;
      if (name != null) requestBody['name'] = name;
      if (nickname != null) requestBody['nickname'] = nickname;
      if (hobbies != null) requestBody['hobbies'] = hobbies;
      if (socialMedia != null) requestBody['socialMedia'] = socialMedia;

      print('Updating profile with: $requestBody');

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Update profile response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Profile.fromJson(data);
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Failed to update profile';
        throw Exception(error);
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
