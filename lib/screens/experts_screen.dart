import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/experts_bloc.dart';
import '../bloc/experts_event.dart';
import '../bloc/experts_state.dart';
import '../models/expert.dart';
import '../constants/string_constants.dart';
import '../constants/app_constants.dart';
import 'booking_screen.dart';

class ExpertsScreen extends StatelessWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpertsBloc()..add(LoadExpertsEvent()),
      child: const ExpertsView(),
    );
  }
}

class ExpertsView extends StatelessWidget {
  const ExpertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.bookSession),
      ),
      body: BlocBuilder<ExpertsBloc, ExpertsState>(
        builder: (context, state) {
          if (state is ExpertsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpertsLoadedState) {
            return ListView.builder(
              padding: EdgeInsets.all(AppConstants.spacingM),
              itemCount: state.experts.length,
              itemBuilder: (context, index) {
                final expert = state.experts[index];
                return ExpertCard(expert: expert);
              },
            );
          }

          if (state is ExpertsErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class ExpertCard extends StatelessWidget {
  final Expert expert;

  const ExpertCard({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(expert.imageUrl),
              radius: AppConstants.profileImageS / 2,
            ),
            title: Text(
              expert.name,
              style: TextStyle(
                fontSize: AppConstants.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(expert.specialization),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${StringConstants.experience}: ${expert.experience}'),
                SizedBox(height: AppConstants.spacingXXS),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: AppConstants.iconS),
                    SizedBox(width: AppConstants.spacingXXS),
                    Text('${expert.rating}'),
                  ],
                ),
                SizedBox(height: AppConstants.spacingXXS),
                Text(
                  '₹${expert.pricePerHour.toStringAsFixed(2)}${StringConstants.pricePerHour}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  // View expert profile
                },
                child: Text(StringConstants.viewProfile),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(expert: expert),
                    ),
                  );
                },
                child: Text(StringConstants.bookSession),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 