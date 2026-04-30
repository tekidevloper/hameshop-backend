import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home/home_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final double total;

  const OrderConfirmationScreen({
    super.key,
    required this.orderNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 32),

              Text(
                'order_placed_success'.tr(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              Text(
                'thank_you_order'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Order Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow('order_number'.tr(), orderNumber),
                      const Divider(height: 24),
                      _buildDetailRow('total_amount'.tr(), '${total.toStringAsFixed(2)} ETB'),
                      const Divider(height: 24),
                      _buildDetailRow('status'.tr(), 'processing'.tr(), valueColor: Colors.orange),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

              const Spacer(),

              // Track Order Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to orders
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.local_shipping),
                  label: Text('track_order'.tr(), style: const TextStyle(fontSize: 16)),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 12),

              // Continue Shopping Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.shopping_bag),
                  label: Text('continue_shopping'.tr(), style: const TextStyle(fontSize: 16)),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
