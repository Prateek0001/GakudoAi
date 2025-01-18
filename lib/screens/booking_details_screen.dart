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
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBanner(context),
              SizedBox(height: 24.h),
              _buildDetailCard(
                context,
                title: 'Session Details',
                icon: Icons.event,
                details: [
                  DetailItem(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _formatDate(booking.dateTime),
                  ),
                  DetailItem(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _formatTime(booking.dateTime),
                  ),
                  DetailItem(
                    icon: _getStatusIcon(booking.status),
                    label: 'Status',
                    value: booking.status,
                    valueColor: _getStatusColor(context, booking.status),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildDetailCard(
                context,
                title: 'Booking Information',
                icon: Icons.info_outline,
                details: [
                  DetailItem(
                    icon: Icons.numbers,
                    label: 'Booking ID',
                    value: booking.id,
                  ),
                  DetailItem(
                    icon: Icons.event_available,
                    label: 'Created',
                    value: _formatDate(booking.dateTime),
                  ),
                  DetailItem(
                    icon: Icons.note,
                    label: 'Remark',
                    value: booking.remark,
                  ),
                ],
              ),
              if (booking.status.toLowerCase() == 'in progress') ...[
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<BookingBloc>().add(
                                RescheduleBookingEvent(
                                  bookingId: booking.id,
                                  newDateTime: DateTime.now(),
                                  timeSlot: '10:00 AM',
                                ),
                              );
                        },
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          'Reschedule',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelConfirmation(context);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getStatusColor(context, booking.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(context, booking.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _getStatusColor(context, booking.status).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: _getStatusColor(context, booking.status),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.status,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(context, booking.status),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getStatusMessage(booking.status),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<DetailItem> details,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...details.map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Icon(
                        detail.icon,
                        size: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            detail.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: detail.valueColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BookingBloc>().add(CancelBookingEvent(booking.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.pending;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your booking has been confirmed';
      case 'in progress':
        return 'Your session is currently in progress';
      case 'completed':
        return 'This session has been completed';
      case 'cancelled':
        return 'This booking was cancelled';
      default:
        return 'Booking status information';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
