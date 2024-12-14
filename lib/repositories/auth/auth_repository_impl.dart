import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_response.dart';
import '../../models/register_response.dart';
import 'auth_repository.dart';
import '../../models/user_profile.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _baseUrl = 'http://98.70.49.14:8000';
  static const String _tokenKey = 'auth_token';

  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/api/v1/token?username=$username&password=$password'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, authResponse.accessToken);

        // Fetch user profile after successful login
        try {
          final userProfile = await getUserProfile(authResponse.accessToken);
          // Convert UserProfile object to JSON-compatible map
          final userProfileJson = userProfile.toJson();

          // Store JSON string in SharedPreferences
          await prefs.setString('user_profile', jsonEncode(userProfileJson));
        } catch (e) {
          print('Failed to fetch user profile: ${e.toString()}');
          // Don't throw the error as login was successful
        }

        return authResponse.accessToken;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to connect to server ${e.toString()}');
    }
  }

  @override
  Future<UserProfile> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/users/profile'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/users/forgot-password/?email=$email'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return 'Password reset instructions sent to your email';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to process request');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Future<RegisterResponse> register({
    required String email,
    required String fullName,
    required String username,
    required String password,
    required String mobileNumber,
    String medium = "English",
    String schoolName = "Default School",
    int standard = 10,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/register'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'full_name': fullName,
          'username': username,
          'password': password,
          'mobile_number': mobileNumber,
          'medium': medium,
          'school_name': schoolName,
          'standard': standard,
        }),
      );

      if (response.statusCode == 200) {
        return RegisterResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        if (error['detail'] is List) {
          throw Exception(error['detail'][0]['msg']);
        }
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
}
