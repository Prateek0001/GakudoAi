import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_logix/repositories/auth/auth_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;

  SignupBloc({required this.authRepository}) : super(SignupInitial()) {
    on<SignupSubmitEvent>(_onSignupSubmit);
  }

  Future<void> _onSignupSubmit(
    SignupSubmitEvent event,
    Emitter<SignupState> emit,
  ) async {
    try {
      emit(SignupLoadingState());
      await authRepository.register(
        email: event.email,
        fullName: event.fullName,
        username: event.username,
        password: event.password,
        mobileNumber: event.mobileNumber,
      );
      emit(SignupSuccessState());
    } catch (e) {
      emit(SignupErrorState(e.toString()));
    }
  }
} 