import 'package:flutter/material.dart';
import 'package:rx_logix/bloc/payment_event.dart';
import 'package:rx_logix/repositories/auth/auth_repository_impl.dart';
import 'package:rx_logix/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import 'package:rx_logix/bloc/payment_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool isLoading = true;
  Map<String, dynamic>? paymentStatus;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPaymentStatus();
  }

  Future<void> _loadPaymentStatus() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.authToken);
      final userProfile = await UserService.getCurrentUser();

      if (token == null || userProfile == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentStatusEndpoint}?username=${userProfile.username}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentStatus = {
            'report': data['report_pmt_status'] ?? false,
            'chat': data['chat_pmt_status'] ?? false,
            'session': data['session_pmt_status'] != null && 
                       data['session_pmt_status'].isNotEmpty && 
                       data['session_pmt_status'][0].values.first ?? false,
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load payment status');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasUnpaidFeature = paymentStatus != null &&
        (!(paymentStatus?['report'] ?? false) ||
         !(paymentStatus?['chat'] ?? false) ||
         !(paymentStatus?['session'] ?? false));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadPaymentStatus,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPaymentStatus,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildStatusCard(
                              title: 'Report Payment',
                              isPaid: paymentStatus?['report'] ?? false,
                              icon: Icons.description,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            _buildStatusCard(
                              title: 'Chat Payment',
                              isPaid: paymentStatus?['chat'] ?? false,
                              icon: Icons.chat_bubble,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            _buildStatusCard(
                              title: 'Session Payment',
                              isPaid: paymentStatus?['session'] ?? false,
                              icon: Icons.calendar_today,
                              color: Colors.purple,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
          ),
          if (hasUnpaidFeature && !isLoading && error == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString(StorageConstants.authToken);
                    final userProfile = await UserService.getCurrentUser();
                    
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext buildContext) {
                          return AlertDialog(
                            title: const Text("Payment Consent"),
                            content: const Text(
                              "By clicking 'Yes', you consent to make payment for all features (chat, tests, and booking a session)."
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Yes"),
                                onPressed: () {
                                  context.read<PaymentBloc>().add(
                                    InitiatePaymentEvent(
                                      username: userProfile?.username ?? "",
                                      token: token ?? "",
                                      feature: "all",
                                      postPayment: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Payment Successful")
                                          )
                                        );
                                        _loadPaymentStatus(); // Refresh the status
                                      },
                                    ),
                                  );
                                  Navigator.of(buildContext).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("No"),
                                onPressed: () {
                                  Navigator.of(buildContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pay for All Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required bool isPaid,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
        child: Padding(
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.pending,
                          size: 16,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPaid ? 'Paid' : 'Pending',
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {
                    // Handle payment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pay Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 