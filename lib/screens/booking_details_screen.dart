import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_logix/bloc/booking_bloc.dart';
import 'package:rx_logix/bloc/booking_event.dart';
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
                'Date: ${_formatDate(booking.dateTime)}',
                'Time: ${_formatTime(booking.dateTime)}',
                'Status: ${booking.status}',
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailCard(
              title: 'Booking Details',
              details: [
                'Booking ID: ${booking.id}',
                'Created: ${_formatDate(booking.dateTime)}',
                'Remark: ${booking.remark}',
              ],
            ),
            if (booking.status.toLowerCase() == 'in progress') ...[
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BookingBloc>().add(
                              RescheduleBookingEvent(
                                bookingId: booking.id,
                                newDateTime: DateTime.now(),
                                timeSlot: '10:00 AM',
                              ),
                            );
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
                        context.read<BookingBloc>().add(
                              CancelBookingEvent(booking.id),
                            );
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
