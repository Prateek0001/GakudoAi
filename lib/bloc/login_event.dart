import 'package:equatable/equatable.dart';

abstract class LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  final String username;
  final String password;

  LoginSubmitEvent({
    required this.username,
    required this.password,
  });
}

class ForgotPasswordEvent extends LoginEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
} 