abstract class QuizEvent {}

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