import 'package:flutter_bloc/flutter_bloc.dart';
import 'experts_event.dart';
import 'experts_state.dart';
import '../models/expert.dart';

class ExpertsBloc extends Bloc<ExpertsEvent, ExpertsState> {
  List<Expert> _allExperts = [];

  ExpertsBloc() : super(ExpertsInitial()) {
    on<LoadExpertsEvent>(_onLoadExperts);
    on<FilterExpertsEvent>(_onFilterExperts);
    on<SearchExpertsEvent>(_onSearchExperts);
  }

  Future<void> _onLoadExperts(
    LoadExpertsEvent event,
    Emitter<ExpertsState> emit,
  ) async {
    try {
      emit(ExpertsLoadingState());

      // Simulated API call - Replace with your actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _allExperts = [
        Expert(
          id: '1',
          name: 'Dr. Sarah Johnson',
          specialization: 'Cognitive Behavioral Therapy',
          experience: '10 years',
          rating: 4.8,
          pricePerHour: 1500.00,
          imageUrl: 'https://example.com/expert1.jpg',
          availableSlots: _generateTimeSlots(),
        ),
        Expert(
          id: '2',
          name: 'Dr. Michael Chen',
          specialization: 'Relationship Counseling',
          experience: '8 years',
          rating: 4.6,
          pricePerHour: 1200.00,
          imageUrl: 'https://example.com/expert2.jpg',
          availableSlots: _generateTimeSlots(),
        ),
        Expert(
          id: '3',
          name: 'Dr. Emily Brown',
          specialization: 'Anxiety Management',
          experience: '12 years',
          rating: 4.9,
          pricePerHour: 1800.00,
          imageUrl: 'https://example.com/expert3.jpg',
          availableSlots: _generateTimeSlots(),
        ),
        // Add more experts as needed
      ];

      final specializations = _allExperts
          .map((expert) => expert.specialization)
          .toSet()
          .toList();

      emit(ExpertsLoadedState(
        experts: _allExperts,
        specializations: specializations,
      ));
    } catch (e) {
      emit(ExpertsErrorState(e.toString()));
    }
  }

  void _onFilterExperts(
    FilterExpertsEvent event,
    Emitter<ExpertsState> emit,
  ) {
    try {
      if (event.specialization.isEmpty) {
        emit(ExpertsLoadedState(
          experts: _allExperts,
          specializations: _getSpecializations(),
        ));
        return;
      }

      final filteredExperts = _allExperts
          .where((expert) => expert.specialization == event.specialization)
          .toList();

      emit(ExpertsLoadedState(
        experts: filteredExperts,
        specializations: _getSpecializations(),
      ));
    } catch (e) {
      emit(ExpertsErrorState(e.toString()));
    }
  }

  void _onSearchExperts(
    SearchExpertsEvent event,
    Emitter<ExpertsState> emit,
  ) {
    try {
      if (event.query.isEmpty) {
        emit(ExpertsLoadedState(
          experts: _allExperts,
          specializations: _getSpecializations(),
        ));
        return;
      }

      final searchQuery = event.query.toLowerCase();
      final searchResults = _allExperts.where((expert) {
        return expert.name.toLowerCase().contains(searchQuery) ||
            expert.specialization.toLowerCase().contains(searchQuery);
      }).toList();

      emit(ExpertsLoadedState(
        experts: searchResults,
        specializations: _getSpecializations(),
      ));
    } catch (e) {
      emit(ExpertsErrorState(e.toString()));
    }
  }

  List<String> _getSpecializations() {
    return _allExperts.map((expert) => expert.specialization).toSet().toList();
  }

  List<String> _generateTimeSlots() {
    return [
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
    ];
  }
} 