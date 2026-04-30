import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_users'.tr()),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(child: Text('no_users_found'.tr()));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.role == UserRole.admin ? Colors.orange.withAlpha(25) : Colors.blue.withAlpha(25),
                    child: Icon(
                      user.role == UserRole.admin ? Icons.admin_panel_settings : Icons.person,
                      color: user.role == UserRole.admin ? Colors.orange : Colors.blue,
                    ),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      if (user.phone != null) Text('${'phone'.tr()}: ${user.phone}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.role == UserRole.admin ? Colors.orange.withAlpha(25) : Colors.blue.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: 4),
                          if (user.createdAt != null)
                            Text(
                              '${'joined'.tr()}: ${DateFormat('MMM dd, yyyy').format(user.createdAt!)}',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          user.role == UserRole.admin ? Icons.arrow_downward : Icons.arrow_upward,
                          color: user.role == UserRole.admin ? Colors.blue : Colors.orange,
                        ),
                        onPressed: () => _toggleRole(user),
                        tooltip: user.role == UserRole.admin ? 'demote_customer'.tr() : 'promote_admin'.tr(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleRole(UserModel user) async {
    final newRole = user.role == UserRole.admin ? UserRole.customer : UserRole.admin;
    final action = newRole == UserRole.admin ? 'promote' : 'demote';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('toggle_user_role'.tr()),
        content: Text('confirm_toggle_role'.tr(namedArgs: {
          'action': action.tr(),
          'name': user.name,
          'role': newRole.name.tr(),
        })),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newRole == UserRole.admin ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(action.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _userService.updateUserRole(user.id, newRole);
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('successfully_updated'.tr(namedArgs: {'action': action.tr(), 'name': user.name}))),
        );
        setState(() {}); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('response_failed'.tr()), backgroundColor: Colors.red),
        );
      }
    }
  }
}
