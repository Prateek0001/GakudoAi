abstract class QuizEvent {
  const QuizEvent();
}

class LoadQuizEvent extends QuizEvent {
  final String quizId;

  LoadQuizEvent(this.quizId);
}

class SubmitQuizEvent extends QuizEvent {
  final String quizId;
  final Map<String, String> answers;

  SubmitQuizEvent({
    required this.quizId,
    required this.answers,
  });
}

class GenerateReportEvent extends QuizEvent {
  final String userId;
  const GenerateReportEvent(this.userId);
}

class DownloadReportEvent extends QuizEvent {
  final String userId;
  const DownloadReportEvent(this.userId);
}

class ReportGeneratedEvent extends QuizEvent {}

class CheckQuizCompletionEvent extends QuizEvent {
  final String userId;
  final String quizId;
  const CheckQuizCompletionEvent(this.userId, this.quizId);
}
