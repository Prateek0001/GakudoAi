import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../services/user_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Session'),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is BookingCreatedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking created successfully')),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDatePicker(context),
                  const SizedBox(height: 24),
                  _buildTimePicker(context),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  if (state is BookingLoadingState)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _canBook() ? () => _createBooking(context) : null,
                        child: const Text('Book Session'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(_selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Pick a date'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Time'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(_selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Pick a time'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool _canBook() {
    return _selectedDate != null &&
        _selectedTime != null &&
        _remarkController.text.isNotEmpty;
  }

  Future<void> _createBooking(BuildContext context) async {
    final userProfile = await UserService.getCurrentUser();
    if (userProfile != null && _selectedDate != null && _selectedTime != null) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      context.read<BookingBloc>().add(
            CreateBookingEvent(
              username: userProfile.username,
              dateTime: dateTime,
              remark: _remarkController.text,
            ),
          );
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}
