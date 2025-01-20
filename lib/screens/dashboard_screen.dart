import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rx_logix/bloc/payment_bloc.dart';
import 'package:rx_logix/bloc/payment_event.dart';
import 'package:rx_logix/bloc/payment_state.dart';
import 'package:rx_logix/constants/storage_constants.dart';
import 'package:rx_logix/models/user_profile.dart';
import 'package:rx_logix/repositories/auth/auth_repository_impl.dart';
import 'package:rx_logix/repositories/chat/chat_repository.dart';
import 'package:rx_logix/screens/booking_details_screen.dart';
import 'package:rx_logix/screens/booking_screen.dart';
import 'package:rx_logix/screens/payment_dialog.dart';
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
          context.read<BookingBloc>().add(
                FetchBookingsEvent(
                  context.read<DashboardBloc>().state is DashboardLoadedState
                      ? (context.read<DashboardBloc>().state as DashboardLoadedState)
                          .userProfile
                          .username
                      : '',
                ),
              );
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.background.withOpacity(0.95),
                ],
              ),
            ),
            child: state is BookingLoadingState
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state is BookingsLoadedState
                    ? state.bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No Bookings Yet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Create your first booking by tapping the + button',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BookingScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Booking'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<BookingBloc>().add(
                                    FetchBookingsEvent(
                                      context.read<DashboardBloc>().state is DashboardLoadedState
                                          ? (context.read<DashboardBloc>().state as DashboardLoadedState)
                                              .userProfile
                                              .username
                                          : '',
                                    ),
                                  );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.bookings.length,
                              itemBuilder: (context, index) {
                                final booking = state.bookings[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingDetailsScreen(booking: booking),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(
                                                    Icons.event_note,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        booking.remark,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 16,
                                                            color: Colors.grey[600],
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            booking.dateTime.toString().split('.')[0],
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(booking.status).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _getStatusIcon(booking.status),
                                                        size: 16,
                                                        color: _getStatusColor(booking.status),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        booking.status,
                                                        style: TextStyle(
                                                          color: _getStatusColor(booking.status),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (booking.status.toLowerCase() == "payment pending")
                                                  ElevatedButton.icon(
                                                    onPressed: ()async {
                                                  
    final userProfile = await UserService.getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageConstants.authToken);
     final bookingBloc = BlocProvider.of<BookingBloc>(context);
            final createdOrder = await AuthRepositoryImpl().createOrder(userProfile?.username??"", token??"", 'session');
if(createdOrder.isNotEmpty){
   showDialog(
      context: context,
      builder: (buildContext) => PaymentDialog(
        username: userProfile?.username??"", // Replace with actual username
        feature: 'session',
        originalPrice: createdOrder['amount']/100.toDouble(),
        discountedPrice: createdOrder['amount_due']/100.toDouble(),onPaynow: (){
Navigator.pop(buildContext);
    context.read<PaymentBloc>().add(
      InitiatePaymentEvent(sessionId:booking.id ,
        username: userProfile?.username??"",createdOrder: createdOrder,
        token: token ?? "",
        feature: "session",
        postPayment: () => (){
        context.read<BookingBloc>().add(FetchBookingsEvent(userProfile?.username??""));
        }, // Pass your createBooking function
      ),
    );
  
                                                   
        },
      ),
    );
}
 },
                                                    icon: const Icon(Icons.payment, size: 18),
                                                    label: const Text('Pay Now'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state is BookingErrorState ? state.message : 'Unknown error',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('New Booking'),
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
            icon: const Icon(Icons.payment),
            onPressed: () async {
             final prefs = await SharedPreferences.getInstance();
             final token = prefs.getString(StorageConstants.authToken);
             final userProfile = await UserService.getCurrentUser();
             showDialog(
               context: context,
               builder: (BuildContext buildContext) {
                 return AlertDialog(
                   title: Text("Payment Consent"),
                   content: Text("By clicking 'Yes', you consent to make payment for all features (chat, tests, and booking a session)."),
                   actions: [
                     TextButton(
                       child: Text("Yes"),
                       onPressed: () {
                         context.read<PaymentBloc>().add(InitiatePaymentEvent(
                           username: userProfile?.username??"",
                           token: token??"",
                           feature: "all",
                           postPayment: () => {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful")))
                           },
                         ));
                         Navigator.of(buildContext).pop();
                       },
                     ),
                     TextButton(
                       child: Text("No"),
                       onPressed: () {
                         Navigator.of(buildContext).pop();
                       },
                     ),
                   ],
                 );
               },
             );
            },
          ),
          if(_selectedIndex==4)
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payment pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'payment pending':
        return Icons.payment;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}
