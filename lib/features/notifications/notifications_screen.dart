import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.fetchNotifications();
  }

  void _markAsRead(String id) {
    _notificationService.markAsRead(id);
  }

  void _markAllAsRead() {
    for (var notification in _notificationService.notifications.value) {
      if (!notification.isRead) {
        _notificationService.markAsRead(notification.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _notificationService.unreadCount,
            builder: (context, count, child) {
              if (count > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _notificationService.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading && _notificationService.notifications.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<NotificationModel>>(
            valueListenable: _notificationService.notifications,
            builder: (context, notifications, child) {
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No notifications', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _notificationService.fetchNotifications(),
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isRead = notification.isRead;
                    
                    IconData iconData;
                    Color color;
                    
                    switch (notification.type) {
                      case 'order':
                        iconData = Icons.local_shipping;
                        color = Colors.blue;
                        break;
                      case 'promo':
                        iconData = Icons.local_offer;
                        color = Colors.orange;
                        break;
                      default:
                        iconData = Icons.notifications;
                        color = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: color),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification.message),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(notification.date),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _markAsRead(notification.id),
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
