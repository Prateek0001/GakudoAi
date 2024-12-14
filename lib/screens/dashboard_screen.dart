import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/string_constants.dart';
import '../screens/quiz_list_screen.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../services/user_service.dart';
import '../repositories/auth/auth_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadUserProfileEvent()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.logout();
      await UserService.clearUserData();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(StringConstants.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardErrorState) {
            return Center(child: Text(state.message));
          } else if (state is DashboardLoadedState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${state.userProfile.fullName}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 32),
                    _buildDashboardCard(
                      context,
                      title: '1. Complete/Update Profile',
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCard(
                      context,
                      title: '2. Complete Tests',
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => QuizBloc(),
                              child: const QuizListScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCard(
                      context,
                      title: '3. Download Report',
                      icon: Icons.cloud_download_outlined,
                      onTap: () {
                        // TODO: Implement report download
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              Icon(
                icon,
                size: 48,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
