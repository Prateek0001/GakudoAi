import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rx_logix/models/postPaymentPayload.dart';
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

        // final paymentCharges = await getPaymentFeatureChargesConfig(username, authResponse.accessToken);
        // await prefs.setString(StorageConstants.paymentCharges, paymentCharges);
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

  @override
  Future<String> getPaymentFeatureChargesConfig(String userName,String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentFeatureChargesConfig}?username=$userName'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        if(response.body=='null'){
          return '';
        }else{
          return jsonDecode(response.body);
        }
    
      } else {
        final error = jsonDecode(response.body);
        if (error['detail'] is List) {
          throw Exception(error['detail'][0]['msg']);
        }
        throw Exception(error['detail'] ?? 'Failed to fetch payment feature charges config');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Future<bool> getPaymentStatus(String userName, String token,String feature) async {
 try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentStatusEndpoint}?username=$userName'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        Map<String,dynamic> paymentStatus=jsonDecode(response.body);
       if(feature=="session"){
        return paymentStatus["session_pmt_status"]==false?false:true;
       }else if(feature=="report"){
        return paymentStatus["report_pmt_status"]==false?false:true;
       }else if(feature=="chat"){
        return paymentStatus["chat_pmt_status"]==false?false:true;
       }
        return false;
      } else {
        final error = jsonDecode(response.body);
        if (error['detail'] is List) {
          throw Exception(error['detail'][0]['msg']);
        }
        throw Exception(error['detail'] ?? 'Failed to fetch payment status');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Future<bool> postPayment(String token,PostPaymentPayload payload) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postPaymentEndpoint}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: jsonEncode(payload.toJson()),
      );
      if (response.statusCode == 200) {
          return response.body.contains('Transaction updated successfully')?true:false;
      } else {
        final error = jsonDecode(response.body);
        if (error['detail'] is List) {
          throw Exception(error['detail'][0]['msg']);
        }
        throw Exception(error['detail'] ?? 'Failed to post payment');
      }
    }
    catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Future<Map<String,dynamic>> createOrder(String username, String token, String feature) async {
 try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createOrder}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: jsonEncode({
  "username": username,
  "feature": feature
}),
      );
      if (response.statusCode == 200) {
          return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        if (error['detail'] is List) {
          throw Exception(error['detail'][0]['msg']);
        }
        throw Exception(error['detail'] ?? 'Failed to create order');
      }
    }
    catch (e) {
      throw Exception('Failed to connect to server');
    }


  }
  
}
