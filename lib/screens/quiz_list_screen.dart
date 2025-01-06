import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rx_logix/bloc/payment_bloc.dart';
import 'package:rx_logix/bloc/payment_event.dart';
import 'package:rx_logix/bloc/payment_state.dart';
import 'package:rx_logix/constants/storage_constants.dart';
import 'package:rx_logix/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import 'quiz_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocListener<PaymentBloc, PaymentState>(
      listener: (context, paymentState) {
        if (paymentState is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(paymentState.message)),
          );
        }else if (paymentState is PaymentSuccess){
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment successful")),
          );
        }
        // Handle other payment states if needed
      },child:Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Tests',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete all tests to generate your performance report',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                _buildQuizCard(
                  context,
                  number: 1,
                  duration: '30 Min',
                  icon: Icons.assignment,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 20),
                _buildQuizCard(
                  context,
                  number: 2,
                  duration: '30 Min',
                  icon: Icons.psychology,
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 20),
                _buildQuizCard(
                  context,
                  number: 3,
                  duration: '45 Min',
                  icon: Icons.lightbulb,
                  color: const Color(0xFFF44336),
                ),
                const SizedBox(height: 20),
                _buildQuizCard(
                  context,
                  number: 4,
                  duration: '30 Min',
                  icon: Icons.extension,
                  color: const Color(0xFF9C27B0),
                  isOptional: true,
                ),
                const SizedBox(height: 40),
                _buildGenerateReportButton(context),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required int number,
    required String duration,
    required IconData icon,
    required Color color,
    bool isOptional = false,
  }) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        final isCompleted = state is QuizLoadedState &&
            state.completedQuizzes.contains('$number');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!isCompleted) {
                  // Prevent retaking completed quiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(quizId: '$number'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz already completed')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Quiz Test $number',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isOptional) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Optional',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isCompleted)
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenerateReportButton(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ReportGeneratedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report generated successfully')),
          );
        } else if (state is ReportDownloadLinkReceivedState) {
          // Launch URL using url_launcher package
          launchUrl(Uri.parse(state.downloadLink));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: state is ReportGeneratedState
                      ? [Colors.grey, Colors.grey.shade600]
                      : [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state is ReportGeneratedState
                      ? null
                      : () async {
                        final userProfile =
                              await UserService.getCurrentUser();
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString(StorageConstants.authToken);
context.read<PaymentBloc>().add(InitiatePaymentEvent(
                username: userProfile?.username??"",
                token: token??"",
                feature: "report",
                postPayment: () => {
                    if (userProfile != null) {
                            context
                                .read<QuizBloc>()
                                .add(GenerateReportEvent(userProfile.username))
                          }
                },
              
              )); 

                        
                          
                        
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.assessment_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generate Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state is ReportGeneratedState) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final userProfile = await UserService.getCurrentUser();
                      if (userProfile != null) {
                        context
                            .read<QuizBloc>()
                            .add(DownloadReportEvent(userProfile.username));
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.download_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Download Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
