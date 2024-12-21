class ApiConstants {
  static const String baseUrl = 'http://98.70.49.14:8000';

  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String loginEndpoint = '/api/v1/token';
  static const String registerEndpoint = '/api/v1/register';
  static const String userProfileEndpoint = '/api/v1/users/profile';
  static const String forgotPasswordEndpoint = '/api/v1/users/forgot-password';
  static const String chatEndpoint = '/api/v1/chat';
}
