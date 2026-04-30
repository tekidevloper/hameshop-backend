import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';
import 'manage_banners_screen.dart';
import 'manage_requests_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'overview'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Total Sales', '45,200 ETB', Icons.trending_up, Colors.green),
                _buildStatCard(context, 'Orders', '128', Icons.shopping_bag, Colors.blue),
                _buildStatCard(context, 'Customers', '1,024', Icons.people, Colors.orange),
                _buildStatCard(context, 'Products', '24', Icons.inventory, Colors.purple),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            Text(
              'quick_actions'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              'Manage Products',
              'Update stock, prices, and info',
              Icons.edit_note,
              Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProductsScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Order Management',
              'Track and update order status',
              Icons.local_shipping,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageOrdersScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'User Management',
              'View and manage customers',
              Icons.person_search,
              Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageUsersScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Manage Banners',
              'Customize home screen banners',
              Icons.image,
              Colors.teal,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageBannersScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Manage Requests',
              'Handle user support & feedback',
              Icons.support_agent,
              Colors.red,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRequestsScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Security & Password',
              'Change your admin password',
              Icons.lock_outline,
              Colors.orange,
              () => Navigator.pushNamed(context, '/change-password'),
            ),
            
            const SizedBox(height: 32),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.history, color: Colors.grey),
                  ),
                  title: Text('New order #HS-12$index'),
                  subtitle: const Text('2 minutes ago'),
                  trailing: const Text('850 ETB', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
