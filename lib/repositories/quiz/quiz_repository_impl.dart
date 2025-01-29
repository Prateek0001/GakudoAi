import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../../models/quiz.dart';
import 'quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  @override
  Future<Quiz> loadQuiz(String quizId, String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/quiz/?quiz_id=$quizId&user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else {
        throw Exception('Failed to load quiz');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<void> submitQuiz({
    required String username,
    required String email,
    required String userId,
    required String mobileNumber,
    required String quizId,
    required Map<String, String> answers,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizSubmissionEndpoint}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'user_id': userId,
          'mobile_number': mobileNumber,
          'quizId': quizId,
          'responses': answers,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit quiz');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkQuizCompletion(String quizId, String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkQuizCompletion}/?quiz_id=$quizId&user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message_code'] == 'already_submitted';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check quiz completion: ${e.toString()}');
    }
  }

  @override
  Future<void> generateReport(String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizReportEndpoint}/?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: '{}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<String> getReportDownloadLink(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/report-download-link/?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        throw Exception('Failed to get download link');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkReportStatus(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/check-report-exist/?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message_code'] == 'already_generated';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check report status: ${e.toString()}');
    }
  }
}
