import 'package:equatable/equatable.dart';
import '../models/expert.dart';

abstract class ExpertsState extends Equatable {
  const ExpertsState();

  @override
  List<Object?> get props => [];
}

class ExpertsInitial extends ExpertsState {}

class ExpertsLoadingState extends ExpertsState {}

class ExpertsLoadedState extends ExpertsState {
  final List<Expert> experts;
  final List<String> specializations;

  const ExpertsLoadedState({
    required this.experts,
    required this.specializations,
  });

  @override
  List<Object?> get props => [experts, specializations];
}

class ExpertsErrorState extends ExpertsState {
  final String message;

  const ExpertsErrorState(this.message);

  @override
  List<Object?> get props => [message];
} 