import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderService().getOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(
                      'Order #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(DateFormat('MMM dd, yyyy').format(order.date)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${order.total.toStringAsFixed(2)} ETB',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Items:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: item.productImage,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                            Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${item.price.toStringAsFixed(2)} ETB',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )),
                            if (order.trackingNumber != null) ...[
                              const Divider(),
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Tracking: ${order.trackingNumber}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
              },
            ),
    );
  }
}
