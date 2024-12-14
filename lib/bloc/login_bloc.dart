import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(InitialState()) {
    on<LoginSubmitEvent>(_onLoginSubmit);
    on<ForgotPasswordEvent>(_onForgotPassword);
  }

  Future<void> _onLoginSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoadingState());
    try {
      final token = await authRepository.login(
        event.username,
        event.password,
      );
      emit(LoginSuccessState(token));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoadingState());
    try {
      final message = await authRepository.forgotPassword(event.email);
      emit(ForgotPasswordSuccessState(message));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }
}
