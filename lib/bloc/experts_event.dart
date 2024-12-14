import 'package:equatable/equatable.dart';

abstract class ExpertsEvent extends Equatable {
  const ExpertsEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpertsEvent extends ExpertsEvent {}

class FilterExpertsEvent extends ExpertsEvent {
  final String specialization;

  const FilterExpertsEvent(this.specialization);

  @override
  List<Object?> get props => [specialization];
}

class SearchExpertsEvent extends ExpertsEvent {
  final String query;

  const SearchExpertsEvent(this.query);

  @override
  List<Object?> get props => [query];
} 