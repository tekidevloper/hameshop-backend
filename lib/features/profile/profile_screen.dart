import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import 'support_requests_screen.dart';
import '../../services/user_service.dart';
import 'edit_profile_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../widgets/ui_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<UserModel?>(
        valueListenable: UserService().currentUser,
        builder: (context, user, child) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Sign In'),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Hero(
                  tag: 'profile_pic',
                  child: ClipOval(
                    child: ProductImage(
                      imageUrl: user.profileImage ?? '',
                      width: 100,
                      height: 100,
                      placeholder: Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ).animate().scale(duration: 500.ms),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == UserRole.admin ? Colors.orange.withAlpha(25) : Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: user.role == UserRole.admin ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildProfileItem(context, Icons.shopping_bag_outlined, 'My Orders', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
                }),
                _buildProfileItem(context, Icons.favorite_outline, 'Wishlist', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                }),
                _buildProfileItem(context, Icons.location_on_outlined, 'shipping_address'.tr(), () {
                  Navigator.pushNamed(context, '/shipping_address');
                }),
                _buildProfileItem(context, Icons.help_outline, 'Support & Requests', () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportRequestsScreen()));
                }),
                _buildProfileItem(context, Icons.info_outline, 'about'.tr(), () {
                  Navigator.pushNamed(context, '/about');
                }),
                _buildProfileItem(context, Icons.lock_outline, 'Security & Password', () {
                  Navigator.pushNamed(context, '/change-password');
                }),
                 const Divider(indent: 20, endIndent: 20),
                 _buildProfileItem(context, Icons.logout, 'logout'.tr(), () {
                    _showLogoutDialog(context);
                 }, iconColor: Colors.red, textColor: Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor, Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: textColor != null ? FontWeight.bold : null)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout'.tr()),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              await UserService().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('logout'.tr()),
          ),
        ],
      ),
    );
  }
}
