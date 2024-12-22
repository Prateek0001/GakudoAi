import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rx_logix/models/user_profile.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final _prefs = SharedPreferences.getInstance();

  QuizBloc() : super(QuizInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<SubmitQuizEvent>(_onSubmitQuiz);
  }

  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());

      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/quiz/${event.quizId}'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quiz = Quiz.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        final completedQuizzes = prefs.getStringList('completed_quizzes') ?? [];

        emit(QuizLoadedState(
          quiz: quiz,
          completedQuizzes: completedQuizzes,
        ));
      } else {
        emit(QuizErrorState('Failed to load quiz'));
      }
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.authToken) ?? '';
  }

  Future<void> _onSubmitQuiz(
      SubmitQuizEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());

      final token = await _getAuthToken();
      final userProfile = await _getUserProfile();

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/save-quiz-response/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: jsonEncode({
          'username': userProfile.username,
          'email': userProfile.email,
          'user_id': userProfile.id,
          'mobile_number': userProfile.mobileNumber,
          'quizId': event.quizId,
          'responses': event.answers,
        }),
      );

      if (response.statusCode == 200) {
        // Save completed quiz locally
        final prefs = await SharedPreferences.getInstance();
        final completedQuizzes = prefs.getStringList('completed_quizzes') ?? [];
        if (!completedQuizzes.contains(event.quizId)) {
          completedQuizzes.add(event.quizId);
          await prefs.setStringList('completed_quizzes', completedQuizzes);
        }

        emit(QuizSubmittedState());
      } else {
        throw Exception('Failed to submit quiz');
      }
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }

  Future<UserProfile?> _getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString(StorageConstants.userProfile);
    if (userProfileJson != null) {
      return UserProfile.fromJson(jsonDecode(userProfileJson));
    }
    return null;
  }
}
