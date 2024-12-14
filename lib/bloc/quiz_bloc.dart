import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final _prefs = SharedPreferences.getInstance();
  
  QuizBloc() : super(QuizInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<SubmitQuizEvent>(_onSubmitQuiz);
  }

  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());
      
      // Simulated quiz data - In real app, this would come from API
      final quiz = Quiz(
        id: event.quizId,
        title: 'Quiz ${event.quizId}',
        questions: List.generate(
          10,
          (index) => Question(
            id: 'q${index + 1}',
            text: 'Question ${index + 1}: Sample question text goes here?',
            options: List.generate(
              4,
              (optIndex) => Option(
                id: 'opt${optIndex + 1}',
                text: 'Option ${optIndex + 1}',
              ),
            ),
            correctOptionId: 'opt1',
          ),
        ),
      );

      // Get completed quizzes from SharedPreferences
      final prefs = await _prefs;
      final completedQuizzes = prefs.getStringList('completed_quizzes') ?? [];

      emit(QuizLoadedState(
        quiz: quiz,
        completedQuizzes: completedQuizzes,
      ));
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }

  Future<void> _onSubmitQuiz(SubmitQuizEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());

      // Save completed quiz to SharedPreferences
      final prefs = await _prefs;
      final completedQuizzes = prefs.getStringList('completed_quizzes') ?? [];
      
      if (!completedQuizzes.contains(event.quizId)) {
        completedQuizzes.add(event.quizId);
        await prefs.setStringList('completed_quizzes', completedQuizzes);
      }

      // In a real app, you would also submit the answers to an API
      // await quizRepository.submitQuiz(event.quizId, event.answers);

      // Reload the quiz state
      add(LoadQuizEvent(event.quizId));
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }
} 