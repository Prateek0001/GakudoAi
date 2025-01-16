class ApiConstants {
  static const String baseUrl = 'http://20.40.51.129:8000';

  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String loginEndpoint = '/api/v1/token';
  static const String registerEndpoint = '/api/v1/register';
  static const String userProfileEndpoint = '/api/v1/users/profile';
  static const String forgotPasswordEndpoint = '/api/v1/users/forgot-password';
  static const String chatEndpoint = '/api/v1/chat';

  // Payment endpoints
  static const String paymentFeatureChargesConfig = '/api/v1/feature-charges-config';
  static const String paymentStatusEndpoint = '/api/v1/user-payment-status/';
  static const String postPaymentEndpoint = '/api/v1/post-rzp-pmt/';
  static const String createOrder = '/api/v1/create-order/';

  // Add this line
  static const String checkQuizCompletion = '/api/v1/check-quiz-response-exist';
}
