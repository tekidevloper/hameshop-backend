import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('profile'.tr())), body: const Center(child: Text('Profile')));
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Admin Panel')), body: const Center(child: Text('Admin Panel')));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('settings'.tr())), body: const Center(child: Text('Settings')));
  }
}
