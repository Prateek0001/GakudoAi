import 'package:equatable/equatable.dart';

abstract class SignupEvent {}

class SignupSubmitEvent extends SignupEvent {
  final String email;
  final String fullName;
  final String username;
  final String password;
  final String mobileNumber;

  SignupSubmitEvent({
    required this.email,
    required this.fullName,
    required this.username,
    required this.password,
    required this.mobileNumber,
  });
} 