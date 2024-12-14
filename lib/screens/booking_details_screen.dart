import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              title: 'Session Details',
              details: [
                'Date: ${_formatDate(booking.sessionDate)}',
                'Time: ${booking.timeSlot}',
                'Status: ${booking.status}',
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailCard(
              title: 'Payment Details',
              details: [
                'Amount: ₹${booking.amount}',
                'Booking ID: ${booking.id}',
                'Created: ${_formatDate(booking.createdAt)}',
              ],
            ),
            if (booking.status == 'confirmed') ...[
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle reschedule
                      },
                      child: Text(
                        'Reschedule',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle cancel
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<String> details,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...details.map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    detail,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 