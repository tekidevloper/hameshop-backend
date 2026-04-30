import 'package:flutter/material.dart';
import '../admin/admin_dashboard.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel (Legacy)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('You are viewing the legacy admin panel.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard())),
              child: const Text('Go to Professional Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
