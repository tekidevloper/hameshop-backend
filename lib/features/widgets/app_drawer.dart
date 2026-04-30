import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin/admin_dashboard.dart';
import '../admin/manage_banners_screen.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../profile/support_requests_screen.dart';
import '../profile/profile_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/about_screen.dart';
import '../support/chat_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final primaryColor = Theme.of(context).primaryColor;
    
    return Drawer(
      child: ValueListenableBuilder<UserModel?>(
        valueListenable: userService.currentUser,
        builder: (context, user, child) {
          final items = [
            {'icon': Icons.home_rounded, 'title': 'home'.tr(), 'onTap': () => Navigator.pop(context)},
            {'icon': Icons.person_rounded, 'title': 'profile'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }},
            {'icon': Icons.shopping_bag_rounded, 'title': 'my_orders'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
            }},
            {'icon': Icons.favorite_rounded, 'title': 'wishlist'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
            }},
            {'icon': Icons.shopping_cart_rounded, 'title': 'shopping_cart'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            }},
            {'icon': Icons.settings_rounded, 'title': 'settings'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }},
            {'icon': Icons.info_rounded, 'title': 'about'.tr(), 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
            }},
            {'icon': Icons.auto_awesome_rounded, 'title': 'ai_chat'.tr(), 'color': primaryColor, 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AIChatScreen()));
            }},
            {'icon': Icons.telegram_rounded, 'title': 'Telegram Admin Support', 'color': const Color(0xFF0088CC), 'onTap': () async {
              final Uri url = Uri.parse('https://t.me/Hameee40');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }},
          ];

          if (user?.role == UserRole.admin) {
            items.addAll([
              {'icon': Icons.admin_panel_settings_rounded, 'title': 'Admin Dashboard', 'color': Colors.orange.shade800, 'onTap': () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
              }},
              {'icon': Icons.image_rounded, 'title': 'Manage Banners', 'color': Colors.orange, 'onTap': () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageBannersScreen()));
              }},
            ]);
          }

          items.addAll([
            {'icon': Icons.help_rounded, 'title': 'Support & Requests', 'onTap': () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportRequestsScreen()));
            }},
            {'icon': Icons.logout_rounded, 'title': 'logout'.tr(), 'onTap': () => _showLogoutDialog(context, userService)},
          ]);

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: items.length + 1, // +1 for Header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(context, user);
              }
              
              final item = items[index - 1];
              if (user?.role == UserRole.admin && item['title'] == 'Admin Dashboard') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('ADMINISTRATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.5)),
                    ),
                    _buildDrawerItem(context, item),
                  ],
                );
              }
              
              return _buildDrawerItem(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: const DecorationImage(
          image: AssetImage('assets/admin.jpg'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: _getProfileProvider(user),
                  child: _buildProfilePlaceholder(context, user),
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  user?.name ?? 'Guest User',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                user?.email ?? 'Sign in to access all features',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, Map<String, dynamic> item) {
    final color = item['color'] as Color?;
    return ListTile(
      leading: Icon(item['icon'] as IconData, color: color ?? Colors.grey[700], size: 22),
      title: Text(
        item['title'] as String, 
        style: TextStyle(
          color: color, 
          fontWeight: color != null ? FontWeight.bold : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: item['onTap'] as VoidCallback,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  ImageProvider? _getProfileProvider(UserModel? user) {
    if (user?.profileImage != null) {
      if (user!.profileImage!.startsWith('http')) {
        return CachedNetworkImageProvider(user.profileImage!);
      }
      try {
        // Clean base64 string if it contains metadata prefix
        String base64Str = user.profileImage!;
        if (base64Str.contains(',')) {
          base64Str = base64Str.split(',').last;
        }
        return MemoryImage(base64Decode(base64Str.trim()));
      } catch (e) {
        debugPrint('Error decoding profile image: $e');
      }
    }
    
    // Admin fallback
    if (user?.email == 'tekidevloper@gmail.com' || user?.role == UserRole.admin) {
      return const AssetImage('assets/admin.jpg');
    }
    
    return null;
  }

  Widget? _buildProfilePlaceholder(BuildContext context, UserModel? user) {
    final hasImage = user?.profileImage != null;
    final isAdmin = user?.email == 'tekidevloper@gmail.com' || user?.role == UserRole.admin;
    
    // If no image and not admin, show person icon
    if (!hasImage && !isAdmin) {
      return Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor);
    }
    
    // If we tried to load an image (or admin asset) and it failed/is pending, we let the provider handle it
    // But if decoding failed specifically, we show error icon
    try {
      if (hasImage && !user!.profileImage!.startsWith('http')) {
        String base64Str = user.profileImage!;
        if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
        base64Decode(base64Str.trim());
      }
    } catch (e) {
      return const Icon(Icons.broken_image_rounded, size: 30, color: Colors.red);
    }
    
    return null;
  }

  void _showLogoutDialog(BuildContext context, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('logout'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out from HameShop?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              await userService.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('logout'.tr()),
          ),
        ],
      ),
    );
  }
}
