import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/user_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(DashboardLoadingState());
      final user = await UserService.getCurrentUser();
      if (user != null) {
        emit(DashboardLoadedState(user));
      } else {
        emit(const DashboardErrorState('User profile not found'));
      }
    } catch (e) {
      emit(DashboardErrorState(e.toString()));
    }
  }
} 