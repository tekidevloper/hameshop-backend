import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import "../features/payment/chapa_payment_screen.dart";
import "../features/payment/bank_transfer_screen.dart";

class PaymentService {
  static Future<void> initiatePayment(BuildContext context, double amount, {String productName = 'Product'}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox.shrink(),
            ),
            Center(
              child: Text(
                'select_payment_method'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${'total'.tr()}: ${amount.toStringAsFixed(2)} ETB',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPaymentOption(
              context,
              icon: Icons.credit_card_rounded,
              color: Colors.green,
              title: 'chapa_payment'.tr(),
              subtitle: 'Secure online payment gateway',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapaPaymentScreen(
                      amount: amount,
                      productName: productName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              icon: Icons.account_balance_rounded,
              color: Colors.indigo,
              title: 'bank_transfer'.tr(),
              subtitle: 'Direct transfer to local banks',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankTransferScreen(
                      amount: amount,
                      productName: productName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              icon: Icons.telegram_rounded,
              color: const Color(0xFF0088CC),
              title: 'telegram_order'.tr(),
              subtitle: 'telegram_to_admin'.tr(),
              onTap: () async {
                final Uri url = Uri.parse('https://t.me/Hameee40');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch Telegram')),
                    );
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(),
      ),
    );
  }

  static Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
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
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
