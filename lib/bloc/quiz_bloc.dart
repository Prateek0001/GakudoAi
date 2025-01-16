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
  List<String> completedQuizzes = [];

  final _prefs = SharedPreferences.getInstance();

  QuizBloc() : super(QuizInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<GenerateReportEvent>(_onGenerateReport);
    on<DownloadReportEvent>(_onDownloadReport);
    on<CheckQuizCompletionEvent>(_onCheckQuizCompletion);
    _loadCompletedQuizzes();
  }

  Future<void> _loadCompletedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    completedQuizzes = prefs.getStringList('completed_quizzes') ?? [];
  }

  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());

      final token = await _getAuthToken();
      final userProfile = await _getUserProfile();
      
      if (userProfile == null) {
        emit(QuizErrorState('User profile not found'));
        return;
      }

      // Check if quiz is already completed
      final isCompleted = await _checkQuizCompletion(event.quizId, userProfile.username);
      if (isCompleted) {
        if (!completedQuizzes.contains(event.quizId)) {
          completedQuizzes.add(event.quizId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('completed_quizzes', completedQuizzes);
        }
        emit(QuizLoadedState(
          quiz: Quiz(id: event.quizId, questions: []), // Empty quiz since it's completed
          completedQuizzes: completedQuizzes,
        ));
        emit(QuizErrorState('You have already completed this quiz'));
        return;
      }

      // /api/v1/quiz/?quiz_id=4&user_id=check123

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/quiz/?quiz_id=${event.quizId}&user_id=${userProfile.username}'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quiz = Quiz.fromJson(data);

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
        // Update completed quizzes
        if (!completedQuizzes.contains(event.quizId)) {
          completedQuizzes.add(event.quizId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('completed_quizzes', completedQuizzes);
        }

        // Emit new state with updated completed quizzes
        emit(QuizLoadedState(
          quiz: (state as QuizLoadedState).quiz,
          completedQuizzes: completedQuizzes,
        ));
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

  Future<void> _onGenerateReport(
      GenerateReportEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());
      final token = await _getAuthToken();

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/generate-report/?user_id=${event.userId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
        body: '{}',
      );

      if (response.statusCode == 200) {
        emit(ReportGeneratedState());
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }

  Future<void> _onDownloadReport(
      DownloadReportEvent event, Emitter<QuizState> emit) async {
    try {
      emit(QuizLoadingState());
      final token = await _getAuthToken();

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/report-download-link/?user_id=${event.userId}'),
        headers: {
          'Accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ReportDownloadLinkReceivedState(data['url']));
      } else {
        throw Exception('Failed to get download link');
      }
    } catch (e) {
      emit(QuizErrorState(e.toString()));
    }
  }

  Future<bool> _checkQuizCompletion(String quizId, String userId) async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/check-quiz-response-exist/?quiz_id=$quizId&user_id=$userId'),
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
      print('Error checking quiz completion: $e');
      return false;
    }
  }

  Future<void> _onCheckQuizCompletion(
    CheckQuizCompletionEvent event, 
    Emitter<QuizState> emit
  ) async {
    try {
      final isCompleted = await _checkQuizCompletion(event.quizId, event.userId);
      if (isCompleted && !completedQuizzes.contains(event.quizId)) {
        completedQuizzes.add(event.quizId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('completed_quizzes', completedQuizzes);
      }
      emit(QuizLoadedState(
        quiz: Quiz(id: event.quizId, questions: []),
        completedQuizzes: completedQuizzes,
      ));
    } catch (e) {
      print('Error checking quiz completion: $e');
    }
  }
}
