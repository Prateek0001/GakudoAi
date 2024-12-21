import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_response.dart';
import '../../models/register_response.dart';
import 'auth_repository.dart';
import '../../models/user_profile.dart';
import '../../constants/api_constants.dart';
import '../../constants/storage_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}?username=$username&password=$password'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            StorageConstants.authToken, authResponse.accessToken);

        try {
          final userProfile = await getUserProfile(authResponse.accessToken);
          await prefs.setString(
              StorageConstants.userProfile, jsonEncode(userProfile.toJson()));
        } catch (e) {
          print('Failed to fetch user profile: ${e.toString()}');
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
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfileEndpoint}'),
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
    await prefs.remove(StorageConstants.authToken);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(StorageConstants.authToken);
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordEndpoint}?email=$email'),
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
    required String standard,
    String medium = "English",
    String schoolName = "Default School",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
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
          'standard': standard,
          'medium': medium,
          'school_name': schoolName,
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
