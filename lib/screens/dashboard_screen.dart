import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rx_logix/bloc/payment_bloc.dart';
import 'package:rx_logix/bloc/payment_event.dart';
import 'package:rx_logix/constants/storage_constants.dart';
import 'package:rx_logix/models/user_profile.dart';
import 'package:rx_logix/repositories/auth/auth_repository_impl.dart';
import 'package:rx_logix/repositories/chat/chat_repository.dart';
import 'package:rx_logix/screens/booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/quiz_list_screen.dart';
import '../screens/chat_screen.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../services/user_service.dart';
import '../repositories/auth/auth_repository.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

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

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.logout();
      await UserService.clearUserData();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  Widget _buildCurrentView(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildTestView(context);
      case 2:
        return _buildBookingView();
      case 3:
        return _buildChatView();
      case 4:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardErrorState) {
          return Center(child: Text(state.message));
        } else if (state is DashboardLoadedState) {
          return Container(
            color: Colors.grey[50],
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.userProfile.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCard(
                      context,
                      title: 'Complete Tests',
                      subtitle: 'Take assessment tests to evaluate your skills',
                      icon: Icons.quiz_outlined,
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
                      title: 'Download Report',
                      subtitle: 'View and download your performance reports',
                      icon: Icons.analytics_outlined,
                      onTap: () {
                        // TODO: Implement report download
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTestView(BuildContext context) {
   return BlocProvider(
      create: (context) => QuizBloc(),
      child: const QuizListScreen(),
    );
  }

  Widget _buildBookingView() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingInitial) {
          // Fetch bookings when view is loaded
          context.read<BookingBloc>().add(
                FetchBookingsEvent(
                  context.read<DashboardBloc>().state is DashboardLoadedState
                      ? (context.read<DashboardBloc>().state
                              as DashboardLoadedState)
                          .userProfile
                          .username
                      : '',
                ),
              );
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: state is BookingLoadingState
              ? const Center(child: CircularProgressIndicator())
              : state is BookingsLoadedState
                  ? state.bookings.isEmpty
                      ? const Center(child: Text('No bookings found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.bookings.length,
                          itemBuilder: (context, index) {
                            final booking = state.bookings[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  booking.remark,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          booking.dateTime
                                              .toString()
                                              .split('.')[0],
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: booking.status == 'In Progress'
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        booking.status,
                                        style: TextStyle(
                                          color: booking.status == 'In Progress'
                                              ? Colors.blue
                                              : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                  : Center(
                      child: Text(
                        state is BookingErrorState
                            ? state.message
                            : 'Unknown error',
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingScreen()),
              );
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Booking',
          ),
        );
      },
    );
  }

  Widget _buildChatView() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocProvider(
            create: (context) => ChatBloc(
              snapshot.data!,
              context.read<ChatRepository>(),
            ),
            child: const ChatScreen(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProfileView() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardErrorState) {
          return Center(child: Text(state.message));
        } else if (state is DashboardLoadedState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          state.userProfile.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.userProfile.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        state.userProfile.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildDashboardCard(
                  context,
                  title: 'Complete/Update Profile',
                  subtitle: 'Update your profile information',
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('School'),
                  subtitle: Text(state.userProfile.schoolName),
                ),
                ListTile(
                  leading: const Icon(Icons.grade_outlined),
                  title: const Text('Standard'),
                  subtitle: Text('${state.userProfile.standard}'),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Medium'),
                  subtitle: Text(state.userProfile.medium),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Mobile'),
                  subtitle: Text(state.userProfile.mobileNumber),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("GakudoAI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: _buildCurrentView(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Test',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
