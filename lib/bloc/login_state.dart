import 'package:equatable/equatable.dart';

abstract class LoginState {}

class InitialState extends LoginState {}

class LoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final String token;
  
  LoginSuccessState(this.token);
}

class ErrorState extends LoginState {
  final String message;
  
  ErrorState(this.message);
}

class ForgotPasswordSuccessState extends LoginState {
  final String message;
  ForgotPasswordSuccessState(this.message);
} 