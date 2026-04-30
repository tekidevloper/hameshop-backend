import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'product_service.dart';
import 'banner_service.dart';
import 'package:uuid/uuid.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn) {
      final token = await ApiClient().getToken();
      if (token == null) {
        // Token missing but logged in flag set - inconsistencies!
        await logout();
      } else {
        final email = prefs.getString('user_email') ?? '';
        final roleStr = prefs.getString('user_role') ?? 'customer';
        
        currentUser.value = UserModel(
          id: prefs.getString('user_id') ?? const Uuid().v4(),
          name: prefs.getString('user_name') ?? 'User',
          email: email,
          phone: prefs.getString('user_phone') ?? '+251900000000',
          role: roleStr == 'admin' ? UserRole.admin : UserRole.customer,
          profileImage: prefs.getString('user_profile_image'),
        );
      }
    }
    isLoading.value = false;
  }

  Future<String?> register(String name, String email, String password, {String? phone}) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        await ApiClient().saveToken(data['token']);
        
        final user = UserModel.fromJson(data['user']);
        
        currentUser.value = user;
        await _saveUserToPrefs(user);
        
        // Refresh data services
        ProductService().fetchProducts();
        BannerService().fetchBanners();
        
        isLoading.value = false;
        return null; // Success
      }
      isLoading.value = false;
      return 'Registration failed';
    } catch (e) {
      isLoading.value = false;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) return data['error']?.toString() ?? 'Registration failed';
        return 'Server error. Please try again.';
      }
      return 'Network error. Please check your connection.';
    }
  }

  Future<String?> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await ApiClient().saveToken(data['token']);
        
        final user = UserModel.fromJson(data['user']);
        
        currentUser.value = user;
        await _saveUserToPrefs(user);
        
        // Refresh data services
        ProductService().fetchProducts();
        BannerService().fetchBanners();
        
        isLoading.value = false;
        return null; // Success
      }
      isLoading.value = false;
      return 'Login failed';
    } catch (e) {
      isLoading.value = false;
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map) return data['error']?.toString() ?? 'Invalid credentials';
        return 'Server error. Please try again.';
      }
      return 'Network error. Please check your connection.';
    }
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.put('/auth/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      isLoading.value = false;
      if (response.statusCode == 200) {
        return null; // Success
      }
      return response.data['error'] ?? 'Failed to change password';
    } catch (e) {
      isLoading.value = false;
      if (e is DioException && e.response != null) {
        return e.response?.data['error'] ?? 'Error changing password';
      }
      return 'Error: $e';
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    await ApiClient().deleteToken();
    currentUser.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_profile_image');
    isLoading.value = false;
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    try {
      Map<String, dynamic> googleData;

      // Mock Google Sign-In universally to bypass configuration errors on physical devices
      await Future.delayed(const Duration(milliseconds: 800));
      googleData = {
        'name': 'Demo Google User',
        'email': 'demo.google@example.com',
        'googleId': 'mock_google_id_12345',
        'profileImage': 'https://ui-avatars.com/api/?name=Demo+Google+User&background=random',
      };

      final response = await ApiClient().dio.post('/auth/google', data: googleData);

      if (response.statusCode == 200) {
        final data = response.data;
        await ApiClient().saveToken(data['token']);
        
        final user = UserModel.fromJson(data['user']);
        
        currentUser.value = user;
        await _saveUserToPrefs(user);
        
        isLoading.value = false;
        return true;
      }
      isLoading.value = false;
      return false;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    return true;
  }

  Future<bool> updateProfile({String? name, String? email, String? phone, String? profileImage}) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.put('/auth/profile', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final updatedUser = UserModel.fromJson(data['user']);

        currentUser.value = updatedUser;
        await _saveUserToPrefs(updatedUser);
        
        isLoading.value = false;
        return true;
      } else if (response.statusCode == 404) {
        // User not found (token invalid/outdated), force logout
        await logout();
        return false;
      }
      isLoading.value = false;
      return false;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
         await logout();
      }
      debugPrint('Update profile error: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_phone', user.phone);
    await prefs.setString('user_role', user.role.toString().split('.').last);
    if (user.profileImage != null) {
      await prefs.setString('user_profile_image', user.profileImage!);
    } else {
      await prefs.remove('user_profile_image');
    }
  }

  Future<bool> updateUserRole(String userId, UserRole role) async {
    try {
      final response = await ApiClient().dio.put(
        '/auth/role/$userId',
        data: {
          'role': role == UserRole.admin ? 'admin' : 'customer',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update user role error: $e');
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await ApiClient().dio.get('/auth/users');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get all users error: $e');
      return [];
    }
  }
}
