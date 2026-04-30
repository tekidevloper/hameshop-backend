import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<List<NotificationModel>> notifications = ValueNotifier<List<NotificationModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        notifications.value = data.map((json) => NotificationModel.fromJson(json)).toList();
        unreadCount.value = notifications.value.where((n) => !n.isRead).length;
      }
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await ApiClient().dio.put('/notifications/$id/read');
      if (response.statusCode == 200) {
        await fetchNotifications();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendNotification({required String title, required String message, required String type, required String userId}) async {
    try {
      await ApiClient().dio.post('/notifications', data: {
        'title': title,
        'message': message,
        'type': type,
        'userId': userId,
      });
    } catch (e) {
      debugPrint('Send notification error: $e');
    }
  }
}
