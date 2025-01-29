class ApiConstants {
  static const String baseUrl = 'http://20.40.51.129:8000';

  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String loginEndpoint = '/api/v1/token';
  static const String registerEndpoint = '/api/v1/register';
  static const String userProfileEndpoint = '/api/v1/users/profile';
  static const String forgotPasswordEndpoint = '/api/v1/users/forgot-password';
  static const String logoutEndpoint = '/api/v1/logout';

  // Chat endpoints
  static const String chatEndpoint = '/api/v1/chat';
  static const String chatHistoryEndpoint = '/api/v1/chat-history';

  // Payment endpoints
  static const String paymentFeatureChargesConfig = '/api/v1/feature-charges-config';
  static const String paymentStatusEndpoint = '/api/v1/user-payment-status';
  static const String postPaymentEndpoint = '/api/v1/post-rzp-pmt/';
  static const String createOrder = '/api/v1/create-order/';

  // Quiz endpoints
  static const String quizEndpoint = '/api/v1/quiz';
  static const String checkQuizCompletion = '/api/v1/check-quiz-response-exist';
  static const String quizSubmissionEndpoint = '/api/v1/save-quiz-response';
  static const String quizReportEndpoint = '/api/v1/generate-report';
  static const String reportDownloadEndpoint = '/api/v1/report-download-link';
  static const String checkReportExistEndpoint = '/api/v1/check-report-exist';

  // Booking endpoints
  static const String createBookingEndpoint = '/api/v1/booking/';
  static const String fetchBookingsEndpoint = '/api/v1/fetch-booking';
  static const String cancelBookingEndpoint = '/api/v1/cancel-booking';
  static const String rescheduleBookingEndpoint = '/api/v1/reschedule-booking';
}
