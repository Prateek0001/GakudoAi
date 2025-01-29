import '../../models/quiz.dart';

abstract class QuizRepository {
  Future<Quiz> loadQuiz(String quizId, String userId, String token);
  Future<void> submitQuiz({
    required String username,
    required String email,
    required String userId,
    required String mobileNumber,
    required String quizId,
    required Map<String, String> answers,
    required String token,
  });
  Future<bool> checkQuizCompletion(String quizId, String userId, String token);
  Future<void> generateReport(String userId, String token);
  Future<String> getReportDownloadLink(String userId, String token);
  Future<bool> checkReportStatus(String userId, String token);
}
