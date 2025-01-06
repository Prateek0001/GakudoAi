import 'package:rx_logix/models/postPaymentPayload.dart';
import 'package:rx_logix/models/register_response.dart';
import '../../models/user_profile.dart';

abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String> forgotPassword(String email);
  Future<RegisterResponse> register({
    required String email,
    required String fullName,
    required String username,
    required String password,
    required String mobileNumber,
    required String standard,
    String medium = "English",
    String schoolName = "Default School",
  });
  Future<UserProfile> getUserProfile(String token);
  Future<String> getPaymentFeatureChargesConfig(String userName,String token);
  Future<bool> getPaymentStatus(String userName,String token,String feature);
  Future<bool> postPayment(String token,PostPaymentPayload payload);
  Future<Map<String,dynamic>> createOrder(String username, String token,String feature);
}
