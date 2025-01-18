import 'package:flutter/material.dart';

class PaymentDialog extends StatelessWidget {
  final String username;
  final String feature;
  final double originalPrice;
  final double discountedPrice;
  final Function onPaynow;

  const PaymentDialog({
    Key? key,
    required this.username,
    required this.feature,
    required this.originalPrice,
    required this.discountedPrice,
    required this.onPaynow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'GakudoAI Payment Page',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Username:', username),
            const SizedBox(height: 12),
            _buildInfoRow('Feature:', feature),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Original Price:',
              '₹${originalPrice.toStringAsFixed(2)}',
              isStrikeThrough: true,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Discounted Price:',
              '₹${discountedPrice.toStringAsFixed(2)}',
              isDiscounted: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:(){
                  onPaynow();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'PAY NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isStrikeThrough = false, bool isDiscounted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isStrikeThrough ? TextDecoration.lineThrough : null,
            color: isDiscounted ? Colors.red : null,
          ),
        ),
      ],
    );
  }
} 