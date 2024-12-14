import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../models/user_data.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoadingState());
      // TODO: Implement your dashboard data loading logic here
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call
      
      final userData = UserData(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
      );
      
      emit(DashboardLoadedState(userData));
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO: Implement logout logic here
    emit(DashboardInitial());
  }
} 