import '../models/quiz.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoadingState extends QuizState {}

class QuizLoadedState extends QuizState {
  final Quiz quiz;
  final List<String> completedQuizzes;

  QuizLoadedState({
    required this.quiz,
    required this.completedQuizzes,
  });
}

class QuizErrorState extends QuizState {
  final String message;

  QuizErrorState(this.message);
}

class QuizSubmittedState extends QuizState {}
